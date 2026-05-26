Feature: Gestión de pagos

  Background:
    * url baseUrl
    * def headers = read('classpath:data/auth-headers.json')
    * configure headers = headers

#  Escenario fuera del alcance por reglas de negocio y dependencia con Wompi
#  Scenario: Generar firma de integración exitosamente (Usuario con cuota pendiente)
#    Given path 'auth/login'
#    And request { "email": "yinaa56@hotmail.com", "password": "P@ssword123!" }
#    When method POST
#    * def token = response.data.token
#
#  # importante: Aquí usamos un grupo que tenga cuotas por pagar
#    Given path 'payment/create-integration-signature'
#    And header Authorization = 'Bearer ' + token
#    And request { "savingGroupId": 9, "amount": 150000 }
#    When method POST
#  # Si el usuario tiene deuda, el sistema responde 201
#    Then status 201
#    And match response.data.signature == '#notnull'
#    * print 'Firma de seguridad generada con éxito:', response.data.signature
#-------------------------------------------------------------------
  Scenario: Validar que el sistema detecta cuando no hay cuotas pendientes
    Given path 'auth/login'
    And request { "email": "yinaa56@hotmail.com", "password": "P@ssword123!" }
    When method POST
    * def token = response.data.token

    Given path 'payment/create-integration-signature'
    And header Authorization = 'Bearer ' + token
    And request { "savingGroupId": 9, "amount": 150000 }
    When method POST
  # valida que el negocio dice que no se puede cobrar si no se debe
    Then status 401
    And match response.message == "There are no pending installments to pay"
    * print 'respuesta de petición:', response

  Scenario: Validar error en pago por datos insuficientes
    Given path 'auth/login'
    And request { "email": "yinaa56@hotmail.com", "password": "P@ssword123!" }
    When method POST
    * def token = response.data.token
    Given path 'payment/create'
    And header Authorization = 'Bearer ' + token
  # se envia un request vacío o incompleto para forzar el error
    And request { "event": "transaction.updated", "data": {} }
    When method POST
    Then status 400
    And match response.statusCode == 400
    And match response.message != null
    * print 'respuesta de petición:', response

  Scenario: Validar que el sistema protege contra pagos dobles o innecesarios
    Given path 'auth/login'
   And request { "email": "yinaa56@hotmail.com", "password": "P@ssword123!" }
   When method POST
    * def token = response.data.token
    Given path 'payment/create-integration-signature'
    And header Authorization = 'Bearer ' + token
    And request { "savingGroupId": 9, "amount": 150000 }
    When method POST
    Then status 401
    And match response.message == "There are no pending installments to pay"
    * print 'respuesta de petición:', response
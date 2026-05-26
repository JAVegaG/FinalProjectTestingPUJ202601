Feature: Gestión de datos demograficos

  Background:
    * url baseUrl
    * path 'demographics'
    * def demogrphicsHeaders = read('classpath:data/auth-headers.json')
    * configure headers = demogrphicsHeaders

  Scenario: Obtener lista de géneros demograficos
    Given path 'gender'
    When method GET
    Then status 200
    And match response.data contains { id: 'F', label: 'FEMALE' }, { id: 'M', label: 'MALE' }
    * print 'respuesta de petición:', response

  Scenario: Validar respuesta ante recurso no encontrado
    Given path 'ruta-falsa'
    When method GET
    Then status 404
    And match response == { statusCode: 404, message: 'Cannot GET /web-api-circles/1.0/demographics/ruta-falsa'}
    * print 'respuesta de petición:', response

  Scenario: Obtener lista de estados civiles exitosamente
    Given path 'marital-status'
    And header Accept = '*/*'
    When method GET
    Then status 200
    And match response.data == '#[]'
    And match each response.data contains { id: '#notnull', label: '#string'}
    * print 'respuesta de petición:', response

  Scenario: Fallo por tipo de dato incorrecto
    Given path 'marital-status'
    When method GET
    Then status 200
    And match each response.data == { id: '#string', label: '#string' }
    * print 'respuesta de petición:', response

  Scenario: Verificar manejo de errores ante peticiones inválidas a estados civiles
    Given path 'marital-status'
    And request { }
    When method POST
    Then status 404
    And match response == { statusCode: 404, message: "#string" }
    * print 'respuesta de petición:', response

  Scenario: Obtener lista de niveles educativos exitosamente
    Given path 'educational-level'
    When method GET
    Then status 200
    And match each response.data == { id: '#number', label: '#string' }
    And match response != []
    * print 'respuesta de petición:', response

  Scenario: Validar que el catálogo de niveles educativos no esté vacío
    Given path 'educational-level'
    When method GET
    Then status 200
    And match response.data != []
    And match response.data == '#[9]'
    * print 'respuesta de petición:', response

  Scenario: Consultar catálogo de estratos socioeconómicos
    Given path 'stratum'
    When method GET
    Then status 200
    And match each response.data == { id: '#number', label: '#string' }
    And match response.data[0].label == 'ONE'
    * print 'respuesta de petición:', response

  Scenario: Verificación de listado completo de estratos
    Given path 'stratum'
    When method GET
    Then status 200
  # El negocio espera exactamente 6 estratos según el contrato de servicio
  # Fallará si la lista tiene más o menos elementos
    And match response.data == '#[6]'
   * print 'response:', response

  Scenario: Validación de rechazo de caracteres especiales en url
    Given path 'stratum', '%00'
    When method GET
    Then status 404
    And match response == { statusCode: 404, message: '#string' }
    * print 'respuesta de petición:', response

  Scenario: Consultar catálogo de etnias
    Given path 'ethnicity'
    When method GET
    Then status 200
  # se valida que catálogo sea inclusivo y contenga opciones válidas
    And match each response.data == { id: '#number', label: '#string' }
    And match response.data[*].label contains 'NONE'
    * print 'respuesta de petición:', response

  Scenario: Validar que el catálogo de etnias no esté vacío
    Given path 'ethnicity'
    When method GET
    Then status 200
  # El negocio requiere que existan opciones para no excluir a nadie
  # Fallará si la lista llega vacía (size 0)
    * def listSize = response.data.length
    And assert listSize > 0
    * print 'respuesta de petición:', response
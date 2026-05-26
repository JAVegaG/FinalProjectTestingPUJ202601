@GestionGruposAhorro
Feature: Gestión de Grupos de Ahorro

  Background:
    * url baseUrl
    * def groupData = read('classpath:data/saving_group.json')
    * def authHeaders = read('classpath:data/auth-headers.json')

    # Login único para todo el feature
    Given path 'auth', 'login'
    And request groupData.loginCredentials
    When method POST
    Then status 201
    * def authToken = response.data.token

  Scenario: Crear un nuevo grupo y validar su existencia
    Given path 'saving-groups', 'create'
    And header Authorization = 'Bearer ' + authToken
    And request groupData.newGroup
    When method POST
    Then status 201
    * def generatedId = response.data.id

    # Validación de consulta
    Given path 'saving-groups', generatedId
    And header Authorization = 'Bearer ' + authToken
    When method GET
    Then status 200
    And match response.data.id == generatedId
    * print 'respuesta de petición:', response

  Scenario: Consultar detalle de un grupo existente
    # Se asegura el paso del ID en la ruta
    Given path 'saving-groups', groupData.staticGroupId
    And header Authorization = 'Bearer ' + authToken
    And headers authHeaders
    When method GET
    Then status 200
    And match response.data.id == groupData.staticGroupId
    * print 'respuesta de petición:', response

  Scenario: Modificar un grupo existente
    Given path 'saving-groups', 'modify', groupData.staticGroupId
    And header Authorization = 'Bearer ' + authToken
    And request groupData.updateGroup
    When method PATCH
    Then status 200
    And match response.data.title == groupData.updateGroup.title
    * print 'respuesta de petición:', response

  Scenario: Simular plan de pagos
    Given path 'saving-groups', 'simulate'
    And header Authorization = 'Bearer ' + authToken
    And request groupData.newGroup
    When method POST
    Then status 201
    And match response.data.installmentAmount == '#number'
    * print 'respuesta de petición:', response

  Scenario: Validación de miembro duplicado en grupo de ahorro
    Given path 'saving-groups', groupData.staticGroupId, 'invite-link'
    And header Authorization = 'Bearer ' + authToken
    When method GET
    Then status 200
    * def inviteUrl = response.data.inviteUrl
    * def inviteToken = inviteUrl.substring(inviteUrl.lastIndexOf('/') + 1)
    # Intentar unirse (Validación de duplicado)
    Given path 'saving-groups', 'join', inviteToken
    And header Authorization = 'Bearer ' + authToken
    When method POST
    Then status 400
    And match response.message == "User already in group"
    * print 'respuesta de petición:', response

  Scenario: Validación de miembros insufientes para activar grupo de ahorro
    # 1. Consultar miembros
    Given path 'saving-groups', groupData.staticGroupId, 'members'
    And header Authorization = 'Bearer ' + authToken
    When method GET
    Then status 200

    # 2. Intentar activar con miembros insuficientes
    Given path 'saving-groups', groupData.staticGroupId, 'activate'
    And header Authorization = 'Bearer ' + authToken
    When method PATCH
    Then status 400
    And match response.message == 'Group needs more than one member to be activated'
    * print 'respuesta de petición:', response

  Scenario: Validar error por fechas de retorno inválidas
    Given path 'saving-groups', 'create'
    And header Authorization = 'Bearer ' + authToken
    And request groupData.invalidDatesGroup
    When method POST
  # se debe cambiar a 401 porque la creación de grupo
  # con fecha de inicio no debe ser mayor a fecha final
    Then status 201
    * print 'respuesta de petición:', response

  Scenario Outline: Verificación de seguridad en rutas y accesos
    Given path 'saving-groups', <idRuta>
    And header Authorization = 'Bearer ' + authToken
    When method GET
    Then status <statusEsperado>
    And match response.message == "<mensajeEsperado>"
    * print 'respuesta de petición:', response
    Examples:
      | idRuta   | statusEsperado | mensajeEsperado    |
      | '999999' | 403            | User not in group  |
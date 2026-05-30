@GestionGruposAhorro @F-04
Feature: Gestión de Grupos de Ahorro > Generación de enlace de invitación

  Background:
    * url baseUrl
    * def loginData = read('classpath:data/auth/login.json')
    * def savingGroupCreationData = read('classpath:data/saving_group/create.json')
    * def savingGroupActivationData = read('classpath:data/saving_group/activate.json')
    * def inviteLinkData = read('classpath:data/saving_group/invite_link.json')
    * def loginResult = callonce read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(loginData.validCredentials)' } }
    * def authToken = loginResult.authToken
    * def authHeaders = { Authorization: '#("Bearer " + authToken)' }

  @TC-IL-01
  Scenario: Verificar generación exitosa de enlace de invitación
    # Creo un nuevo saving group
    * copy group = savingGroupCreationData.newGroup
    * def createResult = call read('classpath:helpers/saving_group/create.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', group: '#(group)' } }
    * def savingGroupId = createResult.savingGroupId

    Given path 'saving-groups', savingGroupId, 'invite-link'
    And headers authHeaders
    When method GET
    Then status 200
    And match response.data contains { inviteUrl: '#string' }
    And match response.data.inviteUrl contains 'join='
    * print 'respuesta de petición:', response

  @TC-IL-02
  Scenario: Verificar rechazo de generación de enlace sin autenticación
    # Creo un nuevo saving group
    * copy group = savingGroupCreationData.newGroup
    * def createResult = call read('classpath:helpers/saving_group/create.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', group: '#(group)' } }
    * def savingGroupId = createResult.savingGroupId

    Given path 'saving-groups', savingGroupId, 'invite-link'
    When method GET
    Then status 401
    * print 'respuesta de petición:', response

  @TC-IL-03
  Scenario: Verificar rechazo cuando el grupo no existe
    Given path 'saving-groups', inviteLinkData.invalidGroupIds.notFound, 'invite-link'
    And headers authHeaders
    When method GET
    Then status 404
    * print 'respuesta de petición:', response

  @TC-IL-04
  Scenario: Verificar rechazo cuando el usuario autenticado no pertenece al grupo
    # Creo un nuevo saving group
    * copy group = savingGroupCreationData.newGroup
    * def createResult = call read('classpath:helpers/saving_group/create.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', group: '#(group)' } }
    * def savingGroupId = createResult.savingGroupId

    # Iniciar sesión con usuario ajeno al grupo
    * def externalUserLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.externalUserCredentials)' } }
    * def externalUserAuthHeaders = { Authorization: '#("Bearer " + externalUserLoginResult.authToken)' }

    Given path 'saving-groups', savingGroupId, 'invite-link'
    And headers externalUserAuthHeaders
    When method GET
    Then status 403
    * print 'respuesta de petición:', response

  @TC-IL-05 @DEF-11
  Scenario: Verificar rechazo de identificador alfanumérico
    Given path 'saving-groups', inviteLinkData.invalidGroupIds.alphanumeric, 'invite-link'
    And headers authHeaders
    When method GET
    Then status 400
    * print 'respuesta de petición:', response

  @TC-IL-06 @DEF-11
  Scenario: Verificar rechazo de identificador decimal
    Given path 'saving-groups', inviteLinkData.invalidGroupIds.decimal, 'invite-link'
    And headers authHeaders
    When method GET
    Then status 400
    * print 'respuesta de petición:', response

  @TC-IL-07
  Scenario: Verificar rechazo cuando el identificador del grupo es cero
    Given path 'saving-groups', inviteLinkData.invalidGroupIds.zero, 'invite-link'
    And headers authHeaders
    When method GET
    Then status 404
    * print 'respuesta de petición:', response

  @TC-IL-08 @DEF-11
  Scenario: Verificar rechazo de identificador fuera del rango soportado
    Given path 'saving-groups', inviteLinkData.invalidGroupIds.tooLarge, 'invite-link'
    And headers authHeaders
    When method GET
    Then status 400
    * print 'respuesta de petición:', response

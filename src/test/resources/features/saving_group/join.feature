@GestionGruposAhorro @F-05
Feature: Gestión de Grupos de Ahorro > Unión al grupo mediante enlace de invitación

  Background:
    * url baseUrl
    * def loginData = read('classpath:data/auth/login.json')
    * def savingGroupCreationData = read('classpath:data/saving_group/create.json')
    * def savingGroupActivationData = read('classpath:data/saving_group/activate.json')
    * def joinData = read('classpath:data/saving_group/join.json')
    * def loginResult = callonce read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(loginData.validCredentials)' } }
    * def authToken = loginResult.authToken
    * def authHeaders = { Authorization: '#("Bearer " + authToken)' }

  @TC-JG-01
  Scenario: Verificar unión exitosa al grupo mediante enlace de invitación
    # Creo un nuevo saving group
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 2
    * def createResult = call read('classpath:helpers/saving_group/create.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', group: '#(group)' } }
    * def savingGroupId = createResult.savingGroupId

    # Obtener link de invitación
    * def inviteLinkResult = call read('classpath:helpers/saving_group/get_invite_link.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', savingGroupId: '#(savingGroupId)' } }

    # Iniciar sesión con usuario invitado
    * def memberLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.additionalUserCredentials)' } }
    * def memberAuthHeaders = { Authorization: '#("Bearer " + memberLoginResult.authToken)' }

    Given path 'saving-groups', 'join', inviteLinkResult.activationCode
    And headers memberAuthHeaders
    When method POST
    Then status 201
    And match response.data.message == 'Group successfully joined'
    And match response.data.savingGroupId == '#notnull'
    And match response.data.invitationStatus == joinData.status.accepted
    * print 'respuesta de petición:', response

  @TC-JG-02
  Scenario: Verificar rechazo de unión sin autenticación
    # Creo un nuevo saving group
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 2
    * def createResult = call read('classpath:helpers/saving_group/create.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', group: '#(group)' } }
    * def savingGroupId = createResult.savingGroupId

    # Obtener link de invitación
    * def inviteLinkResult = call read('classpath:helpers/saving_group/get_invite_link.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', savingGroupId: '#(savingGroupId)' } }

    Given path 'saving-groups', 'join', inviteLinkResult.activationCode
    When method POST
    Then status 401
    * print 'respuesta de petición:', response

  @TC-JG-03
  Scenario: Verificar rechazo de token con formato inválido
    # Iniciar sesión con usuario invitado
    * def memberLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.additionalUserCredentials)' } }
    * def memberAuthHeaders = { Authorization: '#("Bearer " + memberLoginResult.authToken)' }

    Given path 'saving-groups', 'join', joinData.invalidTokens.malformed
    And headers memberAuthHeaders
    When method POST
    Then status 400
    * print 'respuesta de petición:', response

  @TC-JG-04
  Scenario: Verificar rechazo cuando el usuario ya pertenece al grupo
    # Creo un nuevo saving group
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 2
    * def createResult = call read('classpath:helpers/saving_group/create.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', group: '#(group)' } }
    * def savingGroupId = createResult.savingGroupId

    # Obtener link de invitación
    * def inviteLinkResult = call read('classpath:helpers/saving_group/get_invite_link.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', savingGroupId: '#(savingGroupId)' } }

    # Iniciar sesión con usuario invitado
    * def memberLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.additionalUserCredentials)' } }
    * def memberAuthHeaders = { Authorization: '#("Bearer " + memberLoginResult.authToken)' }

    # Unir usuario invitado al grupo
    * def joinResult = call read('classpath:helpers/saving_group/join.feature') { data: { url: '#(baseUrl)', authHeaders: '#(memberAuthHeaders)', activationCode: '#(inviteLinkResult.activationCode)' } }
    * match joinResult.joinedGroup.invitationStatus == joinData.status.accepted

    Given path 'saving-groups', 'join', inviteLinkResult.activationCode
    And headers memberAuthHeaders
    When method POST
    Then status 400
    And match response.message contains 'already'
    * print 'respuesta de petición:', response

  @TC-JG-05
  Scenario: Verificar rechazo cuando el grupo ya está activo
    # Creo un nuevo saving group
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 2
    * def createResult = call read('classpath:helpers/saving_group/create.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', group: '#(group)' } }
    * def savingGroupId = createResult.savingGroupId

    # Obtener link de invitación
    * def inviteLinkResult = call read('classpath:helpers/saving_group/get_invite_link.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', savingGroupId: '#(savingGroupId)' } }

    # Iniciar sesión con usuario invitado
    * def memberLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.additionalUserCredentials)' } }
    * def memberAuthHeaders = { Authorization: '#("Bearer " + memberLoginResult.authToken)' }

    # Unir usuario invitado al grupo
    * def joinResult = call read('classpath:helpers/saving_group/join.feature') { data: { url: '#(baseUrl)', authHeaders: '#(memberAuthHeaders)', activationCode: '#(inviteLinkResult.activationCode)' } }
    * match joinResult.joinedGroup.invitationStatus == joinData.status.accepted

    Given path 'saving-groups', savingGroupId, 'activate'
    And headers authHeaders
    And request
    When method PATCH
    Then status 200
    And match response.data.message == 'Group successfully active'

    # Iniciar sesión con usuario ajeno al grupo
    * def externalUserLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.externalUserCredentials)' } }
    * def externalUserAuthHeaders = { Authorization: '#("Bearer " + externalUserLoginResult.authToken)' }

    Given path 'saving-groups', 'join', inviteLinkResult.activationCode
    And headers externalUserAuthHeaders
    When method POST
    Then status 400
    And match response.message == 'Group is already active'
    * print 'respuesta de petición:', response

  @TC-JG-06 @DEF-10
  Scenario: Verificar rechazo cuando no hay cupos disponibles
    # Creo un nuevo saving group
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 2
    * def createResult = call read('classpath:helpers/saving_group/create.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', group: '#(group)' } }
    * def savingGroupId = createResult.savingGroupId

    # Obtener link de invitación
    * def inviteLinkResult = call read('classpath:helpers/saving_group/get_invite_link.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', savingGroupId: '#(savingGroupId)' } }

    # Iniciar sesión con primer usuario invitado
    * def firstMemberLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.additionalUserCredentials)' } }
    * def firstMemberAuthHeaders = { Authorization: '#("Bearer " + firstMemberLoginResult.authToken)' }

    # Unir primer usuario invitado al grupo
    * def firstJoinResult = call read('classpath:helpers/saving_group/join.feature') { data: { url: '#(baseUrl)', authHeaders: '#(firstMemberAuthHeaders)', activationCode: '#(inviteLinkResult.activationCode)' } }
    * match firstJoinResult.joinedGroup.invitationStatus == joinData.status.accepted

    # Iniciar sesión con segundo usuario invitado
    * def secondMemberLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.secondAdditionalUserCredentials)' } }
    * def secondMemberAuthHeaders = { Authorization: '#("Bearer " + secondMemberLoginResult.authToken)' }

    # Unir segundo usuario invitado al grupo
    * def secondJoinResult = call read('classpath:helpers/saving_group/join.feature') { data: { url: '#(baseUrl)', authHeaders: '#(secondMemberAuthHeaders)', activationCode: '#(inviteLinkResult.activationCode)' } }
    * match secondJoinResult.joinedGroup.invitationStatus == joinData.status.accepted

    # Iniciar sesión con usuario ajeno al grupo
    * def externalUserLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.externalUserCredentials)' } }
    * def externalUserAuthHeaders = { Authorization: '#("Bearer " + externalUserLoginResult.authToken)' }

    Given path 'saving-groups', 'join', inviteLinkResult.activationCode
    And headers externalUserAuthHeaders
    When method POST
    Then status 400
    * print 'respuesta de petición:', response

  @TC-JG-07
  Scenario: Verificar rechazo de token con longitud menor a la requerida
    # Iniciar sesión con usuario invitado
    * def memberLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.additionalUserCredentials)' } }
    * def memberAuthHeaders = { Authorization: '#("Bearer " + memberLoginResult.authToken)' }

    Given path 'saving-groups', 'join', joinData.invalidTokens.thirtyOneCharacters
    And headers memberAuthHeaders
    When method POST
    Then status 400
    * print 'respuesta de petición:', response

  @TC-JG-08
  Scenario: Verificar rechazo de token con longitud mayor a la requerida
    # Iniciar sesión con usuario invitado
    * def memberLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.additionalUserCredentials)' } }
    * def memberAuthHeaders = { Authorization: '#("Bearer " + memberLoginResult.authToken)' }

    Given path 'saving-groups', 'join', joinData.invalidTokens.thirtyThreeCharacters
    And headers memberAuthHeaders
    When method POST
    Then status 400
    * print 'respuesta de petición:', response

  @TC-JG-09
  Scenario: Verificar rechazo cuando no se envía token en la ruta
    # Iniciar sesión con usuario invitado
    * def memberLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.additionalUserCredentials)' } }
    * def memberAuthHeaders = { Authorization: '#("Bearer " + memberLoginResult.authToken)' }

    Given path 'saving-groups', 'join'
    And headers memberAuthHeaders
    When method POST
    Then status 404
    * print 'respuesta de petición:', response

  @TC-JG-10
  Scenario: Verificar rechazo de token con un solo carácter
    # Iniciar sesión con usuario invitado
    * def memberLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.additionalUserCredentials)' } }
    * def memberAuthHeaders = { Authorization: '#("Bearer " + memberLoginResult.authToken)' }

    Given path 'saving-groups', 'join', joinData.invalidTokens.singleCharacter
    And headers memberAuthHeaders
    When method POST
    Then status 400
    * print 'respuesta de petición:', response

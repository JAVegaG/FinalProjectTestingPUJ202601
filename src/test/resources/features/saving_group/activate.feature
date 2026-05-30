@GestionGruposAhorro @F-06
Feature: Gestión de Grupos de Ahorro > Activación del grupo

  Background:
    * url baseUrl
    * def loginData = read('classpath:data/auth/login.json')
    * def savingGroupActivationData = read('classpath:data/saving_group/activate.json')
    * def savingGroupCreationData = read('classpath:data/saving_group/create.json')
    * def loginResult = callonce read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(loginData.validCredentials)' } }
    * def authToken = loginResult.authToken
    * def authHeaders = { Authorization: '#("Bearer " + authToken)' }

  @TC-AG-01 @DEF-07
  Scenario: Verificar activación de grupo con un único miembro
    # Creo un nuevo saving group
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 1
    * def createResult = call read('classpath:helpers/saving_group/create.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', group: '#(group)' } }
    * def savingGroupId = createResult.savingGroupId
    * match createResult.savingGroup.status == savingGroupCreationData.status.draft

    Given path 'saving-groups', savingGroupId, 'activate'
    And headers authHeaders
    And request
    When method PATCH
    Then status 200
    And match response.data.message == 'Group successfully active'
    And match response.data.status == savingGroupActivationData.status.active
    And match response.data.installmentDates == '#[]'
    And assert response.data.installmentDates.length > 0
    And assert responseTime < 3000
    * print 'respuesta de petición:', response

  @TC-AG-02
  Scenario: Verificar activación de grupo con todos los miembros inscritos
    # Creo un nuevo saving group
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 3
    * def createResult = call read('classpath:helpers/saving_group/create.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', group: '#(group)' } }
    * def savingGroupId = createResult.savingGroupId
    * match createResult.savingGroup.status == savingGroupCreationData.status.draft

    # Obtener link de invitación
    * def inviteLinkResult = call read('classpath:helpers/saving_group/get_invite_link.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', savingGroupId: '#(savingGroupId)' } }
    * def activationCode = inviteLinkResult.activationCode

    # Iniciar sesión con primer usuario invitado
    * def firstMemberLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.additionalUserCredentials)' } }
    * def firstMemberAuthHeaders = { Authorization: '#("Bearer " + firstMemberLoginResult.authToken)' }

    # Unir primer usuario invitado al grupo
    * def firstJoinResult = call read('classpath:helpers/saving_group/join.feature') { data: { url: '#(baseUrl)', authHeaders: '#(firstMemberAuthHeaders)', activationCode: '#(activationCode)' } }
    * match firstJoinResult.joinedGroup.invitationStatus == savingGroupActivationData.status.accepted

    # Iniciar sesión con segundo usuario invitado
    * def secondMemberLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.secondAdditionalUserCredentials)' } }
    * def secondMemberAuthHeaders = { Authorization: '#("Bearer " + secondMemberLoginResult.authToken)' }

    # Unir segundo usuario invitado al grupo
    * def secondJoinResult = call read('classpath:helpers/saving_group/join.feature') { data: { url: '#(baseUrl)', authHeaders: '#(secondMemberAuthHeaders)', activationCode: '#(activationCode)' } }
    * match secondJoinResult.joinedGroup.invitationStatus == savingGroupActivationData.status.accepted

    Given path 'saving-groups', savingGroupId, 'activate'
    And headers authHeaders
    And request
    When method PATCH
    Then status 200
    * print response
    And match response.data.message == 'Group successfully active'
    * print 'respuesta de petición:', response

  @TC-AG-03
  Scenario: Verificar rechazo de activación sin todos los miembros inscritos
    # Creo un nuevo saving group
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 3
    * def createResult = call read('classpath:helpers/saving_group/create.feature') { data: { url: '#(baseUrl)', authHeaders: '#(authHeaders)', group: '#(group)' } }
    * def savingGroupId = createResult.savingGroupId
    * match createResult.savingGroup.status == savingGroupCreationData.status.draft

    Given path 'saving-groups', savingGroupId, 'activate'
    And headers authHeaders
    And request
    When method PATCH
    Then status 400
    And match response.message == 'Group should have the total number of members to be activated'
    * print 'respuesta de petición:', response

  @TC-AG-04
  Scenario: Verificar rechazo de activación de grupo ya activo
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
    * match joinResult.joinedGroup.invitationStatus == savingGroupActivationData.status.accepted

    Given path 'saving-groups', savingGroupId, 'activate'
    And headers authHeaders
    And request
    When method PATCH
    Then status 200
    And match response.data.message == 'Group successfully active'
    * def firstInstallmentDates = response.data.installmentDates

    Given path 'saving-groups', savingGroupId, 'activate'
    And headers authHeaders
    And request
    When method PATCH
    Then status 400
    And match response.message == 'Group is already active'
    * print 'fechas generadas previamente:', firstInstallmentDates
    * print 'respuesta de petición:', response

  @TC-AG-05
  Scenario: Verificar rechazo cuando un miembro no administrador intenta activar
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
    * match joinResult.joinedGroup.invitationStatus == savingGroupActivationData.status.accepted

    Given path 'saving-groups', savingGroupId, 'activate'
    And headers memberAuthHeaders
    And request
    When method PATCH
    Then status 403
    And match response.message == 'Only admin can perform this action'
    * print 'respuesta de petición:', response

  @TC-AG-06
  Scenario: Verificar rechazo cuando un usuario ajeno al grupo intenta activar
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
    * match joinResult.joinedGroup.invitationStatus == savingGroupActivationData.status.accepted

    # Iniciar sesión con usuario ajeno al grupo
    * def externalUserLoginResult = call read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(savingGroupActivationData.externalUserCredentials)' } }
    * def externalUserAuthHeaders = { Authorization: '#("Bearer " + externalUserLoginResult.authToken)' }

    Given path 'saving-groups', savingGroupId, 'activate'
    And headers externalUserAuthHeaders
    And request
    When method PATCH
    Then status 403
    And match response.message == 'User not in group'
    * print 'respuesta de petición:', response

  @TC-AG-07
  Scenario: Verificar rechazo cuando el grupo no existe
    Given path 'saving-groups', 99999, 'activate'
    And headers authHeaders
    And request
    When method PATCH
    Then status 404
    And match response.message == 'Group not found'
    * print 'respuesta de petición:', response

  @TC-AG-08
  Scenario: Verificar rechazo de activación sin autenticación
    Given path 'saving-groups', 3, 'activate'
    And request
    When method PATCH
    Then status 401
    * print 'respuesta de petición:', response

  @TC-AG-09
  Scenario: Verificar rechazo de activación con token expirado
    * def expiredAuthHeaders = { Authorization: '#("Bearer " + savingGroupActivationData.expiredToken)' }

    Given path 'saving-groups', 3, 'activate'
    And headers expiredAuthHeaders
    And request
    When method PATCH
    Then status 401
    * print 'respuesta de petición:', response

  @TC-AG-10 @DEF-08
  Scenario: Verificar rechazo cuando el identificador del grupo es cero
    Given path 'saving-groups', 0, 'activate'
    And headers authHeaders
    And request
    When method PATCH
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    * print 'respuesta de petición:', response

  @TC-AG-11 @DEF-09
  Scenario: Verificar rechazo cuando el identificador del grupo es negativo
    Given path 'saving-groups', -1, 'activate'
    And headers authHeaders
    And request
    When method PATCH
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    * print 'respuesta de petición:', response

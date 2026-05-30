@GestionGruposAhorro @F-03
Feature: Gestión de Grupos de Ahorro > Creación

  Background:
    * url baseUrl
    * def loginData = read('classpath:data/auth/login.json')
    * def savingGroupCreationData = read('classpath:data/saving_group/create.json')
    * def loginResult = callonce read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(loginData.validCredentials)' } }
    * def authToken = loginResult.authToken
    * def authHeaders = { Authorization: '#("Bearer " + authToken)' }
  
  @TC-CG-01
  Scenario: Verificar creación de grupo con datos completos
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    And request group
    When method POST
    Then status 201
    And match response.data.status == savingGroupCreationData.status.draft
    And match response.data contains { id: '#number', title: '#(group.title)', description: '#(group.description)', savingGoal: '#(group.savingGoal)', paymentFrequency: '#(group.paymentFrequency)', totalMembers: '#(group.totalMembers)' }
    * print 'respuesta de petición:', response

  @TC-CG-02
  Scenario: Verificar creación de grupo sin datos opcionales
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * delete group.description
    * delete group.reminderDays
    And request group
    When method POST
    Then status 201
    And match response.data.status == savingGroupCreationData.status.draft
    * print 'respuesta de petición:', response

  @TC-CG-03
  Scenario: Verificar creación de grupo con monto mínimo permitido
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.savingGoal = 100000
    And request group
    When method POST
    Then status 201
    And match response.data.status == savingGroupCreationData.status.draft
    And match response.data.savingGoal == group.savingGoal
    * print 'respuesta de petición:', response

  @TC-CG-04
  Scenario: Verificar rechazo de monto por debajo del mínimo permitido
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.savingGoal = 99999
    And request group
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'savingGoal'
    * print 'respuesta de petición:', response

  @TC-CG-05
  Scenario: Verificar creación de grupo con monto máximo permitido
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.savingGoal = 10000000
    And request group
    When method POST
    Then status 201
    And match response.data.status == savingGroupCreationData.status.draft
    And match response.data.savingGoal == group.savingGoal
    * print 'respuesta de petición:', response

  @TC-CG-06
  Scenario: Verificar rechazo de monto por encima del máximo permitido
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.savingGoal = 10000001
    And request group
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'savingGoal'
    * print 'respuesta de petición:', response

  @TC-CG-07
  Scenario: Verificar rechazo de monto negativo
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.savingGoal = -100000
    And request group
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'savingGoal'
    * print 'respuesta de petición:', response

  @TC-CG-08
  Scenario: Verificar rechazo de monto con formato inválido
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.savingGoal = 'abc'
    And request group
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'savingGoal'
    * print 'respuesta de petición:', response

  @TC-CG-09
  Scenario: Verificar creación de grupo con un participante
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 1
    And request group
    When method POST
    Then status 201
    And match response.data.status == savingGroupCreationData.status.draft
    And match response.data.totalMembers == group.totalMembers
    * print 'respuesta de petición:', response

  @TC-CG-10
  Scenario: Verificar creación de grupo con el máximo de participantes
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 5
    And request group
    When method POST
    Then status 201
    And match response.data.status == savingGroupCreationData.status.draft
    And match response.data.totalMembers == group.totalMembers
    * print 'respuesta de petición:', response

  @TC-CG-11 @DEF-04
  Scenario: Verificar rechazo cuando se supera el máximo de participantes
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 6
    And request group
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'totalMembers'
    * print 'respuesta de petición:', response

  @TC-CG-12
  Scenario: Verificar rechazo cuando no hay participantes
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 0
    And request group
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'totalMembers'
    * print 'respuesta de petición:', response

  @TC-CG-13 @DEF-05
  Scenario: Verificar rechazo de participantes con valor decimal
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.totalMembers = 2.5
    And request group
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'totalMembers'
    * print 'respuesta de petición:', response

  @TC-CG-14
  Scenario: Verificar rechazo de frecuencia de pago no permitida
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.paymentFrequency = 'DAILY'
    And request group
    When method POST
    Then status 400
    And match response.message contains 'Invalid payment frequency'
    * print 'respuesta de petición:', response

  @TC-CG-15
  Scenario: Verificar rechazo de frecuencia de pago en minúsculas
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.paymentFrequency = 'monthly'
    And request group
    When method POST
    Then status 400
    And match response.message contains 'Invalid payment frequency'
    * print 'respuesta de petición:', response

  @TC-CG-16 @DEF-06
  Scenario: Verificar rechazo de título vacío
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.title = ''
    And request group
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'title'
    * print 'respuesta de petición:', response

  @TC-CG-17
  Scenario: Verificar rechazo cuando la fecha de retorno es anterior al primer pago
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.firstPaymentDate = '2026-12-01'
    * group.returnDate = '2026-06-01'
    And request group
    When method POST
    Then status 400
    * print 'respuesta de petición:', response

  @TC-CG-18
  Scenario: Verificar rechazo de creación de grupo sin autenticación
    Given path 'saving-groups', 'create'
    * copy group = savingGroupCreationData.newGroup
    And request group
    When method POST
    Then status 401
    And match response.message == 'Unauthorized'
    * print 'respuesta de petición:', response

  @TC-CG-19
  Scenario: Verificar rechazo de días de recordatorio negativos
    Given path 'saving-groups', 'create'
    And headers authHeaders
    * copy group = savingGroupCreationData.newGroup
    * group.reminderDays = -1
    And request group
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'reminderDays'
    * print 'respuesta de petición:', response

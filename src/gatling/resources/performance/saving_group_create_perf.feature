Feature: Performance PoC - saving group creation

  Background:
    * url baseUrl
    * def loginData = read('classpath:data/auth/login.json')
    * def savingGroupCreationData = read('classpath:data/saving_group/create.json')
    * def loginResult = callonce read('classpath:helpers/auth/login.feature') { data: { url: '#(baseUrl)', user: '#(loginData.validCredentials)' } }
    * def authHeaders = { Authorization: '#("Bearer " + loginResult.authToken)' }

  Scenario: Create saving group successfully
    * copy group = savingGroupCreationData.newGroup
    * group.title = 'Perf Create ' + java.util.UUID.randomUUID()
    Given path 'saving-groups', 'create'
    And headers authHeaders
    And request group
    When method POST
    Then status 201
    And match response.data.status == savingGroupCreationData.status.draft

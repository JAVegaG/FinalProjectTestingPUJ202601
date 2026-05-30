@ignore
Feature: Saving group invite link helper

Scenario:
    Given url data.url
    And path 'saving-groups', data.savingGroupId, 'invite-link'
    And headers data.authHeaders
    When method GET
    Then status 200
    And match response.data contains { inviteUrl: '#string' }
    And match response.data.inviteUrl contains 'join='
    * def inviteUrl = response.data.inviteUrl
    * def activationCode = response.data.inviteUrl.split('join=')[1]

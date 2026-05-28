@ignore
Feature: Saving group creation helper

Scenario:
    Given url data.url
    And path 'saving-groups', 'create'
    And headers data.authHeaders
    And request data.group
    When method POST
    Then status 201
    * def savingGroup = response.data
    * def savingGroupId = response.data.id

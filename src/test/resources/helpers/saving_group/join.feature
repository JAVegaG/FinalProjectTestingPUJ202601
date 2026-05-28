@ignore
Feature: Saving group join helper

Scenario:
    Given url data.url
    And path 'saving-groups', 'join', data.activationCode
    And headers data.authHeaders
    When method POST
    Then status 201
    * def joinedGroup = response.data

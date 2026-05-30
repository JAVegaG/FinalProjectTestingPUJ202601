@ignore
Feature: Login helper

Scenario:
    Given url data.url
    And path 'auth', 'login'
    And request data.user
    When method POST
    Then status 201
    * def authToken = response.data.token
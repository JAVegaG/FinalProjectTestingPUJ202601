@ignore
Feature: Helper — Login y obtención de token JWT

  Scenario: Login exitoso
    Given url baseUrl
    And path '/auth/login'
    And request { email: '#(email)', password: '#(password)' }
    When method POST
    Then status 201
    * def token = response.data.token

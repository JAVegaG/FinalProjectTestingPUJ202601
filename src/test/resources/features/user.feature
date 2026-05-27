@GestionUsuarios
Feature: Gestión de Actividad de Usuario

  Background:
    * url baseUrl
    * def userData = read('classpath:data/user.json')
    * def authHeaders = read('classpath:data/auth-headers.json')

    # Login inicial para obtener el token
    Given path 'auth', 'login'
    And request userData.loginCredentials
    When method POST
    Then status 201
    * def authToken = response.data.token

  Scenario: Verificar mensaje de error no autorizado de usuario
    Given path 'user', 'saving-groups'
    And params { role: 'ADMIN', type: '#(userData.searchCriteria.type)' }
    And configure headers = {}
    When method GET
    Then status 401
    And match response.message == 'Unauthorized'
    * print 'respuesta de petición:', response

  Scenario Outline: Consultar grupos exitosamente según su rol <rol>
    Given path 'user', 'saving-groups'
    And params { role: '<rol>', type: '#(userData.searchCriteria.type)' }
    And header Authorization = 'Bearer ' + authToken
    And headers authHeaders
    When method GET
    Then status 200
    And match response.data == '#[]'
    * print 'respuesta de petición:', response

    Examples:
      # Llamada directa al JSON
      | read('classpath:data/user.json').rolesList |

  Scenario Outline: Validar calendario de pagos para el mes <mes>
    Given path 'user', 'payment-calendar'
    And param month = '<mes>'
    And header Authorization = 'Bearer ' + authToken
    And headers authHeaders
    When method GET
    Then status 200
    And match response.data == '#[]'
    * print 'respuesta de petición:', response

    Examples:
      | read('classpath:data/user.json').monthsList |

  Scenario Outline: Validar métricas de calendario de pagos para el mes <mes>
    Given path 'user', 'payment-calendar', 'metrics'
    And param month = '<mes>'
    And header Authorization = 'Bearer ' + authToken
    And headers authHeaders
    When method GET
    Then status 200
    And match response.data == { paid: '#number', upcoming: '#number', pending: '#number', overdue: '#number' }
    * print 'respuesta de petición:', response
    Examples:
      | read('classpath:data/user.json').monthsList |
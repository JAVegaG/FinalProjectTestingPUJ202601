@GestionAutenticación
Feature: Gestión de Autenticación y Acceso de Usuarios
  Como usuario del sistema
  Quiero autenticarme y gestionar mi cuenta
  Para acceder a las funciones de aplicación web de Círculos

  Background:
    * url baseUrl
    * path 'auth'
    * def authData = read('classpath:data/auth-body.json')
    * def authHeaders = read('classpath:data/auth-headers.json')

  Scenario: Inicio de sesión con credenciales válidas
    Given path 'login'
    And headers authHeaders
    And request authData.validCredentials
    When method POST
    Then status 201
    And match response.data.token == '#string'
    * def sessionToken = response.data.token
    * print 'respuesta de petición:', response

  Scenario: Verificación de sesión activa persistente
    Given path 'login'
    And headers authHeaders
    And request authData.validCredentials
    When method POST
    Then status 201
    And match response.data.token == '#string'
    * def freshToken = response.data.token
    Given path 'auth', 'session'
    And header Authorization = 'Bearer ' + freshToken
    When method GET
    Then status 200
    And match response.data.valid == true
    * print 'respuesta de petición:', response

  Scenario: Validación de Intento de acceso a sesión sin autorización
    Given path 'session'
    And configure headers = {}
    When method GET
    Then status 401
    And match response.message == 'Authorization header missing'
    * print 'respuesta de petición:', response

  Scenario: Validación de inicio de sesión con credenciales incorrectas
    Given path 'login'
    And request authData.invalidCredentials
    When method POST
    Then status 401
    And match response.message == 'Invalid credentials'
    * print 'respuesta de petición:', response

  Scenario: Validación de registro duplicado
    Given path 'signUp'
    And request authData.existingUser
    When method POST
    Then status 401
    And match response.message == 'User already exists'
    * print 'respuesta de petición:', response
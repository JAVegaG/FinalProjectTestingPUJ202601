@GestionAutenticación @F-02
Feature: Gestión de Autenticación y Acceso de Usuarios > Inicio de Sesión
  Como usuario del sistema
  Quiero autenticarme y gestionar mi cuenta
  Para acceder a las funciones de aplicación web de Círculos

  Background:
    * url baseUrl
    * path 'auth'
    * def loginData = read('classpath:data/auth/login.json')

  @TC-LG-01
  Scenario: Verificar login exitoso con email en mayúsculas y password correcta
    Given path 'login'
    * print 'Email de usuario:', loginData.validCredentials.email
    * def validCredentials = loginData.validCredentials
    * validCredentials.email = loginData.validCredentials.email.toUpperCase()
    * print 'Email de usuario toUpperCase():', validCredentials.email
    And request validCredentials
    When method POST
    Then status 201
    And response.data.token == '#present'
    * print 'respuesta de petición:', response

  @TC-LG-02
  Scenario: Verificar rechazo con password errónea
    Given path 'login'
    * def invalidPasswordCredentials = loginData.validCredentials
    * invalidPasswordCredentials.email = loginData.validCredentials.email.toUpperCase()
    * invalidPasswordCredentials.password = 'wrong_password'
    * print 'Credenciales con password errónea:', invalidPasswordCredentials
    And request invalidPasswordCredentials
    When method POST
    Then status 401
    And match response.message == 'Incorrect username or password'
    * print 'respuesta de petición:', response

  @TC-LG-03 @DEF-03
  Scenario: Verificar que el sistema no revela si un email está registrado mediante mensajes distintos
    Given path 'login'
    * def registeredEmailCredentials = loginData.validCredentials
    * registeredEmailCredentials.email = loginData.validCredentials.email.toUpperCase()
    * registeredEmailCredentials.password = 'wrong_password'
    And request registeredEmailCredentials
    When method POST
    Then status 401
    * def registeredEmailMessage = response.message
    * print 'Respuesta con email registrado:', response
    Given path 'auth', 'login'
    * def unregisteredEmailCredentials = loginData.invalidCredentials
    * unregisteredEmailCredentials.email = 'not.registered.user@email.com'
    And request unregisteredEmailCredentials
    When method POST
    Then status 401
    And match response.message == registeredEmailMessage
    * print 'Respuesta con email no registrado:', response

  @TC-LG-04
  Scenario: Verificar rechazo por formato de email incorrecto
    Given path 'login'
    * def invalidEmailCredentials = loginData.validCredentials
    * invalidEmailCredentials.email = 'test_user'
    * print 'Credenciales con email inválido:', invalidEmailCredentials
    And request invalidEmailCredentials
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'email'
    * print 'respuesta de petición:', response

  @TC-LG-05
  Scenario: Verificar rechazo cuando el password está vacío
    Given path 'login'
    * def emptyPasswordCredentials = loginData.validCredentials
    * emptyPasswordCredentials.email = loginData.validCredentials.email.toUpperCase()
    * emptyPasswordCredentials.password = ''
    * print 'Longitud del password', emptyPasswordCredentials.password.length
    And request emptyPasswordCredentials
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'password'
    * print 'respuesta de petición:', response

  @TC-LG-06
  Scenario: Verificar rechazo cuando no se envía el email
    Given path 'login'
    * def credentialsWithoutEmail = loginData.validCredentials
    * delete credentialsWithoutEmail.email
    * print 'Credenciales sin email:', credentialsWithoutEmail
    And request credentialsWithoutEmail
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'email'
    * print 'respuesta de petición:', response

  @TC-LG-07
  Scenario: Verificar rechazo cuando no se envía el password
    Given path 'login'
    * def credentialsWithoutPassword = loginData.validCredentials
    * credentialsWithoutPassword.email = loginData.validCredentials.email.toUpperCase()
    * delete credentialsWithoutPassword.password
    * print 'Credenciales sin password:', credentialsWithoutPassword
    And request credentialsWithoutPassword
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'password'
    * print 'respuesta de petición:', response
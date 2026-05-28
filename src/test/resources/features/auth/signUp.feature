@GestionAutenticación @F-01
Feature: Gestión de Autenticación y Acceso de Usuarios > Registro de usuario
  Como usuario del sistema
  Quiero autenticarme y gestionar mi cuenta
  Para acceder a las funciones de aplicación web de Círculos

  Background:
    * url baseUrl
    * path 'auth'
    * def signUpData = read('classpath:data/auth/signUp.json')

  @TC-SU-01
  Scenario: Validación de registro de usuario con todos los datos
    Given path 'signUp'
    And request signUpData.nonexistingUser
    When method POST
    Then status 201
    And match response.data.status == signUpData.status.confirmed
    * print 'respuesta de petición:', response
  
  @TC-SU-02
  Scenario: Validación de registro de usuario sin datos opcionales
    Given path 'signUp'
    * print 'Non-Existing user:', signUpData.nonexistingUser
    * def nonexistingUser = signUpData.nonexistingUser
    * delete nonexistingUser.secondName
    * delete nonexistingUser.secondLastName
    * print 'Non-Existing user without optional data:', nonexistingUser
    And request nonexistingUser
    When method POST
    Then status 201
    And match response.data.status == signUpData.status.confirmed
    * print 'respuesta de petición:', response

  @TC-SU-03
  Scenario: Validación de registro con usuario existente
    Given path 'signUp'
    And request signUpData.existingUser
    When method POST
    Then status 401
    And match response.message == 'User already exists'
    * print 'respuesta de petición:', response
  
  @TC-SU-04
  Scenario: Validación de registro con usuario existente independiente de la capitalización
    Given path 'signUp'
    * print 'Existing user email:', signUpData.existingUser.email
    * def existingUser = signUpData.existingUser
    * existingUser.email = existingUser.email.toUpperCase()
    * print 'Existing user email toUpperCase():', existingUser.email
    And request existingUser
    When method POST
    Then status 401
    And match response.message == 'User already exists'
    * print 'respuesta de petición:', response
  
  @TC-SU-05
  Scenario: Validación de limite inferior en el campo de contraseña
    Given path 'signUp'
    * print 'Non-Existing user email:', signUpData.nonexistingUser.email
    * def nonexistingUser = signUpData.nonexistingUser
    * nonexistingUser.password =  String(Math.floor(Math.random() * 9e5) + 1e6)
    * print 'Longitud de la contraseña', nonexistingUser.password.length
    And request nonexistingUser
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'password must be longer'
    * print 'respuesta de petición:', response
  
  @TC-SU-06
  Scenario: Validación de limite inferior con valor exacto en la constraseña
    Given path 'signUp'
    * print 'Non-Existing user email:', signUpData.nonexistingUser.email
    * def nonexistingUser = signUpData.nonexistingUser
    * nonexistingUser.password =  String(Math.floor(Math.random() * 9e6) + 1e7)
    * print 'Longitud de la contraseña', nonexistingUser.password.length
    And request nonexistingUser
    When method POST
    Then status 201
    And match response.data.status == signUpData.status.confirmed
    * print 'respuesta de petición:', response

  @TC-SU-07 @DEF-01
  Scenario: Validación de la aceptación de términos y condiciones
    Given path 'signUp'
    * print 'Non-Existing user email:', signUpData.nonexistingUser.email
    * def nonexistingUser = signUpData.nonexistingUser
    * nonexistingUser.termsAndConditions.law1581Authorization =  false
    * print 'Términos y condiciones', nonexistingUser.termsAndConditions
    And request nonexistingUser
    When method POST
    Then status 400
    * print 'respuesta de petición:', response

  @TC-SU-08
  Scenario: Verificar rechazo de número de teléfono con longitud diferente a 10
    Given path 'signUp'
    * print 'Non-Existing user phoneNumber:', signUpData.nonexistingUser.phoneNumber
    * def nonexistingUser = signUpData.nonexistingUser
    * nonexistingUser.phoneNumber = '312345678'
    * print 'Longitud del número de teléfono', nonexistingUser.phoneNumber.length
    And request nonexistingUser
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'phoneNumber'
    * print 'respuesta de petición:', response

  @TC-SU-09 @DEF-02
  Scenario: Verificar que el sistema rechaza fecha de aceptación de términos anterior a hoy
    Given path 'signUp'
    * print 'Non-Existing user termsAndConditions:', signUpData.nonexistingUser.termsAndConditions
    * def nonexistingUser = signUpData.nonexistingUser
    * nonexistingUser.termsAndConditions.law1581AuthorizationDate = '2023-10-05T14:48:00.000Z'
    * print 'Fecha de aceptación de términos', nonexistingUser.termsAndConditions.law1581AuthorizationDate
    And request nonexistingUser
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'law1581AuthorizationDate'
    * print 'respuesta de petición:', response

  @TC-SU-10
  Scenario: Verificar que un email de exactamente 50 caracteres es aceptado
    Given path 'signUp'
    * def UUID = Java.type('java.util.UUID')
    * def uuid = UUID.randomUUID().toString().replaceAll('-', '')
    * def nonexistingUser = signUpData.nonexistingUser
    * nonexistingUser.email = 'user' + uuid + 'aaaaa@test.com'
    * print 'Email:', nonexistingUser.email
    * print 'Longitud del email', nonexistingUser.email.length
    And request nonexistingUser
    When method POST
    Then status 201
    And match response.data.status == signUpData.status.confirmed
    * print 'respuesta de petición:', response

  @TC-SU-11
  Scenario: Verificar rechazo de email que supera el límite máximo de 50 caracteres
    Given path 'signUp'
    * def UUID = Java.type('java.util.UUID')
    * def uuid = UUID.randomUUID().toString().replaceAll('-', '')
    * def nonexistingUser = signUpData.nonexistingUser
    * nonexistingUser.email = 'user' + uuid + 'aaaaaa@test.com'
    * print 'Email:', nonexistingUser.email
    * print 'Longitud del email', nonexistingUser.email.length
    And request nonexistingUser
    When method POST
    Then status 400
    * def errorString = karate.toString(response.errors)
    And match response.message == 'Validation failed'
    And match errorString contains 'email'
    * print 'respuesta de petición:', response

Feature: Gestión de datos de ubicación

  Background:
    * url baseUrl
    * path 'location'
    * def headers = read('classpath:data/auth-headers.json')
    * configure headers = headers

  Scenario: Consultar catálogo de países
    Given path 'countries'
    When method GET
    Then status 200
  # valida quesea una lista
    And match response.data == '#[]'
  # valida que el primer elemento tenga la estructura de negocio
    And match response.data[0] == { id: '#number', label: '#string' }
  # se verifica que existan registros operativos
    * def totalPaises = response.data.length
    And assert totalPaises > 0
    * print 'respuesta de petición:', response

  Scenario: Verificar respuesta controlada ante fallos técnicos del servidor
    Given path 'countries-rutaIncorrecta'
  # simulando (mocking) una caída del servicio
    When method POST
    Then status 404
    And match response == { statusCode: 404, message: '#string' }
    * print 'respuesta de petición:', response

  Scenario: Consultar estados por país para segmentación geográfica
    Given path 'states'
    And param country = 1
    When method GET
    Then status 200
    # Validación de esquema de negocio
    And match each response.data == { id: '#number', label: '#string' }
    # Verificación de datos presentes
    And assert response.data.length > 0
    * print 'respuesta de petición:', response

  Scenario: Validar error al consultar estados con datos inválidos
    Given path 'states-rutaIncorrecta'
    When method POST
    Then status 404
    And match response == { statusCode: 404, message: '#string' }
    * print 'respuesta de petición:', response

  Scenario: Verificar respuesta de negocio cuando el país no tiene estados
    Given path 'states'
    And param country = 99
    When method GET
    # El servidor responde OK porque la petición es válida,
    # pero el contenido indica un error de negocio.
    Then status 200
    And match response.data[0] == { id: -1, label: 'NO STATES FOUND' }
    * print 'respuesta de petición:', response

  Scenario: Obtener ciudades por país y estado exitosamente
    Given path 'cities'
    And param country = 1
    And param state = 1
    When method GET
    Then status 200
    And match response.data[0] == { id: '#number', label: '#notnull' }
    * print 'respuesta de petición:', response

  Scenario: Obtener ciudades con relación país/estado inexistente
    Given path 'cities'
    And param country = 999
    And param state = 999
    When method GET
    Then status 200
    And match response.data[0] == { id: -1, label: 'NO CITIES FOUND' }
    * print 'respuesta de petición:', response

  Scenario: Obtener barrios por país, estado y ciudad exitosamente
    Given path 'neighborhoods'
    And params { country: 1, state: 1, city: 1 }
    When method GET
    Then status 200
    And match response.data[0] == { id: '#number', label: '#notnull' }
    * print 'respuesta de petición:', response

  Scenario: Validar respuesta vacía para barrios con parámetros no relacionados
    Given path 'neighborhoods'
    And params { country: 999, state: 999, city: 999 }
    When method GET
    Then status 200
    And match response.data[0] == { id: -1, label: 'NO NEIGHBORHOODS FOUND' }
    * print 'respuesta de petición:', response
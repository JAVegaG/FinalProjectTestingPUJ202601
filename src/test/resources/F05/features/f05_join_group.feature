@f05 @GestionInvitacion
Feature: F-05 — Unión al grupo mediante enlace de invitación

  Background:
    * url baseUrl
    * def users = read('classpath:F05/data/users.json')

    # Login — usuarios ya existen en el entorno
    * def guestResult  = call read('classpath:F05/helpers/login.feature') users.guest
    * def guestToken   = guestResult.token

    * def memberResult = call read('classpath:F05/helpers/login.feature') users.member
    * def memberToken  = memberResult.token

    * def outsiderResult = call read('classpath:F05/helpers/login.feature') users.outsider
    * def outsiderToken  = outsiderResult.token

    # Leer el inviteUrl generado por F-04 y extraer el token
    * def inviteResult = read('file:build/invite-result.json')
    * def inviteToken  = inviteResult.inviteUrl.split('=').pop()
    * print 'Invite token extraído:', inviteToken

      # Token de un grupo ya activado para TC-JG-05
    * def activeGroupResult = read('classpath:F05/data/token-activado.json')
    * def activeGroupToken  = activeGroupResult.token
    * print 'Token de grupo ACTIVE:', activeGroupToken

  # ────────────────────────────────────────────────
  # CLASES NO VÁLIDAS — primero, no modifican estado
  # ────────────────────────────────────────────────

  @auth @tc-jg-02
  Scenario: [TC-JG-02] Sin header Authorization — debe retornar 401
    Given path '/saving-groups/join/' + inviteToken
    When method POST
    Then status 401
    * print 'Respuesta sin auth:', response

  @token @tc-jg-03
  Scenario: [TC-JG-03] Token con formato inválido — debe retornar 400
    Given path '/saving-groups/join/aadadasnñ$_invalid_token'
    And header Authorization = 'Bearer ' + guestToken
    When method POST
    Then status 400
    * print 'Respuesta token inválido:', response

  # ────────────────────────────────────────────────
  # VALORES LÍMITE — no modifican estado
  # ────────────────────────────────────────────────

  @boundary @TC-JG-07
  Scenario: [VL-T-07] Token de 31 chars — off-by-one inferior, debe retornar 400
    Given path '/saving-groups/join/1234567890abcdef1234567890abcde'
    And header Authorization = 'Bearer ' + guestToken
    When method POST
    Then status 400
    * print 'Respuesta token 31 chars:', response

  @boundary @tc-jg-08
  Scenario: [TC-JG-08] Token de 33 chars — off-by-one superior, debe retornar 400
    Given path '/saving-groups/join/1234567890abcdef1234567890abcdef1'
    And header Authorization = 'Bearer ' + guestToken
    When method POST
    Then status 400
    * print 'Respuesta token 33 chars:', response

  @boundary @tc-jg-09
  Scenario: [TC-JG-09] Token vacío — límite inferior absoluto, debe retornar 404
    Given path '/saving-groups/join/'
    And header Authorization = 'Bearer ' + guestToken
    When method POST
    Then status 404
    * print 'Respuesta token vacío:', response

  @boundary @tc-jg-10
  Scenario: [TC-JG-10] Token de 1 carácter — debe retornar 400
    Given path '/saving-groups/join/a'
    And header Authorization = 'Bearer ' + guestToken
    When method POST
    Then status 400
    * print 'Respuesta token 1 char:', response

  # ────────────────────────────────────────────────
  # FLUJOS QUE MODIFICAN ESTADO
  # Orden: guest → member → outsider (sin cupos)
  # ────────────────────────────────────────────────

  @happy-path @tc-jg-01-guest
  Scenario: [TC-JG-01-GUEST] Guest se une exitosamente
    Given path '/saving-groups/join/' + inviteToken
    And header Authorization = 'Bearer ' + guestToken
    When method POST
    Then status 201
    And match response.data.message == 'Group successfully joined'
    And match response.data.savingGroupId == '#notnull'
    And match response.data.invitationStatus == 'ACCEPTED'
    * print 'Respuesta guest unido exitosamente:', response

  @happy-path @tc-jg-01-member
  Scenario: [TC-JG-01-MEMBER] Member se une exitosamente
    Given path '/saving-groups/join/' + inviteToken
    And header Authorization = 'Bearer ' + memberToken
    When method POST
    Then status 201
    And match response.data.message == 'Group successfully joined'
    And match response.data.savingGroupId == '#notnull'
    And match response.data.invitationStatus == 'ACCEPTED'
    * print 'Respuesta member unido exitosamente:', response

  @sin-cupos @tc-jg-06
  Scenario: [TC-JG-06] Outsider no puede unirse — sin cupos disponibles
    Given path '/saving-groups/join/' + inviteToken
    And header Authorization = 'Bearer ' + outsiderToken
    When method POST
    Then status 400
    * print 'Respuesta no hay cupos disponibles:', response

  @token @tc-jg-04
  Scenario: [TC-JG-04] Intento duplicado de unirse — debe retornar  400
    Given path '/saving-groups/join/' + inviteToken
    And header Authorization = 'Bearer ' + memberToken
    When method POST
    Then status 400
    And match response.message contains 'already'
    * print 'Respuesta intento duplicado:', response

  @token @tc-jg-05
  Scenario: [TC-JG-05] Intento de unirse a un grupo ACTIVE — debe retornar 400
    Given path '/saving-groups/join/' + activeGroupToken
    And header Authorization = 'Bearer ' + outsiderToken
    When method POST
    Then status 400
    And match response.message == 'Group is already active'
    * print 'Respuesta grupo activo:', response


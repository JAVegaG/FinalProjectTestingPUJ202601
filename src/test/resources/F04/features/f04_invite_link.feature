@f04 @GestionInvitacion
Feature: F-04 — Generación de enlace de invitación

  Background:
    * url baseUrl
    * def users   = read('classpath:F04/data/users.json')
    * def config  = read('classpath:F04/data/config.json')
    * def groupId = config.groupId

    # Login — usuarios ya existen en el entorno
    * def ownerResult    = call read('classpath:F04/helpers/login.feature') users.owner
    * def ownerToken     = ownerResult.token

    * def outsiderResult = call read('classpath:F04/helpers/login.feature') users.outsider
    * def outsiderToken  = outsiderResult.token

  # ────────────────────────────────────────────────
  # FLUJO FELIZ
  # ────────────────────────────────────────────────

  @happy-path @tc-il-01
  Scenario: [TC-IL-01] Generar enlace exitosamente
    Given path '/saving-groups/' + groupId + '/invite-link'
    And header Authorization = 'Bearer ' + ownerToken
    When method GET
    Then status 200
    And match response.data.inviteUrl == '#notnull'
    And match response.data.inviteUrl == '#string'
    * karate.write(response.data, 'invite-result.json')
    * print 'Invite URL generado:', response.data.inviteUrl

  # ────────────────────────────────────────────────
  # CLASES NO VÁLIDAS — AUTENTICACIÓN
  # ────────────────────────────────────────────────

  @auth @tc-il-02
  Scenario: [TC-IL-02] Sin header Authorization — debe retornar 401
    Given path '/saving-groups/' + groupId + '/invite-link'
    When method GET
    Then status 401
    * print 'Respuesta sin auth:', response

  @auth @tc-il-04
  Scenario: [TC-IL-04] Usuario no pertenece al grupo — debe retornar 403
    Given path '/saving-groups/' + groupId + '/invite-link'
    And header Authorization = 'Bearer ' + outsiderToken
    When method GET
    Then status 403
    * print 'Respuesta sin permisos:', response

  # ────────────────────────────────────────────────
  # CLASES NO VÁLIDAS — groupId
  # ────────────────────────────────────────────────

  @groupid @tc-il-03
  Scenario: [TC-IL-03] groupId no existe en BD — debe retornar 404
    Given path '/saving-groups/9999999/invite-link'
    And header Authorization = 'Bearer ' + ownerToken
    When method GET
    Then status 404
    * print 'Respuesta grupo no existe:', response

  @groupid @tc-il-05
  Scenario: [TC-IL-05] groupId alfanumérico "FF" — debe retornar 500
    Given path '/saving-groups/FF/invite-link'
    And header Authorization = 'Bearer ' + ownerToken
    When method GET
    Then status 500
    * print 'Respuesta groupId alfanumérico:', response

  @groupid @tc-il-06
  Scenario: [TC-IL-06] groupId decimal "1.0" — debe retornar 500
    Given path '/saving-groups/1.0/invite-link'
    And header Authorization = 'Bearer ' + ownerToken
    When method GET
    Then status 500
    * print 'Respuesta groupId decimal:', response

  # ────────────────────────────────────────────────
  # VALORES LÍMITE
  # ────────────────────────────────────────────────

  @boundary @tc-il-07
  Scenario: [TC-IL-07] groupId = 0 — off-by-one inferior, debe retornar 404
    Given path '/saving-groups/0/invite-link'
    And header Authorization = 'Bearer ' + ownerToken
    When method GET
    Then status 404
    * print 'Respuesta groupId = 0:', response

  @boundary @tc-il-08
  Scenario: [TC-IL-08] groupId = 4294967296 — sobre el máximo, debe retornar 500
    Given path '/saving-groups/4294967296/invite-link'
    And header Authorization = 'Bearer ' + ownerToken
    When method GET
    Then status 500
    * print 'Respuesta groupId máximo:', response

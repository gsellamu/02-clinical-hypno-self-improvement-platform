Feature: Human-In-The-Loop (HITL) Review
  As a platform ensuring clinical quality
  I want expert clinician oversight
  So that AI decisions are validated and users receive appropriate care

  Background:
    Given licensed clinicians are available for review
    And the HITL escalation service is running
    And the review queue dashboard is accessible

  @hitl @escalation
  Scenario: Safety Guardian Yellow triggers HITL review
    Given Safety Guardian detects status "yellow"
    When the session completes
    Then a hitl_escalations record should be created with:
      | field                | value                           |
      | escalation_id        | UUID                            |
      | session_id           | <current_session>               |
      | user_id              | <anonymized_user_id>            |
      | escalation_reason    | "safety_yellow_trauma_mention"  |
      | priority             | "medium"                        |
      | created_at           | timestamp                       |
      | review_deadline      | created_at + 24 hours           |
      | review_status        | "pending"                       |
    And the session should be flagged in user's record
    And the user should see "session under review for quality"

  @hitl @review-queue
  Scenario: Clinician accesses prioritized review queue
    Given 15 sessions are pending HITL review
    When the clinician logs into review dashboard
    Then the queue should be sorted by:
      | sort_priority | field                      |
      | 1             | crisis_level (red > yellow)|
      | 2             | review_deadline (soonest)  |
      | 3             | user_risk_score            |
    And each item should display:
      | display_field        | source                        |
      | session_summary      | Reflection Summarizer output  |
      | safety_concerns      | Safety Guardian flags         |
      | user_context         | anonymized demographics       |
      | time_to_deadline     | calculated remaining hours    |
    And the clinician should be able to claim a review

  @hitl @review-actions
  Scenario: Clinician approves session with modifications
    Given a clinician is reviewing session "ABC123"
    And the session contains "unsent letter to abusive parent"
    When the clinician reviews the AI responses
    Then the clinician can take actions:
      | action              | effect                                 |
      | approve_as_is       | session unlocks, no changes            |
      | approve_with_edits  | clinician modifies AI response         |
      | reject_and_replace  | clinician writes full replacement      |
      | escalate_to_senior  | flags for senior clinician review      |
      | request_user_contact| initiates outreach to user             |
    And the action should be logged with clinician_id
    And the user should be notified of review completion

  @hitl @feedback-loop
  Scenario: Clinician feedback improves AI models
    Given a clinician reviews 20 sessions
    When the clinician marks AI responses as:
      | rating        | count |
      | excellent     | 12    |
      | good          | 5     |
      | needs_improvement | 2 |
      | inappropriate | 1     |
    Then the ratings should be stored in ai_decision_log
    And the "inappropriate" case should trigger model audit
    And the feedback should be aggregated for:
      | use_case                     |
      | model_fine_tuning            |
      | prompt_engineering_refinement|
      | safety_guardrail_updates     |
    And monthly reports should summarize trends

  @hitl @escalation-urgency
  Scenario: Code Red escalations bypass queue
    Given a Code Red crisis is detected
    When the escalation is created
    Then it should:
      | immediate_action                      |
      | send_urgent_Slack_notification        |
      | text_on_call_clinician                |
      | bypass_normal_queue                   |
      | appear_in_urgent_dashboard            |
      | require_acknowledgment_within_5min    |
    And if not acknowledged, it should escalate to supervisor
    And the response time should be tracked

  @hitl @anonymization
  Scenario: User data is anonymized for reviewers
    Given a session is queued for HITL review
    When the clinician accesses the session
    Then the displayed data should be:
      | field           | anonymization                    |
      | user_name       | "User #47291" (anonymized ID)    |
      | email           | hidden                           |
      | location        | "United States" (country only)   |
      | age             | "30-35" (age range)              |
      | session_content | full text (necessary for review) |
    And PII should only be accessible with explicit consent
    And de-anonymization should be audit-logged

  @hitl @batch-review
  Scenario: Clinician reviews multiple sessions for same user
    Given a user has 5 sessions pending review
    When the clinician selects "batch review user ABC"
    Then all 5 sessions should load in chronological order
    And the clinician should see longitudinal trends:
      | trend_metric          |
      | sentiment_over_time   |
      | recurring_themes      |
      | safety_status_history |
      | exercise_engagement   |
    And the clinician can approve/reject all at once
    And individual session actions should still be supported

  @hitl @training-mode
  Scenario: Junior clinician reviews with senior oversight
    Given a junior clinician is in training mode
    When they review a session
    Then their decisions should be marked "provisional"
    And a senior clinician should counter-sign
    And discrepancies should be flagged for discussion
    And training metrics should track agreement rates

  @hitl @sla-tracking
  Scenario: Review SLAs are monitored
    Given HITL reviews have SLA targets:
      | priority | target_review_time |
      | urgent   | 2 hours            |
      | high     | 8 hours            |
      | medium   | 24 hours           |
      | low      | 72 hours           |
    When reviews are completed
    Then the actual review time should be logged
    And SLA breaches should trigger alerts
    And weekly reports should show SLA compliance %
    And chronic breaches should trigger capacity planning

  @hitl @clinician-notes
  Scenario: Clinician adds clinical notes to review
    Given a clinician is reviewing a session
    When they add notes:
      """
      User demonstrates good insight. AI response was appropriate but could
      be more trauma-informed. Recommended adding grounding exercise.
      """
    Then the notes should be stored in hitl_escalations.clinician_notes
    And the notes should be visible to future reviewers
    And the notes should NOT be shown to the user (internal)
    And sensitive notes should be encrypted

  @hitl @user-notification
  Scenario: User is notified when review completes
    Given a user's session has been under review for 12 hours
    When the clinician approves the session
    Then the user should receive notification:
      | channel      | message                                    |
      | in_app       | "Your session has been reviewed and approved" |
      | email_opt_in | "You can now continue your journaling journey"|
    And the session should unlock for continued use
    And the user should NOT see clinician notes

  @hitl @audit-trail
  Scenario: Complete audit trail for compliance
    Given a HITL review is completed
    When the audit trail is generated
    Then it should include:
      | audit_element            | data                           |
      | escalation_created_at    | timestamp                      |
      | assigned_to_clinician    | clinician_id + timestamp       |
      | clinician_viewed_at      | timestamp                      |
      | clinician_action         | approve/reject/escalate        |
      | action_rationale         | clinician notes (if provided)  |
      | user_notified_at         | timestamp                      |
      | session_unlocked_at      | timestamp                      |
    And the trail should be immutable
    And the trail should be exportable for regulatory compliance

  @hitl @capacity-management
  Scenario: Review queue alerts on capacity issues
    Given 100 sessions are pending HITL review
    And the average review time is 15 minutes
    And 3 clinicians are available
    When the system calculates capacity
    Then it should estimate:
      | metric                  | calculation                    |
      | total_review_hours      | 100 * 15min / 60 = 25 hours    |
      | available_hours_per_day | 3 clinicians * 8 hours = 24 hrs|
      | estimated_clearance_time| > 1 day                        |
    And if clearance_time > SLA, alert should be sent
    And the alert should recommend temporary capacity increase

  @hitl @review-analytics
  Scenario: Platform analyzes review patterns
    Given 500 HITL reviews are completed
    When analytics are run
    Then insights should include:
      | insight_category           | example_finding                       |
      | most_common_flags          | "trauma mentions" (35% of reviews)    |
      | avg_review_time_by_type    | crisis: 8min, standard: 12min         |
      | clinician_agreement_rate   | 94% (when multiple review same session)|
      | AI_accuracy_improvement    | 15% fewer escalations over 6 months   |
    And the insights should inform AI model improvements
    And the insights should be reported monthly

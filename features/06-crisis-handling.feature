Feature: Crisis Handling & Emergency Protocols
  As a platform committed to user safety
  I want robust crisis detection and response
  So that users in danger receive immediate help

  Background:
    Given the Safety Guardian Agent is active
    And the crisis hotline database is current
    And the emergency escalation service is running

  @crisis @detection
  Scenario: Multi-signal crisis detection
    Given the user session is active
    When the system detects multiple crisis signals:
      | signal_type        | value                              |
      | explicit_ideation  | "I want to end it all"             |
      | behavioral_change  | sudden session frequency increase  |
      | sentiment_drop     | -0.85 (severe negative)            |
    Then the crisis_level should be "severe"
    And the Safety Guardian status should be "red"
    And immediate intervention should trigger

  @crisis @response-templates
  Scenario: Crisis response uses vetted templates
    Given Safety Guardian detects crisis level "severe"
    When generating crisis response
    Then the response should use template "CRISIS_SUICIDAL_IDEATION_v3":
      """
      I'm really concerned about what you've shared. Your safety is the priority right now.
      
      If you're in immediate danger, please:
      • Call 988 (Suicide & Crisis Lifeline) - 24/7, free, confidential
      • Text "HELLO" to 741741 (Crisis Text Line)
      • Call 911 or go to your nearest emergency room
      
      You don't have to go through this alone. Help is available right now.
      """
    And NO journaling exercises should be offered
    And the response should be delivered within 500ms
    And the template should be localized to user's region

  @crisis @hotline-lookup
  Scenario: Region-specific crisis resources
    Given the user's location is "United Kingdom"
    When a crisis is detected
    Then the crisis resources should include:
      | resource_type      | contact                  | availability |
      | Samaritans         | 116 123                  | 24/7         |
      | Crisis Text Line   | Text SHOUT to 85258      | 24/7         |
      | Emergency Services | 999                      | 24/7         |
    And resources should be prioritized by user preference (call vs text)
    And the database should have fallback to global resources

  @crisis @escalation-chain
  Scenario: Crisis escalates through notification chain
    Given a Code Red crisis is detected
    When the crisis response is delivered
    Then the escalation chain should execute:
      | step | action                              | timing      |
      | 1    | Log to crisis_logs table            | immediate   |
      | 2    | Create HITL escalation (urgent)     | immediate   |
      | 3    | Notify on-call clinician (Slack)    | < 2 minutes |
      | 4    | Email platform safety team          | < 5 minutes |
      | 5    | Create incident ticket              | < 10 minutes|
    And the user's session should be locked for safety
    And the escalation should include anonymized context

  @crisis @false-positive
  Scenario: Non-crisis phrase triggers gentle check-in
    Given the user writes "I'm dead tired from work"
    When Safety Guardian analyzes the input
    Then the crisis_level should be "low"
    And the response should include empathetic check-in:
      """
      It sounds like you're exhausted. How are you really doing?
      """
    And standard journaling should continue
    And the false positive should be logged for model tuning

  @crisis @follow-up
  Scenario: Post-crisis session monitoring
    Given a user had a Code Red crisis yesterday
    And the crisis was de-escalated successfully
    When the user returns for a new session
    Then the Safety Guardian should:
      | action                               |
      | flag_session_for_enhanced_monitoring |
      | load_crisis_history_context          |
      | apply_gentle_check_in_protocol       |
      | route_to_senior_clinician_review     |
    And the user should be welcomed back with care
    And progress should be tracked with sensitivity

  @crisis @concurrent-support
  Scenario: Crisis response doesn't replace professional care
    Given a crisis is detected
    When the response is delivered
    Then the message should explicitly state:
      """
      I'm an AI support tool, not a replacement for professional help.
      Please reach out to trained crisis counselors using the resources above.
      """
    And the user should be encouraged to call (not only text)
    And the platform should not attempt therapeutic intervention

  @crisis @blackout-period
  Scenario: User in active crisis cannot access advanced features
    Given the user triggered Code Red crisis
    And the crisis is < 24 hours old
    When the user attempts to start journaling session
    Then the advanced exercises should be disabled
    And only gentle check-in prompts should be available
    And the session should require clinician approval to proceed
    And the user should see supportive holding message

  @crisis @data-privacy
  Scenario: Crisis logs protect user privacy
    Given a crisis event is logged
    When the log is stored
    Then the crisis_logs table should:
      | field               | treatment                        |
      | user_id             | stored (for continuity of care)  |
      | timestamp           | stored                           |
      | crisis_level        | stored                           |
      | input_text          | hashed (not plaintext)           |
      | response_template   | stored (template_id only)        |
      | escalation_status   | stored                           |
    And raw user input should NEVER be logged
    And access to crisis_logs should be audit-logged

  @crisis @sentiment-tracking
  Scenario: Sentiment trends trigger proactive check-in
    Given a user's sentiment has declined over 5 sessions:
      | session | sentiment_score |
      | 1       | 0.6             |
      | 2       | 0.4             |
      | 3       | 0.2             |
      | 4       | -0.1            |
      | 5       | -0.3            |
    Then the Safety Guardian should flag "trending_negative"
    And a gentle check-in should be triggered:
      """
      I've noticed things seem heavier lately. How are you feeling about our sessions?
      """
    And HITL review should be scheduled
    And the trend should be visualized for clinician

  @crisis @multi-language
  Scenario: Crisis resources support user's language
    Given the user's preferred language is "Spanish"
    When a crisis is detected
    Then the response should be in Spanish
    And the hotline resources should include Spanish-speaking lines
    And the translation should be human-verified (not auto-translated)

  @crisis @cooldown
  Scenario: User can self-report feeling better
    Given the user triggered Code Yellow (mild concern)
    And 30 minutes have passed
    When the user is prompted "How are you feeling now?"
    And the user responds "I'm okay, just needed to vent"
    Then the Safety Guardian should:
      | action                          |
      | re-assess_safety_status         |
      | potentially_downgrade_to_green  |
      | log_self_reported_improvement   |
      | maintain_gentle_monitoring      |
    And the user should be able to continue session
    And the cooldown should be logged for analysis

  @crisis @integration-911
  Scenario: Platform can initiate emergency contact (with consent)
    Given the user has consented to emergency contact feature
    And a Code Red crisis is detected
    And the user confirms "Yes, I need help now"
    When the emergency contact flow activates
    Then the system should:
      | step                                      |
      | collect_user_location (if permitted)      |
      | provide_direct_911_calling_option         |
      | offer_to_connect_to_crisis_line           |
      | send_emergency_contact_to_designated_person|
    And the user should maintain control over contact
    And the feature should be opt-in only

  @crisis @clinician-handoff
  Scenario: Crisis session hands off to live clinician
    Given a Code Red crisis is active
    And a licensed clinician is available
    When the handoff is initiated
    Then the transition should include:
      | handoff_element          | data                             |
      | session_context          | last 5 messages (anonymized)     |
      | crisis_level             | "red"                            |
      | user_consent             | "verbal consent to connect"      |
      | safety_plan_status       | "none established"               |
    And the AI should gracefully exit
    And the clinician should have full session history
    And the billing should switch to human-provided service

  @crisis @training-data
  Scenario: Crisis logs improve model safety
    Given 1000+ crisis events have been logged
    When the Safety Guardian model is retrained
    Then the training should use:
      | data_source            | treatment                      |
      | crisis_logs            | positive examples of detection |
      | false_positives        | negative examples              |
      | clinician_annotations  | ground truth labels            |
    And the model should be evaluated on held-out test set
    And improvements should be validated before deployment
    And user privacy should be maintained (no raw text)

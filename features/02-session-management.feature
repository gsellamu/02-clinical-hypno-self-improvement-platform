Feature: Session Management - Journaling Session Lifecycle
  As a user engaging with the platform
  I want seamless session management across modalities
  So that my progress is tracked and context is maintained

  Background:
    Given the user is authenticated
    And the Intake & Triage Agent is available
    And the database connection is established

  @session @intake
  Scenario: New user completes intake assessment
    Given the user has no prior sessions
    When the user starts a new journaling session
    Then an Intake & Triage assessment should be triggered
    And the SessionIntent should be created with:
      | field            | value      |
      | goal_category    | NULL       |
      | intensity_level  | NULL       |
      | readiness_score  | NULL       |
      | contraindications| []         |
    And the user should be prompted with intake questions
    And the session_status should be "intake_pending"

  @session @intake
  Scenario: Intake classifies goal as relationship stress
    Given the user is in intake flow
    When the user responds "I'm having issues with my partner, feeling disconnected"
    Then the Intake & Triage Agent should classify:
      | field            | value         |
      | goal_category    | relationships |
      | intensity_level  | 3             |
      | readiness_score  | 7             |
    And the SessionIntent should be saved to database
    And the Journaling Coach should be notified
    And recommended techniques should include ["unsent_letter", "dialogue", "sentence_stems"]

  @session @resume
  Scenario: Returning user resumes previous session
    Given the user has a session with status "in_progress"
    And the session was last active 2 hours ago
    When the user returns to the platform
    Then the previous SessionContext should be loaded
    And the user should see a "Continue where you left off" prompt
    And the agent_outputs from the last turn should be retrieved
    And the session_updated_at timestamp should be refreshed

  @session @state
  Scenario: Session state transitions through workflow
    Given a new session is created
    When the session progresses through the workflow
    Then the status should transition in order:
      | from              | to                | trigger              |
      | created           | intake_pending    | session_start        |
      | intake_pending    | safety_screening  | intake_complete      |
      | safety_screening  | active            | safety_green         |
      | active            | reflecting        | exercise_complete    |
      | reflecting        | completed         | user_confirms        |
    And each transition should be logged to session_events

  @session @timeout
  Scenario: Inactive session times out gracefully
    Given a session has been active for 45 minutes
    And no user interaction for 15 minutes
    When the timeout threshold is reached
    Then the session status should change to "timed_out"
    And the current exercise state should be auto-saved
    And a gentle notification should be queued for next login
    And the session should be marked resumable

  @session @multi-modal
  Scenario: User switches from Web to VR mode mid-session
    Given the user is in an active web session
    And the current exercise is "sprint journaling"
    When the user initiates VR mode
    Then the SessionContext should be serialized
    And the VR session should be created with:
      | field                | value                    |
      | parent_session_id    | <web_session_id>         |
      | modality             | vr                       |
      | xr_environment       | cozy_cabin               |
    And the exercise progress should be transferred
    And the Safety Guardian constraints should carry over

  @session @concurrent
  Scenario: User attempts concurrent sessions (prevent)
    Given the user has an active session on device A
    When the user starts a new session on device B
    Then the new session should be rejected
    And the response should indicate "active session exists"
    And the user should be offered to:
      | option           |
      | resume_existing  |
      | force_close_old  |
      | join_session     |

  @session @analytics
  Scenario: Session completion triggers analytics aggregation
    Given a user completes a journaling session
    When the session status changes to "completed"
    Then the session_outcomes record should be created with:
      | field                    | source                          |
      | total_duration_minutes   | calculated from timestamps      |
      | exercises_completed      | count from agent_outputs        |
      | themes_identified        | Reflection Summarizer output    |
      | user_sentiment           | sentiment analysis              |
      | follow_up_recommended    | boolean                         |
    And user_progress should be updated
    And the next session recommendation should be generated

  @session @export
  Scenario: User exports session artifacts
    Given a completed session with 3 journaling exercises
    When the user requests session export
    Then a PDF document should be generated containing:
      | section                  |
      | session_summary          |
      | exercises_with_prompts   |
      | user_reflections         |
      | themes_identified        |
      | next_steps               |
    And the document should be stored in MinIO
    And a presigned download URL should be returned
    And the export event should be logged

  @session @hitl
  Scenario: Session flagged for HITL review
    Given a session triggered Safety Guardian "yellow"
    When the session is completed
    Then a hitl_escalations record should be created
    And the escalation priority should be "medium"
    And the review_status should be "pending"
    And the session should be queued for clinician review
    And the user should be notified "session under review"

  @performance
  Scenario: Session state retrieval within latency budget
    Given the user has 50 prior sessions
    When the user starts a new session
    Then the last session context should be retrieved in < 200ms
    And the user_progress aggregate should be cached
    And the database query should use proper indexes

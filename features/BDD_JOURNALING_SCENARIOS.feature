# BDD Test Scenarios - Therapeutic Journaling Module
# Gherkin Feature Files for Behavioral Testing

Feature: Starting a Journaling Session
  As a client using the therapeutic journaling platform
  I want to start a new journaling session safely
  So that I can process my thoughts and emotions with appropriate guidance

  Background:
    Given the user "Sarah" is authenticated
    And the user has completed onboarding
    And the user's E&P profile shows "65% Emotional, 35% Physical"
    And the Safety Guardian service is operational

  Scenario: Starting a session with Code Green safety status
    Given the user's recent sentiment trend is "stable"
    And the user has no recent crisis events
    When the user clicks "Start Journaling" in the client portal
    Then the Safety Guardian should check for crisis signals
    And the safety status should be "green"
    And the system should transition to the Intake state
    And the user should see the prompt "What brings you to journaling today?"
    And the session should be logged in the journaling_sessions table

  Scenario: Starting a session with Code Yellow safety status (modified approach)
    Given the user's recent sentiment trend is "declining"
    And the user's last journaling session contained themes ["relationship_conflict", "anger"]
    And the user has had 3 recent trigger events
    When the user clicks "Start Journaling" in the client portal
    Then the Safety Guardian should detect multiple warning signals
    And the safety status should be "yellow"
    And the system should apply safety constraints ["no_unsent_letter", "gentle_pacing", "extended_grounding"]
    And the system should transition to the ModifiedIntake state
    And the user should see a gentler prompt "What would feel supportive to explore today?"
    And the timebox should be reduced to 10 minutes maximum
    And the session should be flagged for HITL review

  Scenario: Starting a session with Code Red safety status (crisis detected)
    Given the user submits a pre-session message containing "I can't take this anymore"
    And the Safety Guardian detects explicit crisis signals
    When the user attempts to start a journaling session
    Then the safety status should be "red"
    And the crisis level should be "severe"
    And the system should immediately block the journaling session
    And the user should see crisis resources for their region
    And the crisis response should include "988 Suicide & Crisis Lifeline"
    And an urgent HITL escalation should be created
    And a crisis log should be saved with hashed input (no plaintext)
    And the session should NOT proceed to Intake

---

Feature: Completing an Unsent Letter Exercise
  As a client working through relationship issues
  I want to write an unsent letter to express my feelings
  So that I can process emotions without escalating conflict

  Background:
    Given the user "Marcus" is in an active journaling session
    And the user's E&P profile shows "35% Emotional, 65% Physical"
    And the presenting issue is "relationships"
    And the safety status is "green"
    And the selected technique is "unsent_letter"

  Scenario: Successfully completing an unsent letter within timebox
    Given the technique configuration specifies:
      | timebox_minutes | 15              |
      | recipient       | partner         |
      | tone            | honest_but_kind |
    And the opening prompt is "Write a letter to your partner expressing what you wish you could say"
    When the user writes for 12 minutes
    And the user writes 847 words
    And the user completes the grounding close (3 deep breaths)
    Then the entry should be saved to journaling_artifacts table
    And the content should be AES-256 encrypted
    And the word count should be recorded as 847
    And the session should transition to Reflection state
    And theme extraction should identify ["desire_for_connection", "fear_of_vulnerability"]
    And sentiment analysis should return a score of 0.35 (positive shift)
    And action items should be extracted: ["Schedule date night", "Share feelings openly"]

  Scenario: Mid-exercise safety check detects Code Yellow (user triggers)
    Given the user has been writing for 5 minutes
    And the user writes "I'm so angry I could just leave forever"
    When the mid-exercise safety check runs (2-minute interval)
    Then the Safety Guardian should detect behavioral escalation
    And the safety status should be updated to "yellow"
    And the system should transition to GroundingBreak state
    And the user should be offered grounding options:
      | Three Deep Breaths       | 60 seconds  |
      | 5-4-3-2-1 Sensory        | 120 seconds |
      | Body Scan                | 180 seconds |
    And the user should be asked "How would you like to proceed?"
    And if the user selects "Resume journaling", continue from last auto-save
    And if the user selects "End session", transition to Reflection with partial entry

  Scenario: Session times out with auto-save recovery
    Given the user has been writing for 20 minutes
    And the timebox was set to 15 minutes
    And the user has not manually submitted the entry
    When the session timeout triggers
    Then the system should auto-save the partial entry
    And the entry status should be "timed_out"
    And the user should see "Your session has timed out. Your writing has been saved."
    And the session should be marked as "resumable"
    And the system should transition to Reflection state
    And the analysis should run on the partial entry
    And the user should be able to resume the session within 24 hours

---

Feature: Bilateral Drawing in XR (Quest 3)
  As a client using VR journaling
  I want to create bilateral drawings with both hands simultaneously
  So that I can engage in somatic regulation and creative expression

  Background:
    Given the user "Alex" is wearing a Quest 3 headset
    And the user is in the VR environment "forest_clearing"
    And the user's safety status is "green"
    And the selected technique is "bilateral_drawing"
    And hand tracking is enabled
    And spatial audio is configured with HRTF

  Scenario: Successfully completing bilateral drawing with symmetry detection
    Given the VR scene displays dual canvases (left and right)
    And Sophia avatar provides guidance: "Use both hands to draw simultaneously"
    And the drawing mode is set to "mirrored_symmetry"
    When the user draws with both hands for 12 minutes
    And the left hand creates 237 strokes
    And the right hand creates 241 strokes
    And the symmetry score is calculated as 0.87 (high symmetry)
    Then the bilateral drawing should be saved to journaling_artifacts table
    And the stroke data should be stored as JSONB:
      """
      {
        "left_hand": [{"x": 0.5, "y": 0.3, "z": 0.1, "timestamp": 1234}, ...],
        "right_hand": [{"x": -0.5, "y": 0.3, "z": 0.1, "timestamp": 1234}, ...]
      }
      """
    And the drawing should be rendered as a 2D image and saved to MinIO
    And the user should see the final mandala-like pattern
    And Sophia should acknowledge: "Beautiful work. Notice how both sides came together."
    And the session should transition to Reflection

  Scenario: VR performance drops below 72fps (motion sickness prevention)
    Given the user is actively drawing with both hands
    And the VR frame rate is 72fps
    When the system detects frame rate drop to 55fps
    Then the system should immediately reduce render complexity
    And non-essential visual effects should be disabled
    And the frame rate should recover to 72fps within 2 seconds
    And if frame rate does not recover, the system should pause the exercise
    And the user should see "Performance issue detected. Pausing for stability."
    And the partial drawing should be auto-saved
    And the user should be offered the option to continue or exit gracefully

  Scenario: User loses hand tracking mid-exercise (fallback to controllers)
    Given the user is drawing with hand tracking
    And 5 minutes have elapsed
    When the Quest 3 loses hand tracking (hands out of view)
    And hand tracking is unavailable for more than 5 seconds
    Then the system should switch to controller input mode
    And the user should see "Switching to controllers. Please use triggers to draw."
    And the drawing should continue without interruption
    And the stroke data should include input_method: "controller"
    And when hand tracking is restored, the system should offer to switch back
    And the user's drawing progress should be preserved throughout

---

Feature: Saving an Entry with Tags and Mood
  As a client completing a journaling session
  I want to save my entry with custom tags and mood tracking
  So that I can organize my journaling and track emotional patterns

  Background:
    Given the user "Priya" has completed writing a journal entry
    And the entry contains 624 words
    And the entry duration was 11 minutes
    And the technique used was "sprint"
    And the AI has extracted themes: ["work_stress", "imposter_syndrome"]

  Scenario: Saving entry with user-selected tags and mood rating
    Given the user is shown the reflection summary
    And the system suggests tags based on themes: ["work", "anxiety", "self_doubt"]
    And the system asks "How are you feeling now?"
    When the user confirms suggested tags
    And the user adds custom tag "team_meeting"
    And the user selects mood rating: "3/5 - Moderate"
    And the user clicks "Save & Complete"
    Then the entry should be saved to journaling_artifacts table with:
      | user_id           | priya-uuid-123    |
      | content_encrypted | [AES-256 bytes]   |
      | sensitivity_level | standard          |
    And the reflection should be saved to journaling_reflections table with:
      | recurring_themes    | ["work_stress", "imposter_syndrome"] |
      | sentiment_score     | -0.15 (slightly negative)            |
      | action_items        | ["Set boundaries with manager"]      |
    And a Kafka event should be published:
      """
      {
        "event_type": "journaling.session.completed",
        "user_id": "priya-uuid-123",
        "session_id": "session-uuid-456",
        "themes": ["work_stress", "imposter_syndrome"],
        "sentiment_score": -0.15,
        "mood_rating": 3
      }
      """
    And the user_progress table should be updated:
      | journaling_sessions_count | +1                    |
      | journaling_streak_days    | recalculated          |
      | last_journaling_at        | current timestamp     |

  Scenario: Auto-save during writing preserves tags and partial content
    Given the user is actively writing
    And 3 minutes have elapsed since last auto-save
    And the user has written 312 words so far
    When the 30-second auto-save timer triggers
    Then the partial entry should be saved with status "auto_save"
    And the auto-save count should increment to 6
    And the user should see a subtle indicator "Auto-saved"
    And if the user's browser crashes, the entry can be recovered
    And when the user returns, they should see "Resume your journaling session?"
    And clicking "Resume" should restore the content at the last auto-save point

  Scenario: Therapist reviews client's tagged entries before next session
    Given the therapist "Dr. Lisa" logs into the therapist dashboard
    And the therapist selects client "Priya"
    When the therapist views the journaling summary
    Then the therapist should see:
      | Period              | Last 7 days                           |
      | Session count       | 4 entries                             |
      | Top themes          | work_stress (3x), imposter_syndrome (2x) |
      | Sentiment trend     | Declining (-0.05 → -0.15 → -0.22)     |
      | Safety flags        | None                                  |
    And the therapist should see excerpts (first 50 words) of each entry
    And the therapist should see tags: ["work", "anxiety", "self_doubt", "team_meeting"]
    And the therapist should be able to add a note: "Focus next session on assertiveness skills"
    And the note should be encrypted and linked to the client's record
    And the client should NOT see the therapist's internal notes

---

Feature: Safety Escalation Flow
  As the Safety Guardian system
  I want to detect crisis signals and escalate appropriately
  So that users receive immediate support and clinicians are alerted

  Background:
    Given the Safety Guardian service is running on port 8005
    And the HITL escalation service is operational
    And crisis resource templates are loaded for all supported regions
    And the Kafka topic "journaling.safety.flagged" is configured

  Scenario: Code Red crisis detected with immediate escalation
    Given the user "Jordan" is starting a journaling session
    And the user submits pre-session input: "I want to end it all"
    When the Safety Guardian runs the safety_screen() tool
    Then explicit ideation should be detected with confidence 0.95
    And the safety status should be "red"
    And the crisis level should be "severe"
    And the journaling session should be immediately blocked
    And the user should see crisis resources within 500ms:
      | 988 Suicide & Crisis Lifeline | Call or Text 988    |
      | Crisis Text Line              | Text HELLO to 741741 |
      | Local Emergency               | Call 911             |
    And a crisis log should be created with:
      | input_hash SHA-256    | [hashed value]           |
      | crisis_level          | severe                   |
      | resources_provided    | [array of resources]     |
      | hitl_escalated        | true                     |
    And an urgent HITL escalation should be created:
      | priority              | urgent                   |
      | review_deadline       | 2 hours from now         |
      | anonymized_user_id    | User #47291              |
    And a Slack notification should be sent to the on-call clinician
    And an email should be sent to the safety team
    And the user should be in a 24-hour blackout (advanced features disabled)

  Scenario: Code Yellow detected mid-exercise with grounding intervention
    Given the user "Taylor" is writing an unsent letter
    And the user has been writing for 8 minutes
    And the entry contains: "I'm so overwhelmed I can't breathe"
    When the 2-minute mid-exercise safety check runs
    Then the Safety Guardian should detect distress signals
    And the safety status should be updated to "yellow"
    And the system should transition to GroundingBreak state
    And the user should see: "Let's pause for a grounding break."
    And the user should be offered grounding exercises:
      | Three Deep Breaths (60s)     |
      | 5-4-3-2-1 Sensory (120s)     |
      | Body Scan (180s)             |
    And the partial entry should be auto-saved
    And a HITL escalation should be created with priority "medium"
    And the review deadline should be 24 hours
    And a Kafka event should be published:
      """
      {
        "event_type": "journaling.safety.flagged",
        "user_id": "taylor-uuid",
        "safety_status": "yellow",
        "context": "mid_exercise_check",
        "timestamp": "2026-02-11T..."
      }
      """

  Scenario: False positive detection with therapist override
    Given the user "Morgan" wrote: "I could just kill for a good coffee right now"
    And the initial safety check flagged this as potential violence
    And the safety status was set to "yellow"
    And a HITL escalation was created
    When the assigned clinician reviews the context
    And the clinician sees the full entry is about caffeine cravings
    And the clinician determines this is a false positive
    Then the clinician should click "Override - False Positive"
    And the clinician should add a note: "Colloquial expression, no actual risk"
    And the safety status should be updated to "green"
    And the session should be allowed to proceed normally
    And the false positive should be logged for AI model improvement
    And the Safety Guardian's threshold should be slightly adjusted
    And the user should receive an apology: "Thanks for your patience. You're all set to continue."
    And no further restrictions should apply to this user's account

---

# Additional Scenarios for Edge Cases

Feature: Edge Case - Network Disconnection During Journaling
  Scenario: User disconnects mid-writing with successful recovery
    Given the user is writing a journal entry
    And 347 words have been written
    And the last auto-save was 20 seconds ago
    When the user's network connection is lost
    Then the client should detect the disconnection within 5 seconds
    And the client should save the draft to browser localStorage
    And the user should see "Connection lost. Your work is saved locally."
    And when the connection is restored, the draft should sync to the server
    And the user should see "Connection restored. Syncing your entry..."
    And the entry should resume from the exact word count and cursor position

Feature: Edge Case - Multi-Device Session Conflict
  Scenario: User starts session on phone, tries to resume on desktop
    Given the user starts a journaling session on mobile at 2:00 PM
    And the user writes 200 words
    And the session is still active (not completed)
    When the user opens the desktop app at 2:15 PM
    And the user tries to start a new session
    Then the system should detect an active session on another device
    And the user should see "You have an active session on another device."
    And the user should be offered options:
      | Resume on this device   | Transfer session to desktop |
      | End mobile session      | End other session, start new |
    And if the user selects "Resume on this device"
    And the latest auto-saved content should be loaded
    And the mobile session should be marked as "transferred"

Feature: Edge Case - LLM Service Outage During Analysis
  Scenario: Claude API timeout during theme extraction
    Given the user has completed a 15-minute journal entry
    And the system is in the Reflection state
    And the theme extraction calls Claude Sonnet 4.5
    When the Claude API times out after 30 seconds
    Then the system should retry the request 3 times with exponential backoff
    And if all retries fail, the system should fall back to GPT-4o
    And if GPT-4o also fails, the system should use keyword extraction (non-LLM)
    And the user should see "Analysis is taking longer than usual..."
    And the session should NOT fail or lose data
    And a generic summary should be provided: "Your entry has been saved. Themes will be available shortly."
    And the analysis should be queued for async processing
    And the user should receive a notification when analysis completes

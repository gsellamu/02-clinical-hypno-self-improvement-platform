Feature: Journaling Exercises - Core Therapeutic Modalities
  As a user seeking self-reflection support
  I want guided journaling exercises with proper structure
  So that I can explore my thoughts safely and effectively

  Background:
    Given the user has completed intake
    And Safety Guardian status is "green"
    And the Journaling Coach Agent is active

  @exercise @sprint
  Scenario: Sprint journaling with 10-minute timebox
    Given the user selects "sprint journaling" technique
    And the user sets timebox to 10 minutes
    When the exercise begins
    Then the Content Producer should generate:
      | element              | content                                    |
      | opening_prompt       | "Write continuously for 10 minutes about..." |
      | timer_start          | 600 seconds countdown                      |
      | on_screen_reminders  | "Keep writing, don't edit"                 |
      | grounding_close      | "Take 3 deep breaths, notice how you feel" |
    And the UI should disable editing tools
    And the word count should be displayed live
    And background audio should be optional

  @exercise @unsent-letter
  Scenario: Unsent letter exercise with recipient framing
    Given the user selects "unsent letter" technique
    And the user inputs recipient as "my father"
    And Safety Guardian confirms no abuse disclosure
    When the exercise begins
    Then the prompt should include:
      """
      Write a letter to your father that you won't send.
      Express what you need to say without fear of consequences.
      This is for your eyes only.
      """
    And the format should guide:
      | section       |
      | Dear [name]   |
      | Opening       |
      | Body          |
      | Closing       |
    And the letter should be stored encrypted
    And send_options should be disabled

  @exercise @sentence-stems
  Scenario: Sentence stems for self-discovery
    Given the user selects "sentence stems" technique
    And the theme is "inner critic"
    When the exercise begins
    Then the Journaling Coach should provide 8-10 stems:
      | stem_example                              |
      | "My inner critic tells me..."             |
      | "When I hear this voice, I feel..."       |
      | "The criticism I most struggle with is..."|
      | "If I could respond to my critic, I'd say..."|
    And each stem should require 1-2 sentence completion
    And the stems should be presented sequentially
    And the user can skip stems

  @exercise @list-of-100
  Scenario: List-of-100 for exhaustive exploration
    Given the user selects "list of 100" technique
    And the topic is "things I'm grateful for"
    When the exercise begins
    Then the UI should display a numbered list input (1-100)
    And the user should be encouraged to continue past initial resistance
    And the counter should show progress (e.g., "37/100")
    And the Content Producer should provide encouragement at milestones:
      | milestone | message                                    |
      | 25        | "Great start! Keep the momentum going"     |
      | 50        | "Halfway there. Notice any surprises?"     |
      | 75        | "The deeper insights often come now"       |
      | 100       | "You did it! Review your list with curiosity"|
    And the completed list should be saved as artifact

  @exercise @non-dominant-hand
  Scenario: Non-dominant hand writing for accessing inner child
    Given the user selects "non-dominant hand" technique
    And the user confirms they are right-handed
    When the exercise begins
    Then the instruction should be:
      """
      Use your LEFT hand to write a response to:
      'What does my inner child want to tell me?'
      
      Don't worry about neatness. The awkwardness helps bypass your adult filters.
      """
    And the canvas should support freeform drawing/writing
    And the entry should be captured as image (not text)
    And the Reflection Summarizer should NOT attempt OCR

  @exercise @written-dialogue
  Scenario: Written dialogue between inner parts
    Given the user selects "written dialogue" technique
    And the user chooses parts as "inner critic" and "inner wisdom"
    When the exercise begins
    Then the format should alternate:
      | speaker       | prompt_example                          |
      | Inner Critic  | "You're not good enough because..."     |
      | Inner Wisdom  | "I hear your concern, and I also see..." |
    And each part should have 5-8 exchanges
    And the tone should be specified per part
    And the Somatic Regulator should offer grounding between exchanges

  @exercise @inventory
  Scenario: Inventory journaling with categorization
    Given the user selects "inventory" technique
    And the categories are ["relationships", "work", "health", "spirituality"]
    When the exercise begins
    Then the user should assess each category with prompts:
      | category      | prompt                                          |
      | relationships | "How am I showing up in my relationships?"      |
      | work          | "What's working/not working in my career?"      |
      | health        | "How am I caring for my physical/mental health?"|
      | spirituality  | "What brings me meaning and connection?"        |
    And each category should allow 3-5 minute reflection
    And the responses should be stored separately
    And the Reflection Summarizer should identify patterns across categories

  @exercise @springboard
  Scenario: Springboard prompt with multiple angles
    Given the user selects "springboard prompt" technique
    And the topic is "career transition"
    When the exercise begins
    Then the Journaling Coach should offer 3-5 prompts:
      | prompt                                                      |
      | "If money were no object, what would I be doing?"           |
      | "What skills do I have that I'm not using?"                 |
      | "What would my 80-year-old self advise me to do?"           |
      | "What am I afraid will happen if I make a change?"          |
    And the user can choose which prompt to explore
    And the user can switch prompts mid-exercise
    And multiple prompts can be completed in one session

  @exercise @reflection
  Scenario: Post-exercise reflection with theme extraction
    Given the user completes any journaling exercise
    When the exercise ends
    Then the Reflection Summarizer should analyze the content for:
      | analysis_dimension  | example_output                        |
      | recurring_themes    | ["self-doubt", "desire for connection"]|
      | emotional_tone      | "contemplative, with hints of hope"   |
      | action_items        | ["schedule coffee with friend"]       |
      | unresolved_questions| ["Am I ready to leave this job?"]     |
    And a non-judgmental summary should be presented
    And the user should be asked if the summary resonates
    And the themes should be stored for longitudinal tracking

  @exercise @adaptive
  Scenario: Exercise difficulty adapts to user energy
    Given the user indicates "low energy today"
    When the Journaling Coach suggests an exercise
    Then the recommendation should prefer:
      | low_energy_techniques |
      | sprint (5 min)        |
      | sentence_stems (5)    |
      | scribble_technique    |
    And complex exercises should be deferred
    And the timebox should be shortened automatically

  @exercise @grounding
  Scenario: Every exercise includes grounding closure
    Given the user completes any exercise
    When the exercise conclusion phase begins
    Then the Somatic Regulator should offer:
      | grounding_option              |
      | "3 deep breaths"              |
      | "5-4-3-2-1 sensory grounding" |
      | "Body scan from head to toe"  |
      | "Journal one word: how you feel now" |
    And the grounding should be < 2 minutes
    And the user can skip grounding (tracked)
    And skipping grounding frequently should trigger wellbeing check

  @exercise @accessibility
  Scenario: Voice-to-text for journaling exercises
    Given the user enables voice input
    When an exercise begins
    Then the Web Speech API should be activated
    And the transcription should appear in real-time
    And the user can edit transcription before finalizing
    And the audio should NOT be stored (privacy)

  @exercise @privacy
  Scenario: Sensitive entries are encrypted at rest
    Given the user completes an "unsent letter" to abusive parent
    When the entry is saved
    Then the content should be encrypted with user's key
    And the database should store only encrypted blob
    And the entry should be flagged as "high_sensitivity"
    And retrieval should require re-authentication

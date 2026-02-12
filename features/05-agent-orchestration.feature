Feature: Agent Orchestration - LangGraph Multi-Agent Workflow
  As the platform orchestrator
  I want coordinated multi-agent workflows
  So that journaling sessions are coherent, safe, and effective

  Background:
    Given the LangGraph orchestrator is running
    And all 8 agents are registered and healthy
    And the MCP tool layer is accessible

  @orchestration @workflow
  Scenario: Standard journaling session follows agent sequence
    Given a new user session is initiated
    When the workflow begins
    Then the agents should execute in order:
      | sequence | agent                  | expected_output                |
      | 1        | Safety Guardian        | safety_status, constraints[]   |
      | 2        | Intake & Triage        | SessionIntent JSON             |
      | 3        | Journaling Coach       | exercise_plan                  |
      | 4        | XR Scene Director      | scene_spec (if XR mode)        |
      | 5        | Content Producer       | narration + TTS + prompts      |
      | 6        | Somatic Regulator      | grounding_options              |
      | 7        | User Interaction       | user completes exercise        |
      | 8        | Reflection Summarizer  | themes + next_steps            |
    And each agent output should be logged to agent_outputs table
    And the workflow should support conditional branching

  @orchestration @safety-first
  Scenario: Safety Guardian blocks workflow on Code Red
    Given the workflow has started
    When Safety Guardian returns status "red"
    Then the workflow should immediately halt
    And agents 2-8 should NOT execute
    And the crisis response should be delivered
    And the session should be locked
    And HITL escalation should be created

  @orchestration @conditional
  Scenario: XR Scene Director only executes in VR mode
    Given the user session is in web mode (not VR)
    When the workflow reaches XR Scene Director
    Then the agent should be skipped
    And the workflow should continue to Content Producer
    And the scene_spec output should be NULL
    And the skip should be logged with reason "non_vr_session"

  @orchestration @parallel
  Scenario: Content Producer and Somatic Regulator execute in parallel
    Given the Journaling Coach has selected "sprint journaling"
    When the workflow reaches content generation phase
    Then Content Producer and Somatic Regulator should execute concurrently
    And both outputs should be awaited before proceeding
    And the combined outputs should be merged
    And the execution time should be min(agent_1, agent_2) not sum

  @orchestration @retry
  Scenario: Agent failure triggers intelligent retry
    Given the Reflection Summarizer encounters LLM timeout
    When the agent fails on first attempt
    Then the orchestrator should retry with exponential backoff:
      | attempt | delay | max_retries |
      | 1       | 0s    | -           |
      | 2       | 2s    | 3           |
      | 3       | 4s    | 3           |
    And the retry should use different LLM endpoint if available
    And persistent failures should trigger graceful degradation
    And the user should see "generating summary..." status

  @orchestration @mcp-tools
  Scenario: Agents call MCP tools for data operations
    Given the Journaling Coach needs user history
    When the agent executes
    Then it should call MCP tool "rag_retrieve" with:
      | parameter      | value                           |
      | collection     | user_journaling_history         |
      | user_id        | <session_user_id>               |
      | query          | "past exercises on relationships"|
      | top_k          | 5                               |
    And the tool should return relevant past sessions
    And the agent should incorporate context into exercise selection
    And the tool call should be logged to tool_usage_policy

  @orchestration @rag-librarian
  Scenario: RAG Librarian retrieves workbook guidance
    Given the Journaling Coach needs therapeutic framing
    When the RAG Librarian is invoked with query "unsent letter guidelines"
    Then the agent should:
      | step                        | action                                   |
      | embed_query                 | Use OpenAI embedding model               |
      | search_pinecone             | Query workbook_vectors collection        |
      | retrieve_top_3              | Get most relevant workbook chunks        |
      | paraphrase_guidance         | Rewrite in platform voice                |
      | cite_internally             | Log source but don't show to user        |
    And the retrieved guidance should be injected into prompt
    And the response should be workbook-aligned
    And the retrieval should complete < 500ms

  @orchestration @state-management
  Scenario: Workflow state persists across agent executions
    Given the workflow is at Journaling Coach step
    When the user's session disconnects mid-execution
    Then the workflow state should be saved to session_chains table
    And the last completed agent output should be checkpointed
    And on reconnection, the workflow should resume from checkpoint
    And no agent should re-execute unnecessarily

  @orchestration @hitl-handoff
  Scenario: Workflow pauses for HITL review
    Given Safety Guardian status is "yellow"
    And the requires_hitl_review flag is true
    When the workflow reaches HITL decision point
    Then the workflow should transition to "awaiting_review" state
    And a hitl_escalations record should be created with:
      | field              | value                          |
      | priority           | calculated from safety_status  |
      | review_deadline    | 24 hours                       |
      | context_snapshot   | serialized workflow state      |
    And the user should see "session under review" message
    And the workflow should resume after clinician approval

  @orchestration @cost-tracking
  Scenario: Agent execution costs are tracked per session
    Given a complete workflow execution
    When all agents have finished
    Then the crew_execution_log should aggregate:
      | metric                  | source                        |
      | total_input_tokens      | sum across all LLM calls      |
      | total_output_tokens     | sum across all LLM calls      |
      | total_llm_calls         | count of API requests         |
      | total_cost_usd          | calculated from pricing       |
      | execution_duration_sec  | workflow end - start time     |
    And the cost should be attributed to user_id
    And cost anomalies (> 2 std dev) should alert

  @orchestration @graceful-degradation
  Scenario: Essential agents fail gracefully with fallback
    Given the Reflection Summarizer is unavailable
    When the workflow attempts to execute it
    Then the orchestrator should:
      | fallback_action                                  |
      | skip_agent                                       |
      | provide_generic_reflection_prompt                |
      | log_degradation_event                            |
      | continue_workflow                                |
    And the user should receive simplified next steps
    And the session should still be completable
    And the incident should be logged for monitoring

  @orchestration @agent-versioning
  Scenario: Multiple agent versions coexist during deployment
    Given Journaling Coach v2 is being deployed
    And Journaling Coach v1 is still in production
    When a new session starts
    Then the orchestrator should use v1 for existing users
    And the orchestrator should use v2 for 10% canary group
    And the version should be logged in agent_outputs
    And performance metrics should be compared v1 vs v2

  @orchestration @timeout-budget
  Scenario: Workflow enforces total execution timeout
    Given a workflow has timeout budget of 60 seconds
    When agents execute sequentially
    Then the orchestrator should track cumulative time
    And if any agent exceeds remaining budget, it should be skipped
    And the workflow should complete within 60 seconds total
    And timeout events should be logged with agent context

  @orchestration @observability
  Scenario: Agent execution traces are captured
    Given a workflow completes successfully
    When querying the observability system
    Then the trace should include:
      | trace_element       | data                                |
      | trace_id            | unique workflow identifier          |
      | span_per_agent      | duration, inputs, outputs           |
      | dependencies        | which agents called which tools     |
      | performance_marks   | bottlenecks, slowest operations     |
      | error_stack         | if any agent failed                 |
    And the trace should be exportable to external APM
    And the trace should support distributed tracing

  @orchestration @human-in-loop
  Scenario: User can interrupt workflow for clarification
    Given the workflow is at Content Producer step
    When the user sends message "wait, I want to change my goal"
    Then the workflow should pause immediately
    And the current agent execution should complete
    And the user message should be processed
    And the Intake & Triage agent should re-classify
    And the workflow should re-plan from current state

  @orchestration @eval-scoring
  Scenario: Agent outputs are scored against rubrics
    Given a Journaling Coach output is generated
    When the output is evaluated
    Then the eval system should score on rubrics:
      | rubric_dimension       | scoring_method              |
      | safety_adherence       | keyword + sentiment check   |
      | helpfulness            | user feedback proxy         |
      | workbook_alignment     | RAG similarity to source    |
      | coherence              | LLM-as-judge                |
    And scores should be logged to quality_metrics
    And low-scoring outputs should trigger review
    And scores should feed into agent performance dashboards

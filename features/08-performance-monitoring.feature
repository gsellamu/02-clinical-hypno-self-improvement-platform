Feature: Performance, Monitoring & Observability
  As a platform operations team
  I want comprehensive monitoring and observability
  So that we maintain 99.9% uptime and optimal performance

  Background:
    Given the monitoring stack is deployed (Prometheus, Grafana, Datadog)
    And distributed tracing is enabled (OpenTelemetry)
    And log aggregation is active (ELK stack)

  @performance @latency
  Scenario: End-to-end session latency stays under SLA
    Given a user starts a journaling session
    When the complete workflow executes
    Then the latency breakdown should be:
      | component             | target_latency | measured      |
      | Safety Guardian       | < 300ms        | 245ms         |
      | Intake & Triage       | < 500ms        | 420ms         |
      | Journaling Coach      | < 800ms        | 650ms         |
      | Content Producer      | < 1200ms       | 980ms         |
      | Reflection Summarizer | < 600ms        | 530ms         |
      | Total (E2E)           | < 3500ms       | 2825ms        |
    And 95th percentile should be within target
    And outliers should trigger performance alerts

  @performance @throughput
  Scenario: Platform handles concurrent user sessions
    Given 1000 concurrent users are active
    When all users interact simultaneously
    Then the system should maintain:
      | metric                | target     | measured   |
      | avg_response_time     | < 2s       | 1.8s       |
      | error_rate            | < 0.1%     | 0.05%      |
      | database_connections  | < 500      | 320        |
      | cpu_utilization       | < 70%      | 58%        |
      | memory_usage          | < 80%      | 65%        |
    And autoscaling should trigger at 70% CPU
    And no user should experience degraded service

  @performance @database
  Scenario: Database queries are optimized
    Given the user_progress table has 1M+ records
    When a user's progress is retrieved
    Then the query should:
      | optimization           | implementation                    |
      | use_index              | idx_user_progress_user_id         |
      | execution_time         | < 50ms                            |
      | rows_scanned           | < 100 (not full table scan)       |
      | use_connection_pool    | yes (not new connection)          |
    And slow queries (> 100ms) should be logged
    And query plans should be reviewed weekly

  @performance @caching
  Scenario: Frequently accessed data is cached
    Given the same user makes 5 requests in 1 minute
    When the requests access user profile
    Then the cache behavior should be:
      | request | cache_status | source        | latency |
      | 1       | MISS         | PostgreSQL    | 45ms    |
      | 2       | HIT          | Redis         | 2ms     |
      | 3       | HIT          | Redis         | 2ms     |
      | 4       | HIT          | Redis         | 2ms     |
      | 5       | HIT          | Redis         | 2ms     |
    And cache hit rate should be > 85%
    And cache eviction policy should be LRU

  @monitoring @metrics
  Scenario: Business metrics are tracked
    Given the platform is running for 24 hours
    When daily metrics are aggregated
    Then the dashboard should show:
      | metric                     | value    |
      | total_sessions_started     | 3,450    |
      | sessions_completed         | 3,120    |
      | completion_rate            | 90.4%    |
      | avg_session_duration       | 32 min   |
      | crisis_escalations         | 12       |
      | hitl_reviews_pending       | 45       |
      | user_satisfaction_score    | 4.6/5.0  |
    And metrics should update in real-time
    And trends should be visualized in Grafana

  @monitoring @alerting
  Scenario: Anomalies trigger alerts
    Given baseline error rate is 0.05%
    When error rate spikes to 2.5%
    Then an alert should be triggered with:
      | alert_field        | value                               |
      | severity           | critical                            |
      | channel            | PagerDuty + Slack                   |
      | message            | "Error rate 50x baseline"           |
      | runbook_link       | https://wiki/error-spike-playbook   |
      | affected_service   | "journaling_coach"                  |
    And on-call engineer should acknowledge within 5 min
    And auto-mitigation should be attempted (restart service)

  @monitoring @logs
  Scenario: Structured logs support debugging
    Given an error occurs in Reflection Summarizer
    When the engineer queries logs
    Then each log entry should include:
      | field            | example_value                      |
      | timestamp        | 2026-02-11T14:23:45.123Z           |
      | service          | reflection_summarizer              |
      | level            | ERROR                              |
      | trace_id         | abc123-def456                      |
      | user_id          | anonymized_user_789                |
      | session_id       | session_xyz                        |
      | error_message    | "LLM timeout after 30s"            |
      | stack_trace      | full stack                         |
    And logs should be searchable in < 3 seconds
    And logs should be retained for 90 days

  @monitoring @tracing
  Scenario: Distributed traces show request flow
    Given a session workflow executes
    When the trace is visualized
    Then the trace should show:
      | span_name              | duration | parent             |
      | workflow_orchestrator  | 2850ms   | -                  |
      | safety_guardian        | 245ms    | workflow_orchestrator |
      | intake_triage          | 420ms    | workflow_orchestrator |
      | journaling_coach       | 650ms    | workflow_orchestrator |
      | rag_retrieve (tool)    | 180ms    | journaling_coach   |
      | llm_call               | 380ms    | journaling_coach   |
    And bottlenecks should be highlighted
    And traces should link to logs

  @monitoring @uptime
  Scenario: Uptime monitoring detects outages
    Given health check endpoints are configured
    When uptime monitors ping every 30 seconds
    Then the checks should verify:
      | endpoint                  | expected_status | timeout |
      | /health                   | 200             | 5s      |
      | /api/v1/sessions/health   | 200             | 5s      |
      | /api/v1/agents/health     | 200             | 5s      |
      | /api/v1/database/health   | 200             | 5s      |
    And any non-200 should trigger incident
    And 3 consecutive failures should page on-call
    And uptime should be measured at 99.9%

  @monitoring @cost
  Scenario: Cloud costs are tracked per service
    Given the platform runs on AWS
    When monthly billing is analyzed
    Then costs should be broken down by:
      | cost_category      | monthly_cost | optimization_opportunity |
      | EC2 (agents)       | $2,400       | use spot instances       |
      | RDS (PostgreSQL)   | $1,800       | resize to smaller instance|
      | S3 (artifacts)     | $450         | lifecycle policy for old data|
      | OpenAI API         | $3,200       | cache embeddings better  |
      | ElevenLabs TTS     | $1,100       | pre-generate common audio|
    And costs should be attributed to user_id
    And cost anomalies should alert finance team

  @monitoring @user-analytics
  Scenario: User engagement is measured
    Given 1000 active users over 30 days
    When engagement metrics are calculated
    Then the dashboard should show:
      | metric                  | value  |
      | DAU (daily active)      | 350    |
      | WAU (weekly active)     | 720    |
      | MAU (monthly active)    | 1000   |
      | avg_sessions_per_user   | 4.2    |
      | retention_day_7         | 68%    |
      | retention_day_30        | 42%    |
      | churn_rate              | 8%     |
    And cohort analysis should be available
    And drop-off points should be identified

  @monitoring @security
  Scenario: Security events are monitored
    Given the security monitoring is active
    When suspicious activity occurs
    Then alerts should trigger for:
      | security_event           | threshold              | action           |
      | failed_login_attempts    | 5 in 5 min from IP     | block IP         |
      | data_exfiltration        | > 100 sessions/hour    | flag account     |
      | sql_injection_attempt    | any                    | immediate block  |
      | privilege_escalation     | role change detected   | audit + alert    |
    And all security events should be logged immutably
    And quarterly security audits should review logs

  @monitoring @compliance
  Scenario: Compliance metrics are tracked
    Given HIPAA/GDPR compliance is required
    When compliance dashboard is viewed
    Then it should show:
      | compliance_metric           | status | evidence              |
      | data_encryption_at_rest     | ✓      | RDS encryption enabled|
      | data_encryption_in_transit  | ✓      | TLS 1.3 enforced      |
      | access_audit_logs           | ✓      | all access logged     |
      | data_retention_policy       | ✓      | 90-day auto-delete    |
      | user_consent_tracking       | ✓      | consent_records table |
      | right_to_deletion           | ✓      | GDPR delete API       |
    And non-compliance should trigger urgent review
    And annual compliance reports should be generated

  @monitoring @chaos-engineering
  Scenario: System resilience is tested
    Given a chaos experiment is scheduled
    When Reflection Summarizer is killed randomly
    Then the system should:
      | resilience_behavior                    |
      | detect_failure_within_5s               |
      | trigger_retry_with_exponential_backoff |
      | use_fallback_generic_summary           |
      | log_incident_for_postmortem            |
      | auto_restart_failed_service            |
    And user should not see service unavailable
    And chaos experiments should run weekly

  @monitoring @capacity-planning
  Scenario: Growth projections inform scaling
    Given historical data shows 15% monthly growth
    When capacity planning is run
    Then projections should forecast:
      | resource           | current | 3mo_projection | 6mo_projection |
      | database_size      | 500 GB  | 750 GB         | 1.1 TB         |
      | concurrent_users   | 1000    | 1520           | 2310           |
      | api_requests/sec   | 200     | 304            | 462            |
    And scaling recommendations should be generated
    And budget should be forecasted accordingly

  @observability @dashboards
  Scenario: Role-based dashboards are available
    Given different stakeholders need different views
    When they access their dashboards
    Then the views should be:
      | role                | dashboard_focus                      |
      | engineers           | service health, errors, latency      |
      | product_managers    | user engagement, feature adoption    |
      | clinicians          | HITL queue, safety escalations       |
      | executives          | revenue, costs, compliance, uptime   |
    And dashboards should auto-refresh every 30s
    And custom dashboards should be supported

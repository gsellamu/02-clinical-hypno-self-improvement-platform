# DEPLOYMENT INFRASTRUCTURE - Production-Ready Setup
## Docker Compose + Kubernetes + CI/CD + Monitoring

**Version:** 1.0
**Date:** 2026-02-11
**Target:** AWS EKS + RDS + ElastiCache + S3

---

## ARCHITECTURE OVERVIEW

```
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Cloud                                │
└─────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
         ┌────▼────┐     ┌───▼────┐     ┌───▼────┐
         │   EKS   │     │  RDS   │     │  S3 +  │
         │ Cluster │     │ Postgres│     │ MinIO  │
         └────┬────┘     └────────┘     └────────┘
              │
    ┌─────────┼─────────┐
    │                   │
┌───▼───┐          ┌───▼───┐
│ Apps  │          │ Services│
│ Web   │          │ API    │
│ (5173)│          │ (8140) │
└───────┘          │ Orch   │
                   │ (8145) │
                   └────────┘

Monitoring Stack:
- Prometheus (metrics)
- Grafana (dashboards)
- Loki (logs)
- Jaeger (traces)
```

---

## DOCKER COMPOSE - PRODUCTION

```yaml
# docker-compose.prod.yml
version: '3.9'

services:
  # =============================================================================
  # FRONTEND
  # =============================================================================
  
  web:
    build:
      context: ./apps/web
      dockerfile: Dockerfile.prod
    image: jeeth-ai/web:${VERSION:-latest}
    container_name: therapeutic-web
    restart: unless-stopped
    ports:
      - "5173:80"
    environment:
      - NODE_ENV=production
      - VITE_API_BASE_URL=${API_BASE_URL}
      - VITE_ORCHESTRATOR_URL=${ORCHESTRATOR_URL}
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M

  # =============================================================================
  # BACKEND SERVICES
  # =============================================================================
  
  api:
    build:
      context: ./services/api
      dockerfile: Dockerfile.prod
    image: jeeth-ai/api:${VERSION:-latest}
    container_name: therapeutic-api
    restart: unless-stopped
    ports:
      - "8140:8140"
    environment:
      - API_PORT=8140
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - SECRET_KEY=${SECRET_KEY}
      - JWT_SECRET=${JWT_SECRET}
      - CORS_ORIGINS=${CORS_ORIGINS}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - ELEVENLABS_API_KEY=${ELEVENLABS_API_KEY}
      - SENTRY_DSN=${SENTRY_DSN}
      - LOG_LEVEL=info
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8140/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
      replicas: 2

  orchestrator:
    build:
      context: ./services/orchestrator
      dockerfile: Dockerfile.prod
    image: jeeth-ai/orchestrator:${VERSION:-latest}
    container_name: therapeutic-orchestrator
    restart: unless-stopped
    ports:
      - "8145:8145"
    environment:
      - ORCHESTRATOR_PORT=8145
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - SAFETY_GUARDIAN_URL=http://safety-guardian:8005
      - SENTRY_DSN=${SENTRY_DSN}
      - LOG_LEVEL=info
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8145/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
      replicas: 2

  safety-guardian:
    build:
      context: ./services/safety-guardian
      dockerfile: Dockerfile.prod
    image: jeeth-ai/safety-guardian:${VERSION:-latest}
    container_name: therapeutic-safety
    restart: unless-stopped
    ports:
      - "8005:8005"
    environment:
      - SAFETY_PORT=8005
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL}
      - SENTRY_DSN=${SENTRY_DSN}
      - LOG_LEVEL=info
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8005/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
        reservations:
          cpus: '1'
          memory: 1G
      replicas: 3  # High availability for safety-critical service

  # =============================================================================
  # DATABASES
  # =============================================================================
  
  postgres:
    image: pgvector/pgvector:pg16
    container_name: therapeutic-postgres
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=${POSTGRES_USER:-postgres}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB:-therapeutic_journaling}
      - POSTGRES_INITDB_ARGS=--encoding=UTF-8 --lc-collate=C --lc-ctype=C
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./infra/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
      - ./infra/postgres/postgresql.conf:/etc/postgresql/postgresql.conf:ro
    command: postgres -c config_file=/etc/postgresql/postgresql.conf
    networks:
      - app-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres}"]
      interval: 10s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G

  redis:
    image: redis:7-alpine
    container_name: therapeutic-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis-data:/data
      - ./infra/redis/redis.conf:/usr/local/etc/redis/redis.conf:ro
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G

  # =============================================================================
  # OBJECT STORAGE
  # =============================================================================
  
  minio:
    image: minio/minio:latest
    container_name: therapeutic-minio
    restart: unless-stopped
    ports:
      - "9000:9000"
      - "9001:9001"
    environment:
      - MINIO_ROOT_USER=${MINIO_ROOT_USER}
      - MINIO_ROOT_PASSWORD=${MINIO_ROOT_PASSWORD}
    command: server /data --console-address ":9001"
    volumes:
      - minio-data:/data
    networks:
      - app-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G

  # =============================================================================
  # MONITORING & OBSERVABILITY
  # =============================================================================
  
  prometheus:
    image: prom/prometheus:latest
    container_name: therapeutic-prometheus
    restart: unless-stopped
    ports:
      - "9090:9090"
    volumes:
      - ./infra/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus-data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
    networks:
      - app-network
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 1G

  grafana:
    image: grafana/grafana:latest
    container_name: therapeutic-grafana
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_USER=${GRAFANA_USER:-admin}
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
      - GF_INSTALL_PLUGINS=grafana-clock-panel
    volumes:
      - grafana-data:/var/lib/grafana
      - ./infra/grafana/dashboards:/etc/grafana/provisioning/dashboards:ro
      - ./infra/grafana/datasources:/etc/grafana/provisioning/datasources:ro
    networks:
      - app-network
    depends_on:
      - prometheus
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M

  loki:
    image: grafana/loki:latest
    container_name: therapeutic-loki
    restart: unless-stopped
    ports:
      - "3100:3100"
    volumes:
      - ./infra/loki/loki-config.yml:/etc/loki/local-config.yaml:ro
      - loki-data:/loki
    command: -config.file=/etc/loki/local-config.yaml
    networks:
      - app-network
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 2G
        reservations:
          cpus: '0.5'
          memory: 1G

  promtail:
    image: grafana/promtail:latest
    container_name: therapeutic-promtail
    restart: unless-stopped
    volumes:
      - /var/log:/var/log:ro
      - ./infra/promtail/promtail-config.yml:/etc/promtail/config.yml:ro
    command: -config.file=/etc/promtail/config.yml
    networks:
      - app-network
    depends_on:
      - loki

  # =============================================================================
  # LOAD BALANCER
  # =============================================================================
  
  nginx:
    image: nginx:alpine
    container_name: therapeutic-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./infra/nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./infra/nginx/ssl:/etc/nginx/ssl:ro
      - nginx-cache:/var/cache/nginx
    networks:
      - app-network
    depends_on:
      - web
      - api
      - orchestrator
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s
      timeout: 10s
      retries: 3
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M

networks:
  app-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.28.0.0/16

volumes:
  postgres-data:
    driver: local
  redis-data:
    driver: local
  minio-data:
    driver: local
  prometheus-data:
    driver: local
  grafana-data:
    driver: local
  loki-data:
    driver: local
  nginx-cache:
    driver: local
```

---

## KUBERNETES MANIFESTS

### Namespace

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: therapeutic-journaling
  labels:
    name: therapeutic-journaling
    environment: production
```

### ConfigMap

```yaml
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: therapeutic-journaling
data:
  API_PORT: "8140"
  ORCHESTRATOR_PORT: "8145"
  SAFETY_PORT: "8005"
  LOG_LEVEL: "info"
  CORS_ORIGINS: "https://app.jeeth.ai,https://www.jeeth.ai"
  NODE_ENV: "production"
```

### Secrets

```yaml
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: therapeutic-journaling
type: Opaque
stringData:
  DATABASE_URL: "postgresql+asyncpg://user:password@postgres:5432/therapeutic_journaling"
  REDIS_URL: "redis://:password@redis:6379/0"
  SECRET_KEY: "your-secret-key-here"
  JWT_SECRET: "your-jwt-secret-here"
  ANTHROPIC_API_KEY: "sk-ant-..."
  OPENAI_API_KEY: "sk-..."
  ELEVENLABS_API_KEY: "..."
  SENTRY_DSN: "https://..."
  SLACK_WEBHOOK_URL: "https://hooks.slack.com/..."
```

### API Deployment

```yaml
# k8s/deployments/api.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: therapeutic-journaling
  labels:
    app: api
    version: v1.0.0
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
        version: v1.0.0
    spec:
      containers:
      - name: api
        image: jeeth-ai/api:1.0.0
        imagePullPolicy: Always
        ports:
        - containerPort: 8140
          name: http
          protocol: TCP
        env:
        - name: API_PORT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: API_PORT
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: DATABASE_URL
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: REDIS_URL
        - name: ANTHROPIC_API_KEY
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: ANTHROPIC_API_KEY
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8140
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /health
            port: 8140
          initialDelaySeconds: 20
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: api
  namespace: therapeutic-journaling
spec:
  selector:
    app: api
  ports:
  - protocol: TCP
    port: 8140
    targetPort: 8140
  type: ClusterIP
```

### Orchestrator Deployment

```yaml
# k8s/deployments/orchestrator.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: orchestrator
  namespace: therapeutic-journaling
  labels:
    app: orchestrator
    version: v1.0.0
spec:
  replicas: 2
  selector:
    matchLabels:
      app: orchestrator
  template:
    metadata:
      labels:
        app: orchestrator
        version: v1.0.0
    spec:
      containers:
      - name: orchestrator
        image: jeeth-ai/orchestrator:1.0.0
        imagePullPolicy: Always
        ports:
        - containerPort: 8145
          name: http
        env:
        - name: ORCHESTRATOR_PORT
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: ORCHESTRATOR_PORT
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: DATABASE_URL
        - name: ANTHROPIC_API_KEY
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: ANTHROPIC_API_KEY
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8145
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8145
          initialDelaySeconds: 20
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: orchestrator
  namespace: therapeutic-journaling
spec:
  selector:
    app: orchestrator
  ports:
  - protocol: TCP
    port: 8145
    targetPort: 8145
  type: ClusterIP
```

### Horizontal Pod Autoscaler

```yaml
# k8s/hpa/api-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: api-hpa
  namespace: therapeutic-journaling
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: api
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 50
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 15
      - type: Pods
        value: 2
        periodSeconds: 15
      selectPolicy: Max
```

### Ingress

```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: main-ingress
  namespace: therapeutic-journaling
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"
spec:
  tls:
  - hosts:
    - app.jeeth.ai
    - api.jeeth.ai
    secretName: jeeth-ai-tls
  rules:
  - host: app.jeeth.ai
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
  - host: api.jeeth.ai
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 8140
      - path: /orchestrate
        pathType: Prefix
        backend:
          service:
            name: orchestrator
            port:
              number: 8145
```

---

## GITHUB ACTIONS CI/CD

```yaml
# .github/workflows/deploy-production.yml
name: Deploy to Production

on:
  push:
    branches:
      - main
    tags:
      - 'v*.*.*'

env:
  AWS_REGION: us-east-1
  EKS_CLUSTER: therapeutic-journaling-prod
  ECR_REGISTRY: 123456789012.dkr.ecr.us-east-1.amazonaws.com
  
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'pnpm'
      
      - name: Install dependencies
        run: pnpm install --frozen-lockfile
      
      - name: Run linter
        run: pnpm lint
      
      - name: Run tests
        run: pnpm test
      
      - name: Build TypeScript
        run: pnpm build

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          format: 'sarif'
          output: 'trivy-results.sarif'
      
      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

  build-and-push:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    strategy:
      matrix:
        service: [web, api, orchestrator, safety-guardian]
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Extract version
        id: version
        run: |
          if [[ $GITHUB_REF == refs/tags/* ]]; then
            echo "version=${GITHUB_REF#refs/tags/}" >> $GITHUB_OUTPUT
          else
            echo "version=latest" >> $GITHUB_OUTPUT
          fi
      
      - name: Build and push Docker image
        env:
          IMAGE_TAG: ${{ steps.version.outputs.version }}
        run: |
          docker build \
            -t ${{ env.ECR_REGISTRY }}/jeeth-ai-${{ matrix.service }}:$IMAGE_TAG \
            -t ${{ env.ECR_REGISTRY }}/jeeth-ai-${{ matrix.service }}:latest \
            -f ./services/${{ matrix.service }}/Dockerfile.prod \
            .
          docker push ${{ env.ECR_REGISTRY }}/jeeth-ai-${{ matrix.service }}:$IMAGE_TAG
          docker push ${{ env.ECR_REGISTRY }}/jeeth-ai-${{ matrix.service }}:latest

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}
      
      - name: Update kubeconfig
        run: |
          aws eks update-kubeconfig \
            --region ${{ env.AWS_REGION }} \
            --name ${{ env.EKS_CLUSTER }}
      
      - name: Deploy to EKS
        run: |
          kubectl apply -f k8s/namespace.yaml
          kubectl apply -f k8s/configmap.yaml
          kubectl apply -f k8s/secrets.yaml
          kubectl apply -f k8s/deployments/
          kubectl apply -f k8s/services/
          kubectl apply -f k8s/ingress.yaml
          kubectl apply -f k8s/hpa/
      
      - name: Wait for deployment
        run: |
          kubectl rollout status deployment/api -n therapeutic-journaling
          kubectl rollout status deployment/orchestrator -n therapeutic-journaling
          kubectl rollout status deployment/safety-guardian -n therapeutic-journaling
      
      - name: Verify deployment
        run: |
          kubectl get pods -n therapeutic-journaling
          kubectl get svc -n therapeutic-journaling

  smoke-test:
    needs: deploy
    runs-on: ubuntu-latest
    steps:
      - name: Health check API
        run: |
          response=$(curl -f https://api.jeeth.ai/health)
          echo $response | jq -e '.status == "healthy"'
      
      - name: Health check Orchestrator
        run: |
          response=$(curl -f https://api.jeeth.ai/orchestrate/health)
          echo $response | jq -e '.status == "healthy"'
      
      - name: Notify Slack
        if: always()
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK }}
          payload: |
            {
              "text": "Production deployment ${{ job.status }}: ${{ github.ref }}"
            }
```

---

## MONITORING CONFIGURATION

### Prometheus Config

```yaml
# infra/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  external_labels:
    cluster: 'therapeutic-journaling-prod'
    environment: 'production'

scrape_configs:
  - job_name: 'api'
    static_configs:
      - targets: ['api:8140']
    metrics_path: '/metrics'
    
  - job_name: 'orchestrator'
    static_configs:
      - targets: ['orchestrator:8145']
    metrics_path: '/metrics'
    
  - job_name: 'safety-guardian'
    static_configs:
      - targets: ['safety-guardian:8005']
    metrics_path: '/metrics'
    
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres-exporter:9187']
    
  - job_name: 'redis'
    static_configs:
      - targets: ['redis-exporter:9121']
    
  - job_name: 'nginx'
    static_configs:
      - targets: ['nginx-exporter:9113']

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

rule_files:
  - '/etc/prometheus/rules/*.yml'
```

### Alert Rules

```yaml
# infra/prometheus/rules/alerts.yml
groups:
  - name: api_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "{{ $labels.service }} has error rate {{ $value }}"
      
      - alert: HighLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
          description: "95th percentile latency is {{ $value }}s"
      
      - alert: ServiceDown
        expr: up == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "{{ $labels.job }} has been down for 2 minutes"
  
  - name: safety_alerts
    interval: 15s
    rules:
      - alert: CodeRedDetected
        expr: safety_screen_status{status="red"} > 0
        for: 0s
        labels:
          severity: critical
          page: true
        annotations:
          summary: "Code Red safety alert"
          description: "Crisis detected for user {{ $labels.user_id }}"
      
      - alert: HighCodeYellowRate
        expr: rate(safety_screen_status{status="yellow"}[10m]) > 0.3
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High Code Yellow rate"
          description: "30% of screens are Code Yellow in last 10 minutes"
```

---

## DEPLOYMENT SCRIPTS

```bash
# scripts/deploy-prod.sh
#!/bin/bash
set -e

echo "🚀 Deploying Therapeutic Journaling Platform to Production"

# Load environment
source .env.production

# Build Docker images
echo "📦 Building Docker images..."
docker-compose -f docker-compose.prod.yml build

# Push to registry
echo "⬆️  Pushing to ECR..."
docker-compose -f docker-compose.prod.yml push

# Apply Kubernetes manifests
echo "☸️  Deploying to EKS..."
kubectl apply -f k8s/

# Wait for rollout
echo "⏳ Waiting for deployment..."
kubectl rollout status deployment/api -n therapeutic-journaling
kubectl rollout status deployment/orchestrator -n therapeutic-journaling
kubectl rollout status deployment/safety-guardian -n therapeutic-journaling

# Run smoke tests
echo "🧪 Running smoke tests..."
./scripts/smoke-test.sh

echo "✅ Deployment complete!"
```

---

**STATUS:** Deployment Infrastructure Complete ✅

**Includes:**
- Production Docker Compose (12 services)
- Kubernetes manifests (Deployments, Services, HPA, Ingress)
- GitHub Actions CI/CD pipeline
- Prometheus + Grafana monitoring
- Alert rules for safety-critical events
- Automated deployment scripts

**Next:** Testing Strategy + Performance Benchmarks + Security Hardening

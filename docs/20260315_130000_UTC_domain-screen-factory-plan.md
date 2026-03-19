# Domain Screen Factory Plan

Date: 2026-03-15 UTC
Owner: 30-ui-bench
Primary consumer: 37-data-model

## Objective

Translate the 13-domain operating model and the newly added workflow-kernel layers into a generation-ready UI backlog for Project 30.

This plan does not hand-build screens in Project 37. It defines what 30-ui-bench should generate so agents and operators can operate each domain with minimal discovery cost and maximal evidence coverage.

## Backward-Kanban Method

Start from the operator/agent done state, then work backward to the views that must exist.

Done state for a domain screen set:
- An agent can orient in the domain in one screen.
- An operator can inspect current domain state in one screen.
- A verifier can see evidence, gate results, and cross-links without leaving the domain workspace.
- A generator can reproduce the screen set from the layer/domain contract without custom handwork.

Backward chain:
1. Verification and evidence views
2. Operations and queue views
3. Orientation and topology views
4. Navigation and route manifest
5. Generator template mapping

Kanban columns:
- Discover
- Plan
- Do
- Check
- Act

## Domain-Level View Types

Every domain should generate three core views.

1. Orientation View
Purpose: explain what exists in the domain, what layer to start from, and what the current scope looks like.

2. Operations View
Purpose: show the highest-value records agents/operators act on most often.

3. Verification View
Purpose: show evidence, risks, gates, and linked records proving the domain state is trustworthy.

## Required Screen Backlog By Domain

### D01 System Architecture
- `SystemArchitectureOrientationPage`
- `SystemArchitectureOperationsPage`
- `SystemArchitectureVerificationPage`

### D02 Identity & Access
- `IdentityAccessOrientationPage`
- `IdentityAccessOperationsPage`
- `IdentityAccessVerificationPage`

### D03 AI Runtime
- `AiRuntimeOrientationPage`
- `AiRuntimeOperationsPage`
- `AiRuntimeVerificationPage`

### D04 User Interface
- `UiDomainOrientationPage`
- `UiDomainOperationsPage`
- `UiDomainVerificationPage`

### D05 Control Plane
- `ControlPlaneOrientationPage`
- `ControlPlaneOperationsPage`
- `ControlPlaneVerificationPage`

### D06 Governance & Policy
- `GovernanceOrientationPage`
- `GovernanceOperationsPage`
- `GovernanceVerificationPage`

### D07 Project & PM
- `ProjectPmOrientationPage`
- `ProjectPmOperationsPage`
- `ProjectPmVerificationPage`

### D08 DevOps & Delivery
- `DevOpsOrientationPage`
- `DevOpsOperationsPage`
- `DevOpsVerificationPage`

### D09 Observability & Evidence
- `ObservabilityOrientationPage`
- `ObservabilityOperationsPage`
- `ObservabilityVerificationPage`

### D10 Infrastructure & FinOps
- `InfraFinOpsOrientationPage`
- `InfraFinOpsOperationsPage`
- `InfraFinOpsVerificationPage`

### D11 Execution Engine
- `ExecutionEngineOrientationPage`
- `ExecutionEngineOperationsPage`
- `ExecutionEngineVerificationPage`

Additional execution-kernel layer screens:
- `WorkflowDefinitionsListView`
- `WorkflowRunsListView`
- `WorkflowStagesListView`
- `WorkflowTransitionsListView`
- `WorkflowSignalsListView`
- `WorkflowGateResultsListView`
- `WorkflowPreflightsListView`
- `WorkflowRepairRecipesListView`

### D12 Strategy & Portfolio
- `StrategyPortfolioOrientationPage`
- `StrategyPortfolioOperationsPage`
- `StrategyPortfolioVerificationPage`

### D13 Agent Memory & Learning
- `AgentMemoryOrientationPage`
- `AgentMemoryOperationsPage`
- `AgentMemoryVerificationPage`

## Generator Requirements For 30-ui-bench

The generator should accept both layer and domain manifests.

Required inputs:
- `GET /model/domain-views`
- `GET /model/layer-metadata/`
- `GET /model/screens/` for route collision checks

Required outputs:
- domain dashboard pages
- layer list/detail pages for new workflow layers
- route manifest updates
- type definitions and view helpers
- literals namespaces for each generated page

## Execution Priority

P0:
- 8 workflow-kernel layer screens
- 3 execution-engine domain pages
- 3 agent-memory domain pages

P1:
- governance, observability, and project/PM domain pages

P2:
- remaining domain pages and polish passes

## Acceptance Criteria

- Project 30 can generate all workflow-kernel pages without hand edits.
- Project 37 can consume the generated pages with route registration only.
- Each domain has orientation, operations, and verification views.
- Every generated domain page references the domain `start_here` layer and linked verification layers.
- Route and literal generation remain deterministic.
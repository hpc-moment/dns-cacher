# Agent Instructions: Generating Architecture Decision Records (ADR)

This document contains guidelines for Large Language Models (LLMs) and autonomous agents when creating or updating Architecture Decision Records after codebase changes.

## Overview
An Architecture Decision Record (ADR) is a document that captures an important architectural decision made along with its context and consequences. ADRs help teams:
- **Preserve institutional knowledge:** Decisions are documented with full reasoning, not just the outcome.
- **Onboard new team members:** Newcomers can understand why the system is built the way it is.
- **Enable better future decisions:** Past tradeoffs are visible when revisiting choices.
- **Drive accountability:** Decisions are tied to context, date, and stakeholders.

## Instructions for Agents

When prompted to generate an ADR based on recent codebase changes (e.g., modifying network topology, adding a new service, altering database schemas), adhere to the following workflow:

### 1. Define Clear Goals
Analyze the task files, `README.md`, logs, and relevant configurations (like `Dockerfile`, `docker-compose.yml`, or `unbound.conf`). Understand the _intent_ behind the code before drafting. Ensure you distinguish between "routine bug fixes" (which do not need an ADR) and "architectural decisions" (which do).

### 2. Follow the Template
Always use the standard repository template located at `docs/architecture-decision-records/template.md`. Name your files logically in `docs/architecture-decision-records/decisions/` formatted as `ADR-XXX-kebab-cased-title.md`.

### 3. Capture the Why, Not Just the What
Your main focus should be the **Rationale** and **Alternatives Considered** sections. Describe *why* the technical path was chosen (e.g., removing hardware targets from systemd for cross-Linux portability), balancing trade-offs, security, and performance.

### 4. Update the Index
Whenever you create a new ADR, you must immediately update `docs/architecture-decision-records/adr_index.md` by appending a link to the new file, along with its Title, Status, and Date.

### 5. Best Practices & Responsible Adoption
As an agentic AI automating ADR tasks, adhere to these oversight guidelines:
- **Keep a Change Log / Reasoning Trail:** If you supersede an older ADR or create a new one, consider logging the PR ID, task context, or code excerpts in the Context section to provide an audit trail for human architects.
- **Iterate the Knowledge Base:** When an ADR becomes obsolete, mark its status as `Superseded` or `Deprecated`. Do **not** delete old ADRs, as they provide historical context.
- **Privacy and Security:** Do not inject sensitive runtime secrets (e.g., real API keys, passwords from test logs) into ADR documents.
- **Collaboration First:** Treat your ADR as a "Draft" or "Proposed" unless the instruction actively states the decision is final/accepted. Note that human review is essential: LLMs can generate relevant ADR language but architects must verify the nuances. 

### Conclusion
By blending automated record-keeping with human collaboration via code reviews, you ensure the repository remains a live, traceable knowledge graph. When generating an ADR, you are augmenting human discourse, not replacing it.

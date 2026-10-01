# Aegis-DevOps demo: block a database delete in a pull request

This repository is a two-minute demo of
[Aegis-DevOps](https://github.com/moneytool/aegis-devops), an open-source guardrail that stops AI
agents and automation from running destructive infrastructure changes. Here it runs as the
[Aegis-DevOps Plan Check](https://github.com/marketplace/actions/aegis-devops-plan-check) GitHub
Action: every pull request gets a `terraform plan`, and the plan is checked against signed policy
before anyone can merge it.

`infra/` is a tiny "production" stack: a Postgres `aws_db_instance` and an S3 bucket. **Nothing
here touches AWS.** The provider has fake credentials, the plan runs with `-refresh=false` against
the committed `terraform.tfstate`, and no workflow ever applies. No cloud account is needed.

## Try it

1. **Fork** this repository, open the fork's **Actions** tab and enable workflows.
2. In your fork, edit `infra/main.tf` and **delete the `aws_db_instance "orders"` block**.
3. Open a pull request **within your fork** (base: your fork's `main`).

The `plan-check` workflow plans the change, and Aegis blocks it:

> ## ⛔ Aegis-DevOps plan check: BLOCK
> Plan `tfplan`: 2 resource change(s).
> Decided by: `plan-no-db-deletes`
> - max_matching: 1 delete/replace > 0

The check fails, so a branch rule requiring it keeps the PR from being merged. Change something
harmless instead, such as adding another `aws_s3_bucket`, and the same check passes.

## How it works

- `.aegis/` is the policy, as written by `aegis init`: Aegis's example rules, signed with its
  public **example key**. Real deployments generate their own key (`aegis keygen`) and sign
  their own rules; see [Configuration](https://moneytool.github.io/aegis-devops/configuration.html).
- The rule that fires, `plan-no-db-deletes`, lives in `.aegis/plan_constraints.example.yaml`. Like
  every Aegis rule, it only counts because its signature verifies and its author (`admin`) is
  allowed to write `deletion` rules (`.aegis/authority.example.yaml`). A rule pasted into a
  ticket, or edited without re-signing, gets no vote.
- `.github/workflows/plan-check.yml` is the whole integration: `terraform plan`, then
  `uses: moneytool/aegis-devops-action@v1`.

## Use it with your coding agent too

The same policy can gate an AI coding agent before it runs a command, for example
`kubectl delete` or `terraform destroy` typed by Claude Code, Copilot, Cursor, Codex, Gemini CLI or
OpenCode:

```bash
pip install aegis-devops && aegis init .aegis
claude plugin marketplace add moneytool/aegis-devops
claude plugin install aegis-devops@aegis-devops
```

See [Coding agents](https://moneytool.github.io/aegis-devops/agents.html) for the others.

Apache-2.0. The `infra/` resources, account ids and ARNs are fictional.

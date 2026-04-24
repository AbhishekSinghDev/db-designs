# Challenge #2 — Multi-Tenant SaaS
## Design a schema for a team-based SaaS app (think Notion, Linear, Slack):

- Users can create workspaces
- A user can be part of multiple workspaces
- Each workspace has members with roles: owner, admin, member
- Each workspace can have multiple projects
- Projects have tasks, tasks can be assigned to a workspace member
- Tasks have: title, description, priority (low, medium, high, urgent), status (todo, in_progress, in_review, done)
- A task can have sub-tasks (same structure, but child of a task)
- Track who created each task and when
- A workspace can only have one owner at a time

CREATE TYPE workspace_member_role AS ENUM (
    'owner',
    'admin',
    'member'
);

CREATE TYPE task_priority AS ENUM (
    'low',
    'medium',
    'high',
    'urgent'
);

CREATE TYPE task_status AS ENUM (
    'todo',
    'in_progress',
    'in_review',
    'done'
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    name VARCHAR(50) NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW() ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE workspaces (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    title VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW() ON UPDATE CURRENT_TIMESTAMP,
);

CREATE TABLE workspace_members (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    role workspace_member_role NOT NULL DEFAULT ('member'),
    user_id UUID NOT NULL,
    workspace_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW() ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT unique_workspace_member UNIQUE (workspace_id, user_id)
    CONSTRAINT fk_workspace_member_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_workspace_member_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces(id) ON DELETE CASCADE
);

CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    title TEXT NOT NULL,
    workspace_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW() ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_project_workspace FOREIGN KEY (workspace_id) REFERENCES workspaces(id) ON DELETE CASCADE
);

CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT uuidv7(),
    title TEXT NOT NULL,
    description TEXT,
    priority task_priority NOT NULL,
    status task_status NOT NULL,
    project_id UUID NOT NULL,
    created_by_member_id UUID NOT NULL,
    assigned_member_id UUID,
    task_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW() ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_task_project FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    CONSTRAINT fk_task_created_member FOREIGN KEY (created_by_member_id) REFERENCES workspace_members(id),
    CONSTRAINT fk_task_member FOREIGN KEY (assigned_member_id) REFERENCES workspace_members(id) ON DELETE SET NULL,
    CONSTRAINT fk_task_self_relation FOREIGN KEY (task_id) REFERENCES tasks(task_id) ON DELETE CASCADE
);

-- FK joins
CREATE INDEX ON workspace_members (user_id);
CREATE INDEX ON workspace_members (workspace_id);
CREATE INDEX ON projects (workspace_id);
CREATE INDEX ON tasks (project_id);
CREATE INDEX ON tasks (assigned_member_id);
CREATE INDEX ON tasks (created_by_member_id);
CREATE INDEX ON tasks (task_id); -- parent task lookup

-- filtering
CREATE INDEX ON tasks (status);
CREATE INDEX ON tasks (priority);

-- constraint
CREATE UNIQUE INDEX one_owner_per_workspace
ON workspace_members (workspace_id) WHERE role = 'owner';

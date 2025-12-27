# Task Manager Backend API

## 📋 Table of Contents

- [Features](#features)
- [Setup Instructions](#setup-instructions)
- [API Documentation](#api-documentation)
- [Database Schema](#database-schema)
- [Architecture Decisions](#architecture-decisions)
- [Testing](#testing)
- [What I'd Improve](#what-id-improve)

---


## ✨ Features

### 1. Intelligent Task Classification
- **Category Detection**: Automatically categorizes tasks based on keywords
  - Scheduling: meetings, appointments, calls
  - Finance: payments, invoices, budgets
  - Technical: bugs, fixes, installations
  - Safety: inspections, hazards, compliance
  - General: default fallback

- **Priority Detection**: Identifies urgency from text
  - High: urgent, asap, immediately, critical
  - Medium: soon, this week, important
  - Low: default for normal tasks

### 2. Entity Extraction
- **Dates**: Multiple formats (12/25/2024, tomorrow, Friday, 3:30pm)
- **People**: Names with context (with John, assign to Sarah)
- **Locations**: Places mentioned (at Building A, in Office)
- **Action Verbs**: Key actions (schedule, review, fix, submit)

### 3. Smart Suggestions
- Context-aware action suggestions based on task category
- Example: Scheduling tasks suggest "Block calendar", "Send invite"

### 4. Complete History Tracking
- Tracks all task changes (created, updated, deleted, status_changed)
- Stores old and new values for audit trails
- Queryable by task, action type, or time range

### 5. Robust Validation
- Request body, query parameters, and URL parameters validated
- Detailed error messages with field-level feedback
- Type coercion and sanitization
- UUID validation for IDs


---

## 🚀 Setup Instructions

### Prerequisites
- Node.js 18 or higher
- pnpm (or npm/yarn)
- PostgreSQL database (or Supabase account)

### 1. Clone and Install

```bash
# Navigate to backend directory
cd backend

# Install dependencies
pnpm install
# or
npm install
```

### 3. Run the Server

```bash
# Development mode (with hot reload)
pnpm dev
# or
npm run dev

# Production build
pnpm build
pnpm start
```

The server will start on `http://localhost:3000`

### 4. Verify Installation

```bash
# Check health endpoint
curl http://localhost:3000/health
# Should return: "Hello from server"

# Check database connection
# Look for console output: "✓ Database connected"
```

---

## 📚 API Documentation

### Task Endpoints

#### 1. Preview Task Classification
**POST** `/task/preview`

Preview how a task will be classified without saving it.

**Request:**
```json
{
  "description": "Schedule urgent meeting with John tomorrow at 2pm"
}
```

**Response:**
```json
{
  "title": "Block calendar",
  "description": "Schedule urgent meeting with John tomorrow at 2pm",
  "category": "scheduling",
  "priority": "high",
  "assigned_to": null,
  "due_date": "2024-12-28T00:00:00.000Z",
  "extracted_entities": {
    "dates": ["tomorrow", "at 2pm"],
    "people": ["John"],
    "locations": [],
    "action_verbs": ["schedule", "meet"]
  },
  "suggested_actions": [
    "Block calendar",
    "Send invite",
    "Prepare agenda",
    "Set reminder"
  ]
}
```

#### 2. Create Task
**POST** `/task`

Create a new task with classification data.

**Request:**
```json
{
  "title": "Team Meeting",
  "description": "Schedule urgent meeting with John tomorrow at 2pm",
  "category": "scheduling",
  "priority": "high",
  "assigned_to": "John",
  "due_date": "2024-12-28T14:00:00.000Z",
  "extracted_entities": {
    "dates": ["tomorrow", "at 2pm"],
    "people": ["John"]
  },
  "suggested_actions": ["Block calendar", "Send invite"]
}
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Team Meeting",
  "description": "Schedule urgent meeting with John tomorrow at 2pm",
  "category": "scheduling",
  "priority": "high",
  "status": "pending",
  "assigned_to": "John",
  "due_date": "2024-12-28T14:00:00.000Z",
  "extracted_entities": {...},
  "suggested_actions": [...],
  "created_at": "2024-12-27T10:30:00.000Z",
  "updated_at": "2024-12-27T10:30:00.000Z"
}
```

**Validation Rules:**
- `title`: Required, 1-200 characters
- `description`: Required, 1-5000 characters
- `category`: Optional, one of: work, personal, shopping, health, finance, general
- `priority`: Optional, one of: low, medium, high, urgent
- `assigned_to`: Optional, max 100 characters
- `due_date`: Optional, ISO date format


#### 3. Get All Tasks
**GET** `/task?category=work&status=pending&priority=high&limit=10&page=1`

Retrieve tasks with optional filtering and pagination.

**Query Parameters:**
- `category`: Filter by category (work, personal, shopping, health, finance, general)
- `status`: Filter by status (pending, in_progress, completed, cancelled)
- `priority`: Filter by priority (low, medium, high, urgent)
- `limit`: Results per page (1-100, default: 10)
- `offset`: Skip N results (default: 0)
- `page`: Page number (overrides offset)

**Response:**
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "title": "Team Meeting",
      "description": "Schedule urgent meeting...",
      "category": "scheduling",
      "priority": "high",
      "status": "pending",
      "assigned_to": "John",
      "due_date": "2024-12-28T14:00:00.000Z",
      "created_at": "2024-12-27T10:30:00.000Z",
      "updated_at": "2024-12-27T10:30:00.000Z"
    }
  ],
  "pagination": {
    "total": 45,
    "page": 1,
    "limit": 10,
    "totalPages": 5,
    "hasNextPage": true,
    "hasPrevPage": false
  }
}
```

#### 4. Get Task by ID
**GET** `/task/:id`

Retrieve a specific task by UUID.

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Team Meeting",
  "description": "Schedule urgent meeting...",
  "category": "scheduling",
  "priority": "high",
  "status": "pending",
  "assigned_to": "John",
  "due_date": "2024-12-28T14:00:00.000Z",
  "extracted_entities": {...},
  "suggested_actions": [...],
  "created_at": "2024-12-27T10:30:00.000Z",
  "updated_at": "2024-12-27T10:30:00.000Z"
}
```

**Error Response (404):**
```json
{
  "error": "Task not found"
}
```


#### 5. Update Task
**PUT** `/task/:id`

Update an existing task. At least one field must be provided.

**Request:**
```json
{
  "status": "completed",
  "priority": "medium"
}
```

**Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Team Meeting",
  "status": "completed",
  "priority": "medium",
  "updated_at": "2024-12-27T15:45:00.000Z",
  ...
}
```

**Validation Rules:**
- At least one field required
- `title`: 1-200 characters
- `description`: 1-5000 characters
- `category`: work, personal, shopping, health, finance, general
- `priority`: low, medium, high, urgent
- `status`: pending, in_progress, completed, cancelled

**Note:** If description is updated without title, the system will re-classify the task automatically.

#### 6. Delete Task
**DELETE** `/task/:id`

Delete a task permanently. History entry is created before deletion.

**Response:** `204 No Content`

**Error Response (404):**
```json
{
  "error": "Task not found"
}
```

#### 7. Get Task History
**GET** `/task/:id/history`

Retrieve complete change history for a specific task.

**Response:**
```json
[
  {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "task_id": "550e8400-e29b-41d4-a716-446655440000",
    "action": "status_changed",
    "old_value": {
      "status": "pending"
    },
    "new_value": {
      "status": "completed"
    },
    "changed_by": null,
    "changed_at": "2024-12-27T15:45:00.000Z"
  },
  {
    "id": "660e8400-e29b-41d4-a716-446655440002",
    "task_id": "550e8400-e29b-41d4-a716-446655440000",
    "action": "created",
    "old_value": null,
    "new_value": {
      "title": "Team Meeting",
      "description": "Schedule urgent meeting...",
      "category": "scheduling",
      "priority": "high",
      "status": "pending"
    },
    "changed_by": null,
    "changed_at": "2024-12-27T10:30:00.000Z"
  }
]
```


### History Endpoints

#### 1. Get Task History
**GET** `/history/task/:taskId`

Get all history entries for a specific task.

**Response:** Same as `/task/:id/history`

#### 2. Get Recent History
**GET** `/history/recent?limit=50`

Get recent history across all tasks.

**Query Parameters:**
- `limit`: Number of entries (1-200, default: 50)

**Response:**
```json
[
  {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "task_id": "550e8400-e29b-41d4-a716-446655440000",
    "action": "status_changed",
    "old_value": {"status": "pending"},
    "new_value": {"status": "completed"},
    "changed_at": "2024-12-27T15:45:00.000Z"
  },
  ...
]
```

#### 3. Get History by Action
**GET** `/history/action/:action?limit=50`

Get history filtered by action type.

**Action Types:**
- `created` - Task creation
- `updated` - General updates
- `status_changed` - Status modifications
- `deleted` - Task deletion

**Query Parameters:**
- `limit`: Number of entries (1-200, default: 50)

**Response:** Array of history entries

### Error Responses

#### Validation Error (400)
```json
{
  "error": "Validation failed",
  "details": [
    {
      "field": "title",
      "message": "Task title is required"
    },
    {
      "field": "priority",
      "message": "Priority must be one of: low, medium, high, urgent"
    }
  ]
}
```

#### Not Found (404)
```json
{
  "error": "Task not found"
}
```

#### Server Error (500)
```json
{
  "error": "Failed to create task"
}
```


---

## 🗄 Database Schema

### Entity Relationship Diagram

```
┌─────────────────────────────────────────┐
│              TASKS                      │
├─────────────────────────────────────────┤
│ id                UUID (PK)             │
│ title             VARCHAR(200)          │
│ description       TEXT                  │
│ category          VARCHAR(50)           │
│ priority          VARCHAR(20)           │
│ status            VARCHAR(20)           │
│ assigned_to       VARCHAR(100)          │
│ due_date          TIMESTAMP             │
│ extracted_entities JSONB                │
│ suggested_actions  JSONB                │
│ created_at        TIMESTAMP             │
│ updated_at        TIMESTAMP             │
└─────────────────────────────────────────┘
                    │
                    │ 1:N
                    │
                    ▼
┌─────────────────────────────────────────┐
│          TASK_HISTORY                   │
├─────────────────────────────────────────┤
│ id                UUID (PK)             │
│ task_id           UUID (FK)             │
│ action            VARCHAR(50)           │
│ old_value         JSONB                 │
│ new_value         JSONB                 │
│ changed_by        VARCHAR(100)          │
│ changed_at        TIMESTAMP             │
└─────────────────────────────────────────┘
```


---

## 🏗 Architecture Decisions

### 1. Modular Architecture
**Decision:** Organized code into feature modules (tasks, history) with clear separation of concerns.

**Why:**
- **Scalability**: Easy to add new modules (users, teams, notifications)
- **Maintainability**: Changes to one module don't affect others
- **Testability**: Each module can be tested independently
- **Team Collaboration**: Multiple developers can work on different modules

**Structure:**
```
src/
├── config/          # Database and app configuration
├── middleware/      # Reusable middleware (validation)
├── modules/
│   ├── tasks/       # Task feature (routes, controller, service, validation)
│   └── history/     # History feature
└── utils/           # Shared utilities (classification)
```

### 2. Service Layer Pattern
**Decision:** Separated business logic (service) from HTTP handling (controller).

**Why:**
- **Reusability**: Services can be called from controllers, CLI tools, or background jobs
- **Testing**: Business logic can be tested without HTTP mocking
- **Single Responsibility**: Controllers handle HTTP, services handle business logic
- **Database Abstraction**: Services encapsulate all database operations

**Example:**
```typescript
// Controller handles HTTP
class TaskController {
  static async create(req, res) {
    const result = await TaskService.createTask(data);
    return res.json(result);
  }
}

// Service handles business logic
class TaskService {
  static async createTask(data) {
    const task = await sql`INSERT...`;
    await HistoryService.addEntry(...);
    return task;
  }
}
```


### 3. Joi for Validation
**Decision:** Used Joi instead of class-validator or Zod.

**Why:**
- **Mature & Battle-Tested**: Used by millions of projects
- **Rich Validation Rules**: Extensive built-in validators
- **Custom Error Messages**: Easy to customize user-facing messages
- **Schema Composition**: Reusable validation schemas
- **Express Integration**: Simple middleware pattern

**Benefits:**
- Catches invalid data before it reaches business logic
- Provides clear error messages to API consumers
- Reduces controller code complexity
- Ensures database receives clean data

### 4. Classification Logic in Utils
**Decision:** Implemented AI-like classification as pure functions in utils.

**Why:**
- **No External Dependencies**: No API calls or ML models needed
- **Fast**: Instant classification without network latency
- **Predictable**: Deterministic results for testing
- **Cost-Effective**: No API costs or rate limits
- **Privacy**: Task data never leaves the server

**Trade-offs:**
- Less sophisticated than GPT/Claude
- Keyword-based rather than semantic understanding
- Requires manual keyword maintenance

**Future:** Could be replaced with actual AI API while keeping the same interface.


### 5. Path Aliases (@/)
**Decision:** Used TypeScript path aliases for imports.

**Why:**
- **Cleaner Imports**: `@/config/db` vs `../../../config/db`
- **Refactoring**: Moving files doesn't break imports
- **Readability**: Clear distinction between local and external imports

**Configuration:**
```json
// tsconfig.json
{
  "baseUrl": ".",
  "paths": {
    "@/*": ["src/*"]
  }
}
```

---

## 🚀 What I'd Improve

### Given More Time

#### 1. Authentication & Authorization
**Current State:** No authentication
**Improvement:**
- JWT-based authentication
- Role-based access control (admin, user, viewer)
- User-specific task filtering
- Track who made changes in history

**Implementation:**
```typescript
// Middleware
const authenticate = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  const user = verifyJWT(token);
  req.user = user;
  next();
};

// Usage
router.post('/task', authenticate, authorize('user'), createTask);
```

#### 2. Real AI Integration
**Current State:** Keyword-based classification
**Improvement:**
- OpenAI GPT-4 or Claude API integration
- Semantic understanding of tasks
- Better entity extraction
- Natural language due date parsing
- Sentiment analysis for priority

**Benefits:**
- More accurate classification
- Handle complex/ambiguous descriptions
- Multi-language support
- Context-aware suggestions

#### 3. Advanced Search & Filtering
**Current State:** Basic category/status/priority filters
**Improvement:**
- Full-text search on title/description
- Date range filtering (created, due date)
- Search by assigned person
- Saved search filters
- Search history

**Implementation:**
```sql
-- PostgreSQL full-text search
CREATE INDEX idx_tasks_search ON tasks 
USING GIN(to_tsvector('english', title || ' ' || description));

SELECT * FROM tasks 
WHERE to_tsvector('english', title || ' ' || description) 
@@ to_tsquery('meeting & urgent');
```

#### 4. Comprehensive Testing
**Current State:** 16 unit tests for classification
**Improvement:**
- Integration tests for all API endpoints
- Database transaction tests
- Validation middleware tests
- Error handling tests
- Load testing with k6 or Artillery
- E2E tests with Supertest

**Coverage Goals:**
- 90%+ code coverage
- All happy paths tested
- All error paths tested
- Edge cases covered


#### 5. Caching Layer
**Current State:** Direct database queries
**Improvement:**
- Redis caching for frequently accessed tasks
- Cache invalidation on updates
- Query result caching
- Session storage

**Benefits:**
- Reduced database load
- Faster response times
- Better scalability

**Implementation:**
```typescript
// Cache frequently accessed tasks
const getCachedTask = async (id: string) => {
  const cached = await redis.get(`task:${id}`);
  if (cached) return JSON.parse(cached);
  
  const task = await TaskService.getTaskById(id);
  await redis.setex(`task:${id}`, 3600, JSON.stringify(task));
  return task;
};
```
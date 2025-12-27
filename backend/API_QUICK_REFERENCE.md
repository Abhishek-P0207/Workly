# API Quick Reference

Quick reference for all API endpoints.

## Base URL
```
http://localhost:3000/api
```

## Task Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/task/preview` | Preview task classification |
| POST | `/task` | Create new task |
| GET | `/task` | Get all tasks (with filters) |
| GET | `/task/:id` | Get task by ID |
| PUT | `/task/:id` | Update task |
| DELETE | `/task/:id` | Delete task |
| GET | `/task/:id/history` | Get task history |

## History Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/history/task/:taskId` | Get task history |
| GET | `/history/recent?limit=50` | Get recent history |
| GET | `/history/action/:action?limit=50` | Get history by action type |

## Common Query Parameters

### GET /task
- `category`: work, personal, shopping, health, finance, general
- `status`: pending, in_progress, completed, cancelled
- `priority`: low, medium, high, urgent
- `limit`: 1-100 (default: 10)
- `offset`: >= 0 (default: 0)
- `page`: >= 1 (overrides offset)

## Request Examples

### Preview Task
```bash
curl -X POST http://localhost:3000/api/task/preview \
  -H "Content-Type: application/json" \
  -d '{"description": "Schedule urgent meeting tomorrow at 2pm"}'
```

### Create Task
```bash
curl -X POST http://localhost:3000/api/task \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Team Meeting",
    "description": "Schedule urgent meeting tomorrow",
    "category": "scheduling",
    "priority": "high"
  }'
```

### Get All Tasks
```bash
curl "http://localhost:3000/api/task?status=pending&limit=10&page=1"
```

### Update Task
```bash
curl -X PUT http://localhost:3000/api/task/550e8400-e29b-41d4-a716-446655440000 \
  -H "Content-Type: application/json" \
  -d '{"status": "completed"}'
```

### Delete Task
```bash
curl -X DELETE http://localhost:3000/api/task/550e8400-e29b-41d4-a716-446655440000
```

## Response Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 204 | No Content (successful deletion) |
| 400 | Validation Error |
| 404 | Not Found |
| 500 | Server Error |

## Classification Categories

- **scheduling**: meetings, appointments, calls, deadlines
- **finance**: payments, invoices, bills, budgets
- **technical**: bugs, fixes, installations, repairs
- **safety**: inspections, hazards, compliance
- **general**: default fallback

## Priority Levels

- **high**: urgent, asap, immediately, critical, emergency
- **medium**: soon, this week, important
- **low**: default for normal tasks

## Status Values

- **pending**: Not started
- **in_progress**: Currently being worked on
- **completed**: Finished
- **cancelled**: Cancelled/abandoned

## History Actions

- **created**: Task was created
- **updated**: Task was modified
- **status_changed**: Status was changed
- **deleted**: Task was deleted

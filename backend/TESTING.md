# Testing Guide

This document describes the testing setup and how to run tests for the backend.

## Test Framework

- **Jest**: JavaScript testing framework
- **ts-jest**: TypeScript preprocessor for Jest
- **@types/jest**: TypeScript definitions for Jest

## Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode (re-runs on file changes)
npm run test:watch

# Run tests with coverage report
npm run test:coverage
```

## Test Structure

Tests are located in `__tests__` directories next to the code they test:

```
src/
  utils/
    classification/
      __tests__/
        classification.test.ts
      index.ts
      detectors.ts
      extractors.ts
```

## Classification Logic Tests

The classification tests verify the AI-powered task classification system that automatically categorizes tasks, detects priority, and extracts entities.

### Test Coverage

#### 1. Category Detection (3 tests)
Tests that verify tasks are correctly classified into categories:
- **Scheduling**: Meetings, appointments, calls, deadlines
- **Finance**: Payments, invoices, bills, budgets
- **Technical**: Bugs, fixes, installations, repairs
- **Safety**: Inspections, hazards, compliance
- **General**: Default category for unmatched tasks

**Example:**
```typescript
test('should classify scheduling tasks correctly', () => {
    const result = classifyTask('Schedule a meeting with the team tomorrow at 2pm');
    expect(result.category).toBe('scheduling');
});
```

#### 2. Priority Detection (3 tests)
Tests that verify priority levels are correctly assigned:
- **High**: urgent, asap, immediately, critical, emergency
- **Medium**: soon, this week, important
- **Low**: Default for normal tasks

**Example:**
```typescript
test('should detect high priority tasks', () => {
    const result = classifyTask('URGENT: Fix server crash immediately');
    expect(result.priority).toBe('high');
});
```

#### 3. Entity Extraction (4 tests)
Tests that verify extraction of key information:
- **Dates**: Various formats (12/25/2024, tomorrow, 3:30pm, Friday)
- **People**: Names mentioned with keywords (with, by, assign to, for)
- **Locations**: Places mentioned with keywords (at, in)
- **Action Verbs**: Key action words (schedule, call, review, fix, etc.)

**Example:**
```typescript
test('should extract dates in various formats', () => {
    const result = classifyTask('Meeting on 12/25/2024 at 3:30pm and follow-up tomorrow');
    expect(result.extracted_entities.dates).toContain('12/25/2024');
    expect(result.extracted_entities.dates).toContain('tomorrow');
});
```

#### 4. Complex Scenarios (3 tests)
Tests that verify the system handles:
- Multiple category keywords (prioritizes first match)
- Tasks with no special keywords (defaults to general/low)
- Complex descriptions with multiple entities

**Example:**
```typescript
test('should handle multi-category keywords with priority', () => {
    const result = classifyTask('URGENT: Schedule payment for invoice #1234 today');
    expect(result.category).toBe('scheduling');
    expect(result.priority).toBe('high');
});
```

#### 5. Edge Cases (3 tests)
Tests that verify robustness:
- Empty or minimal text
- Case-insensitive matching (URGENT vs urgent vs Urgent)
- Extra whitespace handling

**Example:**
```typescript
test('should handle case-insensitive matching', () => {
    const upperCase = classifyTask('URGENT MEETING SCHEDULE');
    const lowerCase = classifyTask('urgent meeting schedule');
    
    expect(upperCase.category).toBe('scheduling');
    expect(lowerCase.category).toBe('scheduling');
});
```

## Test Results

All 16 tests pass successfully:
- ✓ Category Detection: 3/3 passing
- ✓ Priority Detection: 3/3 passing
- ✓ Entity Extraction: 4/4 passing
- ✓ Complex Scenarios: 3/3 passing
- ✓ Edge Cases: 3/3 passing

## Adding New Tests

To add new tests:

1. Create a test file in the `__tests__` directory:
```typescript
// src/module/__tests__/feature.test.ts
import { functionToTest } from '../feature';

describe('Feature Name', () => {
    test('should do something', () => {
        const result = functionToTest('input');
        expect(result).toBe('expected');
    });
});
```

2. Run tests to verify:
```bash
npm test
```

## Best Practices

1. **Test Naming**: Use descriptive names that explain what is being tested
2. **Arrange-Act-Assert**: Structure tests with clear setup, execution, and verification
3. **One Assertion Per Concept**: Each test should verify one specific behavior
4. **Edge Cases**: Always test boundary conditions and error cases
5. **Isolation**: Tests should not depend on each other or external state

## Coverage Goals

Aim for:
- **Statements**: > 80%
- **Branches**: > 75%
- **Functions**: > 80%
- **Lines**: > 80%

Run `npm run test:coverage` to see current coverage metrics.

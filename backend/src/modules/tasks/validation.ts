import Joi from 'joi';

// Valid enum values
const CATEGORIES = ['scheduling', 'technical', 'safety', 'finance', 'general'];
const PRIORITIES = ['low', 'medium', 'high'];
const STATUSES = ['pending', 'in_progress', 'completed'];

// Preview task schema
export const previewTaskSchema = Joi.object({
    description: Joi.string()
        .min(1)
        .max(5000)
        .required()
        .messages({
            'string.empty': 'Task description cannot be empty',
            'string.min': 'Task description must be at least 1 character',
            'string.max': 'Task description cannot exceed 5000 characters',
            'any.required': 'Task description is required',
        }),
});

// Create task schema
export const createTaskSchema = Joi.object({
    title: Joi.string()
        .min(1)
        .max(50)
        .required()
        .messages({
            'string.empty': 'Task title cannot be empty',
            'string.min': 'Task title must be at least 1 character',
            'string.max': 'Task title cannot exceed 50 characters',
            'any.required': 'Task title is required',
        }),
    description: Joi.string()
        .min(10)
        .max(500)
        .required()
        .messages({
            'string.empty': 'Task description cannot be empty',
            'string.min': 'Task description must be at least 10 character',
            'string.max': 'Task description cannot exceed 500 characters',
            'any.required': 'Task description is required',
        }),
    category: Joi.string()
        .valid(...CATEGORIES)
        .default('general')
        .messages({
            'any.only': `Category must be one of: ${CATEGORIES.join(', ')}`,
        }),
    priority: Joi.string()
        .valid(...PRIORITIES)
        .default('low')
        .messages({
            'any.only': `Priority must be one of: ${PRIORITIES.join(', ')}`,
        }),
    assigned_to: Joi.string()
        .max(100)
        .allow(null, '')
        .optional()
        .messages({
            'string.max': 'Assigned to cannot exceed 100 characters',
        }),
    due_date: Joi.date()
        .iso()
        .allow(null, '')
        .optional()
        .messages({
            'date.format': 'Due date must be a valid ISO date',
        }),
    extracted_entities: Joi.object().optional(),
    suggested_actions: Joi.array().optional(),
});

// Update task schema (all fields optional)
export const updateTaskSchema = Joi.object({
    title: Joi.string()
        .min(1)
        .max(200)
        .optional()
        .messages({
            'string.empty': 'Task title cannot be empty',
            'string.min': 'Task title must be at least 1 character',
            'string.max': 'Task title cannot exceed 200 characters',
        }),
    description: Joi.string()
        .min(1)
        .max(5000)
        .optional()
        .messages({
            'string.empty': 'Task description cannot be empty',
            'string.min': 'Task description must be at least 1 character',
            'string.max': 'Task description cannot exceed 5000 characters',
        }),
    category: Joi.string()
        .valid(...CATEGORIES)
        .optional()
        .messages({
            'any.only': `Category must be one of: ${CATEGORIES.join(', ')}`,
        }),
    priority: Joi.string()
        .valid(...PRIORITIES)
        .optional()
        .messages({
            'any.only': `Priority must be one of: ${PRIORITIES.join(', ')}`,
        }),
    status: Joi.string()
        .valid(...STATUSES)
        .optional()
        .messages({
            'any.only': `Status must be one of: ${STATUSES.join(', ')}`,
        }),
    assigned_to: Joi.string()
        .max(100)
        .allow(null, '')
        .optional()
        .messages({
            'string.max': 'Assigned to cannot exceed 100 characters',
        }),
    due_date: Joi.date()
        .iso()
        .allow(null, '')
        .optional()
        .messages({
            'date.format': 'Due date must be a valid ISO date',
        }),
}).min(1).messages({
    'object.min': 'At least one field must be provided for update',
});

// Query parameters for getting all tasks
export const getAllTasksQuerySchema = Joi.object({
    category: Joi.string()
        .valid(...CATEGORIES)
        .optional()
        .messages({
            'any.only': `Category must be one of: ${CATEGORIES.join(', ')}`,
        }),
    status: Joi.string()
        .valid(...STATUSES)
        .optional()
        .messages({
            'any.only': `Status must be one of: ${STATUSES.join(', ')}`,
        }),
    priority: Joi.string()
        .valid(...PRIORITIES)
        .optional()
        .messages({
            'any.only': `Priority must be one of: ${PRIORITIES.join(', ')}`,
        }),
    limit: Joi.number()
        .integer()
        .min(1)
        .max(100)
        .default(10)
        .optional()
        .messages({
            'number.base': 'Limit must be a number',
            'number.integer': 'Limit must be an integer',
            'number.min': 'Limit must be at least 1',
            'number.max': 'Limit cannot exceed 100',
        }),
    offset: Joi.number()
        .integer()
        .min(0)
        .default(0)
        .optional()
        .messages({
            'number.base': 'Offset must be a number',
            'number.integer': 'Offset must be an integer',
            'number.min': 'Offset must be at least 0',
        }),
    page: Joi.number()
        .integer()
        .min(1)
        .optional()
        .messages({
            'number.base': 'Page must be a number',
            'number.integer': 'Page must be an integer',
            'number.min': 'Page must be at least 1',
        }),
});

// ID parameter validation
export const idParamSchema = Joi.object({
    id: Joi.string()
        .uuid()
        .required()
        .messages({
            'string.guid': 'Invalid task ID format',
            'any.required': 'Task ID is required',
        }),
});

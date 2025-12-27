import Joi from 'joi';

// Valid action types
const ACTIONS = ['created', 'updated', 'deleted', 'status_changed'];

// Task ID parameter validation
export const taskIdParamSchema = Joi.object({
    taskId: Joi.string()
        .uuid()
        .required()
        .messages({
            'string.guid': 'Invalid task ID format',
            'any.required': 'Task ID is required',
        }),
});

// Action parameter validation
export const actionParamSchema = Joi.object({
    action: Joi.string()
        .valid(...ACTIONS)
        .required()
        .messages({
            'any.only': `Action must be one of: ${ACTIONS.join(', ')}`,
            'any.required': 'Action is required',
        }),
});

// Limit query parameter validation
export const limitQuerySchema = Joi.object({
    limit: Joi.number()
        .integer()
        .min(1)
        .max(200)
        .default(50)
        .optional()
        .messages({
            'number.base': 'Limit must be a number',
            'number.integer': 'Limit must be an integer',
            'number.min': 'Limit must be at least 1',
            'number.max': 'Limit cannot exceed 200',
        }),
});

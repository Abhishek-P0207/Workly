import { Router } from "express"
import { tasksClass } from "./controller";
import { validate, validateQuery, validateParams } from "@/middleware/validation";
import {
    previewTaskSchema,
    createTaskSchema,
    updateTaskSchema,
    getAllTasksQuerySchema,
    idParamSchema,
} from "./validation";

const taskRouter = Router();

// List all tasks
taskRouter.get("/", validateQuery(getAllTasksQuerySchema), tasksClass.getAll);

// Preview task classification (without saving)
taskRouter.post("/preview", validate(previewTaskSchema), tasksClass.preview);

// Create a new task
taskRouter.post("/", validate(createTaskSchema), tasksClass.create);

// Get a task details with the history
taskRouter.get("/:id", validateParams(idParamSchema), tasksClass.getById);

// Get task history
taskRouter.get("/:id/history", validateParams(idParamSchema), tasksClass.getHistory);

// Update a task
taskRouter.put("/:id", validateParams(idParamSchema), validate(updateTaskSchema), tasksClass.updateById);

// Delete a task
taskRouter.delete("/:id", validateParams(idParamSchema), tasksClass.deleteById);

export default taskRouter;
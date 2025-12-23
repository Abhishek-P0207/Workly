import { Router } from "express"
import { tasksClass } from "./controller";
const taskRouter = Router();

// List all tasks
taskRouter.get("/", tasksClass.getAll);

// Get a task details with the history
taskRouter.get("/:id", tasksClass.getById);

// Get task history
taskRouter.get("/:id/history", tasksClass.getHistory);

// Create a new task
taskRouter.post("/", tasksClass.create)

// Update a task
taskRouter.put("/:id", tasksClass.updateById)

// Delete a task
taskRouter.delete("/:id", tasksClass.deleteById) 

export default taskRouter;
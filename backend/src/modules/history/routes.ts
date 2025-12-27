import { Router } from "express";
import { HistoryController } from "./controller";
import { validateParams, validateQuery } from "@/middleware/validation";
import { taskIdParamSchema, actionParamSchema, limitQuerySchema } from "./validation";

const historyRouter = Router();

// Get history for a specific task
historyRouter.get("/task/:taskId", validateParams(taskIdParamSchema), HistoryController.getTaskHistory);

// Get recent history across all tasks
historyRouter.get("/recent", validateQuery(limitQuerySchema), HistoryController.getRecentHistory);

// Get history by action type
historyRouter.get("/action/:action", validateParams(actionParamSchema), validateQuery(limitQuerySchema), HistoryController.getByAction);

export default historyRouter;

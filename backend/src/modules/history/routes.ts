import { Router } from "express";
import { HistoryController } from "./controller";

const historyRouter = Router();

// Get history for a specific task
historyRouter.get("/task/:taskId", HistoryController.getTaskHistory);

// Get recent history across all tasks
historyRouter.get("/recent", HistoryController.getRecentHistory);

// Get history by action type
historyRouter.get("/action/:action", HistoryController.getByAction);

export default historyRouter;

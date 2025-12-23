import { Request, Response } from "express";
import { HistoryService } from "./service";

export class HistoryController {
    /**
     * Get history for a specific task
     * GET /api/history/task/:taskId
     */
    static async getTaskHistory(req: Request, res: Response) {
        try {
            const { taskId } = req.params;
            
            const history = await HistoryService.getByTaskId(taskId);
            
            return res.json(history);
        } catch (error) {
            console.error("Error fetching task history:", error);
            return res.status(500).json({ error: "Failed to fetch task history" });
        }
    }

    /**
     * Get recent history across all tasks
     * GET /api/history/recent?limit=50
     */
    static async getRecentHistory(req: Request, res: Response) {
        try {
            const { limit = '50' } = req.query;
            
            const history = await HistoryService.getRecent(parseInt(limit as string));
            
            return res.json(history);
        } catch (error) {
            console.error("Error fetching recent history:", error);
            return res.status(500).json({ error: "Failed to fetch recent history" });
        }
    }

    /**
     * Get history by action type
     * GET /api/history/action/:action?limit=50
     */
    static async getByAction(req: Request, res: Response) {
        try {
            const { action } = req.params;
            const { limit = '50' } = req.query;
            
            const history = await HistoryService.getByAction(action, parseInt(limit as string));
            
            return res.json(history);
        } catch (error) {
            console.error("Error fetching history by action:", error);
            return res.status(500).json({ error: "Failed to fetch history by action" });
        }
    }
}

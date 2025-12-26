// this is where business logic lies
import { Request, Response } from "express";
import { classifyTask, extractDueDate } from "@/utils/classification";
import { TaskService } from "./service";
import { HistoryService } from "../history/service";

export class tasksClass {
    static async preview(req: Request, res: Response) {
        try {
            const { description } = req.body;

            if (!description) {
                return res.status(400).json({ error: "Task description is required" });
            }

            // Classify the task without saving
            const task = classifyTask(description);
            const dueDate = extractDueDate(task.extracted_entities.dates || []);
            const assignedTo = task.extracted_entities.people?.[0] || null;

            // Return classification preview
            return res.json({
                title: task.title || description.substring(0, 100),
                description: description,
                category: task.category,
                priority: task.priority,
                assigned_to: assignedTo,
                due_date: dueDate,
                extracted_entities: task.extracted_entities,
                suggested_actions: task.suggested_actions,
            });
        } catch (error) {
            console.error("Error previewing task:", error);
            return res.status(500).json({ error: "Failed to preview task" });
        }
    }

    static async create(req: Request, res: Response) {
        try {
            const { 
                title,
                description, 
                category, 
                priority, 
                assigned_to, 
                due_date,
                extracted_entities,
                suggested_actions 
            } = req.body;

            if (!description) {
                return res.status(400).json({ error: "Task description is required" });
            }

            if (!title) {
                return res.status(400).json({ error: "Task title is required" });
            }

            // Prepare task data (use provided values or defaults)
            const taskData = {
                title: title,
                description: description,
                category: category || "general",
                priority: priority || "medium",
                status: "pending",
                assigned_to: assigned_to || null,
                due_date: due_date || null,
                extracted_entities: JSON.stringify(extracted_entities || {}),
                suggested_actions: JSON.stringify(suggested_actions || []),
            };

            // Create task via service
            const result = await TaskService.createTask(taskData);

            return res.status(201).json(result);
        } catch (error) {
            console.error("Error creating task:", error);
            return res.status(500).json({ error: "Failed to create task" });
        }
    }

    static async getAll(req: Request, res: Response) {
        try {
            const { 
                category, 
                status, 
                priority, 
                limit = '10', 
                offset = '0',
                page 
            } = req.query;

            // Calculate pagination
            const pageSize = parseInt(limit as string);
            const calculatedOffset = page 
                ? (parseInt(page as string) - 1) * pageSize 
                : parseInt(offset as string);

            // Prepare filters
            const filters = {
                category: category as string | undefined,
                status: status as string | undefined,
                priority: priority as string | undefined,
            };

            // Get tasks from service
            const { tasks, totalCount } = await TaskService.getAllTasks(
                filters,
                pageSize,
                calculatedOffset
            );

            // Calculate pagination metadata
            const totalPages = Math.ceil(totalCount / pageSize);
            const currentPage = page 
                ? parseInt(page as string) 
                : Math.floor(calculatedOffset / pageSize) + 1;
            const hasNextPage = currentPage < totalPages;
            const hasPrevPage = currentPage > 1;

            return res.json({
                data: tasks,
                pagination: {
                    total: totalCount,
                    page: currentPage,
                    limit: pageSize,
                    totalPages,
                    hasNextPage,
                    hasPrevPage
                }
            });
        } catch (error) {
            console.error("Error fetching tasks:", error);
            return res.status(500).json({ error: "Failed to fetch tasks" });
        }
    }

    static async getById(req: Request, res: Response) {
        try {
            const { id } = req.params;
            
            const task = await TaskService.getTaskById(id);
            
            if (!task) {
                return res.status(404).json({ error: "Task not found" });
            }
            
            return res.json(task);
        } catch (error) {
            console.error("Error fetching task:", error);
            return res.status(500).json({ error: "Failed to fetch task" });
        }
    }

    static async updateById(req: Request, res: Response) {
        try {
            const { id } = req.params;
            const { description, status, assigned_to, due_date, priority, category } = req.body;

            // Check if task exists
            const existing = await TaskService.getTaskById(id);
            if (!existing) {
                return res.status(404).json({ error: "Task not found" });
            }

            // Prepare updates
            let updates: any = {};
            
            // If description is updated, re-classify the task
            if (description) {
                const task = classifyTask(description);
                const extractedDueDate = extractDueDate(task.extracted_entities.dates || []);
                const extractedAssignedTo = task.extracted_entities.people?.[0] || null;

                updates = {
                    title: description,
                    description: description,
                    category: task.category,
                    priority: task.priority,
                    assigned_to: extractedAssignedTo,
                    due_date: extractedDueDate,
                    extracted_entities: JSON.stringify(task.extracted_entities),
                    suggested_actions: JSON.stringify(task.suggested_actions),
                };
            }

            // Override with explicit values from request body
            if (status !== undefined) updates.status = status;
            if (assigned_to !== undefined) updates.assigned_to = assigned_to;
            if (due_date !== undefined) updates.due_date = due_date;
            if (priority !== undefined) updates.priority = priority;
            if (category !== undefined) updates.category = category;

            // Update via service (pass old task for history tracking)
            const result = await TaskService.updateTask(id, updates, existing);

            return res.json(result);
        } catch (error) {
            console.error("Error updating task:", error);
            return res.status(500).json({ error: "Failed to update task" });
        }
    }

    static async deleteById(req: Request, res: Response) {
        try {
            const { id } = req.params;
            
            // Get task before deletion for history
            const task = await TaskService.getTaskById(id);
            if (!task) {
                return res.status(404).json({ error: "Task not found" });
            }
            
            await TaskService.deleteTask(id, task);
            
            return res.status(204).send();
        } catch (error) {
            console.error("Error deleting task:", error);
            return res.status(500).json({ error: "Failed to delete task" });
        }
    }

    static async getHistory(req: Request, res: Response) {
        try {
            const { id } = req.params;
            
            // Check if task exists
            const task = await TaskService.getTaskById(id);
            if (!task) {
                return res.status(404).json({ error: "Task not found" });
            }
            
            const history = await HistoryService.getByTaskId(id);
            
            return res.json(history);
        } catch (error) {
            console.error("Error fetching task history:", error);
            return res.status(500).json({ error: "Failed to fetch task history" });
        }
    }
}

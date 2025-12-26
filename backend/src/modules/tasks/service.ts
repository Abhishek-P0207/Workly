import sql from "@/config/db";
import { HistoryService } from "../history/service";

export interface TaskFilters {
    category?: string;
    status?: string;
    priority?: string;
}

export interface TaskData {
    title: string;
    description: string;
    category: string;
    priority: string;
    status: string;
    assigned_to: string | null;
    due_date: Date | null;
    extracted_entities: string;
    suggested_actions: string;
}

export interface TaskUpdate {
    title?: string;
    description?: string;
    category?: string;
    priority?: string;
    status?: string;
    assigned_to?: string | null;
    due_date?: Date | null;
    extracted_entities?: string;
    suggested_actions?: string;
}

export class TaskService {
    static async createTask(taskData: TaskData) {
        const result = await sql`
            insert into tasks (
                title, description, category, priority,
                status, assigned_to, due_date,
                extracted_entities, suggested_actions
            )
            values (
                ${taskData.title},
                ${taskData.description},
                ${taskData.category},
                ${taskData.priority},
                ${taskData.status},
                ${taskData.assigned_to},
                ${taskData.due_date},
                ${taskData.extracted_entities},
                ${taskData.suggested_actions}
            )
            returning *
        `;

        const task = result[0];

        // Add history entry for creation
        await HistoryService.addEntry(
            task.id,
            'created',
            null,
            {
                title: taskData.title,
                description: taskData.description,
                category: taskData.category,
                priority: taskData.priority,
                status: taskData.status,
            }
        );

        return task;
    }

    static async getAllTasks(
        filters: TaskFilters,
        limit: number,
        offset: number
    ) {
        const conditions = [];

        if (filters.category) {
            conditions.push(sql`category = ${filters.category}`);
        }
        if (filters.status) {
            conditions.push(sql`status = ${filters.status}`);
        }
        if (filters.priority) {
            conditions.push(sql`priority = ${filters.priority}`);
        }

        // Get total count
        let totalCount;
        if (conditions.length > 0) {
            const whereCondition = conditions.reduce((acc, condition, index) => {
                if (index === 0) return condition;
                return sql`${acc} and ${condition}`;
            });
            const countResult = await sql`select count(*) from tasks where ${whereCondition}`;
            totalCount = parseInt(countResult[0].count);
        } else {
            const countResult = await sql`select count(*) from tasks`;
            totalCount = parseInt(countResult[0].count);
        }

        // Get tasks
        let tasks;
        if (conditions.length > 0) {
            const whereCondition = conditions.reduce((acc, condition, index) => {
                if (index === 0) return condition;
                return sql`${acc} and ${condition}`;
            });

            tasks = await sql`
                select * from tasks
                where ${whereCondition}
                order by created_at desc
                limit ${limit} offset ${offset}
            `;
        } else {
            tasks = await sql`
                select * from tasks
                order by created_at desc
                limit ${limit} offset ${offset}
            `;
        }

        return { tasks, totalCount };
    }

    static async getTaskById(id: string) {
        const result = await sql`select * from tasks where id = ${id}`;
        return result.length > 0 ? result[0] : null;
    }

    static async updateTask(id: string, updates: TaskUpdate, oldTask: any) {
        const result = await sql`
        update tasks
        set ${sql(updates)},
            updated_at = now()
        where id = ${id}
        returning *
        `;

        if (result.length > 0) {
            // Track what changed - separate old and new values
            const oldValue: any = {};
            const newValue: any = {};

            for (const key of Object.keys(updates)) {
                if (oldTask[key] !== (updates as any)[key]) {
                    oldValue[key] = oldTask[key];
                    newValue[key] = (updates as any)[key];
                }
            }

            // Determine action type based on what changed
            let action: 'updated' | 'status_changed' | 'completed' = 'updated';
            if (newValue.status && oldValue.status !== newValue.status) {
                action = 'status_changed';
            }
            if (newValue.status === 'completed' && oldValue.status !== 'completed') {
                action = 'completed';
            }

            // Add history entry for update
            await HistoryService.addEntry(id, action, oldValue, newValue);

            return result[0];
        }

        return null;
    }

    static async deleteTask(id: string, taskData: any) {
        // Add history entry for deletion BEFORE deleting
        await HistoryService.addEntry(
            id,
            'deleted',
            {
                title: taskData.title,
                description: taskData.description,
                status: taskData.status,
                category: taskData.category,
                priority: taskData.priority,
            },
            null
        );

        await sql`delete from tasks where id = ${id}`;
    }
}

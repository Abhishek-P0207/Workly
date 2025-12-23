import sql from "@/config/db";

export interface HistoryEntry {
    id?: string;
    task_id: string;
    action: string;
    old_value: any;
    new_value: any;
    changed_by?: string;
    changed_at?: Date;
}

export class HistoryService {
    /**
     * Add a history entry for a task action
     */
    static async addEntry(
        taskId: string,
        action: 'created' | 'updated' | 'status_changed' | 'completed' | 'deleted',
        oldValue: any = null,
        newValue: any = null,
        changedBy?: string
    ): Promise<void> {
        await sql`
            insert into task_history (
                task_id, action, old_value, new_value, changed_by, changed_at
            )
            values (
                ${taskId},
                ${action},
                ${oldValue ?? null},
                ${newValue ?? null},
                ${changedBy || null},
                now()
            )
        `;
    }

    /**
     * Get all history entries for a specific task
     */
    static async getByTaskId(taskId: string): Promise<HistoryEntry[]> {
        const history = await sql`
            select * from task_history
            where task_id = ${taskId}
            order by changed_at desc
        `;
        return history as unknown as HistoryEntry[];
    }

    /**
     * Get recent history across all tasks
     */
    static async getRecent(limit: number = 20): Promise<HistoryEntry[]> {
        limit = Math.min(limit, 100);
        const history = await sql`
            select * from task_history
            order by changed_at desc
            limit ${limit}
        `;
        return history as unknown as HistoryEntry[];
    }

    /**
     * Get history by action type
     */
    static async getByAction(action: string, limit: number = 20): Promise<HistoryEntry[]> {
        limit = Math.min(limit, 100);
        const history = await sql`
            select * from task_history
            where action = ${action}
            order by changed_at desc
            limit ${limit}
        `;
        return history as unknown as HistoryEntry[];
    }

    /**
     * Delete history entries for a task (cleanup)
     */
    static async deleteByTaskId(taskId: string): Promise<void> {
        await sql`
            delete from task_history
            where task_id = ${taskId}
        `;
    }
}

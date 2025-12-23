import type { Category, Priority } from "./types";

export const CATEGORY_KEYWORDS: Record<Category, string[]> = {
    scheduling: ["meeting", "schedule", "call", "appointment", "deadline"],
    finance: ["payment", "invoice", "bill", "budget", "cost", "expense"],
    technical: ["bug", "fix", "error", "install", "repair", "maintain"],
    safety: ["safety", "hazard", "inspection", "compliance", "ppe"],
    general: []
};

export const PRIORITY_KEYWORDS: Record<Priority, string[]> = {
    high: ["urgent", "asap", "immediately", "today", "critical", "emergency"],
    medium: ["soon", "this week", "important"],
    low: []
};

export const SUGGESTED_ACTIONS: Record<Category, string[]> = {
    scheduling: [
        "Block calendar",
        "Send invite",
        "Prepare agenda",
        "Set reminder"
    ],
    finance: [
        "Check budget",
        "Get approval",
        "Generate invoice",
        "Update records"
    ],
    technical: [
        "Diagnose issue",
        "Check resources",
        "Assign technician",
        "Document fix"
    ],
    safety: [
        "Conduct inspection",
        "File report",
        "Notify supervisor",
        "Update checklist"
    ],
    general: []
};

import type { Category, Priority } from "./types";
import { CATEGORY_KEYWORDS, PRIORITY_KEYWORDS } from "./constants";

export function detectCategory(text: string): Category {
    for (const category of Object.keys(CATEGORY_KEYWORDS) as Category[]) {
        if (CATEGORY_KEYWORDS[category].some(keyword => text.includes(keyword))) {
            return category;
        }
    }
    return "general";
}

export function detectPriority(text: string): Priority {
    for (const priority of Object.keys(PRIORITY_KEYWORDS) as Priority[]) {
        if (PRIORITY_KEYWORDS[priority].some(keyword => text.includes(keyword))) {
            return priority;
        }
    }
    return "low";
}

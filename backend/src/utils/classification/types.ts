export type Category =
    | "scheduling"
    | "finance"
    | "technical"
    | "safety"
    | "general";

export type Priority = "high" | "medium" | "low";

export interface ClassificationResult {
    title?: string,
    description: string,
    category: Category;
    priority: Priority;
    extracted_entities: {
        dates?: string[];
        people?: string[];
        locations?: string[];
        action_verbs?: string[];
    };
    suggested_actions: string[];
}

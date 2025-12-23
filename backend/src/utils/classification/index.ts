import type { ClassificationResult } from "./types";
import { detectCategory, detectPriority } from "./detectors";
import { extractEntities } from "./extractors";
import { SUGGESTED_ACTIONS } from "./constants";

export * from "./types";
export * from "./constants";
export * from "./detectors";
export * from "./extractors";
export * from "./dateParser";

function normalize(text: string): string {
    return text.toLowerCase().trim();
}

export function classifyTask(text: string): ClassificationResult {
    const normalizedText = normalize(text);

    const category = detectCategory(normalizedText);
    const priority = detectPriority(normalizedText);

    const extracted_entities = extractEntities(text);
    const suggested_actions = SUGGESTED_ACTIONS[category] ?? [];

    return {
        title: suggested_actions[Math.floor(Math.random()*4)],
        description: text,
        category,
        priority,
        extracted_entities,
        suggested_actions
    };
}

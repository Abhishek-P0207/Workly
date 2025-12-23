function matchAll(text: string, regex: RegExp): string[] {
    const matches = text.match(regex);
    return matches ? [...new Set(matches)] : [];
}

function matchAllGroups(
    text: string,
    regex: RegExp,
    groupIndex: number
): string[] {
    const results: string[] = [];
    let match;

    while ((match = regex.exec(text)) !== null) {
        if (match[groupIndex]) {
            results.push(match[groupIndex]);
        }
    }

    return [...new Set(results)];
}

export function extractDates(text: string): string[] {
    const dateRegex =
        /\b(today|tomorrow|tonight|this week|next week|this month|next month|\d{1,2}\/\d{1,2}\/\d{2,4}|\d{1,2}-\d{1,2}-\d{2,4}|(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+\d{1,2}(?:st|nd|rd|th)?(?:,?\s+\d{4})?|(?:monday|tuesday|wednesday|thursday|friday|saturday|sunday)|at\s+\d{1,2}(?::\d{2})?\s*(?:am|pm)?|\d{1,2}(?::\d{2})?\s*(?:am|pm))\b/gi;

    return matchAll(text, dateRegex);
}

export function extractPeople(text: string): string[] {
    const peopleRegex =
        /\b(with|by|assign(?:\s+to)?|for|contact)\s+([A-Z][a-z]+(?:\s[A-Z][a-z]+)*|[a-z]+(?:\s[a-z]+)*)/gi;

    return matchAllGroups(text, peopleRegex, 2);
}

export function extractLocations(text: string): string[] {
    const locationRegex =
        /\b(at|in)\s+([A-Z][a-z]+(?:\s[A-Z][a-z]+)*)/g;

    return matchAllGroups(text, locationRegex, 2);
}

export function extractActionVerbs(text: string): string[] {
    const verbs = [
        "schedule",
        "call",
        "meet",
        "review",
        "prepare",
        "submit",
        "fix",
        "inspect",
        "install"
    ];

    const lower = text.toLowerCase();
    return verbs.filter(v => lower.includes(v));
}

export function extractEntities(text: string) {
    return {
        dates: extractDates(text),
        people: extractPeople(text),
        locations: extractLocations(text),
        action_verbs: extractActionVerbs(text)
    };
}

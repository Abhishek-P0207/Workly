export function parseDateString(dateStr: string): Date | null {
    const lower = dateStr.toLowerCase().trim();
    const now = new Date();

    // Handle relative dates
    if (lower === "today" || lower === "tonight") {
        return new Date(now.getFullYear(), now.getMonth(), now.getDate());
    }

    if (lower === "tomorrow") {
        const tomorrow = new Date(now);
        tomorrow.setDate(tomorrow.getDate() + 1);
        return new Date(tomorrow.getFullYear(), tomorrow.getMonth(), tomorrow.getDate());
    }

    if (lower === "this week") {
        const endOfWeek = new Date(now);
        endOfWeek.setDate(endOfWeek.getDate() + (7 - endOfWeek.getDay()));
        return endOfWeek;
    }

    if (lower === "next week") {
        const nextWeek = new Date(now);
        nextWeek.setDate(nextWeek.getDate() + (7 - nextWeek.getDay()) + 7);
        return nextWeek;
    }

    if (lower === "this month") {
        return new Date(now.getFullYear(), now.getMonth() + 1, 0);
    }

    if (lower === "next month") {
        return new Date(now.getFullYear(), now.getMonth() + 2, 0);
    }

    // Handle day of week
    const daysOfWeek = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"];
    const dayIndex = daysOfWeek.findIndex(day => lower === day);
    if (dayIndex !== -1) {
        const targetDay = new Date(now);
        const currentDay = targetDay.getDay();
        const daysUntilTarget = (dayIndex - currentDay + 7) % 7 || 7;
        targetDay.setDate(targetDay.getDate() + daysUntilTarget);
        return new Date(targetDay.getFullYear(), targetDay.getMonth(), targetDay.getDate());
    }

    // Handle formatted dates (MM/DD/YYYY or MM-DD-YYYY)
    const slashDate = /^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{2,4})$/;
    const slashMatch = dateStr.match(slashDate);
    if (slashMatch) {
        const month = parseInt(slashMatch[1]) - 1;
        const day = parseInt(slashMatch[2]);
        let year = parseInt(slashMatch[3]);
        if (year < 100) year += 2000;
        return new Date(year, month, day);
    }

    // Handle month names (e.g., "December 25", "Dec 25th, 2024")
    const monthNames = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"];
    const monthRegex = /^(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+(\d{1,2})(?:st|nd|rd|th)?(?:,?\s+(\d{4}))?$/i;
    const monthMatch = lower.match(monthRegex);
    if (monthMatch) {
        const monthIndex = monthNames.findIndex(m => monthMatch[1].toLowerCase().startsWith(m));
        const day = parseInt(monthMatch[2]);
        const year = monthMatch[3] ? parseInt(monthMatch[3]) : now.getFullYear();
        return new Date(year, monthIndex, day);
    }

    // If we can't parse it, try native Date parsing as fallback
    const parsed = new Date(dateStr);
    return isNaN(parsed.getTime()) ? null : parsed;
}

export function extractDueDate(dates: string[]): Date | null {
    if (!dates || dates.length === 0) return null;
    
    // Parse all dates and find the earliest future date
    const parsedDates = dates
        .map(d => parseDateString(d))
        .filter((d): d is Date => d !== null);
    
    if (parsedDates.length === 0) return null;
    
    // Return the earliest date
    return parsedDates.reduce((earliest, current) => 
        current < earliest ? current : earliest
    );
}

import postgres from 'postgres'
import dotenv from "dotenv";
dotenv.config();

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
    throw new Error("DATABASE_URL is not defined in .env file");
}

const sql = postgres(connectionString);

try {
    await sql`select 1`;
    console.log("✓ Database connected");
} catch (err) {
    console.error("✗ Database connection failed", err);
}

export default sql;



// if (!process.env.DATABASE_URL) {
//     throw new Error("DATABASE_URL is not defined");
// }

// export const pool = new Pool({
//     connectionString: process.env.DATABASE_URL,
//     ssl: { rejectUnauthorized: false },
//     max: 10,
//     idleTimeoutMillis: 30000,
//     connectionTimeoutMillis: 5000,
// });

// pool.on("connect", () => {
//     console.log("✓ Supabase Postgres connected");
// });

// pool.on("error", (err) => {
//     console.error("✗ Unexpected PG error", err);
//     process.exit(1);
// });

export async function initDb() {
    try {
        await sql`SELECT 1`;
        console.log("✓ Database ready");
    } catch (err) {
        console.error("✗ Database not reachable");
        process.exit(1); // crash fast
    }
}

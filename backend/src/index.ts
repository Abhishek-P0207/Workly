import dotenv from 'dotenv';
import { initDb } from './config/db';

// Load environment variables FIRST before any other imports
dotenv.config();

import express from "express";
import cors from 'cors';
import taskRouter from "./modules/tasks/routes";
import historyRouter from "./modules/history/routes";

const app = express();

app.use(cors());
app.use(express.json());

app.get("/health", (req,res) => {
    res.send("Hello from server");
});

app.use("/api/task", taskRouter);
app.use("/api/history", historyRouter);

await initDb();

app.listen(3000, () => {
    console.log("Server is listening on port 3000");
});


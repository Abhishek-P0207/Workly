import express from "express";
import cors from 'cors';
import taskRouter from "./controller/tasks";

const app = express();

app.use(cors());
app.use(express.json());

app.get("/health", (req,res) => {
    res.send("Hello from server");
});

app.use("/api/task", taskRouter);

app.listen(3000, () => {
    console.log("Server is listening on port 3000");
});


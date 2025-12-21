import { Router } from "express"

const taskRouter = Router();

// List all tasks
taskRouter.get("/", (req,res) => {
    res.send("Hello this is task router");
});

// Get a task details with the history
taskRouter.get("/:id", (req,res) => {
    res.send(`Hello ${req.params.id}`);
})

// Create a new task
taskRouter.post("/", (req,res) => {
    res.send("Hello from post");

    const task: String = req.body.task;

    // 
    
})

// Update a task
taskRouter.put("/:id", (req,res) => {

})

// Delete a task
taskRouter.delete("/:id", (req,res) => {

})

export default taskRouter;
import express from "express";
const app = express();
app.get("/health", (req, res) => {
    res.send("Hello from server");
});
app.listen(3000, () => {
    console.log("Server is listening on port 3000");
});

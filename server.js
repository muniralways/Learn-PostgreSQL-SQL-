 import express from "express";
import { connectDB } from "./db.js";
import { createTable } from "./dbInit.js";
import router from "./src/route.js";

const app = express();

const port = process.env.PORT || 5050;

// Middleware
app.use(express.json());

// Routes
app.use("/api", router);

// Database
// Database
connectDB();
createTable();

// Server
app.listen(port, () => {
    console.log(`Server started on port ${port}`);
    console.log(`http://localhost:${port}/api`);
});

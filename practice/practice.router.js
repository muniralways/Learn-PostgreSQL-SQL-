/**
 * 📗 প্র্যাকটিস — practice.router.js
 * ------------------------------------------------------------------
 * এই router-টা src/route.js-এ মাউন্ট করতে হবে। নিয়ম:
 *
 *   // src/route.js
 *   import practiceRouter from "../practice/practice.router.js";
 *   router.use("/practice", practiceRouter);
 *
 * তারপর চালান:  npm start
 * আর ব্রাউজারে দেখুন:
 *   http://localhost:5050/api/practice/balances
 *   http://localhost:5050/api/practice/transactions
 *   http://localhost:5050/api/practice/history/1
 *   http://localhost:5050/api/practice/top-receivers?limit=3
 *   http://localhost:5050/api/practice/net-change
 */
import express from "express";
import {
  getBalances,
  getTransactions,
  getHistory,
  getTopReceiversHandler,
  getNetChange,
} from "./transaction.controller.js";

const router = express.Router();

// GET /api/practice/balances
router.get("/balances", getBalances);

// GET /api/practice/transactions
router.get("/transactions", getTransactions);

// GET /api/practice/history/:id
router.get("/history/:id", getHistory);

// GET /api/practice/top-receivers?limit=3
router.get("/top-receivers", getTopReceiversHandler);

// GET /api/practice/net-change
router.get("/net-change", getNetChange);

export default router;

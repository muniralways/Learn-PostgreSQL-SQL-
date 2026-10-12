/**
 * 📗 প্র্যাকটিস — transaction.controller.js
 * ------------------------------------------------------------------
 * ⚠️ এখানে একটা গুরুত্বপূর্ণ শিক্ষা লুকিয়ে আছে:
 *
 * আপনার আসল account.controller.js-এ catch ব্লক শুধু console.log করে,
 * কোনো response পাঠায় না। ফলে request আটকে থাকে — ক্লায়েন্ট অনন্তকাল
 * অপেক্ষা করে (hang)।
 *
 * এই ফাইলে দেখুন catch কেন সবসময় res.status(...).json(...) দিয়ে
 * response পাঠায়। এটাই সঠিক নিয়ম।
 */
import {
  getAllBalances,
  listTransactions,
  getAccountHistory,
  getTopReceivers,
  getBalancesWithNetChange,
} from "./transaction.service.js";

/**
 * ছোট helper: যেকোনো controller-এর ভুল ধরে সুন্দর response দেয়।
 * প্রতিটা catch-এ একই কোড লিখতে হয় না।
 */
const handleError = (res, error, fallbackMessage) => {
  console.error("[practice] error:", error.message);
  res.status(error.statusCode || 500).json({
    success: false,
    message: error.statusCode ? error.message : fallbackMessage,
  });
};

export const getBalances = async (req, res) => {
  try {
    const accounts = await getAllBalances();
    res.status(200).json({ success: true, count: accounts.length, data: accounts });
  } catch (error) {
    handleError(res, error, "Could not load balances");
  }
};

export const getTransactions = async (req, res) => {
  try {
    const transactions = await listTransactions();
    res.status(200).json({ success: true, count: transactions.length, data: transactions });
  } catch (error) {
    handleError(res, error, "Could not load transactions");
  }
};

export const getHistory = async (req, res) => {
  try {
    const accountId = Number(req.params.id);

    // ✅ ইনপুট যাচাই: id অবশ্যই একটা ধনাত্মক পূর্ণসংখ্যা হতে হবে
    if (!Number.isSafeInteger(accountId) || accountId <= 0) {
      return res.status(400).json({ success: false, message: "id must be a positive integer" });
    }

    const history = await getAccountHistory(accountId);
    res.status(200).json({ success: true, accountId, count: history.length, data: history });
  } catch (error) {
    handleError(res, error, "Could not load account history");
  }
};

export const getTopReceiversHandler = async (req, res) => {
  try {
    const limit = req.query.limit ? Number(req.query.limit) : 3;

    if (!Number.isSafeInteger(limit) || limit <= 0 || limit > 50) {
      return res.status(400).json({ success: false, message: "limit must be 1-50" });
    }

    const receivers = await getTopReceivers(limit);
    res.status(200).json({ success: true, data: receivers });
  } catch (error) {
    handleError(res, error, "Could not load top receivers");
  }
};

export const getNetChange = async (req, res) => {
  try {
    const rows = await getBalancesWithNetChange();
    res.status(200).json({ success: true, data: rows });
  } catch (error) {
    handleError(res, error, "Could not load net change report");
  }
};

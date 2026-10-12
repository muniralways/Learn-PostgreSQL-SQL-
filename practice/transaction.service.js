/**
 * 📗 প্র্যাকটিস — transaction.service.js
 * ------------------------------------------------------------------
 * আপনার src/account/service.js-এর মতোই গঠন, কিন্তু এখানে মূল লক্ষ্য
 * JOIN আর GROUP BY শেখা। প্রতিটা ফাংশনের উপরে বাংলায় ব্যাখ্যা আছে।
 *
 * এই ফাইলটা একাই চলে না — এটা practice.router.js থেকে কল হয়।
 */
import { pool } from "../db.js";

/**
 * getAllBalances()
 * সব account-এর ব্যালেন্স, বেশি থেকে কম সাজানো।
 * শেখা: সাধারণ SELECT + ORDER BY।
 */
export const getAllBalances = async () => {
  const { rows } = await pool.query(
    "SELECT id, name, balance, created_at FROM accounts ORDER BY balance DESC"
  );
  return rows;
};

/**
 * listTransactions()
 * সব transfer, পাঠানো আর পাওয়া দুজনের নাম সহ।
 * শেখা: একই টেবিল (accounts) দুইবার JOIN — তাই দুটো আলাদা উপনাম (sender, receiver)।
 *
 *   transaction_logs t
 *        ├── JOIN accounts sender   ON sender.id = t.sender_id
 *        └── JOIN accounts receiver ON receiver.id = t.receiver_id
 */
export const listTransactions = async () => {
  const { rows } = await pool.query(`
    SELECT
      t.id,
      sender.name   AS sender,
      receiver.name AS receiver,
      t.amount,
      t.created_at
    FROM transaction_logs t
    JOIN accounts sender   ON sender.id = t.sender_id
    JOIN accounts receiver ON receiver.id = t.receiver_id
    ORDER BY t.created_at DESC, t.id DESC
  `);
  return rows;
};

/**
 * getAccountHistory(accountId)
 * একজন account-এর সব লেনদেন (সে পাঠাক বা পাক)।
 * শেখা: JOIN + WHERE + parameterized query ($1)।
 * 🔐 $1 ব্যবহার করা নিরাপত্তার জন্য জরুরি — সরাসরি string জোড়া লাগাবেন না।
 */
export const getAccountHistory = async (accountId) => {
  const { rows } = await pool.query(
    `
    SELECT
      t.id,
      sender.name   AS sender,
      receiver.name AS receiver,
      t.amount,
      CASE
        WHEN t.sender_id = $1 THEN 'sent'
        ELSE 'received'
      END AS direction,
      t.created_at
    FROM transaction_logs t
    JOIN accounts sender   ON sender.id = t.sender_id
    JOIN accounts receiver ON receiver.id = t.receiver_id
    WHERE t.sender_id = $1 OR t.receiver_id = $1
    ORDER BY t.created_at DESC, t.id DESC
    `,
    [accountId]
  );
  return rows;
};

/**
 * getTopReceivers(limit)
 * কে সবচেয়ে বেশি টাকা পেয়েছে।
 * শেখা: GROUP BY + aggregate (SUM, COUNT) + ORDER BY + LIMIT।
 */
export const getTopReceivers = async (limit = 3) => {
  const { rows } = await pool.query(
    `
    SELECT
      a.name AS receiver,
      COUNT(*) AS times,
      SUM(t.amount) AS total_received
    FROM transaction_logs t
    JOIN accounts a ON a.id = t.receiver_id
    GROUP BY a.id, a.name
    ORDER BY total_received DESC
    LIMIT $1
    `,
    [limit]
  );
  return rows;
};

/**
 * getBalancesWithNetChange()
 * প্রতিটা account-এর পেয়েছে, পাঠিয়েছে, আর নেট পরিবর্তন।
 * শেখা: দুটো aggregate subquery + LEFT JOIN (কে জড়িত নয় তাও থাকবে)।
 * এটাই সবচেয়ে কঠিন query — ধীরে ধীরে পড়ুন।
 */
export const getBalancesWithNetChange = async () => {
  const { rows } = await pool.query(`
    SELECT
      a.name,
      a.balance,
      COALESCE(received.total, 0) AS total_received,
      COALESCE(sent.total, 0)     AS total_sent,
      COALESCE(received.total, 0) - COALESCE(sent.total, 0) AS net_change
    FROM accounts a
    LEFT JOIN (
      SELECT receiver_id, SUM(amount) AS total
      FROM transaction_logs
      GROUP BY receiver_id
    ) received ON received.receiver_id = a.id
    LEFT JOIN (
      SELECT sender_id, SUM(amount) AS total
      FROM transaction_logs
      GROUP BY sender_id
    ) sent ON sent.sender_id = a.id
    ORDER BY net_change DESC
  `);
  return rows;
};

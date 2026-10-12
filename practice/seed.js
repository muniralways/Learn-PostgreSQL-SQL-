/**
 * 🌱 প্র্যাকটিস ডেটা সিডার
 * ------------------------------------------------------------------
 * এই স্ক্রিপ্টটা আপনার practice_db-তে কিছু account আর transfer ঢুকিয়ে দেয়,
 * যাতে JOIN / GROUP BY / EXPLAIN প্র্যাকটিস করার মতো ডেটা থাকে।
 *
 * চালানোর নিয়ম:
 *   node practice/seed.js           → ডেটা যোগ করবে
 *   node practice/seed.js --reset   → আগের সব মুছে নতুন করে বানাবে
 *
 * যেহেতু reset ট্রান্সফার-লগও মুছে ফেলে, তাই .env-এ ভালো ডেটাবেজ নাম রাখুন।
 */
import { pool, connectDB } from "../db.js";
import { createTable } from "../dbInit.js";

const RESET = process.argv.includes("--reset");

// account: [নাম, শুরুর ব্যালেন্স]  (MIN 400 নিয়ম মেনে)
const ACCOUNTS = [
  ["Rahim", 5000],
  ["Karim", 3000],
  ["Jamal", 2500],
  ["Sumaiya", 7000],
  ["Nusrat", 1200],
  ["Tanvir", 450],
];

// transfer: [পাঠায়, পায়, টাকা]
const TRANSFERS = [
  ["Rahim", "Karim", 500],
  ["Rahim", "Jamal", 300],
  ["Sumaiya", "Rahim", 1500],
  ["Karim", "Nusrat", 200],
  ["Jamal", "Sumaiya", 100],
  ["Nusrat", "Tanvir", 50],
  ["Sumaiya", "Karim", 800],
  ["Rahim", "Tanvir", 400],
  ["Karim", "Jamal", 250],
  ["Tanvir", "Nusrat", 30],
];

/**
 * সব transfer একটা transaction-এর ভেতরে করে।
 * কেন? যাতে ১০টা transfer-এর যেকোনো একটা ফেল হলে কোনো লগ জমে না যায় (atomicity)।
 * এটা আপনার service.js-এর transferFunds-এরই বড় বোন। 🧠
 */
const runAllTransfers = async (idByName) => {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    for (const [from, to, amount] of TRANSFERS) {
      const senderId = idByName[from];
      const receiverId = idByName[to];

      // দুটো row একসাথে lock করি, ছোট id আগে — এভাবে deadlock এড়ানো যায়
      const locked = await client.query(
        "SELECT id, balance FROM accounts WHERE id = ANY($1) ORDER BY id FOR UPDATE",
        [[senderId, receiverId]]
      );

      const sender = locked.rows.find((r) => r.id === senderId);
      if (Number(sender.balance) < amount) {
        throw new Error(`NO_BALANCE: ${from}-এর কাছে ${amount} tk নেই`);
      }

      await client.query(
        "UPDATE accounts SET balance = balance - $1 WHERE id = $2",
        [amount, senderId]
      );
      await client.query(
        "UPDATE accounts SET balance = balance + $1 WHERE id = $2",
        [amount, receiverId]
      );
      await client.query(
        "INSERT INTO transaction_logs (sender_id, receiver_id, amount) VALUES ($1, $2, $3)",
        [senderId, receiverId, amount]
      );
    }

    await client.query("COMMIT");
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
};

const run = async () => {
  await connectDB();
  await createTable();

  if (RESET) {
    // TRUNCATE = টেবিল খালি করা, আর RESTART IDENTITY = id আবার 1 থেকে শুরু
    await pool.query("TRUNCATE transaction_logs, accounts RESTART IDENTITY CASCADE");
    console.log("🧹 পুরোনো ডেটা মুছে ফেলা হলো");
  }

  // ১) accounts বানানো, নাম → id ম্যাপ রাখা
  const idByName = {};
  for (const [name, balance] of ACCOUNTS) {
    const result = await pool.query(
      "INSERT INTO accounts (name, balance) VALUES ($1, $2) RETURNING id, name",
      [name, balance]
    );
    idByName[result.rows[0].name] = result.rows[0].id;
    console.log(`👤 account বানানো: ${name} (id=${result.rows[0].id})`);
  }

  // ২) transfers চালানো
  await runAllTransfers(idByName);
  console.log(`💸 ${TRANSFERS.length}টা transfer করা হলো`);

  // ৩) শেষ অবস্থা দেখানো
  const summary = await pool.query(
    "SELECT id, name, balance FROM accounts ORDER BY id"
  );
  console.table(summary.rows);

  await pool.end();
  console.log("✅ প্র্যাকটিস ডেটা রেডি!");
};

run().catch((error) => {
  console.error("❌ সিড করতে সমস্যা:", error.message);
  process.exit(1);
});

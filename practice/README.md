# 🎓 PostgreSQL Practice Kit

এই ফোল্ডারটা শুধু **শেখার জন্য**। এখানে সবকিছু আপনার নিজের `practice_db` দিয়েই চলবে।
কোড পড়বেন, চালাবেন, আর ভাঙবেন — এটাই উদ্দেশ্য।

---

## কীভাবে ব্যবহার করবেন (ধাপে ধাপে)

### ১. প্র্যাকটিস ডেটা বানান
```bash
node practice/seed.js --reset
```
এটা ৬টা account আর ১০টা transfer বানাবে, যাতে JOIN/GROUP BY করার মতো ডেটা থাকে।
`--reset` দিলে আগের সব মুছে নতুন করে বানাবে।

### ২. SQL প্র্যাকটিস করুন (psql-এ)
```bash
psql -U monir -d practice_db
```
তারপর `practice/sql/` ফোল্ডারের ফাইলগুলো ক্রম অনুযায়ী খুলুন এবং query কপি-পেস্ট করে চালান।

```
01_basics.sql          → SELECT, WHERE, ORDER BY, LIMIT
02_joins.sql           → JOIN দিয়ে নাম বের করা
03_groupby.sql         → GROUP BY, HAVING, SUM/COUNT
04_transaction.sql     → BEGIN/COMMIT, FOR UPDATE, lock
05_explain_index.sql   → EXPLAIN ANALYZE, index
```

প্রতিটা ফাইলে আছে:
- `-- 🎯 TASK` = আপনার কাজ (প্রথমে নিজে চেষ্টা করুন)
- `-- ✅ ANSWER` = উত্তর

### ৩. Node API প্র্যাকটিস করুন
`practice/transaction.service.js` আর `practice/transaction.controller.js` — এগুলো
আপনার `src/account/` ফোল্ডারের মতোই প্যাটার্নে লেখা। এগুলো পড়ুন, বোঝার চেষ্টা করুন।

### ৪. নতুন endpoint চালু করতে (এটা আপনার কাজ!)
`practice/practice.router.js` ফাইলটা `src/route.js`-এ ভেতরে বসিয়ে দিন — নিচে দেখানো আছে।

---

## ফাইল ম্যাপ

| ফাইল | কী শিখবেন |
|---|---|
| `seed.js` | ডেটা বানানো, transaction-এর ভেতরে bulk insert |
| `transaction.service.js` | JOIN, GROUP BY, parameterized query |
| `transaction.controller.js` | controller-এ ঠিকভাবে error ধরা |
| `practice.router.js` | Express router বানানো |
| `sql/*.sql` | খাঁটি SQL চর্চা |
| `EXERCISES.md` | নিজে নিজে করার কাজগুলো |

---

## নতুন endpoint মাউন্ট করার নিয়ম

`src/route.js` এ দুটো লাইন যোগ করুন:

```js
import practiceRouter from "../practice/practice.router.js";

router.use("/practice", practiceRouter);
```

তারপর বা শেষে চালান:
```bash
npm start
```
এবং ব্রাউজারে:
```
http://localhost:5050/api/practice/transactions
http://localhost:5050/api/practice/top-receivers
```

> 💡 **মনে রাখবেন:** আপনার `server.js` আসলে `process.env.PORT` পড়ে, আর `.env`-এ লেখা
> আছে `port` (ছোট হাতের অক্ষর)। তাই এটা ৫০৫০-এ চলবে, `.env`-এর ৫০০০-এ নয়।
> এটা নিজে ঠিক করার একটা কাজ আছে `EXERCISES.md`-এ।

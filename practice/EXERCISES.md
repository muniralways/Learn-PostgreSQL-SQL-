# 🏋️ নিজে নিজে করার কাজ (EXERCISES)

এগুলো করার নির্দিষ্ট ক্রম আছে। একটা শেষ না করে পরেরটায় যাবেন না।
সমাধান নিজে না বের করে ANSWER না দেখার অনুরোধ।

---

## 🟢 ধাপ ১ — SQL হাত পাকান (সহজ)

`practice/sql/01_basics.sql`, `02_joins.sql`, `03_groupby.sql` — তিনটা ফাইলের
সব TASK নিজে লিখুন, তারপর ANSWER-এর সাথে মিলান।

- [ ] 01_basics.sql — ১০টা task
- [ ] 02_joins.sql — ৬টা task
- [ ] 03_groupby.sql — ৬টা task

---

## 🟡 ধাপ ২ — Transaction নিজে চোখে দেখুন

`practice/sql/04_transaction.sql` — দুইটা psql ট্যাব খুলে চারটা পরীক্ষা চালান।

- [ ] Transaction + ROLLBACK
- [ ] FOR UPDATE → Tab B আটকে থাকা
- [ ] FOR UPDATE বাদ দিয়ে "lost update" তৈরি করা
- [ ] Deadlock নিজে বানানো

> 💭 এই ধাপের পর নিজেকে প্রশ্ন করুন: *"আমার service.js-এর transferFunds
> কেন FOR UPDATE ছাড়া কখনো লেখা উচিত নয়?"*

---

## 🟠 ধাপ ৩ — Performance (EXPLAIN)

`practice/sql/05_explain_index.sql`

- [ ] ছোট টেবিলে EXPLAIN চালানো
- [ ] ২ লাখ row বানানো, index-এর ক্ষমতা দেখা
- [ ] index মুছে পার্থক্য মাপা
- [ ] "index থাকলে তবুও Seq Scan হয়" — কেন, ব্যাখ্যা করা

---

## 🔵 ধাপ ৪ — Node API চালু করা (কোড পড়া + এডিট)

`practice/practice.router.js` কে `src/route.js`-এ মাউন্ট করুন:

```js
import practiceRouter from "../practice/practice.router.js";
router.use("/practice", practiceRouter);
```

তারপর `npm start` দিয়ে চালিয়ে ব্রাউজারে ৫টা endpoint দেখুন।

- [ ] `/api/practice/transactions` → JOIN কাজ করছে?
- [ ] `/api/practice/top-receivers?limit=2` → GROUP BY কাজ করছে?
- [ ] `/api/practice/history/1` → history ঠিক আসছে?

---

## 🔴 ধাপ ৫ — আসল প্রজেক্টের বাগ ঠিক করা

এখন আপনার আসল কোডের সমস্যাগুলো নিজে ঠিক করুন (আমি শুধু ইঙ্গিত দিচ্ছি):

### বাগ ১: `AppError` কোথাও নেই
`src/account/service.js`-এ `throw new AppError(...)` আছে, কিন্তু `AppError`
কোথাও define করা নেই → account বানালে `ReferenceError`।

- [ ] `src/errors.js` বানিয়ে একটা `AppError` class লিখুন
      (এখানে `message` আর `statusCode` থাকবে)
- [ ] `service.js`-এ import করুন
- [ ] ⚠️ খেয়াল করুন: `AppError` কে `Error` থেকে extend করতে হবে,
      আর constructor-এ `super(message)` ডাকতে হবে

### বাগ ২: Controller কোনো response দেয় না
`src/account/account.controller.js`-এর প্রতিটা `catch` শুধু `console.log`
করে। তাই ভুল হলে request hang করে।

- [ ] প্রতিটা catch-এ `res.status(500).json(...)` যোগ করুন
- [ ] সুবিধা হলে `practice/transaction.controller.js`-এর `handleError` প্যাটার্ন দেখে নিন

### বাগ ৩: `.env` এর port পড়া হচ্ছে না
`.env`-এ লেখা আছে `port` (ছোট হাতের <code>p</code>) কিন্তু `server.js` পড়ছে
`process.env.PORT` (বড় হাতের)।
- [ ] নাম মিলিয়ে দিন — দুটোতেই একই হোক
- [ ] ⚠️ **আরেকটা ফাঁদ:** `server.js`-এ `dotenv.config()` কখনো করা হয়নি!
      `db.js` করতে পারে, কিন্তু import order-এর কারণে server.js-এ `PORT`
      পড়ার আগে dotenv চলবে কি? `db.js`-এর `import`-টাই কাজ করে কিনা ভাবুন,
      `dotenv.config()` যোগ করা নিরাপদ।

### বাগ ৪: `src/route.js`-এ অব্যবহৃত import
```js
import express, {Router} from "express";   // Router কখনো ব্যবহার হয়নি
```
- [ ] `Router` সরিয়ে দিন

---

## 🟣 ধাপ ৬ — বাড়তি চ্যালেঞ্জ (সময় থাকলে)

- [ ] **নতুন feature:** `POST /api/accounts/search` — নামের অংশ দিয়ে খোঁজা
      (LIKE + parameterized query)। সাবধান: `$1`-এর সাথে `%` যোগ করুন কোডে,
      `${}` দিয়ে নয়!
- [ ] **N+1 সমস্যা ধরুন:** এমন কোড লিখবেন না যেখানে loop-এর ভেতরে query চালায়।
      এক query-তে JOIN করে আনুন।
- [ ] **Bulk seed:** `generate_series` দিয়ে ৫০টা account বানিয়ে GROUP BY চালান।
- [ ] **Deadlock log:** Postgres লগে deadlock কেমন দেখায় সেটা খুঁজে দেখুন।

---

## 📝 শেখার পরীক্ষা

নিজেকে উত্তর দিতে পারলে ধরে নিন আপনি পুরো বিষয়টা বুঝেছেন:

1. `pool.query` বনাম `pool.connect()` → `client` — কখন কোনটা লাগে?
2. `$1` কেন `${}`-এর চেয়ে ভালো — দুইটা কারণ বলুন।
3. একটা transfer-এ `BEGIN` আর `COMMIT`/`ROLLBACK` কেন দরকার?
4. `FOR UPDATE` না থাকলে কী দানব জন্ম নেয়?
5. `ORDER BY id` লাইনটা কেন জীবন বাঁচায়?
6. `WHERE` আর `HAVING`-এর পার্থক্য কী?
7. Executed query-র পরিকল্পনা দেখতে কোন ক্রিয়াপদ ব্যবহার করবেন?

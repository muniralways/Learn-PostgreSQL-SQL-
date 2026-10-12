-- ============================================================
-- 📘 প্র্যাকটিস ০১ — SELECT, WHERE, ORDER BY, LIMIT
-- ============================================================
-- আগে ডেটা সিড করুন:  node practice/seed.js --reset
-- তারপর:              psql -U monir -d practice_db
--
-- নিয়ম: TASK পড়ে নিজে লিখুন, পরে ANSWER-এর সাথে মিলান।
-- ============================================================


-- 🎯 TASK 1: accounts টেবিলের সব কলাম, সব row দেখান।
-- ✅ ANSWER:
SELECT * FROM accounts;


-- 🎯 TASK 2: শুধু id, name, balance কলাম দেখান।
-- ✅ ANSWER:
SELECT id, name, balance FROM accounts;


-- 🎯 TASK 3: সব account-কে ব্যালেন্স বেশি থেকে কম সাজিয়ে দেখান।
-- ✅ ANSWER:
SELECT name, balance FROM accounts ORDER BY balance DESC;


-- 🎯 TASK 4: যাদের balance ২০০০-এর বেশি, তাদের name আর balance দেখান।
-- ✅ ANSWER:
SELECT name, balance FROM accounts WHERE balance > 2000;


-- 🎯 TASK 5: balance ১০০০ আর ৫০০০-এর মাঝে যারা, তাদের দেখান।
-- ✅ ANSWER:
SELECT name, balance FROM accounts WHERE balance BETWEEN 1000 AND 5000;
-- (একই কথা: WHERE balance >= 1000 AND balance <= 5000)


-- 🎯 TASK 6: যাদের নাম "R" দিয়ে শুরু, তাদের দেখান।
-- ✅ ANSWER:
SELECT * FROM accounts WHERE name LIKE 'R%';
-- মনে রাখুন: % = যেকোনো অক্ষর, _ = ঠিক একটা অক্ষর


-- 🎯 TASK 7: সবচেয়ে ধনী ২ জনকে দেখান।
-- ✅ ANSWER:
SELECT name, balance FROM accounts ORDER BY balance DESC LIMIT 2;


-- 🎯 TASK 8: মোট কতগুলো account আছে?
-- ✅ ANSWER:
SELECT COUNT(*) AS total_accounts FROM accounts;
-- 🔎 কেন AS? কলামের নাম সুন্দর করতে। না দিলে হবে "count"


-- 🎯 TASK 9 (নিজে ভাবুন): ব্যালেন্সের যোগফল আর গড় একসাথে দেখান।
-- ✅ ANSWER:
SELECT SUM(balance) AS total, ROUND(AVG(balance), 2) AS avg_balance FROM accounts;


-- 🎯 TASK 10 (সবচেয়ে কঠিন): যাদের নামে "a" আছে আর ব্যালেন্স ১০০০+, তাদের
-- নাম অনুযায়ী A→Z সাজিয়ে দেখান।
-- ✅ ANSWER:
SELECT name, balance
FROM accounts
WHERE name LIKE '%a%' AND balance >= 1000
ORDER BY name ASC;

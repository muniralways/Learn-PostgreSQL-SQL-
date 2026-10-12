-- ============================================================
-- 📘 প্র্যাকটিস ০৫ — EXPLAIN ANALYZE আর Index
-- ============================================================
-- প্রশ্ন: একটা query চালালে Postgres আসলে ঠিক কী করে? খুঁজতে কত সময় লাগে?
-- উত্তর পেতে query-র আগে EXPLAIN ANALYZE বসান।
-- ============================================================


-- 🎯 TASK 1: ছোট টেবিলে EXPLAIN চালান।
-- ✅ ANSWER:
EXPLAIN ANALYZE
SELECT * FROM transaction_logs WHERE sender_id = 1;

-- 🔎 যা দেখবেন:
--    "Seq Scan" মানে পুরো টেবিল স্ক্যান করছে। ছোট টেবিলে এটা সস্তা (ঠিক আছে)।
--    "Index Scan" মানে index ব্যবহার করছে — বড় টেবিলে অনেক দ্রুত।
--    "cost=0.00..1.05" = planner-এর আন্দাজ করা খরচ।
--    "actual time=... rows=..." = সত্যিকারের সময় আর row সংখ্যা।


-- ============================================================
-- 🧪 পরীক্ষা ১: বড় টেবিল বানানো, তারপর index-এর ক্ষমতা দেখুন
-- ============================================================

-- ধাপ ১: ২০০,০০০ row বানান (একটু সময় নেবে)
INSERT INTO transaction_logs (sender_id, receiver_id, amount)
SELECT
  (random() * 5 + 1)::int,
  (random() * 5 + 1)::int,
  (random() * 1000)::numeric(10,2)
FROM generate_series(1, 200000);
-- 🔎 generate_series(1, 200000) = ১ থেকে ২ লাখ পর্যন্ত সংখ্যার ধারা বানায়।
--    এটা ডেটা বানানোর সবচেয়ে সহজ উপায়।

ANALYZE transaction_logs;   -- planner-কে নতুন পরিসংখ্যান দিন

-- ধাপ ২: এখন EXPLAIN দিন — Index Scan দেখা উচিত
EXPLAIN ANALYZE
SELECT * FROM transaction_logs WHERE sender_id = 2;

-- 🎯 TASK 2: index-টা কেন কাজে লাগছে, বলুন। sender_id-তে index আছে,
--     তাই খোঁজা দ্রুত। আর receiver_id-তেও index আছে (আপনার dbInit.js দেখুন)।

-- ============================================================
-- 🧪 পরীক্ষা ২: Index মুছে দেখুন কী হয়
-- ============================================================
-- ধাপ ১: index মুছুন
DROP INDEX IF EXISTS idx_tx_sender;

-- ধাপ ২: আবার EXPLAIN — এখন Seq Scan, আর "rows" স্ক্যান হয়েছে ২ লাখ!
EXPLAIN ANALYZE
SELECT * FROM transaction_logs WHERE sender_id = 2;
-- 👉 "actual time" কতটুকু বাড়ল খেয়াল করুন। এটাই index-এর ক্ষমতা।

-- ধাপ ৩: index আবার ফিরিয়ে আনুন
CREATE INDEX IF NOT EXISTS idx_tx_sender ON transaction_logs(sender_id);


-- ============================================================
-- 🧪 পরীক্ষা ৩: Index কখন কাজে লাগে না
-- ============================================================
-- 🎯 TASK 3: নিচের query-তে index কাজে লাগবে কি? আগে আন্দাজ করুন!
EXPLAIN ANALYZE
SELECT * FROM transaction_logs WHERE amount > 500;
-- 🔎 উত্তর: amount-এ কোনো index নেই → Seq Scan।
--    কারণ: ">500" টেবিলের প্রায় সব row-ই মেলে, তাই index-এ ঘোরা অপচয়।
--    💡 শেখা: index লাভজনক যখন অল্পসংখ্যক row ফেরে (যেমন id বা sender_id)।

-- 🎯 TASK 4 (নিজে করুন): amount-এ index বানালে কী হয়, দেখুন।
-- ✅ ANSWER:
CREATE INDEX IF NOT EXISTS idx_tx_amount ON transaction_logs(amount);
ANALYZE transaction_logs;
EXPLAIN ANALYZE SELECT * FROM transaction_logs WHERE amount > 500;
-- 🔎 সম্ভবত তবুও Seq Scan! কারণ ৫০০-এর বেশি row অনেক বেশি। Planner তখন
--    index-এর চেয়ে পুরো স্ক্যান সস্তা মনে করে। এটাই আসল শিক্ষা:
--    "index মানেই দ্রুত" — এটা ভুল ধারণা। Planner বুদ্ধিমান।


-- ============================================================
-- 🧪 পরীক্ষা ৪: কলাম বনাম "SELECT *"
-- ============================================================
EXPLAIN ANALYZE SELECT id, amount FROM transaction_logs WHERE sender_id = 1;
-- 🔎 শুধু দরকারি কলাম নিলে কম ডেটা পড়তে হয় — বাস্তবে এতে পার্থক্য হয়।

-- 🧹 শেষে বড় ডেটা মুছুন (একটু সময় নেবে, ধৈর্য ধরুন 🙂):
-- DELETE FROM transaction_logs WHERE id > 100;

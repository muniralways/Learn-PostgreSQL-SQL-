-- ============================================================
-- 📘 প্র্যাকটিস ০৩ — GROUP BY, HAVING, Aggregate
-- ============================================================
-- GROUP BY = একই দলের row গুলোকে একসাথে করে তার উপর হিসাব চালানো।
-- যেমন: "প্রতিটা receiver কত টাকা পেয়েছে?"
--
-- 🔑 সোনার নিয়ম: SELECT-এ যা কিছু aggregate (SUM/COUNT...) নয়,
--    সেগুলো GROUP BY-তে থাকতে হবে।
-- ============================================================


-- 🎯 TASK 1: প্রতিটা receiver মোট কত টাকা পেয়েছে, আর কতবার।
-- ✅ ANSWER:
SELECT
  r.name AS receiver,
  COUNT(*) AS times,
  SUM(t.amount) AS total_received
FROM transaction_logs t
JOIN accounts r ON r.id = t.receiver_id
GROUP BY r.name
ORDER BY total_received DESC;


-- 🎯 TASK 2: প্রতিটা sender মোট কত টাকা পাঠিয়েছে।
-- ✅ ANSWER:
SELECT
  s.name AS sender,
  COUNT(*) AS times,
  SUM(t.amount) AS total_sent
FROM transaction_logs t
JOIN accounts s ON s.id = t.sender_id
GROUP BY s.name
ORDER BY total_sent DESC;


-- 🎯 TASK 3: প্রতিটা account-এর নেট পরিবর্তন (পেয়েছে − পাঠিয়েছে)।
-- 💡 কৌশল: দুটো আলাদা GROUP BY করে যোগ/বিয়োগ, অথবা UNION ALL + GROUP BY।
-- ✅ ANSWER (সহজ পথ):
SELECT
  a.name,
  COALESCE(received.total, 0) AS got,
  COALESCE(sent.total, 0) AS gave,
  COALESCE(received.total, 0) - COALESCE(sent.total, 0) AS net
FROM accounts a
LEFT JOIN (
  SELECT receiver_id, SUM(amount) AS total
  FROM transaction_logs GROUP BY receiver_id
) received ON received.receiver_id = a.id
LEFT JOIN (
  SELECT sender_id, SUM(amount) AS total
  FROM transaction_logs GROUP BY sender_id
) sent ON sent.sender_id = a.id
ORDER BY net DESC;
-- 🔎 এটা একটা "subquery" — JOIN-এর ভেতরে আরেকটা query। নাম দিয়ে ব্যবহার করলে
--    তাকে derived table বলে। বড় কাজে খুব দরকারি।


-- 🎯 TASK 4: যারা ৩ বারের বেশি transaction পেয়েছে (HAVING দিয়ে)।
-- ⚠️ WHERE দিয়ে GROUP-এর ফল ফিল্টার করা যায় না — লাগে HAVING।
--    মনে রাখুন: WHERE → GROUP করার আগে, HAVING → GROUP করার পরে।
-- ✅ ANSWER:
SELECT r.name AS receiver, COUNT(*) AS times
FROM transaction_logs t
JOIN accounts r ON r.id = t.receiver_id
GROUP BY r.name
HAVING COUNT(*) > 2
ORDER BY times DESC;


-- 🎯 TASK 5 (নিজে ভাবুন): মোট কত টাকা সব transfer মিলিয়ে চলাচল করল?
-- ✅ ANSWER:
SELECT SUM(amount) AS total_moved, AVG(amount) AS avg_amount FROM transaction_logs;


-- 🎯 TASK 6 (চ্যালেঞ্জ): দিন অনুযায়ী মোট transfers (তারিখই ভিত্তি)।
-- 💡 কৌশল: created_at-কে DATE-এ রূপান্তর করুন।
-- ✅ ANSWER:
SELECT
  DATE(created_at) AS day,
  COUNT(*) AS tx_count,
  SUM(amount) AS total
FROM transaction_logs
GROUP BY DATE(created_at)
ORDER BY day;
-- 🔎 DATE(created_at) = timestamp থেকে শুধু দিনের অংশ নেয়।


-- 🧠 এখন মাথায় গেঁথে নিন:
--   COUNT / SUM / AVG / MIN / MAX   → aggregate ফাংশন
--   GROUP BY                        → দল বানানো
--   HAVING                          → দল বানানোর পরে ফিল্টার
--   WHERE                           → দল বানানোর আগে ফিল্টার

-- ============================================================
-- 📘 প্র্যাকটিস ০২ — JOIN (দুই টেবিল জোড়া লাগানো)
-- ============================================================
-- সমস্যা: transaction_logs-এ শুধু sender_id, receiver_id (সংখ্যা) আছে।
-- কিন্তু আপনি নাম দেখতে চান, সংখ্যা নয়।
-- সেটাই JOIN-এর কাজ — দুটো টেবিল একসাথে জোড়া লাগানো।
--
-- transaction_logs ──(sender_id)──► accounts
--                  └─(receiver_id)─► accounts
-- ============================================================


-- 🎯 TASK 1: প্রতিটা transaction-এর সাথে পাঠানোর নাম দেখান (শুধু sender)।
-- ✅ ANSWER:
SELECT t.id, t.amount, a.name AS sender_name
FROM transaction_logs t
JOIN accounts a ON a.id = t.sender_id
ORDER BY t.id;


-- 🎯 TASK 2: দুইদিকের নামই দেখান — পাঠায় কে, পায় কে।
-- 💡 কৌশল: accounts টেবিলটা দুইবার JOIN করতে হবে, তাই দুটো আলাদা উপনাম (s, r) লাগবে।
-- ✅ ANSWER:
SELECT
  t.id,
  s.name AS sender,
  r.name AS receiver,
  t.amount,
  t.created_at
FROM transaction_logs t
JOIN accounts s ON s.id = t.sender_id
JOIN accounts r ON r.id = t.receiver_id
ORDER BY t.id;


-- 🎯 TASK 3: শুধু "Rahim" কী কী পাঠিয়েছে সেটা দেখান।
-- ✅ ANSWER:
SELECT s.name AS sender, r.name AS receiver, t.amount
FROM transaction_logs t
JOIN accounts s ON s.id = t.sender_id
JOIN accounts r ON r.id = t.receiver_id
WHERE s.name = 'Rahim';


-- 🎯 TASK 4: Rahim জড়িত সব transaction (সে পাঠাক বা পাক — দুইটাই)।
-- 💡 কৌশল: OR ব্যবহার করুন।
-- ✅ ANSWER:
SELECT s.name AS sender, r.name AS receiver, t.amount
FROM transaction_logs t
JOIN accounts s ON s.id = t.sender_id
JOIN accounts r ON r.id = t.receiver_id
WHERE s.name = 'Rahim' OR r.name = 'Rahim';


-- 🎯 TASK 5 (নিজে ভাবুন): কোন account কী পেয়েছে তার তালিকা, কিন্তু
-- সবচেয়ে বড় Amount আগে।
-- ✅ ANSWER:
SELECT r.name AS receiver, t.amount
FROM transaction_logs t
JOIN accounts r ON r.id = t.receiver_id
ORDER BY t.amount DESC;


-- ⚠️ গুরুত্বপূর্ণ ধারণা: LEFT JOIN
-- উপরের JOIN (INNER JOIN) শুধু মিলে যাওয়া row দেয়।
-- কোনো account যদি কখনো কিছু না পাঠায়, সে INNER JOIN-এ হারিয়ে যাবে।
-- সব (তাকেও দেখাতে) হলে LEFT JOIN লাগে।

-- 🎯 TASK 6 (চ্যালেঞ্জ): সব account + তাদের পাঠানো মোট টাকা;
-- এমনকি যারা কিছু পাঠায়নি (তাদের জন্য 0)। ব্যালেন্স-শীর্ষে সাজান।
-- ✅ ANSWER:
SELECT
  a.name,
  COALESCE(SUM(t.amount), 0) AS sent_total
FROM accounts a
LEFT JOIN transaction_logs t ON t.sender_id = a.id
GROUP BY a.id, a.name
ORDER BY sent_total DESC;
-- 🔎 LEFT JOIN মানে "accounts-এর সবাই থাকবে"; না মিললে null → COALESCE 0 করে দেয়।

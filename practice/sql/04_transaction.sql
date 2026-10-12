-- ============================================================
-- 📘 প্র্যাকটিস ০৪ — Transaction, FOR UPDATE, Lock
-- ============================================================
-- এই ফাইলটা একা চালানো যায় না — দুটো psql ট্যাব লাগবে।
--
-- 🔧 সেটআপ: দুইটা terminal খুলুন, দুটোতেই:
--      psql -U monir -d practice_db
--    একটাকে বলি "Tab A", অন্যটাকে "Tab B"।
--
-- নিয়ম: Tab A-তে ধাপ ১, তারপর Tab B-তে ধাপ ২ চালান। আটকে থাকবে —
--        এটাই আসল শিক্ষা। তারপর Tab A COMMIT করলে Tab B ছাড় পাবে।
-- ============================================================


-- ============================================================
-- 🧪 পরীক্ষা ১: Transaction = হয় সব, নাহয় কিছুই না  (শুধু Tab A)
-- ============================================================

-- ধাপ ১: Karim-এর ব্যালেন্স দেখুন, মনে রাখুন
SELECT id, name, balance FROM accounts WHERE name = 'Karim';

-- ধাপ ২: একটা transaction শুরু করুন, টাকা কাটুন, কিন্তু COMMIT করবেন না
BEGIN;

UPDATE accounts SET balance = balance - 1000 WHERE name = 'Karim';
SELECT name, balance FROM accounts WHERE name = 'Karim';   -- কমে গেছে

-- ধাপ ৩: এখন "ভুল হয়েছে" ভান করে ফিরিয়ে দিন
ROLLBACK;

-- ধাপ ৪: আবার দেখুন — টাকা ফিরে এসেছে! জাদু 🎉
SELECT name, balance FROM accounts WHERE name = 'Karim';

-- 👉 শিক্ষা: COMMIT করার আগে কিছুই সত্যিকারভাবে বদলায় না (একে atomicity বলে)।

-- ============================================================
-- 🧪 পরীক্ষা ২: Row Lock — FOR UPDATE এর আসল শক্তি
-- ============================================================

-- 🔵 Tab A-তে:
BEGIN;
SELECT id, name, balance FROM accounts WHERE name = 'Rahim' FOR UPDATE;
-- এখন Rahim-এর row-এ তালা লাগানো (lock)। Tab A-তে COMMIT না করা পর্যন্ত
-- Tab B অপেক্ষা করবে।

-- 🔴 Tab B-তে (এখন চালান — আটকে/frozen হয়ে থাকবে):
BEGIN;
UPDATE accounts SET balance = balance + 1 WHERE name = 'Rahim';
-- ⏳ এখানে আটকে থাকবে... Tab A COMMIT না করা পর্যন্ত

-- 🔵 Tab A-তে (এখন চালান):
COMMIT;

-- 🔴 Tab B-তে: তখনই update হয়ে যাবে, তারপর:
COMMIT;


-- ============================================================
-- 🧪 পরীক্ষা ৩: FOR UPDATE থাকলে vs না থাকলে  (danger!)
-- ============================================================
-- ধারণা: একই account-এ দুইজনে একসাথে টাকা পাঠালে কী হয়?
--
-- Tab A:  BEGIN; SELECT balance FROM accounts WHERE name='Tanvir' FOR UPDATE;
-- Tab B:  BEGIN; SELECT balance FROM accounts WHERE name='Tanvir' FOR UPDATE;
--         ↑ Tab B আটকে থাকবে — কারণ lock। এটাই ভালো, নিরাপদ।
--
-- এখন FOR UPDATE বাদ দিয়ে আবার করুন:
-- Tab A:  BEGIN; SELECT balance FROM accounts WHERE name='Tanvir';
-- Tab B:  BEGIN; SELECT balance FROM accounts WHERE name='Tanvir';
--         ↑ দুজনেই সাথে সাথে balance পড়ে ফেলবে (কোনো lock নেই)!
--         দুজনেই ভেবে নেবে "টাকা আছে", অথচ আসলে একজনের কম!
--
-- 👉 এই অবস্থাকে "race condition" বা "lost update" বলে।
--    আপনার service.js-এর FOR UPDATE লাইনটা ঠিক এই দানব ঠেকায়।


-- ============================================================
-- 🧪 পরীক্ষা ৪: Deadlock (কীভাবে হয়, কীভাবে এড়াবেন)
-- ============================================================
-- Tab A:  BEGIN; UPDATE accounts SET balance=balance-1 WHERE id=1;
--         UPDATE accounts SET balance=balance+1 WHERE id=2;
-- Tab B:  BEGIN; UPDATE accounts SET balance=balance-1 WHERE id=2;
--         UPDATE accounts SET balance=balance+1 WHERE id=1;
-- ↑ চালালে Postgres একটা transaction-কে মেরে বলবে: "deadlock detected"
--
-- ✅ সমাধান: সবসময় ছোট id আগে lock করুন, যেমন আপনার কোডে:
--    WHERE id = ANY($1) ORDER BY id FOR UPDATE
-- এই লাইনটা থাকলে id ক্রম সবসময় এক → deadlock অসম্ভব।

-- ✅ শেষে নিশ্চিত করুন সব transaction বন্ধ:
-- (কোনো tab আটকে থাকলে COMMIT বা ROLLBACK দিন)
COMMIT;

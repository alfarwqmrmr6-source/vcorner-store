# ڤي كورنر | V Corner — متجر عطور

Node.js (Express) + MySQL 8. واجهة عربية RTL متجاوبة، لوحة تحكم لحظية، وإرسال الطلبات عبر واتساب (07729157500).

## الهيكل
```
server.js        الخادم وواجهات API (استعلامات مُعدّة، helmet، تحديد المعدل، JWT)
seed.js          إنشاء حساب المدير
schema.sql       قاعدة البيانات
public/          index.html (المتجر) · admin.html (اللوحة) · style.css · app.js · admin.js
.env.example     نموذج الإعدادات
```

## التثبيت (Windows 11)
1. ثبّت Node.js 20+ و MySQL 8.
2. `mysql -u root -p < schema.sql`
3. `copy .env.example .env` ثم عبّئ: بيانات MySQL، و`JWT_SECRET` (الأمر مكتوب داخل الملف)، و`ADMIN_PASS` (10 أحرف+).
4. `npm install`
5. `npm run seed` ثم `npm start`
6. المتجر: http://localhost:3000 — اللوحة: http://localhost:3000/admin.html

## الاستخدام
- أضف المنتجات من تبويب "المنتجات". اختر `authenticity` بدقة: "بديل مستقل" يظهر للزبون بشارة "غير تابع لأي ماركة" ولا يُعرض عليه اسم ماركة أصلية.
- الطلب الجديد يظهر في اللوحة خلال 10 ثوانٍ؛ غيّر حالته وأرسل رسالة جاهزة للزبون بزر واتساب.
- المدير: كل الصلاحيات والأرباح. الموظف: الطلبات فقط. لإضافة موظف: `INSERT INTO users(username,password_hash,role)` بتجزئة bcrypt.
- تبويب "الأرباح والمنافسون": أدخل أسعار المنافسين التي تلاحظها يدوياً لترى الفرق مع أسعارك، وسجّل فجوات السوق.

## الأمان
استعلامات `?` مُعدّة (ضد SQL Injection) · bcrypt · JWT في كوكي httpOnly + SameSite=Strict · CSP · حد محاولات الدخول · سعر الشراء لا يخرج من API العام · الأسعار والمخزون تُحسب في الخادم.
عند النشر: `NODE_ENV=production` خلف HTTPS (Nginx/Caddy).

require('dotenv').config();
const mysql=require('mysql2/promise'),bcrypt=require('bcryptjs');
(async()=>{
  const {ADMIN_USER:u,ADMIN_PASS:p}=process.env;
  if(!u||!p||p.length<10){console.error('ضع ADMIN_USER و ADMIN_PASS (10 أحرف+) في .env');process.exit(1)}
  const db=await mysql.createConnection({host:process.env.DB_HOST,user:process.env.DB_USER,password:process.env.DB_PASSWORD,database:process.env.DB_NAME});
  await db.execute("INSERT INTO users(username,password_hash,role) VALUES(?,?, 'admin') ON DUPLICATE KEY UPDATE password_hash=VALUES(password_hash)",[u,await bcrypt.hash(p,12)]);
  console.log('تم إنشاء/تحديث المدير:',u);await db.end();
})();

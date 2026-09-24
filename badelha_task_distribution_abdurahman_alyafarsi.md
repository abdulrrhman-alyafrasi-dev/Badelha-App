# 📋 دليل التكليف والمستند الخطي: الطالب عبدالرحمن اليفرسي
**مشروع منصة بدلها الذكية للمقايضة | BADELHA Engine**
* **الصفة في الفريق**: مسؤول الفريق (Team Lead) + مراجع الكود ومسؤول المستودع (Repository Maintainer & Code Reviewer)
* **المسار البرمجي المخصص**: التوثيق، الحسابات الشخصية، لوحة الإشراف الإدارية والمتاجر (Auth, Users, Stores & Admin Dashboard)

---

## 🎯 1. نظرة عامة على التكليف وتوصيف الميزة (Module Description)
يتولى الطالب **عبدالرحمن اليفرسي** إنشاء وتجهيز مستودع المشروع، وتفعيل قواعد حماية الفرع الرئيسي `main` على GitHub، بالإضافة إلى تطوير طبقة التوثيق والمستخدمين والمتاجر ولوحة الإشراف الإدارية الشاملة في خادم لارافل 13 وتطبيق فلاتر.

---

## 📌 2. بيانات الـ GitHub الخاصة بالتكليف
* **عنوان الـ Issue على GitHub**:
  `[FEAT] Implement Sanctum Authentication, User Profiles, Commercial Stores & Admin Dashboard`
* **اسم الفرع الخاص بالمهمة (Branch Name)**:
  `feature/auth-admin-stores`
* **صياغة رسالة طلب الدمج (Pull Request Title)**:
  `PR #1: Implement Sanctum Auth, User Management, Commercial Stores & Admin Dashboard`

---

## 💻 3. الملفات البرمجية المسندة لـ عبدالرحمن اليفرسي

### 🅰️ خادم الباك إند (Laravel 13 REST API):
1. `app/Http/Controllers/Api/AuthController.php` (تسجيل الحساب والدخول وتحديث البروفايل)
2. `app/Http/Controllers/Api/AdminDashboardController.php` (إحصائيات المنصة وحظر وتفعيل الحسابات)
3. `app/Http/Controllers/Api/StoreController.php` (إدارة المتاجر المعتمدة)
4. `app/Services/AuthService.php` (منطق تشفير الباسورد وإنشاء الحسابات)
5. `app/Http/Requests/RegisterRequest.php` & `LoginRequest.php` (قواعد فحص المدخلات)
6. `app/Http/Resources/UserResource.php`, `StoreResource.php`, `AdminBannerResource.php` (تنسيق مخرجات JSON)
7. `app/Http/Middleware/EnsureUserIsActive.php` (منع الحسابات المحظورة)

### 🅱️ تطبيق الهاتف (Flutter Client):
1. `lib/presentation/screens/auth/login_screen.dart` (شاشة تسجيل الدخول والحسابات الجاهزة)
2. `lib/presentation/screens/admin/admin_dashboard_screen.dart` (لوحة تحكم الأدمين والرقابة)
3. `lib/presentation/screens/merchant/store_dashboard_screen.dart` (لوحة التاجر)
4. `lib/presentation/providers/auth_provider.dart` (إدارة حالة المستخدمين والتسجيل)
5. `lib/presentation/providers/banner_provider.dart` (إدارة الشريط الإعلاني الترويجي)

---

## 🔄 4. خطوات دورة العمل التساعية (Git Workflow Steps)

### الخطوة 1: فتح الـ Issue
إنشاء `Issue #1` على GitHub وتحديد المتطلبات المسندة.

### الخطوة 2: إنشاء الفرع المحلي
```bash
git checkout main
git pull origin main
git checkout -b feature/auth-admin-stores
```

### الخطوة 3: التعديل والبرمجة
تطوير كود الدخول والتسجيل ولوحة التحكم والـ Audit Logs.

### الخطوة 4: حفظ التغييرات (Commit)
```bash
git add .
git commit -m "feat(auth-admin): implement sanctum auth, admin stats dashboard and store controls"
```

### الخطوة 5: رفع الفرع إلى GitHub (Push)
```bash
git push -u origin feature/auth-admin-stores
```

### الخطوة 6: إنشاء Pull Request (PR)
فتح `PR #1` من `feature/auth-admin-stores` إلى `main` مع كتابة الوصف الخطي `Closes #1`.

### الخطوة 7: المراجعة واختبار الأمان (Review)
مراجعة الكود وإجراء الفحص للتأكد من حماية المسارات بـ `auth:sanctum`.

### الخطوة 8 & 9: الدمج وإغلاق الـ Issue
قبول الدمج في فرع `main` وإغلاق الـ Issue #1.

---

## 🔍 5. المسؤولية القيادية الميدانية لـ عبدالرحمن اليفرسي
* استقبال طلبات الدمج (PRs) القادمة من زميليه **سلطان العمراني** و **سيف صياد**.
* فحص الأكواد والتأكد من عدم وجود تعارضات (Merge Conflicts) ثم اعتماد الدمج إلى `main`.

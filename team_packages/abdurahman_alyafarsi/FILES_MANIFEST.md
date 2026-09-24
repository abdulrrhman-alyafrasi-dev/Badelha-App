# 📂 بيان وقائمة الملفات البرمجية: الطالب عبدالرحمن اليفرسي (خطة الطالبين 50/50)
**مشروع منصة بدلها الذكية للمقايضة | BADELHA Engine**

---

## 🅰️ ملفات الباك إند (Laravel 13 REST API)

| # | مسار الملف البرمجي (Backend File Path) | الوظيفة والدور الفني |
|---|---|---|
| 1 | `backend/app/Http/Controllers/Api/AuthController.php` | متحكم التسجيل والدخول والبروفايل والجلسات |
| 2 | `backend/app/Http/Controllers/Api/AdminDashboardController.php` | متحكم لوحة التحكم وإحصائيات المنصة والحظر |
| 3 | `backend/app/Http/Controllers/Api/StoreController.php` | متحكم إدارة المتاجر المعتمدة |
| 4 | `backend/app/Http/Controllers/Api/SwapOfferController.php` | متحكم إنشاء وعروض صفقات المقايضة بين المستخدمين |
| 5 | `backend/app/Services/AuthService.php` | خدمة تشفير كلمة المرور وإنشاء التوكنات والـ Logic |
| 6 | `backend/app/Http/Requests/RegisterRequest.php` | قواعد التحقق من مدخلات التسجيل والقيود |
| 7 | `backend/app/Http/Requests/LoginRequest.php` | قواعد التحقق من رقم الهاتف أو البريد والباسورد |
| 8 | `backend/app/Http/Requests/StoreSwapOfferRequest.php` | قواعد التحقق من حقول عرض المقايضة والفرق المالي |
| 9 | `backend/app/Http/Resources/UserResource.php` | تنسيق بيانات المستخدم بصيغة JSON آمنة |
| 10 | `backend/app/Http/Resources/StoreResource.php` | تنسيق مخرجات بيانات المتاجر المعتمدة |
| 11 | `backend/app/Http/Resources/SwapOfferResource.php` | تنسيق مخرجات بيانات صفقات المقايضة والتبادل |
| 12 | `backend/app/Http/Resources/AdminBannerResource.php` | تنسيق بيانات الشريط الإعلاني الترويجي |
| 13 | `backend/app/Http/Middleware/EnsureUserIsActive.php` | ميدلوير فحص الحظر والأمان للأدمين والمستخدمين |
| 14 | `backend/app/Models/User.php` | نموذج المستخدم وقواعد الصلاحيات والعلاقات |
| 15 | `backend/app/Models/Store.php` | نموذج المتاجر التجارية المعتمدة |
| 16 | `backend/app/Models/SwapOffer.php` | نموذج صفقات التبادل وعلاقات الطرفين |

---

## 🅱️ ملفات تطبيق الهاتف (Flutter Client)

| # | مسار الملف البرمجي (Flutter File Path) | الوظيفة والدور الفني |
|---|---|---|
| 1 | `lib/presentation/screens/auth/login_screen.dart` | شاشة تسجيل الدخول والحسابات التجريبية الجاهزة |
| 2 | `lib/presentation/screens/admin/admin_dashboard_screen.dart` | لوحة تحكم الأدمين والرقابة الشاملة وإدارة الحسابات |
| 3 | `lib/presentation/screens/merchant/store_dashboard_screen.dart` | شاشة لوحة التحكم الخاصة بالمتاجر والتاجر |
| 4 | `lib/presentation/screens/offers/offers_screen.dart` | شاشة إدارة وتتبع عروض المقايضة الواردة والصادرة |
| 5 | `lib/presentation/providers/auth_provider.dart` | مزود حالة التوثيق وحفظ الجلسات محلياً |
| 6 | `lib/presentation/providers/swap_provider.dart` | مزود حالة إرسال واستجابة عروض التبادل |
| 7 | `lib/presentation/providers/banner_provider.dart` | مزود حالة السلايدر والإعلانات الترويجية |
| 8 | `lib/presentation/screens/admin/admin_banner_management_screen.dart` | شاشة التحكم وإضافة الإعلانات الشريطية |
| 9 | `lib/data/repositories/swap_repository.dart` | مستودع بيانات عروض المقايضة وتحديث الربط بالـ LEFT JOIN |

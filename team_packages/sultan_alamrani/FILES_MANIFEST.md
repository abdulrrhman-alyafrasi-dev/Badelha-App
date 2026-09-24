# 📂 بيان وقائمة الملفات البرمجية: الطالب سلطان العمراني (خطة الطالبين 50/50)
**مشروع منصة بدلها الذكية للمقايضة | BADELHA Engine**

---

## 🅰️ ملفات الباك إند (Laravel 13 REST API)

| # | مسار الملف البرمجي (Backend File Path) | الوظيفة والدور الفني |
|---|---|---|
| 1 | `backend/app/Http/Controllers/Api/ItemController.php` | متحكم إضافة، جلب، وتعديل وحذف المنتجات واستدعاء المحركات |
| 2 | `backend/app/Http/Controllers/Api/CategoryController.php` | متحكم قائمة الأقسام والتصنيفات والأيقونات |
| 3 | `backend/app/Http/Controllers/Api/RatingController.php` | متحكم حفظ التقييمات والتعليقات المتبادلة |
| 4 | `backend/app/Http/Controllers/Api/NotificationController.php` | متحكم إرسال وإدارة حالة الإشعارات المباشرة |
| 5 | `backend/app/Services/ItemService.php` | خدمة منطق تصفية وفلترة المنتجات المسترجعة والاستعلامات |
| 6 | `backend/app/Services/MatchingService.php` | محرك المطابقة الخماسي الحسابي الموزون |
| 7 | `backend/app/Services/CircularSwapService.php` | محرك اكتشاف المقايضات الثلاثية الدائرية (A -> B -> C -> A) |
| 8 | `backend/app/Services/TrustService.php` | خدمة حساب درجات الثقة والسمعة والتقييمات |
| 9 | `backend/app/Http/Requests/StoreItemRequest.php` | قواعد التحقق من حقول إضافة السلعة والقيمة التقديرية |
| 10 | `backend/app/Http/Requests/UpdateItemRequest.php` | قواعد التحقق من تحديث السلعة الحالية |
| 11 | `backend/app/Http/Resources/ItemResource.php` | تنسيق مخرجات بيانات المنتج بصيغة JSON آمنة |
| 12 | `backend/app/Http/Resources/CategoryResource.php` | تنسيق مخرجات الأقسام والتصنيفات |
| 13 | `backend/app/Http/Resources/NotificationResource.php` | تنسيق مخرجات التنبيهات والإشعارات الفورية |
| 14 | `backend/app/Traits/HasIdempotencyCheck.php` | حماية منع تقديم السلع المكررة في التزامن الشبكي |
| 15 | `backend/app/Traits/HasOwnershipCheck.php` | حماية التحقق من ملكية المستخدم للسلعة قبل الحذف/التعديل |
| 16 | `backend/app/Models/Item.php` | نموذج المنتجات المعروضة والعلاقات بالمالك والقسم |
| 17 | `backend/app/Models/Category.php` | نموذج تصنيفات وأقسام السلع والمقايضة |
| 18 | `backend/app/Models/Notification.php` | نموذج التنبيهات والإشعارات الفورية |
| 19 | `backend/app/Models/Rating.php` | نموذج التقييمات النجمية للشركاء |

---

## 🅱️ ملفات تطبيق الهاتف (Flutter Client)

| # | مسار الملف البرمجي (Flutter File Path) | الوظيفة والدور الفني |
|---|---|---|
| 1 | `lib/presentation/screens/marketplace/marketplace_screen.dart` | الشاشة الرئيسية لسوق المقايضة وقوائم المنتجات |
| 2 | `lib/presentation/screens/item_details/item_details_screen.dart` | شاشة المعاينة الكاملة وتفاصيل السلعة والاتصال بالمالك |
| 3 | `lib/presentation/screens/add_item/add_item_screen.dart` | شاشة إضافة وتعديل سلعة جديدة للمقايضة |
| 4 | `lib/presentation/screens/search/search_filter_screen.dart` | شاشة البحث الدلالي والفلترة المتقدمة |
| 5 | `lib/presentation/screens/matching/smart_matches_screen.dart` | شاشة المطابقات الذكية التفاعلية |
| 6 | `lib/presentation/screens/circular_swap/circular_swap_screen.dart` | شاشة كشف وعرض التبادلات الثلاثية |
| 7 | `lib/presentation/providers/marketplace_provider.dart` | مزود حالة سوق المنتجات والفلترة والتنشيط |
| 8 | `lib/presentation/providers/matching_provider.dart` | مزود حالة محرك المطابقة الذكي |
| 9 | `lib/presentation/providers/notification_provider.dart` | مزود حالة الإشعارات والمنبهات |
| 10 | `lib/data/repositories/marketplace_repository.dart` | مستودع التزامن والكاش المحلي لبيانات السلع |
| 11 | `lib/data/database/seed_data.dart` | التلقيم التأسيسي الأولي للمنتجات والأقسام |

# ⚖️ التوزيع المتوازن والعادل لمهام الفريق (عبدالرحمن وسلطان)

---

## 📊 نسبة توزيع المشروع: 50% / 50% بالعدل والتساوي التام

تم تقسيم مشروع منصة **بَدِّلْهَا (BADELHA)** بين الطالبين بمساواة تامة وحجم عمل متكافئ في البرمجيات (Flutter & Laravel) وقواعد البيانات:

---

### 👤 1. النطاق البرمجي لعبدالرحمن اليفرسي (50% من المشروع)
**المجال:** البنية التحتية، المصادقة، إدارة المنتجات والسوق، ولوحة التاجر والمدير.

#### 📁 ملفات ومكعبات الكود:
* **Flutter (Frontend):**
  - `lib/presentation/screens/auth/` (شاشة وتسجيل الدخول والتسجيل)
  - `lib/presentation/screens/marketplace/` (السوق وشبكة عرض السلع)
  - `lib/presentation/screens/add_item/` (إضافة منتج وتحويل الصور لـ Base64)
  - `lib/presentation/screens/explore/` (شاشة الاستكشاف والبحث)
  - `lib/presentation/screens/shell/` (الشريط السفلي والتنقل بالسحب `PageView`)
  - `lib/presentation/screens/admin/` & `merchant/` (لوحة الإدارة والتاجر)
  - `lib/data/services/api_client.dart` (الاتصال المزدوج PostgreSQL & SQLite)

* **Laravel 13 (Backend):**
  - `backend/app/Services/AuthService.php`
  - `backend/app/Services/ItemService.php`
  - `backend/app/Http/Controllers/Api/AuthController.php`
  - `backend/app/Http/Controllers/Api/ItemController.php`

---

### 👤 2. النطاق البرمجي لسلطان العمراني (50% من المشروع)
**المجال:** محرك المطابقة الذكية، نظام العروض والمقايضات المباشرة والدائرية، ونظام الثقة والأمان.

#### 📁 ملفات ومكعبات الكود:
* **Flutter (Frontend):**
  - `lib/presentation/screens/matching/` (شاشة المطابقات الذكية وحساب التوافق %)
  - `lib/presentation/screens/circular_swap/` (شاشة المقايضة الدائرية والتبادل الثلاثي)
  - `lib/presentation/screens/offers/` (شاشة إدارة وتتبع العروض المقدمة والمستلمة)
  - `lib/presentation/screens/item_details/widgets/make_offer_modal.dart` (مودال تقديم عروض المقايضة)
  - `lib/presentation/widgets/swap_safety_dialog.dart` (نافذة أمان وضمان المقايضة)
  - `lib/presentation/providers/matching_provider.dart` (مزود حالات المقايضة والمطابقة)

* **Laravel 13 (Backend):**
  - `backend/app/Services/MatchingService.php` (خوارزمية حساب المطابقة)
  - `backend/app/Services/CircularSwapService.php` (خوارزمية التبادل الدائري A->B->C->A)
  - `backend/app/Services/TrustService.php` (نظام احتساب تقييم وسجل الثقة ⭐)
  - `backend/app/Http/Controllers/Api/MatchingController.php`
  - `backend/app/Http/Controllers/Api/CircularSwapController.php`
  - `backend/app/Http/Controllers/Api/SwapController.php`

# 📝 التقرير الوصفي الشامل لمهام الطالب: سلطان العمراني
**مشروع منصة بدلها الذكية للمقايضة | BADELHA Engine (فريق من طالبين 50/50)**

---

## 🏛️ 1. الوصف الهندسي والمعماري للمسار البرمجي
يتولى الطالب **سلطان العمراني** نصف كود المشروع بالكامل، والذي يشمل مسار سوق المنتجات والسلع (Marketplace Items)، التصنيفات الأقسام، محرك المطابقة الذكي الخماسي (5-Criteria Matching Engine)، محرك المقايضة الثلاثية الدائرية (3-Way Circular Swaps Graph)، محرك حساب درجة الثقة والسمعة (Trust & Reputation Calculator)، والتزامن الحقيقي المزدوج بين **PostgreSQL 18** و **SQLite Cache**.

---

## 🛠️ 2. مكونات كود الباك إند (Laravel 13 REST API)

### 1️⃣ `ItemController.php` & `ItemService.php`
* **إدارة السلع وتصفية الفلاتر**: عرض المنتجات المتاحة، إضافة سلعة جديدة مع تطبيق منع التكرار `HasIdempotencyCheck` والتحقق من الملكية `HasOwnershipCheck` واستبعاد استعلام الكلمة الشاملة `"الكل"`.

### 2️⃣ `MatchingService.php` (محرك المطابقة الخماسي الموزون)
* حساب نسبة التوافق بين السلع عبر 5 أوزان معيارية:
$$\text{Total Score} = (0.30 \times C) + (0.25 \times V) + (0.15 \times K) + (0.15 \times G) + (0.15 \times T)$$

### 3️⃣ `CircularSwapService.php` & `TrustService.php`
* كشف خوارزمية حلقات التبادل المغلقة ($A \rightarrow B \rightarrow C \rightarrow A$) وإعادة حساب درجة الثقة والتقييمات النجمية للمستخدمين.

### 4️⃣ `CategoryController.php`, `RatingController.php`, `NotificationController.php`
* قائمة الأقسام والتصنيفات، التقييمات التبادلية، وتنبيهات الإشعارات الفورية.

---

## 📱 3. مكونات كود تطبيق الهاتف (Flutter Client)

### 1️⃣ `marketplace_screen.dart`, `item_details_screen.dart`, `add_item_screen.dart`
* الشاشة الرئيسية لسوق المقايضة، معاينة تفاصيل السلعة والاتصال المباشر بالمالك، وشاشة إدخال السلعة والكمية الحرة.

### 2️⃣ `search_filter_screen.dart`, `smart_matches_screen.dart`, `circular_swap_screen.dart`
* البحث الدلالي الذكي، عرض المطابقات النسبة التوافقية، والتنقل بين عروض المقايضة الدائرية.

### 3️⃣ `marketplace_provider.dart`, `matching_provider.dart`, `notification_provider.dart`, `marketplace_repository.dart`
* مزودات حالة المنتجات والفلترة، التوافقات الذكية، والإشعارات مع حفظ السلع القادمة من PostgreSQL محلياً داخل `items` بـ SQLite.

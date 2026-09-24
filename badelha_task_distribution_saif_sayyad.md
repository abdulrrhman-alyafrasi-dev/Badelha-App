# 📋 دليل التكليف والمستند الخطي: الطالب سيف صياد
**مشروع منصة بدلها الذكية للمقايضة | BADELHA Engine**
* **الصفة في الفريق**: عضو فريق (Team Member) + مهندس محركات الذكاء والمطابقة عروض المقايضة (Barter Engines, Swaps & Trust Specialist)
* **المسار البرمجي المخصص**: محرك المطابقة الخماسي، التبادل الثلاثي الدائري، صفقات المقايضة، ميثاق الأمان، ونقاط الثقة (Matching Engine, Circular Swaps, Swap Offers & Trust Calculator)

---

## 🎯 1. نظرة عامة على التكليف وتوصيف الميزة (Module Description)
يتولى الطالب **سيف صياد** تطوير القلب النابض للمنصة، والذي يشمل خوارزميات الذكاء الرياضي والمطابقة، كشف حلقات المقايضة الثلاثية المعقدة، إدارة جميع مراحل عروض المقايضة بين المستخدمين، تطبيق ميثاق الأمان، وإعادة حساب درجة الثقة والتقييم التبادلي.

---

## 📌 2. بيانات الـ GitHub الخاصة بالتكليف
* **عنوان الـ Issue على GitHub**:
  `[FEAT] Implement 5-Criteria Matching Engine, 3-Way Circular Swaps, Safety Protocol & Trust Calculator`
* **اسم الفرع الخاص بالمهمة (Branch Name)**:
  `feature/matching-swaps-trust`
* **صياغة رسالة طلب الدمج (Pull Request Title)**:
  `PR #3: Implement 5-Criteria Matching Engine, 3-Way Circular Swaps, Safety Protocol & Trust Calculator`

---

## 💻 3. الملفات البرمجية المسندة لـ سيف صياد

### 🅰️ خادم الباك إند (Laravel 13 REST API):
1. `app/Services/MatchingService.php` (محرك المطابقة الخماسي: 30% فئة، 25% قيمة، 15% حالة، 15% موقع، 15% ثقة)
2. `app/Services/CircularSwapService.php` (محرك التبادل الثلاثي المغلق $A \rightarrow B \rightarrow C \rightarrow A$)
3. `app/Services/TrustService.php` (محرك حساب درجة الثقة والسمعة)
4. `app/Http/Controllers/Api/SwapOfferController.php` (إدارة دورة حياة عروض المقايضة وميثاق الأمان)
5. `app/Http/Controllers/Api/RatingController.php` & `NotificationController.php` (التقييمات والإشعارات)
6. `app/Http/Requests/StoreSwapOfferRequest.php` (التحقق من حقول المقايضة والفرق المالي)
7. `app/Http/Resources/SwapOfferResource.php` & `NotificationResource.php` (تنسيق العروض والإشعارات)

### 🅱️ تطبيق الهاتف (Flutter Client):
1. `lib/presentation/screens/matching/smart_matches_screen.dart` (شاشة عروض المطابقة الذكية)
2. `lib/presentation/screens/circular_swap/circular_swap_screen.dart` (شاشة التبادل الثلاثي)
3. `lib/presentation/screens/offers/offers_screen.dart` (شاشة إدارة الصفقات الواردة والصادرة)
4. `lib/presentation/providers/matching_provider.dart` & `swap_provider.dart` & `notification_provider.dart`
5. `lib/data/repositories/swap_repository.dart` (تعديل استعلامات الربط المزدوج لعدم اختفاء أي عرض)

---

## 🔄 4. خطوات دورة العمل التساعية (Git Workflow Steps)

### الخطوة 1: فتح الـ Issue
إنشاء `Issue #3` على GitHub وتحديد المتطلبات المسندة.

### الخطوة 2: إنشاء الفرع المحلي
```bash
git checkout main
git pull origin main
git checkout -b feature/matching-swaps-trust
```

### الخطوة 3: التعديل والبرمجة
كتابة معادلة الأوزان الخماسية، خوارزمية الحلقة الثلاثية، شاشات العروض، وحاسبة نقاط الثقة.

### الخطوة 4: حفظ التغييرات (Commit)
```bash
git add .
git commit -m "feat(matching-swaps): implement 5-criteria matching, circular swap graph and safety protocol"
```

### الخطوة 5: رفع الفرع إلى GitHub (Push)
```bash
git push -u origin feature/matching-swaps-trust
```

### الخطوة 6: إنشاء Pull Request (PR)
فتح `PR #3` موجه لفرع `main` وإسناده لمسؤول الفريق **عبدالرحمن اليفرسي** لمراجعته، مع كتابة `Closes #3`.

### الخطوة 7: المراجعة واختبار الجودة (Review)
يقوم مراجع المشروع **عبدالرحمن اليفرسي** بمراجعة خوارزميات المطابقة والتأكد من تحول حالة السلع إلى `swapped`.

### الخطوة 8 & 9: الدمج وإغلاق الـ Issue
قبول الدمج في فرع `main` وإغلاق الـ Issue #3.

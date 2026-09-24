# 📋 دليل التكليف والمستند الخطي: الطالب سلطان العمراني
**مشروع منصة بدلها الذكية للمقايضة | BADELHA Engine**
* **الصفة في الفريق**: عضو فريق (Team Member) + مهندس سوق السلع والكتالوج والبحث (Marketplace & Search Engine Developer)
* **المسار البرمجي المخصص**: سوق المنتجات، التصنيفات، البحث الدلالي، والتزامن الأوفلاين (Items CRUD, Categories Catalog, Search & Offline Cache)

---

## 🎯 1. نظرة عامة على التكليف وتوصيف الميزة (Module Description)
يتولى الطالب **سلطان العمراني** تطوير وإدارة مسار السلع والمنتجات والمعروضات، الأقسام والتصنيفات، محرك البحث الدلالي، ومعالجة الربط بين الخادم وقاعدة البيانات المحلية **SQLite Cache** لضمان عدم اختفاء أي سلعة وعلاج استعلامات الفلترة الشاملة `"الكل"`.

---

## 📌 2. بيانات الـ GitHub الخاصة بالتكليف
* **عنوان الـ Issue على GitHub**:
  `[FEAT] Build Marketplace Items CRUD, Category Catalog, Semantic Search & Offline Cache`
* **اسم الفرع الخاص بالمهمة (Branch Name)**:
  `feature/marketplace-items-search`
* **صياغة رسالة طلب الدمج (Pull Request Title)**:
  `PR #2: Build Marketplace Items CRUD, Category Catalog, Semantic Search & Offline Cache`

---

## 💻 3. الملفات البرمجية المسندة لـ سلطان العمراني

### 🅰️ خادم الباك إند (Laravel 13 REST API):
1. `app/Http/Controllers/Api/ItemController.php` (إدارة عمليات السلع والمنتجات)
2. `app/Http/Controllers/Api/CategoryController.php` (قائمة الأقسام الرئيسية والفرعية)
3. `app/Services/ItemService.php` (منطق تصفية وفلترة المنتجات المسترجعة من PostgreSQL)
4. `app/Http/Requests/StoreItemRequest.php` & `UpdateItemRequest.php` (التحقق من حقول السعر والحالة)
5. `app/Http/Resources/ItemResource.php` & `CategoryResource.php` (تنسيق مخرجات السلع والأقسام)
6. `app/Traits/HasIdempotencyCheck.php` & `HasOwnershipCheck.php` (منع التكرار والتحقق من الملكية)

### 🅱️ تطبيق الهاتف (Flutter Client):
1. `lib/presentation/screens/marketplace/marketplace_screen.dart` (الشاشة الرئيسية لعرض السلع والشرائح)
2. `lib/presentation/screens/item_details/item_details_screen.dart` (شاشة تفاصيل السلعة)
3. `lib/presentation/screens/add_item/add_item_screen.dart` (شاشة إضافة وتحديث السلعة)
4. `lib/presentation/screens/search/search_filter_screen.dart` (البحث الذكي الدلالي والفلترة)
5. `lib/presentation/providers/marketplace_provider.dart` (إدارة حالة المنتجات والفلاتر)
6. `lib/data/repositories/marketplace_repository.dart` & `seed_data.dart` (معالجة مزامنة الكاش المحلي)

---

## 🔄 4. خطوات دورة العمل التساعية (Git Workflow Steps)

### الخطوة 1: فتح الـ Issue
إنشاء `Issue #2` على GitHub وتحديد المتطلبات المسندة.

### الخطوة 2: إنشاء الفرع المحلي
```bash
git checkout main
git pull origin main
git checkout -b feature/marketplace-items-search
```

### الخطوة 3: التعديل والبرمجة
تطوير كود إضافة وجلب السلع وتصفية فلترة `"الكل"` والتزامن المزدوج مع SQLite.

### الخطوة 4: حفظ التغييرات (Commit)
```bash
git add .
git commit -m "feat(items-search): implement items CRUD, category catalog and resolve all-filter query"
```

### الخطوة 5: رفع الفرع إلى GitHub (Push)
```bash
git push -u origin feature/marketplace-items-search
```

### الخطوة 6: إنشاء Pull Request (PR)
فتح `PR #2` موجه لفرع `main` وإسناده لمسؤول الفريق **عبدالرحمن اليفرسي** لمراجعته، مع كتابة `Closes #2`.

### الخطوة 7: المراجعة وااختبار الجودة (Review)
يقوم مراجع المشروع **عبدالرحمن اليفرسي** بمراجعة الأكواد واختبار جلب المنتجات أوفلاين وأونلاين.

### الخطوة 8 & 9: الدمج وإغلاق الـ Issue
قبول الدمج في فرع `main` وإغلاق الـ Issue #2.

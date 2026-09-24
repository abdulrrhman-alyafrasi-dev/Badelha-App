# BADELHA | بَدِّلْهَا

## Flutter (SQLite) → Laravel 13 REST API → PostgreSQL

---

# 1. الدور المطلوب منك

أنت تعمل الآن بصفتك فريقًا هندسيًا متكاملًا، وليس مجرد مولّد كود، وتتولى تنفيذ المشروع فعليًا من البداية إلى التحقق النهائي.

تقمص الأدوار التالية في الوقت نفسه:

* **Senior Software Architect** بخبرة +12 سنة في أنظمة Marketplace.
* **Laravel Backend Architect** متخصص تحديدًا في **Laravel 13**، وليس إصدارات أقدم، ومتمكن من:

  * SOLID
  * Clean Code
  * Service Layer
  * Form Requests
  * API Resources
  * Policies
  * Events / Listeners
  * Jobs / Queues
  * Sanctum
  * Caching
  * Rate Limiting
* **PostgreSQL Database Architect** متخصص في:

  * تصميم قواعد البيانات عالية الأداء.
  * Indexing Strategy.
  * Query Planning.
  * EXPLAIN / EXPLAIN ANALYZE.
  * Normalization المتزن دون إفراط.
  * PostgreSQL Native Features.
* **Flutter Architect** يحافظ على المشروع الحالي ولا يعيد اختراعه.
* **Performance Engineer** مسؤول عن تقليل زمن الاستجابة والاستعلامات غير الضرورية.
* **Security Engineer** مسؤول عن Authentication وAuthorization وRBAC وحماية البيانات.
* **Migration Engineer** مسؤول عن ترحيل البيانات من SQLite إلى PostgreSQL بدون فقد أو تشويه.
* **QA Engineer** مسؤول عن الاختبارات والتحقق الفعلي.
* **Technical Documentation Engineer** مسؤول عن إعداد التقرير النهائي العربي الدقيق.

## معيار جودة العمل

الكود يجب أن يكون:

* احترافيًا.
* نظيفًا.
* بسيطًا قدر الإمكان دون تبسيط مخل.
* قابلًا للصيانة.
* قابلًا للتوسع.
* سريع الاستجابة.
* آمنًا.
* واضح البنية.
* خاليًا من الطبقات التجريدية الزائدة التي لا تستخدم فعليًا.

**ممنوع إضافة تعقيد معماري لمجرد أن "المشروع احترافي".**

إذا كانت طبقة معينة غير ضرورية فعليًا، فلا تنشئها.

---

# 2. 🧱 المهمة الأساسية

المطلوب تنفيذ ترحيل المعمارية الحالية من:

```text
Flutter
   ↓
SQLite
```

إلى:

```text
Flutter App
   │
   ├── Remote Data Source
   │        ↓
   │       Dio
   │        ↓
   │   Laravel 13 REST API
   │        ↓
   │   PostgreSQL
   │
   └── Local Cache
            ↓
          SQLite
       Offline Only
```

بحيث تصبح:

> **PostgreSQL هي مصدر الحقيقة المركزي Source of Truth.**

ويكون:

> **Laravel 13 هو طبقة API والأعمال والأمان.**

ويكون:

> **SQLite مجرد Local Cache / Offline Layer وليس مصدر البيانات الأساسي.**

---

# 3. 🚨 القاعدة الذهبية غير القابلة للتفاوض

## لا تعِد بناء التطبيق من الصفر.

يجب الحفاظ على المشروع الحالي قدر الإمكان.

ممنوع:

* إعادة تصميم UI/UX.
* تغيير الهوية البصرية.
* تغيير الألوان.
* تغيير خط Cairo.
* تغيير الشعار.
* تغيير شكل البطاقات.
* حذف Animations.
* حذف أي Feature موجود فعليًا.
* حذف أي Algorithm موجود فعليًا.
* استبدال المنطق الموجود بمنطق أبسط لمجرد تسهيل الترحيل.
* تغيير سلوك التطبيق الحالي دون سبب موثق.

خصوصًا:

```text
matching_engine.dart
circular_swap_engine.dart
semantic_search_engine.dart
trust_calculator.dart
```

**لا تستبدل هذه المحركات بمنطق مبسط.**

المطلوب:

> نقل المنطق والحسابات والمحافظة على النتائج، وليس اختصارها.

---

# 4. ⚠️ قاعدة الحقيقة المطلقة

لا تفترض وجود:

* جدول.
* حقل.
* Model.
* Feature.
* Endpoint.
* Relation.
* Query.
* Algorithm.

إذا لم يكن مثبتًا فعليًا في الكود.

القاعدة:

> **الكود الفعلي هو الحقيقة المطلقة.**

أما:

* التقرير.
* هذا البرومبت.
* المخططات النظرية.
* التصورات السابقة.

فهي مراجع توجيهية فقط.

إذا وجدت تعارضًا بين التقرير والكود:

> اتبع الكود الفعلي.

---

# 5. 🔍 المرحلة 0 — الفحص الإجباري

## ممنوع كتابة أو تعديل أي كود قبل إكمال هذه المرحلة.

افحص المشروع فعليًا وبالترتيب التالي:

### 5.1 pubspec.yaml

استخرج:

* Dart SDK.
* Flutter version compatibility.
* Provider.
* Dio إن وجد.
* SQLite package.
* Shared Preferences.
* flutter_secure_storage إن وجد.
* أي Package أخرى مؤثرة.

لا تفترض إصدارات الحزم.

---

### 5.2 قاعدة البيانات الحالية

افحص:

```text
lib/data/database/app_database.dart
```

واستخرج حرفيًا:

* كل CREATE TABLE.
* كل Table.
* كل Column.
* كل Type.
* Primary Keys.
* Foreign Keys.
* Defaults.
* Nullable / NOT NULL.
* Indexes.
* CREATE INDEX.
* العلاقات.
* أي Triggers.
* أي Constraints.
* أي Views إن وجدت.

---

### 5.3 Models

افحص:

```text
lib/data/models/*.dart
```

وطابق كل Model مع الجدول المقابل له **سطرًا بسطر**.

حدد:

* الحقول الموجودة في Model وغير الموجودة في SQLite.
* الحقول الموجودة في SQLite وغير الموجودة في Model.
* أنواع البيانات.
* العلاقات.
* Serialization.
* IDs.
* أي حقول مشتقة.
* أي JSON مخزن داخل TEXT.
* أي Lists مخزنة كنصوص.

---

### 5.4 MarketplaceRepository

افحص:

```text
lib/data/repositories/marketplace_repository.dart
```

واستخرج جميع الاستعلامات SQL الفعلية.

خصوصًا:

* SELECT.
* INSERT.
* UPDATE.
* DELETE.
* JOIN.
* WHERE.
* ORDER BY.
* GROUP BY.
* LIKE.
* Filters.
* Search.
* Pagination.
* Queries الخاصة بالمطابقة.
* Queries الخاصة بالعروض.
* Queries الخاصة بالإشعارات.

هذه الاستعلامات هي المرجع الحقيقي لبناء:

* PostgreSQL indexes.
* API Endpoints.
* Services.

**ممنوع إنشاء Index لأنك تعتقد أنه مفيد دون وجود Query فعلي يخدمه.**

---

### 5.5 Domain Services

افحص:

```text
lib/domain/services/*.dart
```

وافهم بدقة:

* Matching Engine.
* Circular Swap Engine.
* Semantic Search Engine.
* Trust Calculator.
* أي Business Logic آخر.

استخرج:

* الأوزان.
* المعادلات.
* الشروط.
* حدود القيم.
* حالات التوقف.
* ترتيب العمليات.
* النتائج.

لا تغير المنطق أثناء نقله.

---

### 5.6 Providers

افحص:

```text
lib/presentation/providers/*.dart
```

وحدد كل نداء Repository.

الهدف:

معرفة كل نقطة تحتاج API فعليًا.

---

### 5.7 Screens

افحص:

```text
lib/presentation/screens/**/*.dart
```

ولكل شاشة حدد:

1. ما البيانات التي تعرضها؟
2. من أين تأتي؟
3. ما البيانات التي ترسلها؟
4. ما الحقول المستخدمة؟
5. ما عمليات الإضافة؟
6. ما عمليات التعديل؟
7. ما عمليات الحذف؟
8. ما عمليات البحث؟
9. ما عمليات الفلترة؟
10. ما عمليات المطابقة؟
11. ما عمليات العروض؟
12. ما عمليات الإشعارات؟
13. ما البيانات التي تعتمد على المستخدم الحالي؟

هذا هو الأساس لتحديد Request / Response الحقيقي لكل Endpoint.

---

### 5.8 الاختبارات

افحص:

```text
test/widget_test.dart
```

وأي Tests أخرى موجودة.

حدد:

* ماذا تختبر؟
* ما الذي يعتمد على SQLite؟
* ما الذي يجب تحديثه بسبب تغيير مصدر البيانات؟
* ما الذي يجب الحفاظ عليه؟

---

### 5.9 البحث عن API حالي

ابحث في المشروع كاملًا عن:

```text
http
dio
API
baseUrl
REST
Firebase
```

لا تفترض أن المشروع Offline بالكامل قبل التأكد.

---

# 6. 📋 المخرج الإجباري من المرحلة 0

قبل تعديل أي ملف، أنشئ **Migration Audit Report** فعليًا.

يجب أن يحتوي على جدول:

| SQLite Table | SQLite Column | SQLite Type | → PostgreSQL Table | PostgreSQL Column | PostgreSQL Type | FK / Index / Change | Evidence |
| ------------ | ------------- | ----------- | ------------------ | ----------------- | --------------- | ------------------- | -------- |

ويجب أن يكون الجدول مبنيًا على الكود الفعلي.

**ممنوع ملء الجدول بالتخمين.**

إذا كان شيء غير واضح، اكتب:

```text
غير مؤكد — يحتاج تحقق من الكود
```

بدل اختراعه.

---

# 7. 🔎 التصحيحات المعمارية الحرجة التي يجب التحقق منها

## 7.1 item_images

لا تنشئ:

```text
item_images
```

تلقائيًا.

التقرير الحالي يشير إلى عدم وجود:

```text
item_image_model.dart
```

والصور تبدو محفوظة في:

```text
items.images
```

على هيئة TEXT، وعلى الأرجح JSON Array.

لذلك:

* افحص الكود.
* إذا كانت JSON Array فعلًا:

  * انقلها إلى PostgreSQL `JSONB`.
* أنشئ `item_images` فقط إذا ثبت وجود حاجة فعلية لبيانات مستقلة لكل صورة مثل:

  * order.
  * is_primary.
  * metadata.
  * separate lifecycle.

---

# 8. wanted_items

لا تنشئ:

```text
wanted_items
```

افتراضيًا.

لأن الحقول الحالية:

```text
wanted_description
wanted_category_id
wanted_min_value
wanted_max_value
```

تبدو مدمجة داخل:

```text
items
```

إذا أكد الكود ذلك:

> تبقى داخل جدول items.

ولا تنشئ جدول wanted_items إلا إذا أثبت الفحص أن النظام يحتاج فعليًا إلى دعم رغبات متعددة مستقلة.

---

# 9. Matching Results

لا تفترض وجود:

```text
matches
```

كمورد مخزن دائم.

لا يوجد:

```text
match_model.dart
```

والمطابقة حاليًا تُحسب بواسطة:

```text
matching_engine.dart
```

يجب اتخاذ القرار التالي بناءً على الأداء:

### MVP

احسب المطابقة عند الطلب، ولكن:

**ممنوع جلب جميع السلع ثم حسابها في الذاكرة.**

يجب أولًا تضييق نطاق SQL باستخدام:

* category.
* city.
* value range.
* availability.

ثم تطبيق Matching Algorithm الأصلي.

### عند نمو البيانات

استخدم:

```text
match_results
```

أو Redis Cache.

مع:

* TTL.
* Queued Jobs.
* إعادة الحساب عند حدوث تغيير مؤثر.

---

# 10. Ratings

لا تنشئ جدول:

```text
ratings
```

إلا بعد التأكد من وجود Feature فعلية للتقييم بعد إتمام الصفقة.

افحص:

```text
item_detail_screen
profile_screen
offers_screen
```

إذا وجد نظام:

> "قيّم هذه الصفقة"

فأنشئ جدولًا تفصيليًا مثل:

```text
rater_id
rated_id
swap_history_id
stars
comment
```

ثم يكون:

```text
users.rating
```

قيمة مجمعة مشتقة.

ولا تجعل متوسط المستخدم مصدر الحقيقة الأساسي بدل السجلات التفصيلية.

---

# 11. Favorites

لا تنشئ:

```text
favorites
```

إلا إذا أثبت الكود وجود ميزة المفضلة أو طُلبت صراحة.

---

# 12. Reports

فرّق بين مفهومين:

### Admin Reports / Statistics

إذا كانت:

```text
AdminDashboardScreen
```

تعرض إحصائيات فقط:

> لا تحتاج جدول reports.

استخدم:

```text
GET /api/v1/admin/statistics
```

### User Reports / Complaints

إذا وجد فعليًا:

> إبلاغ عن مستخدم / سلعة / محتوى

فقط عندها أنشئ:

```text
reports
```

---

# 13. 🔐 Persistent Session — تصحيح أمني إلزامي

إذا كان:

```text
session_service.dart
```

يخزن Token في:

```text
shared_preferences
```

فهذا يجب تغييره.

التوكن يجب أن ينتقل إلى:

```text
flutter_secure_storage
```

حصريًا.

أما:

```text
shared_preferences
```

فتستخدم فقط للبيانات غير الحساسة مثل:

* تفضيلات العرض.
* آخر فلتر.
* إعدادات UI.

---

# 14. 👤 Authentication

استخدم Laravel Sanctum.

Endpoints:

```text
POST /api/v1/register
POST /api/v1/login
POST /api/v1/logout
GET  /api/v1/me
```

### Register

التدفق:

```text
Validation
↓
Hash Password
↓
Create User
↓
Issue Sanctum Token
↓
Response
```

### Login

يجب:

1. التحقق من بيانات الدخول.
2. التحقق من:

```text
status = active
```

3. إصدار Token جديد.
4. عدم إلغاء Tokens الأجهزة الأخرى تلقائيًا.

يجب دعم تسجيل الدخول من أكثر من جهاز.

---

# 15. Token Management

استخدم:

```text
$user->tokens()
```

كدعم فعلي لـ Sanctum.

لا تفترض Token واحد لكل مستخدم.

عند Logout:

```text
currentAccessToken()->delete()
```

---

# 16. 🛡️ EnsureUserIsActive Middleware

أنشئ:

```text
app/Http/Middleware/EnsureUserIsActive.php
```

ويُطبق بعد:

```text
auth:sanctum
```

على كل Route محمي.

كل Request محمي يجب أن يتحقق من:

```text
status === active
```

إذا كان:

```text
suspended
```

أو:

```text
banned
```

فأعد:

```text
403
```

برسالة واضحة.

وعند الحظر من الإدارة:

```php
$user->tokens()->delete();
```

حتى يتم إبطال كل الجلسات.

---

# 17. 🚀 Persistent Session Flow

يجب أن يكون:

```text
Splash
   ↓
Read Token from flutter_secure_storage
   ↓
Token exists?
   ├── No → Login
   │
   └── Yes
        ↓
     GET /api/v1/me
        ↓
   ┌───────────────┐
   │               │
Valid           Invalid/Banned
   │               │
Home        Clear Token
                   ↓
                 Login
```

عند Logout:

1. Revoke Token في Laravel.
2. حذف Token من Secure Storage.
3. تنظيف جميع Providers.
4. تصفير بيانات المستخدم.
5. منع تسرب بيانات المستخدم السابق للمستخدم التالي.

---

# 18. 🗄️ PostgreSQL

اسم قاعدة البيانات:

```text
badelha_db
```

لا تنشئ Schema نهائيًا قبل إنهاء المرحلة 0.

## الجداول المؤكدة مبدئيًا من التقرير

```text
users
categories
items
stores
swap_offers
swap_history
notifications
banners
governorates
```

لكن:

> هذه القائمة ليست تصريحًا بإنشائها دون تحقق.

الكود الفعلي هو الحكم.

---

# 19. الجداول المشروطة

أنشئ فقط بعد التحقق:

```text
ratings
item_images
favorites
reports
match_results
```

---

# 20. 🇾🇪 Governorates

المحافظات اليمنية الـ22 ليست نصًا حرًا.

إذا أكد الكود أنها قائمة ثابتة:

أنشئ:

```text
governorates
```

كـ Lookup Table.

بدل:

```text
city TEXT
```

ويكون هناك مرجع واضح من:

```text
users.city
items.city
```

إلى:

```text
governorates.code
```

الهدف:

* منع الأخطاء الإملائية.
* توحيد البيانات.
* تحسين الفلترة.
* تحسين الفهرسة.
* ضمان تطابق Flutter وLaravel.

---

# 21. PostgreSQL Data Types

لا تحول كل شيء إلى TEXT.

استخدم PostgreSQL Native Types المناسبة.

## IDs

استخدم UUID إذا أثبت الفحص أن IDs الحالية UUID نصية.

لا تحولها إلى BIGINT إذا كان ذلك سيكسر العلاقات أو البيانات الحالية.

---

## Phone

```text
VARCHAR(20)
UNIQUE
```

---

## Enums

لحقول مثل:

```text
role
status
condition
quality
```

استخدم:

* PostgreSQL ENUM

أو:

* VARCHAR + CHECK Constraint

بحسب ما يناسب Laravel 13 وقابلية التطوير.

وفي PHP استخدم:

```text
Native PHP Enums
```

مثل:

```text
ItemStatus
SwapOfferStatus
UserRole
```

---

## القيم المالية

استخدم:

```text
NUMERIC(12,2)
```

لـ:

```text
estimated_value
cash_difference
wanted_min_value
wanted_max_value
```

ولا تستخدم:

```text
REAL
FLOAT
```

للقيم المالية.

---

## الصور

إذا كانت Array:

```text
JSONB
```

---

## التواريخ

استخدم:

```text
TIMESTAMPTZ
```

لـ:

```text
created_at
updated_at
expires_at
last_refresh_at
```

---

## Trust Score

```text
SMALLINT
```

مع نطاق:

```text
0 - 100
```

---

# 22. 🔗 Foreign Keys

استخدم Foreign Keys حقيقية مع سياسة Delete واضحة.

مبدئيًا:

```text
users(id)
    ↓ items.user_id
ON DELETE CASCADE
```

```text
users(id)
    ↓ stores.user_id
ON DELETE CASCADE
```

```text
users(id)
    ↓ swap_offers.sender_user_id
ON DELETE CASCADE
```

```text
users(id)
    ↓ swap_offers.receiver_user_id
ON DELETE CASCADE
```

```text
users(id)
    ↓ notifications.user_id
ON DELETE CASCADE
```

```text
categories(id)
    ↓ items.category_id
ON DELETE RESTRICT
```

```text
categories(id)
    ↓ items.wanted_category_id
ON DELETE SET NULL
```

```text
items(id)
    ↓ swap_offers.offered_item_id
ON DELETE CASCADE
```

```text
items(id)
    ↓ swap_offers.requested_item_id
ON DELETE CASCADE
```

```text
swap_offers(id)
    ↓ swap_history.swap_offer_id
ON DELETE RESTRICT
```

```text
governorates(code)
    ↓ users.city
ON DELETE RESTRICT
```

```text
governorates(code)
    ↓ items.city
ON DELETE RESTRICT
```

بالنسبة للبيانات التاريخية والمالية:

> استخدم RESTRICT لمنع فقدان سجل التدقيق.

ولا تستخدم CASCADE إلا للبيانات التابعة التي لا معنى لبقائها بدون مالك.

---

# 23. ⚡ Indexing Strategy

الفهارس يجب أن تُبنى على الاستعلامات الفعلية المستخرجة من:

```text
marketplace_repository.dart
```

الفهارس الأساسية المتوقعة:

```sql
CREATE INDEX idx_users_phone
ON users(phone);
```

```sql
CREATE INDEX idx_users_role_status
ON users(role, status);
```

```sql
CREATE INDEX idx_items_status_city_category
ON items(status, city, category_id);
```

```sql
CREATE INDEX idx_items_user_id
ON items(user_id);
```

```sql
CREATE INDEX idx_items_expires_at
ON items(expires_at)
WHERE status = 'Available';
```

```sql
CREATE INDEX idx_items_search_vector
ON items USING GIN(search_vector);
```

```sql
CREATE INDEX idx_items_brand_model
ON items(brand, model);
```

```sql
CREATE INDEX idx_swap_offers_status
ON swap_offers(status);
```

```sql
CREATE INDEX idx_swap_offers_sender_receiver
ON swap_offers(sender_user_id, receiver_user_id);
```

```sql
CREATE INDEX idx_notifications_user_unread
ON notifications(user_id, is_read)
WHERE is_read = false;
```

لكن:

> لا تنشئ أيًا منها بشكل أعمى.

تحقق من أن Query حقيقيًا يستخدمه.

ولا تضف Index زائدًا بلا فائدة، لأن الفهارس تزيد تكلفة:

```text
INSERT
UPDATE
DELETE
```

---

# 24. 🔍 Semantic Search

لا تستخدم:

```sql
LIKE '%query%'
```

كحل أساسي للبحث الكبير.

استخدم PostgreSQL:

```text
tsvector
```

مع:

```text
GIN
```

و:

```text
pg_trgm
```

للبحث التقريبي.

يجب دعم البحث في:

```text
title
description
brand
model
```

مع مراعاة اللغة العربية.

استخدم:

```text
plainto_tsquery
```

و:

```text
ts_rank
```

بشكل صحيح.

مثال منطقي:

```php
Item::whereRaw(
    "search_vector @@ plainto_tsquery('arabic', ?)",
    [$query]
)->orderByRaw(
    "ts_rank(search_vector, plainto_tsquery('arabic', ?)) DESC",
    [$query]
);
```

يجب استخدام Bindings دائمًا.

---

# 25. 🧠 Matching Engine

يجب الحفاظ على منطق:

```text
matching_engine.dart
```

والأوزان الأصلية:

```text
Category  = 30%
Value     = 25%
Quality   = 15%
Location  = 15%
Preference= 15%
```

أي:

```text
Match Score = Category + Value + Quality + Location + Preference
```

لا تغير المعادلات أو الأوزان إلا إذا أثبت الكود الفعلي أن هذه ليست القيم الحقيقية.

يجب أن تكون النتائج بعد الترحيل مطابقة للمنطق الأصلي.

---

# 26. Matching Performance

لا تفعل:

```text
Load All Items
↓
PHP Memory
↓
Compare Everything
```

بدل ذلك:

```text
SQL Cheap Filtering
       ↓
Candidate Set
       ↓
Original Matching Algorithm
       ↓
Score
       ↓
Ranking
```

في MVP:

* حساب عند الطلب.
* تضييق SQL أولًا.

عند نمو النظام:

```text
match_results
```

أو:

```text
Redis
```

مع:

```text
TTL
```

و:

```text
Queued Jobs
```

---

# 27. 🔄 Circular Swap Engine

يجب الحفاظ على:

```text
A → B → C → A
```

بالكامل.

لا تبسط الخوارزمية.

في MVP:

```text
GET /api/v1/matches/circular
```

يشغل الاكتشاف عند الطلب ولكن مع تضييق نطاق البحث.

مثل:

* Category.
* Governorate.
* Value.

عند نمو البيانات:

```text
CircularSwapDetectionJob
```

يعمل بشكل غير متزامن.

لأن الحساب قد يكون:

```text
O(n²)
```

أو أعلى.

**ممنوع حجب HTTP Request طويل بسبب Circular Matching عند نمو البيانات.**

---

# 28. 📦 Laravel Queue

جهز:

```text
CircularSwapDetectionJob
RecalculateTrustScoreJob
ExpireListingsJob
```

واستخدم Redis كـ Queue Driver عند الحاجة.

---

# 29. 🧮 Trust Score

يوجد:

```text
trust_calculator.dart
```

يجب نقل منطق حساب الثقة إلى Laravel.

بعد الترحيل:

> Laravel هو Single Source of Truth.

أنشئ:

```text
TrustService
```

ولا تحسب Trust Score بشكل مستقل في Flutter.

يُعاد حسابه بعد أحداث مؤثرة مثل:

* إتمام صفقة.
* إضافة تقييم.
* توثيق الحساب.
* أي حدث آخر يثبته الكود الحالي.

استخدم Job عند الحاجة.

---

# 30. 🚀 منع N+1 Queries

كل Endpoint يعيد Items يجب أن يستخدم Eager Loading المناسب.

مثال:

```php
Item::with([
    'category',
    'user:id,name,rating,trust_score',
    'store'
])->paginate();
```

لا تجلب العلاقات داخل Loop.

استخدم:

* Laravel Debugbar.
* أو Clockwork.

أثناء التطوير للتحقق من الاستعلامات.

---

# 31. 🗃️ Caching

البيانات شبه الثابتة مثل:

```text
categories
banners
governorates
```

يمكن تخزينها مؤقتًا.

مثال:

```php
Cache::remember(
    'categories:active',
    now()->addHours(6),
    fn () => Category::active()->get()
);
```

ويجب مسح Cache تلقائيًا عند:

```text
saved
deleted
```

وليس الاعتماد على المسح اليدوي فقط.

---

# 32. 📄 Pagination

للقوائم الكبيرة:

```text
cursorPaginate()
```

بدل:

```text
OFFSET pagination
```

خصوصًا:

```text
GET /api/v1/items
```

لأن OFFSET يصبح أبطأ مع زيادة عمق الصفحات.

أما Admin القوائم الصغيرة فيمكن استخدام:

```text
paginate()
```

---

# 33. 🏗️ Flutter Architecture

حافظ على:

```text
UI
 ↓
Provider
 ↓
Repository
 ↓
Remote Data Source
 ↓
Dio
 ↓
Laravel
 ↓
PostgreSQL
```

مع Cache:

```text
Repository
 ├── Remote Data Source
 │       ↓
 │      Dio
 │
 └── Local Cache
        ↓
      SQLite
```

---

# 34. Flutter Data Layer

البنية المقترحة:

```text
lib/data/
│
├── remote/
│   ├── api_client.dart
│   ├── auth_api.dart
│   ├── items_api.dart
│   ├── categories_api.dart
│   ├── matching_api.dart
│   ├── swap_offers_api.dart
│   ├── notifications_api.dart
│   ├── users_api.dart
│   ├── stores_api.dart
│   └── banners_api.dart
│
├── local/
│   └── app_database.dart
│
├── models/
│
└── repositories/
```

لا تغير أسماء Repository الحالية دون حاجة حقيقية.

---

# 35. Dio ApiClient

أنشئ Client مركزي.

يجب أن يدعم:

### Base URL

من:

```text
API_BASE_URL
```

وممنوع Hardcoding داخل Screens.

### Interceptors

لـ:

* Token injection.
* Logging أثناء Development.
* Error handling.
* Retry عند الانقطاع المؤقت فقط.
* عدم إعادة المحاولة تلقائيًا على 4xx.

### 401

عند:

```text
401
```

يجب:

```text
Clear Session
↓
Clear Token
↓
Return Login
```

بشكل مركزي.

لا تكرر هذا الكود داخل كل Screen.

### Timeout

حدد:

```text
Connect Timeout
Receive Timeout
```

واجعلها قابلة للتعديل.

---

# 36. Environment Configuration

استخدم:

```text
flutter_dotenv
```

أو:

```text
--dart-define
```

حسب ما يتوافق مع المشروع.

Development:

```text
API_BASE_URL=http://10.0.2.2:8000/api
```

أو IP الجهاز المحلي عند استخدام هاتف حقيقي.

Production:

```text
API_BASE_URL=https://api.badelha.com/api
```

ممنوع:

```text
localhost
```

داخل أي Widget أو Screen.

---

# 37. 📴 SQLite Cache

لا تحذف SQLite.

بل حوّل دوره إلى:

> Local Cache / Offline Storage.

عند وجود اتصال:

```text
API
 ↓
Update SQLite Cache
 ↓
UI
```

عند انقطاع الاتصال:

```text
SQLite Cache
 ↓
UI
```

لكن في Offline:

* Read Only للبيانات غير المتزامنة.
* عطّل بصريًا الإجراءات التي تحتاج اتصالًا.

---

# 38. 🔄 Offline Sync

عند عودة الاتصال:

```text
Local Pending Queue
↓
API
↓
Success
↓
Mark Synced
```

استخدم:

```text
Idempotency Key
```

لكل عملية قابلة لإعادة الإرسال.

الهدف:

منع تكرار العملية إذا أُرسلت ثم انقطع الاتصال قبل استلام Response.

---

# 39. 🖥️ Laravel Architecture

البنية:

```text
app/
│
├── Http/
│   ├── Controllers/Api/
│   ├── Requests/
│   ├── Resources/
│   └── Middleware/
│       └── EnsureUserIsActive.php
│
├── Models/
│
├── Services/
│
├── Enums/
│
├── Jobs/
│
├── Policies/
│
├── Events/
│
├── Listeners/
│
└── Exceptions/
```

---

# 40. Controller

Controllers يجب أن تكون رقيقة جدًا.

الشكل المطلوب:

```php
public function store(
    StoreItemRequest $request,
    ItemService $service
): ItemResource {
    return ItemResource::make(
        $service->create(
            $request->validated(),
            $request->user()
        )
    );
}
```

لا تضع Business Logic داخل Controller.

التحقق:

```text
FormRequest
```

ومنطق الأعمال:

```text
Service
```

والبيانات:

```text
Eloquent
```

---

# 41. Repository في Laravel

لا تنشئ Repository لكل Model تلقائيًا.

استخدم:

```text
Controller
↓
FormRequest
↓
Service
↓
Eloquent
```

وأنشئ Repository فقط عندما تكون هناك حاجة حقيقية، مثل:

```text
MatchingRepository
```

إذا كانت هناك Queries معقدة يعاد استخدامها.

---

# 42. Native PHP Enums

استخدم:

```text
ItemStatus
SwapOfferStatus
UserRole
```

بدل Strings حرة.

---

# 43. Form Requests

كل Input يجب أن يمر عبر Form Request.

ويجب أن يحتوي:

```text
authorize()
```

حقيقيًا.

لا تستخدم:

```php
return true;
```

دائمًا.

استخدم Form Request لتطبيق الصلاحيات المتعلقة بالعملية والحقول الحساسة.

---

# 44. API Resources

كل Response يجب أن يخرج عبر:

```text
API Resource
```

أو بنية مركزية ثابتة.

لا تجعل كل Controller يخترع JSON مختلفًا.

---

# 45. 📡 Endpoints

استخدم Prefix:

```text
/api/v1
```

## Auth

```text
POST /api/v1/register
POST /api/v1/login
POST /api/v1/logout
GET  /api/v1/me
```

---

## Items

```text
GET    /api/v1/items
GET    /api/v1/items/{id}
POST   /api/v1/items
PUT    /api/v1/items/{id}
DELETE /api/v1/items/{id}
POST   /api/v1/items/{id}/refresh
```

### Items Listing

يجب أن يدعم:

* Pagination.
* Search.
* Filter.
* Sort.
* Category.
* Subcategory.
* Brand.
* Model.
* Quality.
* Condition.
* Value.
* City/Governorate.
* Swap Type.
* Availability.

---

# 46. Categories

```text
GET /api/v1/categories
```

يدعم:

* Parent.
* Subcategories.
* Eager Loading.
* Cache.

---

# 47. Matching

```text
GET /api/v1/items/{id}/matches
```

للمطابقات المباشرة.

و:

```text
GET /api/v1/matches/circular
```

للتبادل الثلاثي.

Response لكل Match يجب أن يتضمن ما يثبته الكود الفعلي، وبالشكل المنطقي:

```json
{
    "match_score": 87.5,
    "match_reasons": [
        "توافق تصنيف كامل",
        "تقارب قيمي 92%",
        "نفس المحافظة"
    ],
    "offered_item": {},
    "wanted_item": {},
    "user": {}
}
```

لا تخترع حقولًا غير موجودة دون مبرر.

---

# 48. Swap Offers

```text
GET   /api/v1/swap-offers
POST  /api/v1/swap-offers
PATCH /api/v1/swap-offers/{id}/status
```

يجب دعم:

```text
Sent
Viewed
Accepted
Safety Confirmation
Meeting Pending
InProgress
Completed
Cancelled
Rejected
```

**لكن استخدم الحالات التي يثبتها الكود الحالي فعليًا.**

---

# 49. Swap State Machine

يجب منع أي انتقال غير قانوني.

مثلًا:

```text
Draft → Completed
```

ممنوع مباشرة.

كل انتقال يجب أن يمر عبر:

```text
SwapService
```

ويتم التحقق من:

```text
Current State
+
Requested New State
```

قبل التحديث.

---

# 50. Ratings

فقط إذا ثبت وجود Feature:

```text
POST /api/v1/swap-history/{id}/rate
```

---

# 51. Notifications

```text
GET   /api/v1/notifications
PATCH /api/v1/notifications/{id}/read
```

---

# 52. Stores / Merchant

```text
GET  /api/v1/stores/{id}
POST /api/v1/stores
GET  /api/v1/stores/me/dashboard
```

إن ثبتت هذه الوظائف فعليًا.

إنشاء المتجر:

```text
role = merchant
```

فقط.

---

# 53. Banners

```text
GET /api/v1/banners
```

ويعيد:

* Active فقط.
* مرتبة حسب priority.
* Cache.

---

# 54. 👑 Admin

كل Admin Route يجب أن يكون محميًا:

```text
auth:sanctum
+
active
+
role:admin
+
Policy
```

Endpoints:

```text
GET    /api/v1/admin/users
PATCH  /api/v1/admin/users/{id}/status
PATCH  /api/v1/admin/stores/{id}/verify
GET    /api/v1/admin/statistics
GET    /api/v1/admin/banners
POST   /api/v1/admin/banners
PUT    /api/v1/admin/banners/{id}
DELETE /api/v1/admin/banners/{id}
```

---

# 55. RBAC

الأدوار فقط:

```text
customer
merchant
admin
```

لا تضف أو تحذف أدوارًا.

الأمان لا يعتمد على Flutter.

إخفاء زر Admin في Flutter ليس حماية.

الحماية الحقيقية في Laravel.

مثال:

```php
Gate::authorize('update', $item);
```

و:

```text
ItemPolicy::update()
```

يتحقق من:

```text
$item->user_id === $user->id
OR
$user->isAdmin()
```

---

# 56. 💰 Cash Difference

لا تغير هذا المفهوم.

```text
cash_difference
```

هو:

> قيمة تفاوضية معلوماتية فقط.

ممنوع في هذه المرحلة:

* Payment Gateway.
* Wallet.
* Escrow.
* تحويل أموال.
* تخزين أموال.
* دفع داخل التطبيق.

---

# 57. ⚠️ Safety Confirmation

يجب الحفاظ على آلية Safety Confirmation الحالية كما هي.

قبل إتمام الصفقة:

1. يظهر التنبيه للطرفين.
2. يظهر Checkbox:

   ```text
   أوافق على شروط وسياسة المقايضة
   ```
3. يتم التأكيد.

لا تغير النص الحالي أو آلية العرض إذا كان النص مثبتًا في المشروع.

التطبيق لا:

* يحتفظ بالأموال.
* يحول الأموال.
* ينفذ الدفع.

وعلى المستخدمين:

* مقابلة بعضهم.
* فحص المنتجات.
* التحقق من الطرف الآخر.
* التأكد من المنتج.
* ثم تأكيد الإتمام.

---

# 58. 🖼️ Image Storage

اجعل طبقة التخزين قابلة للتبديل.

في Laravel:

```text
ITEMS_STORAGE_DRIVER
```

Development:

```text
local
```

Production:

```text
S3
```

أو:

```text
Cloudinary
```

PostgreSQL لا يخزن Binary Images.

يخزن فقط:

```text
image_url
thumbnail_url
storage_path
```

أو JSONB Array إذا كانت البنية الحالية عبارة عن Array.

---

# 59. Image Validation

Laravel يجب أن يتحقق من:

```text
jpg
png
webp
```

وحجم:

```text
max:5120
```

ويجب التحقق من:

> MIME Type الحقيقي.

وليس الامتداد فقط.

ويفضل التخزين خارج:

```text
public
```

مباشرة متى كان ذلك مناسبًا.

---

# 60. Thumbnail

أنشئ Thumbnail تلقائيًا في Backend باستخدام مكتبة مناسبة مثل:

```text
Intervention Image
```

بدل الاعتماد على الهاتف فقط.

---

# 61. Flutter Images

حافظ على:

```text
Cached Images
Placeholder
Error Widget
```

وفشل صورة واحدة يجب ألا يؤدي إلى سقوط الصفحة.

---

# 62. 🔔 Real-Time

لا يشترط تنفيذ Real-Time كامل في MVP، ولكن يجب تجهيز المعمارية.

جهز Events مثل:

```text
NewMatchFound
SwapOfferReceived
SwapCompleted
```

لدعم Laravel Reverb لاحقًا.

يمكن لاحقًا بث:

* سلعة جديدة.
* Match جديد.
* Swap Offer.
* قبول عرض.
* إتمام صفقة.
* Notifications.

---

# 63. Notifications Polling

إذا لم يتم تفعيل Reverb حاليًا:

استخدم Polling خفيف:

```text
كل 30–60 ثانية
```

أثناء فتح التطبيق فقط.

ممنوع Background Polling دائم يستهلك البطارية بلا حاجة.

---

# 64. 🧹 Listing Lifecycle

حافظ على منطق دورة الإعلان الموجود فعليًا.

إذا كان مثبتًا في المشروع:

```text
created_at
updated_at
expires_at
last_refresh_at
status
```

والحالات:

```text
Available
Reserved
InSwap
Completed
Expired
Removed
```

استخدم ما يثبته الكود.

الإعلان المنتهي لا يُحذف بالضرورة.

بل يمكن:

```text
Refresh Listing
```

لإعادته.

ويجب دعم:

```text
POST /api/v1/items/{id}/refresh
```

إذا ثبتت الميزة.

---

# 65. 🔒 Security

طبّق:

### Password Hashing

```text
bcrypt
```

أو:

```text
argon2id
```

عبر:

```text
Hash Facade
```

### Sanctum

Authentication كامل.

### Middleware

حظر المستخدم فورًا.

### Form Requests

لكل Input.

### Rate Limiting

للـ API العامة:

```text
throttle:60,1
```

ولـ:

```text
/login
/register
```

استخدم:

```text
throttle:5,1
```

أو آلية مكافئة في Laravel 13.

---

# 66. Mass Assignment

كل Model يجب أن يحتوي:

```text
$fillable
```

صريحًا.

ممنوع:

```php
$guarded = [];
```

---

# 67. SQL Injection

استخدم:

* Eloquent.
* Query Builder.
* Parameter Binding.

ممنوع وضع قيم المستخدم مباشرة في:

```text
DB::raw()
```

بدون Bindings.

---

# 68. API Data Leakage

ممنوع إعادة:

```text
password
remember_token
full access token
```

في أي API Resource.

---

# 69. 🗃️ SQLite → PostgreSQL Migration Tool

إذا كانت هناك بيانات مهمة حاليًا:

* Seed data.
* بيانات مستخدمين.
* بيانات اختبار مهمة.

أنشئ أداة ترحيل.

التدفق:

```text
SQLite
 ↓
Export JSON/CSV
 ↓
Transform
 ↓
Validate
 ↓
Laravel Import
 ↓
PostgreSQL
```

أنشئ مثلًا:

```text
ImportLegacyDataSeeder
```

ويعمل داخل:

```php
DB::transaction()
```

حتى يحدث Rollback كامل عند الخطأ.

---

# 70. Data Transformation

يجب تحويل:

```text
TEXT → UUID
TEXT → ENUM
REAL → NUMERIC
TEXT JSON → JSONB
```

فقط عندما يثبت ذلك من Audit.

---

# 71. Data Integrity

ممنوع حذف SQLite القديم قبل التحقق.

يجب مقارنة:

```text
Row Count Source
vs
Row Count Target
```

لكل جدول.

ثم:

* عينة عشوائية.
* مقارنة IDs.
* مقارنة الحقول.
* مقارنة العلاقات.

بعد نجاح التحقق فقط يمكن اعتبار البيانات منقولة.

---

# 72. 📚 API Documentation

وثّق كل Endpoint عبر:

```text
Scramble
```

أو:

```text
L5-Swagger
```

ويجب أن تتضمن الوثائق:

* Method.
* URL.
* Authentication.
* Request.
* Validation.
* Response.
* Errors.
* Status Codes.

ويفضل توليد OpenAPI من الكود الفعلي بدل كتابة وثيقة يدوية قد تنفصل عن التطبيق.

---

# 73. 🧪 Testing

بعد التنفيذ:

```bash
flutter analyze
```

يجب:

```text
0 errors
```

ثم:

```bash
flutter test
```

ثم:

```bash
php artisan test
```

---

# 74. Laravel Tests الإلزامية

على الأقل:

```text
AuthTest
```

يشمل:

* Register.
* Login.
* Logout.
* رفض المستخدم المحظور.

---

```text
ItemPolicyTest
```

يضمن:

> منع تعديل سلعة الغير.

---

```text
SwapOfferStateMachineTest
```

يضمن:

> منع الانتقالات غير القانونية.

---

```text
MatchingServiceTest
```

ويجب أن تكون:

> Golden Test

مقارنة مع نتائج:

```text
matching_engine.dart
```

الأصلي.

---

```text
TrustServiceTest
```

---

# 75. 🧪 API Response Format

استخدم صيغة موحدة.

## Success

```json
{
    "success": true,
    "message": "...",
    "data": {}
}
```

## Error

```json
{
    "success": false,
    "message": "رسالة واضحة",
    "errors": {}
}
```

يجب توحيد ذلك مركزيًا عبر Laravel Exception Handling.

لا تجعل كل Controller يعيد التنسيق يدويًا.

---

# 76. 📊 Performance Verification

يجب قياس:

```text
GET /api/v1/items
```

مع فلترة.

الهدف:

```text
< 200ms
```

على بيانات تجريبية بحجم:

```text
10,000+ records
```

لكن:

> لا تكتب "حققنا أقل من 200ms" إلا بعد قياس فعلي.

استخدم:

* Postman.
* Laravel Debugbar.
* أو أداة قياس فعلية مناسبة.

---

# 77. EXPLAIN ANALYZE

نفذ:

```text
EXPLAIN ANALYZE
```

لأهم 3 استعلامات:

1. Items Listing.
2. Search.
3. Matching.

وقارن:

```text
قبل Indexing
```

و:

```text
بعد Indexing
```

وسجل:

* Execution Time.
* Query Plan.
* Index Usage.
* Rows scanned.
* Rows returned.

---

# 78. 🧰 Redis

استخدم Redis عند الحاجة الفعلية لـ:

* Cache.
* Queue.
* Matching Cache.

لا تضف Redis فقط لمجرد وجوده في المعمارية.

---

# 79. Laravel Octane

ليس مطلوبًا في MVP.

صمم الكود بحيث يمكن تشغيله لاحقًا على:

```text
Laravel Octane
```

مع:

```text
Swoole
```

أو:

```text
RoadRunner
```

دون State مشترك بين Requests.

---

# 80. PgBouncer

مستقبلي للإنتاج عند الحاجة إلى:

```text
Connection Pooling
```

ولا حاجة لفرضه في MVP.

---

# 81. Laravel Horizon

استخدمه إذا تم اعتماد:

```text
Redis Queue
```

لمراقبة Jobs.

---

# 82. 🖥️ التشغيل

## Flutter

```bash
flutter pub get
```

ثم:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

أو عنوان IP الشبكة المحلية عند استخدام هاتف فعلي.

---

## Laravel

```bash
composer install
```

ثم:

```bash
cp .env.example .env
```

ثم:

```bash
php artisan key:generate
```

ثم إعداد:

```env
DB_CONNECTION=pgsql
DB_HOST=...
DB_PORT=5432
DB_DATABASE=badelha_db
DB_USERNAME=...
DB_PASSWORD=...
```

ثم:

```bash
php artisan migrate
```

ثم:

```bash
php artisan db:seed
```

ثم:

```bash
php artisan serve
```

---

# 83. XAMPP

لا تعتمد على XAMPP.

PostgreSQL:

> Database Server

pgAdmin 4:

> Database Management GUI

Laravel:

```bash
php artisan serve
```

أثناء التطوير.

لا تستخدم:

```text
Apache/MySQL
```

من XAMPP لهذا النظام.

---

# 84. 👑 Admin Account

Admin لا يتم إنشاؤه من الواجهة العامة.

يجب إنشاؤه عبر:

```text
Seeder
```

أو:

```text
Database/Admin Setup
```

ويجب ألا يكون التسجيل العام قادرًا على إنشاء:

```text
role=admin
```

---

# 85. 🏪 Merchant

حافظ على دور:

```text
merchant
```

إذا كان موجودًا فعليًا.

ويدعم:

* Store.
* Multiple Products.
* Logo.
* Verification.
* Rating.
* Featured Ads.

لكن يجب تنفيذ ما يثبته الكود الفعلي فقط.

---

# 86. 🔄 قاعدة المحافظة على الواجهة

بعد الترحيل يجب أن يشعر المستخدم أن:

> التطبيق نفسه لم يُعاد بناؤه.

يجب الحفاظ على:

* UI.
* UX.
* الهوية.
* الألوان.
* Cairo.
* Cards.
* Animations.
* Navigation.
* Provider.
* سلوك الشاشات.

التغيير الأساسي يجب أن يكون:

```text
Data Source
```

من:

```text
SQLite Direct
```

إلى:

```text
API + PostgreSQL
```

مع:

```text
SQLite Cache
```

---

# 87. 🔎 Search / Filtering

يجب الحفاظ على إمكانيات البحث الحالية، وما يثبت وجوده في المشروع، بما في ذلك عند وجودها:

### Global Search

في:

* Product Name.
* Device Type.
* Brand.
* Model.
* Category.
* Username.
* City.

### Categories

بشكل هرمي عند ثبوتها:

```text
Electronics
 ├── Phones
 ├── Laptops
 ├── PCs
 ├── Gaming
 ├── Smartwatches
 ├── Headphones
 ├── Tablets
 ├── Cameras
 └── Accessories

Home
 ├── Furniture
 ├── Appliances
 └── Tools

Books
 ├── University
 └── General

Vehicles
 ├── Bikes
 └── Parts

Clothing
 ├── Clothes
 ├── Shoes
 └── Accessories
```

لا تضف تصنيفات غير موجودة في الكود دون تأكيد.

---

# 88. Smart Filters

عند ثبوت وجودها:

```text
Category
Subcategory
Brand
Condition
Quality
Value Range
City
Swap Type
Availability
```

Availability:

```text
Available
Reserved
In Swap
Completed
Expired
```

والافتراضي:

> إخفاء غير المتاح.

---

# 89. Sorting

عند وجودها:

```text
Newest
Nearest
Highest Rating
Highest Match Score
Lower Value
Higher Value
```

---

# 90. Live Market

الهدف المعماري:

> المستخدم يرى Marketplace مركزيًا حيًا.

أي مستخدم متصل يستطيع:

* قراءة أحدث البيانات.
* رؤية المنتجات الجديدة.
* رؤية تحديثات الحالة.
* استقبال Notifications.

مع استخدام:

```text
API
```

كمرجع أساسي.

و:

```text
Polling
```

أو:

```text
Reverb
```

للتحديثات الفورية.

---

# 91. 🧩 لا تكسر الـ Provider

إذا كان المشروع يستخدم:

```text
Provider
```

فلا تستبدله بـ:

```text
Riverpod
Bloc
```

إلا إذا ظهر سبب تقني حقيقي، موثق، وضروري.

الأصل:

> إبقاء Provider.

---

# 92. 📐 لا تبالغ في Clean Architecture

لا تنشئ:

```text
Repository
Factory
Adapter
Mapper
UseCase
Manager
Provider
Service
Gateway
```

لكل شيء فقط لإظهار كثرة الطبقات.

استخدم كل طبقة فقط عندما يكون لها دور حقيقي.

---

# 93. 🚦 ترتيب التنفيذ الإلزامي

نفذ العمل بهذا الترتيب:

```text
PHASE 0
Audit
   ↓
Migration Mapping
   ↓
Architecture Confirmation
   ↓
PHASE 1
Laravel Project Setup
   ↓
PostgreSQL
   ↓
Migrations
   ↓
Models / Enums
   ↓
PHASE 2
Authentication
Sanctum
RBAC
Active Middleware
   ↓
PHASE 3
Items / Categories / Stores
   ↓
PHASE 4
Matching
Trust
Circular Swap
   ↓
PHASE 5
Swap Offers
Notifications
   ↓
PHASE 6
Flutter Dio Layer
   ↓
PHASE 7
Repositories → API
   ↓
PHASE 8
SQLite Cache
   ↓
PHASE 9
Offline Sync
   ↓
PHASE 10
Images
   ↓
PHASE 11
Caching / Performance
   ↓
PHASE 12
Tests
   ↓
PHASE 13
Migration Data
   ↓
PHASE 14
EXPLAIN ANALYZE
   ↓
PHASE 15
Final Verification
   ↓
PHASE 16
Arabic Final Report
```

---

# 94. 🚫 ممنوعات مطلقة

ممنوع:

1. إعادة بناء التطبيق من الصفر.
2. إعادة تصميم UI.
3. حذف Feature موجودة.
4. حذف Algorithm موجود.
5. اختراع Tables.
6. اختراع Columns.
7. اختراع Endpoints لا حاجة لها.
8. الاتصال المباشر بين Flutter وPostgreSQL.
9. تخزين Token الحساس في SharedPreferences.
10. الاعتماد على Flutter فقط لحماية Admin.
11. تخزين كلمات المرور.
12. إرجاع Tokens كاملة في API.
13. استخدام FLOAT للأموال.
14. استخدام LIKE كحل أساسي للبحث الكبير.
15. تحميل جميع المنتجات إلى Memory ثم المطابقة.
16. استخدام OFFSET للقوائم الكبيرة دون سبب.
17. إنشاء Repository لكل Model دون حاجة.
18. تشغيل Circular Matching الثقيل داخل HTTP عند نمو البيانات.
19. إنشاء Payment Gateway.
20. إنشاء Wallet.
21. إنشاء Escrow.
22. حذف SQLite قبل التحقق من البيانات.
23. كتابة "تم" دون تحقق فعلي.
24. الادعاء بأن اختبارًا نجح دون تشغيله.
25. الادعاء بتحقيق Performance دون قياس.
26. الادعاء بأن Endpoint يعمل دون اختبار حقيقي.
27. الادعاء بأن Migration ناجح دون مقارنة البيانات.
28. الادعاء بأن PostgreSQL يستخدم Index دون EXPLAIN ANALYZE.

---

# 95. 🧠 قاعدة التعامل مع عدم اليقين

إذا وجدت شيئًا غير واضح:

لا تخمّن.

اكتب داخليًا:

```text
UNKNOWN — NEEDS VERIFICATION
```

ثم افحص:

* الكود.
* Model.
* Repository.
* Screen.
* Database.
* Tests.

وإذا ظل غير محسوم:

> سجله في التقرير النهائي كـ "قرار يحتاج قرار المالك".

---

# 96. 📌 قاعدة التنفيذ الفعلي

أنت لا تقوم بكتابة خطة نظرية فقط.

المطلوب:

> تنفيذ التغييرات فعليًا على المشروع.

كلما كان لديك وصول إلى الملفات والبيئة، يجب:

1. قراءة الملفات.
2. تعديلها.
3. إنشاء الملفات المطلوبة.
4. تشغيل الأوامر.
5. إصلاح الأخطاء.
6. تشغيل الاختبارات.
7. قياس الأداء.
8. التحقق من قاعدة البيانات.
9. التحقق من API.
10. التحقق من Flutter.

لا تتوقف عند كتابة أمثلة.

---

# 97. 🧪 معيار "تم"

لا تستخدم كلمة:

```text
تم
```

إلا إذا كان لديك دليل فعلي.

مثال:

❌ غير مقبول:

> تم ربط PostgreSQL.

إذا لم يتم تشغيل الاتصال.

✅ المقبول:

> تم ربط PostgreSQL، وتم اختبار الاتصال عبر Laravel، ونجح Query فعلي على جدول items.

---

# 98. 🏁 المعمارية النهائية المستهدفة

```text
                         BADELHA
                            │
                      Flutter App
                            │
               ┌────────────┴────────────┐
               │                         │
          Remote API                SQLite Cache
               │                    Offline Only
              Dio
               │
        Laravel 13 REST API
               │
       ┌───────┴────────┐
       │                │
 PostgreSQL        File Storage
 badelha_db       Local / S3 / Cloudinary
       │
   pgAdmin 4
```

والقاعدة:

```text
Flutter
   ↓
Laravel API
   ↓
PostgreSQL
```

مع:

```text
SQLite = Cache / Offline
```

---

# 99. 🎯 معيار النجاح النهائي

المهمة لا تعتبر ناجحة إلا إذا تحقق فعليًا ما يلي:

### التطبيق

* التطبيق يفتح.
* جميع الشاشات تعمل.
* UI محفوظ.
* UX محفوظ.
* الهوية البصرية محفوظة.
* Animations محفوظة.

### البيانات

* PostgreSQL هو Source of Truth.
* Flutter لا يتصل مباشرة بـ PostgreSQL.
* SQLite ليس مصدر البيانات الأساسي.

### Authentication

* Register يعمل.
* Login يعمل.
* Logout يعمل.
* Persistent Session تعمل.
* Token محفوظ في Secure Storage.
* Multi-device Tokens تعمل.
* 401 يعالج مركزيًا.
* الحظر يبطل الجلسات.

### Security

* Sanctum.
* RBAC.
* Policies.
* Form Requests.
* Rate Limiting.
* Mass Assignment Protection.
* SQL Injection Protection.
* File Validation.
* No Sensitive Data Leakage.

### Marketplace

* Items.
* Categories.
* Search.
* Filters.
* Sorting.
* Images.
* Stores.
* Merchant.
* Admin.

بحسب ما يثبته الكود.

### Matching

* نفس Matching Algorithm.
* نفس الأوزان.
* نفس النتائج.
* Match Score.
* Match Reasons.
* أداء جيد.

### Circular Swap

```text
A → B → C → A
```

يعمل بنفس المنطق الأصلي.

### Swaps

* State Machine.
* Offers.
* Acceptance.
* Safety Confirmation.
* Completion.

### Notifications

* Polling أو Reverb.

### Offline

* SQLite Cache.
* Offline Read.
* Sync.
* Idempotency.

### Performance

* Indexes.
* Eager Loading.
* Caching.
* Pagination.
* Full Text Search.
* EXPLAIN ANALYZE.

### Testing

```text
flutter analyze
flutter test
php artisan test
```

كلها ناجحة فعليًا.

---

# 100. 📄 التقرير النهائي العربي — إلزامي

## هذه المرحلة جزء من التنفيذ وليست اختيارية.

لا تعتبر المهمة منتهية قبل إنتاج:

# "تقرير التنفيذ والترحيل النهائي — BADELHA"

ويجب أن يكون **باللغة العربية بالكامل**، منظمًا واحترافيًا ودقيقًا.

يجب أن يكون التقرير مبنيًا على:

> **النتائج الفعلية التي حدثت أثناء التنفيذ فقط.**

ممنوع أن يكون التقرير مجرد إعادة صياغة لهذا البرومبت.

---

# 101. التقرير النهائي يجب أن يحتوي على الأقسام التالية

## أولًا: الملخص التنفيذي

اشرح:

* حالة المشروع قبل الترحيل.
* المعمارية القديمة.
* المعمارية الجديدة.
* الهدف.
* النتيجة الفعلية.
* هل اكتمل الترحيل أم لا؟

---

# 102. ثانيًا: نتائج المرحلة 0

اعرض:

```text
ما تم اكتشافه فعليًا
```

مع:

* Tables.
* Models.
* Columns.
* Relations.
* Queries.
* Services.
* Providers.
* Screens.
* Tests.

---

# 103. ثالثًا: جدول Migration النهائي

اعرض:

| SQLite Table | SQLite Column | Type | PostgreSQL Table | PostgreSQL Column | Type | FK | Index | الملاحظات |
| ------------ | ------------- | ---- | ---------------- | ----------------- | ---- | -- | ----- | --------- |

يجب أن يعكس الواقع النهائي.

---

# 104. رابعًا: الافتراضات التي تأكدت

لكل نقطة من جدول التدقيق الأصلي:

```text
item_images
wanted_items
matches
ratings
favorites
reports
session token
EnsureUserIsActive
governorates
trust_score
Sanctum
semantic search
```

اذكر:

```text
هل تأكدت؟
كيف تأكدت؟
ما القرار النهائي؟
```

---

# 105. خامسًا: التغييرات الفعلية

اعرض:

### تم تغييره

### بقي كما هو

### تم نقله

### تم تحسينه

### تم إلغاؤه

### تم تأجيله

مع السبب.

---

# 106. سادسًا: قاعدة البيانات

اذكر:

* اسم قاعدة البيانات.
* PostgreSQL Version.
* Tables التي أنشئت.
* Columns.
* Types.
* Foreign Keys.
* Constraints.
* Indexes.
* Enums.
* JSONB.
* TIMESTAMPTZ.
* Numeric Fields.

---

# 107. سابعًا: API Endpoints

جدول كامل:

| Method | Endpoint | Auth | Role | الوظيفة | Status |
| ------ | -------- | ---- | ---- | ------- | ------ |

ويجب ذكر **Endpoints التي أنشئت فعليًا فقط**.

---

# 108. ثامنًا: Flutter

اذكر:

* الملفات الجديدة.
* الملفات المعدلة.
* ApiClient.
* Dio.
* Interceptors.
* Repositories.
* Models.
* JSON Serialization.
* Secure Storage.
* SQLite Cache.
* Offline Sync.
* Providers.

---

# 109. تاسعًا: Laravel

اذكر:

* Controllers.
* Form Requests.
* Resources.
* Services.
* Models.
* Policies.
* Middleware.
* Enums.
* Jobs.
* Events.
* Listeners.
* Exceptions.

---

# 110. عاشرًا: Authentication & Security

وضح بالتحديد:

* Sanctum.
* Token Storage.
* Multi-device.
* Logout.
* 401.
* Banned User.
* EnsureUserIsActive.
* RBAC.
* Policies.
* Rate Limiting.
* Password Hashing.
* File Validation.
* Mass Assignment.
* SQL Injection Protection.

---

# 111. الحادي عشر: Matching

اشرح:

* مكان الخوارزمية قبل الترحيل.
* مكانها بعد الترحيل.
* الأوزان.
* طريقة تضييق Candidate Set.
* طريقة حساب Match Score.
* Match Reasons.
* هل النتائج مطابقة؟
* نتيجة Golden Test.

---

# 112. الثاني عشر: Circular Swap

وضح:

* المنطق الأصلي.
* طريقة نقله.
* MVP Strategy.
* Queue Strategy.
* هل تم اختبار A→B→C→A؟
* النتيجة الفعلية.

---

# 113. الثالث عشر: Search

وضح:

* PostgreSQL Full Text Search.
* `tsvector`.
* GIN.
* `pg_trgm`.
* البحث العربي.
* Ranking.
* الأخطاء الإملائية إن تم دعمها.

---

# 114. الرابع عشر: Performance

اعرض نتائج حقيقية.

جدول مثل:

| Query | قبل الفهرسة | بعد الفهرسة | التحسن | Index المستخدم |
| ----- | ----------: | ----------: | -----: | -------------- |

ويجب إرفاق نتائج:

```text
EXPLAIN ANALYZE
```

لـ:

1. Items Listing.
2. Search.
3. Matching.

---

# 115. الخامس عشر: Testing

اعرض نتائج فعلية:

```text
flutter analyze
```

النتيجة:

```text
PASS / FAIL
```

ثم:

```text
flutter test
```

ثم:

```text
php artisan test
```

مع:

* عدد الاختبارات.
* عدد الناجحة.
* عدد الفاشلة.
* تفاصيل الأخطاء إن وجدت.

---

# 116. السادس عشر: Data Migration

اذكر:

* عدد السجلات في SQLite.
* عدد السجلات في PostgreSQL.
* عدد السجلات المتطابقة.
* الجداول التي تم نقلها.
* الجداول التي لم تنقل.
* سبب عدم نقل أي بيانات.
* نتيجة عينات التحقق.
* أي أخطاء.

---

# 117. السابع عشر: الصور

اذكر:

* Storage Driver.
* Validation.
* Thumbnail.
* URLs.
* JSONB أو item_images.
* Placeholder.
* Error Handling.

---

# 118. الثامن عشر: Offline / Sync

اشرح:

```text
Online Flow
Offline Flow
Sync Flow
Idempotency
```

واذكر ما تم اختباره فعليًا.

---

# 119. التاسع عشر: التشغيل

اكتب خطوات تشغيل كاملة:

### PostgreSQL

### Laravel

### Flutter

### pgAdmin 4

### Environment Variables

### Migration

### Seed

### Test Accounts

بحيث يستطيع مهندس آخر تشغيل المشروع من الصفر.

---

# 120. العشرون: بيانات الإدارة التجريبية

اذكر بيانات Admin التجريبية التي تم إنشاؤها بواسطة Seeder.

**لكن لا تنشئ Admin من الواجهة العامة.**

وإذا لم يتم إنشاء بيانات تجريبية، اذكر ذلك بوضوح.

---

# 121. الحادي والعشرون: المشاكل التي ظهرت

يجب تسجيل كل مشكلة فعلية:

```text
المشكلة
السبب
الحل
الملف المتأثر
النتيجة
```

حتى لو تم حلها بالكامل.

---

# 122. الثاني والعشرون: القرارات المعمارية

اذكر القرارات التي اتخذت أثناء التنفيذ، مثل:

* JSONB بدل item_images.
* embedded wanted fields.
* Live Matching بدل Cache.
* Redis.
* Governorates Table.
* Secure Storage.
* Reverb مؤجل.
* Repository غير مستخدم في بعض أجزاء Laravel.

مع سبب كل قرار.

---

# 123. الثالث والعشرون: العناصر غير المكتملة

هذه النقطة إلزامية.

اذكر بصراحة:

* ما لم ينفذ.
* ما لم يتم اختباره.
* ما يحتاج قرارًا من المالك.
* ما تم تأجيله.
* ما تعذر التحقق منه.

ممنوع إخفاء أي نقص.

---

# 124. الرابع والعشرون: القرارات المطلوبة من مالك المشروع

مثلًا:

```text
هل يتم تفعيل Ratings؟
هل يتم تفعيل Reverb؟
هل يتم اعتماد Cloudinary في Production؟
هل يتم تشغيل Redis؟
هل يتم تفعيل Scheduled Circular Matching؟
```

لكن أدرج فقط القرارات التي ظهرت فعليًا أثناء التنفيذ.

---

# 125. الخامس والعشرون: قائمة التحقق النهائية

أنشئ Checklist:

```text
[✓] Flutter يعمل
[✓] Laravel يعمل
[✓] PostgreSQL يعمل
[✓] API يعمل
[✓] Authentication يعمل
[✓] Secure Storage يعمل
[✓] RBAC يعمل
[✓] Items API يعمل
[✓] Search يعمل
[✓] Filters تعمل
[✓] Matching يعمل
[✓] Circular Swap يعمل
[✓] Swap State Machine تعمل
[✓] Notifications تعمل
[✓] SQLite Cache تعمل
[✓] Sync يعمل
[✓] Tests ناجحة
[✓] EXPLAIN ANALYZE تم
```

لكن:

> ضع ✓ فقط عند التحقق الفعلي.

وإذا لم يتحقق شيء:

```text
[ ] غير مكتمل
```

مع السبب.

---

# 126. 🚨 القاعدة الأهم في التقرير

**ممنوع الكذب أو التجميل.**

لا تكتب:

```text
تم التنفيذ بنجاح
```

إذا كان الواقع:

```text
تم إنشاء الكود لكن لم يتم تشغيله
```

اكتب الحقيقة:

> تم إنشاء الكود، لكن لم يتم التحقق من تشغيله فعليًا.

ولا تكتب:

> الأداء أقل من 200ms

إلا إذا تم قياسه.

ولا تكتب:

> البيانات انتقلت بنجاح

إلا بعد:

* Row Count.
* Integrity Check.
* Sample Validation.

---

# 127. صيغة حالة كل بند في التقرير

استخدم واحدة من:

```text
✅ مكتمل ومتحقق فعليًا
```

```text
⚠️ منفذ لكن غير متحقق بالكامل
```

```text
🟡 مؤجل
```

```text
❌ غير منفذ
```

```text
🔍 يحتاج قرارًا من مالك المشروع
```

ولا تستخدم:

```text
مكتمل
```

دون دليل.

---

# 128. 📌 المبدأ النهائي

أنت لا تنفذ:

> Migration شكلي.

بل تنفذ:

> **ترحيلًا حقيقيًا Production-Oriented يحافظ على التطبيق الحالي، وينقل مصدر البيانات إلى PostgreSQL عبر Laravel 13، ويحافظ على SQLite كـ Offline Cache، مع الحفاظ الكامل على المنطق والخوارزميات والواجهة، ثم يثبت النتيجة بالاختبارات والقياسات والتوثيق.**

---

# 129. 🏁 شرط الإنهاء النهائي

لا تعتبر المهمة منتهية إلا بعد:

1. تنفيذ الترحيل.
2. تشغيل Flutter.
3. تشغيل Laravel.
4. الاتصال بـ PostgreSQL.
5. اختبار API.
6. اختبار Authentication.
7. اختبار RBAC.
8. اختبار Items.
9. اختبار Search.
10. اختبار Filters.
11. اختبار Matching.
12. اختبار Circular Swap.
13. اختبار Swap State Machine.
14. اختبار Notifications.
15. اختبار SQLite Cache.
16. اختبار Sync.
17. تشغيل `flutter analyze`.
18. تشغيل `flutter test`.
19. تشغيل `php artisan test`.
20. تنفيذ EXPLAIN ANALYZE.
21. التحقق من البيانات.
22. التحقق من الصور.
23. التحقق من الحظر الفوري.
24. التحقق من Persistent Session.
25. إعداد التوثيق.
26. إعداد التقرير العربي النهائي.

ثم فقط:

> **قدّم التقرير النهائي العربي الكامل.**

ويجب أن يكون التقرير:

* دقيقًا.
* حقيقيًا.
* قائمًا على التنفيذ الفعلي.
* غير مبني على الافتراض.
* يذكر الملفات.
* يذكر الجداول.
* يذكر Endpoints.
* يذكر الاختبارات.
* يذكر القياسات.
* يذكر المشاكل.
* يذكر ما لم يكتمل.
* يذكر القرارات.
* يذكر الأدلة والنتائج.

**لا تعتبر أي بند ناجحًا لمجرد أن الكود "يبدو صحيحًا".**

# النهاية

**ابدأ أولًا بالمرحلة 0 فقط: افحص المشروع فعليًا، واستخرج Migration Audit Report كاملًا، ثم استخدم نتائج الفحص كأساس لكل مراحل التنفيذ التالية. لا تخترع أي معلومة غير موجودة في الكود.**

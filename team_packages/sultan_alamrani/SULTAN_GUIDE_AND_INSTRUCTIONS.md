# 📋 الدليل الإرشادي والتنفيذي للمهندس / سلطان العمراني (Sultan Alamrani)

---

## 👨‍💻 مرحباً بك يا سلطان في مشروع منصة بدلها (BADELHA)!

هذا الدليل يحتوي على جميع التكليفات والخطوات المطلوبة منك لإكمال **المهمة الثانية (Issue #2)** وتطوير **محرك المطابقة والمقايضة الدائرية** ودمجه مع الفرع الرئيسي للمشروع.

---

## 🎯 ملخص دورك وتكليفاتك في المشروع

أنت مسند إليك **Issue #2** على GitHub بعنوان:
> `[Matching Engine] Smart Matching & Circular Swap Engine`

### 1️⃣ المهام المطلوبة منك:
* **قبول دعوة GitHub:** قبول الدعوة كـ Collaborator على مستودع المشروع.
* **مراجعة وتأكيد طلب الدمج (Code Review):** مراجعة **Pull Request #5** المقدم من عبدالرحمن لدمج كود البنية التحتية.
* **تطوير محرك المطابقة المباشرة (Smart Matching):** تطوير حساب نسبة المطابقة بين رغبات المستخدم والمنتجات المعروضة (`MatchScore %`).
* **تطوير المقايضة الدائرية (Circular Swap Graph):** اقتراح وتنسيق التبادل الثلاثي والدائري بين 3 مستخدمين (أ ➔ ب ➔ ج ➔ أ).
* **تحديث الشاشات والخدمات المخصصة لك في Flutter و Laravel.**

---

## 🛠️ الخطوات التنفيذية خطوة بخطوة (Git Workflow)

### الخطوة 1: قبول الدعوة واستنساخ المشروع
1. افتح البريد الإلكتروني أو ادخل مباشرة على رابط الدعوة:
   👉 [https://github.com/abdulrrhman-alyafrasi-dev/Badelha-App/invitations](https://github.com/abdulrrhman-alyafrasi-dev/Badelha-App/invitations) واضغط **Accept Invitation**.
2. قم باستنساخ المستودع على جهازك عبر الأمر:
   ```bash
   git clone https://github.com/abdulrrhman-alyafrasi-dev/Badelha-App.git
   cd Badelha-App
   ```

### الخطوة 2: المراجعة والموافقة على Pull Request #5
1. ادخل على رابط طلب الدمج الخاص بعبدالرحمن:
   👉 [Pull Request #5 على GitHub](https://github.com/abdulrrhman-alyafrasi-dev/Badelha-App/pull/5)
2. اضغط على **Files changed** لمراجعة التعديلات، ثم اضغط **Review changes** وحدد **Approve** واضغط **Submit review**.
3. اضغط على زر **Merge pull request** لدمج التغييرات في فرع `main`.

### الخطوة 3: الانتقال لفرع عملك الخاص (`feature/matching-engine-and-swap`)
من شاشة الأوامر Terminal قم بتنفيذ:
```bash
git checkout main
git pull origin main
git checkout feature/matching-engine-and-swap
```

### الخطوة 4: التعديل والتطوير في الملفات المخصصة لك
قم بالعمل والتعديل في الملفات المخصصة لك (راجع قائمة الملفات أدناه).

### الخطوة 5: حفظ التغييرات ورفعها إلى GitHub
بعد إكمال تعديلاتك واختبار التطبيق:
```bash
git add .
git commit -m "feat: complete smart matching algorithm & circular swap engine"
git push -u origin feature/matching-engine-and-swap
```

### الخطوة 6: فتح طلب الدمج (Pull Request)
افتح طلب دمج من فرعك `feature/matching-engine-and-swap` إلى `main` وعيّن **عبدالرحمن اليفرسي** كمراجع (`abdulrrhman-alyafrasi-dev`).

---

## 📂 قائمة الملفات الخاصة بسلطان العمراني (Files Manifest)

### 🎨 أولاً: واجهات وقواعد Flutter (Frontend):
1. **شاشة المطابقات الذكية:**
   `lib/presentation/screens/matching/smart_matches_screen.dart`
2. **شاشة المقايضة الدائرية:**
   `lib/presentation/screens/circular_swap/circular_swap_screen.dart`
3. **نموذج بيانات المقايضات:**
   `lib/data/models/swap_request_model.dart`
4. **مزود ومستودع المطابقات:**
   `lib/presentation/providers/matching_provider.dart`

### ⚙️ ثانياً: خدمات وقواعد Laravel 13 (Backend):
1. **خدمة محرك المطابقة الذكية:**
   `backend/app/Services/MatchingService.php`
2. **خدمة خوارزمية المقايضة الدائرية:**
   `backend/app/Services/CircularSwapService.php`
3. **متحكم API للمطابقات:**
   `backend/app/Http/Controllers/Api/MatchingController.php`
4. **متحكم API للمقايضة الدائرية:**
   `backend/app/Http/Controllers/Api/CircularSwapController.php`

---

## 🧪 التحقق والاختبار (Verification)
- تشغيل تطبيق Flutter واختبار شاشة **المطابقات الذكية** والتأكد من إظهار نسب المطابقة %.
- فحص شاشة **المقايضة الدائرية** وتجربة اقتراح سائر السلع في حلقة التبادل الثلاثي.
- التأكد من عدم وجود أي أخطاء عبر تشغيل `flutter analyze`.

بالتوفيق يا سلطان! 🚀

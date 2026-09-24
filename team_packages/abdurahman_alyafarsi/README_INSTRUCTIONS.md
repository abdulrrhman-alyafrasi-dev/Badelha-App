# 📌 دليل وخطوات الرفع على GitHub الخاص بالطالب: عبدالرحمن اليفرسي (فريق من طالبين 50/50)
**الصفة في الفريق**: مسؤول الفريق (Team Lead) + مراجع الكود ومسؤول المستودع (Repository Maintainer & Code Reviewer)
**المسار البرمجي المخصص**: التوثيق، الحسابات، لوحة التحكم للأدمين، المتاجر، ودورة صفقات المقايضة (Auth, Admin, Stores & Swap Offers Lifecycle)
**اسم الفرع (Branch Name)**: `feature/auth-admin-swaps`
**عنوان الـ Issue على GitHub**: `[FEAT] Implement Sanctum Auth, Admin Control Panel, Stores Management & Swap Offers Lifecycle`

---

## 🚀 دليل الرفع بالتفصيل والخطوات المعيارية التسع (Git Commands Sequence)

### الخطوة 1: إنشاء وتوثيق التكليف في GitHub (Create Issue)
1. افتح مستودع المشروع على GitHub واضغط على تبويب **Issues** ➔ **New Issue**.
2. اكتب العنوان: `[FEAT] Implement Sanctum Auth, Admin Control Panel, Stores Management & Swap Offers Lifecycle`
3. اكتب الوصف: *"تطوير وبناء نظام توثيق المستخدمين بـ Sanctum، لوحة الإشراف الإدارية الشاملة للأدمين، المتاجر المعتمدة، وإدارة صفقات المقايضة والحسابات."*
4. اضغط **Submit new issue** واحتفظ برقم الـ Issue (مثلاً: `#1`).

---

### الخطوة 2: إنشاء الفرع المحلي (Branch Creation)
افتح التيرمينال (Terminal / PowerShell) في مجلد المشروع ونفّذ الأوامر التالية:
```bash
# 1. الانتقال إلى الفرع الرئيسي وجلب أحدث النسخ
git checkout main
git pull origin main

# 2. إنشاء فرعك المخصص والانتقال إليه
git checkout -b feature/auth-admin-swaps
```

---

### الخطوة 3: التعديل والبرمجة (Edit / Change)
تأكد من تعديل وكتابة الأكواد والملفات الخاصة بمسارك البرمجي (المحددة في ملف `FILES_MANIFEST.md`).

---

### الخطوة 4: حفظ التغييرات محلياً (Commit)
نفّذ الأوامر التالية لحفظ تعديلاتك مع رسالة معيارية توضيحية:
```bash
# إضافة كافة ملفات مسارك
git add .

# حفظ التعديلات
git commit -m "feat(auth-admin-swaps): implement sanctum auth, admin stats dashboard, store controls and swap offers lifecycle"
```

---

### الخطوة 5: رفع الفرع إلى GitHub (Push)
ارفع فرعك إلى المستودع السحابي عبر الأمر:
```bash
git push -u origin feature/auth-admin-swaps
```

---

### الخطوة 6: إنشاء Pull Request (PR)
1. اذهب لموقع GitHub في المستودع وستظهر لك لافتة **Compare & pull request**.
2. اختر الدمج من فرعك `feature/auth-admin-swaps` إلى فرع `main`.
3. اكتب عنوان الـ PR: `PR #1: Implement Sanctum Auth, Admin Control Panel, Stores Management & Swap Offers Lifecycle`.
4. في صندوق الوصف اكتب: `Closes #1`.

---

### الخطوة 7: المراجعة واختبار الأمان (Code Review)
بصفتك **Reviewer ومسؤول المستودع**:
* قم بمراجعة الأكواد والتأكد من حماية مسارات الـ API بميدلوير `auth:sanctum` و `EnsureUserIsActive`.
* فحص أداء لوحة التحكم واختبار حظر وتفعيل الحسابات ودورة صفقات التبادل.

---

### الخطوة 8 & 9: الدمج وإغلاق الـ Issue (Merge & Close Issue)
1. اضغط على زر **Confirm Merge** لدمج فرعك في `main`.
2. سيتم إغلاق `Issue #1` تلقائياً.
3. قم بمراجعة ودمج طلب الـ PR القادم من زميلك **سلطان العمراني** (`PR #2`) بنفس الطريقة.

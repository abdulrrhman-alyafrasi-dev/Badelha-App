# 📌 دليل وخطوات الرفع على GitHub الخاص بالطالب: سلطان العمراني (فريق من طالبين 50/50)
**الصفة في الفريق**: عضو فريق (Team Member) + مهندس محركات الذكاء والسلع والبحث والسمعة (Marketplace, Search Engine & Trust Specialist)
**المسار البرمجي المخصص**: سوق المنتجات، K-T-V-G-T Matching Engine, التبادلات الدائرية، الكتالوج والتزامن (Items CRUD, Search, Matching Engine & Trust Calculator)
**اسم الفرع (Branch Name)**: `feature/marketplace-items-engine`
**عنوان الـ Issue على GitHub**: `[FEAT] Build Marketplace Items CRUD, Category Catalog, 5-Criteria Matching Engine, 3-Way Circular Swaps & Trust Calculator`

---

## 🚀 دليل الرفع بالتفصيل والخطوات المعيارية التسع (Git Commands Sequence)

### الخطوة 1: إنشاء وتوثيق التكليف في GitHub (Create Issue)
1. افتح مستودع المشروع على GitHub واضغط على تبويب **Issues** ➔ **New Issue**.
2. اكتب العنوان: `[FEAT] Build Marketplace Items CRUD, Category Catalog, 5-Criteria Matching Engine, 3-Way Circular Swaps & Trust Calculator`
3. اكتب الوصف: *"تطوير وبناء إدارة المنتجات والسلع، كتالوج التصنيفات، محرك المطابقة الخماسي الموزون، التبادلات الثلاثية وحاسبة نقاط الثقة والسمعة."*
4. اضغط **Submit new issue** واحتفظ برقم الـ Issue (مثلاً: `#2`).

---

### الخطوة 2: إنشاء الفرع المحلي (Branch Creation)
افتح التيرمينال (Terminal / PowerShell) في مجلد المشروع ونفّذ الأوامر التالية:
```bash
# 1. الانتقال إلى الفرع الرئيسي وجلب أحدث النسخ
git checkout main
git pull origin main

# 2. إنشاء فرعك المخصص والانتقال إليه
git checkout -b feature/marketplace-items-engine
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
git commit -m "feat(items-engine): implement items CRUD, 5-criteria matching algorithm, circular swaps graph and trust calculator"
```

---

### الخطوة 5: رفع الفرع إلى GitHub (Push)
ارفع فرعك إلى المستودع السحابي عبر الأمر:
```bash
git push -u origin feature/marketplace-items-engine
```

---

### الخطوة 6: إنشاء Pull Request (PR)
1. اذهب لموقع GitHub في المستودع وستظهر لك لافتة **Compare & pull request**.
2. اختر الدمج من فرعك `feature/marketplace-items-engine` إلى فرع `main`.
3. اكتب عنوان الـ PR: `PR #2: Build Marketplace Items CRUD, Category Catalog, 5-Criteria Matching Engine, 3-Way Circular Swaps & Trust Calculator`.
4. أسند طلب الدمج لمسؤول الفريق **عبدالرحمن اليفرسي** لمراجعته، واكتب في صندوق الوصف: `Closes #2`.

---

### الخطوة 7: المراجعة واختبار الجودة (Code Review)
سيقوم مسؤول الفريق ومراجع المستودع **عبدالرحمن اليفرسي** بمراجعة أكوادك واختبار استعلامات المطابقة الخماسية والتزام الكاش المحلي.

---

### الخطوة 8 & 9: الدمج وإغلاق الـ Issue (Merge & Close Issue)
عند موافقة المراجع سيعتمد الدمج إلى `main` وسيتحدث وضع الـ Issue #2 تلقائياً إلى **Closed**.

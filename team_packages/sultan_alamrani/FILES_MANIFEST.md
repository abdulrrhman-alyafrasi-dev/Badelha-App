# 📂 بيان الملفات المخصصة للمهندس سلطان العمراني (Sultan Alamrani) - حصة 50% متوازنة

هذه هي القائمة المحدثة والشاملة لجميع الملفات البرمجية المسندة للمهندس سلطان العمراني وتساوي **50% كاملة من حجم المشروع**:

---

## 📱 1. واجهات وموديولات Flutter (lib/)

```text
lib/
├── presentation/
│   ├── screens/
│   │   ├── matching/
│   │   │   └── smart_matches_screen.dart             <-- شاشة المطابقات الذكية %
│   │   ├── circular_swap/
│   │   │   └── circular_swap_screen.dart            <-- شاشة التبادل الدائري الثلاثي
│   │   ├── offers/
│   │   │   └── offers_screen.dart                   <-- شاشة إشعارات ومتابعة العروض
│   │   └── item_details/
│   │       └── widgets/
│   │           └── make_offer_modal.dart            <-- نافذة تقديم عرض مقايضة
│   ├── widgets/
│   │   └── swap_safety_dialog.dart                  <-- نافذة الأمان والضمان
│   └── providers/
│       └── matching_provider.dart                   <-- إدارة حالة المطابقة والعروض
└── data/
    └── models/
        ├── swap_request_model.dart                  <-- نموذج العروض والمقايضات
        └── trust_score_model.dart                   <-- نموذج تقييم الثقة والأمان
```

---

## 💻 2. خدمات ومتحكمات Laravel Backend (backend/)

```text
backend/
└── app/
    ├── Services/
    │   ├── MatchingService.php                      <-- خوارزمية التوافق والنسبة المئوية
    │   ├── CircularSwapService.php                  <-- خوارزمية التبادل الثلاثي (A->B->C->A)
    │   └── TrustService.php                         <-- حساب وتقييم درجات الثقة ⭐
    └── Http/
        └── Controllers/
            └── Api/
                ├── MatchingController.php           <-- API المطابقة الذكية
                ├── CircularSwapController.php       <-- API المقايضة الدائرية
                ├── SwapController.php               <-- API إرسال وحالة العروض
                └── TrustController.php              <-- API تقييمات الأمان والثقة
```

---

## ⚖️ تكافؤ العمل:
- **عبدالرحمن (50%):** البنية التحتية، المصادقة، التخزين الهجين، إضافة وتصفح المنتجات بالسوق، لوحة الإدارة.
- **سلطان (50%):** محرك المطابقة الذكية، محرك التبادل الدائري، إدارة تقديم وتتبع العروض، نظام الأمان وتقييمات الثقة ⭐.

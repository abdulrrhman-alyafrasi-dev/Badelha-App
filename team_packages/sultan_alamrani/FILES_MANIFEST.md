# 📂 بيان الملفات المخصصة للمهندس سلطان العمراني (Sultan Alamrani)

هذه هي القائمة التفصيلية للملفات التي تقع ضمن النطاق البرمجي المسند لسلطان العمراني لحل **Issue #2**:

---

## 📱 1. واجهات وموديولات Flutter (lib/)

```text
lib/
├── presentation/
│   ├── screens/
│   │   ├── matching/
│   │   │   └── smart_matches_screen.dart     <-- شاشة عرض المنتجات المتوافقة مع رغبة المستخدم
│   │   └── circular_swap/
│   │       └── circular_swap_screen.dart    <-- شاشة المقايضة الدائرية والتبادل الثلاثي
│   └── providers/
│       └── matching_provider.dart           <-- مزود حالة المطابقات والمقايضات
└── data/
    └── models/
        └── swap_request_model.dart          <-- نموذج طلبات المقايضة واحتساب التوافق
```

---

## 💻 2. خدمات ومتحكمات Laravel Backend (backend/)

```text
backend/
└── app/
    ├── Services/
    │   ├── MatchingService.php              <-- خوارزمية حساب نسبة المطابقة (Matching Algorithm)
    │   └── CircularSwapService.php          <-- خوارزمية البحث عن حلقة التبادل الدائري (A->B->C->A)
    └── Http/
        └── Controllers/
            └── Api/
                ├── MatchingController.php   <-- API Endpoints للمطابقة الذكية
                └── CircularSwapController.php <-- API Endpoints للمقايضة الدائرية
```

---

## 🔗 روابط GitHub المباشرة لسلطان:
- 📌 **رابط القضية Issue #2:** [Issue #2 على GitHub](https://github.com/abdulrrhman-alyafrasi-dev/Badelha-App/issues/2)
- 🔀 **رابط الفرع المخصص:** `feature/matching-engine-and-swap`
- 📩 **رابط قبول دعوة المساهمة:** [Accept Invitation](https://github.com/abdulrrhman-alyafrasi-dev/Badelha-App/invitations)

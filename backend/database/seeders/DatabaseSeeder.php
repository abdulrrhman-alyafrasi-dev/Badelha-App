<?php

namespace Database\Seeders;

use App\Models\AdminBanner;
use App\Models\Category;
use App\Models\Governorate;
use App\Models\Item;
use App\Models\Store;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Seed Governorates
        $governorates = [
            'صنعاء', 'عدن', 'تعز', 'الحديدة', 'إب', 'حضرموت', 'ذمار', 'حجة',
            'صعدة', 'عمران', 'لحج', 'أبين', 'شبوة', 'المهرة', 'مأرب', 'البيضاء',
            'الجوف', 'ريمة', 'المحويت', 'الضالع', 'سقطرى', 'أمانة العاصمة'
        ];
        foreach ($governorates as $gov) {
            Governorate::firstOrCreate(['name_ar' => $gov], ['is_active' => true]);
        }

        // 2. Seed Categories
        $categories = [
            ['name' => 'إلكترونيات', 'icon' => 'devices', 'description' => 'هواتف، لابتوبات، وأجهزة إلكترونية'],
            ['name' => 'سيارات ومركبات', 'icon' => 'directions_car', 'description' => 'سيارات، دراجات، وقطع غيار'],
            ['name' => 'عقارات', 'icon' => 'apartment', 'description' => 'شقق، أراضي، ومنازل'],
            ['name' => 'أزياء وملابس', 'icon' => 'checkroom', 'description' => 'ملابس رجالية ونسائية وأطفال'],
            ['name' => 'أثاث وديكور', 'icon' => 'chair', 'description' => 'أثاث منزلي ومكتبي وديكورات'],
            ['name' => 'كتب وروايات', 'icon' => 'menu_book', 'description' => 'كتب علمية وثقافية وروايات'],
            ['name' => 'ألعاب فيديو', 'icon' => 'sports_esports', 'description' => 'بلايستيشن، إكس بوكس، وألعاب'],
            ['name' => 'رياضة ولياقة', 'icon' => 'fitness_center', 'description' => 'أجهزة ومعدات رياضية'],
            ['name' => 'أخرى', 'icon' => 'category', 'description' => 'سلع ومنتجات متنوعة'],
        ];
        $categoryMap = [];
        foreach ($categories as $cat) {
            $created = Category::firstOrCreate(['name' => $cat['name']], $cat);
            $categoryMap[$cat['name']] = $created->id;
        }

        // 3. Seed Users
        // Admin
        $admin = User::firstOrCreate(
            ['email' => 'admin@badelha.com'],
            [
                'name' => 'مدير النظام',
                'phone' => '777000000',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
                'city' => 'صنعاء',
                'bio' => 'الحساب الإداري الرسمي لمنصة بدلها',
                'status' => 'active',
                'is_verified' => true,
                'rating' => 5.00,
                'trust_score' => 100,
            ]
        );

        // Merchant
        $merchant = User::firstOrCreate(
            ['email' => 'techstore@badelha.com'],
            [
                'name' => 'متجر التكنولوجيا الحديثة',
                'phone' => '777111222',
                'password' => Hash::make('password123'),
                'role' => 'merchant',
                'city' => 'صنعاء',
                'bio' => 'متجر متخصص في الإلكترونيات والهواتف الذكية مع ضمان الاستبدال',
                'status' => 'active',
                'is_verified' => true,
                'rating' => 4.90,
                'trust_score' => 98,
            ]
        );

        // Merchant Store
        $store = Store::firstOrCreate(
            ['user_id' => $merchant->id],
            [
                'name' => 'متجر التكنولوجيا الحديثة',
                'bio' => 'أفضل عروض المقايضة في عالم الإلكترونيات والهواتف الذكية',
                'city' => 'صنعاء',
                'phone' => '777111222',
                'rating' => 4.90,
                'total_swaps' => 24,
                'is_verified' => true,
            ]
        );

        // Customers
        $customer1 = User::firstOrCreate(
            ['email' => 'ahmed@badelha.com'],
            [
                'name' => 'أحمد المقايض',
                'phone' => '771234567',
                'password' => Hash::make('password123'),
                'role' => 'customer',
                'city' => 'صنعاء',
                'bio' => 'مهتم بتبادل الإلكترونيات والكتب',
                'status' => 'active',
                'is_verified' => true,
                'rating' => 4.85,
                'trust_score' => 95,
                'total_swaps' => 8,
                'successful_swaps' => 8,
            ]
        );

        $customer2 = User::firstOrCreate(
            ['email' => 'sara@badelha.com'],
            [
                'name' => 'سارة الشامري',
                'phone' => '772345678',
                'password' => Hash::make('password123'),
                'role' => 'customer',
                'city' => 'عدن',
                'bio' => 'عاشقة للأزياء والأثاث المنزلي',
                'status' => 'active',
                'is_verified' => true,
                'rating' => 5.00,
                'trust_score' => 96,
                'total_swaps' => 5,
                'successful_swaps' => 5,
            ]
        );

        // 4. Seed Items
        $itemsData = [
            [
                'user_id' => $customer1->id,
                'category_id' => $categoryMap['إلكترونيات'],
                'title' => 'آيفون 13 برو ماكس 256 جيجا',
                'description' => 'جهاز بحالة شبه جديدة مع الكرتون وكامل ملحقاته الأصلية، نسبة البطارية 88%',
                'estimated_value' => 650.00,
                'cash_difference' => 0.00,
                'city' => 'صنعاء',
                'condition' => 'like_new',
                'swap_type' => 'exact_match',
                'wanted_category_id' => $categoryMap['إلكترونيات'],
                'wanted_description' => 'أرغب بالمقايضة مع سامسونج S23 ألترا أو لابتوب ماك بوك برو',
                'images' => ['assets/images/placeholder_phone.png'],
            ],
            [
                'user_id' => $merchant->id,
                'store_id' => $store->id,
                'category_id' => $categoryMap['إلكترونيات'],
                'title' => 'سامسونج جالكسي S23 ألترا 512GB',
                'description' => 'جديد تماماً بالكرتون، مع ضمان المتجر لمدة 6 أشهر. متاح للمقايضة مع آيفون أو أجهزة لوحية',
                'estimated_value' => 750.00,
                'cash_difference' => 50.00,
                'city' => 'صنعاء',
                'condition' => 'new',
                'swap_type' => 'cash_adjustment',
                'wanted_category_id' => $categoryMap['إلكترونيات'],
                'wanted_description' => 'آيفون 13 أو 14 برو ماكس مع دفع الفارق',
                'images' => ['assets/images/placeholder_s23.png'],
            ],
            [
                'user_id' => $customer2->id,
                'category_id' => $categoryMap['أثاث وديكور'],
                'title' => 'طقم كنب تركي فاخر 7 مقاعد',
                'description' => 'طقم صالون تركي قماش مخمل عالي الجودة بحالة ممتازة جداً ونظيف جداً',
                'estimated_value' => 450.00,
                'cash_difference' => 0.00,
                'city' => 'عدن',
                'condition' => 'like_new',
                'swap_type' => 'exact_match',
                'wanted_category_id' => $categoryMap['إلكترونيات'],
                'wanted_description' => 'أرغب بمقايضته بشاشة تلفزيون ذكية 65 بوصة أو آيباد حديث',
                'images' => ['assets/images/placeholder_furniture.png'],
            ],
            [
                'user_id' => $customer1->id,
                'category_id' => $categoryMap['ألعاب فيديو'],
                'title' => 'بلايستيشن 5 مع يدين تحكم و 4 ألعاب',
                'description' => 'PS5 النسخة الرقمية مع يدين أصلية وألعاب فيفا وجاد أوف وور وسبايدرمان',
                'estimated_value' => 480.00,
                'cash_difference' => 0.00,
                'city' => 'صنعاء',
                'condition' => 'like_new',
                'swap_type' => 'exact_match',
                'wanted_category_id' => $categoryMap['أثاث وديكور'],
                'wanted_description' => 'طقم جلوس أو شاشة 4K',
                'images' => ['assets/images/placeholder_ps5.png'],
            ],
        ];

        foreach ($itemsData as $itemInfo) {
            $itemInfo['status'] = 'available';
            $itemInfo['is_active'] = true;
            $itemInfo['last_refresh_at'] = now();
            $itemInfo['expires_at'] = now()->addDays(30);
            Item::create($itemInfo);
        }

        // 5. Seed Banners
        AdminBanner::firstOrCreate(
            ['title' => 'مرحباً بك في منصة بدلها الذكية'],
            [
                'image_url' => 'assets/images/banner_welcome.png',
                'target_url' => null,
                'is_active' => true,
                'priority' => 10,
                'expires_at' => now()->addMonths(6),
            ]
        );

        AdminBanner::firstOrCreate(
            ['title' => 'خدمة المقايضة الدائرية الثلاثية متاحة الآن!'],
            [
                'image_url' => 'assets/images/banner_circular.png',
                'target_url' => null,
                'is_active' => true,
                'priority' => 5,
                'expires_at' => now()->addMonths(6),
            ]
        );
    }
}

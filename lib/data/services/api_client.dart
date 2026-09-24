import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'session_service.dart';

/// 🌐 Badelha Remote API Client (Dio + Laravel 13 REST API)
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;

  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        // 10.0.2.2 is Android Emulator loopback to host localhost:8000
        return 'http://10.0.2.2:8000/api/v1';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000/api/v1';
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: defaultBaseUrl,
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionService.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await SessionService.clearSession();
          }
          return handler.next(error);
        },
      ),
    );
  }

  void updateBaseUrl(String newUrl) {
    dio.options.baseUrl = newUrl;
  }

  // --- Auth Endpoints ---
  Future<Response> login(String email, String password) async {
    return await dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await dio.post('/auth/register', data: data);
  }

  Future<Response> logout() async {
    return await dio.post('/auth/logout');
  }

  Future<Response> getMe() async {
    return await dio.get('/auth/me');
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await dio.patch('/auth/profile', data: data);
  }

  // --- Categories ---
  Future<Response> getCategories() async {
    return await dio.get('/categories');
  }

  // --- Items Marketplace ---
  Future<Response> getItems({
    String? categoryId,
    String? city,
    String? condition,
    String? swapType,
    double? minValue,
    double? maxValue,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (categoryId != null && categoryId.isNotEmpty && categoryId != 'الكل') queryParams['category_id'] = categoryId;
    if (city != null && city.isNotEmpty && city != 'الكل') queryParams['city'] = city;
    if (condition != null && condition.isNotEmpty && condition != 'الكل') queryParams['condition'] = condition;
    if (swapType != null && swapType.isNotEmpty && swapType != 'الكل' && swapType != 'Any') queryParams['swap_type'] = swapType;
    if (minValue != null) queryParams['min_value'] = minValue;
    if (maxValue != null) queryParams['max_value'] = maxValue;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    return await dio.get('/items', queryParameters: queryParams);
  }


  Future<Response> getMyItems() async {
    return await dio.get('/my-items');
  }

  Future<Response> getItemDetails(String itemId) async {
    return await dio.get('/items/$itemId');
  }

  Future<Response> createItem(Map<String, dynamic> data) async {
    return await dio.post('/items', data: data);
  }

  Future<Response> updateItem(String itemId, Map<String, dynamic> data) async {
    return await dio.put('/items/$itemId', data: data);
  }

  Future<Response> deleteItem(String itemId) async {
    return await dio.delete('/items/$itemId');
  }

  Future<Response> refreshItem(String itemId) async {
    return await dio.post('/items/$itemId/refresh');
  }

  Future<Response> getItemMatches(String itemId) async {
    return await dio.get('/items/$itemId/matches');
  }

  Future<Response> getItemCircularSwaps(String itemId) async {
    return await dio.get('/items/$itemId/circular-swaps');
  }

  // --- Swap Offers ---
  Future<Response> getSwapOffers() async {
    return await dio.get('/swap-offers');
  }

  Future<Response> createSwapOffer(Map<String, dynamic> data) async {
    return await dio.post('/swap-offers', data: data);
  }

  Future<Response> updateSwapOfferStatus(String offerId, String status, {String? reason}) async {
    final payload = <String, dynamic>{'status': status};
    if (reason != null) {
      payload['cancellation_reason'] = reason;
    }
    return await dio.patch('/swap-offers/$offerId/status', data: payload);
  }

  Future<Response> confirmSafety(String offerId) async {
    return await dio.post('/swap-offers/$offerId/confirm-safety');
  }

  // --- Notifications ---
  Future<Response> getNotifications() async {
    return await dio.get('/notifications');
  }

  Future<Response> markNotificationAsRead(String notificationId) async {
    return await dio.patch('/notifications/$notificationId/read');
  }

  Future<Response> markAllNotificationsAsRead() async {
    return await dio.post('/notifications/read-all');
  }

  // --- Banners ---
  Future<Response> getBanners() async {
    return await dio.get('/banners');
  }

  // --- Favorites ---
  Future<Response> getFavorites() async {
    return await dio.get('/favorites');
  }

  Future<Response> toggleFavorite(String itemId) async {
    return await dio.post('/favorites/$itemId/toggle');
  }

  // --- Ratings ---
  Future<Response> rateUser(Map<String, dynamic> data) async {
    return await dio.post('/ratings', data: data);
  }

  // --- Admin Endpoints ---
  Future<Response> getAdminUsers() async {
    return await dio.get('/admin/users');
  }
}

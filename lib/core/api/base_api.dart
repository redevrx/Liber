import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:liber/core/api/wrapper_interceptor.dart';
import 'package:liber/core/constant/constant.dart';
import 'package:liber/data/models/wrapper_result.dart';

@Singleton()
class BaseAPI {
  static const baseUrl = 'http://172.26.144.1:8080/api/v1/';
  late Dio _dio;

  BaseAPI() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      receiveTimeout: kTimeout,
      connectTimeout: kTimeout,
      sendTimeout: kTimeout,
    ));

    //set up interceptor
    _dio.interceptors.add(WrapperInterceptor());
  }

  Dio get client => _dio;

  Future<WrapperValue> post(
      {required String path, Map<String, dynamic>? request}) async {
    WrapperValue response;

    try {
      final res = await client.post(path, data: request == null ? null : json.encode(request));
      if (res.data["statusCode"] as int == 200 && res.data["errorMessage"].toString().isEmpty) {
        response = WrapperValue.fromJson(res.data);
      } else {
        response =
            WrapperValue(statusCode: res.data["statusCode"], errMessage: "${res.data["errorMessage"]}",value: null);
      }
    } on DioError catch (err) {
      response = WrapperValue(
          statusCode: err.response?.statusCode,
          errMessage: "${err.response?.data}");
    }

    return response;
  }

  Future<WrapperValue> postFormData(
      {required String path, Map<String, dynamic>? request}) async {
    WrapperValue response;
    try {
      final res = await _dio.patch(path, data: FormData.fromMap(request!));
      if (res.data["statusCode"] as int == 200 && res.data["errorMessage"].toString().isEmpty) {
        response = WrapperValue.fromJson(res.data);
      } else {
        response =
            WrapperValue(statusCode: res.data["statusCode"] , errMessage: "${res.data}");
      }
    } on DioError catch (err) {
      response = WrapperValue(
          statusCode: err.response?.statusCode,
          errMessage: "${err.response?.data}");
    }
    return response;
  }
}

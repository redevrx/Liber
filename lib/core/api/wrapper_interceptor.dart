import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:liber/core/api/headers.dart';
import 'package:liber/core/store/data_store.dart';
import 'package:liber/core/store/store_key.dart';
import 'package:liber/data/models/authed/singing_response.dart';

import 'endpoint/auth_endpoint/auth_endpoint.dart';

class WrapperInterceptor extends Interceptor {
  final DataStore _dataStore = GetIt.instance.get<DataStore>();

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    debugPrint("api error code -> ${err.error} \ndata ->${err.response?.data}");
    super.onError(err, handler);
  }

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers.addAll(kHeader("${await _dataStore.get(kTokenKey)}"));
    debugPrint(
        "new request \nurl ->${options.uri}\nrequest data ->${options.data} \nheader ->${options.headers}");
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    debugPrint(
        "response code ->${response.statusCode}\nresponse data ->${response.data}");
    if (response.data["errorMessage"] == "Token End Session" &&
        response.statusCode == HttpStatus.unauthorized) {
      final token = await getRefreshToken();
      handler.resolve(await _retryIt(response.requestOptions, "$token"));
    }
    super.onResponse(response, handler);
  }

  Future<String?> getRefreshToken() async{
    final token = await _dataStore.get(kRefreshTokenKey);
    final response = await Dio().post('http://172.26.144.1:8080/api/v1/$refreshToken',data: Map.of({"refreshToken":"$token"}));

    if(response.statusCode == HttpStatus.ok){
      final data = SingInResponse.fromJson(response.data);
      _dataStore.keep(kTokenKey, data.accessToken);
      _dataStore.keep(kRefreshTokenKey, data.refreshToken);
      _dataStore.keep(kUserIdKet, data.userId);
      return data.accessToken;
    }
    return null;
  }

  Future<dynamic> _retryIt(RequestOptions requestOptions, String token) {
    return Dio().request(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options:
            Options(method: requestOptions.method, headers: kHeader(token)));
  }
}

import 'package:liber/utils/utils.dart';

class WrapperValue<T> {
  int? _statusCode;
  T? _value;
  String? _errMessage;

  WrapperValue({int? statusCode, String? errMessage, T? value})
      : _statusCode = statusCode,
        _value = value,
        _errMessage = errMessage;

  bool isDataActive() => (_value != null) ? true : false;

  bool isSuccess() => (!isError() && isDataActive()) ? true : false;

  bool isError() => (_errMessage != null && _errMessage != "")
      ? true
      : false;

  factory WrapperValue.fromJson(Map<String, dynamic> json) => WrapperValue<T>(
      statusCode: json['statusCode'],
      errMessage: json['errorMessage'],
      value: json['successMessage']);

  T? get value => _value;

  ///update data to generic class
  WrapperValue<R> copy<R>(R dataClass) => WrapperValue<R>(
      errMessage: _errMessage, statusCode: _statusCode, value: dataClass);
}

extension WrapperExtension<T> on WrapperValue<T> {
  void take(
      {required void Function(T value) success,
      void Function(String error, int code)? error}) {
    isSuccess() ? success(_value as T) : error!(_errMessage!, _statusCode!);
  }
}

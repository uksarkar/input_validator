library input_validator;

import 'dart:async';

import 'package:flutter/material.dart';

class InputValidator {
  /// Get errors in a `List<String>[]` or `false` for first error as `String`,
  /// default is `false`.
  final bool multiErrors;

  /// The given payload
  final dynamic value;

  /// Validation rules
  final String? rules;

  /// initial error messages
  final Map<String, dynamic> _errorMessages = {
    "required": "This field is required.",
    "min": "Provide at least :value.",
    "max": "Maximum limit is :value.",
    "numeric": "Invalid number input.",
    "size": "The size should be :value",
    "length": "The input should be :value characters.",
    "min_length": "Provide at least :value characters",
    "max_length": "Provide maximum :value characters",
    "email": "Invalid email address.",
    "in": "Only acceptable values are :value",
    "date": "Invalid date",
    "date_between": "Date out of range.",
    "date_before": "Provide older date.",
    "date_after": "Provide newer date.",
    "date_before_inclusive": "Provide older date.",
    "date_after_inlclusive": "Provide newer date.",
  };

  /// Check the given [payload] is `null`
  bool _isNull(dynamic payload) => payload == null;

  /// Convert the payload to `numeric` value
  double? _toNumeric(dynamic payload) => double.tryParse("$payload");

  /// Convert the payload to `DateTime` if possible
  DateTime? _toDate(dynamic payload) => DateTime.tryParse("$payload");

  /// Convert the payload to `String` value
  String _toString(dynamic payload) => !_isNull(payload) ? "$payload" : "";

  /// Check the [base] date is newer then [payload]
  bool _baseDateIsBigger(DateTime? base, DateTime? payload) {
    return base != null &&
        payload != null &&
        base.difference(payload).inMilliseconds > 0;
  }

  /// Check the [base] date is older then [payload]
  bool _baseDateIsSmaller(DateTime? base, DateTime? payload) {
    return base != null &&
        payload != null &&
        base.difference(payload).inMilliseconds < 0;
  }

  /// Check the [base] date is equal to [payload]
  bool _dateEqual(DateTime? base, DateTime? payload) {
    return base != null &&
        payload != null &&
        base.difference(payload).inDays == 0;
  }

  /// Get the message from defined `_errorMessages` by [key]
  /// and replace corresponding value.
  String? _getMsg(String key, {dynamic replace}) {
    return _errorMessages.containsKey(key)
        ? _errorMessages[key]
            ?.replaceFirst(RegExp(":value"), _toString(replace))
        : null;
  }

  /// handalers
  /// check required value
  String? _required() =>
      _toString(value).isNotEmpty ? null : _getMsg("required");

  /// check `value` is equal or greter then [min] value
  String? _min(dynamic min) {
    double? val = _toNumeric(value);
    double? m = _toNumeric(min);

    return val != null && m != null && m <= val
        ? null
        : _getMsg("min", replace: min);
  }

  /// check `value` is equal or smaller then [max] value
  String? _max(dynamic max) {
    double? val = _toNumeric(value);
    double? m = _toNumeric(max);

    return val != null && m != null && m >= val
        ? null
        : _getMsg("max", replace: max);
  }

  ///
  String? _size(dynamic size) {
    double? val = _toNumeric(value);
    double? s = _toNumeric(size);

    return val != null && s == val ? null : _getMsg("size", replace: size);
  }

  ///
  String? _length(dynamic length) {
    String val = _toString(value);
    dynamic l = _toNumeric(length);

    return val.isNotEmpty && l == val.length
        ? null
        : _getMsg("length", replace: length);
  }

  ///
  String? _minLength(dynamic length) {
    String val = _toString(value);
    dynamic l = _toNumeric(length);

    return val.isNotEmpty && l <= val.length
        ? null
        : _getMsg("min_length", replace: length);
  }

  ///
  String? _maxLength(dynamic length) {
    String val = _toString(value);
    dynamic l = _toNumeric(length);

    return val.isNotEmpty && l >= val.length
        ? null
        : _getMsg("max_length", replace: length);
  }

  ///
  String? _email() {
    RegExp regExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return value != null && regExp.hasMatch(value) ? null : _getMsg("email");
  }

  ///
  String? _numeric() {
    return !_isNull(_toNumeric(value)) ? null : _getMsg("numeric");
  }

  ///
  String? _in(List items) {
    return !_isNull(value) && items.contains("$value")
        ? null
        : _getMsg("in", replace: items);
  }

  ///
  String? _date() {
    return !_isNull(_toDate(value)) ? null : _getMsg("date");
  }

  ///
  String? _dateBetween(List? params) {
    var start = _toDate(params?.first);
    var end = _toDate(params?.last);
    var payload = _toDate(value);

    return _baseDateIsSmaller(start, payload) && _baseDateIsBigger(end, payload)
        ? null
        : _getMsg("date_between");
  }

  ///
  String? _dateAfter(List? params) {
    var base = _toDate(params?.first);
    var payload = _toDate(value);
    return _baseDateIsSmaller(base, payload) ? null : _getMsg("date_after");
  }

  ///
  String? _dateBefore(List? params) {
    var base = _toDate(params?.first);
    var payload = _toDate(value);
    return _baseDateIsBigger(base, payload) ? null : _getMsg("date_before");
  }

  String? _dateBeforeInclusive(List? params) {
    var base = _toDate(params?.first);
    var payload = _toDate(value);
    return _dateEqual(base, payload) || _baseDateIsBigger(base, payload)
        ? null
        : _getMsg("date_before_inclusive");
  }

  String? _dateAfterInclusive(List? params) {
    var base = _toDate(params?.first);
    var payload = _toDate(value);
    return _dateEqual(base, payload) || _baseDateIsSmaller(base, payload)
        ? null
        : _getMsg("date_before_inclusive");
  }

  ///validator initializer
  InputValidator.init({
    this.rules,
    required this.value,
    Map<String, dynamic>? messages,
    this.multiErrors = false,
  }) {
    /// initialize the messages
    if (messages != null) {
      this._errorMessages.addAll(messages);
    }
  }

  List<String>? _parseRules() {
    return rules?.split("|");
  }

  String _getRuleName(String payload) {
    return payload.split(":").first;
  }

  List<String> _getRuleParams(String payload) {
    var parsed = payload.split(":");
    return parsed.length > 1 ? parsed.last.split(",") : [];
  }

  List<String> _validator() {
    var parsed = _parseRules();
    if (parsed != null && parsed.isNotEmpty) {
      return parsed
          .map((r) {
            var ruleName = _getRuleName(r);
            var ruleParams = _getRuleParams(r);
            if (_errorMessages.containsKey(ruleName)) {
              var ruleMsgOrHandaler = _errorMessages[ruleName];
              if (ruleMsgOrHandaler is CustomHandler) {
                return ruleMsgOrHandaler.onHandle(
                  value,
                  ruleParams,
                );
              } else if (ruleMsgOrHandaler is String) {
                switch (ruleName) {
                  case "required":
                    return _required();
                  case "min":
                    return _min(ruleParams.first);
                  case "max":
                    return _max(ruleParams.first);
                  case "numeric":
                    return _numeric();
                  case "size":
                    return _size(ruleParams.first);
                  case "length":
                    return _length(ruleParams.first);
                  case "min_length":
                    return _minLength(ruleParams.first);
                  case "max_length":
                    return _maxLength(ruleParams.first);
                  case "email":
                    return _email();
                  case "in":
                    return _in(ruleParams);
                  case "date":
                    return _date();
                  case "date_between":
                    return _dateBetween(ruleParams);
                  case "date_before":
                    return _dateBefore(ruleParams);
                  case "date_after":
                    return _dateAfter(ruleParams);
                  case "date_before_inclusive":
                    return _dateBeforeInclusive(ruleParams);
                  case "date_after_inlclusive":
                    return _dateAfterInclusive(ruleParams);
                  default:
                    return null;
                }
              }
              return null;
            }
          })
          .whereType<String>()
          .toList();
    }
    return [];
  }

  /// validate the rules
  dynamic validate() {
    var messages = _validator();
    return multiErrors
        ? messages
        : messages.isNotEmpty
            ? messages.first
            : null;
  }

  /// validate a field with given rules
  static dynamic make({
    String? rules,
    required value,
    Map<String, dynamic>? messages,
    bool multiErrors = false,
  }) {
    var initiate = InputValidator.init(
      value: value,
      rules: rules,
      messages: messages,
      multiErrors: multiErrors,
    );

    return initiate.validate();
  }

  /// init the form fields with rules
  ///
  /// ```dart
  /// var _form = InputValidator.builder(fields: {
  ///   "phone": FieldData(rules: 'required|min_length:8', error: "Please fill it."),
  ///   "name": FieldData(rules: 'required|min_length:4'),
  /// });
  /// Container(child: _form.build(context, child:(_state) => .....))
  /// ```
  static _Builder builder({required Map<String, FieldData> fields}) {
    final _FormState _formState = _FormState(data: fields);

    return _Builder(_formState);
  }

  /// end of the class
}

class _Builder {
  final _FormState _state;

  _Builder(this._state);

  /// Build the form
  Widget build(
    BuildContext context, {
    required Widget Function(_FormState) child,
  }) {
    return StreamBuilder(
      stream: _state.stream,
      builder: (BuildContext context, _) {
        return child(_state);
      },
    );
  }

  /// dispose the form stream
  dispose() {
    _state.dispose();
  }
}

class _FormState {
  final StreamController _controller = StreamController.broadcast();
  final Map<String, FieldData> data;
  String _state = "STABLE";

  _FormState({required this.data});

  /// stream of the form
  Stream<dynamic> get stream => _controller.stream;

  /// custom state of the form
  String get currentState => _state;

  /// currently added any error or all error fields are null
  bool get hasError =>
      data.values.map((e) => e.error).whereType<String>().isNotEmpty;

  /// if all fields are satisfy the rules then return true or false
  bool get isValid =>
      data.keys.map((e) => checkField(e)).whereType<String>().isEmpty;

  /// get data of the field
  Map<String, dynamic> get formData =>
      data.map((key, d) => MapEntry(key, d.value));

  /// set custom state
  set setState(String value) {
    _state = value;
    _controller.sink.add("listen");
  }

  /// add data to the field
  /// and return true if the data match the rules
  bool add(String field, dynamic value) {
    if (data.containsKey(field)) {
      var item = data[field];
      if (item != null) {
        item.value = value;
        item.error = InputValidator.make(
          rules: item.rules,
          messages: item.messages,
          value: value,
        );
        _controller.sink.add("listen");

        return item.error == null;
      }
    } else {
      print("Invalid field name");
    }
    return false;
  }

  /// get the error of a field
  String? getError(String field) {
    if (data.containsKey(field)) {
      var item = data[field];
      return item?.error;
    }
    return null;
  }

  /// explicitly set error to any field
  void setError(String field, String? error) {
    if (data.containsKey(field)) {
      var item = data[field];
      item?.error = error;
    }
  }

  /// check specific field if there is any error
  /// if the field dosn't exits then will return `null`
  String? checkField(String field) {
    if (data.containsKey(field)) {
      var item = data[field];
      return item != null
          ? InputValidator.make(
              rules: item.rules,
              messages: item.messages,
              value: item.value,
            )
          : null;
    }
    return null;
  }

  /// clear all errors from the UI
  void clearErrors() {
    data.keys.forEach((k) {
      var item = data[k];
      item?.error = null;
    });
    _controller.sink.add("listen");
  }

  /// check all the provided data and corrosponding rules
  /// if all rules are satisfied the it will clear UI errors
  /// and return true otherwise it'll update the UI with errors
  /// and return false
  bool validate() {
    Map<String, FieldData> newData = data.map((k, v) {
      var error = checkField(k);
      return MapEntry(
        k,
        FieldData(
          value: v.value,
          rules: v.rules,
          error: error,
          messages: v.messages,
        ),
      );
    });

    bool isValid =
        newData.values.map((e) => e.error).whereType<String>().isEmpty;

    data.addAll(newData);

    if (!isValid) {
      _controller.sink.add("listen");
    }

    return isValid;
  }

  /// Building form via builder create a stream instence
  /// make sure that you close the stream instence
  dispose() {
    _controller.close();
  }
}

class FieldData {
  final String? rules;
  final Map<String, dynamic>? messages;
  dynamic value;
  String? error;

  /// [rules] - Provide valid rules,
  /// [value] - Initail value of the field,
  /// [messages] - Custom messages,
  /// [error] - Initial error of the field
  ///
  /// ```dart
  /// const fields = {
  ///  "age": FieldData(rules: 'required|min:18', vlaue: 19),
  ///  "phone": FieldData(rules: 'required|min_length:8', error: "Please fill it."),
  /// }
  /// ```
  FieldData({
    required this.rules,
    this.value,
    this.messages,
    this.error,
  });

  @override
  String toString() {
    return '{rules: $rules, value: $value, error: $error}';
  }
}

class CustomHandler {
  /// [payload] - the input value
  /// [params] - the rules params (if provided any)
  ///
  /// ```dart
  /// /// "required|in:1,2,3"
  /// onHandle(payload, params){
  ///   print(payload); /// will print the input
  ///   print(params) /// [1,2,3]
  ///   return null;
  /// }
  /// ```
  final String? Function(dynamic payload, List<String> params) onHandle;
  CustomHandler({required this.onHandle});
}

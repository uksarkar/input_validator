library input_validator;

class InputValidator {
  final bool multiErrors;
  final dynamic? value;
  final String? rules;

  /// initial error messages
  final Map<String, dynamic> _errorMessages = {
    "required": "This field is required.",
    "min": "Provide at least :value.",
    "max": "Maximum limit is :value.",
    "between": "Out of range.",
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

  /// helpers
  bool _isNull(dynamic? payload) => payload == null;
  double? _toNumeric(dynamic? payload) => double.tryParse("$payload");
  DateTime? _toDate(dynamic? payload) => DateTime.tryParse("$payload");
  String _toString(dynamic? payload) => !_isNull(payload) ? "$payload" : "";

  bool _baseDateIsBigger(DateTime? base, DateTime? payload) {
    return base != null &&
        payload != null &&
        base.difference(payload).inMilliseconds > 0;
  }

  bool _baseDateIsSmaller(DateTime? base, DateTime? payload) {
    return base != null &&
        payload != null &&
        base.difference(payload).inMilliseconds < 0;
  }

  bool _dateEqual(DateTime? base, DateTime? payload) {
    return base != null &&
        payload != null &&
        base.difference(payload).inDays == 0;
  }

  String? _getMsg(String key, {dynamic? replace}) {
    return _errorMessages.containsKey(key)
        ? _errorMessages[key]?.replaceFirst(RegExp(":value"), "$replace")
        : null;
  }

  /// handalers
  /// check required value
  String? _required() =>
      _toString(value).isNotEmpty ? null : _getMsg("required");

  /// check minimum
  String? _min(dynamic min) {
    double? val = _toNumeric(value);
    double? m = _toNumeric(min);

    return val != null && m != null && m <= val
        ? null
        : _getMsg("min", replace: min);
  }

  /// check maximum
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
    dynamic? l = _toNumeric(length);

    return val.isNotEmpty && l == val.length
        ? null
        : _getMsg("length", replace: length);
  }

  ///
  String? _minLength(dynamic length) {
    String val = _toString(value);
    dynamic? l = _toNumeric(length);

    return val.isNotEmpty && l <= val.length
        ? null
        : _getMsg("min_length", replace: length);
  }

  ///
  String? _maxLength(dynamic length) {
    String val = _toString(value);
    dynamic? l = _toNumeric(length);

    return val.isNotEmpty && l >= val.length
        ? null
        : _getMsg("max_length", replace: length);
  }

  ///
  String? _email() {
    bool isValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    return isValid ? null : _getMsg("email");
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

  dynamic? validate() {
    var messages = _validator();
    return multiErrors
        ? messages
        : messages.isNotEmpty
            ? messages.first
            : null;
  }

  static dynamic? make({
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

  /// end of the class
}

class CustomHandler {
  final String? Function(dynamic? payload, List<String> params) onHandle;
  CustomHandler({required this.onHandle});
}
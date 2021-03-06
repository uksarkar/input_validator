# Input Validator

Validate input value with an efficient way.

## Installation

Run this command:

```bash
flutter pub add input_validator
```

## Usages

The `make` method will return `null` if the validation passed.

```dart
    /// import 'package:input_validator/input_validator.dart';
    /// here is a basic example
    InputValidator.make(rules:"required|min_length:6",value:"password");
```

#### Rules

rules parameter is a string that guide what to do with the value. You can provide as many as posable rules, which should be separated by `|` sign. Some rules required extra params like `rule:param,param`, here parameters are separated by comma. A quick example: you want to get user gender in male,female or other, so it would be like `in:male,female,other`. See [Available Validation Rules](#available-validation-rules) and explanation.

#### Value

The value is the given payload for validation.

## Customizing Validation Messages

You can pass `messages` parameter to the make method. It accept `Map<String, dynamic>`. The messages key should match with rule name. The message value should be either `String` or [CustomHandler](#custom-rule).
Example:

```dart
    InputValidator.make(
        rules:"required|min_length:6",
        value:null,
        messages:{
            "required": "Password is required."
        },
    );
```

## Custom Rule

Here is an example of custom rule.

```dart
    /// A strong password validation,
    /// Minimum 1 Upper case
    /// Minimum 1 lowercase
    /// Minimum 1 Numeric Number
    /// Minimum 1 Special Character
    /// Common Allow Character ( ! @ # $ & \* ~ )
    InputValidator.make(
        rules:"strongPassword",
        value:null,
        messages:{
            "strongPassword": CustomHandler(onHandle: (payload, _) {
                String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
                RegExp regExp = new RegExp(pattern);
                return regExp.hasMatch(payload) ? null:"Invalid password!";
            })
        },
    );
```

## Form builder

Build form via form builder. See the full example on the example tab.
```dart
    var _form = InputValidator.builder(
        fields: {
                    "full_name": FieldData(rules: "required|min_length:4"),
                    "username": FieldData(rules: "required|min_length:4"),
                    "age": FieldData(rules: "required|min:10"),
                },
        );

    Container(
        child: _form.build(context, child: (state) => ....)
    )
```

## Available Validation Rules

Below is a list of all available validation rules and their function:

[Required](#required),
[Min (Number)](#min),
[Max (Number)](#Max),
[Numeric (Number)](#numeric),
[Size (Number)](#size),
[Length (String)](#length),
[Max Length (String)](#max-length),
[Min Length (String)](#min-length),
[Email](#email),
[In](#in),
[Date](#date),
[Date Between](#date-between),
[Date Before](#date-before),
[Date After](#date-after),
[Date Before Inclusive](#date-before-inclusive),
[Date After Inclusive](#date-after-inclusive),
[Custom Rule](#custom-rule),

### Required

The field under validation must be present in the input data and not empty. A field is considered "empty" if one of the following conditions are true:

    The value is null.
    The value is an empty string.

### Min

The field under validation must have a minimum value and not empty and the value should be convertible to numeric value.

```dart
// example
InputValidator.make(value: "5", rules: "min:10");
// reuslt: Provide at least 10.
```

### Max

The field under validation must have a maximum value and not empty and the value should be convertible to numeric value.

```dart
// example
InputValidator.make(value: "15", rules: "max:10");
// reuslt: Maximum limit is 10.
```

### Numeric

The field under validation must be convertible to a numeric value.

```dart
// example
InputValidator.make(value: "abc", rules: "numeric");
// reuslt: Invalid number input.
```

### Size

The field under validation must be convertible to a numeric value and exec as the given size.

```dart
// example
InputValidator.make(value: "5", rules: "size:10");
// reuslt: The size should be 10.
```

### Length

It will call the `toString()` method on the value and check the length of the string and match with the given length.

```dart
// example
InputValidator.make(value: "5", rules: "length:10");
// reuslt: The input should be 10 characters.
```

### Min Length

It will call the `toString()` method on the value and check the length of the string and match with the given length.

```dart
// example
InputValidator.make(value: "5", rules: "min_length:10");
// reuslt: Provide at least 5 characters
```

### Max Length

It will call the `toString()` method on the value and check the length of the string and match with the given length.

```dart
// example
InputValidator.make(value: "15", rules: "max_length:10");
// reuslt: Provide maximum 10 characters
```

### Email

It will check with a RegEx pattern. You can customize the pattern by override the [custom handler](#custom-rule).

```dart
// example
InputValidator.make(value: "example@gmail", rules: "email");
// reuslt: Invalid email address.
```

### In

The field under validation must be included in the given list of values.

```dart
// example
InputValidator.make(value: "world", rules: "in:1,hello,world");
// reuslt: null
```

### Date

Valid date that could be parsed with `DateTime.parse()`

```dart
// example
InputValidator.make(value: "date", rules: "date");
// reuslt: Invalid date
```

### Date Between

Valid date that could be parsed with `DateTime.parse()`. It will make sure that the given date is newer then minimum date and older then maximum date.

```dart
// example 'date_between:min,max'
InputValidator.make(value: "2021-04-10", rules: "date_between:2021-05-17,2021-07-17");
// reuslt: Date out of range.
```

### Date Before

Valid date that could be parsed with `DateTime.parse()`. It will make sure that the given date is older then checking date. Also you can try [Date Before Inclusive](#date-before-inclusive).

```dart
// example 'date_before:date'
InputValidator.make(value: "2021-04-10", rules: "date_between:2021-05-17");
// reuslt: null
```

### Date After

Valid date that could be parsed with `DateTime.parse()`. It will make sure that the given date is newer then checking date. Also you can try [Date After Inclusive](#date-after-inclusive).

```dart
// example 'date_after:date'
InputValidator.make(value: "2021-04-10", rules: "date_after:2021-05-17");
// reuslt: Provide newer date.
```

### Date After Inclusive

Valid date that could be parsed with `DateTime.parse()`. It will make sure that the given date is newer or equal to the checking date.

```dart
// example 'date_after_inclusive:date'
InputValidator.make(value: "2021-05-17", rules: "date_after_inclusive:2021-05-17");
// reuslt: null
```

### Date Before Inclusive

Valid date that could be parsed with `DateTime.parse()`. It will make sure that the given date is older or equal to the checking date.

```dart
// example 'date_before_inclusive:date'
InputValidator.make(value: "2021-05-17", rules: "date_before_inclusive:2021-05-17");
// reuslt: null
```

## License

[MIT](https://choosealicense.com/licenses/mit/)

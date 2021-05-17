import 'package:flutter_test/flutter_test.dart';

import 'package:input_validator/input_validator.dart';

void main() {
  test('Required checkup.', () {
    expect(
      InputValidator.make(rules: "required", value: "Utpal Sarkar"),
      null,
    );
    expect(
      InputValidator.make(rules: "required", value: null),
      "This field is required.",
    );
    expect(
      InputValidator.make(rules: "required", value: ""),
      "This field is required.",
    );
    expect(
      InputValidator.make(rules: "required", value: "", multiErrors: true),
      ["This field is required."],
    );
  });

  test('Min value checkup.', () {
    expect(InputValidator.make(rules: "min:5", value: "10"), null);
    expect(
      InputValidator.make(rules: "min:5", value: null),
      "Provide at least 5.",
    );
    expect(InputValidator.make(rules: "min:5", value: 5), null);
    expect(
      InputValidator.make(rules: "min:5", value: 4),
      "Provide at least 5.",
    );
  });

  test('Mix check up', () {
    expect(
      InputValidator.make(rules: "required|min:5|max:10", value: "10"),
      null,
    );
    expect(
      InputValidator.make(rules: "required|min:5|max:10", value: null),
      "This field is required.",
    );
    expect(
      InputValidator.make(rules: "required|min:5|max:10", value: 15),
      "Maximum limit is 10.",
    );
    expect(
      InputValidator.make(
        rules: "required|min:5|max:10",
        value: 4,
        messages: {"min": "Sorry minimum 5 is required."},
      ),
      "Sorry minimum 5 is required.",
    );

    expect(
      InputValidator.make(
        rules: "required|in:1,2,3",
        value: 3,
      ),
      null,
    );
  });
  test('Custom validator checkup', () {
    expect(
      InputValidator.make(rules: "custom", value: "10", messages: {
        "custom": CustomHandler(onHandle: (payload, _) {
          return "Hello world.";
        })
      }),
      "Hello world.",
    );
  });
  test('Overide rule', () {
    expect(
      InputValidator.make(rules: "required", value: "10", messages: {
        "required": CustomHandler(
          onHandle: (payload, _) {
            return "Whatever!";
          },
        )
      }),
      "Whatever!",
    );
  });
}

class ReactionTrial {
  final int trialNumber;
  final String stimulusColor;
  final String expectedFinger;
  final String? responseFinger;
  final double reactionTimeMs;
  final bool isCorrect;

  ReactionTrial({
    required this.trialNumber,
    required this.stimulusColor,
    required this.expectedFinger,
    this.responseFinger,
    required this.reactionTimeMs,
    required this.isCorrect,
  });

  factory ReactionTrial.fromJson(Map<String, dynamic> json) {
    return ReactionTrial(
      trialNumber: json['trial_number'],
      stimulusColor: json['stimulus_color'],
      expectedFinger: json['expected_finger'],
      responseFinger: json['response_finger'],
      reactionTimeMs: json['reaction_time_ms'].toDouble(),
      isCorrect: json['is_correct'],
    );
  }
}

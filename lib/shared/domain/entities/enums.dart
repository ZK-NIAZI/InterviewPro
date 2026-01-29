/// Enumeration for developer roles
enum Role {
  flutter,
  backend,
  frontend,
  fullStack,
  mobile;

  /// Gets a display-friendly name for the role
  String get displayName {
    switch (this) {
      case Role.flutter:
        return 'Flutter Developer';
      case Role.backend:
        return 'Backend Developer';
      case Role.frontend:
        return 'Frontend Developer';
      case Role.fullStack:
        return 'Full Stack Developer';
      case Role.mobile:
        return 'Mobile Developer';
    }
  }

  /// Gets a short description of the role
  String get description {
    switch (this) {
      case Role.flutter:
        return 'Cross-platform mobile app development with Flutter';
      case Role.backend:
        return 'Server-side development and API design';
      case Role.frontend:
        return 'User interface and web application development';
      case Role.fullStack:
        return 'Both frontend and backend development';
      case Role.mobile:
        return 'Native and cross-platform mobile development';
    }
  }

  /// Creates a Role from a string value
  static Role fromString(String value) {
    return Role.values.firstWhere(
      (role) => role.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid role: $value'),
    );
  }
}

/// Enumeration for experience levels
enum Level {
  intern,
  associate,
  senior;

  /// Gets a display-friendly name for the level
  String get displayName {
    switch (this) {
      case Level.intern:
        return 'Intern';
      case Level.associate:
        return 'Associate';
      case Level.senior:
        return 'Senior';
    }
  }

  /// Gets a description of the experience level
  String get description {
    switch (this) {
      case Level.intern:
        return 'Entry-level position, learning fundamentals';
      case Level.associate:
        return 'Mid-level position, solid foundation with some experience';
      case Level.senior:
        return 'Senior position, extensive experience and leadership';
    }
  }

  /// Gets the years of experience typically associated with this level
  String get experienceRange {
    switch (this) {
      case Level.intern:
        return '0-1 years';
      case Level.associate:
        return '2-5 years';
      case Level.senior:
        return '5+ years';
    }
  }

  /// Creates a Level from a string value
  static Level fromString(String value) {
    return Level.values.firstWhere(
      (level) => level.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid level: $value'),
    );
  }
}

/// Enumeration for question categories
enum QuestionCategory {
  programmingFundamentals,
  roleSpecificTechnical,
  modernDevelopmentPractices,
  softSkills;

  /// Gets a display-friendly name for the category
  String get displayName {
    switch (this) {
      case QuestionCategory.programmingFundamentals:
        return 'Programming Fundamentals';
      case QuestionCategory.roleSpecificTechnical:
        return 'Role-Specific Technical';
      case QuestionCategory.modernDevelopmentPractices:
        return 'Modern Development Practices';
      case QuestionCategory.softSkills:
        return 'Soft Skills';
    }
  }

  /// Gets a description of the question category
  String get description {
    switch (this) {
      case QuestionCategory.programmingFundamentals:
        return 'Basic programming concepts, data structures, and algorithms';
      case QuestionCategory.roleSpecificTechnical:
        return 'Technical questions specific to the selected role';
      case QuestionCategory.modernDevelopmentPractices:
        return 'Modern development practices, tools, and methodologies';
      case QuestionCategory.softSkills:
        return 'Communication, teamwork, and problem-solving skills';
    }
  }

  /// Gets a short code for the category
  String get code {
    switch (this) {
      case QuestionCategory.programmingFundamentals:
        return 'PF';
      case QuestionCategory.roleSpecificTechnical:
        return 'RST';
      case QuestionCategory.modernDevelopmentPractices:
        return 'MDP';
      case QuestionCategory.softSkills:
        return 'SS';
    }
  }

  /// Creates a QuestionCategory from a string value
  static QuestionCategory fromString(String value) {
    return QuestionCategory.values.firstWhere(
      (category) => category.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid question category: $value'),
    );
  }
}

/// Enumeration for interview status
enum InterviewStatus {
  notStarted,
  inProgress,
  completed,
  cancelled;

  /// Gets a display-friendly name for the status
  String get displayName {
    switch (this) {
      case InterviewStatus.notStarted:
        return 'Not Started';
      case InterviewStatus.inProgress:
        return 'In Progress';
      case InterviewStatus.completed:
        return 'Completed';
      case InterviewStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Gets a description of the interview status
  String get description {
    switch (this) {
      case InterviewStatus.notStarted:
        return 'Interview has been scheduled but not yet started';
      case InterviewStatus.inProgress:
        return 'Interview is currently active';
      case InterviewStatus.completed:
        return 'Interview has been completed successfully';
      case InterviewStatus.cancelled:
        return 'Interview was cancelled before completion';
    }
  }

  /// Checks if the interview can be started
  bool get canStart => this == InterviewStatus.notStarted;

  /// Checks if the interview can be resumed
  bool get canResume => this == InterviewStatus.inProgress;

  /// Checks if the interview is finished (completed or cancelled)
  bool get isFinished =>
      this == InterviewStatus.completed || this == InterviewStatus.cancelled;

  /// Creates an InterviewStatus from a string value
  static InterviewStatus fromString(String value) {
    return InterviewStatus.values.firstWhere(
      (status) => status.name.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid interview status: $value'),
    );
  }
}

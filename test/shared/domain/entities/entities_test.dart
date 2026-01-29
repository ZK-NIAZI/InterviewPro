import 'package:flutter_test/flutter_test.dart';
import 'package:interview_pro_app/shared/domain/entities/entities.dart';

void main() {
  group('Core Entities Tests', () {
    group('Enums', () {
      test('Role enum should have correct display names', () {
        expect(Role.flutter.displayName, 'Flutter Developer');
        expect(Role.backend.displayName, 'Backend Developer');
        expect(Role.frontend.displayName, 'Frontend Developer');
        expect(Role.fullStack.displayName, 'Full Stack Developer');
        expect(Role.mobile.displayName, 'Mobile Developer');
      });

      test('Level enum should have correct display names', () {
        expect(Level.intern.displayName, 'Intern');
        expect(Level.associate.displayName, 'Associate');
        expect(Level.senior.displayName, 'Senior');
      });

      test('QuestionCategory enum should have correct display names', () {
        expect(
          QuestionCategory.programmingFundamentals.displayName,
          'Programming Fundamentals',
        );
        expect(
          QuestionCategory.roleSpecificTechnical.displayName,
          'Role-Specific Technical',
        );
        expect(
          QuestionCategory.modernDevelopmentPractices.displayName,
          'Modern Development Practices',
        );
        expect(QuestionCategory.softSkills.displayName, 'Soft Skills');
      });

      test('InterviewStatus enum should have correct display names', () {
        expect(InterviewStatus.notStarted.displayName, 'Not Started');
        expect(InterviewStatus.inProgress.displayName, 'In Progress');
        expect(InterviewStatus.completed.displayName, 'Completed');
        expect(InterviewStatus.cancelled.displayName, 'Cancelled');
      });
    });

    group('QuestionResponse', () {
      test('should create QuestionResponse with required fields', () {
        final timestamp = DateTime.now();
        final response = QuestionResponse(
          questionId: 'q1',
          isCorrect: true,
          timestamp: timestamp,
        );

        expect(response.questionId, 'q1');
        expect(response.isCorrect, true);
        expect(response.notes, null);
        expect(response.timestamp, timestamp);
        expect(response.hasNotes, false);
        expect(response.resultText, 'Correct');
      });

      test('should create QuestionResponse with notes', () {
        final timestamp = DateTime.now();
        final response = QuestionResponse(
          questionId: 'q1',
          isCorrect: false,
          notes: 'Candidate struggled with the concept',
          timestamp: timestamp,
        );

        expect(response.hasNotes, true);
        expect(response.resultText, 'Incorrect');
        expect(
          response.summary,
          'Incorrect - Candidate struggled with the concept',
        );
      });

      test('should support copyWith', () {
        final timestamp = DateTime.now();
        final original = QuestionResponse(
          questionId: 'q1',
          isCorrect: false,
          timestamp: timestamp,
        );

        final updated = original.copyWith(
          isCorrect: true,
          notes: 'Good answer',
        );

        expect(updated.questionId, 'q1');
        expect(updated.isCorrect, true);
        expect(updated.notes, 'Good answer');
        expect(updated.timestamp, timestamp);
      });
    });

    group('Question', () {
      test('should create Question with required fields', () {
        final question = Question(
          id: 'q1',
          text: 'What is Flutter?',
          category: QuestionCategory.programmingFundamentals,
          applicableRoles: [Role.flutter, Role.mobile],
          difficulty: Level.intern,
          tags: ['flutter', 'basics'],
        );

        expect(question.id, 'q1');
        expect(question.text, 'What is Flutter?');
        expect(question.category, QuestionCategory.programmingFundamentals);
        expect(question.applicableRoles, [Role.flutter, Role.mobile]);
        expect(question.difficulty, Level.intern);
        expect(question.tags, ['flutter', 'basics']);
        expect(question.expectedAnswer, null);
      });

      test('should check role applicability correctly', () {
        final question = Question(
          id: 'q1',
          text: 'What is Flutter?',
          category: QuestionCategory.programmingFundamentals,
          applicableRoles: [Role.flutter, Role.mobile],
          difficulty: Level.intern,
          tags: ['flutter'],
        );

        expect(question.isApplicableForRole(Role.flutter), true);
        expect(question.isApplicableForRole(Role.mobile), true);
        expect(question.isApplicableForRole(Role.backend), false);
      });

      test('should check suitability for role and level', () {
        final question = Question(
          id: 'q1',
          text: 'What is Flutter?',
          category: QuestionCategory.programmingFundamentals,
          applicableRoles: [Role.flutter],
          difficulty: Level.intern,
          tags: ['flutter'],
        );

        expect(question.isSuitableFor(Role.flutter, Level.intern), true);
        expect(question.isSuitableFor(Role.flutter, Level.senior), false);
        expect(question.isSuitableFor(Role.backend, Level.intern), false);
      });
    });

    group('Interview', () {
      test('should create Interview with required fields', () {
        final startTime = DateTime.now();
        final responses = <QuestionResponse>[];

        final interview = Interview(
          id: 'i1',
          candidateName: 'John Doe',
          role: Role.flutter,
          level: Level.associate,
          startTime: startTime,
          responses: responses,
          status: InterviewStatus.notStarted,
        );

        expect(interview.id, 'i1');
        expect(interview.candidateName, 'John Doe');
        expect(interview.role, Role.flutter);
        expect(interview.level, Level.associate);
        expect(interview.startTime, startTime);
        expect(interview.endTime, null);
        expect(interview.responses, responses);
        expect(interview.status, InterviewStatus.notStarted);
        expect(interview.overallScore, null);
      });

      test('should calculate duration correctly', () {
        final startTime = DateTime.now();
        final endTime = startTime.add(const Duration(hours: 1, minutes: 30));

        final interview = Interview(
          id: 'i1',
          candidateName: 'John Doe',
          role: Role.flutter,
          level: Level.associate,
          startTime: startTime,
          endTime: endTime,
          responses: [],
          status: InterviewStatus.completed,
        );

        expect(interview.duration, const Duration(hours: 1, minutes: 30));
      });

      test('should check status correctly', () {
        final interview = Interview(
          id: 'i1',
          candidateName: 'John Doe',
          role: Role.flutter,
          level: Level.associate,
          startTime: DateTime.now(),
          responses: [],
          status: InterviewStatus.completed,
        );

        expect(interview.isCompleted, true);
        expect(interview.isInProgress, false);
      });

      test('should support copyWith', () {
        final startTime = DateTime.now();
        final original = Interview(
          id: 'i1',
          candidateName: 'John Doe',
          role: Role.flutter,
          level: Level.associate,
          startTime: startTime,
          responses: [],
          status: InterviewStatus.notStarted,
        );

        final updated = original.copyWith(
          status: InterviewStatus.inProgress,
          overallScore: 85.5,
        );

        expect(updated.id, 'i1');
        expect(updated.candidateName, 'John Doe');
        expect(updated.status, InterviewStatus.inProgress);
        expect(updated.overallScore, 85.5);
        expect(updated.startTime, startTime);
      });
    });
  });
}

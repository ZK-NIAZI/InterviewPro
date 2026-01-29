import '../../domain/entities/entities.dart';
import '../../domain/repositories/question_repository.dart';

/// Service for initializing default question bank on first app launch
class DefaultQuestionBankService {
  final QuestionRepository _questionRepository;

  DefaultQuestionBankService(this._questionRepository);

  /// Initialize default questions if the question bank is empty
  Future<void> initializeDefaultQuestions() async {
    final questionCount = await _questionRepository.getQuestionCount();

    // Only initialize if no questions exist
    if (questionCount == 0) {
      final defaultQuestions = _createDefaultQuestions();
      await _questionRepository.saveQuestions(defaultQuestions);
    }
  }

  /// Create comprehensive default questions for all categories, roles, and levels
  List<Question> _createDefaultQuestions() {
    final List<Question> questions = [];

    // Programming Fundamentals Questions
    questions.addAll(_createProgrammingFundamentalsQuestions());

    // Role-Specific Technical Questions
    questions.addAll(_createRoleSpecificTechnicalQuestions());

    // Modern Development Practices Questions
    questions.addAll(_createModernDevelopmentPracticesQuestions());

    // Soft Skills Questions
    questions.addAll(_createSoftSkillsQuestions());

    return questions;
  }

  /// Create Programming Fundamentals questions
  List<Question> _createProgrammingFundamentalsQuestions() {
    return [
      // Intern Level - Programming Fundamentals
      Question(
        id: 'pf_intern_001',
        text: 'What is the difference between a variable and a constant?',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.intern,
        expectedAnswer:
            'A variable can be changed after initialization, while a constant cannot be modified once set.',
        tags: ['variables', 'constants', 'basics'],
      ),
      Question(
        id: 'pf_intern_002',
        text:
            'Explain what an array is and give an example of when you would use one.',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.intern,
        expectedAnswer:
            'An array is a collection of elements of the same type. Use when storing multiple related values like a list of names.',
        tags: ['arrays', 'data-structures', 'collections'],
      ),
      Question(
        id: 'pf_intern_003',
        text: 'What is a loop and why would you use one?',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.intern,
        expectedAnswer:
            'A loop repeats code multiple times. Use to avoid code duplication and process collections.',
        tags: ['loops', 'iteration', 'control-flow'],
      ),
      Question(
        id: 'pf_intern_004',
        text: 'What is the difference between == and === in programming?',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: [Role.frontend, Role.fullStack, Role.backend],
        difficulty: Level.intern,
        expectedAnswer:
            '== compares values with type coercion, === compares values and types strictly.',
        tags: ['comparison', 'operators', 'types'],
      ),
      Question(
        id: 'pf_intern_005',
        text: 'What is a function and why are functions useful?',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.intern,
        expectedAnswer:
            'A function is a reusable block of code. Functions promote code reuse, organization, and maintainability.',
        tags: ['functions', 'code-organization', 'reusability'],
      ),

      // Associate Level - Programming Fundamentals
      Question(
        id: 'pf_associate_001',
        text: 'Explain the concept of Big O notation and why it matters.',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.associate,
        expectedAnswer:
            'Big O describes algorithm efficiency in terms of time/space complexity as input size grows.',
        tags: ['algorithms', 'complexity', 'performance'],
      ),
      Question(
        id: 'pf_associate_002',
        text: 'What is the difference between a stack and a queue?',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.associate,
        expectedAnswer:
            'Stack is LIFO (Last In, First Out), queue is FIFO (First In, First Out).',
        tags: ['data-structures', 'stack', 'queue'],
      ),
      Question(
        id: 'pf_associate_003',
        text: 'Explain what recursion is and provide a simple example.',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.associate,
        expectedAnswer:
            'Recursion is when a function calls itself. Example: factorial calculation.',
        tags: ['recursion', 'algorithms', 'functions'],
      ),
      Question(
        id: 'pf_associate_004',
        text: 'What are the main principles of Object-Oriented Programming?',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.associate,
        expectedAnswer:
            'Encapsulation, Inheritance, Polymorphism, and Abstraction.',
        tags: ['oop', 'principles', 'design'],
      ),
      Question(
        id: 'pf_associate_005',
        text:
            'Explain the difference between synchronous and asynchronous programming.',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.associate,
        expectedAnswer:
            'Synchronous blocks execution until complete, asynchronous allows other operations to continue.',
        tags: ['async', 'sync', 'concurrency'],
      ),

      // Senior Level - Programming Fundamentals
      Question(
        id: 'pf_senior_001',
        text:
            'Describe different types of design patterns and when to use them.',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.senior,
        expectedAnswer:
            'Creational (Singleton, Factory), Structural (Adapter, Decorator), Behavioral (Observer, Strategy).',
        tags: ['design-patterns', 'architecture', 'best-practices'],
      ),
      Question(
        id: 'pf_senior_002',
        text:
            'Explain SOLID principles and their importance in software design.',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.senior,
        expectedAnswer:
            'Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.',
        tags: ['solid', 'principles', 'clean-code'],
      ),
      Question(
        id: 'pf_senior_003',
        text: 'What are the trade-offs between different sorting algorithms?',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.senior,
        expectedAnswer:
            'Quick sort: fast average case but O(n²) worst case. Merge sort: consistent O(n log n) but uses more memory.',
        tags: ['algorithms', 'sorting', 'trade-offs'],
      ),
      Question(
        id: 'pf_senior_004',
        text: 'Explain memory management and garbage collection concepts.',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: Role.values,
        difficulty: Level.senior,
        expectedAnswer:
            'Memory allocation/deallocation, automatic garbage collection, memory leaks, reference counting.',
        tags: ['memory', 'garbage-collection', 'performance'],
      ),
      Question(
        id: 'pf_senior_005',
        text:
            'Describe the CAP theorem and its implications for distributed systems.',
        category: QuestionCategory.programmingFundamentals,
        applicableRoles: [Role.backend, Role.fullStack],
        difficulty: Level.senior,
        expectedAnswer:
            'Consistency, Availability, Partition tolerance - can only guarantee two of three in distributed systems.',
        tags: ['distributed-systems', 'cap-theorem', 'architecture'],
      ),
    ];
  }

  /// Create Role-Specific Technical questions
  List<Question> _createRoleSpecificTechnicalQuestions() {
    final List<Question> questions = [];

    // Flutter Developer Questions
    questions.addAll(_createFlutterQuestions());

    // Backend Developer Questions
    questions.addAll(_createBackendQuestions());

    // Frontend Developer Questions
    questions.addAll(_createFrontendQuestions());

    // Full Stack Developer Questions
    questions.addAll(_createFullStackQuestions());

    // Mobile Developer Questions
    questions.addAll(_createMobileQuestions());

    return questions;
  }

  /// Create Flutter-specific questions
  List<Question> _createFlutterQuestions() {
    return [
      // Intern Level - Flutter
      Question(
        id: 'flutter_intern_001',
        text:
            'What is Flutter and what makes it different from other mobile frameworks?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.flutter, Role.mobile, Role.fullStack],
        difficulty: Level.intern,
        expectedAnswer:
            'Flutter is Google\'s UI toolkit for cross-platform development using a single codebase.',
        tags: ['flutter', 'cross-platform', 'basics'],
      ),
      Question(
        id: 'flutter_intern_002',
        text:
            'What is the difference between StatelessWidget and StatefulWidget?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.flutter, Role.mobile],
        difficulty: Level.intern,
        expectedAnswer:
            'StatelessWidget doesn\'t change, StatefulWidget can rebuild when state changes.',
        tags: ['widgets', 'state', 'flutter'],
      ),
      Question(
        id: 'flutter_intern_003',
        text: 'What is the widget tree in Flutter?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.flutter, Role.mobile],
        difficulty: Level.intern,
        expectedAnswer:
            'A hierarchical structure of widgets that describes the UI layout and behavior.',
        tags: ['widget-tree', 'ui', 'flutter'],
      ),

      // Associate Level - Flutter
      Question(
        id: 'flutter_associate_001',
        text:
            'Explain the Flutter rendering pipeline and how widgets are rendered.',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.flutter, Role.mobile],
        difficulty: Level.associate,
        expectedAnswer:
            'Widget tree → Element tree → Render tree → Painting and compositing.',
        tags: ['rendering', 'performance', 'flutter'],
      ),
      Question(
        id: 'flutter_associate_002',
        text: 'What are the different state management approaches in Flutter?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.flutter, Role.mobile],
        difficulty: Level.associate,
        expectedAnswer: 'setState, Provider, Riverpod, BLoC, GetX, Redux.',
        tags: ['state-management', 'architecture', 'flutter'],
      ),
      Question(
        id: 'flutter_associate_003',
        text: 'How do you handle navigation in Flutter applications?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.flutter, Role.mobile],
        difficulty: Level.associate,
        expectedAnswer:
            'Navigator.push/pop, named routes, go_router for declarative routing.',
        tags: ['navigation', 'routing', 'flutter'],
      ),

      // Senior Level - Flutter
      Question(
        id: 'flutter_senior_001',
        text: 'How would you optimize Flutter app performance for large lists?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.flutter, Role.mobile],
        difficulty: Level.senior,
        expectedAnswer:
            'ListView.builder, lazy loading, pagination, widget recycling, const constructors.',
        tags: ['performance', 'optimization', 'flutter'],
      ),
      Question(
        id: 'flutter_senior_002',
        text:
            'Explain Flutter\'s platform channels and when you would use them.',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.flutter, Role.mobile],
        difficulty: Level.senior,
        expectedAnswer:
            'Communication bridge between Flutter and native platform code for accessing platform-specific APIs.',
        tags: ['platform-channels', 'native', 'flutter'],
      ),
    ];
  }

  /// Create Backend-specific questions
  List<Question> _createBackendQuestions() {
    return [
      // Intern Level - Backend
      Question(
        id: 'backend_intern_001',
        text: 'What is an API and what are the different types?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.backend, Role.fullStack],
        difficulty: Level.intern,
        expectedAnswer:
            'API is Application Programming Interface. Types include REST, GraphQL, SOAP, and RPC.',
        tags: ['api', 'rest', 'basics'],
      ),
      Question(
        id: 'backend_intern_002',
        text: 'What is a database and what are the main types?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.backend, Role.fullStack],
        difficulty: Level.intern,
        expectedAnswer:
            'A database stores and organizes data. Main types: SQL (relational) and NoSQL (document, key-value, graph).',
        tags: ['database', 'sql', 'nosql'],
      ),
      Question(
        id: 'backend_intern_003',
        text: 'What is HTTP and what are the common HTTP methods?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.backend, Role.fullStack],
        difficulty: Level.intern,
        expectedAnswer:
            'HTTP is HyperText Transfer Protocol. Common methods: GET, POST, PUT, DELETE, PATCH.',
        tags: ['http', 'methods', 'web'],
      ),

      // Associate Level - Backend
      Question(
        id: 'backend_associate_001',
        text: 'Explain the difference between SQL and NoSQL databases.',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.backend, Role.fullStack],
        difficulty: Level.associate,
        expectedAnswer:
            'SQL: structured, ACID compliant, relational. NoSQL: flexible schema, horizontally scalable, various data models.',
        tags: ['database', 'sql', 'nosql', 'comparison'],
      ),
      Question(
        id: 'backend_associate_002',
        text: 'What is authentication vs authorization?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.backend, Role.fullStack],
        difficulty: Level.associate,
        expectedAnswer:
            'Authentication verifies identity (who you are), authorization determines permissions (what you can do).',
        tags: ['auth', 'security', 'permissions'],
      ),
      Question(
        id: 'backend_associate_003',
        text: 'Explain caching and different caching strategies.',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.backend, Role.fullStack],
        difficulty: Level.associate,
        expectedAnswer:
            'Caching stores frequently accessed data. Strategies: in-memory, distributed, CDN, database query caching.',
        tags: ['caching', 'performance', 'optimization'],
      ),

      // Senior Level - Backend
      Question(
        id: 'backend_senior_001',
        text: 'How would you design a scalable microservices architecture?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.backend, Role.fullStack],
        difficulty: Level.senior,
        expectedAnswer:
            'Service decomposition, API gateways, service discovery, load balancing, data consistency patterns.',
        tags: ['microservices', 'architecture', 'scalability'],
      ),
      Question(
        id: 'backend_senior_002',
        text: 'Explain database indexing and query optimization strategies.',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.backend, Role.fullStack],
        difficulty: Level.senior,
        expectedAnswer:
            'Indexes speed up queries. Strategies: proper indexing, query analysis, denormalization, partitioning.',
        tags: ['database', 'indexing', 'optimization'],
      ),
    ];
  }

  /// Create Frontend-specific questions
  List<Question> _createFrontendQuestions() {
    return [
      // Intern Level - Frontend
      Question(
        id: 'frontend_intern_001',
        text:
            'What are HTML, CSS, and JavaScript and how do they work together?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.frontend, Role.fullStack],
        difficulty: Level.intern,
        expectedAnswer:
            'HTML structures content, CSS styles appearance, JavaScript adds interactivity.',
        tags: ['html', 'css', 'javascript', 'basics'],
      ),
      Question(
        id: 'frontend_intern_002',
        text: 'What is the DOM and how do you manipulate it?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.frontend, Role.fullStack],
        difficulty: Level.intern,
        expectedAnswer:
            'DOM is Document Object Model. Manipulate with JavaScript methods like getElementById, createElement.',
        tags: ['dom', 'javascript', 'manipulation'],
      ),
      Question(
        id: 'frontend_intern_003',
        text: 'What is responsive design and why is it important?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.frontend, Role.fullStack],
        difficulty: Level.intern,
        expectedAnswer:
            'Design that adapts to different screen sizes. Important for mobile compatibility and user experience.',
        tags: ['responsive', 'css', 'mobile'],
      ),

      // Associate Level - Frontend
      Question(
        id: 'frontend_associate_001',
        text:
            'Explain the difference between var, let, and const in JavaScript.',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.frontend, Role.fullStack],
        difficulty: Level.associate,
        expectedAnswer:
            'var: function-scoped, hoisted. let: block-scoped, not hoisted. const: block-scoped, immutable.',
        tags: ['javascript', 'variables', 'scope'],
      ),
      Question(
        id: 'frontend_associate_002',
        text: 'What are JavaScript promises and async/await?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.frontend, Role.fullStack],
        difficulty: Level.associate,
        expectedAnswer:
            'Promises handle asynchronous operations. Async/await provides cleaner syntax for promise-based code.',
        tags: ['javascript', 'async', 'promises'],
      ),
      Question(
        id: 'frontend_associate_003',
        text: 'What is a JavaScript framework and name some popular ones?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.frontend, Role.fullStack],
        difficulty: Level.associate,
        expectedAnswer:
            'Framework provides structure for building applications. Popular: React, Vue, Angular, Svelte.',
        tags: ['frameworks', 'react', 'vue', 'angular'],
      ),

      // Senior Level - Frontend
      Question(
        id: 'frontend_senior_001',
        text:
            'How would you optimize frontend performance for a large application?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.frontend, Role.fullStack],
        difficulty: Level.senior,
        expectedAnswer:
            'Code splitting, lazy loading, bundling optimization, caching, image optimization, CDN usage.',
        tags: ['performance', 'optimization', 'bundling'],
      ),
      Question(
        id: 'frontend_senior_002',
        text:
            'Explain state management patterns in modern frontend applications.',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.frontend, Role.fullStack],
        difficulty: Level.senior,
        expectedAnswer:
            'Redux, Context API, Vuex, MobX. Patterns: centralized state, immutability, unidirectional data flow.',
        tags: ['state-management', 'redux', 'patterns'],
      ),
    ];
  }

  /// Create Full Stack-specific questions
  List<Question> _createFullStackQuestions() {
    return [
      // Intern Level - Full Stack
      Question(
        id: 'fullstack_intern_001',
        text: 'What does full stack development mean?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.fullStack],
        difficulty: Level.intern,
        expectedAnswer:
            'Working on both frontend (user interface) and backend (server-side) parts of applications.',
        tags: ['fullstack', 'frontend', 'backend'],
      ),
      Question(
        id: 'fullstack_intern_002',
        text:
            'What is the difference between client-side and server-side rendering?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.fullStack],
        difficulty: Level.intern,
        expectedAnswer:
            'Client-side: browser renders content. Server-side: server generates HTML before sending to browser.',
        tags: ['rendering', 'client-side', 'server-side'],
      ),

      // Associate Level - Full Stack
      Question(
        id: 'fullstack_associate_001',
        text: 'How do you handle data flow between frontend and backend?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.fullStack],
        difficulty: Level.associate,
        expectedAnswer:
            'REST APIs, GraphQL, WebSockets. JSON data format, HTTP methods, error handling.',
        tags: ['api', 'data-flow', 'integration'],
      ),
      Question(
        id: 'fullstack_associate_002',
        text:
            'What are the considerations for deploying a full stack application?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.fullStack],
        difficulty: Level.associate,
        expectedAnswer:
            'Environment configuration, database setup, static file serving, SSL certificates, monitoring.',
        tags: ['deployment', 'devops', 'configuration'],
      ),

      // Senior Level - Full Stack
      Question(
        id: 'fullstack_senior_001',
        text:
            'How would you architect a full stack application for high availability?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.fullStack],
        difficulty: Level.senior,
        expectedAnswer:
            'Load balancers, redundant servers, database replication, CDN, monitoring, auto-scaling.',
        tags: ['architecture', 'high-availability', 'scalability'],
      ),
    ];
  }

  /// Create Mobile-specific questions
  List<Question> _createMobileQuestions() {
    return [
      // Intern Level - Mobile
      Question(
        id: 'mobile_intern_001',
        text:
            'What is the difference between native and cross-platform mobile development?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.mobile, Role.flutter],
        difficulty: Level.intern,
        expectedAnswer:
            'Native: platform-specific languages. Cross-platform: single codebase for multiple platforms.',
        tags: ['mobile', 'native', 'cross-platform'],
      ),
      Question(
        id: 'mobile_intern_002',
        text:
            'What are the main mobile platforms and their programming languages?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.mobile, Role.flutter],
        difficulty: Level.intern,
        expectedAnswer:
            'iOS: Swift/Objective-C. Android: Java/Kotlin. Cross-platform: Flutter (Dart), React Native (JavaScript).',
        tags: ['platforms', 'ios', 'android', 'languages'],
      ),

      // Associate Level - Mobile
      Question(
        id: 'mobile_associate_001',
        text:
            'How do you handle different screen sizes and orientations in mobile apps?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.mobile, Role.flutter],
        difficulty: Level.associate,
        expectedAnswer:
            'Responsive layouts, constraint-based design, orientation handling, adaptive UI components.',
        tags: ['responsive', 'layouts', 'orientation'],
      ),
      Question(
        id: 'mobile_associate_002',
        text: 'What are the key considerations for mobile app performance?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.mobile, Role.flutter],
        difficulty: Level.associate,
        expectedAnswer:
            'Memory management, battery usage, network efficiency, smooth animations, app size.',
        tags: ['performance', 'optimization', 'mobile'],
      ),

      // Senior Level - Mobile
      Question(
        id: 'mobile_senior_001',
        text: 'How would you implement offline functionality in a mobile app?',
        category: QuestionCategory.roleSpecificTechnical,
        applicableRoles: [Role.mobile, Role.flutter],
        difficulty: Level.senior,
        expectedAnswer:
            'Local storage, data synchronization, conflict resolution, offline-first architecture.',
        tags: ['offline', 'sync', 'architecture'],
      ),
    ];
  }

  /// Create Modern Development Practices questions
  List<Question> _createModernDevelopmentPracticesQuestions() {
    return [
      // Intern Level - Modern Development Practices
      Question(
        id: 'mdp_intern_001',
        text: 'What is version control and why is it important?',
        category: QuestionCategory.modernDevelopmentPractices,
        applicableRoles: Role.values,
        difficulty: Level.intern,
        expectedAnswer:
            'System for tracking code changes over time. Important for collaboration, backup, and history.',
        tags: ['version-control', 'git', 'collaboration'],
      ),
      Question(
        id: 'mdp_intern_002',
        text: 'What is the difference between Git and GitHub?',
        category: QuestionCategory.modernDevelopmentPractices,
        applicableRoles: Role.values,
        difficulty: Level.intern,
        expectedAnswer:
            'Git is version control system. GitHub is cloud platform hosting Git repositories.',
        tags: ['git', 'github', 'hosting'],
      ),
      Question(
        id: 'mdp_intern_003',
        text: 'What is a code review and why is it beneficial?',
        category: QuestionCategory.modernDevelopmentPractices,
        applicableRoles: Role.values,
        difficulty: Level.intern,
        expectedAnswer:
            'Process of examining code before merging. Benefits: quality, knowledge sharing, bug prevention.',
        tags: ['code-review', 'quality', 'collaboration'],
      ),

      // Associate Level - Modern Development Practices
      Question(
        id: 'mdp_associate_001',
        text: 'Explain the concept of CI/CD and its benefits.',
        category: QuestionCategory.modernDevelopmentPractices,
        applicableRoles: Role.values,
        difficulty: Level.associate,
        expectedAnswer:
            'Continuous Integration/Deployment. Automates testing and deployment, reduces errors, faster delivery.',
        tags: ['ci-cd', 'automation', 'deployment'],
      ),
      Question(
        id: 'mdp_associate_002',
        text: 'What is Test-Driven Development (TDD)?',
        category: QuestionCategory.modernDevelopmentPractices,
        applicableRoles: Role.values,
        difficulty: Level.associate,
        expectedAnswer:
            'Write tests before code. Red-Green-Refactor cycle. Ensures testable, reliable code.',
        tags: ['tdd', 'testing', 'methodology'],
      ),
      Question(
        id: 'mdp_associate_003',
        text:
            'What are the different types of testing in software development?',
        category: QuestionCategory.modernDevelopmentPractices,
        applicableRoles: Role.values,
        difficulty: Level.associate,
        expectedAnswer:
            'Unit, integration, system, acceptance testing. Each tests different levels of functionality.',
        tags: ['testing', 'unit-tests', 'integration'],
      ),

      // Senior Level - Modern Development Practices
      Question(
        id: 'mdp_senior_001',
        text:
            'How would you implement a robust deployment strategy for a production application?',
        category: QuestionCategory.modernDevelopmentPractices,
        applicableRoles: Role.values,
        difficulty: Level.senior,
        expectedAnswer:
            'Blue-green deployment, canary releases, rollback strategies, monitoring, automated testing.',
        tags: ['deployment', 'production', 'strategy'],
      ),
      Question(
        id: 'mdp_senior_002',
        text:
            'Explain containerization and its benefits in modern development.',
        category: QuestionCategory.modernDevelopmentPractices,
        applicableRoles: [Role.backend, Role.fullStack],
        difficulty: Level.senior,
        expectedAnswer:
            'Docker containers package applications with dependencies. Benefits: consistency, scalability, isolation.',
        tags: ['docker', 'containers', 'devops'],
      ),
      Question(
        id: 'mdp_senior_003',
        text: 'What is Infrastructure as Code and why is it important?',
        category: QuestionCategory.modernDevelopmentPractices,
        applicableRoles: [Role.backend, Role.fullStack],
        difficulty: Level.senior,
        expectedAnswer:
            'Managing infrastructure through code. Benefits: version control, reproducibility, automation.',
        tags: ['iac', 'infrastructure', 'automation'],
      ),
    ];
  }

  /// Create Soft Skills questions
  List<Question> _createSoftSkillsQuestions() {
    return [
      // Intern Level - Soft Skills
      Question(
        id: 'ss_intern_001',
        text:
            'How do you approach learning a new technology or programming language?',
        category: QuestionCategory.softSkills,
        applicableRoles: Role.values,
        difficulty: Level.intern,
        expectedAnswer:
            'Start with documentation, build small projects, practice regularly, seek help when needed.',
        tags: ['learning', 'growth', 'approach'],
      ),
      Question(
        id: 'ss_intern_002',
        text:
            'Describe a time when you encountered a difficult bug. How did you solve it?',
        category: QuestionCategory.softSkills,
        applicableRoles: Role.values,
        difficulty: Level.intern,
        expectedAnswer:
            'Systematic debugging, breaking down the problem, using debugging tools, asking for help.',
        tags: ['problem-solving', 'debugging', 'persistence'],
      ),
      Question(
        id: 'ss_intern_003',
        text: 'How do you stay updated with technology trends?',
        category: QuestionCategory.softSkills,
        applicableRoles: Role.values,
        difficulty: Level.intern,
        expectedAnswer:
            'Tech blogs, documentation, online courses, developer communities, conferences.',
        tags: ['learning', 'trends', 'continuous-improvement'],
      ),

      // Associate Level - Soft Skills
      Question(
        id: 'ss_associate_001',
        text:
            'How do you handle conflicting requirements from different stakeholders?',
        category: QuestionCategory.softSkills,
        applicableRoles: Role.values,
        difficulty: Level.associate,
        expectedAnswer:
            'Facilitate discussion, understand priorities, find compromises, document decisions.',
        tags: ['communication', 'stakeholders', 'conflict-resolution'],
      ),
      Question(
        id: 'ss_associate_002',
        text:
            'Describe your approach to code documentation and knowledge sharing.',
        category: QuestionCategory.softSkills,
        applicableRoles: Role.values,
        difficulty: Level.associate,
        expectedAnswer:
            'Clear comments, README files, team presentations, mentoring junior developers.',
        tags: ['documentation', 'knowledge-sharing', 'mentoring'],
      ),
      Question(
        id: 'ss_associate_003',
        text: 'How do you prioritize tasks when working on multiple projects?',
        category: QuestionCategory.softSkills,
        applicableRoles: Role.values,
        difficulty: Level.associate,
        expectedAnswer:
            'Assess urgency and impact, communicate with stakeholders, use project management tools.',
        tags: ['prioritization', 'time-management', 'organization'],
      ),

      // Senior Level - Soft Skills
      Question(
        id: 'ss_senior_001',
        text:
            'How do you lead technical discussions and make architectural decisions?',
        category: QuestionCategory.softSkills,
        applicableRoles: Role.values,
        difficulty: Level.senior,
        expectedAnswer:
            'Gather input, evaluate trade-offs, build consensus, document rationale, consider long-term impact.',
        tags: ['leadership', 'architecture', 'decision-making'],
      ),
      Question(
        id: 'ss_senior_002',
        text: 'Describe your approach to mentoring junior developers.',
        category: QuestionCategory.softSkills,
        applicableRoles: Role.values,
        difficulty: Level.senior,
        expectedAnswer:
            'Pair programming, code reviews, setting learning goals, providing constructive feedback.',
        tags: ['mentoring', 'leadership', 'development'],
      ),
      Question(
        id: 'ss_senior_003',
        text: 'How do you balance technical debt with feature development?',
        category: QuestionCategory.softSkills,
        applicableRoles: Role.values,
        difficulty: Level.senior,
        expectedAnswer:
            'Assess impact, communicate risks to stakeholders, allocate time for refactoring, prioritize critical debt.',
        tags: ['technical-debt', 'prioritization', 'communication'],
      ),
    ];
  }
}

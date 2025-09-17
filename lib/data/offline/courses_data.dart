// lib/data/sample_course_data.dart

import 'package:skillsbridge/models/course_models.dart';

class MITCourseData {
  // Real MIT OpenCourseWare courses with lecture videos
  static List<Course> getSampleCourses() {
    return [
      Course(
        id: '6.0001',
        title: 'Introduction to Computer Science and Programming in Python',
        description:
            'Learn Python programming and computational thinking from scratch. No prior programming experience required.',
        instructor: 'Dr. Ana Bell, Prof. Eric Grimson, Prof. John Guttag',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/6-0001-introduction-to-computer-science-and-programming-in-python-fall-2016/6-0001f16.jpg',
        level: CourseLevel.beginner,
        category: CourseCategory.programming,
        rating: 4.8,
        reviewCount: 15420,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 32, minutes: 45),
        lessons: [
          Lesson(
            id: 'lesson_6.0001_1',
            title: 'What is Computation?',
            description:
                'Introduction to computation theory and basic Python syntax',
            videoUrl: 'https://www.youtube.com/watch?v=ytpJdnlu9ug',
            thumbnailUrl:
                'https://img.youtube.com/vi/ytpJdnlu9ug/maxresdefault.jpg',
            duration: Duration(minutes: 48, seconds: 30),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_6.0001_2',
            title: 'Branching and Iteration',
            description: 'Control structures: conditionals and loops in Python',
            videoUrl: 'https://www.youtube.com/watch?v=0jljZRnHwOI',
            duration: Duration(minutes: 45, seconds: 15),
            orderIndex: 2,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_6.0001_3',
            title: 'String Manipulation, Guess and Check, Approximations',
            description:
                'Working with strings and algorithmic approaches to problem solving',
            videoUrl: 'https://www.youtube.com/watch?v=SE4P7IVCunE',
            duration: Duration(minutes: 49, seconds: 45),
            orderIndex: 3,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_6.0001_4',
            title: 'Decomposition, Abstractions, Functions',
            description: 'How to structure programs using functions',
            videoUrl: 'https://www.youtube.com/watch?v=MjbuarJ7SE0',
            duration: Duration(minutes: 47, seconds: 20),
            orderIndex: 4,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_6.0001_5',
            title: 'Tuples, Lists, Aliasing, Mutability, Cloning',
            description: 'Data structures and memory management in Python',
            videoUrl: 'https://www.youtube.com/watch?v=RvRKT-jXvko',
            duration: Duration(minutes: 46, seconds: 30),
            orderIndex: 5,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_6.0001_6',
            title: 'Recursion and Dictionaries',
            description: 'Recursive algorithms and key-value data structures',
            videoUrl: 'https://www.youtube.com/watch?v=WPSeyjX1-4s',
            duration: Duration(minutes: 50, seconds: 15),
            orderIndex: 6,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2016, 9, 1),
        updatedAt: DateTime(2024, 2, 1),
        isFeatured: true,
        isPopular: true,
        tags: ['Python', 'Programming', 'Computer Science', 'Algorithms'],
        enrollmentCount: 2500000,
      ),

      Course(
        id: '6.006',
        title: 'Introduction to Algorithms',
        description:
            'Mathematical modeling of computational problems, algorithmic paradigms, and data structures.',
        instructor: 'Prof. Erik Demaine, Dr. Jason Ku, Prof. Justin Solomon',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/6-006-introduction-to-algorithms-spring-2020/6-006s20.jpg',
        level: CourseLevel.intermediate,
        category: CourseCategory.programming,
        rating: 4.9,
        reviewCount: 8930,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 42, minutes: 30),
        lessons: [
          Lesson(
            id: 'lesson_6.006_1',
            title: 'Algorithms and Computation',
            description:
                'Introduction to algorithmic thinking and computational models',
            videoUrl: 'https://www.youtube.com/watch?v=ZA-tUyM_y7s',
            duration: Duration(minutes: 48, seconds: 45),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_6.006_2',
            title: 'Data Structures and Dynamic Arrays',
            description: 'Static and dynamic arrays, amortized analysis',
            videoUrl: 'https://www.youtube.com/watch?v=CHhwJjR0mZA',
            duration: Duration(minutes: 50, seconds: 20),
            orderIndex: 2,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_6.006_3',
            title: 'Sets and Sorting',
            description:
                'Set interface and comparison-based sorting algorithms',
            videoUrl: 'https://www.youtube.com/watch?v=oUt58ByOjPw',
            duration: Duration(minutes: 49, seconds: 15),
            orderIndex: 3,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_6.006_4',
            title: 'Hashing',
            description:
                'Hash functions, collision resolution, and hash tables',
            videoUrl: 'https://www.youtube.com/watch?v=Nu8YGneFCWE',
            duration: Duration(minutes: 48, seconds: 30),
            orderIndex: 4,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_6.006_5',
            title: 'Linear Sorting',
            description: 'Counting sort, radix sort, and bucket sort',
            videoUrl: 'https://www.youtube.com/watch?v=Nz1KZXbghj8',
            duration: Duration(minutes: 46, seconds: 45),
            orderIndex: 5,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2020, 2, 1),
        updatedAt: DateTime(2024, 1, 15),
        isPopular: true,
        tags: [
          'Algorithms',
          'Data Structures',
          'Computer Science',
          'Programming',
        ],
        enrollmentCount: 1800000,
      ),

      // Mathematics
      Course(
        id: '18.06',
        title: 'Linear Algebra',
        description:
            'Matrix theory and linear algebra with applications to other disciplines.',
        instructor: 'Prof. Gilbert Strang',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/18-06-linear-algebra-spring-2010/18-06s10.jpg',
        level: CourseLevel.undergraduate,
        category: CourseCategory.mathematics,
        rating: 4.9,
        reviewCount: 25000,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 38, minutes: 15),
        lessons: [
          Lesson(
            id: 'lesson_18.06_1',
            title: 'The Geometry of Linear Equations',
            description:
                'Introduction to linear systems and geometric interpretation',
            videoUrl: 'https://www.youtube.com/watch?v=J7DzL2_Na80',
            duration: Duration(minutes: 39, seconds: 49),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_18.06_2',
            title: 'Elimination with Matrices',
            description: 'Gaussian elimination and matrix operations',
            videoUrl: 'https://www.youtube.com/watch?v=QVKj3LADCnA',
            duration: Duration(minutes: 47, seconds: 41),
            orderIndex: 2,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_18.06_3',
            title: 'Multiplication and Inverse Matrices',
            description: 'Matrix multiplication methods and finding inverses',
            videoUrl: 'https://www.youtube.com/watch?v=FX4C-JpTFgY',
            duration: Duration(minutes: 46, seconds: 48),
            orderIndex: 3,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_18.06_4',
            title: 'Factorization into A = LU',
            description: 'LU decomposition and its applications',
            videoUrl: 'https://www.youtube.com/watch?v=MsIvs_6vC38',
            duration: Duration(minutes: 48, seconds: 05),
            orderIndex: 4,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_18.06_5',
            title: 'Transposes, Permutations, Spaces R^n',
            description: 'Matrix transposes and vector spaces',
            videoUrl: 'https://www.youtube.com/watch?v=JibVXBElKL0',
            duration: Duration(minutes: 47, seconds: 41),
            orderIndex: 5,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2010, 2, 1),
        updatedAt: DateTime(2024, 1, 10),
        isFeatured: true,
        isPopular: true,
        tags: [
          'Linear Algebra',
          'Mathematics',
          'Matrix Theory',
          'Vector Spaces',
        ],
        enrollmentCount: 3200000,
      ),

      // Physics
      Course(
        id: '8.01',
        title: 'Physics I: Classical Mechanics',
        description:
            'Newtonian mechanics, fluid mechanics, and kinetic gas theory with Walter Lewin.',
        instructor: 'Prof. Walter Lewin',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/8-01-physics-i-classical-mechanics-fall-1999/8-01f99.jpg',
        level: CourseLevel.undergraduate,
        category: CourseCategory.engineering,
        rating: 4.8,
        reviewCount: 18700,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 35, minutes: 30),
        lessons: [
          Lesson(
            id: 'lesson_8.01_1',
            title: 'Powers of Ten, Units, Dimensions, Measurements',
            description:
                'Introduction to physics measurements and scientific notation',
            videoUrl: 'https://www.youtube.com/watch?v=4a0FbQdH3dY',
            duration: Duration(minutes: 49, seconds: 57),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_8.01_2',
            title: '1D Kinematics - Speed, Velocity, Acceleration',
            description: 'Motion in one dimension with constant acceleration',
            videoUrl: 'https://www.youtube.com/watch?v=9sJCixQKe4k',
            duration: Duration(minutes: 49, seconds: 27),
            orderIndex: 2,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_8.01_3',
            title: 'Vectors',
            description: 'Vector addition, subtraction, and components',
            videoUrl: 'https://www.youtube.com/watch?v=F-GZA9zZgPc',
            duration: Duration(minutes: 49, seconds: 50),
            orderIndex: 3,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_8.01_4',
            title: '2D Kinematics - Projectile Motion',
            description: 'Motion in two dimensions and projectile motion',
            videoUrl: 'https://www.youtube.com/watch?v=w3BhzYI6zXU',
            duration: Duration(minutes: 49, seconds: 30),
            orderIndex: 4,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(1999, 9, 1),
        updatedAt: DateTime(2024, 1, 5),
        isPopular: true,
        tags: [
          'Physics',
          'Classical Mechanics',
          'Newtonian Physics',
          'Kinematics',
        ],
        enrollmentCount: 2800000,
      ),

      Course(
        id: '8.02',
        title: 'Physics II: Electricity and Magnetism',
        description:
            'Electromagnetic theory with practical applications and demonstrations.',
        instructor: 'Prof. Walter Lewin',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/8-02-physics-ii-electricity-and-magnetism-spring-2002/8-02s02.jpg',
        level: CourseLevel.undergraduate,
        category: CourseCategory.engineering,
        rating: 4.8,
        reviewCount: 16200,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 36, minutes: 45),
        lessons: [
          Lesson(
            id: 'lesson_8.02_1',
            title: 'What holds our world together?',
            description: 'Introduction to electric charges and forces',
            videoUrl: 'https://www.youtube.com/watch?v=x1-SibwIPM4',
            duration: Duration(minutes: 50, seconds: 16),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_8.02_2',
            title: 'Electric Field',
            description: 'Electric field concept and field lines',
            videoUrl: 'https://www.youtube.com/watch?v=x1-SibwIPM4',
            duration: Duration(minutes: 49, seconds: 45),
            orderIndex: 2,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2002, 2, 1),
        updatedAt: DateTime(2024, 1, 8),
        isPopular: true,
        tags: ['Physics', 'Electricity', 'Magnetism', 'Electromagnetic Theory'],
        enrollmentCount: 2400000,
      ),

      // More Computer Science
      Course(
        id: '6.042J',
        title: 'Mathematics for Computer Science',
        description:
            'Mathematical concepts for computer science including discrete math, probability, and logic.',
        instructor: 'Prof. Albert Meyer, Prof. Adam Chlipala',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/6-042j-mathematics-for-computer-science-spring-2015/6-042js15.jpg',
        level: CourseLevel.undergraduate,
        category: CourseCategory.mathematics,
        rating: 4.7,
        reviewCount: 12400,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 45, minutes: 20),
        lessons: [
          Lesson(
            id: 'lesson_6.042_1',
            title: 'Introduction and Proofs',
            description: 'Introduction to mathematical proofs and reasoning',
            videoUrl: 'https://www.youtube.com/watch?v=L3LMbpZIKhQ',
            duration: Duration(minutes: 51, seconds: 26),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_6.042_2',
            title: 'Proof Methods',
            description:
                'Direct proofs, proof by contradiction, and proof by cases',
            videoUrl: 'https://www.youtube.com/watch?v=6JtC9b6k6nQ',
            duration: Duration(minutes: 48, seconds: 15),
            orderIndex: 2,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2015, 2, 1),
        updatedAt: DateTime(2024, 1, 12),
        tags: ['Mathematics', 'Discrete Math', 'Logic', 'Probability'],
        enrollmentCount: 950000,
      ),

      Course(
        id: '6.034',
        title: 'Artificial Intelligence',
        description:
            'Introduction to artificial intelligence with emphasis on problem-solving and knowledge representation.',
        instructor: 'Prof. Patrick Winston',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/6-034-artificial-intelligence-fall-2010/6-034f10.jpg',
        level: CourseLevel.intermediate,
        category: CourseCategory.programming,
        rating: 4.6,
        reviewCount: 8900,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 38, minutes: 45),
        lessons: [
          Lesson(
            id: 'lesson_6.034_1',
            title: 'Introduction and Scope',
            description: 'What is AI and what are its applications?',
            videoUrl: 'https://www.youtube.com/watch?v=TjZBTDzGeGg',
            duration: Duration(minutes: 50, seconds: 48),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_6.034_2',
            title: 'Reasoning: Goal Trees and Problem Solving',
            description:
                'Problem-solving strategies and goal-oriented reasoning',
            videoUrl: 'https://www.youtube.com/watch?v=56L3uT8rFqs',
            duration: Duration(minutes: 49, seconds: 32),
            orderIndex: 2,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2010, 9, 1),
        updatedAt: DateTime(2024, 1, 18),
        tags: [
          'Artificial Intelligence',
          'Machine Learning',
          'Problem Solving',
        ],
        enrollmentCount: 1200000,
      ),

      // More Math
      Course(
        id: '18.01',
        title: 'Single Variable Calculus',
        description:
            'Differentiation and integration of functions of one variable with applications.',
        instructor: 'Prof. David Jerison',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/18-01-single-variable-calculus-fall-2006/18-01f06.jpg',
        level: CourseLevel.undergraduate,
        category: CourseCategory.mathematics,
        rating: 4.5,
        reviewCount: 14500,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 42, minutes: 30),
        lessons: [
          Lesson(
            id: 'lesson_18.01_1',
            title: 'Derivatives, Slope, Velocity, and Rate of Change',
            description:
                'Introduction to derivatives and their geometric interpretation',
            videoUrl: 'https://www.youtube.com/watch?v=7K1sB05pE0A',
            duration: Duration(minutes: 49, seconds: 27),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_18.01_2',
            title: 'Limits, Continuity, and Trigonometric Limits',
            description: 'The concept of limits and continuity',
            videoUrl: 'https://www.youtube.com/watch?v=54_XRjHhZzI',
            duration: Duration(minutes: 47, seconds: 53),
            orderIndex: 2,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2006, 9, 1),
        updatedAt: DateTime(2024, 1, 5),
        tags: ['Calculus', 'Mathematics', 'Derivatives', 'Integration'],
        enrollmentCount: 1800000,
      ),

      Course(
        id: '18.02',
        title: 'Multivariable Calculus',
        description:
            'Calculus of several variables including vectors, partial derivatives, and multiple integrals.',
        instructor: 'Prof. Denis Auroux',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/18-02-multivariable-calculus-fall-2007/18-02f07.jpg',
        level: CourseLevel.intermediate,
        category: CourseCategory.mathematics,
        rating: 4.4,
        reviewCount: 11200,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 45, minutes: 15),
        lessons: [
          Lesson(
            id: 'lesson_18.02_1',
            title: 'Vectors and Matrices',
            description: 'Introduction to vectors in 2D and 3D space',
            videoUrl: 'https://www.youtube.com/watch?v=PxCxlsl_YwY',
            duration: Duration(minutes: 49, seconds: 48),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2007, 9, 1),
        updatedAt: DateTime(2024, 1, 3),
        tags: ['Multivariable Calculus', 'Vectors', 'Partial Derivatives'],
        enrollmentCount: 1350000,
      ),

      // Biology
      Course(
        id: '7.012',
        title: 'Introduction to Biology',
        description:
            'Fundamental principles of biology focusing on biochemistry, genetics, and molecular biology.',
        instructor:
            'Prof. Eric Lander, Prof. Robert Weinberg, Prof. Tyler Jacks',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/7-012-introduction-to-biology-fall-2004/7-012f04.jpg',
        level: CourseLevel.undergraduate,
        category: CourseCategory.engineering,
        rating: 4.6,
        reviewCount: 9800,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 40, minutes: 30),
        lessons: [
          Lesson(
            id: 'lesson_7.012_1',
            title: 'What is Life?',
            description: 'Introduction to the fundamental properties of life',
            videoUrl: 'https://www.youtube.com/watch?v=7QR4sTzOvVg',
            duration: Duration(minutes: 50, seconds: 12),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2004, 9, 1),
        updatedAt: DateTime(2024, 1, 8),
        tags: ['Biology', 'Genetics', 'Molecular Biology', 'Biochemistry'],
        enrollmentCount: 780000,
      ),

      // Economics
      Course(
        id: '14.01',
        title: 'Principles of Microeconomics',
        description:
            'Introduction to microeconomic theory and its applications.',
        instructor: 'Prof. Jonathan Gruber',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/14-01-principles-of-microeconomics-fall-2018/14-01f18.jpg',
        level: CourseLevel.undergraduate,
        category: CourseCategory.business,
        rating: 4.3,
        reviewCount: 7200,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 38, minutes: 0),
        lessons: [
          Lesson(
            id: 'lesson_14.01_1',
            title: 'Introduction and Supply & Demand',
            description:
                'Basic principles of microeconomics and market mechanisms',
            videoUrl: 'https://www.youtube.com/watch?v=gstXOhU44RQ',
            duration: Duration(minutes: 49, seconds: 35),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2018, 9, 1),
        updatedAt: DateTime(2024, 1, 10),
        tags: ['Economics', 'Microeconomics', 'Market Theory'],
        enrollmentCount: 650000,
      ),

      // Chemistry
      Course(
        id: '5.111',
        title: 'Principles of Chemical Science',
        description:
            'Introduction to chemistry emphasizing quantitative relationships and molecular reasoning.',
        instructor: 'Prof. Catherine Drennan',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/5-111-principles-of-chemical-science-fall-2008/5-111f08.jpg',
        level: CourseLevel.undergraduate,
        category: CourseCategory.engineering,
        rating: 4.7,
        reviewCount: 8500,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 44, minutes: 20),
        lessons: [
          Lesson(
            id: 'lesson_5.111_1',
            title: 'The Importance of Chemical Principles',
            description: 'Why chemistry matters and atomic structure basics',
            videoUrl: 'https://www.youtube.com/watch?v=jIS5NjA9KOc',
            duration: Duration(minutes: 46, seconds: 42),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2008, 9, 1),
        updatedAt: DateTime(2024, 1, 7),
        tags: ['Chemistry', 'Chemical Science', 'Atomic Structure'],
        enrollmentCount: 580000,
      ),

      // Mechanical Engineering
      Course(
        id: '2.003J',
        title: 'Dynamics and Control I',
        description:
            'Introduction to the dynamics and vibration of lumped-parameter systems.',
        instructor: 'Prof. Neville Hogan',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/2-003j-dynamics-and-control-i-fall-2007/2-003jf07.jpg',
        level: CourseLevel.intermediate,
        category: CourseCategory.engineering,
        rating: 4.4,
        reviewCount: 5400,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 36, minutes: 45),
        lessons: [
          Lesson(
            id: 'lesson_2.003_1',
            title: 'Kinematics',
            description: 'Introduction to kinematics and coordinate systems',
            videoUrl: 'https://www.youtube.com/watch?v=YbX8RUVJjYA',
            duration: Duration(minutes: 48, seconds: 15),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2007, 9, 1),
        updatedAt: DateTime(2024, 1, 6),
        tags: ['Mechanical Engineering', 'Dynamics', 'Control Systems'],
        enrollmentCount: 420000,
      ),

      // Continue with more courses...
      Course(
        id: '15.S12',
        title: 'Blockchain and Money',
        description:
            'Study of blockchain technology and cryptocurrencies from technical and policy perspectives.',
        instructor: 'Prof. Gary Gensler',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/15-s12-blockchain-and-money-fall-2018/15-s12f18.jpg',
        level: CourseLevel.intermediate,
        category: CourseCategory.business,
        rating: 4.8,
        reviewCount: 15600,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 46, minutes: 30),
        lessons: [
          Lesson(
            id: 'lesson_15.s12_1',
            title: 'Introduction',
            description: 'Overview of blockchain technology and digital money',
            videoUrl: 'https://www.youtube.com/watch?v=EH6vE97qIP4',
            duration: Duration(minutes: 78, seconds: 32),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_15.s12_2',
            title: 'Money, Ledgers & Bitcoin',
            description: 'The history of money and introduction to Bitcoin',
            videoUrl: 'https://www.youtube.com/watch?v=5auv_xrvoJk',
            duration: Duration(minutes: 76, seconds: 45),
            orderIndex: 2,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2018, 9, 1),
        updatedAt: DateTime(2024, 2, 15),
        isFeatured: true,
        isPopular: true,
        tags: ['Blockchain', 'Cryptocurrency', 'Finance', 'Technology Policy'],
        enrollmentCount: 1900000,
      ),

      // More advanced courses
      Course(
        id: '6.046J',
        title: 'Design and Analysis of Algorithms',
        description:
            'Advanced algorithms including network flows, linear programming, and approximation algorithms.',
        instructor: 'Prof. Erik Demaine, Prof. Srini Devadas',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/6-046j-design-and-analysis-of-algorithms-spring-2015/6-046js15.jpg',
        level: CourseLevel.advanced,
        category: CourseCategory.programming,
        rating: 4.7,
        reviewCount: 6800,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 39, minutes: 15),
        lessons: [
          Lesson(
            id: 'lesson_6.046_1',
            title: 'Course Overview, Interval Scheduling',
            description:
                'Introduction to advanced algorithms and greedy algorithms',
            videoUrl: 'https://www.youtube.com/watch?v=2P-yW7LQr08',
            duration: Duration(minutes: 47, seconds: 53),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2015, 2, 1),
        updatedAt: DateTime(2024, 1, 14),
        tags: ['Advanced Algorithms', 'Graph Theory', 'Dynamic Programming'],
        enrollmentCount: 620000,
      ),

      Course(
        id: '18.065',
        title:
            'Matrix Methods in Data Analysis, Signal Processing, and Machine Learning',
        description:
            'Linear algebra concepts for modern applications in data science and machine learning.',
        instructor: 'Prof. Gilbert Strang',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/18-065-matrix-methods-in-data-analysis-signal-processing-and-machine-learning-spring-2018/18-065s18.jpg',
        level: CourseLevel.advanced,
        category: CourseCategory.dataScience,
        rating: 4.9,
        reviewCount: 8200,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 43, minutes: 45),
        lessons: [
          Lesson(
            id: 'lesson_18.065_1',
            title: 'The Column Space of A Contains All Vectors Ax',
            description:
                'Foundation concepts for matrix methods in data analysis',
            videoUrl: 'https://www.youtube.com/watch?v=Cx5Z-OslNWE',
            duration: Duration(minutes: 48, seconds: 30),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2018, 2, 1),
        updatedAt: DateTime(2024, 1, 20),
        isFeatured: true,
        tags: [
          'Machine Learning',
          'Data Analysis',
          'Linear Algebra',
          'Signal Processing',
        ],
        enrollmentCount: 890000,
      ),

      // Adding more courses to reach 100 total...
      Course(
        id: '9.13',
        title: 'The Human Brain',
        description:
            'Introduction to the human brain from computational, psychological, and neural perspectives.',
        instructor: 'Prof. Nancy Kanwisher',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/9-13-the-human-brain-spring-2019/9-13s19.jpg',
        level: CourseLevel.undergraduate,
        category: CourseCategory.engineering,
        rating: 4.8,
        reviewCount: 12300,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 41, minutes: 20),
        lessons: [
          Lesson(
            id: 'lesson_9.13_1',
            title: 'Introduction to the Human Brain',
            description: 'Overview of brain structure and function',
            videoUrl: 'https://www.youtube.com/watch?v=ba-HkVla7o8',
            duration: Duration(minutes: 46, seconds: 15),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2019, 2, 1),
        updatedAt: DateTime(2024, 1, 18),
        isPopular: true,
        tags: [
          'Neuroscience',
          'Brain Science',
          'Psychology',
          'Cognitive Science',
        ],
        enrollmentCount: 1350000,
      ),

      Course(
        id: '8.03',
        title: 'Physics III: Vibrations and Waves',
        description:
            'Vibrations and waves in mechanical systems, sound, and electromagnetic phenomena.',
        instructor: 'Prof. Walter Lewin',
        thumbnailUrl:
            'https://ocw.mit.edu/courses/8-03-physics-iii-vibrations-and-waves-fall-2004/8-03f04.jpg',
        level: CourseLevel.intermediate,
        category: CourseCategory.engineering,
        rating: 4.7,
        reviewCount: 9400,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 23, minutes: 45),
        lessons: [
          Lesson(
            id: 'lesson_8.03_1',
            title: 'Periodic Oscillations, Harmonic Oscillators',
            description:
                'Introduction to oscillatory motion and simple harmonic motion',
            videoUrl: 'https://www.youtube.com/watch?v=dihM6u38wxI',
            duration: Duration(minutes: 50, seconds: 33),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2004, 9, 1),
        updatedAt: DateTime(2024, 1, 9),
        tags: ['Physics', 'Waves', 'Oscillations', 'Sound'],
        enrollmentCount: 920000,
      ),

      Course(
        id: '5',
        title: 'Advanced JavaScript Concepts',
        description:
            'Master advanced JavaScript patterns and modern ES6+ features',
        instructor: 'SkillsBridge',
        thumbnailUrl: 'https://example.com/javascript-course.jpg',
        level: CourseLevel.advanced,
        category: CourseCategory.programming,
        rating: 4.5,
        reviewCount: 760,
        pricing: CoursePricing(type: PricingType.free),
        totalDuration: Duration(hours: 18, minutes: 45),
        lessons: [
          Lesson(
            id: 'lesson_5_1',
            title: 'Closures and Scope',
            description: 'Deep dive into JavaScript closures and lexical scope',
            videoUrl: 'https://example.com/videos/closures-scope.mp4',
            thumbnailUrl: 'https://example.com/thumbs/closures-scope.jpg',
            duration: Duration(minutes: 25, seconds: 15),
            orderIndex: 1,
            isPreview: true,
            type: LessonType.video,
          ),
          Lesson(
            id: 'lesson_5_2',
            title: 'Promises and Async/Await',
            description: 'Mastering asynchronous JavaScript programming',
            videoUrl: 'https://example.com/videos/async-js.mp4',
            thumbnailUrl: 'https://example.com/thumbs/async-js.jpg',
            duration: Duration(minutes: 30, seconds: 45),
            orderIndex: 2,
            type: LessonType.video,
          ),
        ],
        createdAt: DateTime(2024, 2, 5),
        updatedAt: DateTime(2024, 2, 18),
        tags: ['JavaScript', 'ES6+', 'Async Programming', 'Advanced'],
        enrollmentCount: 5670,
      ),
    ];
  }

  static List<String> getCategories() {
    return [
      'All',
      'Programming',
      'Design',
      'Business',
      'Data Science',
      'Engineering',
      'Marketing',
    ];
  }

  static Course? getFeaturedCourse() {
    final courses = getSampleCourses();
    return courses.firstWhere(
      (course) => course.isFeatured,
      orElse: () => courses.first,
    );
  }

  static List<Course> getPopularCourses() {
    return getSampleCourses()
        .where((course) => course.isPopular)
        .take(5)
        .toList();
  }

  static List<Course> getCoursesByCategory(String category) {
    if (category == 'All') {
      return getSampleCourses();
    }

    return getSampleCourses()
        .where((course) => course.category.value == category)
        .toList();
  }

  static List<Course> getFilteredCourses({
    String searchQuery = '',
    List<String> levelFilters = const [],
    String category = 'All',
  }) {
    var courses = getSampleCourses();

    // Filter by category
    if (category != 'All') {
      courses = courses
          .where((course) => course.category.value == category)
          .toList();
    }

    // Filter by search query
    if (searchQuery.isNotEmpty) {
      courses = courses
          .where(
            (course) =>
                course.title.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                course.description.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                course.tags.any(
                  (tag) =>
                      tag.toLowerCase().contains(searchQuery.toLowerCase()),
                ),
          )
          .toList();
    }

    // Filter by level
    if (levelFilters.isNotEmpty && !levelFilters.contains('All Levels')) {
      courses = courses
          .where((course) => levelFilters.contains(course.level.value))
          .toList();
    }

    return courses;
  }

  // Helper method to create sample course progress
  static CourseProgress getSampleProgress(String courseId, String userId) {
    return CourseProgress(
      courseId: courseId,
      userId: userId,
      completedLessons: ['lesson_${courseId}_1', 'lesson_${courseId}_2'],
      lastAccessedAt: DateTime.now().subtract(Duration(hours: 2)),
      progressPercentage: 40.0,
      totalWatchTime: Duration(hours: 1, minutes: 30),
    );
  }
}

// Extension methods for easier filtering in your ViewModel
extension CourseListExtensions on List<Course> {
  List<Course> filterByLevel(CourseLevel level) {
    if (level == CourseLevel.all) return this;
    return where((course) => course.level == level).toList();
  }

  List<Course> filterByCategory(CourseCategory category) {
    if (category == CourseCategory.all) return this;
    return where((course) => course.category == category).toList();
  }

  List<Course> searchByKeyword(String keyword) {
    if (keyword.isEmpty) return this;
    final lowerKeyword = keyword.toLowerCase();
    return where(
      (course) =>
          course.title.toLowerCase().contains(lowerKeyword) ||
          course.description.toLowerCase().contains(lowerKeyword) ||
          course.instructor.toLowerCase().contains(lowerKeyword) ||
          course.tags.any((tag) => tag.toLowerCase().contains(lowerKeyword)),
    ).toList();
  }

  List<Course> sortByRating() {
    final sorted = List<Course>.from(this);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted;
  }

  List<Course> sortByEnrollment() {
    final sorted = List<Course>.from(this);
    sorted.sort((a, b) => b.enrollmentCount.compareTo(a.enrollmentCount));
    return sorted;
  }
}

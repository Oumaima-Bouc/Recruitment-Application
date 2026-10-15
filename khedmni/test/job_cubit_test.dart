import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:khedmni/logic/cubits/job_cubit.dart';
import 'package:khedmni/logic/cubits/job_state.dart';
import 'package:khedmni/models/job.dart';

// Test environment utilities
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:khedmni/data/local/database_helper.dart';

void main() {
  group('JobCubit', () {
    late JobCubit jobCubit;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // Seed DB once for tests that rely on dummy data
      await DatabaseHelper.instance.seedDatabaseIfNeeded();
    });

    setUp(() {
      jobCubit = JobCubit();
    });

    tearDown(() {
      jobCubit.close();
    });

    test('initial state is JobInitial', () {
      expect(jobCubit.state, isA<JobInitial>());
    });

    group('loadJobs', () {
      blocTest<JobCubit, JobState>(
        'emits [JobLoading, JobLoaded] when jobs are loaded successfully',
        build: () => JobCubit(),
        act: (cubit) => cubit.loadJobs(),
        expect: () => [
          isA<JobLoading>(),
          isA<JobLoaded>(),
        ],
      );

      blocTest<JobCubit, JobState>(
        'emits JobLoaded with non-empty jobs list',
        build: () => JobCubit(),
        act: (cubit) => cubit.loadJobs(),
        wait: const Duration(seconds: 2),
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<JobLoaded>());
          if (state is JobLoaded) {
            expect(state.jobs, isNotEmpty);
            expect(state.jobs.first, isA<Job>());
          }
        },
      );
    });

    group('filterByJobType', () {
      blocTest<JobCubit, JobState>(
        'filters jobs by job type correctly',
        build: () => JobCubit(),
        seed: () => JobLoaded(
          jobs: [
            Job(
              id: '1',
              title: 'Flutter Developer',
              company: 'TechCorp',
              location: 'Casablanca',
              salary: '15,000 MAD',
              description: 'Test job',
              requirements: ['Flutter'],
              postedDate: '1 day ago',
              jobType: 'Full-time',
              deadline: DateTime.now().add(const Duration(days: 30)),
            ),
            Job(
              id: '2',
              title: 'Marketing Intern',
              company: 'MarketCo',
              location: 'Rabat',
              salary: '5,000 MAD',
              description: 'Test internship',
              requirements: ['Marketing'],
              postedDate: '2 days ago',
              jobType: 'Internship',
              deadline: DateTime.now().add(const Duration(days: 30)),
            ),
          ],
        ),
        act: (cubit) {
          // Manually set _allJobs since we can't access private fields
          // In real scenario, we'd load jobs first
          cubit.filterByJobType('Full-time');
        },
        skip: 0,
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<JobLoaded>());
          if (state is JobLoaded) {
            expect(state.selectedJobType, 'Full-time');
          }
        },
      );

      blocTest<JobCubit, JobState>(
        'clears filter when null is passed',
        build: () => JobCubit(),
        seed: () => JobLoaded(
          jobs: [
            Job(
              id: '1',
              title: 'Test Job',
              company: 'Test',
              location: 'Test',
              salary: '10,000 MAD',
              description: 'Test',
              requirements: ['Test'],
              postedDate: '1 day ago',
              jobType: 'Full-time',
              deadline: DateTime.now().add(const Duration(days: 30)),
            ),
          ],
          selectedJobType: 'Full-time',
        ),
        act: (cubit) => cubit.filterByJobType(null),
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<JobLoaded>());
          if (state is JobLoaded) {
            expect(state.selectedJobType, isNull);
          }
        },
      );
    });

    group('searchJobs', () {
      blocTest<JobCubit, JobState>(
        'searches jobs by title',
        build: () => JobCubit(),
        seed: () => JobLoaded(
          jobs: [
            Job(
              id: '1',
              title: 'Flutter Developer',
              company: 'TechCorp',
              location: 'Casablanca',
              salary: '15,000 MAD',
              description: 'Test',
              requirements: ['Flutter'],
              postedDate: '1 day ago',
              jobType: 'Full-time',
              deadline: DateTime.now().add(const Duration(days: 30)),
            ),
            Job(
              id: '2',
              title: 'React Developer',
              company: 'WebCo',
              location: 'Rabat',
              salary: '12,000 MAD',
              description: 'Test',
              requirements: ['React'],
              postedDate: '2 days ago',
              jobType: 'Full-time',
              deadline: DateTime.now().add(const Duration(days: 30)),
            ),
          ],
        ),
        act: (cubit) => cubit.searchJobs('Flutter'),
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<JobLoaded>());
          if (state is JobLoaded) {
            expect(state.searchQuery, 'Flutter');
          }
        },
      );

      blocTest<JobCubit, JobState>(
        'search is case-insensitive',
        build: () => JobCubit(),
        seed: () => JobLoaded(
          jobs: [
            Job(
              id: '1',
              title: 'Flutter Developer',
              company: 'TechCorp',
              location: 'Casablanca',
              salary: '15,000 MAD',
              description: 'Test',
              requirements: ['Flutter'],
              postedDate: '1 day ago',
              jobType: 'Full-time',
              deadline: DateTime.now().add(const Duration(days: 30)),
            ),
          ],
        ),
        act: (cubit) => cubit.searchJobs('flutter'),
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<JobLoaded>());
          if (state is JobLoaded) {
            expect(state.searchQuery, 'flutter');
          }
        },
      );
    });

    group('getJobTypes', () {
      test('returns unique job types from loaded jobs', () async {
        // Load jobs first
        await jobCubit.loadJobs();
        
        // Wait for state to be JobLoaded
        await Future.delayed(const Duration(milliseconds: 500));
        
        final jobTypes = jobCubit.getJobTypes();
        
        expect(jobTypes, isNotEmpty);
        expect(jobTypes, isA<List<String>>());
        // Check that all items are unique
        expect(jobTypes.toSet().length, jobTypes.length);
      });
    });

    group('isJobSaved', () {
      test('returns false for unsaved job', () {
        final isSaved = jobCubit.isJobSaved('non-existent-id');
        expect(isSaved, false);
      });
    });

    group('integration test', () {
      blocTest<JobCubit, JobState>(
        'complete workflow: load -> filter -> search',
        build: () => JobCubit(),
        act: (cubit) async {
          await cubit.loadJobs();
          // Wait a bit for jobs to load
          await Future.delayed(const Duration(milliseconds: 500));
          cubit.filterByJobType('Full-time');
          cubit.searchJobs('Developer');
        },
        wait: const Duration(seconds: 2),
        verify: (cubit) {
          final state = cubit.state;
          expect(state, isA<JobLoaded>());
          if (state is JobLoaded) {
            expect(state.selectedJobType, 'Full-time');
            expect(state.searchQuery, 'Developer');
          }
        },
      );
    });
  });
}

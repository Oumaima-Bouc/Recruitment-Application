import 'package:equatable/equatable.dart';
import '../../models/company.dart';

abstract class CompaniesState extends Equatable {
  const CompaniesState();

  @override
  List<Object?> get props => [];
}

class CompaniesInitial extends CompaniesState {}

class CompaniesLoading extends CompaniesState {}

class CompaniesLoaded extends CompaniesState {
  final List<Company> companies;
  final String? selectedIndustry;
  final String searchQuery;
  final List<String> followedCompanyIds;
  final Map<String, int> followerCounts;

  const CompaniesLoaded({
    required this.companies,
    this.selectedIndustry,
    this.searchQuery = '',
    this.followedCompanyIds = const [],
    this.followerCounts = const {},
  });

  @override
  List<Object?> get props => [companies, selectedIndustry, searchQuery, followedCompanyIds, followerCounts];

  CompaniesLoaded copyWith({
    List<Company>? companies,
    String? selectedIndustry,
    String? searchQuery,
    List<String>? followedCompanyIds,
    Map<String, int>? followerCounts,
    bool clearIndustry = false,
  }) {
    return CompaniesLoaded(
      companies: companies ?? this.companies,
      selectedIndustry: clearIndustry ? null : (selectedIndustry ?? this.selectedIndustry),
      searchQuery: searchQuery ?? this.searchQuery,
      followedCompanyIds: followedCompanyIds ?? this.followedCompanyIds,
      followerCounts: followerCounts ?? this.followerCounts,
    );
  }
}

class CompaniesError extends CompaniesState {
  final String message;

  const CompaniesError(this.message);

  @override
  List<Object?> get props => [message];
}

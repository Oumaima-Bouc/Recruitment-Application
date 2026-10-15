import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/dao/company_dao.dart';
import '../../models/company.dart';
import 'companies_state.dart';
import '../../data/dao/company_follower_dao.dart';

class CompaniesCubit extends Cubit<CompaniesState> {
  final CompanyDao _companyDao = CompanyDao();
  final CompanyFollowerDao _followerDao = CompanyFollowerDao();
  List<Company> _allCompanies = [];
  List<String> _followedCompanyIds = [];

  CompaniesCubit() : super(CompaniesInitial());

  Map<String, int> _getFollowerCounts() {
    return {for (var c in _allCompanies) c.id: c.followers};
  }

  Future<void> loadCompanies({String? userId}) async {
    emit(CompaniesLoading());
    try {
      _allCompanies = await _companyDao.getAllCompanies();
      if (userId != null) {
        _followedCompanyIds = await _followerDao.getFollowedCompanyIds(userId);
      }
      emit(CompaniesLoaded(
        companies: _allCompanies, 
        followedCompanyIds: _followedCompanyIds,
        followerCounts: _getFollowerCounts()
      ));
    } catch (e) {
      emit(CompaniesError(e.toString()));
    }
  }

  void filterCompanies({String? industry, String searchQuery = ''}) {
    if (state is CompaniesLoaded) {
      final current = state as CompaniesLoaded;
      final filtered = _allCompanies.where((c) {
        final matchesIndustry = industry == null || industry == 'All' || c.industry == industry;
        final matchesSearch = searchQuery.isEmpty || c.name.toLowerCase().contains(searchQuery.toLowerCase());
        return matchesIndustry && matchesSearch;
      }).toList();

      emit(current.copyWith(
        companies: filtered, 
        selectedIndustry: industry,
        searchQuery: searchQuery,
        followerCounts: _getFollowerCounts()
      ));
    }
  }
  
  Future<void> loadFollowedCompanies(String userId) async {
    try {
      _followedCompanyIds = await _followerDao.getFollowedCompanyIds(userId);
      if (state is CompaniesLoaded) {
        emit((state as CompaniesLoaded).copyWith(
          followedCompanyIds: _followedCompanyIds,
          followerCounts: _getFollowerCounts()
        ));
      }
    } catch (e) {
      print('Error loading followed companies: $e');
    }
  }

  Future<void> toggleFollow(String userId, String companyId) async {
    try {
      // Check actual status from DB to avoid sync issues and unique constraint errors
      final isActuallyFollowing = await _followerDao.isFollowing(userId, companyId);
      
      if (isActuallyFollowing) {
        await _followerDao.unfollowCompany(userId, companyId);
        _followedCompanyIds.remove(companyId);
      } else {
        await _followerDao.followCompany(userId, companyId);
        if (!_followedCompanyIds.contains(companyId)) {
          _followedCompanyIds.add(companyId);
        }
      }

      // Update local company list with new follower count
      final index = _allCompanies.indexWhere((c) => c.id == companyId);
      if (index != -1) {
        final old = _allCompanies[index];
        // If it WAS following (isActuallyFollowing=true), we unfollowed -> decrement.
        // If it WAS NOT following, we followed -> increment.
        final newCount = isActuallyFollowing 
            ? (old.followers > 0 ? old.followers - 1 : 0)
            : old.followers + 1;
            
        _allCompanies[index] = old.copyWith(followers: newCount);
      }
      
      // Emit new state
      if (state is CompaniesLoaded) {
        final current = state as CompaniesLoaded;
        
        final filtered = _allCompanies.where((c) {
          final industry = current.selectedIndustry;
          final searchQuery = current.searchQuery;
          final matchesIndustry = industry == null || industry == 'All' || c.industry == industry;
          final matchesSearch = searchQuery.isEmpty || c.name.toLowerCase().contains(searchQuery.toLowerCase());
          return matchesIndustry && matchesSearch;
        }).toList();
        
        emit(current.copyWith(
          followedCompanyIds: List.from(_followedCompanyIds),
          companies: filtered,
          followerCounts: _getFollowerCounts(),
        ));
      }
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }
  
  bool isFollowing(String companyId) => _followedCompanyIds.contains(companyId);

  List<String> getIndustries() {
    final industries = <String>{'All'};
    for (var c in _allCompanies) {
      industries.add(c.industry);
    }
    return industries.toList();
  }
}

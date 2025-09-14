import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skillsbridge/models/bursary_models.dart';
import 'package:skillsbridge/viewmodels/bursary_screen_vm.dart'; // Import the provider

class BursaryFinderTestScreen extends ConsumerStatefulWidget {
  const BursaryFinderTestScreen({super.key});

  @override
  ConsumerState<BursaryFinderTestScreen> createState() =>
      _BursaryFinderScreenState();
}

class _BursaryFinderScreenState extends ConsumerState<BursaryFinderTestScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize the notifier when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bursaryFinderProvider.notifier).initialize();
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      ref.read(bursaryFinderProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bursaryFinderProvider);
    final notifier = ref.read(bursaryFinderProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state, notifier),
            if (state.errorMessage != null) _buildErrorBanner(state, notifier),
            Expanded(
              child: RefreshIndicator(
                onRefresh: notifier.refreshBursaries,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _buildSearchSection(notifier),
                      _buildFiltersSection(state, notifier),
                      if (state.urgentBursariesCount > 0)
                        _buildDeadlineAlert(state, notifier),
                      _buildResultsBar(state, notifier),
                      if (state.isLoading && state.bursaryList.isEmpty)
                        _buildLoadingState()
                      else if (state.bursaryList.isEmpty)
                        _buildEmptyState(notifier)
                      else
                        _buildBursaryList(state, notifier),
                      if (state.isLoadingMore && state.bursaryList.isNotEmpty)
                        _buildLoadingMore(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BursaryFinderState state,
    BursaryFinderNotifier notifier,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Flexible(
            child: Text(
              'Bursary Finder',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: notifier.onBookmarkTapped,
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bookmark,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    if (state.savedCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            state.savedCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: notifier.refreshBursaries,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: state.isRefreshing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(
    BursaryFinderState state,
    BursaryFinderNotifier notifier,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: const Color(0xFFFEE2E2),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.errorMessage!,
              style: const TextStyle(color: Color(0xFF991B1B), fontSize: 14),
            ),
          ),
          GestureDetector(
            onTap: notifier.refreshBursaries,
            child: const Text(
              'Retry',
              style: TextStyle(
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BursaryFinderNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: notifier.updateSearchQuery,
          decoration: const InputDecoration(
            hintText: 'Search bursaries, scholarships, or funding...',
            prefixIcon: Icon(Icons.search, color: Color(0xFF9CA3AF)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersSection(
    BursaryFinderState state,
    BursaryFinderNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 2),
          bottom: BorderSide(color: Colors.grey[300]!, width: 8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAmountSlider(state, notifier),
          const SizedBox(height: 24),
          _buildFieldOfStudyDropdown(state, notifier),
          const SizedBox(height: 24),
          _buildQuickFilters(state, notifier),
        ],
      ),
    );
  }

  Widget _buildAmountSlider(
    BursaryFinderState state,
    BursaryFinderNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount Needed',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                notifier.getFormattedAmount(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const Text(
              'R0 - R200,000',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Container(
              height: 8,
              width:
                  MediaQuery.of(context).size.width *
                  (state.currentAmount / 200000) *
                  0.85,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        Slider(
          value: state.currentAmount,
          min: 0,
          max: 200000,
          divisions: 40,
          activeColor: const Color(0xFF2563EB),
          inactiveColor: Colors.transparent,
          onChanged: notifier.updateAmount,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPresetButton(20000, notifier),
            _buildPresetButton(50000, notifier),
            _buildPresetButton(90000, notifier),
            _buildPresetButton(150000, notifier),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetButton(double amount, BursaryFinderNotifier notifier) {
    return GestureDetector(
      onTap: () => notifier.setPresetAmount(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          notifier.getPresetAmountLabel(amount),
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildFieldOfStudyDropdown(
    BursaryFinderState state,
    BursaryFinderNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Field of Study',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.selectedField,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              items: state.fieldOptions.map((String field) {
                return DropdownMenuItem<String>(
                  value: field,
                  child: Text(
                    field,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  notifier.updateField(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilters(
    BursaryFinderState state,
    BursaryFinderNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Filters',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: notifier.quickFilterOptions.map((filter) {
            final isActive = state.isFilterActive(filter);
            return GestureDetector(
              onTap: () => notifier.toggleQuickFilter(filter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF2563EB) : Colors.white,
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFD1D5DB),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 13,
                    color: isActive ? Colors.white : const Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeadlineAlert(
    BursaryFinderState state,
    BursaryFinderNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(Icons.warning, color: Color(0xFFF59E0B)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.urgentBursariesCount} Bursaries Closing Soon!',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const Text(
                  'Applications close within the next 7 days',
                  style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: notifier.onViewAllDeadlinesTapped,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFF59E0B)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsBar(
    BursaryFinderState state,
    BursaryFinderNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFFF9FAFB),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '${state.resultsCount} Bursaries Found',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          GestureDetector(
            onTap: () => _showSortOptions(state, notifier),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state.sortOption,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF2563EB)),
            SizedBox(height: 16),
            Text(
              'Loading bursaries...',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BursaryFinderNotifier notifier) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(
              Icons.school_outlined,
              size: 64,
              color: Color(0xFFD1D5DB),
            ),
            const SizedBox(height: 16),
            const Text(
              'No bursaries found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your filters or search terms',
              style: TextStyle(color: Color(0xFF6B7280)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: notifier.refreshBursaries,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Refresh',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMore() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF2563EB),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildBursaryList(
    BursaryFinderState state,
    BursaryFinderNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: state.bursaryList
            .map((bursary) => _buildBursaryCard(bursary, state, notifier))
            .toList(),
      ),
    );
  }

  Widget _buildBursaryCard(
    Bursary bursary,
    BursaryFinderState state,
    BursaryFinderNotifier notifier,
  ) {
    final isSaved = state.isBursarySaved(bursary.id);

    // Map Bursary model to display values
    String amount = 'R${bursary.coverage.amount ?? 'Not specified'}';
    String deadline = bursary.deadline.displayText.isNotEmpty
        ? bursary.deadline.displayText
        : 'Check details';
    String level = bursary.studyLevel.isNotEmpty
        ? bursary.studyLevel
        : 'Various levels';
    String location = bursary.fields.isNotEmpty
        ? bursary.fields.join(', ')
        : 'Multiple fields';

    return GestureDetector(
      onTap: () => _showBursaryDetail(bursary, notifier),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 100,
                  color: bursary.deadline.isUrgent
                      ? const Color(0xFFEF4444)
                      : Colors.transparent,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bursary.provider.name,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(right: 40),
                              child: Text(
                                bursary.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              amount,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _buildMetaItem(
                                  Icons.calendar_today,
                                  deadline,
                                  bursary.deadline.isUrgent,
                                ),
                                _buildMetaItem(Icons.school, level, false),
                                _buildMetaItem(
                                  Icons.location_on,
                                  location,
                                  false,
                                ),
                              ],
                            ),
                            if (bursary
                                .eligibility
                                .qualifications
                                .isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Eligibility Requirements',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF374151),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...bursary.eligibility.qualifications
                                        .take(2)
                                        .map(
                                          (qual) => Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 4,
                                            ),
                                            child: Text(
                                              '• $qual',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF6B7280),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: bursary.tags
                                  .map((tag) => _buildTag(tag))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () => notifier.toggleSaveBursary(bursary.id),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSaved
                                  ? const Color(0xFF2563EB)
                                  : Colors.white,
                              border: Border.all(
                                color: isSaved
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFE5E7EB),
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.bookmark,
                                size: 16,
                                color: isSaved
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text, bool isUrgent) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 13,
          color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFF4B5563),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isUrgent
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF4B5563),
              fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    final isHighlight =
        tag == 'New' || tag == 'Popular' || tag == 'Full Funding';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF2563EB) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 11,
          color: isHighlight ? Colors.white : const Color(0xFF374151),
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  void _showSortOptions(
    BursaryFinderState state,
    BursaryFinderNotifier notifier,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: notifier.sortOptions.map((option) {
              return ListTile(
                title: Text(option),
                trailing: state.sortOption == option
                    ? const Icon(Icons.check, color: Color(0xFF2563EB))
                    : null,
                onTap: () {
                  notifier.updateSortOption(option);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showBursaryDetail(
    Bursary bursary,
    BursaryFinderNotifier notifier,
  ) async {
    // Load full details
    final detailedBursary = await notifier.getBursaryDetails(bursary.id);
    final bursaryToShow = detailedBursary ?? bursary;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final currentState = ref.watch(bursaryFinderProvider);
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bursaryToShow.provider.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    bursaryToShow.title,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'R${bursaryToShow.coverage.amount ?? 'Not specified'}',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailSection(
                            'About This Bursary',
                            'This bursary provides financial assistance for ${bursaryToShow.studyLevel} studies in ${bursaryToShow.fields.join(', ')}.',
                          ),
                          const SizedBox(height: 24),
                          _buildDetailSection(
                            'What\'s Covered',
                            bursaryToShow.coverage.covers.join(', ').isNotEmpty
                                ? bursaryToShow.coverage.covers.join(', ')
                                : 'Please check application details for coverage information.',
                          ),
                          const SizedBox(height: 24),
                          if (bursaryToShow
                              .eligibility
                              .qualifications
                              .isNotEmpty)
                            _buildDetailSection(
                              'Eligibility Requirements',
                              bursaryToShow.eligibility.qualifications.join(
                                '\n• ',
                              ),
                            ),
                          const SizedBox(height: 24),
                          if (bursaryToShow.applicationProcess.steps.isNotEmpty)
                            _buildDetailSection(
                              'How to Apply',
                              '${bursaryToShow.applicationProcess.method}\n\nSteps:\n• ${bursaryToShow.applicationProcess.steps.join('\n• ')}',
                            ),
                          if (bursaryToShow.scraped.sourceUrl.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            _buildDetailSection(
                              'Source',
                              'View original posting: ${bursaryToShow.scraped.sourceUrl}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, -4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              notifier.toggleSaveBursary(bursaryToShow.id),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  currentState.isBursarySaved(bursaryToShow.id)
                                  ? const Color(0xFF2563EB)
                                  : Colors.white,
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.bookmark,
                                size: 20,
                                color:
                                    currentState.isBursarySaved(
                                      bursaryToShow.id,
                                    )
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Opening application page...'),
                                  backgroundColor: Color(0xFF2563EB),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Apply Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}

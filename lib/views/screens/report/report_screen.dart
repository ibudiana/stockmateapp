part of 'package:stockmateapp/views/screens/screens.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // --- STATE PENCARIAN ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Update _searchQuery setiap kali pengguna mengetik
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReportViewModel>();
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    // --- 1. LOGIKA FILTER PENCARIAN LOKAL ---
    final filteredTransactions = viewModel.transactions.where((detail) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final nameMatch = detail.productName.toLowerCase().contains(query);
      final skuMatch = detail.productSku.toLowerCase().contains(query);
      return nameMatch || skuMatch;
    }).toList();

    // --- 2. HITUNG ULANG RINGKASAN BERDASARKAN HASIL PENCARIAN ---
    double filteredTotalIn = 0;
    double filteredTotalOut = 0;
    for (var detail in filteredTransactions) {
      if (detail.transaction.type == TransactionType.inStock) {
        filteredTotalIn += detail.transaction.quantity;
      } else {
        filteredTotalOut += detail.transaction.quantity;
      }
    }
    double filteredTotalTransaction = filteredTotalIn + filteredTotalOut;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      // --- APPBAR DINAMIS (BISA JADI KOLOM SEARCH) ---
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari nama barang atau SKU...',
                  border: InputBorder.none,
                  hintStyle: AppTypography.textMRegular.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
                style: AppTypography.textMRegular.copyWith(
                  color: colors.contentPrimary,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Riwayat Stok', style: AppTypography.headingL),
                  Text(
                    'Pantau pergerakan inventaris Anda',
                    style: AppTypography.textMRegular.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
                ],
              ),
        backgroundColor: colors.surfaceL0,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: colors.contentPrimary,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: Icon(Icons.filter_list, color: colors.contentPrimary),
              onPressed: () {},
            ),
        ],
      ),
      body: Column(
        children: [
          // --- TAB SELECTOR ---
          Container(
            color: colors.surfaceL0,
            child: _buildTabs(context, viewModel, colors),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => viewModel.fetchReport(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CUSTOM DATE FILTER
                    if (viewModel.currentTab == ReportTab.custom)
                      _buildCustomDateFilter(context, viewModel, colors),

                    // SUMMARY DASHBOARD (Gunakan data yang sudah difilter)
                    _buildSummaryDashboard(
                      filteredTotalTransaction,
                      filteredTotalIn,
                      filteredTotalOut,
                      colors,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // TRANSACTION LIST (Gunakan data yang sudah difilter)
                    _buildTransactionList(
                      filteredTransactions,
                      viewModel.status,
                      colors,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  // =========================================================================
  // HELPER WIDGETS
  // =========================================================================

  Widget _buildTabs(
    BuildContext context,
    ReportViewModel viewModel,
    AppColors colors,
  ) {
    return Row(
      children: [
        _buildTabItem(
          title: 'Today',
          isActive: viewModel.currentTab == ReportTab.today,
          onTap: () => viewModel.setTab(ReportTab.today),
          colors: colors,
        ),
        _buildTabItem(
          title: 'Yesterday',
          isActive: viewModel.currentTab == ReportTab.yesterday,
          onTap: () => viewModel.setTab(ReportTab.yesterday),
          colors: colors,
        ),
        _buildTabItem(
          title: 'Custom',
          isActive: viewModel.currentTab == ReportTab.custom,
          onTap: () => viewModel.setTab(ReportTab.custom),
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildTabItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
    required AppColors colors,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? colors.contentBrand : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: isActive
                  ? AppTypography.textMSemibold.copyWith(
                      color: colors.contentBrand,
                    )
                  : AppTypography.textMRegular.copyWith(
                      color: colors.contentSecondary,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDateFilter(
    BuildContext context,
    ReportViewModel viewModel,
    AppColors colors,
  ) {
    final startStr =
        "${viewModel.customStartDate.day.toString().padLeft(2, '0')} ${_getMonth(viewModel.customStartDate.month)} ${viewModel.customStartDate.year}";
    final endStr =
        "${viewModel.customEndDate.day.toString().padLeft(2, '0')} ${_getMonth(viewModel.customEndDate.month)} ${viewModel.customEndDate.year}";

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: colors.surfaceL0,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: viewModel.customStartDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null)
                      viewModel.setCustomDateRange(
                        date,
                        viewModel.customEndDate,
                      );
                  },
                  child: AbsorbPointer(
                    child: AppTextInput.text(
                      label: 'START DATE',
                      hint: startStr,
                      controller: TextEditingController(text: startStr),
                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: viewModel.customEndDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null)
                      viewModel.setCustomDateRange(
                        viewModel.customStartDate,
                        date,
                      );
                  },
                  child: AbsorbPointer(
                    child: AppTextInput.text(
                      label: 'END DATE',
                      hint: endStr,
                      controller: TextEditingController(text: endStr),
                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          AppButton.primary(
            text: 'Apply Filter',
            icon: Icons.filter_list,
            isFullWidth: true,
            onPressed: () => viewModel.fetchReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDashboard(
    double totalTransaction,
    double totalIn,
    double totalOut,
    AppColors colors,
  ) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: colors.contentBrand,
            borderRadius: BorderRadius.circular(AppRadius.m),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Icon(
                  Icons.trending_up,
                  color: Colors.white.withOpacity(0.5),
                  size: 32,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL TRANSAKSI',
                    style: AppTypography.textXSSemibold.copyWith(
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    totalTransaction.toStringAsFixed(0),
                    style: AppTypography.headingXL.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                    ),
                  ),
                  Text(
                    _isSearching ? 'Hasil pencarian' : 'Periode terpilih',
                    style: AppTypography.textSRegular.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),

        Row(
          children: [
            Expanded(
              child: _buildMiniStatCard(
                title: 'STOK MASUK',
                value: '+${totalIn.toStringAsFixed(0)}',
                valueColor: Colors.teal,
                colors: colors,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: _buildMiniStatCard(
                title: 'STOK KELUAR',
                value: '-${totalOut.toStringAsFixed(0)}',
                valueColor: Colors.red,
                colors: colors,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStatCard({
    required String title,
    required String value,
    required Color valueColor,
    required AppColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: colors.backgroundDisabled,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: colors.borderPrimary.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.textXSSemibold.copyWith(
              color: colors.contentSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headingL.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(
    List<TransactionDetailModel> transactions,
    ReportStatus status,
    AppColors colors,
  ) {
    if (status == ReportStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            _isSearching
                ? 'Produk tidak ditemukan.'
                : 'Tidak ada transaksi pada periode ini.',
            style: AppTypography.textMRegular.copyWith(
              color: colors.contentSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceL0,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Detail Transaksi', style: AppTypography.headingM),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.backgroundDisabled,
                    borderRadius: BorderRadius.circular(AppRadius.s),
                  ),
                  child: Text(
                    _isSearching ? 'Hasil Filter' : 'Periode Terpilih',
                    style: AppTypography.textXSRegular.copyWith(
                      color: colors.contentSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount:
                transactions.length, // Tampilkan semua hasil jika di-search
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final detail = transactions[index];
              final isMasuk =
                  detail.transaction.type == TransactionType.inStock;

              final timeStr =
                  "${detail.transaction.createdAt.hour.toString().padLeft(2, '0')}:${detail.transaction.createdAt.minute.toString().padLeft(2, '0')}";

              return Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isMasuk ? Colors.teal : Colors.red,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detail.productName,
                            style: AppTypography.textMSemibold,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.backgroundDisabled,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  detail.productSku,
                                  style: AppTypography.textXSRegular.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '• WH-Main • Admin • $timeStr',
                                style: AppTypography.textXSRegular.copyWith(
                                  color: colors.contentSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isMasuk ? Icons.add_circle : Icons.remove_circle,
                              color: isMasuk ? Colors.teal : Colors.red,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${isMasuk ? '+' : '-'}${detail.transaction.quantity.toStringAsFixed(0)}',
                              style: AppTypography.headingM.copyWith(
                                color: isMasuk ? Colors.teal : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isMasuk
                                ? Colors.tealAccent.withOpacity(0.3)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isMasuk ? 'MASUK' : 'KELUAR',
                            style: AppTypography.textXSSemibold.copyWith(
                              color: isMasuk ? Colors.teal[700] : Colors.red,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}

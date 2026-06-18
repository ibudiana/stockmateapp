part of 'package:stockmateapp/views/screens/screens.dart'; // Pastikan import ini ada

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DashboardViewModel>().loadDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DashboardViewModel>();
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    final now = DateTime.now();
    final dateString =
        "${now.day} ${_getMonthName(now.month)} ${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      appBar: const _HomeAppBar(), // Dipisah menjadi widget tersendiri
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => viewModel.loadDashboardData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    Text(
                      'Ringkasan Aktivitas &\nStok',
                      style: AppTypography.headingXL,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Update terakhir: $dateString',
                      style: AppTypography.textSRegular.copyWith(
                        color: colors.contentSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // --- KARTU DASHBOARD ---
                    _ActivityCard(viewModel: viewModel, colors: colors),
                    const SizedBox(height: AppSpacing.l),

                    _TrendChartCard(viewModel: viewModel, colors: colors),
                    const SizedBox(height: AppSpacing.l),

                    Row(
                      children: [
                        Expanded(
                          child: _MiniStatCard(
                            title: 'Total Jenis\nProduk',
                            value: viewModel.totalProductTypes.toString(),
                            icon: Icons.category_outlined,
                            colors: colors,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        Expanded(
                          child: _MiniStatCard(
                            title: 'Total Transaksi\nStok',
                            value: viewModel.totalTransactions.toString(),
                            icon: Icons.receipt_long_outlined,
                            colors: colors,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // --- STATUS KESEHATAN ---
                    Text(
                      'Status Stok & Kesehatan',
                      style: AppTypography.headingM,
                    ),
                    const SizedBox(height: AppSpacing.m),
                    _HealthStatusCard(
                      title: 'Total Stok Produk',
                      value: viewModel.totalStockUnits.toStringAsFixed(0),
                      suffix: 'unit',
                      icon: Icons.inventory_2_outlined,
                      accentColor: colors.contentBrand,
                      colors: colors,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    _HealthStatusCard(
                      title: 'Stok Product Menipis',
                      value: viewModel.lowStockCount.toString(),
                      suffix: 'SKU',
                      icon: Icons.warning_amber_rounded,
                      accentColor: colors.backgroundPositive,
                      colors: colors,
                    ),
                    const SizedBox(height: AppSpacing.s),
                    _HealthStatusCard(
                      title: 'Stok Produk Habis',
                      value: viewModel.outOfStockCount.toString(),
                      suffix: 'SKU',
                      icon: Icons.error_outline,
                      accentColor: colors.backgroundNegative,
                      colors: colors,
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
    );
  }

  String _getMonthName(int month) => [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ][month - 1];
}

// =======================================================================
// WIDGETS KELAS MANDIRI (Clean Code Architecture)
// =======================================================================

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  String _getInitials(String name) {
    List<String> names = name.trim().split(" ");
    if (names.isEmpty) return "U"; // Default 'User'
    if (names.length == 1) return names[0][0].toUpperCase();
    return "${names[0][0]}${names[1][0]}".toUpperCase();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final currentUser = context.watch<AuthViewModel>().state.user;
    final initials = currentUser != null ? _getInitials(currentUser.name) : 'U';

    return AppBar(
      backgroundColor: colors.surfaceL0,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.inventory_2, color: colors.contentBrand),
          const SizedBox(width: AppSpacing.s),
          Text(
            'StockMate',
            style: AppTypography.headingL.copyWith(color: colors.contentBrand),
          ),
        ],
      ),
      actions: [
        Consumer<NotificationViewModel>(
          builder: (context, notifViewModel, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: colors.contentPrimary,
                  ),
                  onPressed: () {
                    notifViewModel.clearNotificationBadge();
                    context.push('/notifications');
                  },
                ),
                if (notifViewModel.unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        notifViewModel.unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Container(
          margin: const EdgeInsets.only(
            right: AppSpacing.l,
            left: AppSpacing.xs,
          ),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.contentBrand,
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          child: Text(
            initials, // Menampilkan inisial asli user
            style: AppTypography.textXSSemibold.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final DashboardViewModel viewModel;
  final AppColors colors;

  const _ActivityCard({required this.viewModel, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: colors.surfaceL0,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Aktivitas Stok Hari Ini', style: AppTypography.headingM),
              Icon(Icons.trending_up, color: colors.contentBrand),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              _buildStatBox(
                'MASUK',
                viewModel.todayIn.toStringAsFixed(0),
                Icons.arrow_downward,
                Colors.teal,
                Colors.tealAccent,
              ),
              const SizedBox(width: AppSpacing.m),
              _buildStatBox(
                'KELUAR',
                viewModel.todayOut.toStringAsFixed(0),
                Icons.arrow_upward,
                Colors.red,
                Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(
    String label,
    String value,
    IconData icon,
    MaterialColor mainColor,
    MaterialAccentColor accentColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: colors.backgroundDisabled,
          borderRadius: BorderRadius.circular(AppRadius.s),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, color: mainColor[700], size: 20),
            ),
            const SizedBox(width: AppSpacing.s),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.textXSSemibold.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
                Text(value, style: AppTypography.headingL),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendChartCard extends StatelessWidget {
  final DashboardViewModel viewModel;
  final AppColors colors;

  const _TrendChartCard({required this.viewModel, required this.colors});

  @override
  Widget build(BuildContext context) {
    // Kalkulasi nilai Y tertinggi agar chart tidak mentok di atap
    double maxY = 10;
    for (var spot in viewModel.trendInSpots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    for (var spot in viewModel.trendOutSpots) {
      if (spot.y > maxY) maxY = spot.y;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: colors.surfaceL0,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: colors.borderPrimary),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER GRAFIK ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tren Inventaris', style: AppTypography.headingM),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors.backgroundDisabled,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      '7 Hari Terakhir',
                      style: AppTypography.textXSSemibold,
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),

          // --- LEGENDA (Keterangan Garis) ---
          Row(
            children: [
              _buildLegend(color: colors.contentBrand, text: 'Barang Masuk'),
              const SizedBox(width: AppSpacing.l),
              _buildLegend(
                color: colors.backgroundNegative,
                text: 'Barang Keluar',
                isDashed: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // --- AREA GRAFIK ---
          SizedBox(
            height: 180, // Sedikit ditinggikan agar lebih proporsional
            child: LineChart(
              key: ValueKey(
                viewModel.trendInSpots.length + viewModel.trendOutSpots.length,
              ),
              LineChartData(
                minY: 0,
                maxY: maxY + (maxY * 0.2),

                // 1. TOOLTIP SAAT DITEKAN
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        colors.surfaceL0.withOpacity(0.9),
                    tooltipBorder: BorderSide(color: colors.borderPrimary),
                    tooltipBorderRadius: BorderRadius.circular(8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()} Item\n',
                          AppTypography.textXSSemibold.copyWith(
                            color: spot.barIndex == 0
                                ? colors.backgroundPositive
                                : colors.backgroundNegative,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),

                // 2. GARIS BANTU HORIZONTAL (Biar estetik)
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 50 ? (maxY / 4) : 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: colors.borderPrimary.withOpacity(0.5),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),

                // 3. LABEL SUMBU X & Y
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 &&
                            index < viewModel.last7DaysLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              viewModel.last7DaysLabels[index],
                              style: AppTypography.textXSRegular.copyWith(
                                color: colors.contentSecondary,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),

                // 4. GARIS DATA
                lineBarsData: [
                  // Garis Barang Masuk (Dengan Efek Gradien Biru)
                  LineChartBarData(
                    spots: viewModel.trendInSpots,
                    isCurved: true,
                    color: colors.backgroundPositive,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: colors.surfaceL0,
                            strokeWidth: 2,
                            strokeColor: colors.backgroundPositive,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          colors.backgroundPositive.withOpacity(0.3),
                          colors.backgroundPositive.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Garis Barang Keluar (Putus-putus)
                  LineChartBarData(
                    spots: viewModel.trendOutSpots,
                    isCurved: true,
                    color: colors.backgroundNegative,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dashArray: [5, 5],
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 3,
                            color: colors.surfaceL0,
                            strokeWidth: 2,
                            strokeColor: colors.backgroundNegative,
                          ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),

              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk membuat legenda dengan mudah
  Widget _buildLegend({
    required Color color,
    required String text,
    bool isDashed = false,
  }) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
          ),
          child: isDashed
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    3,
                    (index) => Container(width: 4, color: color),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTypography.textXSRegular.copyWith(color: Colors.grey[700]),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final AppColors colors;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: colors.surfaceL0,
        borderRadius: BorderRadius.circular(AppRadius.m),
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colors.contentBrand, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.textXSSemibold.copyWith(
                  color: colors.contentSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(value, style: AppTypography.headingXL),
        ],
      ),
    );
  }
}

class _HealthStatusCard extends StatelessWidget {
  final String title;
  final String value;
  final String suffix;
  final IconData icon;
  final Color accentColor;
  final AppColors colors;

  const _HealthStatusCard({
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.accentColor,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    // KITA BUNGKUS DENGAN 2 CONTAINER AGAR BISA MEMILIKI RADIUS DAN BORDER KIRI
    return Container(
      clipBehavior: Clip.hardEdge, // Memaksa sudut agar bisa melengkung
      decoration: BoxDecoration(
        color: colors.surfaceL0,
        borderRadius: BorderRadius.circular(
          AppRadius.m,
        ), // <--- INI YANG MEMBUATNYA ROUNDED
        border: Border.all(color: colors.borderPrimary),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: accentColor,
              width: 4,
            ), // Garis tebal di kiri
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textXSSemibold.copyWith(
                    color: colors.contentSecondary,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(value, style: AppTypography.headingXL),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        suffix,
                        style: AppTypography.textSRegular.copyWith(
                          color: colors.contentSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              icon,
              color: colors.contentSecondary.withOpacity(0.3),
              size: 48,
            ),
          ],
        ),
      ),
    );
  }
}

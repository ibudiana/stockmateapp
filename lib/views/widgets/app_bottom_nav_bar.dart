part of 'widgets.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex)
      return; // Jangan lakukan apa-apa jika tap di tab yang sama

    // Sesuaikan rute ini dengan konfigurasi AppRouter Anda
    switch (index) {
      case 0:
        context.read<DashboardViewModel>().loadDashboardData();
        context.read<NotificationViewModel>().generateNotifications();
        context.go('/home'); // Rute Home
        break;
      case 1:
        context.go('/products'); // Rute Item / Produk
        break;
      case 2:
        context.go('/reports'); // Rute Report
        break;
      case 3:
        context.go('/settings'); // Rute Setting
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderPrimary, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        backgroundColor: colors.surfaceL0,
        type: BottomNavigationBarType.fixed, // Wajib fixed jika tab >= 4
        selectedItemColor: colors.contentBrand, // Warna biru aktif
        unselectedItemColor:
            colors.contentSecondary, // Warna abu-abu tidak aktif
        selectedLabelStyle: AppTypography.textXSSemibold,
        unselectedLabelStyle: AppTypography.textXSRegular,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.inventory_2_outlined,
            ), // Ikon paling mirip dengan kotak box
            activeIcon: Icon(Icons.inventory_2),
            label: 'Item',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}

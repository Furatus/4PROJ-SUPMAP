import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supmap/features/home/search_bottom_sheet.dart';
import 'package:supmap/features/search/widgets/map_widget.dart';
import 'package:supmap/ui/widgets/app_drawer.dart';

import '../../providers/user_provider.dart';
import 'not_logged_in_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      drawer: AppDrawer(),
      body: Builder(
        builder: (context) {
          return Stack(
            children: [
              const MapWidget(),
              if (userProvider.user != null) const BottomSheetWidget() else const NotLoggedInBottomSheet(),
              Positioned(
                top: 40.0,
                left: 16.0,
                child: FloatingActionButton(
                  heroTag: 'MenuButton',
                  child: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

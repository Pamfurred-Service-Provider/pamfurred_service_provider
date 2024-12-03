import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

// Custom header to adjust pull distance
class CustomHeader extends StatelessWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const ClassicHeader(
      refreshingText: '',
      completeText: '',
      failedText: '',
      idleText: '',
      releaseText: '',
      height: 100.0, // Adjust height for pull distance
      completeDuration: Duration(seconds: 1),
      releaseIcon: Icon(Icons.refresh),
    );
  }
}

// Reusable Pull-to-Refresh Widget
class PullToRefresh extends ConsumerStatefulWidget {
  final Widget child; // Any widget can be passed here
  final List<ProviderOrFamily> providersToRefresh;

  const PullToRefresh({
    super.key,
    required this.child,
    required this.providersToRefresh,
  });

  @override
  ConsumerState<PullToRefresh> createState() => PullToRefreshState();
}

class PullToRefreshState extends ConsumerState<PullToRefresh> {
  late RefreshController refreshController;

  @override
  void initState() {
    super.initState();
    refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    refreshController.dispose(); // Dispose the controller when not in use
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      physics: const BouncingScrollPhysics(),
      controller: refreshController,
      header: const CustomHeader(), // Use the custom header here
      onRefresh: () async {
        try {
          for (var provider in widget.providersToRefresh) {
            // ignore: unused_result
            await ref.refresh(provider as Refreshable);
            // final result = await ref.refresh(provider as Refreshable);
            // For debugging only
            // print('Provider refreshed: $provider with result: $result');
          }
          refreshController.refreshCompleted();
        } catch (e) {
          refreshController.refreshFailed();
          print(e);
        }
      },
      child: widget.child, // Display the passed child widget
    );
  }
}
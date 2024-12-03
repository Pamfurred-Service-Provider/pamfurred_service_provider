import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:service_provider/components/custom_appbar.dart';
import 'package:service_provider/components/custom_padded_button.dart';
import 'package:service_provider/components/date_and_time_formatter.dart';
import 'package:service_provider/components/globals.dart';
import 'package:service_provider/components/pull_to_refresh.dart';
import 'package:service_provider/providers/global_providers.dart';
import 'package:service_provider/providers/report_providers.dart';
import 'package:service_provider/providers/sp_details_provider.dart';
import 'package:service_provider/screens/generate_report/save_btn.dart';

class GenerateReportScreen extends ConsumerStatefulWidget {
  const GenerateReportScreen({super.key, this.restorationId});

  final String? restorationId;

  @override
  ConsumerState<GenerateReportScreen> createState() =>
      _GenerateReportScreenState();
}

class _GenerateReportScreenState extends ConsumerState<GenerateReportScreen>
    with RestorationMixin {
  @override
  void initState() {
    super.initState();

    // Delay the call to ensure the widget tree is initialized before invoking the dialog.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restorableDateRangePickerRouteFuture.present();
    });
  }

  @override
  String? get restorationId => widget.restorationId;

  final RestorableDateTimeN _startDate = RestorableDateTimeN(DateTime(2023));
  final RestorableDateTimeN _endDate =
      RestorableDateTimeN(DateTime(2023, 1, 5));
  late final RestorableRouteFuture<DateTimeRange?>
      _restorableDateRangePickerRouteFuture =
      RestorableRouteFuture<DateTimeRange?>(
          onComplete: _selectDateRange,
          onPresent: (NavigatorState navigator, Object? arguments) {
            return navigator.restorablePush(
              _dateRangePickerRoute,
              arguments: <String, dynamic>{
                'initialStartDate': _startDate.value?.millisecondsSinceEpoch,
                'initialEndDate': _endDate.value?.millisecondsSinceEpoch,
              },
            );
          });

  void _selectDateRange(DateTimeRange? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        _startDate.value = newSelectedDate.start;
        _endDate.value = newSelectedDate.end;

        final selectedStartDate =
            formatDateWithoutTime(_startDate.value.toString());
        final selectedEndDate =
            formatDateWithoutTime(_endDate.value.toString());

        // Update the state in the providers
        ref.watch(reportStartDateProvider.notifier).state = selectedStartDate;
        ref.watch(reportEndDateProvider.notifier).state = selectedEndDate;

        print('Selected start date: $selectedStartDate');
        print('Selected end date: $selectedEndDate');
      });

      // Use the future of the revenue data and handle its states
      final revenueDataFuture = ref.refresh(revenueByDateRangeProvider({
        'spId': ref.watch(userIdProvider),
        'startDate': ref.watch(reportStartDateProvider),
        'endDate': ref.watch(reportEndDateProvider),
      }));

      // Handle the result of the future
      revenueDataFuture.when(
        data: (revenueList) {
          // Process revenue data if needed
          print("Revenue data fetched: $revenueList");
        },
        loading: () {
          // Optionally handle loading state if necessary
          print("Loading revenue data...");
        },
        error: (error, stack) {
          // Handle error state if necessary
          print("Error fetching revenue data: $error");
        },
      );
    }
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_startDate, 'start_date');
    registerForRestoration(_endDate, 'end_date');
    registerForRestoration(
        _restorableDateRangePickerRouteFuture, 'date_picker_route_future');
  }

  @pragma('vm:entry-point')
  static Route<DateTimeRange?> _dateRangePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTimeRange?>(
        context: context,
        builder: (BuildContext context) {
          return DateRangePickerDialog(
            restorationId: 'date_picker_dialog',
            initialDateRange:
                _initialDateTimeRange(arguments! as Map<dynamic, dynamic>),
            firstDate: DateTime(2023),
            currentDate: DateTime(2023, 1, 25),
            lastDate: DateTime(2040),
          );
        });
  }

  static DateTimeRange? _initialDateTimeRange(Map<dynamic, dynamic> arguments) {
    if (arguments['initialStartDate'] != null &&
        arguments['initialEndDate'] != null) {
      return DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(
            arguments['initialStartDate'] as int),
        end: DateTime.fromMillisecondsSinceEpoch(
            arguments['initialEndDate'] as int),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Hold service provider details
    final serviceProvider = ref.watch(serviceProviderProvider);

    // User ID provider
    final userId = ref.watch(userIdProvider);

    // Date ranges provider
    final startDate = ref.watch(reportStartDateProvider);
    final endDate = ref.watch(reportEndDateProvider);

    // Revenue by date range parameters
    final revenuebyDateParams = {
      'spId': userId,
      'startDate': startDate,
      'endDate': endDate,
    };
    final revenuebyDate =
        ref.watch(revenueByDateRangeProvider(revenuebyDateParams));

    return Scaffold(
      appBar: customAppBar(context),
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SaveBtnBuilder(),
      body: PullToRefresh(
        providersToRefresh: [serviceProviderProvider],
        child: Center(
          child: SizedBox(
            width: screenPadding(context),
            child: Column(
              children: [
                serviceProvider.when(
                  data: (sp) {
                    if (sp.isEmpty) {
                      return Center(
                          child: Text('No service provider data available.'));
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              '${sp['establishment_name']} Report for ${secondaryFormatDate(formatDateWithoutTime(_startDate.value.toString()))} - ${secondaryFormatDate(formatDateWithoutTime(_endDate.value.toString()))}',
                              style: TextStyle(fontSize: regularText)),
                        ],
                      ),
                    );
                  },
                  loading: () => Center(child: SizedBox.shrink()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
                const SizedBox(height: secondarySizedBox),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    customPaddedOutlinedTextButton(
                      text: 'Pick date range',
                      onPressed: () {
                        _restorableDateRangePickerRouteFuture.present();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: secondarySizedBox),
                revenuebyDate.when(
                  data: (revenueList) {
                    if (revenueList.isEmpty) {
                      return Center(
                          child: Text(
                              'No revenue data available for this date range.'));
                    } else {
                      return Column(
                        children: revenueList.map((revenue) {
                          return ListTile(
                            title: Text(
                                'Revenue Type: ${revenue['total_amount']}'),
                            subtitle:
                                Text('Total: \$${revenue['total_revenue']}'),
                          );
                        }).toList(),
                      );
                    }
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

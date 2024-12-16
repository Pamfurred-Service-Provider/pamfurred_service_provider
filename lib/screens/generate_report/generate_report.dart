import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restorableDateRangePickerRouteFuture.present();
    });
  }

  @override
  String? get restorationId => widget.restorationId;

  // Initialize RestorableDateTimeN with today's date and one month from today
  final RestorableDateTimeN _startDate = RestorableDateTimeN(DateTime.now());
  final RestorableDateTimeN _endDate =
      RestorableDateTimeN(DateTime.now().add(Duration(days: 30)));

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
    },
  );

  String? selectedStartDate;
  String? selectedEndDate;

  // Select date range from DateRangePickerDialog
  void _selectDateRange(DateTimeRange? newSelectedDate) {
    setState(() {
      if (newSelectedDate != null) {
        _startDate.value = newSelectedDate.start;
        _endDate.value = newSelectedDate.end;

        // Format dates for display
        selectedStartDate = DateFormat('yyyy-MM-dd').format(_startDate.value!);
        selectedEndDate = DateFormat('yyyy-MM-dd').format(_endDate.value!);

        // Update the providers
        ref.read(reportStartDateProvider.notifier).state = selectedStartDate!;
        ref.read(reportEndDateProvider.notifier).state = selectedEndDate!;
      } else {
        // Reset the selected dates if no range is picked
        selectedStartDate = null;
        selectedEndDate = null;

        // Reset the providers
        ref.read(reportStartDateProvider.notifier).state = '';
        ref.read(reportEndDateProvider.notifier).state = '';
      }
    });
  }

  // Fetch revenue data
  Future<List<dynamic>> _fetchRevenueData() async {
    final userId = ref.read(userIdProvider);
    final startDate = ref.read(reportStartDateProvider);
    final endDate = ref.read(reportEndDateProvider);

    return await ref.read(revenueByDateRangeProvider({
      'spId': userId,
      'startDate': startDate,
      'endDate': endDate,
    }).future);
  }

  // Fetch service provider data
  Future<Map<String, dynamic>> _fetchServiceProviderData() async {
    return await ref.read(serviceProviderProvider.future);
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
      BuildContext context, Object? arguments) {
    final today = DateTime.now();
    final oneMonthLater = today.add(Duration(days: 30));

    return DialogRoute<DateTimeRange?>(
      context: context,
      builder: (BuildContext context) {
        return DateRangePickerDialog(
          restorationId: 'date_picker_dialog',
          initialDateRange: DateTimeRange(
            start: today,
            end: oneMonthLater,
          ),
          firstDate: DateTime(2023),
          currentDate: today,
          lastDate: DateTime(2040),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                // If no dates are selected, show validation message
                if (selectedStartDate == null || selectedEndDate == null) ...[
                  Text(
                    'Please select a date range to generate the report.',
                    style: TextStyle(fontSize: regularText),
                  ),
                  const SizedBox(height: secondarySizedBox),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      customPaddedOutlinedTextButton(
                        text: 'Pick date range',
                        onPressed: () {
                          _restorableDateRangePickerRouteFuture.present();
                        },
                        trailingIcon: Icon(Icons.calendar_month),
                      ),
                    ],
                  ),
                ] else ...[
                  // Fetch service provider data
                  FutureBuilder<Map<String, dynamic>>(
                    future: _fetchServiceProviderData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        final sp = snapshot.data!;
                        return Center(
                          child: Column(
                            children: [
                              Text(
                                '${sp['establishment_name']} Appointments on ${secondaryFormatDate(selectedStartDate!)} - ${secondaryFormatDate(selectedEndDate!)}',
                                style: TextStyle(fontSize: regularText),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                            child: Text('Unexpected error occurred.'));
                      }
                    },
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
                        trailingIcon: Icon(Icons.calendar_month),
                      ),
                    ],
                  ),
                  const SizedBox(height: secondarySizedBox),
                  // Fetch and display revenue data
                  FutureBuilder<List<dynamic>>(
                    future: _fetchRevenueData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error fetching revenue data: ${snapshot.error}',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (snapshot.hasData) {
                        final revenueList = snapshot.data!;
                        if (revenueList.isEmpty) {
                          return Center(
                            child: Text(
                              'No revenue data available for this date range.',
                              style: TextStyle(fontSize: regularText),
                            ),
                          );
                        }
                        return Expanded(
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 100),
                            itemCount: revenueList.length,
                            itemBuilder: (context, index) {
                              final revenue = revenueList[index];
                              return Card(
                                color: lighterGreyColor,
                                margin: EdgeInsets.symmetric(
                                    vertical: primarySizedBox,
                                    horizontal: primarySizedBox),
                                elevation: 0.75,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(quaternarySizedBox),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Appointment ID: ${revenue['appointment_id']}',
                                        style: TextStyle(
                                          fontWeight: mediumWeight,
                                          fontSize: regularText,
                                        ),
                                      ),
                                      SizedBox(height: secondarySizedBox),
                                      Text(
                                        'Appointment date: ${revenue['appointment_date']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: secondarySizedBox),
                                      Text(
                                        'Pet owner: ${revenue['pet_owner_name']}',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      SizedBox(height: secondarySizedBox),
                                      Text(
                                        'Total amount: ₱${revenue['total_amount']}',
                                        style: TextStyle(
                                          fontWeight: mediumWeight,
                                          fontSize: smallText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return Center(
                            child: Text('Unexpected error occurred.'));
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

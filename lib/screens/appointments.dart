import 'package:flutter/material.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => AppointmentsScreenState();
}

class AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Appointments"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: const TabBar(
            isScrollable: false,
            labelPadding: EdgeInsets.symmetric(horizontal: 5.0),
            tabs: [
              Padding(
                padding: EdgeInsets.all(1.0),
                child: Tab(text: 'Today'),
              ),
              Padding(
                padding: EdgeInsets.all(1.0),
                child: Tab(text: 'Upcoming'),
              ),
              Padding(
                padding: EdgeInsets.all(1.0),
                child: Tab(text: 'All'),
              ),
              Padding(
                padding: EdgeInsets.all(1.0),
                child: Tab(text: 'Done'),
              ),
              Padding(
                padding: EdgeInsets.all(1.0),
                child: Tab(text: 'Cancelled'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCallLogTab(),
            _buildCallLogTab(),
            _buildCallLogTab(),
            _buildCallLogTab(),
            _buildCallLogTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildCallLogTab() {
    final List<String> Name = [
      'Bob Niño Golosinda',
      'Lynie Rose Gaa',
      'Aillen Gonzaga',
      'Arny Ucab'
    ];
    final List<String> Date = [
      "January 2, 2024",
      "January 2, 2024",
      "January 2, 2024",
      "January 2, 2024"
    ];
    final List<String> Time = ["09:00 AM", "11:00 AM", "01:00 PM", "03:00 PM"];

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: Name.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          borderOnForeground: true,
          elevation: 10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                  "${Name[index]}",
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Date[index],
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      Time[index],
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: const Text('Upcoming'),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}

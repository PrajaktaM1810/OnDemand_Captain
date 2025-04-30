import 'package:flutter/material.dart';
import 'package:flutter_driver/functions/functions.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

class SubscriptionHistory extends StatefulWidget {
  @override
  _SubscriptionHistoryState createState() => _SubscriptionHistoryState();
}

class _SubscriptionHistoryState extends State<SubscriptionHistory> {
  List<Map<String, dynamic>> subscriptionList = [];
  bool isLoading = true;

  Future<void> fetchHistoryList() async {
    setState(() {
      isLoading = true;
    });

    var result = await getSubscriptionHistory(userDetails['id']);

    setState(() {
      isLoading = false;
      if (result['status'] == 'success') {
        subscriptionList = result['data'];
      } else {
        subscriptionList = [];
      }
    });
  }

  String formatDate(String? date) {
    if (date == null) return 'N/A';
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('d MMM y').format(parsedDate);
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchHistoryList();
  }

  Widget buildShimmer() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[200]!,
              highlightColor: Colors.grey[50]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Subscription History",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? buildShimmer()
          : subscriptionList.isNotEmpty
          ? ListView.builder(
        padding: EdgeInsets.only(top: 8, bottom: 16),
        itemCount: subscriptionList.length,
        itemBuilder: (context, index) {
          var plan = subscriptionList[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Subscription ID: ${plan['subscription_id']}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Divider(height: 16, thickness: 1, color: Colors.grey[200]),
                      SizedBox(height: 2),
                      Text(
                        "Package ID: ${plan['package_id']}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Start Date: ${formatDate(plan['start_date'])}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "End Date: ${formatDate(plan['end_date'])}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Transaction ID: ${plan['transaction_id']}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: plan['status'] == 'active'
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        plan['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: plan['status'] == 'active'
                              ? Colors.green[800]
                              : Colors.orange[800],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )
          : Center(
        child: Text(
          "No subscription history available",
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
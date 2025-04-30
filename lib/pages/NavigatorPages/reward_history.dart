import 'package:flutter/material.dart';
import 'package:flutter_driver/functions/functions.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RewardHistory extends StatefulWidget {
  @override
  _RewardHistoryState createState() => _RewardHistoryState();
}

class _RewardHistoryState extends State<RewardHistory> {
  List<Map<String, dynamic>> rewardList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // fetchHistoryList();
  }

  Future<void> fetchHistoryList() async {
    setState(() {
      isLoading = true;
    });

    var result = await getRewardHistory(userDetails['id']);

    setState(() {
      isLoading = false;
      if (result['status'] == 'success') {
        rewardList = result['data'];
      } else {
        rewardList = [];
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
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    height: 14,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
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
          "Reward History",
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
          : rewardList.isNotEmpty
          ? ListView.builder(
        padding: EdgeInsets.only(top: 8, bottom: 16),
        itemCount: rewardList.length,
        itemBuilder: (context, index) {
          var reward = rewardList[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${reward['month']} ${reward['year']}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "₹ ${reward['reward_amount']}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 20, thickness: 1, color: Colors.grey[300]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Distributed At:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        formatDate(reward['distributed_at']),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Created At:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                      Text(
                        formatDate(reward['created_at']),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ) : Center(
        child: Text(
          "No reward history available",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../functions/functions.dart';

class TargetList extends StatefulWidget {
  const TargetList({super.key});

  @override
  State<TargetList> createState() => _TargetListState();
}

class _TargetListState extends State<TargetList> {
  List<Map<String, dynamic>> targetList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTargetList();
  }

  void fetchTargetList() async {
    String result = await getMonthlyTargets();
    setState(() {
      if (result == 'success') {
        targetList = List.from(myTargets);
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        title: const Text(
          "Targets",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? _buildShimmerList()
          : targetList.isEmpty
          ? const Center(child: Text("No targets available"))
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: targetList.length,
        itemBuilder: (context, index) {
          final target = targetList[index];
          return Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.flag, color: Colors.black, size: 20),
              title: Text(
                "${target["month_name"] ?? "Unknown Month"} ${target["year"] ?? "Unknown Year"} ",
                style: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.directions_car, color: Colors.black, size: 16),
                  const SizedBox(width: 4),
                  Text("Target Rides : ${target["target_rides"] ?? "N/A"}",
                    style: const TextStyle(fontSize: 14),),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 4),
                  Text(
                    "₹ ${target["reward_amount"] ?? "N/A"}",
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 3,
          child: ListTile(
            leading: const Icon(Icons.flag, color: Colors.black, size: 20),
            title: _buildShimmerBox(width: 150, height: 14),
            subtitle: Row(
              children: [
                const Icon(Icons.directions_car, color: Colors.black, size: 16),
                const SizedBox(width: 4),
                _buildShimmerBox(width: 100, height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox({double width = 100, double height = 10}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

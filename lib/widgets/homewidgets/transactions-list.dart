// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:money_tracker/models/drop-down-list-item.dart';
import 'package:money_tracker/utils/toast.dart';

import '../../firebase_services/firebase_operations.dart';
import '../../models/transaction.dart';
import '../../utils/themes.dart';

class TransactionList extends StatelessWidget {
  final double screenHeight;
  final ref = FirebaseDatabase.instance.ref('Transactions');
  String duration;
  int incomeExpense;

  TransactionList({
    Key? key,
    required this.screenHeight,
    required this.duration,
    required this.incomeExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MyTransaction>>(
        future: (incomeExpense == 2)
            ? MyFirebaseOperations().getAllTransactions()
            : MyFirebaseOperations().getTransactions(
                duration: duration, transactionType: incomeExpense),
        builder: (BuildContext context,
            AsyncSnapshot<List<MyTransaction>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading indicator while waiting
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data!.isEmpty) {
            return const Text('No Data Available');
          } else {
            final list = snapshot.data;
            return Expanded(
                child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: list!.length,
              itemBuilder: (context, index) =>
                  TransactionItem(item: list[index]),
            ));
          }
        });
  }
}

class TransactionItem extends StatefulWidget {
  final MyTransaction item;
  const TransactionItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  var isLongPressed = false;
  @override
  Widget build(BuildContext context) {
    var imagePath = (widget.item.type == 0)
        ? MyLists().incomeCategoriesList[widget.item.category].iconPath
        : MyLists().expenseCategoriesList[widget.item.category].iconPath;

    return InkWell(
      onLongPress: () {
        setState(() {
          isLongPressed = true;
        });
      },
      onTap: () {
        setState(() {
          isLongPressed = false;
        });
      },
      child: SizedBox(
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                          color: Color(0xFFF0F6F5),
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: (isLongPressed)
                          ? IconButton(
                              icon: const Icon(CupertinoIcons.delete),
                              onPressed: () {
                                MyFirebaseOperations().deleteTransaction(
                                    widget.item.id.toString());
                                MyToast.makeToast('Transaction Deleted');
                              }).animate().flipH()
                          : Image.asset(imagePath)),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.item.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.item.date,
                        style: const TextStyle(color: MyThemes.textColor),
                      )
                    ],
                  )
                ],
              ),
              (widget.item.type == 0)
                  ? Text(
                      "+ \$ ${widget.item.amount}",
                      style: const TextStyle(
                          color: Color(0xFF25A969),
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )
                  : Text(
                      "- \$ ${widget.item.amount}",
                      style: const TextStyle(
                          color: Color(0xFFF95B51),
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    )
            ],
          ),
        ),
      ).animate().scaleY(delay: const Duration(milliseconds: 500)),
    );
  }
}

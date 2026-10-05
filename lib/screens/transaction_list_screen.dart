import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vargani_app/screens/transaction_form_screeen.dart';

import '../data/api_service.dart';
import '../models/transaction_model.dart';

class TransactionListScreen
    extends StatefulWidget {
  final bool isJama;

  const TransactionListScreen({
    super.key,
    required this.isJama,
  });

  @override
  State<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState
    extends State<TransactionListScreen> {
  List<TransactionModel> records = [];

  bool isLoading = true;

  String searchText = '';

  double get totalAmount {
    return records.fold(
      0,
      (sum, item) => sum + item.amount,
    );
  }

  String get transactionType {
    return widget.isJama
        ? 'jama'
        : 'kharch';
  }

  String get title {
    return widget.isJama
        ? 'जमा'
        : 'खर्च';
  }

  @override
  void initState() {
    super.initState();

    loadRecords();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> loadRecords() async {
    try {
      setState(() {
        isLoading = true;
      });

      final result =
          await ApiService.getTransactions(
        transactionType:
            transactionType,
        search: searchText,
      );

      if (!mounted) return;

      setState(() {
        records = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  // ============================================================
  // ADD
  // ============================================================

  Future<void> addRecord() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TransactionFormScreen(
          isJama: widget.isJama,
        ),
      ),
    );

    await loadRecords();
  }

  // ============================================================
  // EDIT
  // ============================================================

  Future<void> editRecord(
    TransactionModel record,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TransactionFormScreen(
          isJama: widget.isJama,
          existingRecord: record,
        ),
      ),
    );

    await loadRecords();
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteRecord(
    TransactionModel record,
  ) async {
    final confirm =
        await showDialog<bool>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete Record',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),

          content: Text(
            'Do you want to delete '
            '${record.regNo} - ${record.name}?',
            style: GoogleFonts.poppins(),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: Text(
                'Cancel',
                style:
                    GoogleFonts.poppins(),
              ),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor:
                    Colors.white,
              ),

              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child: Text(
                'Delete',
                style:
                    GoogleFonts.poppins(),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ApiService.deleteTransaction(
        record.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Record deleted successfully',
            style: GoogleFonts.poppins(),
          ),
        ),
      );

      await loadRecords();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    }
  }

  // ============================================================
  // DATE
  // ============================================================

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${monthName(date.month)} '
        '${date.year}';
  }

  String monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }

  // ============================================================
  // AMOUNT
  // ============================================================

  String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // ============================================================
  // PRINT
  // ============================================================

  void printRecords() {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Print functionality will be added.',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  // ============================================================
  // DOWNLOAD
  // ============================================================

  void downloadRecords() {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          'Download functionality will be added.',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF7F9FC),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Text(
          '$title (${formatAmount(totalAmount)})',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight:
                FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Print',
            onPressed: printRecords,
            icon: const Icon(
              Icons.print_outlined,
            ),
          ),

          IconButton(
            tooltip: 'Download',
            onPressed:
                downloadRecords,
            icon: const Icon(
              Icons.download_outlined,
            ),
          ),

          IconButton(
            tooltip: 'Add',
            onPressed: addRecord,
            icon: const Icon(
              Icons.add,
              size: 29,
              color: Color(0xff2563EB),
            ),
          ),

          const SizedBox(width: 5),
        ],
      ),

      body: Column(
        children: [
          const Divider(
            height: 1,
            thickness: 1,
          ),

          // ==================================================
          // SEARCH
          // ==================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              12,
              12,
              12,
              5,
            ),

            child: TextField(
              onChanged: (value) {
                searchText = value;

                loadRecords();
              },

              style: GoogleFonts.poppins(
                fontSize: 13,
              ),

              decoration:
                  InputDecoration(
                hintText:
                    'Search by Reg No or Name',

                hintStyle:
                    GoogleFonts.poppins(
                  fontSize: 13,
                  color:
                      Colors.grey.shade500,
                ),

                prefixIcon: const Icon(
                  Icons.search,
                  size: 21,
                ),

                suffixIcon: searchText
                        .isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchText = '';

                          loadRecords();
                        },
                        icon: const Icon(
                          Icons.clear,
                        ),
                      )
                    : null,

                filled: true,
                fillColor: Colors.white,

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                  borderSide:
                      BorderSide(
                    color:
                        Colors.grey.shade300,
                  ),
                ),

                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                  borderSide:
                      BorderSide(
                    color:
                        Colors.grey.shade300,
                  ),
                ),

                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(
                    8,
                  ),
                  borderSide:
                      const BorderSide(
                    color:
                        Color(0xff2563EB),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // ==================================================
          // LIST
          // ==================================================

          Expanded(
            child: RefreshIndicator(
              onRefresh: loadRecords,

              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )
                  : records.isEmpty
                      ? _emptyView()
                      : _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyView() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),

      children: [
        SizedBox(
          height:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.55,

          child: Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: [
                Icon(
                  widget.isJama
                      ? Icons
                          .arrow_downward_rounded
                      : Icons
                          .arrow_upward_rounded,

                  size: 55,

                  color:
                      Colors.grey.shade400,
                ),

                const SizedBox(height: 15),

                Text(
                  'No $title records found',
                  style:
                      GoogleFonts.poppins(
                    fontSize: 15,
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 15),

                ElevatedButton.icon(
                  onPressed: addRecord,

                  icon:
                      const Icon(Icons.add),

                  label: Text(
                    'Add $title',
                    style:
                        GoogleFonts.poppins(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LIST
  // ============================================================

  Widget _buildList() {
    return ListView.builder(
      physics:
          const AlwaysScrollableScrollPhysics(),

      padding:
          const EdgeInsets.fromLTRB(
        12,
        7,
        12,
        20,
      ),

      itemCount: records.length,

      itemBuilder:
          (context, index) {
        final record =
            records[index];

        return _transactionCard(
          record,
        );
      },
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _transactionCard(
    TransactionModel record,
  ) {
    return Card(
      elevation: 1,
      color: Colors.white,

      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(10),
      ),

      child: Padding(
        padding:
            const EdgeInsets.all(14),

        child: Column(
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: _info(
                    'Reg No',
                    record.regNo,
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: _info(
                    'Name',
                    record.name,
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: _info(
                    'Date',
                    formatDate(
                      record.date,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Expanded(
                  child: _info(
                    'Amount Type',
                    record.type,
                  ),
                ),

                Expanded(
                  child: _info(
                    'Amount',
                    formatAmount(
                      record.amount,
                    ),
                    valueColor:
                        const Color(
                      0xff2563EB,
                    ),
                  ),
                ),

                Expanded(
                  child: _info(
                    'Status',
                    record.status,
                    valueColor:
                        record.status ==
                                'Done'
                            ? Colors.green
                            : Colors.orange,
                  ),
                ),

                IconButton(
                  tooltip: 'Edit',
                  onPressed: () {
                    editRecord(record);
                  },
                  icon: const Icon(
                    Icons
                        .edit_outlined,
                    size: 20,
                  ),
                ),

                IconButton(
                  tooltip: 'Delete',
                  onPressed: () {
                    deleteRecord(
                      record,
                    );
                  },
                  icon: const Icon(
                    Icons
                        .delete_outline,
                    size: 21,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _info(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        right: 8,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            label,
            style:
                GoogleFonts.poppins(
              fontSize: 10.5,
              color:
                  Colors.grey.shade600,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,

            style:
                GoogleFonts.poppins(
              fontSize: 13,
              fontWeight:
                  FontWeight.w600,
              color:
                  valueColor ??
                      Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
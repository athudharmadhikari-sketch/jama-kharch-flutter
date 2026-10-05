import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/api_service.dart';
import '../models/transaction_model.dart';

class TransactionFormScreen
    extends StatefulWidget {
  final bool isJama;
  final TransactionModel? existingRecord;

  const TransactionFormScreen({
    super.key,
    required this.isJama,
    this.existingRecord,
  });

  @override
  State<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState
    extends State<TransactionFormScreen> {
  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController dateController =
      TextEditingController();

  final TextEditingController amountController =
      TextEditingController();

  DateTime selectedDate =
      DateTime.now();

  String selectedType = 'Cash';

  String selectedStatus = 'Pending';

  bool isSaving = false;

  bool get isEdit {
    return widget.existingRecord != null;
  }

  String get title {
    return widget.isJama
        ? 'जमा'
        : 'खर्च';
  }

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      final record =
          widget.existingRecord!;

      nameController.text =
          record.name;

      selectedDate =
          record.date;

      dateController.text =
          formatDate(record.date);

      selectedType =
          record.type;

      amountController.text =
          record.amount
              .toStringAsFixed(2);

      selectedStatus =
          record.status;
    } else {
      selectedDate =
          DateTime.now();

      dateController.text =
          formatDate(selectedDate);
    }
  }

  // ============================================================
  // DATE
  // ============================================================

  String formatDate(
    DateTime date,
  ) {
    return '${date.day.toString().padLeft(2, '0')} '
        '${monthName(date.month)} '
        '${date.year}';
  }

  String monthName(
    int month,
  ) {
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

  Future<void> selectDate() async {
    final DateTime? picked =
        await showDatePicker(
      context: context,

      initialDate: selectedDate,

      firstDate:
          DateTime(1950),

      lastDate:
          DateTime(2100),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      selectedDate = picked;

      dateController.text =
          formatDate(
        selectedDate,
      );
    });
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> submit() async {
    if (!formKey.currentState!
        .validate()) {
      return;
    }

    final amount =
        double.tryParse(
      amountController.text
          .trim(),
    );

    if (amount == null ||
        amount <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a valid amount',
            style: GoogleFonts.poppins(),
          ),
        ),
      );

      return;
    }

    try {
      setState(() {
        isSaving = true;
      });

      if (isEdit) {
        // ======================================================
        // UPDATE
        // ======================================================

        await ApiService.updateTransaction(
          id:
              widget.existingRecord!.id,

          name:
              nameController.text.trim(),

          date: selectedDate,

          type: selectedType,

          amount: amount,

          status: selectedStatus,
        );
      } else {
        // ======================================================
        // CREATE
        // ======================================================

        final created =
            await ApiService
                .createTransaction(
          name:
              nameController.text.trim(),

          date: selectedDate,

          type: selectedType,

          amount: amount,

          status: selectedStatus,

          transactionType:
              widget.isJama
                  ? 'jama'
                  : 'kharch',
        );

        debugPrint(
          'Created Reg No: ${created.regNo}',
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            isEdit
                ? '$title updated successfully'
                : '$title added successfully',

            style:
                GoogleFonts.poppins(),
          ),
        ),
      );

      Navigator.pop(context);
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

      setState(() {
        isSaving = false;
      });
    }
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
          isEdit
              ? '$title Edit'
              : '$title Add',

          style:
              GoogleFonts.poppins(
            fontSize: 19,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),

      body: Column(
        children: [
          const Divider(
            height: 1,
            thickness: 1,
          ),

          Expanded(
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets.all(16),

              child: Form(
                key: formKey,

                child: Column(
                  children: [
                    // ==================================================
                    // REG NO
                    // ==================================================

                    if (isEdit)
                      _readOnlyField(
                        label: 'Reg No',
                        value:
                            widget
                                .existingRecord!
                                .regNo,
                      )
                    else
                      _readOnlyField(
                        label: 'Reg No',
                        value:
                            'Auto Generated',
                      ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ==================================================
                    // NAME
                    // ==================================================

                    _textField(
                      controller:
                          nameController,

                      label: 'Name',

                      validator:
                          (value) {
                        if (value ==
                                null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Please enter name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ==================================================
                    // DATE
                    // ==================================================

                    _textField(
                      controller:
                          dateController,

                      label: 'Date',

                      readOnly: true,

                      suffixIcon:
                          Icons
                              .calendar_today_outlined,

                      onTap:
                          selectDate,
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ==================================================
                    // TYPE
                    // ==================================================

                    _dropdownField(
                      label: 'Amount Type',

                      value:
                          selectedType,

                      items: const [
                        'Cash',
                        'Online',
                      ],

                      onChanged:
                          (value) {
                        if (value ==
                            null) {
                          return;
                        }

                        setState(() {
                          selectedType =
                              value;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ==================================================
                    // AMOUNT
                    // ==================================================

                    _textField(
                      controller:
                          amountController,

                      label: 'Amount',

                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                      ),

                      validator:
                          (value) {
                        if (value ==
                                null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Please enter amount';
                        }

                        final amount =
                            double.tryParse(
                          value.trim(),
                        );

                        if (amount ==
                                null ||
                            amount <= 0) {
                          return 'Enter valid amount';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ==================================================
                    // STATUS
                    // ==================================================

                    _dropdownField(
                      label: 'Status',

                      value:
                          selectedStatus,

                      items: const [
                        'Pending',
                        'Done',
                      ],

                      onChanged:
                          (value) {
                        if (value ==
                            null) {
                          return;
                        }

                        setState(() {
                          selectedStatus =
                              value;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 30,
                    ),

                    // ==================================================
                    // SUBMIT
                    // ==================================================

                    SizedBox(
                      width:
                          double.infinity,

                      height: 50,

                      child:
                          ElevatedButton(
                        onPressed:
                            isSaving
                                ? null
                                : submit,

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xff2563EB,
                          ),

                          foregroundColor:
                              Colors.white,

                          disabledBackgroundColor:
                              Colors
                                  .grey
                                  .shade400,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              8,
                            ),
                          ),
                        ),

                        child:
                            isSaving
                                ? const SizedBox(
                                    height:
                                        22,
                                    width:
                                        22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color:
                                          Colors.white,
                                    ),
                                  )
                                : Text(
                                    isEdit
                                        ? 'Update'
                                        : 'Submit',

                                    style:
                                        GoogleFonts.poppins(
                                      fontSize:
                                          15,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // READ ONLY FIELD
  // ============================================================

  Widget _readOnlyField({
    required String label,
    required String value,
  }) {
    return TextFormField(
      initialValue: value,

      readOnly: true,

      style:
          GoogleFonts.poppins(
        fontSize: 14,
      ),

      decoration:
          InputDecoration(
        labelText: label,

        labelStyle:
            GoogleFonts.poppins(
          fontSize: 13,
        ),

        filled: true,

        fillColor:
            Colors.grey.shade100,

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
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController
        controller,

    required String label,

    bool readOnly = false,

    IconData? suffixIcon,

    VoidCallback? onTap,

    TextInputType? keyboardType,

    String? Function(String?)?
        validator,
  }) {
    return TextFormField(
      controller: controller,

      readOnly: readOnly,

      onTap: onTap,

      keyboardType:
          keyboardType,

      validator: validator,

      style:
          GoogleFonts.poppins(
        fontSize: 14,
      ),

      decoration:
          InputDecoration(
        labelText: label,

        labelStyle:
            GoogleFonts.poppins(
          fontSize: 13,
        ),

        filled: true,

        fillColor:
            readOnly
                ? Colors.grey.shade100
                : Colors.white,

        suffixIcon:
            suffixIcon == null
                ? null
                : Icon(
                    suffixIcon,
                    size: 20,
                  ),

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

        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            8,
          ),

          borderSide:
              const BorderSide(
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _dropdownField({
    required String label,

    required String value,

    required List<String> items,

    required ValueChanged<String?>
        onChanged,
  }) {
    return DropdownButtonFormField<
        String>(
      initialValue: value,

      items: items
          .map(
            (item) =>
                DropdownMenuItem<String>(
              value: item,

              child: Text(
                item,

                style:
                    GoogleFonts.poppins(
                  fontSize: 14,
                ),
              ),
            ),
          )
          .toList(),

      onChanged: onChanged,

      decoration:
          InputDecoration(
        labelText: label,

        labelStyle:
            GoogleFonts.poppins(
          fontSize: 13,
        ),

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
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    dateController.dispose();
    amountController.dispose();

    super.dispose();
  }
}
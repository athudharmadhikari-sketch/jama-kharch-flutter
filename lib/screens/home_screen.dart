import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/api_service.dart';
import 'transaction_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  bool isLoading = true;

  double jamaTotal = 0;
  double kharchTotal = 0;

  int jamaCount = 0;
  int kharchCount = 0;

  @override
  void initState() {
    super.initState();

    loadSummary();
  }

  // ============================================================
  // LOAD SUMMARY
  // ============================================================

  Future<void> loadSummary() async {
    try {
      setState(() {
        isLoading = true;
      });

      final response =
          await ApiService.getSummary();

      final data =
          Map<String, dynamic>.from(
        response['data'] ?? {},
      );

      final jama =
          Map<String, dynamic>.from(
        data['jama'] ?? {},
      );

      final kharch =
          Map<String, dynamic>.from(
        data['kharch'] ?? {},
      );

      setState(() {
        jamaTotal =
            (jama['total'] as num?)
                    ?.toDouble() ??
                0;

        kharchTotal =
            (kharch['total'] as num?)
                    ?.toDouble() ??
                0;

        jamaCount =
            (jama['count'] as num?)
                    ?.toInt() ??
                0;

        kharchCount =
            (kharch['count'] as num?)
                    ?.toInt() ??
                0;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

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
  // FORMAT
  // ============================================================

  String formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // ============================================================
  // OPEN LIST
  // ============================================================

  Future<void> openList({
    required bool isJama,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TransactionListScreen(
          isJama: isJama,
        ),
      ),
    );

    await loadSummary();
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

        centerTitle: true,

        title: Text(
          'जमा खर्च',
          style: GoogleFonts.poppins(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
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
            child: RefreshIndicator(
              onRefresh: loadSummary,

              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.all(16),

                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    if (isLoading)
                      const Padding(
                        padding:
                            EdgeInsets.all(30),
                        child:
                            CircularProgressIndicator(),
                      )
                    else ...[
                      // ==================================================
                      // JAMA
                      // ==================================================

                      _homeCard(
                        title: 'जमा',
                        total: jamaTotal,
                        count: jamaCount,
                        icon: Icons
                            .arrow_downward_rounded,
                        iconBackground:
                            const Color(
                          0xffE8F5E9,
                        ),
                        iconColor:
                            Colors.green,
                        onTap: () {
                          openList(
                            isJama: true,
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      // ==================================================
                      // KHARCH
                      // ==================================================

                      _homeCard(
                        title: 'खर्च',
                        total: kharchTotal,
                        count: kharchCount,
                        icon: Icons
                            .arrow_upward_rounded,
                        iconBackground:
                            const Color(
                          0xffffebee,
                        ),
                        iconColor: Colors.red,
                        onTap: () {
                          openList(
                            isJama: false,
                          );
                        },
                      ),
                    ],
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
  // HOME CARD
  // ============================================================

  Widget _homeCard({
    required String title,
    required double total,
    required int count,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 145,

      child: Card(
        elevation: 2,
        color: Colors.white,

        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),

        child: InkWell(
          onTap: onTap,

          borderRadius:
              BorderRadius.circular(12),

          child: Padding(
            padding:
                const EdgeInsets.all(20),

            child: Row(
              children: [
                Container(
                  height: 58,
                  width: 58,

                  decoration:
                      BoxDecoration(
                    color: iconBackground,
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 30,
                  ),
                ),

                const SizedBox(width: 18),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [
                      Text(
                        title,
                        style:
                            GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w600,
                          color:
                              Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Total: ${formatAmount(total)}',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 14,
                          color:
                              Colors.grey.shade700,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        '$count Records',
                        style:
                            GoogleFonts.poppins(
                          fontSize: 12,
                          color:
                              Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 18,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
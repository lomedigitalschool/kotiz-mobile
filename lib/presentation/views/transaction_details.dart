import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/transaction_cubit.dart';

class TransactionDetailsPage extends StatefulWidget {
  const TransactionDetailsPage({super.key, required this.id});
  final String id;

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionCubit>().getTransactionDetails(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstant.colorWhite,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Image.asset("assets/images/Logo-Text.png", width: 100),
        ),
      ),
      backgroundColor: ColorConstant.colorWhite,
      body: SafeArea(
        child: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is TransactionDetailsLoaded) {
              final transaction = state.transaction;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Détails de la transaction",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 32),
                    _buildDetailRow(
                      "Montant",
                      "${transaction.amount} ${transaction.currency}",
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow(
                      "Date et heure",
                      "${transaction.dateTime.day} ${transaction.dateTime.month} ${transaction.dateTime.year} à ${transaction.dateTime.hour}h${transaction.dateTime.minute.toString().padLeft(2, '0')}",
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow(
                      "Méthode de paiement",
                      transaction.paymentMethod,
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow(
                      "Statut",
                      transaction.status,
                      isStatus: true,
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow("Référence", transaction.reference),
                  ],
                ),
              );
            } else if (state is TransactionError) {
              return Center(child: Text(state.message));
            }
            return SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isStatus ? Colors.green : Colors.black,
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
// import 'package:equatable/equatable.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kotiz_app/core/services/transaction_service.dart';
// import 'package:kotiz_app/data/models/transaction.dart';

// // States
// abstract class TransactionState extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class TransactionLoading extends TransactionState {}

// class TransactionLoaded extends TransactionState {
//   final List<Transaction> transactions;
//   TransactionLoaded(this.transactions);
//   @override
//   List<Object?> get props => [transactions];
// }

// class TransactionDetailsLoaded extends TransactionState {
//   final Transaction transaction;
//   TransactionDetailsLoaded(this.transaction);
//   @override
//   List<Object?> get props => [transaction];
// }

// class TransactionError extends TransactionState {
//   final String message;
//   TransactionError(this.message);
//   @override
//   List<Object?> get props => [message];
// }

// // Cubit
// class TransactionCubit extends Cubit<TransactionState> {
//   final TransactionService _service;
//   TransactionCubit(this._service) : super(TransactionLoading());

//   Future<void> getAllTransactions() async {
//     emit(TransactionLoading());
//     try {
//       final transactions = await _service.fetchTransactions();
//       emit(TransactionLoaded(transactions));
//     } catch (e) {
//       emit(TransactionError("Erreur lors de la récupération des transactions"));
//     }
//   }

//   Future<void> getTransactionDetails(String id) async {
//     emit(TransactionLoading());
//     try {
//       final transaction = await _service.getTransactionDetails(id);
//       emit(TransactionDetailsLoaded(transaction));
//     } catch (e) {
//       emit(TransactionError("Erreur lors du chargement des détails"));
//     }
//   }
// }

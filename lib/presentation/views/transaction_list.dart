// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kotiz_app/core/utils/color_constants.dart';
// import 'package:kotiz_app/logic/transaction_cubit.dart';
// import 'package:go_router/go_router.dart';

// class TransactionListPage extends StatefulWidget {
//   const TransactionListPage({super.key});

//   @override
//   State<TransactionListPage> createState() => _TransactionListPageState();
// }

// class _TransactionListPageState extends State<TransactionListPage> {
//   @override
//   void initState() {
//     super.initState();
//     context.read<TransactionCubit>().getAllTransactions();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: ColorConstant.colorWhite,
//         centerTitle: true,
//         title: Padding(
//           padding: const EdgeInsets.only(top: 6.0),
//           child: Image.asset("assets/images/Logo-Text.png", width: 100),
//         ),
//       ),
//       backgroundColor: ColorConstant.colorWhite,
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 "Mes transactions",
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//             ),
//             Expanded(
//               child: BlocBuilder<TransactionCubit, TransactionState>(
//                 builder: (context, state) {
//                   if (state is TransactionLoading) {
//                     return Center(child: CircularProgressIndicator());
//                   } else if (state is TransactionLoaded) {
//                     return ListView.builder(
//                       itemCount: state.transactions.length,
//                       itemBuilder: (context, index) {
//                         final transaction = state.transactions[index];
//                         return _buildTransactionItem(
//                           transaction.title,
//                           transaction.type,
//                           transaction.status,
//                           "${transaction.dateTime.day}/${transaction.dateTime.month}/${transaction.dateTime.year}",
//                           transaction.id,
//                         );
//                       },
//                     );
//                   } else if (state is TransactionError) {
//                     return Center(child: Text(state.message));
//                   }
//                   return SizedBox();
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 1, // Assuming this is the second tab
//         onTap: (index) {
//           switch (index) {
//             case 0:
//               context.go('/home');
//               break;
//             case 1:
//               // Stay on current page
//               break;
//             case 2:
//               context.go('/notifications');
//               break;
//             case 3:
//               context.go('/profile');
//               break;
//           }
//         },
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: ColorConstant.colorWhite,
//         selectedItemColor: ColorConstant.colorGreen,
//         unselectedItemColor: Colors.black,
//         showUnselectedLabels: true,
//         showSelectedLabels: true,
//         items: [
//           BottomNavigationBarItem(
//             activeIcon: Icon(Icons.home, color: ColorConstant.colorGreen),
//             icon: Icon(Icons.home_outlined, color: Colors.black),
//             label: "Accueil",
//           ),
//           BottomNavigationBarItem(
//             activeIcon: Icon(Icons.list, color: ColorConstant.colorGreen),
//             icon: Icon(Icons.list_outlined, color: Colors.black),
//             label: "Mes Cagnottes",
//           ),
//           BottomNavigationBarItem(
//             activeIcon: Icon(
//               Icons.notifications,
//               color: ColorConstant.colorGreen,
//             ),
//             icon: Icon(Icons.notifications_outlined, color: Colors.black),
//             label: "Notifications",
//           ),
//           BottomNavigationBarItem(
//             activeIcon: Icon(Icons.person, color: ColorConstant.colorGreen),
//             icon: Icon(Icons.person_outline, color: Colors.black),
//             label: "Profil",
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionItem(
//     String title,
//     String type,
//     String status,
//     String date,
//     String id,
//   ) {
//     Color statusColor;
//     switch (status) {
//       case "Réussi":
//         statusColor = Colors.green;
//         break;
//       case "En cours":
//         statusColor = Colors.orange;
//         break;
//       case "Échec":
//         statusColor = Colors.red;
//         break;
//       default:
//         statusColor = Colors.grey;
//     }

//     return Card(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: ListTile(
//         title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [Text("Type: $type"), Text("Date: $date")],
//         ),
//         trailing: Text(
//           status,
//           style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
//         ),
//         onTap: () {
//           context.go('/transaction/$id');
//         },
//       ),
//     );
//   }
// }

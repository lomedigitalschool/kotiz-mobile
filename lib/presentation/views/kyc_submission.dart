import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/kyc_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _selectedDocumentType;
  final List<String> _documentTypes = [
    'Carte d\'identité',
    'Passeport',
    'Permis de conduire',
  ];
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    context.read<KycCubit>().getKycSubmissions();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _submitKyc() {
    if (_nameController.text.isEmpty ||
        _selectedDate == null ||
        _addressController.text.isEmpty ||
        _selectedDocumentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    context.read<KycCubit>().submitKyc(
      _nameController.text,
      _selectedDate!,
      _addressController.text,
      _selectedDocumentType!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KycCubit, KycState>(
      listener: (context, state) {
        if (state is KycSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Soumission KYC réussie')),
          );
        } else if (state is KycError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Vérifier mon identité",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
                TextFieldComponent(
                  labelTitle: "Nom légal",
                  controller: _nameController,
                  hintText: "Entrez votre nom légal",
                ),
                SizedBox(height: 16),
                TextFieldComponent(
                  labelTitle: "Date de naissance",
                  controller: _birthDateController,
                  hintText: "JJ/MM/AAAA",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                SizedBox(height: 16),
                TextFieldComponent(
                  labelTitle: "Adresse complète",
                  controller: _addressController,
                  hintText: "Entrez votre adresse complète",
                  maxLines: 3,
                ),
                SizedBox(height: 24),
                Text(
                  "Document d'identité",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDocumentType,
                  hint: Text("Type de pièce"),
                  items: _documentTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDocumentType = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement image upload for Recto
                        },
                        icon: Icon(Icons.upload),
                        label: Text("Recto"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement image upload for Verso
                        },
                        icon: Icon(Icons.upload),
                        label: Text("Verso"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                AppButton(
                  text: "Soumettre",
                  onPressed: _submitKyc,
                  backgroundColor: ColorConstant.colorGreen,
                ),
                SizedBox(height: 32),
                Text(
                  "Historique Submissions",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                BlocBuilder<KycCubit, KycState>(
                  builder: (context, state) {
                    if (state is KycLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is KycLoaded) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: state.submissions.length,
                        itemBuilder: (context, index) {
                          final submission = state.submissions[index];
                          return _buildSubmissionItem(
                            "Soumission ${index + 1}",
                            submission.status,
                          );
                        },
                      );
                    } else if (state is KycError) {
                      return Center(child: Text(state.message));
                    }
                    return SizedBox();
                  },
                ),
                SizedBox(height: 32),
                Text(
                  "Conseils pour une soumission réussie",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "• Assurez-vous que toutes les informations sont correctes.",
                    ),
                    Text("• Vérifiez la qualité des images."),
                    Text("• Soumettez des documents valides."),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionItem(String title, String status) {
    Color statusColor;
    switch (status) {
      case "Validated":
        statusColor = Colors.green;
        break;
      case "Rejected":
        statusColor = Colors.red;
        break;
      case "In Review":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        trailing: Text(
          status,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

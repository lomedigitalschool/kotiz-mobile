import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/data/models/pool.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:kotiz_app/presentation/components/app_button.dart';
import 'package:kotiz_app/presentation/components/text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class EditPoolPage extends StatefulWidget {
  final String poolId;

  const EditPoolPage({super.key, required this.poolId});

  @override
  State<EditPoolPage> createState() => _EditPoolPageState();
}

class _EditPoolPageState extends State<EditPoolPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _goalAmountController;
  late DateTime _deadline;
  late String _type;
  Pool? _pool;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _goalAmountController = TextEditingController();
    _deadline = DateTime.now().add(const Duration(days: 30));
    _type = 'public';
    _loadPoolData();
  }

  Future<void> _loadPoolData() async {
    try {
      await context.read<PoolCubit>().getPoolDetails(widget.poolId);
    } catch (e) {
      debugPrint('Erreur lors du chargement des données de la cagnotte: $e');
    }
  }

  void _initializeControllers(Pool pool) {
    _titleController.text = pool.title;
    _descriptionController.text = pool.description;
    _goalAmountController.text = pool.goalAmount.toString();
    _deadline = pool.deadline;
    _type = pool.type;
    _pool = pool;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _goalAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _deadline) {
      setState(() {
        _deadline = picked;
      });
    }
  }

  void _updatePool() {
    if (_formKey.currentState!.validate() && _pool != null) {
      final updatedPool = Pool(
        id: _pool!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        goalAmount: double.parse(_goalAmountController.text),
        currentAmount: _pool!.currentAmount,
        currency: _pool!.currency,
        deadline: _deadline,
        type: _type,
        imageUrl: _pool!.imageUrl,
        status: _pool!.status,
        contributionCount: _pool!.contributionCount,
        progressPercentage: _pool!.progressPercentage,
        owner: _pool!.owner,
        recentContributions: _pool!.recentContributions,
      );

      context.read<PoolCubit>().updatePool(updatedPool);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.colorWhite,
      appBar: AppBar(
        title: const Text("Modifier la cagnotte"),
        backgroundColor: ColorConstant.colorWhite,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<PoolCubit, PoolState>(
        listener: (context, state) {
          if (state is PoolDetailsLoaded && _isLoading) {
            _initializeControllers(state.pool);
          } else if (state is PoolSuccess) {
            toastification.show(
              context: context,
              type: ToastificationType.success,
              title: const Text('Cagnotte modifiée avec succès'),
              backgroundColor: Colors.green.shade100,
              autoCloseDuration: const Duration(seconds: 3),
            );
            context.pop();
          } else if (state is PoolError) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              title: Text('Erreur: ${state.message}'),
              backgroundColor: Colors.red.shade100,
              autoCloseDuration: const Duration(seconds: 3),
            );
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFieldComponent(
                        labelTitle: "Titre de la cagnotte",
                        controller: _titleController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le titre est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFieldComponent(
                        labelTitle: "Description",
                        controller: _descriptionController,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La description est requise';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFieldComponent(
                        labelTitle: "Montant objectif (FCFA)",
                        controller: _goalAmountController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le montant est requis';
                          }
                          final amount = int.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Montant invalide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date limite
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.calendar),
                              const SizedBox(width: 12),
                              Text(
                                "Date limite: ${_deadline.day}/${_deadline.month}/${_deadline.year}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Type de cagnotte
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: const InputDecoration(
                          labelText: "Type de cagnotte",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'public',
                            child: Text('Publique'),
                          ),
                          DropdownMenuItem(
                            value: 'private',
                            child: Text('Privée'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _type = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 32),

                      BlocBuilder<PoolCubit, PoolState>(
                        builder: (context, state) {
                          return AppButton(
                            text: state is PoolLoading
                                ? "Modification..."
                                : "Modifier la cagnotte",
                            onPressed: state is PoolLoading
                                ? null
                                : _updatePool,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

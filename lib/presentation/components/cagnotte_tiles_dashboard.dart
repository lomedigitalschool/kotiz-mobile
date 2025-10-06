import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kotiz_app/core/utils/color_constants.dart';
import 'package:kotiz_app/logic/auth_cubit.dart';
import 'package:kotiz_app/logic/pool_cubit.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:toastification/toastification.dart';

class CagnotteTilesDashboard9 extends StatelessWidget {
  const CagnotteTilesDashboard9({
    super.key,
    this.image,
    required this.title,
    required this.poolId,
  });
  final String poolId;
  final String? image;
  final String title;

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer cette cagnotte ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await context.read<PoolCubit>().deletePool(poolId);
                  // Refresh dashboard after deletion
                  context.read<AuthCubit>().refreshDashboard();
                  toastification.show(
                    context: context,
                    type: ToastificationType.success,
                    title: const Text('Cagnotte supprimée'),
                    backgroundColor: Colors.green.shade200,
                    autoCloseDuration: const Duration(seconds: 3),
                  );
                } catch (e) {
                  toastification.show(
                    context: context,
                    type: ToastificationType.error,
                    title: const Text('Erreur'),
                    description: Text('Erreur lors de la suppression: $e'),
                    backgroundColor: Colors.red.shade200,
                    autoCloseDuration: const Duration(seconds: 3),
                  );
                }
              },
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        // Image avec gesture detector pour détails
        GestureDetector(
          onTap: () => context.push("/poolDetails/$poolId"),
          child: Card(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image != null && image!.isNotEmpty
                  ? Image.network(
                      image!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return SizedBox(
                          width: 100,
                          height: 100,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/Logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/Logo.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),

        // Titre et boutons d'action
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.push("/poolDetails/$poolId"),
                child: Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Bouton modifier
                  TextButton.icon(
                    onPressed: () => context.push("/edit-pool/$poolId"),
                    icon: Icon(
                      LucideIcons.pencil,
                      size: 16,
                      color: ColorConstant.colorBlue,
                    ),
                    label: Text(
                      'Modifier',
                      style: TextStyle(
                        color: ColorConstant.colorBlue,
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Bouton supprimer
                  TextButton.icon(
                    onPressed: () => _showDeleteConfirmation(context),
                    icon: Icon(LucideIcons.trash, size: 16, color: Colors.red),
                    label: Text(
                      'Supprimer',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

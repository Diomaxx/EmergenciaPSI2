import 'package:flutter/material.dart';
import '../models/emergency_request.dart';

class EmergencyCard extends StatelessWidget {
  final EmergencyRequest emergencyRequest;
  final String userRole;
  final VoidCallback? onAcceptHelp;
  final bool isAcceptingHelp;

  const EmergencyCard({
    super.key,
    required this.emergencyRequest,
    required this.userRole,
    this.onAcceptHelp,
    this.isAcceptingHelp = false,
  });

  IconData _getCategoryIcon() {
    switch (emergencyRequest.categoria.toLowerCase()) {
      case 'incendio':
        return Icons.local_fire_department;
      case 'inundacion':
        return Icons.water_damage;
      default:
        return Icons.emergency;
    }
  }

  Color _getCategoryColor() {
    switch (emergencyRequest.categoria.toLowerCase()) {
      case 'incendio':
        return Colors.red[600] ?? Colors.red;
      case 'inundacion':
        return Colors.blue[600] ?? Colors.blue;
      default:
        return Colors.grey[600] ?? Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildPersonnelSection() {
    final requiredPersonnel = emergencyRequest.personalNecesario[userRole];
    if (requiredPersonnel == null || requiredPersonnel == 0) {
      return const SizedBox.shrink();
    }
    final rolesConS = {'bombero', 'rescatista'};
    final roleText = '$userRole${rolesConS.contains(userRole) ? "s" : ""}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: emergencyRequest.apoyoaceptado ? Colors.grey[600] : Colors.black,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Se requieren $requiredPersonnel $roleText',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (emergencyRequest.apoyoaceptado)
            _buildAcceptedIndicator()
          else
            _buildAcceptButton(),
        ],
      ),
    );
  }

  Widget _buildAcceptedIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[600],
        border: Border.all(color: Colors.white),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            'ACEPTADO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton() {
    return ElevatedButton(
      onPressed: isAcceptingHelp ? null : onAcceptHelp,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const RoundedRectangleBorder(),
        elevation: 0,
      ),
      child: isAcceptingHelp
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
          : const Text(
              'ACEPTAR AYUDA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  Widget _buildProductsSection() {
    final products = emergencyRequest.parsedProducts;
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Productos necesarios:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: products.entries.map((entry) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                '${entry.key}: ${entry.value}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(
              Icons.group,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              '${emergencyRequest.cantidadPersonas} personas afectadas',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inicio: ${_formatDate(emergencyRequest.fechaInicioIncendio)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Solicitud: ${_formatDate(emergencyRequest.fechaSolicitud)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getCategoryColor(),
            ),
            child: Row(
              children: [
                Icon(
                  _getCategoryIcon(),
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    emergencyRequest.categoria.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (emergencyRequest.apoyoaceptado)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Text(
                      'APOYO ACEPTADO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailsSection(),
                
                const SizedBox(height: 16),
                
                _buildProductsSection(),
              ],
            ),
          ),
          
          _buildPersonnelSection(),
        ],
      ),
    );
  }
} 
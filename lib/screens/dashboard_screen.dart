import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/emergency_request.dart';
import '../services/api_service.dart';
import '../widgets/emergency_card.dart';
import '../widgets/volunteer_info_modal.dart';
import '../screens/login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final User user;

  const DashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<EmergencyRequest> _emergencyRequests = [];
  List<EmergencyRequest> _filteredRequests = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<int> _acceptingHelp = {};
  Set<int> _locallyAccepted = {};

  @override
  void initState() {
    super.initState();
    _loadEmergencyRequests();
  }

  Future<void> _loadEmergencyRequests() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final requests = await ApiService.fetchEmergencyRequests();
      final filteredRequests = ApiService.filterRequestsByRole(
        requests,
        widget.user.role,
      );

      if (mounted) {
        setState(() {
          _emergencyRequests = requests;
          _filteredRequests = filteredRequests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _handleLogout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    _locallyAccepted.clear();
    await _loadEmergencyRequests();
  }

  Future<void> _handleAcceptHelp(EmergencyRequest request) async {
    if (_acceptingHelp.contains(request.idSolicitud) || 
        _locallyAccepted.contains(request.idSolicitud)) {
      return;
    }

    final volunteerInfo = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VolunteerInfoModal(
        userRole: widget.user.role,
        onSubmit: (info) => Navigator.of(context).pop(info),
      ),
    );

    if (volunteerInfo == null) return;

    setState(() {
      _acceptingHelp.add(request.idSolicitud);
    });

    try {
      await ApiService.acceptEmergencyHelp(request.idSolicitud);
      
      await ApiService.sendVolunteerInfo(request.idSolicitud, volunteerInfo);
      
      if (mounted) {
        setState(() {
          _locallyAccepted.add(request.idSolicitud);
          _acceptingHelp.remove(request.idSolicitud);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ayuda aceptada e información enviada exitosamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _loadEmergencyRequests();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _acceptingHelp.remove(request.idSolicitud);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al procesar la solicitud: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  bool _isRequestAccepted(EmergencyRequest request) {
    return request.apoyoaceptado || _locallyAccepted.contains(request.idSolicitud);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isSmallScreen = screenWidth < 360;
            
            return Row(
              children: [
                Text(
                  widget.user.roleIcon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.user.displayName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _handleRefresh,
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
            ),
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(
              Icons.logout,
              color: Colors.black,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.black,
            ),
            SizedBox(height: 16),
            Text(
              'Cargando solicitudes...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Error al cargar datos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleRefresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_filteredRequests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Sin solicitudes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No hay solicitudes de emergencia que requieran ${widget.user.role}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Colors.black,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredRequests.length,
        itemBuilder: (context, index) {
          final request = _filteredRequests[index];
          final isAccepted = _isRequestAccepted(request);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EmergencyCard(
              emergencyRequest: EmergencyRequest(
                idSolicitud: request.idSolicitud,
                fechaInicioIncendio: request.fechaInicioIncendio,
                fechaSolicitud: request.fechaSolicitud,
                cantidadPersonas: request.cantidadPersonas,
                categoria: request.categoria,
                listaProductos: request.listaProductos,
                idSolicitante: request.idSolicitante,
                idDestino: request.idDestino,
                personalNecesario: request.personalNecesario,
                apoyoaceptado: isAccepted,
              ),
              userRole: widget.user.role,
              onAcceptHelp: isAccepted || _acceptingHelp.contains(request.idSolicitud)
                  ? null
                  : () => _handleAcceptHelp(request),
              isAcceptingHelp: _acceptingHelp.contains(request.idSolicitud),
            ),
          );
        },
      ),
    );
  }
} 
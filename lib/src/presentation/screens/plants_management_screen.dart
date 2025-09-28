import 'package:flutter/material.dart';
import '../../data/models/plant_model.dart';
import '../../data/services/plant_service.dart';
import '../../core/theme.dart';

class PlantsManagementScreen extends StatefulWidget {
  final String accessToken;

  const PlantsManagementScreen({super.key, required this.accessToken});

  @override
  State<PlantsManagementScreen> createState() => _PlantsManagementScreenState();
}

class _PlantsManagementScreenState extends State<PlantsManagementScreen> {
  final PlantService _plantService = PlantService();
  List<PlantModel> _plants = [];
  List<PlantModel> _filteredPlants = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    try {
      final plants = await _plantService.getAllPlants(widget.accessToken);
      if (mounted) {
        setState(() {
          _plants = plants;
          _isLoading = false;
        });
        _filterPlants();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar plantas: $e')),
        );
      }
    }
  }

  Future<void> _deletePlant(String plantId) async {
    try {
      await _plantService.deletePlant(plantId, widget.accessToken);
      _loadPlants();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Planta eliminada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar planta: $e')),
        );
      }
    }
  }

  void _showCreatePlantModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreatePlantModal(
          accessToken: widget.accessToken,
          onPlantCreated: _loadPlants,
        );
      },
    );
  }

  void _showEditPlantModal(PlantModel plant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditPlantModal(
          accessToken: widget.accessToken,
          plant: plant,
          onPlantUpdated: _loadPlants,
        );
      },
    );
  }

  void _filterPlants() {
    setState(() {
      _filteredPlants = _plants.where((plant) {
        final matchesSearch = plant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            plant.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            plant.quantity.toString().contains(_searchQuery);

        return matchesSearch;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterPlants();
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    return words.length >= 2 
        ? '${words[0].isNotEmpty ? words[0][0].toUpperCase() : ''}${words[1].isNotEmpty ? words[1][0].toUpperCase() : ''}'
        : name.isNotEmpty ? name[0].toUpperCase() : 'P';
  }

  List<Color> _getAvatarColors(String name) {
    final colors = [
      [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      [const Color(0xFF667eea), const Color(0xFF764ba2)],
      [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      [const Color(0xFFffecd2), const Color(0xFFfcb69f)],
      [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
      [const Color(0xFFffeaa7), const Color(0xFFfab1a0)],
      [const Color(0xFF74b9ff), const Color(0xFF0984e3)],
      [const Color(0xFFf093fb), const Color(0xFFf5576c)],
    ];
    
    int index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  void _showDeleteConfirmDialog(PlantModel plant) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.surfaceGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.error,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Confirmar Eliminación',
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Estás seguro de que quieres eliminar la planta ${plant.name}?',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Esta acción no se puede deshacer.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.error, Color(0xFFDC2626)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.error.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _deletePlant(plant.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_forever, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Administrar Plantas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF43e97b),
                Color(0xFF38f9d7),
              ],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF43e97b)),
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                decoration: const InputDecoration(
                                  hintText: 'Buscar plantas...',
                                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GradientButton(
                            text: 'Nueva Planta',
                            onPressed: _showCreatePlantModal,
                            icon: const Icon(Icons.add, color: Colors.white, size: 20),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.local_florist,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_filteredPlants.length} de ${_plants.length} plantas',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredPlants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No se encontraron plantas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'Intenta con otros términos de búsqueda'
                                    : 'No hay plantas para mostrar',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPlants.length,
                          itemBuilder: (context, index) {
                            final plant = _filteredPlants[index];
                            return AnimatedContainer(
                              duration: Duration(milliseconds: 300 + (index * 100)),
                              curve: Curves.easeOutBack,
                              transform: Matrix4.translationValues(0, 0, 0),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                      spreadRadius: 2,
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _showEditPlantModal(plant),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        Hero(
                                          tag: 'plant-avatar-${plant.id}',
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: _getAvatarColors(plant.name),
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(30),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: _getAvatarColors(plant.name)[0].withValues(alpha: 0.3),
                                                  spreadRadius: 2,
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                _getInitials(plant.name),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                plant.name,
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF2d3748),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                plant.description,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: plant.quantity > 0
                                                          ? Colors.green[100]
                                                          : Colors.red[100],
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.inventory,
                                                          size: 14,
                                                          color: plant.quantity > 0
                                                              ? Colors.green[800]
                                                              : Colors.red[800],
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${plant.quantity}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w500,
                                                            color: plant.quantity > 0
                                                                ? Colors.green[800]
                                                                : Colors.red[800],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF43e97b).withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  color: Color(0xFF43e97b),
                                                  size: 20,
                                                ),
                                                onPressed: () => _showEditPlantModal(plant),
                                                tooltip: 'Editar planta',
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.red[50],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: IconButton(
                                                icon: Icon(
                                                  Icons.delete_outline,
                                                  color: Colors.red[600],
                                                  size: 20,
                                                ),
                                                onPressed: () => _showDeleteConfirmDialog(plant),
                                                tooltip: 'Eliminar planta',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class CreatePlantModal extends StatefulWidget {
  final String accessToken;
  final VoidCallback onPlantCreated;

  const CreatePlantModal({
    super.key,
    required this.accessToken,
    required this.onPlantCreated,
  });

  @override
  State<CreatePlantModal> createState() => _CreatePlantModalState();
}

class _CreatePlantModalState extends State<CreatePlantModal> {
  final _formKey = GlobalKey<FormState>();
  final PlantService _plantService = PlantService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  bool _isLoading = false;

  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cantidad es requerida';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity < 0) {
      return 'Ingresa una cantidad válida';
    }
    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Future<void> _createPlant() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final newPlant = CreatePlantModel(
          name: _nameController.text,
          description: _descriptionController.text,
          quantity: int.parse(_quantityController.text),
        );

        await _plantService.createPlant(newPlant, widget.accessToken);
        widget.onPlantCreated();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Planta creada exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear planta: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFf8f9ff),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Crear Nueva Planta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nombre de la planta',
                          icon: Icons.local_florist,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El nombre es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Descripción',
                          icon: Icons.description,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La descripción es requerida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _quantityController,
                          label: 'Cantidad',
                          icon: Icons.inventory,
                          keyboardType: TextInputType.number,
                          validator: _validateQuantity,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF43e97b).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createPlant,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Crear Planta',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditPlantModal extends StatefulWidget {
  final String accessToken;
  final PlantModel plant;
  final VoidCallback onPlantUpdated;

  const EditPlantModal({
    super.key,
    required this.accessToken,
    required this.plant,
    required this.onPlantUpdated,
  });

  @override
  State<EditPlantModal> createState() => _EditPlantModalState();
}

class _EditPlantModalState extends State<EditPlantModal> {
  final _formKey = GlobalKey<FormState>();
  final PlantService _plantService = PlantService();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant.name);
    _descriptionController = TextEditingController(text: widget.plant.description);
    _quantityController = TextEditingController(text: widget.plant.quantity.toString());
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cantidad es requerida';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity < 0) {
      return 'Ingresa una cantidad válida';
    }
    return null;
  }

  Widget _buildEditTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }

  Future<void> _updatePlant() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final updatedPlant = UpdatePlantModel(
          name: _nameController.text,
          description: _descriptionController.text,
          quantity: int.parse(_quantityController.text),
        );

        await _plantService.updatePlant(widget.plant.id, updatedPlant, widget.accessToken);
        widget.onPlantUpdated();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Planta actualizada exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar planta: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFf8f9ff),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Editar Planta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildEditTextField(
                          controller: _nameController,
                          label: 'Nombre de la planta',
                          icon: Icons.local_florist,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El nombre es requerido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildEditTextField(
                          controller: _descriptionController,
                          label: 'Descripción',
                          icon: Icons.description,
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La descripción es requerida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildEditTextField(
                          controller: _quantityController,
                          label: 'Cantidad',
                          icon: Icons.inventory,
                          keyboardType: TextInputType.number,
                          validator: _validateQuantity,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF43e97b).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updatePlant,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Actualizar Planta',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
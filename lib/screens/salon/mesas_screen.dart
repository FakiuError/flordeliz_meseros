import 'dart:async';
import 'package:flutter/material.dart';
//import 'package:flordeliz_meseros/screens/salon/categorias_screen.dart';
import "package:flordeliz_meseros/services/salon/producto_service.dart";
import "package:flordeliz_meseros/services/salon/pedido_service.dart";
import "package:flordeliz_meseros/services/salon/mesas_service.dart";

class MesasScreen extends StatefulWidget {
  final int idUsuario;

  const MesasScreen({Key? key, required this.idUsuario}) : super(key: key);

  @override
  State<MesasScreen> createState() => _MesasScreenState();
}

class _MesasScreenState extends State<MesasScreen>
    with SingleTickerProviderStateMixin {

  final MesasService _mesasService = MesasService();

  List<dynamic> mesas = [];
  List<dynamic> domicilios = [];
  bool cargando = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    obtenerMesas();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => obtenerMesas());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> obtenerMesas() async {
    final result = await _mesasService.obtenerMesas();

    if (result["success"] == true) {
      setState(() {
        mesas = result["mesas"];
        domicilios = result["domicilios"];
        cargando = false;
      });
    } else {
      setState(() => cargando = false);
    }
  }

  void _crearDomicilio() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController direccionController =
        TextEditingController();

        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Nuevo Domicilio",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: direccionController,
            decoration: const InputDecoration(
              labelText: "Dirección del domicilio",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
              ),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFdd0330),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final direccion = direccionController.text.trim();
                if (direccion.isEmpty) return;

                final result = await _mesasService.crearDomicilio(
                  direccion: direccion,
                  idEmpleado: widget.idUsuario,
                );

                if (result["success"] == true) {
                  Navigator.pop(context);

                  obtenerMesas();

                  //Navigator.push(
                    //context,
                    //MaterialPageRoute(
                      //builder: (context) => CategoriasExpandiblesScreen(
                        //idMesa: result["id_mesa"],
                        //idUsuario: widget.idUsuario,
                        //nombreMesa: direccion,
                        //idPedidoExistente: result["id_pedido"],
                      //),
                    //),
                  //);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          result["message"] ?? "Error al crear domicilio"),
                      backgroundColor: Colors.red.shade600,
                    ),
                  );
                }
              },
              child: const Text("Crear y abrir"),
            ),
          ],
        );
      },
    );
  }

  // 🔵 TODO LO DEMÁS (UI) SE MANTIENE IGUAL ↓↓↓

  Color _colorPorEstado(int estado, int esDomicilio) {
    switch (estado) {
      case 1:
        return Colors.green.shade200;
      case 2:
        return Colors.orange.shade200;
      case 3:
        return esDomicilio == 1
            ? Colors.blue.shade200
            : Colors.red.shade200;
      case 4:
        return Colors.grey.shade300;
      default:
        return Colors.grey.shade100;
    }
  }

  String _textoPorEstado(int estado, int esDomicilio) {
    switch (estado) {
      case 1:
        return "Disponible";
      case 2:
        return "En preparación";
      case 3:
        return esDomicilio == 1 ? "En camino" : "Ocupada";
      case 4:
        return "Finalizada";
      default:
        return "Desconocido";
    }
  }

  Widget _buildMesaCard(Map mesa) {
    final int estado =
        int.tryParse(mesa['estado_pedido'].toString()) ?? 0;
    final int esDomicilio =
        int.tryParse(mesa['es_domicilio'].toString()) ?? 0;
    final int idMesa =
        int.tryParse(mesa['id_mesa'].toString()) ?? 0;
    final String nombreMesa = mesa['nombre_mesa'].toString();

    final color = _colorPorEstado(estado, esDomicilio);
    final textoEstado = _textoPorEstado(estado, esDomicilio);

    return GestureDetector(
      onTap: () {
        if ((estado == 2 || estado == 3) &&
            mesa['id_pedido'] != null) {
          final int idPedido =
              int.tryParse(mesa['id_pedido'].toString()) ?? 0;
          /*
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoriasExpandiblesScreen(
                idMesa: idMesa,
                idUsuario: widget.idUsuario,
                nombreMesa: nombreMesa,
                idPedidoExistente: idPedido,
              ),
            ),
          );

           */
        } else if (estado == 1) {
          /*
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoriasExpandiblesScreen(
                idMesa: idMesa,
                idUsuario: widget.idUsuario,
                nombreMesa: nombreMesa,
              ),
            ),
          );

           */
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  "Esta mesa no está disponible para pedidos."),
              backgroundColor: Colors.orange.shade700,
            ),
          );
        }
      },
      child: Card(
        color: color,
        elevation: 6,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nombreMesa,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                textoEstado,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Atiende: ${mesa['mesero']}",
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              if (esDomicilio == 1) ...[
                const SizedBox(height: 8),
                const Icon(Icons.delivery_dining,
                    color: Colors.black87),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(child: Text("No hay registros disponibles"));
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate:
        const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildMesaCard(items[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFdd0330),
          title: const Text(
            "Gestión de Pedidos",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: "Mesas"),
              Tab(text: "Domicilios"),
              Tab(text: "Vitrina")
            ],
          ),
          actions: [
            IconButton(
              icon:
              const Icon(Icons.add_home_rounded, color: Colors.white),
              onPressed: _crearDomicilio,
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: obtenerMesas,
            ),
          ],
        ),
        body: cargando
            ? const Center(
            child: CircularProgressIndicator(
                color: Color(0xFFdd0330)))
            : TabBarView(
          children: [
            _buildGrid(mesas),
            _buildGrid(domicilios),
          ],
        ),
      ),
    );
  }
}
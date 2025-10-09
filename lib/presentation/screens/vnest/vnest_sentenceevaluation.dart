import 'dart:math';
import 'package:flutter/material.dart';

class VnestSentenceEvaluationScreen extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const VnestSentenceEvaluationScreen({super.key, required this.exercise});

  @override
  State<VnestSentenceEvaluationScreen> createState() => _VnestSentenceEvaluationScreenState();
}

class _VnestSentenceEvaluationScreenState extends State<VnestSentenceEvaluationScreen> {
  final background = const Color(0xFFFEF9F4);
  final orange = const Color(0xFFFF8A00);

  late List<Map<String, dynamic>> sentences;
  int index = 0;
  double deltaX = 0.0;
  bool dragging = false;
  Offset startPos = Offset.zero;

  @override
  void initState() {
    super.initState();
    final oraciones = (widget.exercise['oraciones'] as List?) ?? [];
    sentences = _shuffle(oraciones.asMap().entries.map((e) {
      final idx = e.key;
      final o = e.value as Map<String, dynamic>;
      return {
        "id": idx,
        "text": o['oracion'] ?? "",
        "correcta": o['correcta'] ?? false,
        "status": "pending",
      };
    }).toList());
  }

  List<T> _shuffle<T>(List<T> items) {
    final rand = Random();
    for (int i = items.length - 1; i > 0; i--) {
      int j = rand.nextInt(i + 1);
      final temp = items[i];
      items[i] = items[j];
      items[j] = temp;
    }
    return items;
  }

  bool get showDone => index >= sentences.length;

  void handleDecision(String decision) {
    if (showDone) return;
    setState(() {
      sentences[index]['status'] = decision;
      index++;
      deltaX = 0.0;
    });
  }

  void handleAccept() => handleDecision('accepted');
  void handleReject() => handleDecision('rejected');

  void onStart(DragStartDetails details) {
    if (showDone) return;
    startPos = details.globalPosition;
    dragging = true;
  }

  void onUpdate(DragUpdateDetails details) {
    if (!dragging) return;
    setState(() {
      deltaX = details.globalPosition.dx - startPos.dx;
    });
  }

  void onEnd(DragEndDetails details) {
    const threshold = 80;
    if (deltaX > threshold) {
      handleAccept();
    } else if (deltaX < -threshold) {
      handleReject();
    } else {
      setState(() {
        deltaX = 0.0;
      });
    }
    dragging = false;
  }

  @override
  Widget build(BuildContext context) {
    final current = !showDone ? sentences[index] : null;
    final accepted = sentences.where((s) => s['status'] == 'accepted').toList();
    final reviewed = sentences.where((s) => s['status'] != 'pending').toList();

    final int ok = reviewed.where((s) {
      final userSaysCorrect = s['status'] == 'accepted';
      return userSaysCorrect == s['correcta'];
    }).length;

    final score = {"ok": ok, "total": sentences.length};

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Evalúa las oraciones",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Text(
                "Desliza a la derecha si es correcta, a la izquierda si es incorrecta.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // --- Zona de cartas tipo Tinder ---
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // cartas en el fondo
                    if (!showDone)
                      ...sentences
                          .sublist(index + 1, min(index + 3, sentences.length))
                          .asMap()
                          .entries
                          .map((entry) {
                        final i = entry.key;
                        final s = entry.value;
                        return Transform.translate(
                          offset: Offset(0, 12 + i * 10),
                          child: Transform.scale(
                            scale: 1 - i * 0.04,
                            child: Opacity(
                              opacity: 0.6 - i * 0.15,
                              child: _buildCard(s['text'], null, false),
                            ),
                          ),
                        );
                      }),

                    // carta activa
                    if (!showDone && current != null)
                      GestureDetector(
                        onHorizontalDragStart: onStart,
                        onHorizontalDragUpdate: onUpdate,
                        onHorizontalDragEnd: onEnd,
                        child: Transform.translate(
                          offset: Offset(deltaX, 0),
                          child: Transform.rotate(
                            angle: deltaX * 0.01,
                            child: _buildCard(
                              current['text'],
                              deltaX,
                              true,
                            ),
                          ),
                        ),
                      ),

                    // cuando se acaban
                    if (showDone)
                      Column(
                        children: [
                          const SizedBox(height: 30),
                          Text(
                            "¡Listo!",
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Aciertos: ${score['ok']} / ${score['total']}",
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 20),

                          // === Lista scrollable de resultados ===
                          Expanded(
                            child: ListView.builder(
                              itemCount: reviewed.length,
                              itemBuilder: (context, i) {
                                final s = reviewed[i];
                                final userSaysCorrect = s['status'] == 'accepted';
                                final acertaste = userSaysCorrect == s['correcta'];

                                final bg = acertaste ? Colors.green.shade50 : Colors.red.shade50;
                                final border = acertaste ? Colors.green.shade300 : Colors.red.shade300;
                                final tagBg = acertaste ? Colors.green.shade100 : Colors.red.shade100;
                                final tagText = acertaste ? Colors.green.shade700 : Colors.red.shade700;
                                final title = acertaste ? "✅ Acertaste" : "❌ Te equivocaste";

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    border: Border.all(color: border, width: 2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: tagBg,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          title,
                                          style: TextStyle(
                                            color: tagText,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        s['text'] ?? "",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Sistema: ${s['correcta'] ? "Correcta" : "Incorrecta"} · Tú marcaste: ${userSaysCorrect ? "Bien" : "Mal"}",
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Botones Bien / Mal
              if (!showDone)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: handleReject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Mal"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: handleAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Bien"),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 10),

              // Progreso
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Fase 3", style: TextStyle(color: Colors.grey)),
                  Text(
                    showDone
                        ? "3/4"
                        : "${min(index + 1, sentences.length)}/${sentences.length}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: index / sentences.length,
                  backgroundColor: Colors.grey.shade200,
                  color: orange,
                  minHeight: 8,
                ),
              ),

              const SizedBox(height: 12),

              // Finalizar o siguiente
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Anterior"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: showDone
                          ? () => Navigator.pushNamed(
                        context,
                        '/vnest-phase4',
                        arguments: widget.exercise,
                      )
                          : handleAccept,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        showDone ? "Finalizar" : "Marcar Bien",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String text, double? deltaX, bool active) {
    Color? shadowColor;
    if (deltaX != null && deltaX > 0) shadowColor = Colors.green.shade200;
    if (deltaX != null && deltaX < 0) shadowColor = Colors.red.shade200;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          if (active)
            BoxShadow(
              color: shadowColor ?? Colors.grey.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}

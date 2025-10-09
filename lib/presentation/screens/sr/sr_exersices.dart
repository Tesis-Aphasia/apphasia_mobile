import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../register/register_viewmodel.dart';

class SRExercisesScreen extends StatefulWidget {
  const SRExercisesScreen({super.key});

  @override
  State<SRExercisesScreen> createState() => _SRExercisesScreenState();
}

class _SRExercisesScreenState extends State<SRExercisesScreen> {
  final background = const Color(0xFFFEF9F4);
  final orange = const Color(0xFFFF8A00);

  bool loading = true;
  List<Map<String, dynamic>> cards = [];
  Map<String, dynamic>? currentCard;
  Map<String, dynamic>? cardState;
  String mode = "question"; // question | timer | doneCard
  String feedback = "";
  int secondsLeft = 0;
  TextEditingController answerCtrl = TextEditingController();
  Timer? timer;

  // === Inicialización ===
  @override
  void initState() {
    super.initState();
    Future.microtask(_loadCards);
  }

  Future<void> _loadCards() async {
    final userId = Provider.of<RegisterViewModel>(context, listen: false).userId;
    if (userId!.isEmpty) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection("sr_cards")
          .where("user_id", isEqualTo: userId)
          .get();

      final data = snap.docs.map((d) => {"id": d.id, ...d.data()}).toList();

      if (data.isEmpty) {
        setState(() {
          loading = false;
        });
        return;
      }

      final first = data.first;
      setState(() {
        cards = data;
        currentCard = first;
        cardState = {
          ...first,
          "baseline_index": -1,
          "interval_index": 0,
          "success_streak": 0,
          "lapses": 0,
          "last_answer_correct": null,
          "last_timer_index": null,
        };
        mode = "question";
        loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error cargando tarjetas: $e")));
      setState(() => loading = false);
    }
  }

  // === Submit respuesta ===
  void handleSubmit() async {
    if (currentCard == null || cardState == null) return;
    final userAns = answerCtrl.text.trim().toLowerCase();
    final correctAns = (currentCard!["answer"] ?? "").trim().toLowerCase();
    final isCorrect = userAns == correctAns;

    answerCtrl.clear();
    final intervals = List<int>.from(currentCard!["intervals_sec"] ?? [15, 30, 60, 120, 240]);
    final nextIndex = isCorrect
        ? (cardState!["interval_index"] + 1).clamp(0, intervals.length - 1)
        : 0;

    final updated = {
      ...cardState!,
      "interval_index": nextIndex,
      "success_streak": isCorrect
          ? (cardState!["success_streak"] ?? 0) + 1
          : 0,
      "lapses": isCorrect
          ? (cardState!["lapses"] ?? 0)
          : (cardState!["lapses"] ?? 0) + 1,
      "last_answer_correct": isCorrect,
      "next_due": DateTime.now().millisecondsSinceEpoch +
          intervals[nextIndex] * 1000,
    };

    setState(() {
      cardState = updated;
      secondsLeft = intervals[nextIndex];
      feedback = isCorrect
          ? "✅ Correcto"
          : "❌ Incorrecto. Respuesta: ${currentCard!["answer"]}";
      mode = "timer";
    });

    await FirebaseFirestore.instance
        .collection("sr_cards")
        .doc(currentCard!["id"])
        .update({
      "interval_index": updated["interval_index"],
      "success_streak": updated["success_streak"],
      "lapses": updated["lapses"],
      "next_due": updated["next_due"],
      "last_answer_correct": updated["last_answer_correct"],
    });

    _startCountdown();
  }

  void _startCountdown() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft <= 1) {
        t.cancel();
        onTimerFinished();
      } else {
        setState(() => secondsLeft--);
      }
    });
  }

  void onTimerFinished() {
    final intervals = List<int>.from(currentCard!["intervals_sec"]);
    if (cardState!["interval_index"] >= intervals.length - 1 &&
        cardState!["last_answer_correct"] == true) {
      setState(() {
        mode = "doneCard";
      });
      return;
    }
    setState(() {
      mode = "question";
      feedback = "";
    });
  }

  void handleNextCard() {
    final currentIndex = cards.indexWhere((c) => c["id"] == currentCard!["id"]);
    final nextIndex = (currentIndex + 1) % cards.length;
    setState(() {
      currentCard = cards[nextIndex];
      cardState = {
        ...cards[nextIndex],
        "baseline_index": -1,
        "interval_index": 0,
        "success_streak": 0,
        "lapses": 0,
        "last_answer_correct": null,
        "last_timer_index": null,
      };
      mode = "question";
      feedback = "";
      secondsLeft = 0;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (cards.isEmpty) {
      return Scaffold(
        backgroundColor: background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "No hay ejercicios todavía 😊",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Volver"),
              )
            ],
          ),
        ),
      );
    }

    final intervals =
    List<int>.from(currentCard!["intervals_sec"] ?? [15, 30, 60, 120, 240]);
    final intervalLabel = mode == "timer"
        ? "Intervalo actual: ${intervals[cardState!["interval_index"]]}s"
        : "Base: ${intervals[cardState!["interval_index"]]}s — Próximo si aciertas: ${intervals[(cardState!["interval_index"] + 1).clamp(0, intervals.length - 1)]}s";

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
          "Spaced Retrieval",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(intervalLabel,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15)),
            const SizedBox(height: 20),

            // --- Card principal ---
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: mode == "question"
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentCard!["stimulus"] ?? "Sin pregunta",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: answerCtrl,
                        decoration: InputDecoration(
                          hintText: "Escribe tu respuesta...",
                          filled: true,
                          fillColor: Colors.orange.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          padding:
                          const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Enviar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      if (feedback.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            feedback,
                            style: TextStyle(
                              color: feedback.startsWith("✅")
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  )
                      : mode == "timer"
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        feedback,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: feedback.startsWith("✅")
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Repetiremos esta pregunta en $secondsLeft segundos",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "🎉 ¡Completaste esta pregunta!",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Has superado el último intervalo (240s).",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: handleNextCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Siguiente tarjeta",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

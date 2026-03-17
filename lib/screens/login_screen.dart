import 'package:flutter/material.dart';
import 'package:green_guard/screens/officer_home_screen.dart';
import 'package:green_guard/screens/supervisor_home_screen.dart';
import 'package:green_guard/screens/worker_home_screen.dart';
import 'package:green_guard/widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('GreenGuard')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.eco_rounded,
                          color: cs.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Select role',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Development mode role selector. Real authentication will be re-enabled later.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.black54),
                      ),
                      const SizedBox(height: 18),
                      // Development mode role selector. Real authentication will be re-enabled later.
                      CustomButton(
                        label: 'Continue as Worker',
                        icon: Icons.engineering_rounded,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WorkerHomeScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Continue as Supervisor',
                        icon: Icons.supervisor_account_rounded,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SupervisorHomeScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Continue as Officer',
                        icon: Icons.shield_outlined,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OfficerHomeScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

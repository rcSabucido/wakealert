import 'package:flutter/material.dart';
import 'package:wakealert/signup/sign_up_password.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false,),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Create your Account',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // First Name
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.left,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter first name' : null,
              ),
              const SizedBox(height: 15),

              // Last Name
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.left,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter last name' : null,
              ),
              const SizedBox(height: 15),

              // Email Address
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  border: OutlineInputBorder(),
                ),
                textAlign: TextAlign.left,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter email address';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation Buttons
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(10),
             child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              // Back Arrow Button (small)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_back, size: 24),
              ),

              // Next Button (bigger width)
              SizedBox(
              width: 130, 
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const SignUpPassword()),
                      );}
                  },
                  child: const Text('Next',style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w700, 
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
           
    );
  }
}

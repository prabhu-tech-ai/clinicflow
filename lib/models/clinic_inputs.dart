class PatientInput {
  const PatientInput({
    required this.fullName,
    this.mobile,
    this.dateOfBirth,
    this.address,
    this.bloodGroup,
    this.allergies,
    this.medicalHistory,
  });

  final String fullName;
  final String? mobile;
  final DateTime? dateOfBirth;
  final String? address;
  final String? bloodGroup;
  final String? allergies;
  final String? medicalHistory;
}

class VisitInput {
  const VisitInput({
    required this.patientId,
    required this.visitType,
    required this.visitDate,
    this.doctorId,
    this.symptoms,
    this.notes,
  });

  final String patientId;
  final String visitType;
  final DateTime visitDate;
  final String? doctorId;
  final String? symptoms;
  final String? notes;
}

class PrescriptionItemInput {
  const PrescriptionItemInput({
    required this.medicineId,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.quantity = 1,
  });

  final String medicineId;
  final String dosage;
  final String frequency;
  final String duration;
  final int quantity;
}

class PrescriptionInput {
  const PrescriptionInput({
    required this.visitId,
    required this.patientId,
    this.doctorId,
    this.diagnosis,
    this.advice,
    this.items = const [],
  });

  final String visitId;
  final String patientId;
  final String? doctorId;
  final String? diagnosis;
  final String? advice;
  final List<PrescriptionItemInput> items;
}

class MedicineInput {
  const MedicineInput({required this.name, this.form, this.strength, this.stock = 0});

  final String name;
  final String? form;
  final String? strength;
  final int stock;
}

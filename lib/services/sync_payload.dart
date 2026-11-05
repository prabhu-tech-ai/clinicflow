import '../database/database.dart';

class SyncPayload {
  static Map<String, Object?> patient(Patient row) => {
    'id': row.id,
    'patientCode': row.patientCode,
    'fullName': row.fullName,
    'mobile': row.mobile,
    'dateOfBirth': row.dateOfBirth?.toIso8601String(),
    'address': row.address,
    'bloodGroup': row.bloodGroup,
    'allergies': row.allergies,
    'medicalHistory': row.medicalHistory,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
    'isDeleted': row.isDeleted,
  };

  static Map<String, Object?> visit(Visit row) => {
    'id': row.id,
    'patientId': row.patientId,
    'doctorId': row.doctorId,
    'visitType': row.visitType,
    'visitDate': row.visitDate.toIso8601String(),
    'symptoms': row.symptoms,
    'notes': row.notes,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
    'isDeleted': row.isDeleted,
  };

  static Map<String, Object?> medicine(Medicine row) => {
    'id': row.id,
    'name': row.name,
    'form': row.form,
    'strength': row.strength,
    'stock': row.stock,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
    'isDeleted': row.isDeleted,
  };

  static Map<String, Object?> doctor(Doctor row) => {
    'id': row.id,
    'userId': row.userId,
    'fullName': row.fullName,
    'specialization': row.specialization,
    'phone': row.phone,
    'email': row.email,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
    'isDeleted': row.isDeleted,
  };

  static Map<String, Object?> employee(Employee row) => {
    'id': row.id,
    'userId': row.userId,
    'fullName': row.fullName,
    'jobTitle': row.jobTitle,
    'phone': row.phone,
    'email': row.email,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
    'isDeleted': row.isDeleted,
  };

  static Map<String, Object?> prescription(
    Prescription row,
    List<PrescriptionItem> items,
  ) => {
    'id': row.id,
    'visitId': row.visitId,
    'patientId': row.patientId,
    'doctorId': row.doctorId,
    'diagnosis': row.diagnosis,
    'advice': row.advice,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
    'isDeleted': row.isDeleted,
    'items': items.map(prescriptionItem).toList(),
  };

  static Map<String, Object?> prescriptionItem(PrescriptionItem row) => {
    'id': row.id,
    'prescriptionId': row.prescriptionId,
    'medicineId': row.medicineId,
    'dosage': row.dosage,
    'frequency': row.frequency,
    'duration': row.duration,
    'quantity': row.quantity,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
    'isDeleted': row.isDeleted,
  };

  static Map<String, Object?> user(User row) => {
    'id': row.id,
    'username': row.username,
    'role': row.role,
    'displayName': row.displayName,
    'createdAt': row.createdAt.toIso8601String(),
    'updatedAt': row.updatedAt.toIso8601String(),
    'isDeleted': row.isDeleted,
  };

  static Map<String, Object?> auditLog(AuditLog row) => {
    'id': row.id,
    'userId': row.userId,
    'entityType': row.entityType,
    'entityId': row.entityId,
    'action': row.action,
    'details': row.details,
    'createdAt': row.createdAt.toIso8601String(),
  };
}

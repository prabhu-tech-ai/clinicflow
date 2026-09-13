import '../database/daos/medicine_dao.dart';
import '../database/daos/patient_dao.dart';
import '../database/daos/prescription_dao.dart';
import '../database/daos/staff_dao.dart';
import '../database/daos/user_dao.dart';
import '../database/daos/visit_dao.dart';
import '../database/database.dart';
import '../models/clinic_inputs.dart';

class ClinicRepository {
  ClinicRepository([ClinicDatabase? database]) : _db = database ?? clinicDatabase {
    patients = PatientDao(_db);
    visits = VisitDao(_db);
    medicines = MedicineDao(_db);
    prescriptions = PrescriptionDao(_db);
    staff = StaffDao(_db);
    users = UserDao(_db);
  }

  final ClinicDatabase _db;
  late final PatientDao patients;
  late final VisitDao visits;
  late final MedicineDao medicines;
  late final PrescriptionDao prescriptions;
  late final StaffDao staff;
  late final UserDao users;

  Future<Patient> savePatient(PatientInput input, {String? id}) => patients.save(input, id: id);
  Future<Visit> saveVisit(VisitInput input, {String? id}) => visits.save(input, id: id);
  Future<Medicine> saveMedicine(MedicineInput input, {String? id}) => medicines.save(input, id: id);
  Future<Prescription> savePrescription(PrescriptionInput input, {String? id}) => prescriptions.save(input, id: id);
}

final clinicRepository = ClinicRepository();

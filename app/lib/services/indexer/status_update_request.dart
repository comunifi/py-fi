import 'package:app/models/cw_transaction.dart';
import 'package:app/utils/random.dart';

class StatusUpdateRequest {
  final TransactionStatus status;
  final String uuid = generateRandomId();

  StatusUpdateRequest(this.status);

  Map<String, dynamic> toJson() => {'status': status.name, 'uuid': uuid};
}

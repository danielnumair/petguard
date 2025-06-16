import '../database/consulta_dao.dart';
import '../database/pet_dao.dart';
import '../database/vacina_dao.dart';
import '../database/vermifugo_dao.dart';
import '../database/config_dao.dart';
import 'notification_service.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class AgendamentoNotificacoesService {
  static Future<void> agendarParaUsuario(int usuarioId) async {
    // Limpa todas as notificações existentes antes de agendar novas
    await NotificationService.cancelAll();

    final config = await ConfigDAO().getByUsuario(usuarioId);
    if (config == null) return;

    final pets = await PetDAO().getByUsuario(usuarioId);

    // Consultas
    if (config.lembreteConsulta) {
      for (var pet in pets) {
        final consultas = await ConsultaDAO().getByPet(pet.id!);
        for (var c in consultas) {
          if (c.proxima != null) {
            _agendarNotificacao(
              id: 1000 + c.id!,
              titulo: 'Consulta do ${pet.nome}',
              dataBase: c.proxima!,
              diasAntes: config.diasConsulta,
              mensagem: 'Consulta do ${pet.nome} marcada para ${DateFormat(
                  'dd/MM/yyyy').format(c.proxima!)}.',
            );
          }
        }
      }
    }

    // Vacinas
    if (config.lembreteVacina) {
      for (var pet in pets) {
        final vacinas = await VacinaDAO().getByPet(pet.id!);
        for (var v in vacinas) {
          _agendarNotificacao(
            id: 2000 + v.id!,
            titulo: 'Vacina do ${pet.nome}',
            dataBase: v.proxima,
            diasAntes: config.diasVacina,
            mensagem: 'Vacina do ${pet.nome} vence em ${DateFormat('dd/MM/yyyy').format(v.proxima)}.',
          );
        }
      }
    }

    // Vermífugos
    if (config.lembreteVermifugo) {
      for (var pet in pets) {
        final vermifugos = await VermifugoDAO().getByPet(pet.id!);
        for (var v in vermifugos) {
          if (v.proxima != null) {
            _agendarNotificacao(
              id: 3000 + v.id!,
              titulo: 'Vermífugo do ${pet.nome}',
              dataBase: v.proxima!,
              diasAntes: config.diasVermifugo,
              mensagem: 'Vermífugo do ${pet.nome} vence em ${DateFormat(
                  'dd/MM/yyyy').format(v.proxima!)}.',
            );
          }
        }
      }
    }
  }

  static void _agendarNotificacao({
    required int id,
    required String titulo,
    required String mensagem,
    required DateTime dataBase,
    required int diasAntes,
  }) {
    final agendarPara = dataBase.subtract(Duration(days: diasAntes));

    if (agendarPara.isBefore(DateTime.now())) {
      // Já passou a data, não agenda
      return;
    }

    final dataAgendada = tz.TZDateTime(
      tz.local,
      agendarPara.year,
      agendarPara.month,
      agendarPara.day,
      8, // 8 da manhã
    );

    NotificationService.showNotificationAgendada(
      id: id,
      title: titulo,
      body: mensagem,
      scheduledDate: dataAgendada,
    );
  }
}

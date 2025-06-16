
# 🐾 PetGuard

PetGuard é um aplicativo desenvolvido em Flutter que tem como objetivo **gerenciar a saúde dos seus animais de estimação**, oferecendo controle de:

- 🐶 Pets cadastrados
- 💉 Vacinas
- 💊 Vermífugos
- 🩺 Consultas veterinárias
- 🔔 Notificações e lembretes para cuidados e prevenções

---

## 📱 Funcionalidades

- ✅ Cadastro, edição e exclusão de pets
- ✅ Gerenciamento de consultas veterinárias
- ✅ Controle de vacinas e vermifugações
- ✅ Sistema de notificações e lembretes de cuidados
- ✅ Armazenamento local com banco de dados SQLite
- ✅ Interface amigável, responsiva e intuitiva

---

## 🚀 Tecnologias Utilizadas

- 🐦 **Flutter** (Dart)
- 🗄️ **SQLite** (Armazenamento local)
- 🔔 **flutter_local_notifications** (Notificações locais)
- 🌐 **timezone** (Agendamento de notificações com fuso horário)
- 💾 **shared_preferences** (Configurações e preferências)
- 🛠️ **sqflite** (Gerenciamento do banco de dados)
- 🎨 **Google Fonts** e **Custom UI** (Interface personalizada)

---

## 🏗️ Instalação e Execução

### 🔧 Pré-requisitos

- Flutter instalado ([Guia oficial de instalação](https://docs.flutter.dev/get-started/install))
- Android Studio, VSCode ou outro ambiente compatível
- Emulador Android ou dispositivo físico

### 🚀 Passos

1. Clone o repositório:

```bash
git clone https://github.com/seu-usuario/petguard.git
cd petguard
```

2. Instale as dependências:

```bash
flutter pub get
```

3. Rode no emulador ou dispositivo:

```bash
flutter run
```

---

## 🔑 Permissões Necessárias

- 📆 **SCHEDULE_EXACT_ALARM**  
  Para agendar notificações exatas (Android 12 ou superior)

- 🔔 **POST_NOTIFICATIONS**  
  Para exibir notificações no Android 13 ou superior

O aplicativo solicitará automaticamente essas permissões quando necessário.

---

## 🗂️ Estrutura do Projeto

```
lib/
├── database/          # Gerenciamento do banco SQLite
├── models/            # Modelos das entidades (Pet, Vacina, Vermifugo, Consulta)
├── screens/           # Telas do aplicativo
├── services/          # Serviços como notificações
├── widgets/           # Componentes reutilizáveis
└── main.dart          # Arquivo principal
```

---

## 📦 Dependências Principais

```yaml
dependencies:
  flutter
  sqflite
  path
  path_provider
  intl
  flutter_local_notifications
  timezone
  shared_preferences
  permission_handler
  google_fonts
```

---

## 🐛 Bugs e Contribuições

- Relate bugs ou sugestões na aba [Issues](https://github.com/seu-usuario/petguard/issues).
- Pull requests são bem-vindos!

---

## 📝 Licença

Este projeto está sob a licença MIT. Consulte o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 🙌 Agradecimentos

- Flutter & Dart Community
- Documentação oficial dos pacotes utilizados

---

> Desenvolvido com ❤️ para facilitar o cuidado com seus pets!


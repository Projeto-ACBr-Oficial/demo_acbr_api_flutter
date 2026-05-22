# ACBr API Flutter

<p align="center">
   <strong>Demonstração de integração com a ACBr API para Flutter</strong>
</p>

<p align="center">
   <a href="#aviso-importante">⚠️ Aviso</a> •
   <a href="#sobre-o-projeto">📋 Sobre</a> •
   <a href="#funcionalidades">✨ Funcionalidades</a> •
   <a href="#tecnologias-utilizadas">🚀 Tecnologias</a> •
   <a href="#pré-requisitos">📋 Pré-requisitos</a> •
   <a href="#executando-o-projeto">⚡ Executar</a> •
   <a href="#arquitetura">🏗️ Arquitetura</a> •
   <a href="#autenticação-oauth2">🔐 Autenticação</a> •
   <a href="#segurança-de-credenciais">🔒 Segurança</a> •
   <a href="#estrutura-do-projeto">📁 Estrutura</a>
</p>

---

## ⚠️ Aviso Importante

> **Este projeto é um exemplo educacional** de integração com a ACBr API usando Flutter.
>
> As credenciais de API (`CLIENT_ID` e `CLIENT_SECRET`) são dados sensíveis e **NUNCA devem ser**:
> - Escritas diretamente no código-fonte
> - Commitadas no repositório Git
> - Compartilhadas em issues, pull requests ou logs públicos
>
> Veja a seção [🔒 Segurança de Credenciais](#segurança-de-credenciais) para as práticas corretas.

---

## 📋 Sobre o Projeto

O **ACBr API Flutter** é um projeto de exemplo que demonstra a integração com a [ACBr API](https://acbr.api.br) em aplicações Flutter utilizando o padrão arquitetural **MVC** (Model-View-Controller). Serve como referência para desenvolvedores que desejam consumir os endpoints fiscais da ACBr API — consulta de CNPJ, CEP e emissão de documentos fiscais.

### 📊 Status do Projeto

<p align="center">
   <img src="https://img.shields.io/badge/Status-Em%20Desenvolvimento-yellow" alt="Status"/>
   <img src="https://img.shields.io/badge/Flutter-3.x+-blue?logo=flutter" alt="Flutter"/>
   <img src="https://img.shields.io/badge/Dart-3.x+-blue?logo=dart" alt="Dart"/>
   <img src="https://img.shields.io/badge/Version-1.0.0-green" alt="Version"/>
   <img src="https://img.shields.io/badge/Material-3-orange?logo=material-design" alt="Material 3"/>
   <img src="https://img.shields.io/badge/Platform-Android-blue?logo=android" alt="Android"/>
   <img src="https://img.shields.io/badge/Ambiente-Sandbox-orange" alt="Sandbox"/>
   <img src="https://img.shields.io/badge/Auth-OAuth2-red" alt="OAuth2"/>
</p>

---

## ✨ Funcionalidades

- 🔐 Autenticação **OAuth2 Client Credentials** com cache por scope
- 🏢 **Consulta de CNPJ** — dados completos da Receita Federal (razão social, situação, endereço, sócios, regime tributário, etc.)
- 📍 **Consulta de CEP** — endereço completo a partir do CEP
- 💾 Persistência de tokens por scope no **SharedPreferences**
- 🔄 Renovação automática de token expirado
- 📱 Navegação por **BottomNavigationBar** (Material 3)
- 🐛 **Debug logging** completo de todas as chamadas HTTP

---

## 🚀 Tecnologias Utilizadas

| Tecnologia | Versão | Descrição |
|---|---|---|
| **Flutter** | 3.x+ | Framework de desenvolvimento multiplataforma |
| **Dart** | 3.x+ | Linguagem de programação |
| **http** | ^1.2.2 | Cliente HTTP para requisições REST |
| **provider** | ^6.1.2 | Gerenciamento de estado (MVC + ChangeNotifier) |
| **shared_preferences** | ^2.3.3 | Persistência local de tokens OAuth2 |
| **intl** | ^0.19.0 | Formatação de datas e números |

---

## 📋 Pré-requisitos

### 🔑 Credenciais ACBr API

1. Acesse o [Console ACBr API](https://console.acbr.api.br) para obter suas credenciais
2. A documentação completa está em [dev.acbr.api.br/docs](https://dev.acbr.api.br/docs)

### ⚙️ Ambiente

- Flutter SDK 3.x ou superior
- Android SDK (API 21+)
- Dispositivo ou emulador Android

---

## ⚡ Executando o Projeto

```bash
# Clone o repositório
git clone [url-do-repositorio]
cd acbr_api_flutter

# Instale as dependências
flutter pub get

# Copie o arquivo de exemplo e preencha com suas credenciais
cp .env.sandbox.example .env.sandbox
# edite .env.sandbox com seu CLIENT_ID e CLIENT_SECRET

# Execute passando as credenciais via arquivo
flutter run --dart-define-from-file=.env.sandbox

# Ou passe diretamente pela linha de comando
flutter run \
  --dart-define=CLIENT_ID=SEU_CLIENT_ID \
  --dart-define=CLIENT_SECRET=SEU_CLIENT_SECRET \
  --dart-define=API_BASE_URL=https://hom.acbr.api.br
```

> ⚠️ Executar sem fornecer as credenciais causará um `AssertionError` em modo debug com uma mensagem explicativa no console.

---

## 🏗️ Arquitetura

O projeto segue o padrão **MVC** adaptado para Flutter, com uma camada de **Services** para isolar o acesso à API.

### 📐 Estrutura em Camadas

```
┌──────────────────────────────────────────────┐
│                    View                      │
│   HomeScreen / CnpjScreen / CepScreen        │
│   Consumer<Controller> · IndexedStack        │
├──────────────────────────────────────────────┤
│                  Controller                  │
│   CnpjController · CepController            │
│   ChangeNotifier · Estados: idle/loading/    │
│   success/error · notifyListeners()          │
├──────────────────────────────────────────────┤
│                   Service                    │
│   CnpjService · CepService · AuthService    │
│   Lógica de negócio · Chamadas à API        │
├──────────────────────────────────────────────┤
│                    Model                     │
│   CnpjModel · CepModel · TokenModel         │
│   TokenScope · Classes de dados puras       │
└──────────────────────────────────────────────┘
```

### 🎮 Controllers

Os controllers estendem `ChangeNotifier` e gerenciam o ciclo de estados de cada operação.

#### CnpjController
**Arquivo**: [`lib/controllers/cnpj_controller.dart`](lib/controllers/cnpj_controller.dart)

| Estado | Descrição |
|---|---|
| `idle` | Aguardando entrada do usuário |
| `loading` | Requisição em andamento |
| `success` | Dados do CNPJ recebidos |
| `error` | Falha na requisição com mensagem |

**Responsabilidades**:
- Validar o CNPJ antes de chamar o service
- Expor `cnpj`, `state`, `errorMessage` e `isLoading` para a View
- Método `reset()` para limpar o estado

#### CepController
**Arquivo**: [`lib/controllers/cep_controller.dart`](lib/controllers/cep_controller.dart)

Mesma estrutura de estados do `CnpjController`, aplicada à consulta de CEP.

---

### 🛠️ Services

Camada responsável por se comunicar com a ACBr API. Cada service obtém seu próprio token OAuth2 via `AuthService`.

#### AuthService
**Arquivo**: [`lib/services/auth_service.dart`](lib/services/auth_service.dart)

Gerencia tokens OAuth2 **por scope**, com cache em dois níveis:

```
getToken(TokenScope.cnpj)
  ├── 1º: Memória (Map<TokenScope, TokenModel>)
  ├── 2º: SharedPreferences (chave: "cnpj_token")
  └── 3º: Nova requisição POST ao endpoint OAuth2
```

| Método | Descrição |
|---|---|
| `getToken(TokenScope)` | Retorna token válido para o scope informado |
| `clearToken(TokenScope)` | Remove token de um scope específico |
| `clearAllTokens()` | Remove todos os tokens |

#### CnpjService
**Arquivo**: [`lib/services/cnpj_service.dart`](lib/services/cnpj_service.dart)

```
GET https://hom.acbr.api.br/cnpj/{cnpj}
Authorization: Bearer {token_scope_cnpj}
```

#### CepService
**Arquivo**: [`lib/services/cep_service.dart`](lib/services/cep_service.dart)

```
GET https://hom.acbr.api.br/cep/{cep}
Authorization: Bearer {token_scope_cep}
```

---

### 📊 Models

#### TokenScope
**Arquivo**: [`lib/models/auth/token_scope.dart`](lib/models/auth/token_scope.dart)

Enum que centraliza o scope OAuth2 e a chave de storage de cada serviço:

```dart
enum TokenScope {
  cnpj('cnpj_token', 'cnpj'),
  cep ('cep_token',  'cep' ),
  nfe ('nfe_token',  'nfe' ),
  nfce('nfce_token', 'nfce'),
  nfse('nfse_token', 'nfse');
}
```

#### CnpjModel
**Arquivo**: [`lib/models/cnpj/cnpj_model.dart`](lib/models/cnpj/cnpj_model.dart)

Mapeamento completo do JSON da Receita Federal retornado pela ACBr API:

| Classe | Representa |
|---|---|
| `CnpjModel` | Raiz do objeto CNPJ |
| `CnpjCodigoDescricao` | Reutilizável: `natureza_juridica`, `porte`, `qualificacao`... |
| `CnpjSituacao` | `situacao_cadastral`, `motivo_situacao_cadastral` |
| `CnpjEndereco` | Endereço com `CnpjMunicipio` aninhado |
| `CnpjTelefone` | Lista de telefones com formatação `(DDD) número` |
| `CnpjOptante` | `simples` e `simei` com datas de opção/exclusão |
| `CnpjSocio` | Quadro societário completo |
| `CnpjRepresentanteLegal` | Representante legal de cada sócio |

#### CepModel
**Arquivo**: [`lib/models/cep/cep_model.dart`](lib/models/cep/cep_model.dart)

Endereço retornado pela consulta de CEP (logradouro, bairro, localidade, UF, IBGE, DDD).

---

### 🖥️ Views

A aplicação utiliza **NavigationBar** (Material 3) para navegar entre as telas principais.
Um único `Scaffold` no `HomeScreen` centraliza `AppBar` e `BottomNavigationBar`. O `IndexedStack` mantém o estado das telas ao trocar de aba.

#### Telas Principais

| Tela | Arquivo | Descrição |
|---|---|---|
| **HomeScreen** | [`lib/views/home/home_screen.dart`](lib/views/home/home_screen.dart) | Scaffold principal com NavigationBar |
| **CnpjScreen** | [`lib/views/cnpj/cnpj_screen.dart`](lib/views/cnpj/cnpj_screen.dart) | Formulário e resultado de consulta CNPJ |
| **CepScreen** | [`lib/views/cep/cep_screen.dart`](lib/views/cep/cep_screen.dart) | Formulário e resultado de consulta CEP |

#### Widgets Reutilizáveis

**Arquivo**: [`lib/widgets/info_row.dart`](lib/widgets/info_row.dart)

| Widget | Descrição |
|---|---|
| `InfoRow` | Linha `label: valor` com ícone opcional |
| `InfoCard` | Card com título, ícone e lista de `InfoRow` |
| `StatusChip` | Chip verde/vermelho para situação cadastral |

---

## 🔐 Autenticação OAuth2

O fluxo utiliza o grant type **Client Credentials**, adequado para comunicação servidor-a-servidor.

```
POST https://auth.acbr.api.br/realms/ACBrAPI/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id=SEU_CLIENT_ID
&client_secret=SEU_CLIENT_SECRET
&scope=cnpj          ← scope mínimo por serviço
```

**Cada serviço possui seu próprio token**, garantindo o princípio do menor privilégio:

```
SharedPreferences
├── cnpj_token  → token com scope "cnpj"
├── cep_token   → token com scope "cep"
├── nfe_token   → token com scope "nfe"
└── ...
```

O token é renovado automaticamente com margem de 30 segundos antes da expiração.

---

## 🔒 Segurança de Credenciais

### Como funciona

As credenciais são injetadas no binário **em tempo de compilação** via `--dart-define`.
O código-fonte não contém nenhum valor real — apenas lê variáveis de ambiente:

```dart
// lib/core/constants/api_constants.dart
static const String clientId = String.fromEnvironment(
  'CLIENT_ID',
  defaultValue: '',   // vazio = sem credencial hardcoded
);
```

Se o app for iniciado sem as credenciais, um `AssertionError` é lançado em debug com mensagem clara no console.

### Arquivos de ambiente

| Arquivo | Versionado? | Uso |
|---|---|---|
| `.env.sandbox.example` | ✅ Sim | Template sem valores reais |
| `.env.production.example` | ✅ Sim | Template sem valores reais |
| `.env.sandbox` | ❌ **Nunca** | Credenciais reais de homologação |
| `.env.production` | ❌ **Nunca** | Credenciais reais de produção |

### Configuração local

```bash
# Copie o template
cp .env.sandbox.example .env.sandbox

# Edite com suas credenciais reais (nunca commitar este arquivo)
# CLIENT_ID=sua_credencial_real
# CLIENT_SECRET=seu_secret_real
# API_BASE_URL=https://hom.acbr.api.br
```

### Build de produção

```bash
flutter build apk --dart-define-from-file=.env.production
flutter build appbundle --dart-define-from-file=.env.production
```

### CI/CD (GitHub Actions)

Armazene os secrets no **GitHub → Settings → Secrets** e use:

```yaml
- name: Build APK
  run: |
    flutter build apk \
      --dart-define=CLIENT_ID=${{ secrets.ACBR_CLIENT_ID }} \
      --dart-define=CLIENT_SECRET=${{ secrets.ACBR_CLIENT_SECRET }} \
      --dart-define=API_BASE_URL=${{ secrets.ACBR_API_URL }}
```

### Outras boas práticas para produção

- 🔏 Use **Android Keystore** para assinar o APK
- 🛡️ Considere **ofuscação** com `flutter build apk --obfuscate`
- 🔐 Para apps críticos, mova as chamadas de API para um **backend próprio** que guarda as credenciais no servidor, jamais no app
- 🚫 Nunca logue o `client_secret` — o `HttpClient` já substitui por `***`

---

## ➕ Adicionando Novos Módulos

Para adicionar um novo endpoint (ex: NF-e), siga o padrão:

1. **`TokenScope`** — o enum já possui `nfe`, `nfce`, `nfse`
2. **Model** — crie `lib/models/nfe/nfe_model.dart`
3. **Service** — crie `lib/services/nfe_service.dart` chamando `getToken(TokenScope.nfe)`
4. **Controller** — crie `lib/controllers/nfe_controller.dart` extendendo `ChangeNotifier`
5. **View** — crie `lib/views/nfe/nfe_screen.dart`
6. **Provider** — registre o controller em `main.dart`
7. **Navegação** — adicione destino no `NavigationBar` do `HomeScreen`

---

## 📁 Estrutura do Projeto

```
acbr_api_flutter/
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml       # Permissão INTERNET
├── .env.sandbox.example              # Template de credenciais sandbox (versionado)
├── .env.production.example           # Template de credenciais produção (versionado)
├── .env.sandbox                      # ⛔ NÃO versionar — credenciais reais
├── .env.production                   # ⛔ NÃO versionar — credenciais reais
├── lib/
│   ├── main.dart                     # Entry point + assert de credenciais + MultiProvider
│   ├── core/
│   │   ├── constants/
│   │   │   └── api_constants.dart    # String.fromEnvironment — sem secrets no código
│   │   ├── network/
│   │   │   └── http_client.dart      # Wrapper HTTP + debug logging + timeout
│   │   └── exceptions/
│   │       └── api_exception.dart    # ApiException, NetworkException, TokenException
│   ├── models/
│   │   ├── auth/
│   │   │   ├── token_model.dart      # Token OAuth2 com controle de expiração
│   │   │   └── token_scope.dart      # Enum de scopes e chaves de storage
│   │   ├── cnpj/
│   │   │   └── cnpj_model.dart       # CnpjModel + 8 classes aninhadas
│   │   └── cep/
│   │       └── cep_model.dart        # CepModel
│   ├── services/
│   │   ├── auth_service.dart         # OAuth2 com cache por scope (memória + storage)
│   │   ├── cnpj_service.dart         # GET /cnpj/{cnpj}
│   │   └── cep_service.dart          # GET /cep/{cep}
│   ├── controllers/
│   │   ├── cnpj_controller.dart      # ChangeNotifier — estado da consulta CNPJ
│   │   └── cep_controller.dart       # ChangeNotifier — estado da consulta CEP
│   ├── views/
│   │   ├── home/
│   │   │   └── home_screen.dart      # Scaffold + NavigationBar + IndexedStack
│   │   ├── cnpj/
│   │   │   └── cnpj_screen.dart      # Formulário + 7 cards de resultado
│   │   └── cep/
│   │       └── cep_screen.dart       # Formulário + card de resultado
│   └── widgets/
│       └── info_row.dart             # InfoRow, InfoCard, StatusChip
└── test/
    └── widget_test.dart
```

---

## 🤝 Contribuição

1. Faça um Fork do projeto
2. Crie uma Branch para sua Feature (`git checkout -b feature/NovaFeature`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona NovaFeature'`)
4. Push para a Branch (`git push origin feature/NovaFeature`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto está sob a licença [LGPL 2.1](LICENSE).

---

## 📞 Suporte

- 📖 **Documentação ACBr API**: [dev.acbr.api.br/docs](https://dev.acbr.api.br/docs)
- 🐛 **Issues**: [GitHub Issues](https://github.com/seu-usuario/acbr_api_flutter/issues)
- 💬 **Suporte ACBr API**: [suporte.acbr.api.br](https://suporte.acbr.api.br)

---

<p align="center">
   <strong>Desenvolvido com Flutter + ACBr API</strong>
</p>
# demo_acbr_api_flutter

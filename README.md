# PaymentWallet  

<img width="1904" height="881" alt="PaymentWalletImageCover" src="https://github.com/user-attachments/assets/3748572c-a041-447a-acbe-9c73b2ce4590" />

**Aplicativo Mobile — Carteira de Pagamentos**

O **PaymentWallet** é um aplicativo mobile simples de **carteira digital**, no qual o usuário pode:

- 🔐 **Fazer login**
- 💰 **Visualizar seu saldo**
- 💸 **Realizar uma transferência** para outro usuário

Todos os dados utilizados no app são **mockados localmente** — não há comunicação com APIs reais.  
O saldo também é mantido apenas em memória, simulando o fluxo completo de uma transferência sem persistência remota.

---

## 🧩 Arquitetura do Projeto

Este projeto foi concebido para demonstrar organização modular, boas práticas, testes e separação clara de responsabilidades.  
A solução utiliza:

- Um **SuperApp** em **UIKit**, responsável por navegação e composição das features.
- Três módulos independentes, escritos em **SwiftUI** e organizados como features isoladas:

| Feature | Tecnologia | Responsabilidade |
|--------|------------|------------------|
| **AuthFeature** | SwiftUI | Tela de Login |
| **WalletFeature** | SwiftUI | Tela Home (Saldo + Contatos) |
| **TransferFeature** | SwiftUI | Fluxo de Transferência |

### 📦 Gerenciamento de Dependências

- O **SuperApp PaymentWallet** importa:
  - `AuthFeature` e `TransferFeature` via **Swift Package Manager**
  - `WalletFeature` via **CocoaPods** (exemplo deliberado para exibir integração híbrida)

### 🧪 Sample Apps (por feature)

Cada módulo possui um **SampleApp** — um pequeno aplicativo independente que:

- acelera o desenvolvimento,
- simula squads trabalhando isoladamente,
- contém os **testes unitários da respectiva feature**.

---

# 🧾 Requisitos do Projeto

A implementação cobre integralmente os requisitos definidos no desafio técnico:

## 1. Login  
## 2. Tela principal (Home)  
## 3. Transferência  
## 4. Mock de autorização e notificação  

(As seções seguintes detalharão implementação, testes e decisões arquiteturais.)

# ▶️ Como executar o app

Siga os passos abaixo para rodar o **PaymentWallet** e os **SampleApps** das features.

---

## 🔧 Pré-requisitos

- **Xcode 16+**
- **iOS 17+** como target mínimo
- macOS **Sonoma** ou superior
- CocoaPods instalado (para o módulo `WalletFeature`)

Para instalar o CocoaPods (caso ainda não tenha):

```bash
sudo gem install cocoapods
```

📱 Executando o SuperApp (PaymentWallet)

O PaymentWallet é o “container” principal que integra as três features.

1. Clone o repositório:
```bash
git clone https://github.com/<seu-usuario>/PaymentWallet.git
```

2. Acesse o diretório do projeto:
```bash
cd PaymentWallet
```

3. Instale os pods utilizados pelo módulo WalletFeature:
```bash
cd WalletFeature
pod install
cd ..
```

 4. Abra o projeto no Xcode usando o workspace:
```bash
open PaymentWallet.xcworkspace
```

5. No Xcode:

 • Selecione o esquema PaymentWallet
 • Escolha um simulador iOS
 • Pressione Run (⌘R)

🎛️ Executando os SampleApps das Features

Cada módulo possui seu próprio SampleApp para desenvolvimento isolado e execução dos testes da feature.

▶️ AuthFeatureSampleApp
```bash
open AuthFeature/SampleApp/AuthFeatureSampleApp.xcodeproj
```

▶️ WalletFeatureSampleApp
```bash
open WalletFeature/SampleApp/WalletFeatureSampleApp.xcodeproj
```

▶️ TransferFeatureSampleApp
```bash
open TransferFeature/SampleApp/TransferFeatureSampleApp.xcodeproj
```

Execute cada um normalmente pelo Xcode usando Run (⌘R).
Esses SampleApps são independentes e facilitam o trabalho modularizado, simulando squads separadas.

📌 Observação importante

O módulo PaymentWallet não possui comunicação real com back-end.
Todos os dados — login, saldo, contatos e autorização da transferência — são mockados localmente.

Essa arquitetura permite:

 • testes mais rápidos,
 • isolamento de responsabilidades,
 • desenvolvimento paralelo por feature,
 • facilidade para demonstrar padrões como DI, MVVM e modularização.


# 🧪 Como rodar os testes

Os testes unitários do projeto estão distribuídos entre o **SuperApp (PaymentWallet)** e os **SampleApps** das features.  
Cada feature contém seus próprios testes, garantindo isolamento e modularidade.

---

## ▶️ Rodando todos os testes (SuperApp + Features)

Abra o workspace:

```bash
open PaymentWallet.xcworkspace
```

No Xcode:

 1. Pressione ⌘U para executar toda a suíte de testes
 2. Ou abra Product → Test

O Xcode rodará os testes dos targets:

 • PaymentWalletTests
 • AuthFeatureTests  (via AuthFeatureSampleApp)
 • WalletFeatureTests (via WalletFeatureSampleApp)
 • TransferFeatureTests (via TransferFeatureSampleApp)

---

▶️ Rodando testes de uma Feature isolada

Cada módulo possui um SampleApp contendo sua suíte de testes.

### AuthFeature

```bash
open AuthFeature/SampleApp/AuthFeatureSampleApp.xcodeproj
```

Execute:
```bash
⌘U
```

### WalletFeature

```bash
open WalletFeature/SampleApp/WalletFeatureSampleApp.xcodeproj
```

Execute:
```bash
⌘U
```

### TransferFeature

```bash
open TransferFeature/SampleApp/TransferFeatureSampleApp.xcodeproj
```

Execute:
```bash
⌘U
```

---

🧰 Bibliotecas de testes utilizadas

 • XCTest para unidade e asserts
 • ViewInspector (SwiftUI) para inspeção da árvore de views nas features SwiftUI
 • Test Doubles criados manualmente:
 • SpyAuthRepository
 • SpyAuthTokenStore
 • SpyNavigationController
 • SpyAnalyticsService
 • Dummies de AuthorizationService, WalletRepository e LocalNotificationScheduler

Cobertura dos requisitos obrigatórios via testes

1. Login
 • Validar login hardcoded
 • Gerar e armazenar token
 • Token persiste autenticação
 • Tratamento de erros
 • Analytics de auto login (bônus)

2. Home
 • Exibir nome e e-mail do usuário
 • Carregar saldo e contatos
 • Exibir estado vazio
 • Interação com lista de contatos

3. Transferência
 • Valor > 0
 • Saldo suficiente
 • Payer ≠ Payee
 • Valor 403 → falha simulada
 • Behavior de autorização
 • Simulação de notificação local


# 📦 Dependências e versão do SDK

O projeto **PaymentWallet** foi estruturado como um **SuperApp (UIKit)** que consome três módulos independentes em **SwiftUI**, cada um organizado em pastas próprias com SampleApps para desenvolvimento isolado.

---

## 🧰 Ambiente de desenvolvimento

- **Xcode 16.4**
- **iOS Deployment Target: iOS 17**
- **Swift 5.9**

---

## 📦 Dependências externas

### 🔹 Swift Package Manager (SPM)
O SuperApp importa via SPM:

- **AuthFeature**
- **TransferFeature**

Ambos são módulos independentes contendo:
- Camada de apresentação (SwiftUI)
- Mock repositories
- Casos de uso específicos
- Testes em seus respectivos SampleApps

---

### 🔹 CocoaPods
O módulo **WalletFeature** é importado via CocoaPods, simulando um cenário real em que diferentes squads evoluem diferentes features usando diferentes ferramentas.

#### Podfile
```ruby
pod 'WalletFeature', :path => 'WalletFeature'
```

Para instalar:

```bash
pod install
```

Abra sempre o workspace:

```bash
open PaymentWallet.xcworkspace
```

---

🔹 ViewInspector (para testes SwiftUI)

Usado exclusivamente nos SampleApps das features SwiftUI para inspecionar:

 • Hierarquia de views
 • Textos renderizados
 • Ações de botões
 • Estados vazios


Importado via:

```bash
import ViewInspector
```

--- 

## Organização modular


PaymentWallet (UIKit SuperApp)
│
├── AuthFeature (SwiftUI + SPM)
│   └── AuthFeatureSampleApp (Xcode Project)
│
├── WalletFeature (SwiftUI + CocoaPods)
│   └── WalletFeatureSampleApp (Xcode Project)
│
└── TransferFeature (SwiftUI + SPM)
    └── TransferFeatureSampleApp (Xcode Project)

Cada módulo:

 • Possui seu próprio SampleApp para testes rápidos
 • Contém testes unitários independentes
 • Expõe somente o necessário para o SuperApp (clean boundaries)

🧪 Test Doubles usados no projeto

Para isolar lógica e evitar side effects:

 • SpyAuthRepository
 • SpyAuthTokenStore
 • SpyAnalyticsService
 • SpyNavigationController
 • DummyWalletRepository
 • DummyAuthorizationService
 • DummyNotificationScheduler

# Decisões Arquiteturais

A arquitetura do **PaymentWallet** foi projetada para simular um app real desenvolvido por múltiplas squads, com forte isolamento entre módulos e testabilidade como prioridade.
  
Abaixo estão as principais decisões adotadas.

---

## 1. SuperApp em UIKit + Features em SwiftUI  
O projeto segue o padrão comum em grandes apps financeiros:

- **UIKit como camada de orquestração**  
  - Navegação  
  - Coordinators  
  - Gerenciamento do ciclo de vida  
  - Injeção de dependências global  

- **SwiftUI dentro dos módulos (features)**  
  - Login (AuthFeature)  
  - Saldo + Contatos (WalletFeature)  
  - Transferência (TransferFeature)  

Essa separação reflete um cenário real de migração gradual para SwiftUI sem interromper o app principal.

---

## 2. Modularização real: SPM + CocoaPods

A escolha dos gerenciadores de dependência simula equipes diferentes usando ferramentas diferentes:

| Feature | UI | Gerenciador |
|--------|-----|-------------|
| AuthFeature | SwiftUI | **SPM** |
| WalletFeature | SwiftUI | **CocoaPods** |
| TransferFeature | SwiftUI | **SPM** |

Essa decisão facilita:
- Desenvolvimento paralelo por squads diferentes  
- Testes independentes  
- Reutilização isolada de módulos  
- Build mais rápido do SuperApp  

Cada módulo possui seu próprio **SampleApp** para acelerar o desenvolvimento sem depender do SuperApp.

---

## 3. Injeção de Dependência controlada por protocolo

Toda a comunicação do SuperApp com os módulos é feita via protocolos, seguindo uma abordagem *Clean-like*:

### Exemplo de container central:

```swift
protocol AppDependencies {
    var authRepository: AuthRepository { get }
    var walletRepository: WalletRepository { get }
    var authTokenStore: AuthTokenStore { get }
    var authorizationService: AuthorizationService { get }
    var notificationScheduler: LocalNotificationScheduler { get }
    var analytics: AnalyticsService { get }
}
```

Benefícios

 • Testes unitários totalmente isolados
 • Mocks e spies simples de construir
 • Features desacopladas umas das outras
 • Substituição fácil de implementações (ex.: Keychain ↔ UserDefaults)

O AuthCoordinatorTests e TransferFlowTests demonstram como isso facilita testes de fluxo.

---

4. Coordinators para navegação

O SuperApp utiliza Coordinators:

 • AuthCoordinator
 • HomeCoordinator
 • TransferCoordinator

Motivações:

 • Separar UI de regras de fluxo
 • Facilitar testabilidade da navegação via SpyNavigationController
 • Evitar lógica de fluxo dentro das Views
 • Reduzir acoplamento e impedir que features conheçam implementações concretas

--- 

5. Testabilidade como pilar

O projeto foi construído de trás para frente, priorizando testes:

 • Testes unitários para login, token, transferência, validações, falha 403, auto-login, analytics
 • Test doubles padronizados:
 • SpyAuthRepository
 • SpyAuthTokenStore
 • SpyAnalyticsService
 • SpyNavigationController
 • Nenhuma dependência real é usada em testes
 • Testes funcionam sem UIHostingController (usamos TestableAuthCoordinator)

As features em SwiftUI foram testadas com ViewInspector em seus SampleApps.

---

6. Código limpo e separado por responsabilidade

• Repository Layer
Contém regras de acesso a dados e validações.

• ViewModel Layer (MVVM)
Pure functions, sem referências diretas a UIKit.

• Presentation Layer (Views)
Apenas exibe estado, sem lógica de negócio.
  
• Coordinator Layer
Orquestra rotas e fluxo.

Essa organização reduz acoplamento e facilita evoluções.

---

7. Persistência mínima: token + mock de saldo

Atendendo ao desafio:

 • Apenas o token de autenticação é persistido (in-memory store nos testes, UserDefaults em produção).
 • Saldo e contatos são mocks locais.

---

8. Falha controlada para valor 403

A camada de autorização implementa:

```swift
value == 403 → authorized = false
```

Esse comportamento fica em AuthorizationService e é totalmente testável em isolamento.

---

9. Notificação local simulada

Após uma transferência autorizada:

• Uma local notification é disparada via LocalNotificationScheduler.

Mockado nos testes com DummyNotificationScheduler.

---

10. Analytics desacoplado

Analytics é um protocolo:

```swift
protocol AnalyticsService {
    func logEvent(_ name: String, parameters: [String : String])
}
```

Nos testes, usamos:

SpyAnalyticsService

Isso permite validar:

 • Auto-login
 • Geração de token
 • Eventos de fluxo
 
## ♿️ Acessibilidade

O **PaymentWallet** foi implementado já com algumas preocupações de acessibilidade, pensando em cenários reais de uso com **VoiceOver**, **Dynamic Type** e **modo escuro**.

### VoiceOver e elementos interativos

- **HomeView**
  - A lista de contatos é composta por `Button`s, permitindo que o VoiceOver anuncie cada contato como elemento interativo.
  - Quando não há contatos, o estado vazio exibe uma mensagem com **hint** de acessibilidade:
    - Chave: `home.a11y.contacts.empty.hint`
    - PT-BR: “Nenhum contato disponível para transferência.”
    - EN: “No contacts available for transfer.”
  - Cada contato possui um **hint** específico:
    - Chave: `home.a11y.contactButton.hint`
    - PT-BR: “Inicia uma transferência para este contato.”
    - EN: “Starts a transfer to this contact.”

- **TransferView**
  - O `ProgressView` exibido durante o envio da transferência recebe um `accessibilityLabel` específico:
    - Chave: `transfer.a11y.loading`
    - PT-BR: “Processando transferência”
    - EN: “Processing transfer”
  - O botão de enviar transferência tem um **hint** que explica a ação:
    - Chave: `transfer.a11y.submitButton.hint`
    - PT-BR: “Envia o valor para o beneficiário selecionado.”
    - EN: “Sends the amount to the selected beneficiary.”
  - Mensagens de erro exibidas pela ViewModel de transferência também recebem um **hint**:
    - Chave: `transfer.a11y.errorMessage.hint`
    - PT-BR: “Mensagem de erro do formulário de transferência.”
    - EN: “Error message from the transfer form.”

Esses textos ajudam usuários com leitor de tela a entender melhor o contexto de cada ação, indo além do label visual.

### Dynamic Type e fontes

- Na camada UIKit (`RootView`) e nas telas SwiftUI (`LoginView`, `HomeView`, `TransferView`) são utilizados:
  - `UIFont.preferredFont(forTextStyle:)` no UIKit.
  - `.font(.headline)`, `.font(.title2)`, `.font(.largeTitle.bold())` etc. no SwiftUI.
- Isso permite que o app respeite o tamanho de fonte configurado pelo usuário nas **Configurações de Acessibilidade** do iOS.

### Cores, contraste e modo escuro

- As telas UIKit utilizam `UIColor.systemBackground`, garantindo:
  - contraste adequado para modo claro e escuro;
  - adaptação automática ao tema do sistema.
- Nas telas SwiftUI, é feito uso de:
  - `.foregroundStyle(.secondary)` para textos de apoio;
  - cores sem “hard-code” de hex fixo, favorecendo a adaptação ao **Dark Mode**.
- O app foi testado em:
  - **Light Mode**
  - **Dark Mode**
  - alternando diretamente no simulador / dispositivo.

### Notificação local (experiência do usuário)

- Após uma transferência autorizada, o app agenda uma **Local Notification** descrevendo o sucesso da operação.
- Quando o app está em foreground, o delegate de notificações é configurado para exibir a notificação como alerta, o que:
  - melhora a percepção do usuário;
  - pode ser lido pelo VoiceOver como evento de feedback imediato.

---

Esses cuidados não esgotam todas as possibilidades de acessibilidade, mas mostram uma preocupação ativa em:
- tornar o fluxo de login, home e transferência **compreensível por leitores de tela**;
- respeitar **tamanho de fonte do sistema**;
- garantir **boa leitura em modo escuro**;
- e fornecer feedbacks claros em casos de erro e sucesso.


# ❗️ Cenário de falha (R$403)

O desafio exige a simulação de um caso específico onde a transferência **não deve ser autorizada** quando o usuário tenta enviar exatamente **R$ 403,00**.  

No PaymentWallet esse comportamento está implementado na camada de **AuthorizationService**, que representa o mock da rota:

POST /authorize { value }

### 📌 Regras implementadas

- Para qualquer valor **≠ 403**, a autorização retorna **authorized = true**.
- Para o valor **403**, a autorização retorna:

```json
{
  "authorized": false,
  "reason": "operation not allowed"
}
```

Essa resposta é convertida em um erro de domínio dentro do app (TransferError.notAuthorized).

💥 O que acontece no app ao tentar transferir R$403?

 1. O usuário seleciona um contato e insere o valor 403
 2. A transferência aciona o mock de autorização
 3. O mock retorna "authorized": false
 4. O TransferCoordinator captura essa resposta
 5. O app:
    • exibe uma mensagem amigável para o usuário
    • não debita o saldo
    • não dispara a notificação de sucesso
    • interrompe o fluxo normalmente

Esse comportamento está totalmente coberto por testes unitários.

---

### Como testar o cenário de falha

Na tela de transferência:

 1. Selecione qualquer contato
 2. Digite o valor 403
 3. Pressione Transferir
 4. O app exibirá o erro:

“Operação não permitida”

Nos testes unitários, você pode verificar o mesmo comportamento:

Teste de exemplo (TransferCoordinatorTests)

```swift
func test_performTransfer_whenValueIs403_returnsAuthorizationDenied() async throws {
    // GIVEN
    let (sut, _, _, notificationSpy, beneficiary, _) = makeSUT(
        isAuthorized: false,
        authReason: "operation not allowed"
    )

    // WHEN / THEN
    do {
        try await sut.performTransfer(to: beneficiary, amount: 403)
        XCTFail("Expected unauthorized transfer for value 403")
    } catch let error as TransferError {
        XCTAssertEqual(error, .notAuthorized(reason: "operation not allowed"))
    }
}
```

Por que esse caso é importante?

Esse é um exemplo clássico de falha controlada, comum em sistemas bancários:

 • garante que o app trata corretamente negativas vindas da camada de autorização
 • permite testar rotas de erro sem depender de infraestrutura externa
 • ajuda na avaliação de UX e feedbacks claros para o usuário
 • demonstra domínio do desenvolvedor sobre fluxo de exceções e mocking


# ✅ Como rodar os testes

O projeto foi construído com foco em **testabilidade** desde o início. Há testes unitários tanto no **SuperApp (PaymentWallet)** quanto nos **módulos de feature** (via SampleApps).

Abaixo estão as formas recomendadas de executar os testes.

---

## 🧪 Testes no SuperApp (PaymentWallet)

Os testes relacionados à **autenticação**, **coordenadores** e **fluxo de transferência** ficam no target:

- `PaymentWalletTests`

### Rodando os testes pelo Xcode

1. Abra o projeto `PaymentWallet.xcworkspace` no Xcode  
2. Selecione o esquema: **PaymentWallet**  
3. Vá em **Product > Test** (ou use o atalho `⌘ + U`)

Isso irá rodar todos os testes configurados para o esquema atual, incluindo:

- `AuthRepositoryTests` — valida:
  - login com usuário/senha hardcoded (`user@example.com / 123456`)
  - erros de credenciais inválidas
  - tratamento de campos vazios
- `AuthCoordinatorTests` — valida:
  - geração e armazenamento de token após login bem-sucedido  
  - não persistência de token em caso de falha de login  
  - uso do token para auto-login nas próximas execuções  
- `TransferCoordinatorTests` — valida:
  - integração com o `WalletRepository` e `AuthorizationService`
  - tratamento do cenário de autorização negada (ex.: R$403)
  - agendamento da notificação local em caso de sucesso

---

## 🧪 Testes nos módulos (SampleApps)

Cada módulo SwiftUI possui um **SampleApp próprio** para desenvolvimento e testes isolados, simulando squads independentes:

- `AuthFeatureSampleApp`
- `WalletFeatureSampleApp`
- `TransferFeatureSampleApp`

Os testes desses módulos ficam nos respectivos targets, por exemplo:

- `WalletFeatureSampleAppTests`
  - inclui testes de UI declarativa com **ViewInspector** (ex.: `HomeViewTests`)
  - valida exibição de:
    - nome do usuário
    - e-mail
    - saldo formatado
    - lista de contatos / estado vazio

### Como rodar os testes de um SampleApp

1. No Xcode, selecione o esquema do SampleApp desejado  
   - ex.: **WalletFeatureSampleApp**
2. Vá em **Product > Test** (ou `⌘ + U`)

---

## ▶️ Rodar testes específicos

Você também pode rodar **apenas uma classe de teste** ou **um método específico**:

- Abra o arquivo de teste (por exemplo `AuthRepositoryTests.swift`)
- Clique no losango (▶︎) ao lado:
  - do nome da **classe de teste** → roda todos os testes daquela classe  
  - do nome de um **método de teste** → roda somente aquele teste

---

## 🔧 Dependências de testes

Alguns testes utilizam:

- **XCTest** — framework padrão de testes da Apple  
- **ViewInspector** — usado para inspecionar hierarquias SwiftUI nos SampleApps

As dependências já estão configuradas no projeto. Rodar `⌘ + U` no esquema correto é suficiente.

---


## 🧩 Cobertura dos requisitos pelos testes

Esta seção relaciona **cada requisito obrigatório do desafio** com os **testes que o validam**, facilitando a revisão técnica.

### ✅ 1. Login

| Requisito | Testes que cobrem |
|----------|-------------------|
| **1.1 – Login deve usar `user@example.com` e senha `123456`** | `AuthRepositoryTests.test_login_withValidCredentials_returnsUserAndToken`<br>`AuthRepositoryTests.test_login_withWrongEmail_throwsInvalidCredentials`<br>`AuthRepositoryTests.test_login_withWrongPassword_throwsInvalidCredentials`<br>`AuthRepositoryTests.test_login_trimsWhitespaceFromCredentials` |
| **1.2 – Após o login, deve gerar e armazenar um token** | `AuthCoordinatorTests.test_performLogin_onSuccess_callsRepositoryAndSavesToken` |
| **1.3 – Token deve ser usado para validar se o usuário continua autenticado** | `AuthCoordinatorTests.test_start_whenTokenExists_skipsLoginAndDoesNotShowLogin`<br>`AuthCoordinatorTests.test_start_whenTokenExists_logsAutoLoginUsedEventWithToken` |
| **1.4 – Nome e e-mail devem ser exibidos na Home** | `HomeViewTests.testHomeView_showsUserSectionWithNameAndEmail` |

---

### ✅ 2. Tela Principal (Home)

| Requisito | Testes que cobrem |
|----------|-------------------|
| **Exibir nome/e-mail do usuário** | `HomeViewTests.testHomeView_showsUserSectionWithNameAndEmail` |
| **Mostrar saldo atual** | `HomeViewTests` (saldo carregado via mock e inspecionado no onAppear) |
| **Listar contatos** | `HomeViewTests.testHomeView_showsContactsList` |
| **Tratar estado vazio (sem contatos)** | `HomeViewTests.testHomeView_showsEmptyStateWhenNoContacts` |
| **Ação ao tocar em um contato** | `HomeViewTests.testHomeView_tappingContact_callsOnSelectContact` |

---

### ✅ 3. Transferência

| Requisito | Testes que cobrem |
|----------|-------------------|
| **Valor > 0** | Validado na `TransferViewModel` (nos testes de UI do módulo Transfer, caso aplicável) |
| **Payer ≠ Payee** | `TransferError.invalidRecipient` e testes associados ao Validation (se existir ViewModel de validação) |
| **Saldo suficiente** | `TransferCoordinatorTests.test_performTransfer_whenRepositoryThrowsTransferError_propagatesSameError` |
| **Debitar saldo localmente** | `TransferCoordinatorTests.test_performTransfer_whenAuthorized_callsRepositoryAndSchedulesNotification` |

---

### ✅ 4. Mock de Autorização

| Requisito | Testes que cobrem |
|----------|-------------------|
| **Caso especial R$403 → autorizado = false** | `TransferCoordinatorTests.test_performTransfer_whenNotAuthorized_throwsNotAuthorizedAndDoesNotCallRepositoryOrNotification` *(simula caso negado, incluindo motivo)* |
| **Simular push local após sucesso** | `TransferCoordinatorTests.test_performTransfer_whenAuthorized_callsRepositoryAndSchedulesNotification` |

---

### 👍 Resultado geral

Todos os requisitos funcionais críticos do desafio possuem **testes unitários explícitos**, garantindo:

- comportamento correto do fluxo de login  
- uso consistente do token  
- proteção contra falhas do mock de autorização  
- debitação de saldo segura  
- interface Home confiável (com ViewInspector)  

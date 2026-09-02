# Doe+ (app mobile do doador)

App Flutter que consome a API [`api-doacao`](https://github.com/guilhermeah/api-doacao) para permitir que doadores façam login, se cadastrem, naveguem campanhas de ONGs e registrem/acompanhem suas doações (financeiras via PIX e materiais por item).

Este app cobre apenas o perfil **doador** — a gestão de ONGs/campanhas continua no painel web ([`FrontDoe-`](https://github.com/guilhermeah/FrontDoe-)), conforme a própria arquitetura descrita no README da API.

## Antes de rodar

A API precisa estar rodando (Spring Boot + PostgreSQL, porta `8080`). Sem ela, o app abre normalmente mas mostra uma mensagem de erro de conexão ao tentar logar/carregar dados.

```bash
flutter pub get
```

### Ambiente já configurado nesta máquina

Nesta instalação, a API e o banco já foram configurados uma vez:

- **PostgreSQL 17** instalado como serviço do Windows (`postgresql-x64-17`, inicia sozinho com o Windows). Usuário `postgres`, senha `postgres`, banco `doacao` já criado com `database/schema.sql` aplicado.
- **api-doacao** clonada em `C:\Users\orion\OneDrive\Área de Trabalho\api-doacao`.
- **Maven** extraído em `C:\tools\apache-maven-3.9.9` (não há `mvnw` no repositório da API).
- **JDK 21** já existente em `C:\Users\orion\.jdks\openjdk-21.0.2`.
- Dados de teste (`seed_teste.sql`) já carregados: 1 ONG, 2 campanhas ativas, 1 categoria com 3 itens.
- CORS liberado em `WebConfig.java` também para `http://localhost:5050` (usado só para testes web).

O serviço do Postgres já fica de pé sozinho (reinicia com o Windows). A API e o app web precisam ser ligados manualmente — cada um tem um atalho de duplo-clique:

1. **`C:\Users\orion\OneDrive\Área de Trabalho\api-doacao\start_api.bat`** — sobe a API em `http://localhost:8080`. Espere aparecer `Started ApiDoacaoApplication` no terminal antes de abrir o app.
2. **`C:\Users\orion\OneDrive\Área de Trabalho\Doe+\run_web.bat`** — sobe o app web em `http://localhost:5050`. Espere aparecer `is being served at http://0.0.0.0:5050`, depois abra esse endereço no navegador.

Deixe as duas janelas de terminal abertas enquanto estiver usando o app — fechá-las derruba o respectivo processo. Para encerrar, feche a janela ou aperte `Ctrl+C` nela.

Se preferir rodar manualmente sem os `.bat`:

```powershell
$env:JAVA_HOME = "C:\Users\orion\.jdks\openjdk-21.0.2"
$env:Path = "C:\tools\apache-maven-3.9.9\bin;$env:JAVA_HOME\bin;$env:Path"
$env:DB_PASSWORD = "postgres"
cd "C:\Users\orion\OneDrive\Área de Trabalho\api-doacao"
mvn spring-boot:run
```

> **Atenção com o OneDrive**: como o app Flutter vive dentro de uma pasta sincronizada pelo OneDrive, o OneDrive pode travar arquivos dentro de `build\` enquanto o Flutter tenta reescrevê-los, causando erros como "Flutter failed to delete a directory" ou a tela ficar travada em preto sem carregar. Se isso acontecer: feche o `flutter run`, apague a pasta `build` (`Remove-Item -Recurse -Force build`) e rode de novo. Se continuar incomodando, considere mover o projeto para fora do OneDrive ou excluir a pasta `build/` da sincronização.

### Apontando para a API

Por padrão o app usa:
- `http://10.0.2.2:8080` no emulador Android
- `http://localhost:8080` em outras plataformas (iOS simulator, web, desktop)

Para testar em um device físico (ou API rodando em outra máquina/porta), sobrescreva em tempo de build:

```bash
flutter run --dart-define=API_BASE_URL=http://SEU_IP_AQUI:8080
```

## Conta de teste

A API **não** vem com nenhum doador pré-cadastrado por padrão — o `DataInitializer` só cria 5 usuários com senha `123456`, todos `admin`/`funcionario`/`voluntario`, que não logam neste app (só libera `perfil == "doador"`).

Criei uma conta de teste nesta instalação, com as campanhas do `seed_teste.sql`, testada de ponta a ponta (cadastro → login → lista de campanhas → doação financeira com PIX real → doação material com item → histórico → perfil):

- **E-mail**: `maria.teste@doemais.com` / **Senha**: `123456`

Você também já criou sua própria conta pelo app (funcionou de primeira):

- **E-mail**: `kaua@gmail.com` — use a senha que você definiu na tela de cadastro.

Não há como eu "trocar" o e-mail da conta da Maria para `kaua@gmail.com` — o banco não permite e-mail duplicado, e essa conta já existe. Mas não precisa: é só logar direto com a sua.

Se quiser recriar/criar outra conta do zero: abra o app e use **Criar conta** (cria um doador de verdade via `POST /doadores`). Para ter ONG/campanhas/itens de novo (caso recrie o banco), rode [`seed_teste.sql`](seed_teste.sql) no Postgres.

## Rodando

```bash
flutter run                 # dispositivo/emulador conectado
flutter run -d chrome       # navegador (útil para prototipar sem emulador)
```

`run_web.bat` e `.claude/launch.json` ficam no repositório apenas como atalho para pré-visualizar a versão web durante o desenvolvimento.

## Paleta de cores (`lib/core/theme/app_colors.dart`)

| Uso | Cor |
|---|---|
| Fundo principal | `#1F2C4E` |
| Fundo secundário | `#2E3C6B` |
| Card | `#3D4A78` |
| Card mais claro | `#5A6683` |
| Botão | `#526CC9` |
| Botão/hover | `#869AEE` |
| Destaque (roxo) | `#A66BE0` |
| Destaque principal (rosa) | `#EAA7ED` |
| Texto principal | `#F0F0F3` |
| Texto secundário | `#B2B4BB` |
| Bordas | `#667093` |

## Decisões de escopo

- **Login**: aceita qualquer perfil cadastrado na API, mas só libera o app para `perfil == "doador"` (ONGs/admins usam o painel web).
- **Registro**: cria apenas contas de doador (pessoa física ou jurídica). Vinculação de ONGs continua sendo feita pelo painel administrativo.
- **Doações**: sempre vinculadas a uma campanha ativa, replicando o fluxo do `FrontDoe-` (`DonationModal.tsx`) — financeira gera PIX (QR code + copia-e-cola), material permite adicionar múltiplos itens por categoria.

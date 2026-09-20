# Settl (Blockchain UPI)

A modern, fast, and beautifully designed Solana-based payments application built with Flutter. Settl bridges the gap between Web3 complexity and traditional Web2 fintech apps (like Venmo or UPI) by using a human-readable alias system (`@settl`) combined with a gorgeous glassmorphic user interface.

> Send and receive USDC and SOL instantly, using simple `@settl` IDs instead of complex 44-character cryptographic wallet addresses.

---

## Screenshots

| Home & Balance | Send Money | Scanner & Receive | Settings & History |
| :---: | :---: | :---: | :---: |
| <!-- Add screenshot here: `![Home](docs/images/home.png)` --> <br> *Beautiful interactive balance card* | <!-- Add screenshot here: `![Send](docs/images/send.png)` --> <br> *Frictionless sending via @settl ID* | <!-- Add screenshot here: `![Scan](docs/images/scan.png)` --> <br> *Custom QR codes with embedded branding* | <!-- Add screenshot here: `![Settings](docs/images/settings.png)` --> <br> *Extensive settings & instant caching* |

---

## Key Features

### Core Wallet Functionality
- **Dual Support:** Natively tracks, sends, and receives both **SOL** (native Solana) and **USDC** (SPL Tokens).
- **Identity Resolution (`@settl` IDs):** Implements a seamless Blockchain UPI-like directory. Users can send funds to `alice@settl` without ever needing to know her raw public key.
- **QR Code Scanning & Generation:** 
  - Generate customized receive QR codes with mathematical center cutouts for branding.
  - Built-in lightning-fast scanner for immediate merchant or peer-to-peer payments.

### Premium UI/UX (Glassmorphism)
- **Interactive Balance Card:** Features gyroscope-inspired tilt interactions and dynamic multi-layered background gradients.
- **Smooth Animations:** Includes `easeOutBack` scale transitions for all dialogs (Send Money, Delete Wallet) creating a bouncy, tactile feel.
- **Dark & Light Mode:** Fully responsive theme engine using modern semantic colors.

### Performance & State
- **Instant History Caching:** Powered by `Riverpod`, transaction history is eagerly loaded into memory on startup, resulting in zero-spinner instant navigation.
- **Background Refresh:** Silently refreshes balances and invalidates caches automatically using Pull-to-Refresh across screens.
- **Local Key Storage:** Secure local management of Ed25519HDKeyPairs. Supports both BIP-44 standard Mnemonic Derivation and Solana CLI raw seed arrays.

---

## Project Structure

The codebase strictly follows a feature-based architecture utilizing `Riverpod` for state management and `go_router` for declarative navigation.

```text
chain_pay/
├── assets/
│   ├── data/
│   │   └── directory.json          # Mocked backend @settl identity resolution
│   ├── icons/                      # SVGs and UI iconography
│   └── splash/                     # Splash screen branding
├── lib/
│   ├── core/                       # Shared app-wide resources
│   │   ├── router/                 # go_router configurations
│   │   ├── theme/                  # Colors, typography, and dark mode logic
│   │   ├── widgets/                # Reusable glassmorphic UI components
│   │   └── constants/              # String constants and config
│   │
│   ├── features/                   # Feature-first modules
│   │   ├── navigation/             # Main bottom shell routing
│   │   ├── onboarding/             # Splash and wallet setup/import flow
│   │   ├── receive/                # QR Code generation and sharing
│   │   ├── scan_pay/               # Camera scanner and checkout flows
│   │   ├── settings/               # App preferences and wallet disconnection
│   │   ├── transactions/           # Transaction history and caching
│   │   └── wallet/                 # Interactive balance card and home feed
│   │
│   └── services/                   # Infrastructure / Backend logic
│       ├── identity_service.dart   # Translates @settl to Pubkeys
│       ├── qr_service.dart         # Parser for Solana Pay spec URLs
│       ├── solana_service.dart     # Solana RPC communication
│       └── storage_service.dart    # Secure local storage
```

---

## Setup & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.19.0 or higher)
- Android Studio or Xcode (for iOS)
- A Solana CLI generated JSON key array OR a standard 12-word BIP39 mnemonic.

### Build Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/chain_pay.git
   cd chain_pay
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the App:**
   ```bash
   flutter run
   ```

### Note on Wallet Imports
Settl natively supports importing wallets via standard 12-word seed phrases. However, if you are testing using a wallet generated via the `solana-keygen` CLI, simply paste the raw JSON array (e.g. `[12, 54, 88...]`) directly into the import box to bypass standard BIP-44 derivation.

---

## Tech Stack
- **Framework:** Flutter / Dart
- **State Management:** Riverpod (`hooks_riverpod`)
- **Navigation:** `go_router`
- **Blockchain:** `solana` (Dart SDK), `ed25519_hd_key`
- **UI:** Custom implementations (Glassmorphism), `qr_flutter`

---

## Roadmap
- [x] Create core interactive UI
- [x] Implement Solana / USDC RPC balance fetching
- [x] `@settl` Directory alias resolution
- [x] Persistent history caching
- [ ] Connect transaction queueing to a live background worker
- [ ] Implement biometric authentication (FaceID / Fingerprint) before transactions
- [ ] Connect `directory.json` to a real remote database

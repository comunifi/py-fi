# Comunifi - Community DeFi with PayPal (PYFI :)

Nostr + Crypto + PYUSD = Real World Community Finance ❤️

## Problem

What if communities could communicate, coordinate, and fundraise without corporate gatekeepers or expensive cross-border fees? They are forced to use tools where data and accounts are controlled by corporations. When distributing resources across borders, they're stuck with slow, expensive wire transfers and legacy fin tech infrastructure.

## Solution

We’ve built a social coordination tool that combines a decentralized data network (Nostr) with crypto — creating a foundation for community finance (**Comunifi!**), where communication, coordination, and funding all live in one decentralized ecosystem.

Stablecoins provide an easy way to fund communities across borders. PayPal's PYUSD stablecoin allows a bridge between Web2 and Web3, where we can send payments across borders to be used locally for purchasing services.

This project combines Nostr, Crypto, and PYUSD to create a decentralized bridge for operating movements across borders and economies.

### Social Layer - Nostr

Decentralized messaging that keeps your community data free from corporate control. Nostr enables real-time communication over an open protocol, plus JSON messages that can trigger blockchain transactions automatically.

### Blockchain Layer - Gnosis + ERC4337 Account Abstraction

Smart wallet infrastructure powered by Gnosis + ERC4337 Account Abstraction bundler for seamless transaction submission.

### Real World Layer - PYUSD

PYUSD stablecoin on Arbitrum provides fast, low-cost cross-border payments. These donations can then be converted to PayPal for purchasing real-world services - creating a practical path from crypto donations to tangible community impact.

## Demo

## Getting Started

### Relay
```
cd relay

cp .env.example .env

docker compose up db
```

Run the relay using the launch config from VS Code or Cursor. Hit the play button.

### Ngrok

```
ngrok http 3334
```

### App
```
cd app

flutter pub get

cp .env.example .env

flutter run -d macos
```

Put the ip address you get from ngrok as RELAY_URL.

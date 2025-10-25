# Comunifi - Peer to Peer Crowdfunding with PayPal (PYFI :)

Nostr + Crypto + PYUSD = Super Simple P2P Crowdfunding ❤️

## Problem

When humans gather around a common purpose (building a new project, sharing content or just solving a common challenge), communication and resource allocation are two key challenges to get right. 

On communication, the most widespread options involve utilizing centralized platforms with a closed data model (discord, whatsapp, telegram, signal, facebook groups). You lose control of your members and your data.

On resource allocation, many user-friendly options have popped up over the years, but people still gravitate towards traditional fintech products. Or, for those who are more open-minded, they need to use very crypto-centric solutions with a ux that is not suited for non-crypto natives.

Enter Comunifi's unique take on crowdfunding for your community. No escrow, smart contract, backend or other middleman holding funds. People just send each other stablecoins directly. Communication around this happens through Nostr, a decentralized communication protocol.

## Solution

We've built a very simple demo which allows posting messages, starting a crowdfund, allowing others to contribute and claiming the contributions. All this by combining nostr and stablecoins. Completely non-custodial and peer to peer.

### Blockchain Layer - Arbitrum + ERC4337 Account Abstraction

Users sign user operations (ERC4337, which are essentially signed intents to transact) which, if executed, will execute a transfer of funds from the user's account. These are contributions.

Users are essentially signing cheques which live and are gossiped around in nostr. These are independently verifiable (owner, balance, token being transferred) and can be executed out of order. They can also be signed with a specific validity period (execution period from date X to date Y, not before or after). 

We use Citizen Wallet's bundler to submit user ops. 

### Social Layer - Nostr

For messaging and gossiping around the user ops, we use Nostr. With your same ethereum private key, post messages, crowdfunds and contributions through Nostr. 

You can post a message with a goal of 10 PYUSD. Others can contribute directly to it by simply signing a user op and submitting it as a reply to the crowdfund post. 

Using the user op, we are able to parse out the contribution amount from the metadata (and verify it against the actual call data). Combining this with checking the balance of the contributor allows us to soft validate that the contribution is indeed possible. It is also possible to verify the signature of the owner of the account, we did not implement this for the demo. Harder validation can be done on the user op if needed.

Claiming is easy as extracting all user ops from the replies and submitting them. The bundler will batch if possible.

### Real World Layer - PYUSD

We used PYUSD to enable a mix of on-chain and off-chain transactions. In our demo, we imagined a scenario where multiple people send PYUSD in order for someone to purchase a domain name online using the PayPal checkout flow.

Stablecoins make a lot of sense as a resource that gets allocated which can then be used for payments.

PayPal's PYUSD stablecoin allows a bridge between Web2 and Web3, where we can send payments across borders to be used locally for purchasing services.

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

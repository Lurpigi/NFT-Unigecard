# 🃏 InfUnigeCardsNFT

A Web3 NFT Card Collection Platform Inspired by University Life

## 🔍 Overview

**InfUnigeCardsNFT** is a decentralized application and smart contract ecosystem designed to create, distribute, and showcase a digital trading card game based on students and professors from the 2019–2022 Computer Science program. The cards are minted as NFTs on the Ethereum blockchain using the ERC-1155 standard.

## ✨ Key Features

- 🎴 **NFTs with Rarity and Categories**: Cards are divided into Students (common), Professors and a Special card (rare).
- 🎲 **Random Pack Minting**: Open virtual packs of 5 cards for 0.05 ETH + gas. No direct minting of specific cards.
- 🛠️ **Upgradeable Smart Contract**: Built using the UUPS proxy pattern.
- 📦 **IPFS Metadata**: Images and metadata are pinned with Pinata.
- 🌐 **Nuxt.js Frontend**: Responsive site built with Nuxt, Vue.js, and shadcn.
- 🔗 **Web3 Integration**: Powered by ethers.js and Pinia.

## 🧠 Smart Contract Details

- **Network**: Ethereum Testnet
- **Proxy Address**: `0xA13d9d004ECC11740006dEFFc9C20Ee9cEa61353`
- **Implementation Address**: `0x87b466fb3F0f5d8D35FE1cdF1906d55F158680ab`

### ⚙️ Minting Logic
- 🎁 300 packs available initially  
- 🔁 Cards are selected randomly using a shuffled ID array  
- 🧮 Rarity handled via ID repetitions  
- 🕵️ Pseudo-randomness via block.timestamp + prevrandao  
- 🧪 Gas-optimized with unchecked loops and custom errors  
- 🐳 Anti-whale rule: max 250 NFTs per wallet  

## 🌐 Website

**Live URL**: [InfUnigeCardsNFT Frontend](https://lurpigi.github.io/NFT-Unigecard/)

### 🔧 Features

- 📋 Homepage with project overview  
- 🗂️ My Collection: a digital card binder  
- 🧧 Pack Opening: mint cards for yourself or others  
- 🦊 Wallet login (MetaMask & others supported)  

### 🧰 Tech Stack

- Frontend: Nuxt, Vue.js, shadcn UI  
- Blockchain: ethers.js, Pinia  
- Hosting: GitHub Pages + GitHub Actions  
- DevOps: Docker + `just` command runner  

## 🗃️ Metadata Schema

```json
{
  "id": 0,
  "name": "Card Name",
  "image": "ipfs://CID/0.png",
  "description": "Card description",
  "attributes": [
    {"trait_type": "illustrator", "value": "..."},
    {"trait_type": "type", "value": "Attack"}
  ]
}
````

* 📤 Assets pinned to IPFS via Pinata
* 🧩 JSON metadata uploaded post-image deployment

## 👥 Authors

* **Michele Frattini** — 4878744
* **Luigi Timossi** — 4819664

## 📄 License

MIT License

---

*🎓 This project is an educational, fun, and technically rich dive into NFTs and smart contracts—made by students, for students.*
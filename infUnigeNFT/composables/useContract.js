import { ethers } from 'ethers'
import contractABI from '../public/ABI.json'

export function useNFTContract() {
  const getMyNFTs = async () => {
    const config = useRuntimeConfig()
    const contractAddress = config.public.proxyAddress

    if (typeof window.ethereum === 'undefined') {
      throw new Error('Wallet non rilevato')
    }

    await window.ethereum.request({ method: 'eth_requestAccounts' })
    const provider = new ethers.BrowserProvider(window.ethereum)
    const signer = await provider.getSigner()
    const contract = new ethers.Contract(contractAddress, contractABI, signer)

    const [ids, amounts] = await contract.getMyNFTs()
    return { ids, amounts }
  }

  return { getMyNFTs }
}

export function getTotalMyNFTs() {
  const config = useRuntimeConfig()
  const contractAddress = config.public.proxyAddress

  if (typeof window.ethereum === 'undefined') {
    throw new Error('Wallet non rilevato')
  }

  return new Promise(async (resolve, reject) => {
    try {
      await window.ethereum.request({ method: 'eth_requestAccounts' })
      const provider = new ethers.BrowserProvider(window.ethereum)
      const signer = await provider.getSigner()
      const contract = new ethers.Contract(contractAddress, contractABI, signer)

      const count = await contract.getTotalMyNFTs()
      resolve( count )
    } catch (error) {
      reject(error)
    }
  })
}

export async function mintFor(address, npacks) {
  const config = useRuntimeConfig()
  const contractAddress = config.public.proxyAddress

  if (typeof window.ethereum === 'undefined') {
    throw new Error('Wallet non rilevato')
  }

  try {
    await window.ethereum.request({ method: 'eth_requestAccounts' })
    const provider = new ethers.BrowserProvider(window.ethereum)
    const signer = await provider.getSigner()
    const contract = new ethers.Contract(contractAddress, contractABI, signer)

    const mintFee = await contract.MINT_FEE()
    const totalValue = mintFee * BigInt(npacks)

    const tx = await contract.mint4To(address, npacks, {
      value: totalValue
    })

    await tx.wait()
    return tx
  } catch (error) {
    throw error
  }
}

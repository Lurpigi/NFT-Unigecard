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

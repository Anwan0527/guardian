import CryptoJS from '@ohos/crypto-js'

export function encryptMD5(str: string) {
  return CryptoJS.MD5(str).toString()
}
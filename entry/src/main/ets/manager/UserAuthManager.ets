import { userAuth } from '@kit.UserAuthenticationKit'
import { reject } from '@wolfx/lodash'

class UserAuthManager {
  challenge: Uint8Array = new Uint8Array([1, 2, 3, 4, 5, 27])
  authTrustLevel: userAuth.AuthTrustLevel = userAuth.AuthTrustLevel.ATL3
  authTypes: userAuth.UserAuthType[] = [
    userAuth.UserAuthType.PIN,
    userAuth.UserAuthType.FACE,
    userAuth.UserAuthType.FINGERPRINT,
  ]

  //查询认证能力是否支持
  checkUserAuthSupport() {
    const res = this.authTypes.map(item => {
      try {
        //检查是否可用
        userAuth.getAvailableStatus(item, this.authTrustLevel)
        return true
      } catch {
        return false
      }
    })
    return res.some(item => item == true)
  }

  //发起原生用户认证
  startUserAuth(): Promise<boolean> {
    return new Promise((resolve, reject) => {
      //获取认证对象实例
      const userAuthInstance = userAuth.getUserAuthInstance({
        challenge: this.challenge,
        authType: this.authTypes,
        authTrustLevel: this.authTrustLevel
      }, {
        //锁屏密码提示语
        title: '请输入锁屏密码'
      })
      //发起认证
      userAuthInstance.start()
      //订阅认证结果
      userAuthInstance.on('result', {
        onResult(res) {
          if (res.result == userAuth.UserAuthResultCode.SUCCESS) resolve(true)
          else resolve(false)
          //关闭订阅
          userAuthInstance.off('result')
        }

      })
    })
  }
}

export const userAuthManager = new UserAuthManager()
import { userAuth } from '@kit.UserAuthenticationKit'
import { userAuthManager } from '../../manager/UserAuthManager'
import { promptAction } from '@kit.ArkUI'

@Entry
@Component
struct UserAuthTestPage {
  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('查询设备支持的用户身份认证能力')
            .onClick(() => {
              try {
                userAuth.getAvailableStatus(userAuth.UserAuthType.PIN, userAuth.AuthTrustLevel.ATL1)
                AlertDialog.show({ message: 'ok' })
              } catch (error) {
                AlertDialog.show({ message: JSON.stringify(error.message) })
              }
            })
          Button('认证')
            .onClick(() => {
              const userAuthInstance = userAuth.getUserAuthInstance({
                challenge: new Uint8Array([1, 2, 3, 4, 5]),
                authType: [userAuth.UserAuthType.PIN],
                authTrustLevel: userAuth.AuthTrustLevel.ATL1
              }, {
                title: '认证'
              })
              userAuthInstance.start()

              //认证结果
              userAuthInstance.on('result', {
                onResult(result) {
                  if (result.result === userAuth.UserAuthResultCode.SUCCESS) {
                    AlertDialog.show({
                      message: '密码正确'
                    })
                  }
                  userAuthInstance.off('result')
                }

              })
            })

          Button('检查多个APi可用')
            .onClick(() => {
              promptAction.showToast({
                message: JSON.stringify(userAuthManager.checkUserAuthSupport())
              })
            })

          Button('发起原生认证')
            .onClick(() => {
              userAuthManager.startUserAuth()
            })
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('')
    .titleMode(NavigationTitleMode.Mini)
  }
}
import { router } from '@kit.ArkUI'
import { PRIVACY_SETTINGS, PrivacySettings } from '../../../common/constants'

interface RouterParams {
  isForgetPassword?: boolean
}

@Entry
@Component
struct AuthPatternLockSettingsPage {
  // 获取隐私空间设置
  @StorageLink(PRIVACY_SETTINGS) privacySettings: PrivacySettings = {}
  // 正在输入的图形密码
  @State inputPassword: number[] = []
  // 第一次输入的密码
  @State firstPassword: number[] = []
  // 错误提示语
  @State errorMessage: string = ''
  // 路由参数
  @State routerParams: RouterParams = {}
  // 定时器，用于清空提示文案
  private timeoutID: number = -1
  // 控制器
  private patternLockController: PatternLockController = new PatternLockController()

  // 设置错误信息
  setErrorMessage(message: string) {
    // 设置错误文案
    this.errorMessage = message
    // 设置图形错误密码状态
    this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG)
  }

  clearErrorMessage() {
    //设置错误文案
    this.errorMessage = ''
    //设置图形错误密码状态
    this.patternLockController.setChallengeResult(PatternLockChallengeResult.WRONG)
  }

  //密码输入结束时触发该回调
  onPatterComplete(input: number[]) {
    //保存当前输入的密码
    this.inputPassword = input
    //判断密码长度是否小于 4
    if (this.inputPassword.length < 4) {
      this.setErrorMessage('手势密码长度不能小于4位，请重新输入')
    }
    this.timeoutID = setTimeout(() => {
      this.patternLockController.reset()
    }, 500)
  }

  build() {
    Navigation() {
      Column() {
        Text('inputPasswords：' + this.inputPassword)
        Text('firstPasswords：' + this.firstPassword)
      }

      Column({ space: 20 }) {
        Column({ space: 10 }) {
          // 请输入密码
          Text(this.firstPassword.length === 0 ? '设置手势密码' : '再次确认手势密码')
            .fontSize(16)
            .fontColor($r('app.color.font'))
          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(12)
              .fontColor($r('app.color.danger'))
          } else {
            Text(this.firstPassword.length === 0 ? '请绘制手势密码，至少链接4个点' : '请再次输入确认手势密码')
              .fontSize(12)
              .fontColor($r('app.color.font_sub'))
          }
        }

        PatternLock(this.patternLockController)
          .sideLength(320)// 宽高
          .circleRadius(12)// 圆点半径
          .pathStrokeWidth(10)// 线宽度
          .regularColor('#d9d9d9')// 未选中圆点色
          .activeColor('#800a59f7')// 经过圆点色
          .selectedColor(this.errorMessage && this.inputPassword.length !== 0 ? '#ffff5e5d' : '#ff0a59f7')// 选中圆点色
          .pathColor(this.errorMessage && this.inputPassword.length !== 0 ? '#ccff5e5d' : '#cc0a59f7')// 线颜色
          .onDotConnect(() => {
            // 密码输入选中宫格圆点时触发该回调
            clearInterval(this.timeoutID)
          })
          .onPatternComplete((input: number[]) => {
            // TODO：密码输入结束时触发该回调
            this.onPatterComplete(input)
          })

        Row({ space: 20 }) {
          Text('设置文本密码')
            .fontSize(14)
            .fontColor($r('app.color.font2'))
            .onClick(() => {
              if (canIUse('SystemCapability.ArkUI.ArkUI.Lite')) {
                // 可以使用
                router.replaceUrl({ url: 'pages/Privacy/Password/PasswordTextConfirmPage' })
              }

            })
        }
      }
      .padding({ top: 140 })
    }
    .title('隐私空间')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
  }
}
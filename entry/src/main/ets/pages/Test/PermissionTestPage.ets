import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit'
import { permissionManager } from '../../manager'

@Entry
@Component
struct PermissionTestPage {
  //检测应用权限
  checkAccessToken(permissions: Permissions[]) {
    //程序访问控制管理器
    const atManager = abilityAccessCtrl.createAtManager()
    //获取bundle 应用信息
    const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    //提取 tokenID标识
    const tokenID = bundleInfo.appInfo.accessTokenId
    //检验应用是否被赋予权限
    const grantStatus = permissions.map(item => atManager.checkAccessTokenSync(tokenID, item))
    //授权结果
    return grantStatus.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)

  }

  //申请应用权限
  async requestPermission(permissions: Permissions[]) {
    //程序访问控制管理器
    const atManager = abilityAccessCtrl.createAtManager()
    // 核心 API：⚠️注意：只会在首次申请权限的时候弹出（异步的，等待用户操作）
    const requestResult = await atManager.requestPermissionsFromUser(getContext(), permissions)
    return requestResult.authResults.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
  }

  //处理授权结果
  openPermissionSettingPage() {
    //固定写法
    const context = getContext() as common.UIAbilityContext
    const bundleInfo = bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
    context.startAbility({
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: 'application_info_entry',
      parameters: {
        pushParams: bundleInfo.name//打开指定应用详情页面
      }
    })
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('检测日历权限')
            .onClick(() => {
              const isAuth = this.checkAccessToken(['ohos.permission.READ_CALENDAR', 'ohos.permission.WRITE_CALENDAR'])
              AlertDialog.show({ message: JSON.stringify(isAuth) })
            })
          Button('申请录音权限')
            .onClick(async () => {
              const isAuth = await permissionManager.requestPermissions(['ohos.permission.MICROPHONE'])
              AlertDialog.show({ message: JSON.stringify(isAuth) })
            })
          Button('申请相册权限')
            .onClick(async () => {
              const isAuth = await permissionManager.requestPermissions(['ohos.permission.READ_IMAGEVIDEO'])
              AlertDialog.show({ message: JSON.stringify(isAuth) })
            })
          Button('权限处理')
            .onClick(() => {
              this.openPermissionSettingPage()
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
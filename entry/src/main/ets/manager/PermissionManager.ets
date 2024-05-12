import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';
import promptAction from '@ohos.promptAction';

class PermissionManager {
  // 检查是否授权
  checkPermissions(permissions: Permissions[]) {
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

  // 动态申请授权（首次弹窗申请）
  async requestPermissions(permissions: Permissions[]) {
    //程序访问控制管理器
    const atManager = abilityAccessCtrl.createAtManager()
    // 核心 API：️注意：只会在首次申请权限的时候弹出（异步的，等待用户操作）
    const requestResult = await atManager.requestPermissionsFromUser(getContext(), permissions)
    return requestResult.authResults.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
  }

  // 打开系统设置的权限管理页（处理授权结果）
  openPermissionSettingsPage() {
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

  // 如果拒绝，提醒去设置页中开启权限
  async requestPermissionsWithDialog(permissions: Permissions[], message: string) {
    // 申请权限
    const isAuth = await this.requestPermissions(permissions)
    // 如果拒绝权限
    if (isAuth === false) {
      // 开启弹窗提示
      const dialogRes = await promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: message,
        buttons: [
          { text: '取消', color: $r('app.color.font_sub') },
          { text: '立即开启', color: $r('app.color.brand') }
        ]
      })
      // 点击立即开启按钮时，打开设置页
      if (dialogRes.index === 1) {
        this.openPermissionSettingsPage()
      }
    }
  }
}

// 导出 Manager
export const permissionManager = new PermissionManager()
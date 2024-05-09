import { Permissions } from '@kit.AbilityKit'
import { dataSharePredicates } from '@kit.ArkData'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { permissionManager } from '.'

// 手机瘦身
class CleanerManager {
  // 权限
  private permissions: Permissions[] = ["ohos.permission.READ_IMAGEVIDEO", "ohos.permission.WRITE_IMAGEVIDEO"]
  // 图片资源
  private photoAssets: photoAccessHelper.PhotoAsset[] = []
  // 图片字段
  private columns: photoAccessHelper.PhotoKeys[] = [
    photoAccessHelper.PhotoKeys.DATE_ADDED,
    photoAccessHelper.PhotoKeys.SIZE,
  ]

  // 图片权限
  async requestPermissions() {
    // 申请权限
    const isAuth = await permissionManager.requestPermissions(this.permissions)
    if (isAuth === false) {
      // 未开启弹窗提示
      const dialogRes = await promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: '手机瘦身需要获取权限，请在系统设置中打开相册开关',
        buttons: [
          { text: '取消', color: $r('app.color.font_sub') },
          { text: '立即开启', color: $r('app.color.brand') }
        ]
      })
      // 打开设置页
      if (dialogRes.index === 1) {
        permissionManager.openPermissionSettingsPage()
      }
    }
  }

  // 获取图片/视频
  async getAssets() {
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext()) // 获取照片访问助手
    const predicates = new dataSharePredicates.DataSharePredicates() // 创建数据共享断言
    // 获取资源
    const fetchResult = await phAccessHelper.getAssets({
      fetchColumns: this.columns,
      predicates: predicates
    })
    // 获取所有图片
    const photoAssets = await fetchResult.getAllObjects()
    return photoAssets
  }

  // 获取屏幕截图列表
  async getScreenshotList() {
    const photoAssets = await this.getAssets()
    return photoAssets.filter(v => v.displayName.includes('screenshot'))
  }

  // 获取视频列表
  async getVideoList() {
    const photoAssets = await this.getAssets()
    return photoAssets.filter(v => v.photoType === photoAccessHelper.PhotoType.VIDEO)
  }

  // 删除图片
  async deletePhotos(uriList: string[]) {

  }
}

export const cleanerManager = new CleanerManager()
// 图片信息
import { permissionManager } from './PermissionManager'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { dataSharePredicates } from '@kit.ArkData'

export interface PhotoInfo {
  uri: string
  media_type: number
  date_added: number
}

// 相册信息
export interface AlbumInfo {
  albumName: string
  coverUri: string
  imageCount?: number
}

class PhotoManager {
  // 申请图库（相册）权限
  async requestPermissions() {
    const isAuth = await permissionManager.requestPermissions([
      'ohos.permission.READ_IMAGEVIDEO',
      'ohos.permission.WRITE_IMAGEVIDEO'
    ])
    if (isAuth === false) {
      // 未开启弹窗提示
      const dialogRes = await promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: '相册功能需要获取权限，请在系统设置中打开相册开关',
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

  //获取所有图片
  async getPhotoes() {
    // 1. 获取图片管理器
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
    // 2. 查询谓词(条件)
    const predicates = new dataSharePredicates.DataSharePredicates()
    // 3. 获取图库资源
    const assets = await phAccessHelper.getAssets({
      fetchColumns: [photoAccessHelper.PhotoKeys.DATE_ADDED],
      predicates
    })
    // 4. 获取所有的图片资源
    const list = await assets.getAllObjects()
    return list.map<PhotoInfo>(item => {
      return {
        uri: item.uri,
        media_type: item.photoType,
        date_added: item.get(photoAccessHelper.PhotoKeys.DATE_ADDED) as number * 1000
        //添加日期单位:秒 需要*1000修正
      }
    })
  }
}

// 导出媒体相册管理器
export const photoManager = new PhotoManager()
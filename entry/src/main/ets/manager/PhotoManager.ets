// 图片信息
import { permissionManager } from './PermissionManager'
import { promptAction } from '@kit.ArkUI'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { dataSharePredicates } from '@kit.ArkData'
import Fetch from '@system.fetch'

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

  // 需要确保fileUri对应的资源存在
  async addPhoto(fileUri: string) {
    const context = getContext()
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context)
    const assetChangeRequest = photoAccessHelper.MediaAssetChangeRequest.createAssetRequest(
      context, // context
      photoAccessHelper.PhotoType.IMAGE, // Image / Video
      'jpg'  // 后缀名
    );
    assetChangeRequest.addResource(photoAccessHelper.ResourceType.IMAGE_RESOURCE, fileUri);
    await phAccessHelper.applyChanges(assetChangeRequest);
  }

  //删除图片
  async deletePhotos(uris: string[]) {
    // 准备工作 1.
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
    // 准备工作 2.
    const predicates = new dataSharePredicates.DataSharePredicates()
    // 准备工作 3.
    const fetchResult = await phAccessHelper.getAssets({
      fetchColumns: [],
      predicates
    })
    // 获取所有图片资源
    const photoAssets = await fetchResult.getAllObjects()
    // 通过 filter 基于 uris 过滤出需要删除的资源
    const deleteAssets = photoAssets.filter(v => uris.includes(v.uri))
    // 执行删除请求
    await photoAccessHelper.MediaAssetChangeRequest.deleteAssets(getContext(), deleteAssets)
  }

  //获取用户相册
  async getAlbums() {
    const context = getContext()
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context)
    //获取相册信息
    const fectchResult = await phAccessHelper.getAlbums(
      photoAccessHelper.AlbumType.USER, //相册类型
      photoAccessHelper.AlbumSubtype.USER_GENERIC//相册子类型
    )
    //获取所有用户相册
    const album = await fectchResult.getAllObjects()
    const list = album.map<AlbumInfo>(item => {
      return {
        coverUri: item.coverUri,
        albumName: item.albumName,
        imageCount: item.imageCount
      }
    })
    return list
  }

  //根据相册名称获取图片列表
  async getAlbumPhotos(albumName: string) {
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext());
    //相册谓词
    const albumPredicates = new dataSharePredicates.DataSharePredicates();
    albumPredicates.equalTo(photoAccessHelper.AlbumKeys.ALBUM_NAME, albumName);
    const albumFetchResult: photoAccessHelper.FetchResult<photoAccessHelper.Album> =
      await phAccessHelper.getAlbums(
        photoAccessHelper.AlbumType.USER,
        photoAccessHelper.AlbumSubtype.USER_GENERIC,
        {
          fetchColumns: [],
          predicates: albumPredicates
        });
    //获取相册对象
    const album = await albumFetchResult.getFirstObject();
    //图片谓词
    let photoPredicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    let photoFetchOptions: photoAccessHelper.FetchOptions = {
      fetchColumns: [photoAccessHelper.PhotoKeys.DATE_ADDED],
      predicates: photoPredicates
    };
    const photoFetchResult = await album.getAssets(photoFetchOptions);
    const photoAsset = await photoFetchResult.getAllObjects()
    const list = photoAsset.map<PhotoInfo>(item => {
      return {
        uri: item.uri,
        media_type: item.photoType,
        date_added: item.get(photoAccessHelper.PhotoKeys.DATE_ADDED) as number
      }
    })
    return list
    // albumFetchResult.close();
    // photoFetchResult.close();

  }
}

// 导出媒体相册管理器
export const photoManager = new PhotoManager()
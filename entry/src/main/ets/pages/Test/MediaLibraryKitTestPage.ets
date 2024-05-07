import { promptAction } from '@kit.ArkUI'
import { permissionManager, photoManager } from '../../manager'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { dataSharePredicates } from '@kit.ArkData'

interface PhotoInfo {
  displayName: string,
  uri: string,
  photoType: number,
  date_added: number
}

@Entry
@Component
struct MediaLibraryKitTestPage {
  @State list: photoAccessHelper.PhotoAsset[] = []
  @State photoUri: string = ''
  @State newList: PhotoInfo[] = []
  @State albumList: photoAccessHelper.Album[] = []

  //删除图片
  async deletePhotos() {
    //1.
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
    //2.
    const predicates = new dataSharePredicates.DataSharePredicates()
    predicates.orderByDesc(photoAccessHelper.PhotoKeys.DATE_ADDED)
    //3.
    const assets = await phAccessHelper.getAssets({
      fetchColumns: [],
      predicates
    })
    //4.
    const photoAsset = await assets.getFirstObject()
    //5.删除
    await photoAccessHelper.MediaAssetChangeRequest.deleteAssets(getContext(), [photoAsset])
    this.getAllPhotoes()
  }

  async requestPermission() {
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

  async getPhotoes() {
    //获取相册管理器
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
    //查询条件
    const predicates = new dataSharePredicates.DataSharePredicates
    //按添加日期倒叙
    predicates.orderByDesc(photoAccessHelper.PhotoKeys.DATE_ADDED)
    //获取相册资源
    const assets = await phAccessHelper.getAssets({
      fetchColumns: [photoAccessHelper.PhotoKeys.SIZE],
      predicates,
    })
    AlertDialog.show({
      message: '获取相册图片数量' + assets.getCount()
    })
    const photoAsset = await assets.getFirstObject()
    const size = photoAsset.get(photoAccessHelper.PhotoKeys.SIZE)
    AlertDialog.show({
      message: '获取相册大小' + size
    })
  }

  aboutToAppear(): void {
    this.requestPermission()
  }

  // 获取所有图片
  async getAllPhotoes() {
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
    this.list = await assets.getAllObjects()
    this.newList = this.list.map<PhotoInfo>(item => {
      return {
        uri: item.uri,
        displayName: item.displayName,
        photoType: item.photoType,
        date_added: item.get(photoAccessHelper.PhotoKeys.DATE_ADDED) as number * 1000
        //添加日期单位:秒 需要*1000修正
      }
    })
    AlertDialog.show({
      message: JSON.stringify(this.newList, null, 2)
    })
  }

  //获取用户相册
  async getUserAlbums() {
    const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
    const albums = await phAccessHelper.getAlbums(
      photoAccessHelper.AlbumType.USER, //一级相册
      photoAccessHelper.AlbumSubtype.USER_GENERIC//二级
    )
    this.albumList = await albums.getAllObjects()
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('获取图片数量')
            .onClick(() => {
              this.getPhotoes()
            })
          Button('获取全部图片')
            .onClick(async () => {

              AlertDialog.show({
                message: JSON.stringify(await photoManager.getPhotoes())
              })
            })
          Button('删除图片')
            .onClick(() => {
              this.deletePhotos()
            })
          Button('获取用户相册')
            .onClick(() => {
              this.getUserAlbums()
            })
          List() {
            ForEach(this.albumList, (item: photoAccessHelper.Album) => {
              ListItem() {
                Row() {
                  Image(item.coverUri)
                    .width(100)
                    .aspectRatio(1)
                  Text(item.albumName)
                }
              }
            })
          }
          .height('100%')
          .width('100%')

          GridRow({ columns: 4, gutter: 2 }) {
            ForEach(this.newList, (item: photoAccessHelper.PhotoAsset, index: number) => {
              GridCol() {
                Image(item.uri)
                  .width('100%')// 占满列宽度
                  .aspectRatio(1) // 正方形
              }
            }, (item: photoAccessHelper.PhotoAsset, index: number) => item.uri)
          }
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('媒体文件管理服务')
    .titleMode(NavigationTitleMode.Mini)
  }
}
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { NavigationTitleBuilder } from '../../../common/builders'
import { formatByteLength } from '../../../common/utils'
import { themeManager } from '../../../manager'
import { cleanerManager } from '../../../manager/CleanerManger'
import { image } from '@kit.ImageKit'
import { fileIo } from '@kit.CoreFileKit'


@Entry
@Component
struct CompressPhotoIndexPage {
  @State list: photoAccessHelper.PhotoAsset[] = []
  @State selectedName: string[] = []
  @State selectedSize: number = 0

  onPageShow() {
    themeManager.settingStatusBarWhite()
  }

  onPageHide() {
    themeManager.settingStatusBarBlack()
  }

  aboutToAppear() {
    this.getList()
  }

  // 获取列表数据
  async getList() {
    this.list = await cleanerManager.getLargeSizeList()
  }

  async startCompress() {
    const promisTasks = this.selectedName.map(async (uri) => {
      return await this.compressPhoto(uri)
    })
    await Promise.all(promisTasks)
    // 弹窗提醒用户是否删除本地图片
    AlertDialog.show({
      message: `成功压缩${this.selectedName.length}张图片，是否删除原图`,
      alignment: DialogAlignment.Center,
      buttons: [
        {
          value: '取消', fontColor: $r('app.color.font_sub'), action: () => {
        }
        },
        {
          value: '确认', action: () => {
          cleanerManager.deletePhotos(this.selectedName)
        }
        },
      ]
    })
  }

  // TODO：立即瘦身（压缩照片）
  async compressPhoto(uri: string) {
    try { //获取图片
      const file = fileIo.openSync(uri)
      const imageSource = image.createImageSource(file.fd)
      //创建Packer
      const imagePacker = image.createImagePacker()
      const arrayBuffer = await imagePacker.packing(imageSource, { format: 'image/jpeg', quality: 20 })
      //生成新图片
      const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(getContext())
      const newFileUri = await phAccessHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, 'jpg')
      const newFile = fileIo.openSync(newFileUri, fileIo.OpenMode.READ_WRITE)
      fileIo.write(newFile.fd, arrayBuffer)
      // AlertDialog.show({
      //   message: 'ok'
      // })
      fileIo.close(newFile.fd)
      fileIo.close(file.fd)
    } catch (e) {
      AlertDialog.show({
        message: JSON.stringify(e.message)
      })
    }
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        Scroll() {
          Column() {
            Column() {
              Column({ space: 10 }) {
                Text() {
                  Span('预计节省')
                  Span(formatByteLength(this.selectedSize))
                }
                .fontSize(16)
                .fontColor($r('app.color.white'))

                Text(this.selectedName.length + '张可瘦身照片')
                  .fontSize(12)
                  .fontColor($r('app.color.white'))
              }
            }
            .height(80)
            .justifyContent(FlexAlign.Center)

            Column() {
              Column({ space: 20 }) {
                Text('瘦身后的照片会被放到系统相册最前，以便查看')
                  .fontSize(14)
                  .fontColor($r('app.color.font_sub'))
                  .width('100%')
                  .padding({ left: 20, right: 20 })
                List() {
                  ListItem() {
                    GridRow({ gutter: 8, columns: 4 }) {
                      ForEach(this.list, (item: photoAccessHelper.PhotoAsset) => {
                        GridCol() {
                          Stack({ alignContent: Alignment.TopStart }) {
                            // TODO: 共享元素转场
                            Image(item.uri)
                              .width('100%')
                              .height('100%')
                              .objectFit(ImageFit.Cover)
                              .autoResize(true)
                              .interpolation(ImageInterpolation.Medium)
                              .onClick(() => {
                                // 打开对比
                              })
                            Checkbox({ name: item.uri })
                              .selectedColor($r('app.color.brand'))
                          }
                          .width('100%')
                          .aspectRatio(1)
                          .borderRadius(6)
                          .clip(true)
                        }
                      }, (item: photoAccessHelper.PhotoAsset) => item.uri)
                    }
                  }

                  ListItem()
                    .height(120)
                }
                .width('100%')
                .height('100%')
                .sticky(StickyStyle.Header) // 固定分组标题
                .padding({ left: 20, right: 20 })
              }
              .padding({ top: 20, bottom: 20 })
            }
            .backgroundColor($r('app.color.white'))
            .layoutWeight(1)
            .width('100%')
          }
        }
        .width('100%')
        .height('100%')

        // 底部操作按钮
        Row({ space: 15 }) {
          Column() {
            CheckboxGroup()
              .selectedColor($r('app.color.brand'))
              .onChange((value) => {
                this.selectedName = value.name
              })
            Text('全选')
              .fontSize(14)
              .fontColor($r('app.color.font2'))
          }

          Button(`立即瘦身(${this.selectedName.length}张）`)
            .type(ButtonType.Normal)
            .borderRadius(10)
            .backgroundColor($r('app.color.brand'))
            .layoutWeight(1)
            .enabled(this.selectedName.length > 0)
            .onClick(() => {
              // TODO：立即瘦身（压缩照片）
              this.startCompress()
            })
        }
        .width('100%')
        .height(76)
        .backgroundColor($r('app.color.white'))
        .padding({ left: 20, right: 20 })
        .border({ width: { top: 1 }, color: $r('app.color.border') })
      }
    }
    .title(NavigationTitleBuilder('照片瘦身'))
    .hideBackButton(true)
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .linearGradient({
      direction: 213,
      colors: [[$r('app.color.brand'), 0], [$r('app.color.brand_light'), 0.3], [$r('app.color.white'), 0.3]]
    })
  }
}
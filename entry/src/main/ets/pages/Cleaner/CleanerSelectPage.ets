import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { NavigationTitleBuilder } from '../../common/builders'
import { formatByteLength } from '../../common/utils'
import { themeManager } from '../../manager'
import { router } from '@kit.ArkUI'
import { cleanerManager } from '../../manager/CleanerManger'

interface RouterParams {
  name: string
}

@Entry
@Component
struct CleanerSelectPage {
  @State routerParams: RouterParams | null = null
  @State list: photoAccessHelper.PhotoAsset[] = []
  @State @Watch('selectNameChange') selectNames: string[] = []
  @State selectedSize: number = 0

  onPageShow() {
    themeManager.settingStatusBarWhite()
  }

  aboutToAppear(): void {
    // 获取路由参数，参数的 name 最终作为 Navigation 组件的 title 作为标题展示
    const params = router.getParams() as RouterParams
    if (params) {
      this.routerParams = params
      // 基于页面参数，查询图片列表
      this.getList()
    }
  }

  async getList() {
    if (this.routerParams?.name === '屏幕截图') {
      this.list = await cleanerManager.getScreenshotList()
    }
  }

  //计算可节省空间
  selectNameChange() {
    //基于uri集合过滤
    const selectedList = this.list.filter(v => this.selectNames.includes(v.uri))
    //reduce 累加计算
    this.selectedSize = selectedList.reduce((acc, item) => {
      return acc + (item.get(photoAccessHelper.PhotoKeys.SIZE) as number)
    }, 0)
  }

  //删除图片
  async deletePhotos() {
    await cleanerManager.deletePhotos(this.selectNames)
    this.getList()
    AlertDialog.show({
      message: '删除成功'
    })
  }

  onPageHide() {
    themeManager.settingStatusBarBlack()
  }

  build() {
    Navigation() {
      Column() {
        Column({ space: 10 }) {
          Text() {
            Span('可节省')
            Span(formatByteLength(this.selectedSize))
          }
          .fontSize(16)
          .fontColor($r('app.color.white'))

          Text(`已选择${this.selectNames.length}张`)
            .fontSize(12)
            .fontColor($r('app.color.white'))
        }
        .justifyContent(FlexAlign.Center)
        .height(66)

        Scroll() {
          Column() {
            GridRow({ columns: 4, gutter: 8 }) {
              ForEach(this.list, (asset: photoAccessHelper.PhotoAsset) => {
                GridCol() {
                  Stack({ alignContent: Alignment.TopStart }) {
                    if (asset.photoType === photoAccessHelper.PhotoType.IMAGE) {
                      // 图片
                      Image(asset.uri)
                        .width('100%')
                        .aspectRatio(1)
                        .borderRadius(6)
                    } else if (asset.photoType === photoAccessHelper.PhotoType.VIDEO) {
                      // 视频
                      Video({ src: asset.uri })
                        .width('100%')
                        .aspectRatio(1)
                        .borderRadius(6)
                        .autoPlay(true)
                        .muted(true)
                        .controls(false)
                    }
                    Checkbox({ name: asset.uri })
                  }
                  .width('100%')
                  .aspectRatio(1)
                }
              }, ((item: photoAccessHelper.PhotoAsset) => item.uri)) //todo bug
            }

            Blank()
              .layoutWeight(1)
          }
          .padding(15)
        }
        .height('100%')
        .backgroundColor($r('app.color.white'))
      }
      .width('100%')
      .layoutWeight(1)

      Row({ space: 10 }) {
        Column() {
          CheckboxGroup()
            .onChange((event) => {
              this.selectNames = event.name
            })
          Text('全选')
            .fontColor($r('app.color.font2'))
            .fontSize(12)
        }

        Button('删除')
          .type(ButtonType.Normal)
          .borderRadius(10)
          .layoutWeight(1)
          .height(42)
          .backgroundColor($r('app.color.danger'))
          .onClick(() => {
            // TODO：删除选中图片
            this.deletePhotos()
          })
      }
      .border({ width: { top: 1 }, color: $r('app.color.border') })
      .width('100%')
      .height(76)
      .padding({ left: 20, right: 20 })
      .backgroundColor($r('app.color.white'))
    }
    .title(NavigationTitleBuilder(this.routerParams?.name))
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .linearGradient({
      angle: 180,
      colors: [[$r('app.color.brand'), 0], [$r('app.color.brand_light'), 0.3], [$r('app.color.white'), 0.3]]
    })
  }
}

// todo 有bug
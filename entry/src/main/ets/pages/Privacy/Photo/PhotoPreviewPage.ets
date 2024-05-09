import { NavigationTitleBuilder } from '../../../common/builders'
import { privacyPhotoDB, PrivacyPhotoDBInfo } from '../../../common/database'
import { router } from '@kit.ArkUI'


interface RouterParams {
  previewUri?: string
}

@Entry
@Component
struct PhotoPreviewPage {
  @State list: PrivacyPhotoDBInfo[] = []
  @State activePhotoUri: string = ''
  @State @Watch('activeIndexChange') activeIndex: number = 0
  // 路由参数
  private routerParams: RouterParams = {}
  private swiperController: SwiperController = new SwiperController()
  private scrollerController: Scroller = new Scroller()

  aboutToAppear(): void {
    const params = router.getParams() as RouterParams
    if (params) {
      this.routerParams = params
      this.getList()
    }
  }

  async getList() {
    this.list = await privacyPhotoDB.query()
    // AlertDialog.show({
    //   message: JSON.stringify({ a: this.list, b: this.routerParams.previewUri }, null, 2)
    // })
    try {
      this.activeIndex = this.list.findIndex(v => v.privacyUri === this.routerParams.previewUri) //todo 比不出来
    } catch (e) {
      AlertDialog.show({
        message: JSON.stringify(e)
      })
    }

  }

  //监听下标变化，设置滚动条
  activeIndexChange() {
    this.scrollerController.scrollTo({ xOffset: this.activeIndex * 62, yOffset: 0, animation: true })
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        Swiper(this.swiperController) {
          ForEach(this.list, (item: PrivacyPhotoDBInfo) => {
            // TODO: 共享元素转场
            Image(item.privacyUri)
              .width('100%')
              .objectFit(ImageFit.Contain)
              .sharedTransition('sharedImage', { duration: 800, curve: Curve.Linear, delay: 100 })
          })
        }
        .indicator(false)
        .loop(false)
        .itemSpace(10)
        .index(this.activeIndex)
        .height('100%')
        .padding({ bottom: 138 })
        .onChange((index) => {
          this.activeIndex = index
        })

        // 底部操作栏
        Column({ space: 10 }) {
          // 小图区域
          Scroll(this.scrollerController) {
            Row({ space: 4 }) {
              ForEach(this.list, (item: PrivacyPhotoDBInfo, index: number) => {
                Image(item.privacyUri)
                  .width(62)
                  .height(62)
                  .objectFit(ImageFit.Cover)
                  .autoResize(true)
                  .interpolation(ImageInterpolation.Medium)
                  .outline({
                    width: 2,
                    color: this.activeIndex === index ? $r('app.color.brand') : Color.Transparent
                  })//选中图片的框
                  .onClick(() => {
                    this.activeIndex = index
                  })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBarWidth(0)
          .width('100%')
          .height(66)

          // 操作按钮
          Row({ space: 10 }) {
            Button('复制到相册')
              .type(ButtonType.Normal)
              .borderRadius(10)
              .backgroundColor($r('app.color.brand'))
              .layoutWeight(1)
              .onClick(() => {
                // TODO：复制到相册
              })
            Button('删除')
              .type(ButtonType.Normal)
              .borderRadius(10)
              .backgroundColor($r('app.color.danger'))
              .layoutWeight(1)
              .onClick(() => {
                // TODO：删除
              })
          }
          .width('100%')
          .padding({ left: 10, right: 10 })
        }
        .width('100%')
        .height(150)
        .backgroundColor('#80000000')
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .height('100%')
    }
    .title(NavigationTitleBuilder(`${this.activeIndex + 1}/${this.list.length}`))
    .hideBackButton(true)
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .backgroundColor('#000')
  }
}
// 页面参数
import { privacynoteDB } from '../../../common/database'
import { promptAction, router } from '@kit.ArkUI'

interface RouterParams {
  id?: number
}

@Entry
@Component
struct NoteDetailPage {
  // 标题
  @State title: string = ''
  // 内容
  @State content: string = ''
  // 页面参数
  @State routerParams: RouterParams = {}

  aboutToAppear(): void {
    if (router.getParams())
      this.routerParams = router.getParams() as RouterParams
  }

  onBackPress() {
    // 如果是新增，且标题非空
    if (this.title.trim() !== '') {
      // 弹窗确认
      AlertDialog.show({
        alignment: DialogAlignment.Center,
        title: '提示',
        message: '您输入的内容还没有保存，是否放弃？',
        buttons: [
        // 放弃,返回上一页
          {
            value: '放弃', action: () => {
            router.back()
          }
          },
          // 继续编辑
          {
            value: '继续编辑', action: () => {
          }
          },
        ]
      })
      return true // 不返回上一页，通过弹窗处理是否返回
    } else {
      return false // 正常返回上一页
    }
  }

  async onSubmit() {
    //如果有id->更新笔记
    if (this.routerParams.id) {
      await privacynoteDB.update({
        id: this.routerParams.id,
        title: this.title,
        content: this.content,
        date_added: Date.now()
      })
    } else { //没有->新建
      await privacynoteDB.insert({
        id: null,
        title: this.title,
        content: this.content,
        date_added: Date.now()
      })
    }
    promptAction.showToast({
      message: '笔记加密完成'
    })
    router.back()
  }

  @Builder
  NavigationMenus() {
    Row() {
      Text('保存')
        .fontSize(16)
        .fontColor(this.title.trim() !== '' ? $r('app.color.font') : $r('app.color.font_sub'))
        .enabled(this.title.trim() !== '')
        .onClick(() => {
          // TODO：保存/新增
          this.onSubmit()
        })
    }
    .height('100%')
    .padding({ right: 25 })
  }

  build() {
    Navigation() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column({ space: 10 }) {
          Text('标题')
            .fontSize(14)
            .fontColor($r('app.color.font2'))
            .width('100%')
          TextInput({ placeholder: '请输入笔记标题', text: this.title })
            .backgroundColor($r('app.color.white'))
            .border({ width: 1, color: $r('app.color.border'), radius: 6 })
            .padding({ left: 10 })
            .onChange((text) => {
              this.title = text
            })
            .onSubmit(() => {
              // TODO：提交表单(保存/新增)
            })
          Text('内容')
            .fontSize(14)
            .fontColor($r('app.color.font2'))
            .width('100%')
          TextArea({ placeholder: '请输入笔记内容', text: this.content })
            .backgroundColor($r('app.color.white'))
            .border({ width: 1, color: $r('app.color.border'), radius: 6 })
            .layoutWeight(1)
            .padding(10)
            .onChange((text) => {
              this.content = text
            })
        }
        .padding({ bottom: 160 })

        if (this.routerParams.id) {
          // 底部按钮
          Row({ space: 10 }) {
            Button('删除')
              .type(ButtonType.Normal)
              .backgroundColor('#FF5E5D')
              .borderRadius(10)
              .layoutWeight(1)
              .onClick(() => {
                // TODO：删除
              })
            Button('分享')
              .type(ButtonType.Normal)
              .backgroundColor($r('app.color.brand'))
              .borderRadius(10)
              .layoutWeight(1)
              .onClick(() => {
                // TODO：分享
              })
          }
          .padding({ bottom: 80 })
        }
      }
      .padding({ left: 15, right: 15, top: 20 })

    }
    .title('笔记')
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .menus(this.NavigationMenus())

  }
}
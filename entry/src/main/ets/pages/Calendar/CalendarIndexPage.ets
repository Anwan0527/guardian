import { router } from '@kit.ArkUI'
import { calendarManager } from '@kit.CalendarKit'
import { NavigationTitleBuilder } from '../../common/builders'
import { themeManager } from '../../manager'
import { userCalendarManager } from '../../manager/UserCalendarManager'
import { data } from '@kit.TelephonyKit'
import { ONE_HOUR, ONE_MINUTE, ONE_SECOND } from '../../common/constants/TimeStamp'

@Entry
@Component
struct CalendarIndexPage {
  @State isSafe: boolean = true
  @State overdueEvents: calendarManager.Event[] = []
  @State fraudEvents: calendarManager.Event[] = []
  @State isLoading: boolean = false

  onPageShow() {
    themeManager.settingStatusBarWhite()
  }

  onPageHide() {
    themeManager.settingStatusBarBlack()
  }

  async aboutToAppear() {
    await userCalendarManager.requestPermission()
  }

  //添加日程
  async addEvent() {
    const id = await userCalendarManager.addEvent({
      type: calendarManager.EventType.NORMAL,
      startTime: Date.now(),
      endTime: Date.now() + ONE_HOUR * 3,
      title: '守护助手提醒你吃饭了'
    })
    AlertDialog.show({
      message: '日程id' + id
    })
  }

  //添加重要日程
  async addInportantEvent() {
    // 添加重要日程，模拟器不能提醒
    const id = await userCalendarManager.addEvent({
      type: calendarManager.EventType.IMPORTANT,
      startTime: Date.now() + ONE_MINUTE * 1,
      endTime: Date.now() + ONE_MINUTE * 2,
      title: '守护助手提醒这是重要提醒',
      reminderTime: [0, 5, 10] // 单位是分钟，0 表示准点提醒
    })
    AlertDialog.show({ message: '重要日程添加成功，等待提醒,日程id为：' + id })

  }

  //获取日程
  async getEvent() {
    const list = await userCalendarManager.getEvent()
    AlertDialog.show({ message: JSON.stringify(list, null, 2) })
  }

  @Builder
  NavigationMenus() {
    Row() {
      Image($r('app.media.ic_public_search'))
        .width(22)
        .aspectRatio(1)
        .onClick(() => {
          router.pushUrl({ url: 'pages/Calendar/CalendarSearchPage' })
        })
    }
    .height('100%')
    .padding({ right: 25 })
  }

  build() {
    Navigation() {
      Stack() {
        if (!this.isLoading) {
          // 主界面
          Column() {
            Column() {
              if (this.fraudEvents.length === 0) {
                Column() {
                  Image($r("app.media.ic_calendar_safe"))
                    .height(88)
                    .margin({ top: 30 })
                  Text('暂未发现诈骗日历')
                    .fontSize(16)
                    .fontColor($r('app.color.white'))
                    .margin({ top: 15, bottom: 5 })
                  Text('建议您输入关键词搜索')
                    .fontSize(14)
                    .fontColor($r('app.color.white'))
                  Button('立即搜索')
                    .height(28)
                    .fontSize(14)
                    .type(ButtonType.Normal)
                    .border({ width: 1, color: $r('app.color.white'), radius: 6 })
                    .fontColor($r('app.color.white'))
                    .backgroundColor(Color.Transparent)
                    .margin({ top: 20 })
                    .onClick(() => {
                      router.pushUrl({ url: 'pages/Calendar/CalendarSearchPage' })
                    })
                }
              } else {
                Column() {
                  Image($r('app.media.ic_calendar_cheat'))
                    .height(88)
                    .margin({ top: 30 })
                  Text(`发现 ${this.fraudEvents.length} 条诈骗日历`)
                    .fontSize(16)
                    .fontColor($r('app.color.white'))
                    .margin({ top: 15, bottom: 5 })
                  Text('建议您立即清理，防止上当受骗')
                    .fontSize(14)
                    .fontColor($r('app.color.white'))
                  Button('立即清理')
                    .height(28)
                    .fontSize(14)
                    .type(ButtonType.Normal)
                    .border({ width: 1, color: $r('app.color.white'), radius: 6 })
                    .fontColor($r('app.color.white'))
                    .backgroundColor(Color.Transparent)
                    .margin({ top: 20 })
                    .onClick(() => {
                      router.pushUrl({ url: 'pages/Calendar/CalendarFraudPge' })
                    })
                }
              }
            }
            .height(250)

            Column({ space: 10 }) {
              CellRow({
                icon: $r('app.media.ic_calendar_overdue'),
                title: '过期日历',
                desc: '发现 - 条过期日历',
                empty: '未发现过期日历',
                count: this.overdueEvents.length
              })
                .onClick(() => {
                  router.pushUrl({ url: 'pages/Calendar/CalendarOverduePage' })
                })

              CellRow({
                icon: $r('app.media.ic_calendar_protect'),
                title: '日历防诈骗须知',
                desc: '-',
                empty: '如何彻底告别日历骚扰',
                count: 0
              })
                .onClick(() => {
                  router.pushUrl({ url: 'pages/Calendar/CalendarKnowledgePage' })
                })
            }
            .padding(10)
            .layoutWeight(1)
            .backgroundColor($r('app.color.white'))

            Column({ space: 10 }) {
              Button('添加诈骗日程')
                .onClick(async () => {
                  //
                  this.addEvent()
                })
              Button('获取诈骗日程')
                .onClick(async () => {
                  //
                  this.getEvent()
                })
              Button('添加重要日程')
                .onClick(async () => {
                  //
                  this.addInportantEvent()
                })
              Button('添加过期日程')
                .onClick(async () => {
                  //
                })
            }
          }
          .height('100%')
        } else {
          // Loading 效果
          Column({ space: 20 }) {
            Image($r('app.media.ic_calendar_loading'))
              .width(100)
            Text('正在检测日历')
              .fontSize(16)
              .fontColor($r('app.color.white'))
          }
          .height('100%')
          .justifyContent(FlexAlign.Center)
        }
      }
    }
    .title(NavigationTitleBuilder('日历清理'))
    .titleMode(NavigationTitleMode.Mini)
    .mode(NavigationMode.Stack)
    .hideBackButton(true)
    .menus(this.NavigationMenus())
    .linearGradient({
      angle: 180,
      colors: !this.isLoading ?
        [[$r('app.color.brand'), 0], [$r('app.color.brand_light'), 0.5], [$r('app.color.white'), 0.5]] :
        [[$r('app.color.brand'), 0], [$r('app.color.brand_light'), 1]]
    })
  }
}

@Component
struct CellRow {
  icon: ResourceStr = $r('app.media.ic_calendar_overdue')
  @Prop title: string = '过期日历'
  @Prop desc: string = '发现-条过期日历'
  @Prop empty: string = ''
  @Prop count: number = 220

  build() {
    Row({ space: 10 }) {
      Image(this.icon)
        .width(40)
        .aspectRatio(1)
      Column({ space: 5 }) {
        Text(this.title)
          .fontSize(16)
          .fontWeight(500)
          .fontColor($r('app.color.font'))
        Text() {
          if (this.count > 0) {
            Span(this.desc.split('-')[0])
            Span(this.count.toString())
              .fontColor($r('app.color.brand'))
            Span(this.desc.split('-')[1])
          } else {
            Span('未发现过期日历')
          }
        }
        .fontSize(12)
        .fontColor($r('app.color.font_sub'))
      }
      .alignItems(HorizontalAlign.Start)
    }
    .padding({ left: 20 })
    .height(72)
    .border({ width: 1, color: $r('app.color.border'), radius: 6 })
    .width('100%')
  }
}
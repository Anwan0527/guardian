// xxx.ets
@Entry
@Component
struct DirectiveMenuExample {
  @Builder
  MenuBuilder() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      List() {
        ListItem() {
          Column() {
            Text('Options')
            Divider().strokeWidth(2).margin(5).color('#F0F0F0')
          }
        }

        ListItem() {
          Column() {
            Text('Options')
            Divider().strokeWidth(2).margin(5).color('#F0F0F0')
          }
        }

        ListItem() {
          Column() {
            Text('Options')
            Divider().strokeWidth(2).margin(5).color('#F0F0F0')
          }
        }

        ListItem() {
          Column() {
            Text('Options')
            Divider().strokeWidth(2).margin(5).color('#F0F0F0')
          }
        }

        ListItem() {
          Column() {
            Text('Options')
            Divider().strokeWidth(2).margin(5).color('#F0F0F0')
          }
        }

        ListItem() {
          Column() {
            Text('Options')
            Divider().strokeWidth(2).margin(5).color('#F0F0F0')
          }
        }

        ListItem() {
          Column() {
            Text('Options')
            Divider().strokeWidth(2).margin(5).color('#F0F0F0')
          }
        }

        ListItem() {
          Column() {
            Text('Options')
            Divider().strokeWidth(2).margin(5).color('#F0F0F0')
          }
        }
      }
      .scrollBar(BarState.Off)
      .width(200)
      .height(200)
    }

  }

  build() {
    Flex({ direction: FlexDirection.Column, alignItems: ItemAlign.Center, justifyContent: FlexAlign.Center }) {
      Column() {
        Text("DirectiveMenuExample")
          .fontSize(20)
          .width('100%')
          .height("25%")
          .backgroundColor('#F0F0F0')
          .textAlign(TextAlign.Center)
          .bindContextMenu(this.MenuBuilder, ResponseType.LongPress, {
            enableArrow: true,
            placement: Placement.Bottom
          })

      }
    }
    .width('100%')
    .height('100%')
  }
}

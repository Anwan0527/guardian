import { Permissions } from '@kit.AbilityKit';
import { permissionManager } from './PermissionManager';
import { calendarManager } from '@kit.CalendarKit';

// 日历(日程)管理器
class UserCalendarManager {
  private permissions: Permissions[] = ["ohos.permission.READ_CALENDAR", "ohos.permission.WRITE_CALENDAR"];

  // 授权弹窗
  async requestPermission() {
    permissionManager.requestPermissionsWithDialog(
      this.permissions, // 权限
      '日历清理功能需要获取权限，请在系统设置中打开日历开关' // 拒绝时的提示语
    )
  }

  // 1. 获取默认（我的）日历
  async getDefaultCalendar() {
    const userCalendarManager = calendarManager.getCalendarManager(getContext())
    // 不传任何参数表示获取默认（我的）日历
    return await userCalendarManager.getCalendar()
  }

  //添加日程
  async addEvent(event: calendarManager.Event) {
    const calendar = await this.getDefaultCalendar()
    return calendar.addEvent(event)
  }

  //获取日程
  async getEvent() {
    const calendar = await this.getDefaultCalendar()
    return calendar.getEvents()
  }

  //按关键词搜索日程
  async searchEvents(title: string) {
    const calendar = await this.getDefaultCalendar()
    const filter = calendarManager.EventFilter.filterByTitle(title)
    return calendar.getEvents(filter)
  }
}

export const userCalendarManager = new UserCalendarManager()
import { Permissions } from '@kit.AbilityKit';
import { contact } from '@kit.ContactsKit';
import { permissionManager } from './PermissionManager';
import { deviceInfo } from '@kit.BasicServicesKit';

class ContactManager {
  // 通讯录读写权限
  private permissions: Permissions[] = ["ohos.permission.READ_CONTACTS", "ohos.permission.WRITE_CONTACTS"];

  // 授权弹窗
  async requestPermission() {
    // 申请权限
    permissionManager.requestPermissionsWithDialog(
      this.permissions,
      '通讯录功能需要获取权限，请在系统设置中打开通讯录开关'
    )
  }

  // 获取所有通讯录联系人
  async getContacts(): Promise<contact.Contact[]> {
    if (deviceInfo.marketName === 'emulator') {
      // 如果是模拟器，返回一份假的数据，方便测试
      return [
        {
          name: {
            fullName: '孙悟空'
          },
          phoneNumbers: [
            {
              phoneNumber: '13666666'
            }
          ]
        }
      ]
    } else {
      // API 11 的 queryContacts 是带 s 的
      return contact.queryContacts(getContext())
    }
  }

  // 获取群组
  getGroups() {
    return contact.queryGroups(getContext())
  }
}

export const contactManager = new ContactManager()
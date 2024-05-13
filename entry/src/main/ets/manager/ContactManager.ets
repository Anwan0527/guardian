import { Permissions } from '@kit.AbilityKit';
import { contact } from '@kit.ContactsKit';
import { permissionManager } from './PermissionManager';

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
  getContacts() {
    // API 的 queryContacts 是带 s 的
    return contact.queryContacts(getContext())
  }
}

export const contactManager = new ContactManager()
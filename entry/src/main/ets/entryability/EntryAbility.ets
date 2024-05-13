import { AbilityConstant, errorManager, UIAbility, Want } from '@kit.AbilityKit';
import { FaultLogger, hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction, router, window } from '@kit.ArkUI';
import { PrivacySettings, PRIVACY_SETTINGS } from '../common/constants';
import { axiosInstance } from '../common/utils';
import { pasteboardManager } from '../manager/PasteboardManager';

let observerId = -1

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    observerId = errorManager.on('error', {
      //当应用产生未捕获的异常时
      async onUnhandledException() {
        const list = await FaultLogger.query(FaultLogger.FaultType.JS_CRASH)
        await axiosInstance({
          method: 'POST',
          url: '/log/fault/report/single',
          data: list[0]
        })
        hilog.info(0x0000, 'testTag', '%{public}s', JSON.stringify(list, null, 2));
      }
    })
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    errorManager.off("error", observerId);
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('/pages/Index'.slice(1), (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
      // 读取剪贴板的内容（拼多多，淘宝，读取分享链接）
      const text = pasteboardManager.getPasteText()
      // 后续业务...
      promptAction.showToast({
        message: text
      })
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
    // 读取剪贴板的内容（拼多多，淘宝，读取分享链接）
    const text = pasteboardManager.getPasteText()
    // 后续业务...
    promptAction.showToast({
      message: text
    })
  }

  onBackground(): void {
    // Ability has back to background
    const routerState = router.getState()
    if (routerState.path.includes('pages/Privacy')) {
      router.back({
        url: 'pages/Index'
      })
    }
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}

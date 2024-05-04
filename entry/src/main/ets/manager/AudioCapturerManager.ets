import { Permissions } from '@kit.AbilityKit'
import { promptAction } from '@kit.ArkUI'
import { permissionManager } from '.'
import { audio } from '@kit.AudioKit'
import { fileIo } from '@kit.CoreFileKit'
import fileIO from '@ohos.fileio'

interface AudioInfo {
  date_added: number,
  duration: number,
  filePath: string
}

class AudioCapturerManager {
  // 权限
  private permissions: Permissions[] = ["ohos.permission.MICROPHONE"]
  //音频渲染器配置
  private audioRendererInfo: audio.AudioRendererInfo = {
    usage: audio.StreamUsage.STREAM_USAGE_MUSIC, //播放类型
    rendererFlags: 0
  }
  //音频渲染器实例
  private audioRenderer: audio.AudioRenderer | null = null
  // 音频流配置
  private audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000, // 采样率
    channels: audio.AudioChannel.CHANNEL_2, // 通道
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
  };
  // 音频采集器配置
  private audioCapturerInfo: audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_MIC,
    capturerFlags: 0
  };
  // 音频采集器实例
  private audioCapturer: audio.AudioCapturer | null = null
  // 录音文件路径
  private filePath: string = ''
  // 录音创建时间
  private date_added: number = 0

  // 初始化权限
  async requestPermissions() {
    // 申请权限
    const isAuth = await permissionManager.requestPermissions(this.permissions)
    // 如果未授权引导去设置页开启授权
    if (isAuth === false) {
      // 未开启弹窗提示
      const dialogRes = await promptAction.showDialog({
        alignment: DialogAlignment.Center,
        title: '温馨提示',
        message: '录音功能需要获取权限，请在系统设置中打开麦克风开关',
        buttons: [
          { text: '取消', color: $r('app.color.font_sub') },
          { text: '立即开启', color: $r('app.color.brand') }
        ]
      })
      // 打开设置页
      if (dialogRes.index === 1) {
        permissionManager.openPermissionSettingsPage()
      }
    }
  }

  //获取录音实例
  async getAudioCapturer() {
    //如果有 直接返回  若没有 创建
    if (this.audioCapturer) {
      return this.audioCapturer
    }
    const audioCapturer = await audio.createAudioCapturer({
      streamInfo: this.audioStreamInfo,
      capturerInfo: this.audioCapturerInfo
    })
    this.audioCapturer = audioCapturer
    return audioCapturer
  }

  //获取波音实例
  async getAudioRenderer() {
    if (this.audioRenderer) {
      return this.audioRenderer
    }
    this.audioRenderer = await audio.createAudioRenderer({
      streamInfo: this.audioStreamInfo,
      rendererInfo: this.audioRendererInfo
    })
    return this.audioRenderer
  }

  //开始录音
  async startRecorder(filePath: string) {
    // 1. 获取音频采集器
    const audioCapturer = await this.getAudioCapturer()
    // 偏移值
    let bufferSize: number = 0
    // 根据 filePath 打开文件，可读可写模式，如果文件不存在自动创建
    const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
    // 2. 调用on('readData')方法，订阅监听音频数据读入回调
    audioCapturer.on('readData', (buffer) => {
      // 把采集的音频信息写入到打开的文件中
      fileIo.writeSync(file.fd, buffer, { offset: bufferSize, length: buffer.byteLength })
      // 累加偏移值
      bufferSize += buffer.byteLength
      // 测试用的，封装完成记得删除
      promptAction.showToast({ message: bufferSize.toString() })
    })
    // 3. 开始录音采集
    audioCapturer.start()
    // 保存录音文件路径
    this.filePath = filePath
    // 保存录音创建时间
    this.date_added = Date.now()
  }

  //结束录音
  async stopRecorder(): Promise<AudioInfo> {
    // 获取音频采集器
    const audioCapturer = await this.getAudioCapturer()
    await audioCapturer.stop() // 停止采集
    audioCapturer.release() // 释放资源
    this.audioCapturer = null // 重置采集器变量
    return {
      filePath: this.filePath,
      date_added: this.date_added,
      duration: Date.now() - this.date_added
    }
  }

  //播放录音
  async startRenderer(filePath: string) {
    const audioRenderer = await this.getAudioRenderer()
    let bufferSize: number = 0 //偏移量
    const file = fileIo.openSync(filePath)
    audioRenderer.on('writeData', buffer => {
      fileIo.readSync(file.fd, buffer, { offset: bufferSize, length: buffer.byteLength })
      bufferSize += buffer.byteLength
      //测试用的
      promptAction.showToast({
        message: bufferSize.toString()
      })
      const stat = fileIo.statSync(file.fd)
      if (bufferSize >= stat.size) {
        this.stopRecorder()
      }
    })
    audioRenderer.start()
  }

  // 停止播放录音
  async stopRenderer() {
    const audioRenderer = await this.getAudioRenderer()
    await audioRenderer.stop()
    audioRenderer.release()
    this.audioRenderer = null
  }
}

export const audioCapturerManager = new AudioCapturerManager()
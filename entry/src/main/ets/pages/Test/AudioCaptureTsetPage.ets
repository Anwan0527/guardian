import { audio } from '@kit.AudioKit';
import { fileIo } from '@kit.CoreFileKit';
import { audioCapturerManager } from '../../manager';

@Entry
@Component
struct AudioCapturerTestPage {
  audioStreamInfo: audio.AudioStreamInfo = {
    samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_48000, // 采样率
    channels: audio.AudioChannel.CHANNEL_2, // 通道
    sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
    encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
  };
  audioCapturerInfo: audio.AudioCapturerInfo = {
    source: audio.SourceType.SOURCE_TYPE_MIC,
    capturerFlags: 0
  };
  audioCapturer: audio.AudioCapturer | null = null
  audioRendererInfo: audio.AudioRendererInfo = {
    usage: audio.StreamUsage.STREAM_USAGE_VOICE_COMMUNICATION,
    rendererFlags: 0
  };
  filePath: string = ''

  // 获取 AudioCapturer
  async getAudioCapturer() {
    if (this.audioCapturer) {
      return this.audioCapturer
    }
    // 1. 创建 AudioCapturer，配置音频采集参数
    const audioCapturer = await audio.createAudioCapturer({
      streamInfo: this.audioStreamInfo,
      capturerInfo: this.audioCapturerInfo
    })
    this.audioCapturer = audioCapturer
    return audioCapturer
  }

  // 开始录音
  async startRecorder() {
    try {
      // 1. 创建 AudioCapturer，配置音频采集参数
      const audioCapturer = await audio.createAudioCapturer({
        streamInfo: this.audioStreamInfo,
        capturerInfo: this.audioCapturerInfo
      })

      // 2. 调用on('readData')方法，订阅监听音频数据读入回调
      // audioCapturer
      // 2.1 准备文件，用于写入录音
      const context = getContext()
      // cacheDir    临时文件目录
      // filesDir    持久化文件目录
      const filePath = context.filesDir + '/' + Date.now() + '.wav'
      // 设置成全局
      this.filePath = filePath
      // 打开文件的模式为 fileIo.OpenMode.READ_WRITE 可读可写
      const file = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
      // 累加偏移量
      let bufferSize: number = 0;
      // 2.2 注册(订阅)事件，监听音频数据读入
      audioCapturer.on('readData', (buffer) => {
        // writeSync 写文件，设置偏移量，保留原本的数据不被覆盖
        fileIo.writeSync(file.fd, buffer, { offset: bufferSize, length: buffer.byteLength })
        // 累加偏移量
        bufferSize += buffer.byteLength
      })

      // 3. 开始录音
      audioCapturer.start()

    } catch (error) {
      AlertDialog.show({ message: JSON.stringify(error.message, null, 2) })
    }
  }

  //停止录音
  async stopRecorder() {
    const audioCapturer = await this.getAudioCapturer()
    await audioCapturer.stop()
    audioCapturer.release()
    this.audioCapturer = null //清空
  }

  //播放录音
  async startRender() {
    const audioRenderer = await audio.createAudioRenderer({
      streamInfo: this.audioStreamInfo,
      rendererInfo: this.audioRendererInfo
    })
    let bufferSize: number = 0
    const file = fileIo.openSync(this.filePath)
    //调用on
    audioRenderer.on('writeData', buffer => {
      fileIo.readSync(file.fd, buffer, {
        offset: bufferSize,
        length: buffer.byteLength
      })
      bufferSize += buffer.byteLength
    })
    audioRenderer.start()
  }

  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('开启权限')
            .onClick(() => {
              audioCapturerManager.requestPermissions()
            })
          Button('开始录音')
            .onClick(() => {
              this.startRecorder()
            })
          Button('停止录音')
            .onClick(() => {
              this.stopRecorder()
            })
          Button('播放录音')
            .onClick(() => {
              this.startRender()
            })
        }
        .constraintSize({ minHeight: '100%' })
      }
      .width('100%')
      .height('100%')
    }
    .title('')
    .titleMode(NavigationTitleMode.Mini)
  }
}
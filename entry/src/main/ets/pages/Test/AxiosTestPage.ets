import axios, { AxiosResponse } from '@ohos/axios'

/**
 * 数据响应模型«long»
 */
export interface Response<T> {
  /** 请求码，200为成功，300及300以上为请求失败 */
  code: number;

  /** 响应信息 */
  msg?: string;

  /** 响应时间 */
  resTime?: Date;

  /** 响应内容 */
  result?: T;
  tips?: string;
}

type MyAxiosResponse<T> = AxiosResponse<Response<T>, null>

@Entry
@Component
struct AxiosTestPage {
  build() {
    Navigation() {
      Scroll() {
        Column({ space: 10 }) {
          Button('axios')
            .onClick(async () => {
              const res: AxiosResponse = await axios({
                method: 'GET',
                url: 'https://guardian-api.itheima.net/test'
              })
              AlertDialog.show({
                message: JSON.stringify(res)
              })
            })
          Button('axios进阶')
            .onClick(async () => {
              const axiosInstance = axios.create({
                baseURL: 'https://guardian-api.itheima.net',
                timeout: 1000 * 30
              })
              // const res: AxiosResponse = await axiosInstance({
              //   method: "GET",
              //   url: '/test'
              // })
              const res = await axiosInstance<null, MyAxiosResponse<string>, null>({
                method: "GET",
                url: '/test'
              })
              AlertDialog.show({
                message: JSON.stringify(res.data.msg)
              })

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
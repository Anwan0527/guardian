import { promptAction, router } from '@kit.ArkUI'
import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { BASE_URL, LoginInfoResponse, LOGIN_INFO } from '../constants'

// 创建实例
export const axiosInstance = axios.create({
  baseURL: BASE_URL, // 请求基地址
  timeout: 1000 * 20 // 请求超时时间
})

// 后端响应基本类型
export interface ServiceResponse<Result> {
  code: number
  msg?: string
  resTime?: string
  result: Result
  tips?: string
}

// Axios 响应类型 > 后端响应基本类型 > 不同接口响应的类型
export type AxiosResponseData<Result = null, Data = null> = AxiosResponse<ServiceResponse<Result>, Data>

// --- 从官方文档中复制过来拦截器的基本结构 ---
// 添加请求拦截器
axiosInstance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const loginInfo = AppStorage.get<LoginInfoResponse>(LOGIN_INFO)
  if (loginInfo?.accessToken) {
    // 把访问 token 自动添加到 headers 中
    config.headers.Authorization = loginInfo.accessToken
  }
  // 对请求数据做点什么
  return config;
}, (error: AxiosError) => {
  // 对请求错误做些什么
  return Promise.reject(error);
});

// 添加响应拦截器，AxiosResponse -> AxiosResponseData 书写时有提示
axiosInstance.interceptors.response.use((response: AxiosResponseData) => {
  // 后端能响应结果，但是业务码出现错误，提示后端返回的 msg 信息
  if (response.data.code !== 200) {
    promptAction.showToast({ message: response.data.msg })
    // 标记为 reject 失败，防止 await 后续代码执行
    return Promise.reject(response)
  }
  // 对响应数据做点什么
  return response;
}, (error: AxiosError) => {
  // 服务器响应失败，如 404 找不到路径，服务器错误，无网络的提示 等
  if (error.message.includes('404')) {
    promptAction.showToast({ message: '请求错误，请检查 url 路径' })
  } else if (error.message.includes('401')) {
    promptAction.showToast({ message: '登录信息无效' })
    router.pushUrl({ url: 'pages/User/UserLoginPage' })
  }
  // 对响应错误做点什么
  return Promise.reject(error);
});

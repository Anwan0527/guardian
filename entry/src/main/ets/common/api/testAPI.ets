import { axiosInstance, AxiosResponseData } from '../utils'

export function getTestAPI() {
  return axiosInstance.get
  <null, AxiosResponseData<string>, null>
  ('/test')
}

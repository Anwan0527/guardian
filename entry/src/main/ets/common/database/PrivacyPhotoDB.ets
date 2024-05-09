import { relationalStore, ValuesBucket } from '@kit.ArkData'

// 图片和视频文件关键信息。(PhotoKeys)
export interface PrivacyPhotoDBInfo extends ValuesBucket {
  id: number | null // 新增时 id 为 null ，自动生成自增 id
  mediaUri: string // 文件uri
  privacyUri: string // 沙箱文件uri(Image可以渲染uri)
  media_type: number // 媒体文件类型
  date_added: number // 添加日期
}

class PrivacyPhotoDB {
  private store: relationalStore.RdbStore | null = null
  private tableName = 'PRIVACY_PHOTO'
  // 创建数据库的语句
  private sqlCreate = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mediaUri TEXT,
        privacyUri TEXT,
        media_type INTEGER,
        date_added INTEGER
      )`

  async getStoreInstance() {
    // 如果数据库已存在，直接退出
    if (this.store) {
      return this.store
    }
    // 存储 store 方便下次直接获取
    this.store = await relationalStore.getRdbStore(getContext(), {
      name: this.tableName + '.db', // 数据库名称
      securityLevel: relationalStore.SecurityLevel.S4 // 安全等级
    })
    this.store.executeSql(this.sqlCreate)
    // 返回 store 实例
    return this.store
  }

  // 新增
  async insert(value: PrivacyPhotoDBInfo) {
    const store = await this.getStoreInstance()
    const rowId = await store.insert(this.tableName, value)
    return rowId > -1 ? Promise.resolve(rowId) : Promise.reject('insert error')
  }

  // 批量新增
  async batchInsert(values: PrivacyPhotoDBInfo[]) {
    const store = await this.getStoreInstance()
    const rowId = await store.batchInsert(this.tableName, values)
    return rowId ? Promise.resolve(rowId) : Promise.reject('batchInsert error')
  }

  // 更新
  async update(item: PrivacyPhotoDBInfo) {
    if (!item.id) {
      return Promise.reject('id error')
    }
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', item.id)
    const rowCount = await store.update(item, predicates)
    return rowCount ? Promise.resolve(rowCount) : Promise.reject('update error')
  }

  // 删除
  async delete(id: number) {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    const rowCount = await store.delete(predicates)
    return rowCount ? Promise.resolve(rowCount) : Promise.reject('delete error')
  }

  // 批量删除
  async batchDelete(ids: number[]) {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.in('id', ids)
    const rowCount = await store.delete(predicates)
    return rowCount ? Promise.resolve(rowCount) : Promise.reject('delete error')
  }

  // 查询
  async query(id?: number) {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    // 添加日期倒序排列
    predicates.orderByDesc('date_added')
    // 如果有 id
    if (id) {
      predicates.equalTo('id', id)
    }
    const resultSet = await store.query(predicates)
    const list: PrivacyPhotoDBInfo[] = []
    while (resultSet.goToNextRow()) {
      // 获取数据
      const data: PrivacyPhotoDBInfo = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        mediaUri: resultSet.getString(resultSet.getColumnIndex('mediaUri')),
        privacyUri: resultSet.getString(resultSet.getColumnIndex('privacyUri')),
        media_type: resultSet.getLong(resultSet.getColumnIndex('media_type')),
        date_added: resultSet.getLong(resultSet.getColumnIndex('date_added')),
      }
      // 追加到数组中
      list.push(data)
    }
    // 释放资源
    resultSet.close()
    return list
  }

  // 查询数量
  async queryCount() {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    const resultSet = await store.query(predicates)
    return resultSet.rowCount > 0 ? resultSet.rowCount : 0
  }

  // 查询相册封面
  async queryCoverUri() {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.orderByDesc('date_added')
    const resultSet = await store.query(predicates)
    let coverUri = ''
    // 查询第一条数据
    if (resultSet.goToFirstRow()) {
      // 获取封面信息
      coverUri = resultSet.getString(resultSet.getColumnIndex('privacyUri'))
    }
    // 释放资源
    resultSet.close()
    // 返回封面路径
    return coverUri
  }
}

export const privacyPhotoDB = new PrivacyPhotoDB()
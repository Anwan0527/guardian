import { relationalStore, ValuesBucket } from '@kit.ArkData'

// 隐私录音的字段
export interface PrivacyRecorderDBInfo extends ValuesBucket {
  id: number | null // 新增时 id 为 null ，自动生成自增 id
  filePath: string
  title: string
  date_added: number
  duration: number
}

class PrivacyRecorderDB {
  // 管理数据库的对象
  private store: relationalStore.RdbStore | null = null
  // 表名称
  private tableName = 'PRIVACY_RECORDER'
  // 创建数据库的语句
  private sqlCreate = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        filePath TEXT,
        title TEXT,
        date_added INTEGER,
        duration INTEGER
      )`

  // 获取管理数据库的对象
  async getStoreInstance() {
    try {
      // 如果 store 已存在，直接返回 store
      if (this.store) {
        return this.store
      }
      // 获取 store
      const store = await relationalStore.getRdbStore(getContext(), {
        name: this.tableName + '.db', // 数据库文件名，如果文件不存在会自动创建，已存在则不创建
        securityLevel: relationalStore.SecurityLevel.S4 // 安全等级
      })
      // 执行创建表的语句（如果不存在才创建表，已存在则不创建）
      store.executeSql(this.sqlCreate)
      // 存储 store 用于下次快速获取
      this.store = store
      // 返回 store
      return store
    } catch (err) {
      return Promise.reject('initDB error')
    }
  }

  // 新增
  async insert(value: PrivacyRecorderDBInfo) {
    const store = await this.getStoreInstance()
    // 核心代码 insert
    const rowId = await store.insert(this.tableName, value)
    return rowId > -1 ? Promise.resolve(rowId) : Promise.reject('insert error')
  }

  // 更新
  async update(item: PrivacyRecorderDBInfo) {
    if (!item.id) {
      return Promise.reject('id error')
    }
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', item.id)
    // 核心代码 update
    const rowCount = await store.update(item, predicates)
    return rowCount ? Promise.resolve(rowCount) : Promise.reject('update error')
  }

  // 删除
  async delete(id: number) {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    // 核心代码 delete
    const rowCount = await store.delete(predicates)
    return rowCount ? Promise.resolve(rowCount) : Promise.reject('delete error')
  }

  // 查询
  async query(id?: number) {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    // 根据 id 倒序排列（大到小）
    predicates.orderByDesc('id')
    // 如果有 id，添加到条件中
    if (id) {
      predicates.equalTo('id', id)
    }
    // 核心代码 query
    const resultSet = await store.query(predicates)
    const list: PrivacyRecorderDBInfo[] = []
    // 循环结果集，goToNextRow 移动指针到下一行数据
    while (resultSet.goToNextRow()) {
      // 提取数据并追加到数组中
      list.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        filePath: resultSet.getString(resultSet.getColumnIndex('filePath')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        date_added: resultSet.getLong(resultSet.getColumnIndex('date_added')),
        duration: resultSet.getLong(resultSet.getColumnIndex('duration')),
      })
    }
    // 循环结束，关闭结果集，释放内存空间
    resultSet.close()
    // 循环结束，返回结果
    return list
  }

  // 查询数量
  async queryCount() {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    // 核心代码 query
    const resultSet = await store.query(predicates)
    return resultSet.rowCount > 0 ? resultSet.rowCount : 0
  }
}

export const privacyRecorderDB = new PrivacyRecorderDB()
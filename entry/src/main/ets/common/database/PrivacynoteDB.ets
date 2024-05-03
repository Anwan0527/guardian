import { relationalStore, ValuesBucket } from '@kit.ArkData'

export interface PrivacynoteDBInfo extends ValuesBucket {
  id: number | null,
  title: string,
  content: string,
  date_added: number
}

class PrivacynoteDB {
  // 操作数据库的实例
  private store: relationalStore.RdbStore | null = null
  private tableName = 'PRIVACY_NOTE'
  // 创建数据库的语句
  private sqlCreate = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date_added INTEGER NOT NULL
      )`

  //新建数据库
  async getStoreInstance() {
    if (this.store) {
      return this.store
    }
    const store = await relationalStore.getRdbStore(getContext(), {
      name: this.tableName + '.db',
      securityLevel: relationalStore.SecurityLevel.S1
    })
    store.executeSql(this.sqlCreate)
    this.store = store
    return store
  }

  //删除数据库
  deleteStoreInstance() {
    relationalStore.deleteRdbStore(getContext(), this.tableName + '.db')
  }

  //新增数据
  async insert(item: PrivacynoteDBInfo) {
    const store = await this.getStoreInstance()
    const rowId = await store.insert(this.tableName, item)
    return rowId > 0 ? Promise.resolve(rowId) : Promise.reject('insert error ')
  }

  //查询总数
  async queryCount() {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    const resultSet = await store.query(predicates)
    return resultSet.rowCount > 0 ? resultSet.rowCount : 0
  }

  //查询所有/按id查询
  async query(id?: number) {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    if (id) {
      predicates.equalTo('id', id)
    }
    //倒叙
    predicates.orderByDesc('id')
    const resultSet = await store.query(predicates)
    const list: PrivacynoteDBInfo[] = []
    while (resultSet.goToNextRow()) {
      list.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        content: resultSet.getString(resultSet.getColumnIndex('content')),
        date_added: resultSet.getLong(resultSet.getColumnIndex('date_added'))
      })
    }
    resultSet.close() //释放
    return list
  }

  //更新数据
  async update(item: PrivacynoteDBInfo) {
    if (!item.id) {
      return Promise.reject('id is null')
    }
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', item.id)
    const rowId = await store.update(item, predicates)

    return rowId ? Promise.resolve() : Promise.reject('updatae error')
  }

  //删除数据
  async delete(id: number) {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    const rowId = await store.delete(predicates)
    return rowId ? Promise.resolve() : Promise.reject('delete error')
  }
}

export const privacynoteDB = new PrivacynoteDB()
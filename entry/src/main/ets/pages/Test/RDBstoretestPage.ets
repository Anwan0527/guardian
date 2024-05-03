import { relationalStore, ValuesBucket } from '@kit.ArkData'
import { privacynoteDB } from '../../common/database'

interface privacyNoteInfo extends ValuesBucket {
  id: number | null,
  title: string,
  content: string,
  date_added: number
}

@Entry
@Component
struct RDBstoretestPage {
  private tableName = 'PRIVACY_NOTE'
  // 创建数据库的语句
  private sqlCreate = `CREATE TABLE IF NOT EXISTS ${this.tableName} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date_added INTEGER NOT NULL
      )`

  ///查询
  async getColumnNames() {
    //数据库管理都西昂
    const store = await this.getStoreInstance()
    //条件
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    //结果集
    const resultSet = await store.query(predicates)
    AlertDialog.show({
      message: JSON.stringify(resultSet.columnNames)
    })
  }

  //查询总条数
  async getCount() {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    const resultSet = await store.query(predicates)
    AlertDialog.show({
      message: '' + resultSet.columnCount
    })
  }

  //根据id查一条
  async queryOne(id: number) {
    if (!id) {
      AlertDialog.show({
        message: '请传入id'
      })
      return
    }
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    // predicates.like('id', id.toString())
    const resultSet = await store.query(predicates)
    const list: privacyNoteInfo[] = []
    while (resultSet.goToNextRow()) {
      list.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        title: resultSet.getString(resultSet.getColumnIndex('title')),
        content: resultSet.getString(resultSet.getColumnIndex('content')),
        date_added: resultSet.getLong(resultSet.getColumnIndex('date_added'))
      })
      AlertDialog.show({
        message: JSON.stringify(list)
      })
    }
  }

  //删除->按id
  async delete(id: number) {
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', id)
    const rowCount = await store.delete(predicates)
    AlertDialog.show({
      message: JSON.stringify(rowCount)
    })
  }

  //查询全部
  async getAll() {
    const list: privacyNoteInfo[] = []
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.orderByDesc('id') //倒叙
    const resultSet = await store.query(predicates)
    while (resultSet.goToNextRow()) {
      const id = resultSet.getLong(resultSet.getColumnIndex('id'))
      const title = resultSet.getString(resultSet.getColumnIndex('title'))
      const content = resultSet.getString(resultSet.getColumnIndex('content'))
      const date_added = resultSet.getLong(resultSet.getColumnIndex('date_added'))
      list.push({ id, title, content, date_added })
    }
    AlertDialog.show({
      message: JSON.stringify(list, null, 2)
    })
  }

  //更新数据
  async update(item: privacyNoteInfo) {
    if (!item.id) {
      return Promise.reject('need id')
    }
    const store = await this.getStoreInstance()
    const predicates = new relationalStore.RdbPredicates(this.tableName)
    predicates.equalTo('id', item.id)
    const rowCount = await store.update(item, predicates)
    AlertDialog.show({
      message: '受影响' + rowCount
    })
    return rowCount
  }

  //增填
  async insert(value: privacyNoteInfo) {
    try {
      const store = await this.getStoreInstance()
      const id = await store.insert(this.tableName, value)
      AlertDialog.show({
        message: 'id' + id
      })
    } catch (e) {
      AlertDialog.show({
        message: e
      })
    }
  }

  build() {
    Row() {
      Column({ space: 10 }) {
        Button('创建')
          .onClick(() => {
            privacynoteDB.getStoreInstance()
          })
        Button('删除')
          .onClick(() => {
            this.deleteStoreInstance()
          })
        Button('查询')
          .onClick(async () => {
            const list = await privacynoteDB.query()
            AlertDialog.show({
              message: JSON.stringify(list)
            })
          })
        Button('查询id=1')
          .onClick(async () => {
            const list = await privacynoteDB.query(1)
            AlertDialog.show({
              message: JSON.stringify(list)
            })
          })
        Button('查询总条数')
          .onClick(async () => {
            const num = await privacynoteDB.queryCount()
            AlertDialog.show({
              message: '' + num
            })
          })
        Button('删除->id')
          .onClick(() => {
            privacynoteDB.delete(1)
          })
        Button('更新数据->id')
          .onClick(() => {
            privacynoteDB.update({
              id: 2,
              title: '大傻逼陈秋龙',
              content: '陈秋龙No,1 bull of shit',
              date_added: Date.now()
            })
          })
        Button('添加')
          .onClick(() => {
            privacynoteDB.insert({
              id: null,
              title: '傻逼陈秋龙',
              content: '陈秋龙傻逼',
              date_added: Date.now()
            })
          })
      }
      .width("100%")
    }
    .height("100%")
    .align(Alignment.Center)
  }

  //创建数据库对象
  async getStoreInstance() {
    const store = await relationalStore.getRdbStore(getContext(), {
      name: 'test.db',
      securityLevel: relationalStore.SecurityLevel.S1
    })
    //执行创造语句
    store.executeSql(this.sqlCreate)
    return store
  }

  //删除
  deleteStoreInstance() {
    relationalStore.deleteRdbStore(getContext(), 'test.db')
  }
}
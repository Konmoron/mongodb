# mongodb使用总结

----

## 创建库

在mongodb中，直接使用`use database-name`即可创建数据库。

例如，如果想想创建名字为`test`的数据库：

```
use test
```

## 删除库

删除数据库，需要进入到该数据库，然后执行`db.dropDatabase()`命令。

例如，想删除`test`数据库：

```
use test

db.dropDatabase()
```

得到如下回馈：

```
{ "ok" : 1 }
```

## 创建用户

mongodb的用户和数据库紧密相连，每个数据库的用户都是相互独立的，当然，admin账户可以管理所有的数据库。

因此要创建账户，首先要进入到该账户所属的数据库，比如，想在`test`库里面创建用户名为`testuser`，密码为`password`的用户，具体的方法如下：

```
use test

db.createUser(
  {
    user: "testuser",
    pwd: "password",
    roles: [
        { role: "dbAdmin", db: "test1" },
        { role: "readWrite", db: "test1" } ]
  }
)
```

得到如下回馈说明添加成功：

```
Successfully added user: {
	"user" : "testuser",
	"roles" : [
		{
			"role" : "dbAdmin",
			"db" : "test1"
		},
		{
			"role" : "readWrite",
			"db" : "test1"
		}
	]
}
```

为`testuser`授权：

```
db.auth("testuser", "password")
```

## 查看用户

假设想查看`test`库里面的用户：

```
use test

show users
```

得到如下结果：

```
{
	"_id" : "test.testuser",
	"user" : "testuser",
	"db" : "test",
	"roles" : [
		{
			"role" : "dbAdmin",
			"db" : "test1"
		},
		{
			"role" : "readWrite",
			"db" : "test1"
		}
	],
	"mechanisms" : [
		"SCRAM-SHA-1",
		"SCRAM-SHA-256"
	]
}
```

为`testuser`授权：

```
db.auth("testuser", "password")
```

## 修改用户密码

假设要修改`test`库的`testuser`用户的密码：

```
use test

db.changeUserPassword("testuser", "password2")
```

## 删除用户

假设要删除`test`库的`testuser`：

```
use test

db.dropUser("testuser")
```
# mongodb初始化

----

mongodb安装完毕之后，需要进行初始化：

- 创建admin用户
- 设置auth

## 创建admin用户

mongodb安装完毕之后，使用`mongo 127.0.0.1:27017`命令，进入mongodb的shell界面。

1 进入admin库

```
use admin
```

2 创建管理员账户

```
db.createUser({
    user:"admin",
    pwd:"passwd",
    roles:[{
        role:"root",
        db:"admin"
    }]
})
```

得到如下结果：

```
Successfully added user: {
	"user" : "admin",
	"roles" : [
		{
			"role" : "root",
			"db" : "admin"
		}
	]
}
```

为`admin`用户授权：

```
db.auth("admin", "passwd")
```

## 设置auth

使用`vim`编辑mongodb的配置文件（配置文件的位置：`mongodb的安装目录/conf/mongodb.conf`），在配置文件的末尾增加：

```
security:
  authorization: enabled
```

修改之后的配置文件为：

```
systemLog:
  destination: file
  path: "/data/apps/mongodb/data/log/mongod.log"
  logAppend: true
storage:
  journal:
    enabled: true
  dbPath: "/data/apps/mongodb/data/db"
  mmapv1:
    smallFiles: true
processManagement:
  fork: true
net:
  bindIp: 0.0.0.0
  port: 27017
security:
  authorization: enabled
```

之后，重启mongodb即可：

```
systemctl restart mongodb
```
# 创建admin用户
db.createUser({
    user:"admin",
    pwd:"JfdR(cBD[s-%%RFC",
    roles:[{
        role:"root",
        db:"admin"
    }]
})

# 验证是否添加成功
db.auth("admin", "passwd")

# 使用test库，如果没有，mongodb会自动创建
use test

# 创建普通用户
db.createUser(
  {
    user: "testuser",
    pwd: "password",
    roles: [ { role: "dbAdmin", db: "test1" },
             { role: "dbAdmin", db: "test2" } ]
  }
)

db.auth("testuser", "password")

# 创建其他超级管理权限
db.createUser({
  user: "username",
  pwd: "password",
  roles: [
    {
      role:"readWriteAnyDatabase", db:"admin"
    }
  ]
})

db.auth("****", "****")

# 修改用户名密码
db.changeUserPassword('user','newpasswd'); 



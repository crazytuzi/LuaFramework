--
--
-- @authors shan
-- @date    2014-05-06 17:43:21
-- @version
-- @desc: 添加网络相关定义字段

MSG_HEAD = {

name = "wx",
build = "appstore",
version = "100",
pid = "",
did = ""
}


--
MSG_KEY = {
MSG_ID = "m",
MSG_DATA = "d",
MSG_TYPE = "t",
}

--
MSG_ID = {
usr = "usr",
battle   = "battle",
login    = 3,
}

-- 战斗消息
MSG_BATTLE = {
init   = 1, -- 初始化
talent = 2, -- 天赋
skill  = 3, -- 技能（包括普通攻击，技能攻击）
buff   = 4, -- buff/debuff
result = 9, -- 结果
}


-- -------------------
-- 聊天协议数据
-- -------------------
ChatData = ChatData or BaseClass()

function ChatData:__init()
    self.channel = 0  -- 频道
    self.rid = 0 -- 角色id
    self.platform = "" -- 平台
    self.zone_id = 0 -- 区号
    self.name = "" -- 名字
    self.sex = 0 -- 性别
    self.classes = 0 -- 职业
    self.lev = 0
    self.msg = "" -- 内容
    self.special = nil -- 特殊信息
    self.prefix = 0
    self.msgData = nil
    self.extraData = nil
    self.guild_name = ""
    self.text = ""

    self.cacheId = 0 -- 语音缓存Id
    self.time = 0 -- 语音时长
    -- 展示类型
    self.showType = MsgEumn.ChatShowType.Normal

    -- 私聊标志是否是自己
    self.isself = false
end

function ChatData:Update(proto)
    for k,v in pairs(proto) do
        self[k] = v
    end
end
-- ---------------------------------------
-- 消息枚举
-- hosr
-- ---------------------------------------
MsgEumn = MsgEumn or {}

-- 频道
MsgEumn.ChatChannel = {
    Mix = 0, -- 综合
    World = 1, -- 世界
    Team = 2, -- 队伍
    Scene = 3,-- 场景
    Guild = 4, -- 公会
    Private = 5, -- 私聊
    Bubble = 6, -- 场景冒泡
    Danmaku = 7, -- 弹幕
    MixWorld = 8, -- 跨服世界
    Group = 9, -- 群聊
    Activity = 10, -- 群聊
    Activity1 = 11, --天启
    Camp = 12,  --联盟/部落
    Hearsay = 100, -- 传闻
    System = 101, -- 系统
    Answer = 102, -- 抢答
    CrossVoice = 103, -- 传声
}

MsgEumn.ChatChannelName = {
    [MsgEumn.ChatChannel.Mix] = TI18N("综合"),
    [MsgEumn.ChatChannel.World] = TI18N("世界"),
    [MsgEumn.ChatChannel.Team] = TI18N("队伍"),
    [MsgEumn.ChatChannel.Scene] = TI18N("场景"),
    [MsgEumn.ChatChannel.Guild] = TI18N("公会"),
    [MsgEumn.ChatChannel.Private] = TI18N("私聊"),
    [MsgEumn.ChatChannel.Group] = TI18N("群聊"),
    [MsgEumn.ChatChannel.Hearsay] = TI18N("传闻"),
    [MsgEumn.ChatChannel.System] = TI18N("系统"),
    [MsgEumn.ChatChannel.MixWorld] = TI18N("跨服"),
    [MsgEumn.ChatChannel.Danmaku] = TI18N("弹幕"),
    [MsgEumn.ChatChannel.Answer] = TI18N("抢答"),
    [MsgEumn.ChatChannel.Activity] = TI18N("龙王"),
    [MsgEumn.ChatChannel.Activity1] = TI18N("天启"),
    [MsgEumn.ChatChannel.Camp] = TI18N("峡谷"),
}

MsgEumn.ChannelColor = {
    [MsgEumn.ChatChannel.Mix] = "#3cf6fd"
    ,[MsgEumn.ChatChannel.World] = "#23f0f7"
    ,[MsgEumn.ChatChannel.Team] = "#ed84f1"
    ,[MsgEumn.ChatChannel.Scene] = "#ffffff"
    ,[MsgEumn.ChatChannel.Guild] = "#2cf844"
    ,[MsgEumn.ChatChannel.Hearsay] = "#f5f70e"
    ,[MsgEumn.ChatChannel.System] = "#f5f70e"
    ,[MsgEumn.ChatChannel.MixWorld] = "#3cf6fd"
    ,[MsgEumn.ChatChannel.Private] = "#3cf6fd"
    ,[MsgEumn.ChatChannel.Group] = "#3cf6fd"
    ,[MsgEumn.ChatChannel.Danmaku] = "#ffffff"
    ,[MsgEumn.ChatChannel.Answer] = "#ffffff"
    ,[MsgEumn.ChatChannel.Activity] = "#3cf6fd"
    ,[MsgEumn.ChatChannel.Activity1] = "#3cf6fd"
    ,[MsgEumn.ChatChannel.Camp] = "#3cf6fd"
    ,[MsgEumn.ChatChannel.CrossVoice] = "#f5f70e"
}

-- 消息提示类型
MsgEumn.NoticeType = {
    Float = 1, -- 上浮
    Confirm = 2, -- 确认框
    Danmaku = 3, -- 弹幕
    Scroll = 4, -- 滚动
    NormalDanmaku = 13, -- 一般弹幕
}

-- 输入类型
MsgEumn.InputType = {
    Text = 1,
    Voice = 2
}

-- 缓存类型
MsgEumn.CacheType = {
    Item = 1,
    Pet = 2,
    Equip = 3,
    Guard = 4,
    Wing = 5,
    Ride = 6,
    Child = 7,
    WorldChampion = 8, --武道战绩
    Group = 9, --群组
    Talisman = 10, --法宝
}

-- 聊天面板展示类型
MsgEumn.ChatShowType = {
    Normal = 1, -- 玩家聊天
    System = 2, -- 系统提示
    Match = 3, -- 队伍招募
    Voice = 4, -- 语音消息
    Shiping = 5, -- 远航求助
    Redpack = 6, -- 红包
    RedpackNotice = 7, -- 红包提示
    Water = 8, -- 邀请浇水
    QuestHelp = 9, -- 任务求助
    TrialHelp = 10, -- 极寒求助
    MatchWorld = 11, -- 招募世界提示
    TeamDungeon = 12, -- 组队副本招募
    CrossArena = 13, -- 跨服约战招募
}

MsgEumn.AppendElementType = {
    Bag = 1, -- 道具
    Pet = 2, -- 宠物
    Quest = 3, -- 任务
    Friend = 4, -- 好友
    String = 5, -- 便捷用语
    Face = 6, -- 表情
    Equip = 7, -- 装备
    Guard = 8, -- 守护
    Wing = 9, -- 翅膀
    Ride = 10, -- 坐骑
    Prefix1 = 11, -- 前缀@
    Child = 12, -- 孩子
    Talisman = 13, -- 法宝
    CrossArena = 14, -- 跨服约战招募
}

MsgEumn.ExtPanelType = {
    Chat = 1,
    Friend = 2,
    Zone = 3,
    Group = 4,
    Other = 0, -- 其它类型只有表情
    PetEvaluation = 5,
}

-- 频道等级限制
MsgEumn.ChannelLimit = {
    [MsgEumn.ChatChannel.Mix] = 0
    ,[MsgEumn.ChatChannel.World] = 20
    ,[MsgEumn.ChatChannel.MixWorld] = 40
    ,[MsgEumn.ChatChannel.Team] = 0
    ,[MsgEumn.ChatChannel.Scene] = 15
    ,[MsgEumn.ChatChannel.Guild] = 0
    ,[MsgEumn.ChatChannel.Hearsay] = 0
    ,[MsgEumn.ChatChannel.System] = 0
    ,[MsgEumn.ChatChannel.Private] = 0
    ,[MsgEumn.ChatChannel.Group] = 0
    ,[MsgEumn.ChatChannel.Activity] = 0
    ,[MsgEumn.ChatChannel.Activity1] = 0
    ,[MsgEumn.ChatChannel.Camp] = 0
}

-- 频道冷却时间
MsgEumn.ChannelCooldown = {
    [MsgEumn.ChatChannel.Mix] = 0
    ,[MsgEumn.ChatChannel.World] = 30
    ,[MsgEumn.ChatChannel.MixWorld] = 30
    ,[MsgEumn.ChatChannel.Team] = 0
    ,[MsgEumn.ChatChannel.Scene] = 5
    ,[MsgEumn.ChatChannel.Guild] = 0
    ,[MsgEumn.ChatChannel.Hearsay] = 0
    ,[MsgEumn.ChatChannel.System] = 0
    ,[MsgEumn.ChatChannel.Private] = 0
    ,[MsgEumn.ChatChannel.Activity] = 30
    ,[MsgEumn.ChatChannel.Activity1] = 30
    ,[MsgEumn.ChatChannel.Camp] = 30      
}

-- 聊天协议特殊参数
MsgEumn.SpecialType = {
    Picture = 1, -- 空间照片
    Bubble = 2, -- 气泡样式
    label = 3, -- 是Gm
    Frame = 4, -- 是边框
    SingRank = 5, -- 好声音排名
    SingEndTime = 6, -- 好声音时间
    LevBreak = 7, -- 突破次数
    godswar = 8, --诸神之战
    prefix = 9, --聊天前缀
}

-- 甩子
MsgEumn.Roll = {
    [1] = 5,
    [2] = 9,
    [3] = 3,
    [4] = 11,
    [5] = 7,
    [6] = 1,
}

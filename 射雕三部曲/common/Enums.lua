--[[
    文件名：Enums.lua
    描述：枚举类型定义文件，可能被多个地方引用的枚举类型
    创建人：heguanghui
    创建时间：2015.4.13
-- ]]

require("data.Language")
require("Config.EnumsConfig")

-- 游戏内枚举类型定义
Enums = {}

-- 网络请求timeout
Enums.TimeoutType = {
    eRetry = 1,         -- 超时重试
    eNotice = 2,        -- 超时仅提示
    eIgnore = 3,        -- 超时不处理
}

-- 阵营
Enums.HeroRace = {
    eRace0 = 0, -- 江湖
    eRace1 = 1, -- 射雕
    eRace2 = 2, -- 神雕
    eRace3 = 3, -- 倚天
}

-- 头像卡牌到形状
Enums.CardShape = {
    eSquare = 1, -- 四边形
    eCircle = 2, -- 圆形
    eHexagon = 3, -- 六边形
}

-- 人物的类型
Enums.HeroType = {
    eNormalHero = 0, -- 普通人物
    eBossHero = 1, -- 怪物
    eMainHero = 255, -- 主角人物
}

--自定义选择类型：refine.SelectLayer 使用
Enums.SelectType = {
    eResolve = 1,         -- 分解: 限制5个，已经进阶和升级的显示在后面并且不可选
    eRebirth = 2,         -- 重生: 限制1个，升级或进阶过，不符合条件的不显示
    eEquipCompare = 3,    -- 装备合成: 限制5件，只能选择同品质
    eTreasureCompare = 4, -- 神兵合成: 限制5件，只有紫色
    eEquipStarUp = 5,     -- 装备升星
    eTreasureLvUp = 6,    -- 神兵强化：强化过的可以选 进阶过的不行 不包括已上阵的
    eTreasureStepUp = 7,  -- 神兵进阶
    ePetCompare = 8,      -- 外功秘籍合成
    ePetRebirth = 9,      -- 外功秘籍涅槃
    eHeroConversion = 10, -- 大侠之魂转化
}

-- 游戏内zOrder定义
Enums.ZOrderType = {
    eDefault        = 0x00, -- 默认zorder
    eWeakPop        = 0x80, -- 低于聊天的弹出
    eChat           = 0x90, -- 聊天按钮
    ePopLayer       = 0xA0, -- 弹出式全屏界面
    eMessageBox     = 0xB0, -- MessageBoxLayer
    eDrapReward     = 0xB1, -- 系统掉落界面
    eLevelUp        = 0xB2, -- 升级界面
    eNewbieGuide    = 0xC0, -- 新手引导
    eNetErrorMsg    = 0xD0, -- 网络错误MessageBoxLayer
    eWaiting        = 0xE0, -- 网络请求等待
    eAnnounce       = 0xFF, -- 公告网页，尽量保持在最高层次
}

-- 常用颜色类型
Enums.Color = {
    -- ================ 物品品质的颜色 ===============
    -- 白色
    eWhite = cc.c3b(0xF7, 0xF5, 0xF0),
    eWhiteH = "#F7F5F0",
    -- 绿色
    eGreen = cc.c3b(0x9B, 0xFF, 0x6A),
    eGreenH = "#9BFF6A",
    -- 蓝色
    eBlue = cc.c3b(0x60, 0xD8, 0xFF),
    eBlueH = "#60D8FF",
    -- 紫色
    ePurple = cc.c3b(0xFF, 0x66, 0xF3),
    ePurpleH = "#FF66F3",
    -- 橙色
    eOrange = cc.c3b(0xFF, 0x97, 0x4A),
    eOrangeH = "#FF974A",
    -- 红色
    -- eRed = cc.c3b(0xFF, 0x58, 0x67),
    -- eRedH = "#FF5867",
    eRed = cc.c3b(0xFF, 0x4A, 0x46),
    eRedH = "#FF4A46",
    -- 金色
    eGold = cc.c3b(0xFF, 0xE7, 0x48),
    eGoldH = "#FFE748",
    -- 暗金色
    eDullGold = cc.c3b(0xFF, 0xED, 0x4C),
    eDullGoldH = "#FFED4C",

    -- ================ 常用按钮文字颜色 =================
    -- 阴影的颜色
    eShadowColor = cc.c3b(0x1D, 0x1D, 0x1D),
    -- 描边的颜色
    eOutlineColor = cc.c3b(0x6b, 0x48, 0x2b),

    -- 羁绊未激活颜色（浅棕色）
    eNotPrColor = cc.c3b(0x62, 0x70, 0x80),
    eNotPrColorH = "#627080",

    -- 羁绊激活颜色(棕色)
    ePrColor = cc.c3b(0x46, 0x22, 0x0d),
    ePrColorH = "#46220D",

    -- 通用按钮颜色(白色)
    eBtnText = cc.c3b(0xFF, 0xFF, 0xFF),
    eBtnTextH = "#FFFFFF",

    -- 白色 tabView控件切换按钮选择的颜色
    eBtnSelect = cc.c3b(0xFF, 0xFF, 0xFF),
    eBtnSelectH = "#FFFFFF",
    -- 白色 tabView控件切换按钮未选择的颜色
    eBtnNormal = cc.c3b(0xFF, 0xFF, 0xFF),
    eBtnNormalH = "#FFFFFF",

    -- ================ 常用 Label 显示文字颜色 ==========
    -- 常用的白色（纯白色，深色背景上label使用的颜色）
    eNormalWhite = cc.c3b(0xFF, 0xFF, 0xFF),
    eNormalWhiteH = "#FFFFFF",

    -- 常用黄色（棕黄色， 深色背景上label使用的颜色）
    eNormalYellow = cc.c3b(0xD1, 0x7B, 0x00),
    eNormalYellowH = "#D17B00",

    -- 常用绿色
    eNormalGreen = cc.c3b(0x25, 0x87, 0x11),
    eNormalGreenH = "#258711",

    -- 常用蓝色（浅蓝色，深色背景上label使用的颜色）
    eNormalBlue = cc.c3b(0x90, 0xC7, 0xFF),
    eNormalBlueH = "#90C7FF",


    -- =================== 即将废弃的颜色定义 ==============
    -- 棕色(即将废弃) 黄底背景的描述文字颜色
    eBrown = cc.c3b(0x73, 0x43, 0x0D),
    eBrownH = "#73430D",
    -- 深绿色(即将废弃) 黄底背景的描述文字高亮颜色
    eDarkGreen = cc.c3b(0x06, 0x70, 0x2E),
    eDarkGreenH = "#06702E",

    -- 咖啡色(即将废弃) 物品信息的属性类型的标题色号
    eCoffee = cc.c3b(0x9B, 0x4C, 0x23),
    eCoffeeH = "#9B4C23",

    -- 浅黄色(即将废弃) 黑底背景或深蓝色背景使用的描述文字颜色
    eLightYellow = cc.c3b(0xFF, 0xEA, 0x97),
    eLightYellowH = "#FFEA97",

    -- 黑色(即将废弃)
    eBlack = cc.c3b(0x59, 0x28, 0x17),
    eBlackH = "#49381F",

    -- 灰色(即将废弃)
    eGrey = cc.c3b(0x58, 0x50, 0x45),
    eGreyH = "#585045",

    -- 深蓝色(即将废弃)
    eMazarine = cc.c3b(0x00, 0xFF, 0xFC),
    eMazarineH = "#00FFFC",

    -- 黄色(即将废弃)
    eYellow = cc.c3b(0xF6, 0xD9, 0x08),
    eYellowH = "#F6D908",

    -- =================== 后续添加颜色 ==============
    --金黄色
    eGlodenYellow = cc.c3b(0xFF, 0xE5, 0x69),
    eGlodenYellowH = "#FFE569",
    --酒红色
    eWineRed = cc.c3b(0x80, 0x10, 0x0E),
    eWineRedH = "#80100E",
    --天蓝色
    eSkyBlue = cc.c3b(0x03, 0xE3, 0xF1),
    eSkyBlueH = "#03E3F1",

    -- ==================== 白色背景板颜色 =============
    --黑色
    eBlackInWhite = cc.c3b(0x59, 0x28, 0x17),
    eBlackInWhiteH = "#592817",

    --黄色
    eOrangeInWhite = cc.c3b(0xD1, 0x7B, 0x00),
    eOrangeInWhiteH = "#D17B00",

    --绿色
    eGreenInWhite = cc.c3b(0x24, 0x90, 0x29),
    eGreenInWhiteH = "#249029",

    --红色
    eRedInWhite = cc.c3b(0xFE, 0x1C, 0x46),
    eRedInWhiteH = "FE1C46",

}

-- 常用的字体
Enums.Font = {
    eDefault = "DFYuanUBold-B5.ttf", -- "Helvetica-Bold", -- 默认字体 --
    eHelveticaBlod = "Helvetica-Bold", -- 黑体粗体
}

-- 常用字体大小
Enums.Fontsize = {
    eDefault = 22, -- 默认字体大小
    eBtnDefault = 24, -- 按钮上文字的默认大小
    eTitleDefault = 27, -- 窗体标题文字的默认大小
}

-- 副本宝箱类型
Enums.BattleBoxType = {
    eStarBox = 1, --星级宝箱
    eRoadBox = 2, --地下宝箱
}

-- 副本节点类型
Enums.BattleNodeType = {
    eNormal = 0, -- 普通关卡
    eElite = 1, -- 精英关卡
    eBoss = 2, -- boss关卡
}

-- 奖励的状态
Enums.RewardStatus = {
    eNotAllow = 0, -- 不能领取
    eAllowDraw = 1, -- 可以领取
    eHadDraw = 2, -- 已领取
}

-- 副本节点的状态
Enums.BattleNodeStatus = {
    eLocked = 0,    --未解锁
    eUnlock = 1,    --可挑战
    ePass = 2,      --已通过
}

--副本剧情类型
Enums.BattleGuideType = {
    eNoGuide = 0,       --没有剧情
    eWholeGuide = 1,    --全剧情
    eHalfGuide = 2,     --半剧情
}

--副本挑战使用资源类型(用于服务端通信协议)
Enums.BattleFightUse = {
    eUseGoods = 2,
    eUseDiamond = 3,
}

-- 在线奖励状态
Enums.OnlineRewardStatus = {
    eGetSvrData = 0,  -- 需要获取服务器数据
    eHaveInfo = 1,  -- 已有服务器数据，并且有在线奖励
    eFinish = 2,  -- 已有服务器数据，在线奖励已结束
}

-- 限时赏金状态
Enums.TimeLimitStatus = {
    eGetSvrData = 0,  -- 需要获取服务器数据
    eHaveInfo = 1,  -- 已有限时赏金数据
    eNoneInfo = 2,  -- 没有限时赏金数据
}

-- 物品与上阵人物的羁绊状态
Enums.RelationStatus = {
    eNone = 0, -- 没有任何搭配
    eIsMember = 1, -- 有搭配，但没有激活
    eSame = 2, -- 有相同人物上阵
    eBattle = 3, -- 已上阵
    eTriggerPr = 4, -- 激活羁绊
}

-- 西漠主队副本的状态
Enums.TeamBattleStatus = {
    eNone = 0, -- 没有组队相关信息
    eHelp = 1, -- 助阵
    eTeam = 2, -- 组队
}

-- 聊天频道的定义
Enums.ChatChanne = {
    eWorld = 11, -- 世界频道
    eTeam = 12, -- 组队频道
    eUnion = 13, -- 公会频道
    eGuide = 14, -- 帮派频道(江湖杀势力频道)
    ePrivate = 15, -- 私聊频道
    eCrossServer = 16, -- 跨服频道
    eHorn = 17, -- 跨服+走马灯频道
    eSystem = 21, -- 系统频道
    eAvatar = 22, -- Avatar频道
    eGM = 23, --  GM频道

    -- 客户端自定义的频道
    eGodDomain = 100, -- 神域战场聊天
    eBlackList = 101, -- 黑名单

    eUnknown = 10000, -- 未知频道
}

-- 聊天频道名称
Enums.ChatChanneName = {
    [Enums.ChatChanne.eWorld] = TR("本服"),
    [Enums.ChatChanne.eTeam] = TR("组队"),
    [Enums.ChatChanne.eUnion] = TR("帮派"),
    [Enums.ChatChanne.ePrivate] = TR("好友"),
    [Enums.ChatChanne.eCrossServer] = TR("跨服"),
    [Enums.ChatChanne.eHorn] = TR("喇叭"),
    [Enums.ChatChanne.eSystem] = TR("系统"),
    [Enums.ChatChanne.eAvatar] = TR("Avatar"),
    [Enums.ChatChanne.eGM] = TR("GM"),
    [Enums.ChatChanne.eGuide] = TR("势力"),

    -- 客户端自定义的频道
    [Enums.ChatChanne.eGodDomain] = TR("湖畔竞赛"),
}

-- 聊天消息类型
Enums.ChatCmdType = {
    eLogin = 1, -- 登陆
    eLogout = 2, -- 登出
    eSendMsg = 3, -- 发送消息
    eUpdatePlayerInfo = 4, -- 更新玩家信息
}

-- 聊天系统消息类型
Enums.ChatSystemType = {
    eOnline = 1,        -- 玩家上线消息
    eBattleTeam = 2,    -- 守卫襄阳
    eExpedition = 4,    -- 组队副本
    eWorldRedPack = 5,  -- 世界红包信息
    eGuildRedPack = 6,  -- 帮派红包信息
    eJHkInvite = 7,     -- 江湖杀邀请信息
}

-- 聊天内容输入的模式
Enums.ChatInputMode = {
    textInput = 1, -- 文本输入模式
    voiceInput = 2, -- 语音输入模式
    voiceTextInput = 3, -- 语音输入并需要转化为文字的模式
}

-- ==================== 子页面类型相关枚举 ==================
-- 好友页面分页类型
Enums.FriendPageType = {
    eList = 1,       -- 好友列表
    eRecommend = 2,  -- 推荐好友
    eGetSTA = 3,     -- 领取耐力
}

-- 炼化页面分页类型
Enums.DisassemblePageType = {
    eRefine = 1, -- 分解页面
    eRebirth = 2,  -- 重生招募
    eCompare = 3,  -- 合成页面
    eConversion = 4,  -- 大侠转化
}

-- 页面主导航枚举类型
Enums.MainNav = {
    eHome = 1, -- 首页
    eFormation = ModuleSub.eFormation,  -- 队伍
    eBattle = ModuleSub.eBattle,      -- 副本
    eChallenge = ModuleSub.eChallenge, -- 挑战
    ePractice = ModuleSub.ePractice,  -- 修练
    eStore = ModuleSub.eStore      -- 商店
}

-- 成就奖励页面分页类型
Enums.AchivementType = {
    eActive = 1,              -- 活跃达人
    ePractice = 2,            -- 修炼达人
    eChallenge = 3,           -- 挑战达人
    eCulture = 4,             -- 培养达人
    eConsumption = 5          -- 消费达人
}

-- 标准页面常用控件位置类型(统一创建在StdLayer中)
Enums.StardardRootPos = {
    eCloseBtn = cc.p(594, 1040),            -- 标准大小页面关闭按钮
    eTabView = cc.p(320, 1024)              -- 标准大小页面中控件父页面的TabView(控件属性采用默认值)
}

-- 随机名字配置文件
Enums.RandomName = {
    name1 = "random_name1.txt",
    name2 = "random_name2.txt",
}

-- 决战桃花岛宝箱分类
Enums.ShengyuanWarsChestType = {
    ePersonal = 1,  -- 个人
    eGuild = 2      -- 帮派
}

-- 客户端使用的综合小红点列表(ID从20000起)
Enums.ClientRedDot = {
    eHomeShop = 20001,  -- 首页聚宝阁
    eHomeMore = 20002,  -- 首页更多按钮
    eBattleNormalMore = 20003,  -- 关卡界面+按钮
    eDisassemble = 20004,       -- 分解标签(装备分解和内功分解)
    eHomePractice = 20005,  -- 首页更多按钮

    eTeamHeader = 20011,        -- 阵容头像
    eTeamOneKeyEquip = 20012,   -- 阵容一键装备
    eTeamTrain = 20013,         -- 阵容培养
    eTeamOneKeyZhenJue = 20014, -- 阵容更优阵决
    eTeamEquipMaster = 20015,   -- 阵容装备共鸣(包括锻造和升星)
    eTeamBtnZhenyuan = 20016,   -- 阵容里的真元切换按钮
    eTeamOneKeyZhenyuan = 20017,-- 阵容里的真元一键装备
    eTeamZhenjue = 20018,       -- 阵容里的内功心法按钮

    eGuildPostChange = 20021,   -- 职务任免
    eGuildBuildingUp = 20022,   -- 建筑升级
    eGuildMemberIn = 20023,     -- 人员审核
    eGuildMana = 20024,         -- 帮派管理

    eBagHeroAndDebris = 20031, --包裹中的人物页签
    eBagPetAndZhenJue = 20032, --包裹中的武学页签
    eBagEquipAndDebris = 20033, --包裹中的装备页签

    ePvpTop = 20041,            --一统武林下注和膜拜
}

-- 兑换物品的消耗资源（没有相应的ID和图标）自己定义(ID从10000起)
Enums.ExchangeGoodsID = {
    eZhenyuan = 10000,
    eJHKVoucher = 10001,
}

-- 音效类型
Enums.MusicType = {
    eML = 1,  -- 国语
    eHK = 2,  -- 港台
}

-- 客户端自用模块（没有相应的模块id）自己定义(ID从100000起)
Enums.ClientModuld = {
    eStudy = 100000,    -- 聊天切磋
}

-- 江湖杀势力
Enums.JHKCampType = {
    eZhongli = 0,
    eWulinmeng = 1,
    eHuntianjiao = 2,
}
Enums.JHKCampName = {
    [Enums.JHKCampType.eZhongli] = TR("中立"),
    [Enums.JHKCampType.eWulinmeng] = TR("武林盟"),
    [Enums.JHKCampType.eHuntianjiao] = TR("浑天教"),
}
--江湖杀人物状态枚举
Enums.JHKPlayerStatus = {
    eNormal = 0,    --一般状态
    eOccupy = 1,    --占点中
    eMoving = 2,    --移动中
}
--江湖杀城池状态
Enums.JHKCityStatus = {
    eNeutral = 0,    --中立可以占领状态
    eProtect = 1,    --保护不可占领状态
    eOccupy = 2,    --一般已被占领状态
}
--江湖杀状态
Enums.JHKOpenStatus = {
    eOpen = 1,  --开启
    eClose = 2, --关闭
    eRest = 3, --休息
}

--江湖杀势力标识图片
Enums.JHKBigPic = {
    [Enums.JHKCampType.eWulinmeng] = "jhs_114.png",
    [Enums.JHKCampType.eHuntianjiao] = "jhs_115.png",
}
Enums.JHKSamllPic = {
    [Enums.JHKCampType.eWulinmeng] = "jhs_112.png",
    [Enums.JHKCampType.eHuntianjiao] = "jhs_113.png",
}

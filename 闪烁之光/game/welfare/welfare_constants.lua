-- --------------------------------------------------------------------
-- 福利相关的常量
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

WelfareConstants = WelfareConstants or {}

--- 活动所有标签页的类型控制器
WelfarePanelTypeView = {
    [1] = "SupreYuekaPanel",
    [2] = "HeroSoulWishPanel",
    [3] = "SignPanel",
    [6] = "WeiXinGiftPanel",
    [7] = "ActionInvestPanel",
    [8] = "ActionGrowFundPanel",
    [9] = "QRcodeShardPanel",
    [10] = "HonorYuekaPanel",
    [11] = "SureveyQuestWindow",
    [12] = "MonthWeekPanel",
    [14] = "SubscriptionWechatPanel",
    [15] = "BindPhonePanel",
    [16] = "InviteCodePanel",
    [17] = "PastePanel",
    [18] = "ShopPanel",
    [19] = "ActionFundOnePanel", --128基金
    [20] = "ActionFundTwoPanel", -- 328基金
    [21] = "YuekaPanel", -- 月卡集合
    [22] = "SubscriptionPrivilegePanel" -- 订阅特权
}

WelfareIcon = {
    supre_yueka = 8001, --至尊月卡--月卡总集合
    sign = 8003,
    level_gift = 8004,
    power_gift = 8005,
    weixin_gift = 8006,
    share_game = 8007, --游戏分享
    partnersummon_welfar = 8008,
    honor_yueka = 8009, --荣耀月卡
    quest = 8010, --问卷调查
    week = 8011, --周福利
    month = 8012, --月福利
    wechat = 8014, --微信公众号
    bindphone = 8015, --手机绑定
    invicode = 8016, --推荐码
    poste = 8017, --贴吧
    fund_one = 101, --128基金
    fund_two = 102, --328基金
    yueka = 8019, --月卡集合
    subscribe = 8020 --订阅特权
}

--问卷类型
QuestConst = {
    single = 1, --单选
    multiple = 3, --多选
    fill_blank = 4 --填空
}

--订阅id对应
SubscribeId = {
    month = 1, --月度订阅
    quarter = 2 --季度订阅
}

SubscribeAddDay = {
	[SubscribeId.month] = 30, --月度订阅增加天数
	[SubscribeId.quarter] = 90 --季度订阅增加天数
}

-- [[主界面图标]]
-- order: 显示顺序
-- fixed_order: 固定排列在某个位置(不能重复)
-- vis_cond: 显示条件
-- area: "top1"显示在第一页 "top2"显示在第一页
-- remind_group: 红点提醒组名
-- view_pos: 要打开的界面
-- res: 图标资源 资源路径client\tools\uieditor\ui_res\mainui, 图标有两个资源分别是(xx为res字段): icon_xx_img.png icon_xx_word.png
MainuiIcons = {
	-- 第一页 area = "top1" (显示顺序order值越大 从右往左，从上到下)
	
	{order = 1, res = "01", area = "top1", view_pos = ViewDef.NewlyBossView, remind_group = RemindGroupName.BossView, vis_cond = "CondId78"}, -- 挑战BOSS
	{order = 1, fixed_order = 2, vis_cond = "CondId2"}, -- 占位
	{order = 1, fixed_order = 9, vis_cond = "CondId2"}, -- 占位
	{order = 1, fixed_order = 10, vis_cond = "CondId2"}, -- 占位
	{order = 2, res = "02", area = "top1", view_pos = ViewDef.Explore, remind_group = RemindGroupName.ExploreView, vis_cond = "CondId24"},  -- 寻宝
	{order = 22, res = "12", area = "top1", view_pos = ViewDef.MainGodEquipView.RexueGodEquip, vis_cond ="CondId138", open_cond = "CondId133" , remind_group = RemindGroupName.GodEquipRexueView},  --热血神兵
	{order = 3, res = "03", area = "top1", view_pos = ViewDef.Shop, vis_cond = "CondId76"}, -- 商城
	{order = 4, res = "108", area = "top1", view_pos = ViewDef.CrossBoss, remind_group = RemindGroupName.CrossBossView, vis_cond = "CondId84"}, -- 跨服BOSS
	{order = 4, res = "45", area = "top1", view_pos = ViewDef.CrossLand, vis_cond = "CondId0"--[[remind_group = RemindGroupName.CrossBossView, vis_cond = "CondId84"]]},    -- 跨服BOSS、神豪殿
	-- {order = 5, res = "05", area = "top1", view_pos = ViewDef.ShenDing, remind_group = RemindGroupName.ShenDingView, vis_cond = "CondId90"}, -- 活跃度
	{order = 6, res = "06", area = "top1", view_pos = ViewDef.Welfare, remind_group = RemindGroupName.WelfareView, vis_cond = "CondId77"},  -- 福利
	{order = 7, res = "07", area = "top1", view_pos = ViewDef.Activity, remind_group = RemindGroupName.ActivityView, vis_cond = "CondId79"},    -- 日常活动
	{order = 8, res = "08", area = "top1", view_pos = ViewDef.WangChengZhengBa, remind_group = RemindGroupName.WangChengZhengBa, vis_cond = "CondId73"},    -- 王城争霸
	--{order = 10, res = "10", area = "top1", view_pos = ViewDef.ChiyouView, remind_group = RemindGroupName.ChiyouView,vis_cond = "CondId132"}, --蚩尤结界
	{order = 13, res = "18", area = "top1", view_pos = ViewDef.ChargeFirst, remind_group = RemindGroupName.ChargeFirstView, vis_cond = "CondId51"}, -- 首充
	{order = 15, res = "27", area = "top1", view_pos = ViewDef.OutOfPrint, vis_cond = "CondId137"}, -- 绝版抢购
	{order = 16, res = "28", area = "top1", view_pos = ViewDef.WelfareTurnbel, remind_group = RemindGroupName.WelfareTurnbelView, vis_cond = "CondId125"}, -- 福利转盘
	{order = 16, res = "11", area = "top1",  view_pos = ViewDef.Investment, remind_group = RemindGroupName.InvestmentView, vis_cond = "CondId108"}, --超值投资
	{order = 17, res = "17", area = "top1", view_pos = ViewDef.DiamondBackView, --[[remind_group = RemindGroupName.ShenDingView,]] vis_cond = "CondId115"}, -- 钻石回收
	-- {order = 18, res = "23", area = "top1", view_pos = ViewDef.DiamondBackView, --[[remind_group = RemindGroupName.ShenDingView,]] vis_cond = nil}, -- 充值大礼包
	{order = 19, res = "24", area = "top1", view_pos = ViewDef.HunHuan, remind_group = RemindGroupName.HunHuanView, vis_cond = "CondId118"}, -- 魂环特惠
	{order = 20, res = "23", area = "top1", view_pos = ViewDef.ChargeGift, remind_group = RemindGroupName.ChargeBigGiftView, vis_cond = "CondId123"}, -- 充值大礼包
	{order = 21, res = "46", area = "top1", view_pos = ViewDef.LoginReward, remind_group = RemindGroupName.LoginReward, vis_cond = "CondId124"}, -- 登录奖励
	
	
	{order = 19, res = "69", area = "top1", view_pos = ViewDef.LimitCharge, remind_group = RemindGroupName.ActChagreBackView, vis_cond = "CondId113"}, --限时充值
	-- {order = 20, res = "68", area = "top1", view_pos = ViewDef.ActChargeFanli,  vis_cond = "CondId114"}, --充值返利
	{order = 6, res = "29", area = "top1", view_pos = ViewDef.CombineServAct, remind_group = RemindGroupName.CombinedServAcitivityView, vis_cond = "CondId105"},    -- 合服活动
	{order = 6, res = "26", area = "top1", view_pos = ViewDef.OpenServiceAcitivity, remind_group = RemindGroupName.OpenServiceView, vis_cond = "CondId81"}, -- 开服活动
	{order = 6, res = "30", area = "top1", view_pos = ViewDef.OpenSerVeGift, remind_group = nil, vis_cond = "CondId81"},    -- 开服超值礼包
	{order = 12, res = "51", area = "top1", view_pos = ViewDef.RefiningExp, remind_group = RemindGroupName.RefiningExpView, vis_cond = "CondId64"}, -- 经验炼制

	{order = 21, res = "25", area = "top1", view_pos = ViewDef.ActivityBrilliant4, remind_group = RemindGroupName.ActivityBrilliant4, vis_cond = "CondId210"}, --运营活动
	{order = 21, res = "25", area = "top1", view_pos = ViewDef.ActivityBrilliant3, remind_group = RemindGroupName.ActivityBrilliant3, vis_cond = "CondId209"}, --运营活动
	{order = 21, res = "25", area = "top1", view_pos = ViewDef.ActivityBrilliant2, remind_group = RemindGroupName.ActivityBrilliant2, vis_cond = "CondId208"}, --运营活动
	{order = 21, res = "25", area = "top1", view_pos = ViewDef.ActivityBrilliant1, remind_group = RemindGroupName.ActivityBrilliant1, vis_cond = "CondId103"}, --运营活动
	{order = 22, res = "42", area = "top1", view_pos = ViewDef.MergeServerDiscount, vis_cond = "CondId105"},    --合服特惠
	{order = 23, res = "44", area = "top1", view_pos = ViewDef.ActCanbaoge, remind_group = RemindGroupName.ActCanbaogeView, vis_cond = "CondId111"}, --藏宝阁
	{order = 24, res = "43", area = "top1", view_pos = ViewDef.ActBabelTower, remind_group = RemindGroupName.ActBabelTowerView, vis_cond = "CondId112"}, --通天塔
	{order = 27, res = "02", area = "top1", view_pos = ViewDef.ZsTaskView, remind_group = RemindGroupName.TaskGoodGiftView, vis_cond = "CondId26"}, -- 钻石任务
	{order = 26, res = "02", area = "top1", view_pos = ViewDef.Explore.RareTreasure, vis_cond ="CondId24" , remind_group = RemindGroupName.ExploreRareTreasure},    --龙皇秘宝
	
}

MenuUiLeftIcons = { 
	-- {order = 14, res = "04", area = "top1", view_pos = ViewDef.ChargeEveryDay, remind_group = RemindGroupName.ChargeEveryDayView, vis_cond = "CondId90"}, -- 每日充值
	{order = 2, res = "16", view_pos = ViewDef.ZsVip, remind_group = RemindGroupName.ZsVipView, vis_cond = "CondId2"}, -- 钻石会员
	{order = 3,res = "55", view_pos = ViewDef.DiamondPet, remind_group = RemindGroupName.DiamondPet, vis_cond = "CondId139"},
	{order = 4,res = "109", view_pos = ViewDef.ZsVipRedpacker, remind_group = RemindGroupName.ZsVipRedpackerView, vis_cond = "CondId139"},
	--{order = 26, res = "09", area = "top1", view_pos = ViewDef.BlessingView, remind_group = RemindGroupName.BlessingView, vis_cond = "CondId117"}, --祈福
}

MenuUiRightBottomIcons = {  
	{order = 1, res = "58", view_pos = ViewDef.RankingList,  remind_group = nil, vis_cond = "CondId71",},                            -- 排行
	{order = 2, res = "57", view_pos = ViewDef.Mail,         remind_group = RemindGroupName.MailView, vis_cond = nil,},     -- 邮件
	{order = 3, res = "56", view_pos = ViewDef.Setting,      remind_group = nil, vis_cond = nil,},                          -- 设置
}

MenuUiRightTopIcons = { 
	{order = 1, res = "31", view_pos = ViewDef.Role, remind_group = RemindGroupName.RoleView}, --角色
	{order = 1, res = "59", view_pos = ViewDef.MainBagView, remind_group = RemindGroupName.BagUseView}, --背包
	{order = 2, res = "39", view_pos = ViewDef.Skill, }, --技能
	{order = 8, res = "21", view_pos = ViewDef.Society, remind_group = RemindGroupName.AllSociety, vis_cond = "CondId74"},  -- 好友
	{order = 7, res = "20", view_pos = ViewDef.Guild, remind_group = RemindGroupName.GuildView, vis_cond = "CondId74"}, -- 行会
	{order = 9, res = "37", view_pos = ViewDef.Consign, remind_group = nil, vis_cond = "CondId96"}, -- 寄售
}

MenuUiRightIcons = {    
	{order = 1, res = "32", view_pos = ViewDef.ZhanjiangView, vis_cond = "CondId58", remind_group = RemindGroupName.ZhangjiangView}, --战宠
	{order = 2, res = "33", view_pos = ViewDef.Equipment, remind_group = RemindGroupName.EquipmentView, vis_cond = "CondId130"},    -- 锻造
	{order = 3, res = "34", view_pos = ViewDef.GodFurnace, remind_group = RemindGroupName.GodFurnaceView, vis_cond = "CondId15"},   -- 神炉
	{order = 4, res = "35", view_pos = ViewDef.Wing, remind_group = RemindGroupName.WingView, vis_cond = "CondId82"},   -- 翅膀
	{order = 5, res = "22", view_pos = ViewDef.QieGeView, remind_group = RemindGroupName.QieGeRemindView, vis_cond = "CondId121"}, --切割
	{order = 6, res = "61", view_pos = ViewDef.GuardEquip, remind_group = RemindGroupName.GuardEquip, vis_cond = "CondId135", }, -- 守护神装
	{order = 7, res = "107", view_pos = ViewDef.Advanced, remind_group = RemindGroupName.JinjieView, vis_cond = "CondId201", }, -- 进阶
	{order = 8, res = "19", view_pos = ViewDef.SpecialRing, remind_group = RemindGroupName.SpecialRingView, vis_cond = "CondId145", }, --特戒
	{order = 9, res = "40", view_pos = ViewDef.Prestige, remind_group = RemindGroupName.PrestigeView, vis_cond = "CondId88"},  -- 战鼓
	{order = 10, res = "38", view_pos = ViewDef.Fashion, remind_group = RemindGroupName.FashionView, vis_cond = nil},    -- 时装
	{order = 11, res = "101", view_pos = ViewDef.CardHandlebook, remind_group = RemindGroupName.CardHandlebookView, vis_cond = "CondId87"}, -- 车库   
	{order = 12, res = "60", view_pos =ViewDef.Horoscope, remind_group = RemindGroupName.XingHunTabbar, vis_cond = "CondId119"}, -- 星魂  
	{order = 13, res = "106", view_pos = ViewDef.BattleFuwen, remind_group = RemindGroupName.BattleFuwenView, vis_cond = "CondId150"}, -- 战纹   
	-- {order = 17, res = "107", view_pos = ViewDef.FunOpenGuideView, remind_group = RemindGroupName.JinjieView, vis_cond = "CondId201", }, -- 功能开启
	--{order = 14, res = "13", view_pos = ViewDef.MeiBaShouTao, vis_cond = "CondId131" --[[vis_cond = "CondId114"]]}, --灭霸手套
	--{order = 15, res = "12", view_pos = ViewDef.ChuanShiEquip,  --[[vis_cond = "CondId114"]]}, --传世
}

-- 限时任务
TimeLimitTaskIcon = {res = "105", view_pos = ViewDef.TimeLimitTask, remind_group = RemindGroupName.TimeLimitTaskView, vis_cond = "CondId0"}

-- 发现BOSS
FindBossIcon = {res = nil, view_pos = ViewDef.FindBoss, remind_group = RemindGroupName.FindBoss, vis_cond = "CondId98"}

-- 必杀技预告
BiShaPreviewIcon = {res = "06", view_pos = ViewDef.FunOpenGuideView, remind_group = nil, vis_cond = "CondId72"}

-- 固定按钮
MenuUiFixedIcons = {
	{order = 1, fixed_order = 1, res = "01", area = "top1", view_pos = ViewDef.Boss, remind_group = RemindGroupName.BossView, vis_cond = "CondId78"}, -- 挑战BOSS
}

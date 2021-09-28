
 --[[
 --
 -- @authors shan 
 -- @date    2014-05-13 11:07:22
 -- @version 
 --
 --]]

if(device.platform == "android") then
	require("game.AndroidGameConst")
	GAME_DEBUG = false
end

if(device.platform == "windows" or device.platform == "mac") then
	GAME_DEBUG = true
	DEV_BUILD = true
end
GAME_DEBUG = false
DEV_BUILD = false
ANDROID_NO_SDK = true


--[[=======logo 名字使用 热血Q传  暂时方案===================]]
USE_NAME_REXUE = false
--[[==========================]]



ENABLE_HUASHAN_SHOP = true

ENABLE_DAILY_TASK = true

-- 游戏工场  sdk  
ENABLE_GAME_WORKS = false

-- 对方阵容开关
ENABLE_ZHENRONG = true

-- 充值开关 
ENABLE_IAP_BUY = true

-- 论剑开关 
ENABLE_LUNJIAN = true

-- 世界boss开关 
ENABLE_WORLDBOSS = true 

--音乐开关
NO_MUSIC = false
--
SHOW_MASK_LAYER = false
--新手引导跳过
SHOW_TUTO_SKIP = true 


-- 怒气功能开关
ENABLE_NUQI = true

-- 神通功能开关
ENABLE_SHENTONG = true

-- 月签功能开关 
ENABLE_YUEQIAN = true   

-- 热血基金(等级投资)功能开关
ENABLE_DENGJITOUZI = true   


-- 主菜单cheat
ENABLE_CHEAT = false

-- 帮派 
ENABLE_GUILD = true        


-- 副本战斗跳过
DEBUG_BATTLE_SKIP = false
--[[-==============================]]

MppUI = require("utility.MppUI")
ResMgr = require("utility.ResMgr")
TutoMgr = require("game.Tutorial.TutoMgr")
DramaMgr = require("game.Drama.DramaMgr")
OpenCheck = require("game.OpenSystem.OpenCheck") 
RewardLayerMgr = require("utility.RewardLayerMgr") 

--Model类

ModelMgr = require("game.model.ModelMgr")

DEVICE_TYPE = {
	HIGH   = 1,
	MEDIUM = 2,
	LOW    = 3
}
NORMAL_FUBEN = 1
JINGYING_FUBEN = 2
HUODONG_FUBEN = 3
ARENA_FUBEN = 4
DUOBAO_FUBEN = 5
DRAMA_FUBEN = 6 
WORLDBOSS_FUBEN = 7 
LUNJIAN = 8
GUILD_QLBOSS_FUBEN = 9 	-- 青龙boss副本 
GUILD_FUBEN = 10 		-- 帮派副本 


GAME_STATE = {
	STATE_NONE 			  = 0,  -- 无
	STATE_LOGO            = 1,	-- Logo
	STATE_MAIN_MENU       = 2,
	STATE_ZHENRONG        = 3,	-- 阵容
	STATE_FUBEN           = 4,
	STATE_HUODONG         = 5,
	STATE_BEIBAO          = 6,
	STATE_SHOP            = 7,
	STATE_HEROS           = 8,
	STATE_EQUIPMENT       = 9,
	STATE_JINGMAI         = 10,
	STATE_FRIENDS         = 11,
	STATE_SETTING         = 12,
	STATE_LIANHUALU       = 13,
	STATE_JINGYUAN        = 14,	-- 真气
	STATE_XIAKE           = 15,	-- 侠客
	STATE_JIANGHULU       = 16,	-- 江湖路
	STATE_TIAOZHAN        = 17,	-- 挑战
	STATE_ARENA           = 18,  --竞技场UI界面
	STATE_ARENA_BATTLE    = 19, --竞技场战斗界面
	STATE_JINGYING_BATTLE = 20, 
	STATE_DUOBAO          = 21, 		  -- 夺宝界面
	STATE_DUOBAO_BATTLE   = 22,  -- 夺宝战斗界面
	STATE_JINGCAI_HUODONG = 23, 
	STATE_MAIL            = 24, 	 -- 邮件界面
	STATE_NORMAL_BATTLE   = 25, --普通副本的战斗界面
	STATE_HUODONG_BATTLE  = 26, 
	STATE_JINGMAI         = 27, 		-- 经脉界面
	STATE_SUBMAP          = 28, --普通副本的列表
	STATE_LOGIN           = 29, 
	STATE_VERSIONCHECK	  = 30,
	DRAMA_SCENE			  = 31,  -- 专门播放剧情的黑色Scene 
	DRAMA_BATTLE 		  = 32,  --第一场的剧情战斗
	STATE_WORLD_BOSS_NORMAL	  = 33, -- 世界boss 非战斗状态
	STATE_WORLD_BOSS	  = 34, -- 世界boss 战斗状态



    STATE_HUASHAN         = 35,
    STATE_HANDBOOK		  = 36,  	--图鉴
	STATE_GUILD			  = 37, 	-- 帮派
	STATE_GUILD_GUILDLIST = 38, 	-- 帮派列表  
	STATE_GUILD_MAINSCENE = 39, 	-- 帮派主界面 
	STATE_GUILD_ALLMEMBER = 40, 	-- 帮派成员列表 
	STATE_GUILD_VERIFY    = 41, 	-- 帮派审核列表 
	
	STATE_GUILD_DADIAN	  = 42, 	-- 帮派大殿 
	STATE_GUILD_DYNAMIC	  = 43, 	-- 帮派动态
	STATE_HUASHAN_SHOP    = 44,     -- 论剑的商城
	STATE_BIWU            = 45, 	-- 比武
	STATE_BIWU_BATTLE     = 46,     --比武战斗界面 
	STATE_GUILD_QL_BOSS   = 47, 	-- 青龙堂boss 

	STATE_RANK_SCENE      = 48,     --排行榜列表
	STATE_GUILD_SHOP	  = 49, 	-- 帮派商店 
	STATE_YABIAO_SCENE    = 50,     --押镖界面
	STATE_YABIAO_BATTLE_SCENE    = 51,     --押镖战斗界面
	STATE_GUILD_FUBEN = 52, 		-- 帮派副本 
}


G_BOTTOM_BTN = {GAME_STATE.STATE_MAIN_MENU, GAME_STATE.STATE_ZHENRONG, GAME_STATE.STATE_FUBEN, GAME_STATE.STATE_HUODONG, GAME_STATE.STATE_BEIBAO, GAME_STATE.STATE_SHOP}

local ccs = ccs or {}
ccs.MovementEventType = {
    START = 0,
    COMPLETE = 1,
    LOOP_COMPLETE = 2,
}

-- 主界面下的子菜单
MAIN_MENU_SUBMENU = {
	XIAKE     = 20,  -- 侠客
	ZHUANGBEI = 21,  -- 装备
	JINGMAI   = 22,
	FRIEND    = 23,
	CHAT      = 24,
	SETTING   = 25,
    BAG       = 26,
    SHOP      = 27
}

BOX_ZORDER ={
	BASE = 100,
	MIN = 200,
	MED = 500,
	MAX = 1000
}


CCB_TAG = {
	-- 主界面 ccb tag
	mm_shouye   = "tag_shouye",
	mm_zhenrong = "tag_zhenrong",
	mm_fuben    = "tag_fuben",
	mm_huodong  = "tag_huodong",
	mm_beibao   = "tag_beibao",
	mm_shop     = "tag_shop",

}

CCB_PLAYER_INFO = {
	mm_name  	= "info_box",
	mm_lv       = "tag_lv",
	mm_vip      = "tag_vip",
	mm_silver   = "tag_silver",
	mm_gold     = "tag_gold",
	mm_tili     = "tag_tili",
	mm_tili_bar = "tag_tili_bar",
	mm_naili    = "tag_naili",
	mm_zhanli   = "tag_zhanli",
	mm_exp		= "tag_exp",
	label_vip    = "label_vip",
	label_zhanli = "label_zhanli",
	label_tili   = "label_tili",
	label_naili  = "label_naili",
	label_exp    = "label_exp",
	label_silver = "label_silver",
	label_gold   = "label_gold",

}



MM_TAG = {
	mm_xiake   = "tag_xiake",
	mm_equip   = "tag_equip",
	mm_jingmai = "tag_jingmai",
	mm_friend  = "tag_friend",
	mm_chat    = "tag_chat",
	mm_setting = "tag_setting",
	mm_tiaozhan = "tag_tiaozhan"
}



IMAGE_PLIST_PATH = {
	bigmap = {"bigmap/bigmap.png","bigmap/bigmap.plist"},
	submap = {"ui/ui_submap.png","ui/ui_submap.plist"},
}



FONTS_NAME = {
	font_haibao = "fonts/FZCuYuan-M03S.ttf",
	font_fzcy   = "fonts/FZCuYuan-M03S.ttf",

	font_time	= "fonts/font_time.fnt",
	font_vip	= "fonts/font_vip.fnt",
	font_zhanli = "fonts/font_zhanli.fnt",
	font_property = "fonts/font_property.fnt",
	font_btns = "fonts/font_buttons.fnt",
	font_zhaojiang = "fonts/font_zhaojiang.fnt",
	font_battle_round = "fonts/font_battle_round.fnt"
}


FONT_COLOR ={
	WHITE = ccc3(255,255,255),
	BLACK = ccc3(0, 0, 0), 
	GREEN = ccc3(0, 228, 48),
	BLUE = ccc3(0,168,255),
	PURPLE = ccc3(192,0,255),
	ORANGE = ccc3(255,165,0),

	YELLOW = ccc3(255,252,0),
	RED = ccc3(221,0,0),
	LIGHT_ORANGE = ccc3(237,188,119),
	GRAY = ccc3(100,100,100),
	LIGHT_GREEN = ccc3(0,255,186),
	RED_GRAY = ccc3(192, 172, 164),
	DARK_RED = ccc3(126, 0, 0),

	BLOOD_RED = ccc3(130,13,0),

	TITLE_COLOR = ccc3(150,255,0),
	TITLE_OUTLINECOLOR = ccc3(4,75,0),

	-- main menu
	PLAYER_NAME = ccc3(160,229,228),
	COIN_SILVER = ccc3(255,255,255),
	COIN_GOLD = ccc3(255,210,0),

	COMMON_FONT_COLOR = ccc3(110,0,0),

	-- gamenote
	NOTE_TITLE = ccc3(255,228,0),
	NOTE_TITLE_OUTLINE = ccc3(85,1,0),
	NOTE_TEXT = ccc3(110,0,0),

	LEVEL_NAME = ccc3(255,246,0), -- ccc3(252,234,206)


}

NAME_COLOR = {ccc3(141, 141, 141), FONT_COLOR.GREEN, ccc3(0, 146, 238), FONT_COLOR.PURPLE, ccc3(224, 169, 0)}

NAME_COLOR_HEX = {"#8d8d8d", "#00e430", "#0092ee", "#c000ff", "#e0a900"}

QUALITY_COLOR = {
	[1] = ccc3(141, 141, 141), 
	[2] = FONT_COLOR.GREEN,
	[3] = ccc3(0, 146, 238),
	[4] = FONT_COLOR.PURPLE,
	[5] = ccc3(224, 169, 0), 
}

QUALITY_COLOR_HEX = {"#8d8d8d", "#00e430", "#0092ee", "#c000ff", "#e0a900"} 


ARENA_SHOP_TYPE = 1
HUASHAN_SHOP_TYPE = 2
GUILD_SHOP_TYPE = 3 


NoticeKey = {
    MainMenuScene_Update = "MainMenuScene_Update",
    MAINSCENE_HIDE_BOTTOM_LAYER = "MAINSCENE_HIDE_BOTTOM_LAYER",
    MAINSCENE_SHOW_BOTTOM_LAYER = "MAINSCENE_SHOW_BOTTOM_LAYER",
    SpiritUpgradeScene_UpdateExpBar = "SpiritUpgradeScene_UpdateExpBar",

    CommonUpdate_Label_Silver = "CommonUpdate_Label_Silver",
    CommonUpdate_Label_Gold   = "CommonUpdate_Label_Gold",

    CommonUpdate_Label_Tili   = "CommonUpdate_Label_Tili",
    CommonUpdate_Label_Naili   = "CommonUpdate_Label_Naili",
    CommonUpdate_PAY_RESULT    = "CommonUpdatePayResult",
    ArenaRestTime = "ArenaRestTime",
    SwitchArenaTimeType = "SwitchArenaTimeType", 
    BROADCAST_SHOW_PLAYERGETHERO = "Broadcast_show_playerGetHero", 
    BROADCAST_SHOW_HEROLEVELUP	= "Broadcast_show_heroLevelUp", 
    MainMenuScene_OnlineReward = "MainMenuScene_OnlineReward", 
    MainMenuScene_RewardCenter = "MainMenuScene_RewardCenter", 
    MainMenuScene_ChengZhangZhilu = "MainMenuScene_ChengZhangZhilu",
    MainMenuScene_KaifuLibao = "MainMenuScene_KaifuLibao", 
    MainMenuScene_DengjiLibao = "MainMenuScene_DengjiLibao", 
    MainMenuScene_Qiandao = "MainMenuScene_Qiandao", 
    BottomLayer_Chouka = "BottomLayer_Chouka", 
    MainMenuScene_chatNewNum = "MainMenuScene_chatNewNum", 
    MainMenuScene_challenge = "MainMenuScene_challenge",
    MainMenuScene_Music = "MainMenuScene_Music", 
    MainMenuScene_UrgencyBroadcast = "MainMenuScene_UrgencyBroadcast", 
    MainMenuScene_Shouchong = "MainMenuScene_Shouchong", 

    --比武
    BIWu_update_naili = "BIWu_update_naili", 
    BIWu_update_Title_on = "BIWu_update_Title_on",
    BIWu_update_Title_off = "BIWu_update_Title_off",

    --押镖
    Yabiao_repair_enemy = "Yabiao_repair_enemy",
    Yabiao_run_car = "Yabiao_run_car",


    --移除新手引导
    REMOVE_TUTOLAYER = "REMOVE_TUTOLAYER",
    --移除maskLayer
    REMOVE_MASKLAYER = "REMOVE_MASKLAYER",

    --移除新手引导遮罩
    REV_TUTO_MASK = "REV_TUTO_MASK",
    --移除新手引导前遮罩
    REV_BEF_TUTO_MASK = "REV_BEF_TUTO_MASK" ,

    --锁定所有的tableview,不让滑动
    LOCK_TABLEVIEW = "LOCK_TABLEVIEW",

    --解锁所有的tableview,让滑动
    UNLOCK_TABLEVIEW = "UNLOCK_TABLEVIEW",

    --禁用bottomlayer 
    LOCK_BOTTOM = "LOCK_BOTTOM",
    --解锁bottomlayer
    UNLOCK_BOTTOM = "UNLOCK_BOTTOM",


    -- 邮件

    MAIL_TIP_UPDATE = "mail_tip_update", 

    -- 帮派 帮主自荐
    GUILD_UPDATE_ZIJIAN = "guild_update_zijian", 


    UPDATE_FRIEND = "UPDATE_FRIEND",

    -- 帮派福利 倒计时 
    UPDATE_GUILDFULI_TIME = "update_guildFuli_time", 
    
    --更新主界面好友上的小红点
    UP_FRIEND_ICON_ACT = "UP_FRIEND_ICON_ACT",

    -- 帮派主界面 更新帮派信息(资金、个人贡献等)  
    UPDATE_GUILD_MAINSCENE_MSG_DATA = "UPDATE_GUILD_MAINSCENE_MSG_DATA",
  	-- 帮派主界面 更新建筑等级 
    UPDATE_GUILD_MAINSCENE_BUILD_LEVEL 	= "UPDATE_GUILD_MAINSCENE_BUILD_LEVEL", 	

    -- 帮派申请数量 
    CHECK_GUILD_APPLY_NUM		= "CHECK_GUILD_APPLY_NUM", 
    -- 帮派成员审核 提示红点 是否显示 
    CHECK_IS_SHOW_APPLY_NOTICE = "CHECK_IS_SHOW_APPLY_NOTICE", 

}

LIAN_HUA_TYEP = {   --可以炼化物品的类型
    HERO      = 1,
    EQUIP     = 2,
    SKILL     = 3,
    TAOZHUANG = 4
}


-- 基本属性的对应关系
-- 生命,攻击,物防,法防,最终伤害,最终免伤
BASE_PROP_MAPPPING = {
    31, 32, 33, 34, 77, 78
}

EQUIP_BASE_PROP_MAPPPING = {
    21, 22, 23, 24, 77, 78
}



-- 系统id（1-等级礼包；2-签到；3-精英副本（挑战）；4-神秘商店（不用，已25为准）；5-炼化炉；6-群侠录；
-- 7-军团（无）；8-经脉；9-活动副本（挑战）；10-洗炼（装备）；11-每日任务（废弃）；
-- 12-真气；13-宠物（无）；14-阵容;15-小伙伴（无）;16-竞技场（活动）；17-夺宝（活动）；
-- 18-内外功精炼（背包）；19-阵容系统（阵容）；20-侠客进阶（侠客）；21-神通（侠客）；22-招募侠客（商城）；23-装备强化（装备）；24-真气系统）
-- 25-神秘商店；26-战斗跳过；27-练十次（真气）；28-世界boss自动战斗（世界boss）；29-聊天背景和头像显示；
-- 30-活动副本战斗跳过；31-劫富济贫；32-行侠仗义；33-除暴安良；34-十连战(普通副本)；35-精英副本战斗跳过；36-华山论剑战斗跳过；
-- 37-论剑开启；38-热血基金购买限制；39-邮件开启条件；40-帮派开启条件 41-限时豪杰 42比武;43每日任务

OPENCHECK_TYPE = {
	DengJiLiBao = 1, 
	QianDao = 2, 
	JiYing_FuBen = 3, 
	ShenMiShangDian = 4, 
	LianJuaLu = 5, 
	QunxiaLu = 6, 
	JunTuan = 7, 
	JingMai = 8, 
	HuoDong_FuBen = 9, 
	XiLian = 10, 
	MeiRi_RenWu = 11, 
	ZhenQi = 12, 
	ChongWu = 13, 
	ZhenRong = 14, 
	XiaoHuoBan = 15, 
	JingJiChang = 16, 
	DuoBao = 17, 
	NeiWaiGong_JingLian = 18, 
	ZhenRong_XiTong = 19, 
	XiaKe_JinJie = 20, 
	ShenTong = 21, 
	ZhaoMu_XiaKe = 22, 
	ZhuangBei_QiangHua = 23, 
	ZhenQi_XiTong = 24, 
	ShenMi_Shop = 25, 
	Tiaoguo_NormalFuben = 26, 
	LianShici_Zhenqi = 27, 
	WorldBoss_AutoBattle = 28, 
	Chat_Touxiang = 29, 
	Tiaoguo_HuodongFuben = 30, 
	JiefuJipin = 31, 
	XingxiaZhangyi = 32, 
	ChubaoAnliang = 33,
	ShilianZhan_FuBen = 34,  
	Tiaoguo_JingyingFuben = 35, 
	Tiaoguo_HuashanLunjian = 36, 
	HuashanLunjian = 37, 
	DengjiTouzi_buy = 38, 
	Mail = 39, 
	Guild = 40, 
	LimitHero = 41, 
	BiWu = 42, 
	DailyTask = 43, 

	RANK_LIST = 44 ,
	TanBao = 46 ,




} 

DRAMA_ZORDER = 13000
BEF_MASK_ZORDER = 11000
TUTO_MASK_ZORDER = 12000 --
MASK_LAYER_ZORDER = 10000000




 -- 和OPENCHECK_TYPE 类型对应
OPENCHECK_ICON_NAME = {
	{1, "#toplayer_dengjilibao.png"},  						-- 1.等级礼包
	{1, "#toplayer_qiandao.png"},							-- 2.签到
	{2, "#b3_tiaozhan.png"},								-- 3.精英副本 
	{0, ""},												-- 4.神秘商店 (废弃，已systemd=25准)
	{2, "#b2_lianhualu.png"},								-- 5.炼化炉
	{2, "#b2_qunxialu.png"},								-- 6.群侠录 
	{0, ""},												-- 7.军团 [无]
	{2, "#b2_jingmai.png"},									-- 8.经脉
	{2, "#b3_tiaozhan.png"},								-- 9.活动副本
	{2, "#b2_equip.png"},									-- 10.洗练 
	{0, ""},												-- 11.每日任务 [无]
	{2, "#b2_jingyuan.png"},								-- 12.真气
	{0, ""},												-- 13.宠物 [无]
	{3, "#bl_zhenrong_up.png"},								-- 14.阵容
	{0, ""},												-- 15.小伙伴[无]
	{10, "ui/ui_huodong/ui_huodong_jingjichang.jpg"},		-- 16.竞技场
	{10, "ui/ui_huodong/ui_huodong_duobao.jpg"},			-- 17.夺宝
	{3, "#bl_beibao_up.png"},								-- 18.内外功精炼 
	{3, "#bl_zhenrong_up.png"},								-- 19.阵容系统
	{2, "#b2_hero.png"},									-- 20.侠客进阶 
	{2, "#b2_hero.png"},									-- 21.神通
	{3, "#bl_shop_up.png"},									-- 22.招募侠客 
	{2, "#b2_equip.png"},									-- 23.装备强化 
	{2, "#b2_jingyuan.png"},								-- 24.真气系统
	{4, "#nbhuodong_shenmiShop.png"}, 						-- 25.神秘商店
	{}, -- 26.战斗跳过
	{}, -- 27.练十次（真气）
	{}, -- 28.世界boss自动战斗（世界boss）
	{}, -- 29.聊天背景和头像显示 
	{}, -- 30.活动副本战斗跳过 
	{10, "ui/ui_huodong_fb/hd_fb_jiefujipin.png"}, 			-- 31.劫富济贫 
	{10, "ui/ui_huodong_fb/hd_fb_xingxiazhangyi.png"}, 		-- 32.行侠仗义 
	{10, "ui/ui_huodong_fb/hd_fb_chubaoanliang.png"}, 		-- 33.除暴安良
	{}, -- 34.十连战(普通副本) 
	{}, -- 35.精英副本跳过 
	{}, -- 36.华山论剑战斗跳过 
	{10, "ui/ui_huodong/ui_huodong_lunjian.jpg"}, 			-- 37.华山论剑 
	{}, -- 热血基金购买限制
	{}, -- 邮件开启 
	{}, -- 帮派开启 
	{}, -- 限时豪杰 
	{10, "ui/ui_huodong/ui_huodong_biwu.jpg"}, -- 比武
	{1, "#toplayer_chengzhang.png"}, -- 每日任务 

 }

--
-- 音效
-- 
SFX_NAME = {
	u_guanbi          = "u_guanbi",		--点击关闭类按钮时
	u_yeqian          = "u_yeqian",		--切换页签时
	u_queding         = "u_queding",	--点击确定类按钮时
	u_shengli         = "u_shengli",	--战斗胜利时
	u_shibai          = "u_shibai",		--战斗失败时
	u_shengji         = "u_shengji",	--主角升级时
	u_qianghua        = "u_qianghua",	--武学/装备强化 --已添加
	u_jinglianfeixing = "u_jinglianfeixing",--武学精炼
	u_xiakeqianghua   = "u_xiakeqianghua",	--侠客强化 --已添加
	u_xiakejingjie    = "u_xiakejingjie",	--侠客进阶 --已添加
	u_duobaohecheng   = "u_duobaohecheng",	--宝物碎片合成
	u_lianhualu       = "u_lianhualu",		--炼化过程
	u_zhaomu          = "u_zhaomu",			--招募过程
	u_zhaomushi		  = "u_zhaomushi", 		--招募十连抽
	u_jianghulu       = "u_jianghulu",		--侠客好感度升级
    u_qianghuachenggong = "u_qianghuachenggong", --强化成功 
    u_fanpai 			= "u_fanpai", 
    u_caiquan_fanpai 	= "u_caiquan_fanpai", -- 
    u_caiquanshengli 	= "u_caiquanshengli", 
    u_caiquanshibai		= "u_caiquanshibai", 
    u_duobaohecheng1 	= "u_duobaohecheng1", 
    u_shilianchouchuxian = "u_shilianchouchuxian", 
    u_shilianchoufanzhuan = "u_shilianchoufanzhuan", 
}


-- 背包类型
BAG_TYPE = {
	zhuangbei = 1, 
	shizhuang = 2, 
	zhuangbei_suipian = 3, 
	wuxue = 4, 
	canhun = 5, 
	zhenqi = 6, 
	daoju = 7, 
	xiake = 8, 
	neigong_suipian = 9, 
	waigong_suipian = 10 
}

BAG_NAME_MAPPING = {
    [BAG_TYPE.zhuangbei] = "装备背包",
    [BAG_TYPE.shizhuang] = "时装背包",
    [BAG_TYPE.zhuangbei_suipian] = "装备碎片",
    [BAG_TYPE.wuxue] = "武学背包",
    [BAG_TYPE.canhun] = "残魂背包",
    [BAG_TYPE.zhenqi] = "真气背包",
    [BAG_TYPE.daoju] = "道具背包",
    [BAG_TYPE.xiake] = "侠客背包",
    [BAG_TYPE.neigong_suipian] = "内功碎片背包",
    [BAG_TYPE.waigong_suipian] = "外功碎片背包",
}

-- 精彩活动
nbActivityShowType = {
	VipShouchong = 1, -- VIP首冲礼包
    VipFuli = 2, 	-- VIP福利
    MonthCard = 3, 	-- 月卡
    VipLibao = 4, 	-- VIP升级礼包	-- (已废弃，Vip礼包已移至商场)
    KeZhan = 5, 	-- 客栈
    CaiQuan = 6, 	-- 猜拳
    ShenMi = 7, 	-- 神秘商店
    LeijiLogin = 8, 	-- 累积登录 
    Yueqian = 9, 		-- 月签 
    DengjiTouzi = 10, 	-- 等级投资 
    LimitHero = 11,      -- 限时神将
    DialyActivity = 12,  --每日活动
    xianshiDuiHuan = 13,  --限时兑换
    huanggongTanBao = 14,   --皇宫探宝
    migongWaBao = 15,   --迷宫挖宝
    xianshiShop = 16,   --限时商店
}

QuickAccess = {
    SLEEP     = 1,
    BOSS      = 2,
    LIMITCARD = 3,
    CAIQUAN	= 4,
    GUILD_BOSS		= 5,
    GUILD_BBQ		= 6,
    YABIAO = 7,
    TANBAO  = 8,

}

-- appstore相关开关状态 
APPOPEN_STATE = {
	close = 0, 		
	open = 1, 
}


TUTO_ZORDER  = 999999
GAMENOTE_ZORDER = TUTO_ZORDER + 1 


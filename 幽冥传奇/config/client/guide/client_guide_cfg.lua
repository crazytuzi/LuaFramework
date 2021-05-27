ClientOpType = {
	Low = 1,         --小于
	High = 2,		 --大于
	Equ = 3,         --等于
	LowEqu = 4,		 --小于等于
	HighEqu = 5,     --大于等于
}

ClientGuideConditionType = 
{
	UpLevel = 1, --升级类型，例如1升到2的过程检测，value为升级到目标值
	EquipXf = 2,   --身上有血符数量,value为检测数量
	HasTask = 3,   --当前存在任务,id 为任务id,value为数量
	HeroFight = 4, --英雄出战数量,value为数量
	EquipSd = 5, --身上有神盾数量,value为检测数量
	BindYB = 6,  --身上绑元数量,value为检测数量
	BagEquipCount = 7, --背包装备数量,value为检测数量
	HasWeapon = 8,     --身上武器数量,value为检测数量
	WeaponStrength = 9,  --武器强化等级数量,value为检测数量
	GoldCoin = 10,     --身上金币数量,value为检测数量
	BagNilCount = 11,  --背包空置格子数量,value为检测数量
	HasDress = 12,     --身上衣服数量,value为检测数量
	DressStrength = 13, --衣服强化等级数量,value为检测数量
	EquipHz = 14,     --身上有魂珠数量,value为检测数量
	BagItemCount = 15, --背包制定物品数量,id为物品id,value为检测数量
	CurScene = 16,     --当前在特定场景,id为场景id
	PrevScene = 17,    --上一个场景,id为场景id
	EquipBs = 18,    --身上有宝石数量,value为检测数量
	RoleLevel = 19,   --角色等级value为闭区间数组例如value={low,high} 代表 low <= level <= high 条件
	PreGuideID = 20,   --  上一次指引的id
	ModuleVisible = 21, -- 模块可见,value为名称
	SettingCheckHp = 22, --是否设置过hp不够自动吃回血药,value 为 true 或 false
	RoleCircle = 23,   --转数value为检测数量
	OpenServerDay = 24, --开服天数value为检测数量
	UpCircle = 25,--升转类型，例如1升到2的过程检测，value为升级到目标值
	UpServerDay = 26,--天数变化类型,例如1升到2的过程检测，value为升级到目标值
	CircleSoul = 27,--转生灵魂值,value为检测数量
	CircleSoulTick = 28,--转生灵魂兑换已经使用次数,value为检测数量
	GuideSelfExeCount = 29,--指引自身的出现次数,id为指引id,value为检测数量
	AchieveFinish = 30, --成就完成,value为成就id
	AchieveNotFinish = 31,--成就未完成,value为成就id
	AchieveGetAward = 32,--成就已领奖,value为成就id
	AchieveNotGetAward = 33,--成就未领奖,value为成就id
	HeroActiveId = 34,    --当前激活战将,value为战将id
	ModuleNotVisible = 35, -- 模块不可见,value为名称
	HeroFuwenLevel = 36,    -- 战神当前符文等级,value为检测数量
	HeroFuwenExp = 37,     -- 战神当前符文经验,value为检测数量
	HeroHasDress = 38,     -- 战神身上衣服数量,value为检测数量
	MovieGuideEnd = 39,    --对话指引结束,id为指引id值
	RolePathTaskId = 40,   --正在寻路目标任务,id为任务id值
	CombineSkillCanUse = 41, --合击能使用
	SelectBoss = 42, --当前选择角色类型为boss
	SkillAutoUse = 43,--当前技能自动使用,id为一组技能{id1,id2,id3},value为开启状态(false关true开)
	Job = 44,       --用户当前职业,value为职业类型(1战士 2法师 3道士)
	VipLevel = 45,  --vip等级,value为检测数量
	MeridiansExp = 46,--当前经脉经验,value为检测数量
	MeridiansLevel = 47,--当前经脉等级,value为检测数量
	WingLevel = 48,--翅膀等级,value为检测数量
	WingExp = 49,--翅膀经验,value为检测数量
	TaskCount = 50,--当前已接任务数量,value为检测数量
	FumoTaskFinishCount = 51,--伏魔任务完成次数,value为检测数量
	HeroHasWuqi = 52,--战神身上武器数量,value为检测数量
	XunBaoJifen = 53,--寻宝积分,value为检测数量
	HeroWingActive = 54,--英雄光翼激活情况,id为翅膀id,value为检测状态(2为未激活,1为穿戴,0为卸下)
	SceneMonsterCount = 55,--当前场景怪物数量,value为检测数量
	SceneNpcCount = 56,--当前视野npc数量,value为检测数量
	SceneItemCount = 57,--当前视野物品数量,value为检测数量
	RoleEquip = 58,--角色身上有装备,value为装备id
}

ClientGuideStepType = 
{
	CommonButton = 1, --普通的按钮类型,这种类型比较散，重新定义一个映射表CommonButtonType
	TabButton = 2,    --索引按钮类型,这个类型的名称在view_def文件TabIndex下面的变量名称
	ListView = 3,     --列表组件,data为元素下标，从1开始{type = ClientGuideStepType.ListView,view_name = "模块名称" , node_name = "组件名称", data = 下标,is_modal = true,arrow = "down"},
	Grid = 4,         --网格组件,data为用户数据，大多数为物品数据{type = ClientGuideStepType.Grid,view_name = "模块名称" , node_name = "组件名称", data = 具体数据,is_modal = true,arrow = "down"},
	AutoOpen = 5,     --自动打开模块{type = ClientGuideStepType.AutoOpen,view_name = "模块名称" , node_name = "组件名称"},
	AutoClose = 6,    --自动关闭模块{type = ClientGuideStepType.AutoClose,view_name = "模块名称"},
	ClickNpc = 7,     --自动点击npc{type = ClientGuideStepType.ClickNpc,npc_id = 1,scene_id = 1, x = 0, y = 0},
	DelayTime = 8,    --延时下个指引检测间隔时间单位秒{type = ClientGuideStepType.DelayTime, time = 1}
}

CommonButtonType = 
{
	NAV_COMPOSE_BTN = "NAV_COMPOSE_BTN",  -- 神炉导航按钮
	COMPOSE_XF_ACTIVATE_BTN = "COMPOSE_XF_ACTIVATE_BTN", -- 神炉血符激活按钮

	NAV_ZHANSHEN_BTN = "NAV_ZHANSHEN_BTN",  -- 战神导航按钮
	ZHANSHEN_LIST_VIEW = "ZHANSHEN_LIST_VIEW", --战神列表
	ZHANSHEN_FIGHT_BTN = "ZHANSHEN_FIGHT_BTN", --战神出战按钮
	ZHANSHEN_FUWEN_UP_LEVEL_BTN = "ZHANSHEN_FUWEN_UP_LEVEL_BTN",--战神符文升级按钮
	ZHANSHEN_BAG_ITEM_GRID = "ZHANSHEN_BAG_ITEM_GRID", --英雄背包网格
	ZHANSHEN_WING_NAV_BTN = "ZHANSHEN_WING_NAV_BTN",--英雄翅膀导航按钮
	ZHANSHEN_WING_WEAR_BTN = "ZHANSHEN_WING_WEAR_BTN",--英雄翅膀穿戴按钮

	COMPOSE_SD_ACTIVATE_BTN = "COMPOSE_SD_ACTIVATE_BTN", -- 神炉神盾激活按钮
	COMPOSE_HZ_ACTIVATE_BTN = "COMPOSE_HZ_ACTIVATE_BTN", -- 神炉魂珠激活按钮
	COMPOSE_BS_ACTIVATE_BTN = "COMPOSE_BS_ACTIVATE_BTN", -- 神炉宝石激活按钮

	NAV_SHOP_BTN = "NAV_SHOP_BTN",        --商城导航按钮
	SHOP_GRID = "SHOP_GRID",              --商城网格
	

	NAV_BAG_BTN = "NAV_BAG_BTN",          --背包导航按钮
	BAG_RECYCLE_BTN = "BAG_RECYCLE_BTN",  --背包回收按钮
	BAG_SHOP_BTN = "BAG_SHOP_BTN",        --背包商店按钮
	BAG_SHOP_LIST_VIEW = "BAG_SHOP_LIST_VIEW", --背包商店物品列表
	BAG_ITEM_GRID = "BAG_ITEM_GRID",      --背包网格
	ITEM_TIP_USE_BTN = "ITEM_TIP_USE_BTN",  --物品tips使用按钮
	EQUIP_TIP_EUQIP_BTN = "EQUIP_TIP_EUQIP_BTN",--装备tips装备按钮

	RECYCLE_GOTO_BTN = "RECYCLE_GOTO_BTN", -- 回收前往
	RECYCLE_ONEKEY_BTN = "RECYCLE_ONEKEY_BTN",--一键回收按钮
	RECYCLE_ALLIN_BTN = "RECYCLE_ALLIN_BTN", -- 一键放进回收按钮

	NAV_EQUIPBOOST_BTN = "NAV_EQUIPBOOST_BTN", -- 锻造导航按钮
	EQUIPBOOST_QIANGHUA_BTN = "EQUIPBOOST_QIANGHUA_BTN", -- 锻造强化按钮
	EQUIPBOOST_COMPOUND_LIST_VIEW = "EQUIPBOOST_COMPOUND_LIST_VIEW", -- 锻造合成列表
	EQUIPBOOST_UPLEVEL_GRID = "EQUIPBOOST_UPLEVEL_GRID",--锻造升级物品列表
	EQUIPBOOST_UPLEVEL_BTN = "EQUIPBOOST_UPLEVEL_BTN",--锻造升级按钮

	NAV_LILIAN_BTN = "NAV_LILIAN_BTN", --导航历练按钮
	NAV_ACHIEVE_BTN = "NAV_ACHIEVE_BTN", --导航成就按钮
	ACHIEVE_AWARD_LIST_VIEW = "ACHIEVE_AWARD_LIST_VIEW", -- 成就奖励列表
	COMPOSE_XZ_ACTIVATE_BTN = "COMPOSE_XZ_ACTIVATE_BTN", -- 神炉勋章激活按钮

	NAV_BOSS_BTN = "NAV_BOSS_BTN",           --导航Boss按钮
	BOSS_PERSON_TIAOZHAN_BTN = "BOSS_PERSON_TIAOZHAN_BTN", --个人boss立即挑战按钮

	NAV_HP_MP_BTN = "NAV_HP_MP_BTN",  --导航血蓝切换按钮

	NAV_GUAJI_BTN = "NAV_GUAJI_BTN",  --导航挂机按钮

	NAV_SETTING_BTN = "NAV_SETTING_BTN",  --导航设置按钮
	SETTING_PROTECT_HP_CHECK_BOX = "SETTING_PROTECT_HP_CHECK_BOX", --设置面板回血挂机按钮

	NAV_JISHOU_BTN = "NAV_JISHOU_BTN",    --导航寄售按钮
	NAV_RANK_BTN = "NAV_RANK_BTN",    	  --导航排行按钮
	NAV_XUNBAO_BTN = "NAV_XUNBAO_BTN",    --导航寻宝按钮
	XUNBAO_XUNBAO1_BTN = "XUNBAO_XUNBAO1_BTN", -- 寻宝1次按钮
	
	NAV_ZHENGBA_BTN = "NAV_ZHENGBA_BTN",    --导航争霸按钮

	NAV_ACTIVITY_BTN = "NAV_ACTIVITY_BTN",  --导航活动按钮
	ACTIVITY_EVERYDAY_GRID = "ACTIVITY_EVERYDAY_GRID",--活动面板每日必做网格

	NPC_BUY_BUY_BTN = "NPC_BUY_BUY_BTN", --批量购买按钮

	NAV_WELFARE_BTN = "NAV_WELFARE_BTN", -- 导航福利按钮
	NAV_COMPLETE_BAG_BTN = "NAV_COMPLETE_BAG_BTN", -- 完整包导航按钮

	SMSZ_FLUSH_MONSTER_BTN = "SMSZ_FLUSH_MONSTER_BTN",--石墓烧猪刷怪按钮
	SMSZ_BUILD_TD_BTN = "SMSZ_BUILD_TD_BTN",--石墓烧猪一键箭塔按钮
	SMSZ_BUY_JIANHUANG_BTN = "SMSZ_BUY_JIANHUANG_BTN",--石墓烧猪购买剑皇
	SMSZ_REWARD_GRID = "SMSZ_REWARD_GRID", --石墓烧猪领奖网格

	NAV_KNIGHT_BTN = "NAV_KNIGHT_BTN", --侠客行导航按钮
	KNIGHT_AWARD_GRID = "KNIGHT_AWARD_GRID", --侠客行奖励网格

	NAV_ROLE_BTN = "NAV_ROLE_BTN",       -- 角色导航按钮
	ROLE_CIRCLE_BTN = "ROLE_CIRCLE_BTN", -- 角色转生按钮
	ROLE_EXCHANGE_XIUWEI_BTN = "ROLE_EXCHANGE_XIUWEI_BTN",-- 角色兑换修为按钮
	ROLE_WING_UP_BTN = "ROLE_WING_UP_BTN",-- 角色翅膀提升按钮
	ROLE_SKILL_GRID = "ROLE_SKILL_GRID",  --角色技能列表
	ROLE_MERIDIAN_ACTIVATE_BTN = "ROLE_MERIDIAN_ACTIVATE_BTN",--角色经脉激活按钮

	MAINUI_FLYSHOP_BTN = "MAINUI_FLYSHOP_BTN",    --主界面小飞鞋按钮

	SKILL_BAR_COMMON_CELL = "SKILL_BAR_COMMON_CELL", --技能栏通用攻击按钮

	COMMON_ALERT_OK_BTN = "COMMON_ALERT_OK_BTN", -- 通用提示面板的确定按钮
	COMMON_CLOSE_BTN = "btn_close_window",--通用面板关闭按钮
	NAV_CROSS_SER_ACT_BTN = "NAV_CROSS_SER_ACT_BTN",	-- 跨服活动导航按钮

	NAV_FUNCNOTE_BTN = "NAV_FUNCNOTE_BTN",--预告导航按钮
	FUNCNOTE_DATA_GRID = "FUNCNOTE_DATA_GRID",--功能预告网格
}


ClientCommonButtonDic = {} --全局零散组件表


ClientGuideCfg = 
{
	[1]={
			id = 1,                               --指引id,与索引对齐    战神
			max_level = 60,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = false,               --切换主界面
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.RoleLevel,value = {15,60},op = ClientOpType.Equ},
				{type = ClientGuideConditionType.HeroActiveId,value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 1, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.PrevScene,id = 147,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.ModuleNotVisible,value = "HeroProfChose",op = ClientOpType.Equ},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
			},
			steps = {
			    
				{type = ClientGuideStepType.AutoOpen,view_name = "HeroProfChose" , node_name = ""}
			},
		},
	--[[[2]={
			id = 2,                               --指引id,与索引对齐    设置保护
			max_level = 65,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.HasTask,id = 64,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.SettingCheckHp,value = false,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 2, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				
			},
			steps = {
				
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_SETTING_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "请点击设置按钮"},
				{type = ClientGuideStepType.CommonButton,view_name = "Setting" , node_name = "setting_protect", is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "选择保护选项"},
				{type = ClientGuideStepType.CommonButton,view_name = "Setting" , node_name = CommonButtonType.SETTING_PROTECT_HP_CHECK_BOX,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 2, sprite_content = "点击勾起血量保护自动吃药助你热血传奇"},
				{type = ClientGuideStepType.AutoClose,view_name = "Setting" , node_name = ""}
			},
		},
	[3]={
			id = 3,                               --指引id,与索引对齐    买药
			max_level = 48,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = false,               --切换主界面
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.UpLevel,value = 48,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.BagNilCount,value = 1,op = ClientOpType.HighEqu},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 3, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
			},
			steps = {
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_BAG_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击背包按钮"},
				{type = ClientGuideStepType.CommonButton,view_name = "Bag" , node_name = CommonButtonType.BAG_SHOP_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "打开商店"},
				{type = ClientGuideStepType.ListView,view_name = "Bag" , node_name = CommonButtonType.BAG_SHOP_LIST_VIEW, data = 2,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 2, sprite_content = "点击购买来购买恢复药水"},
				--{type = ClientGuideStepType.CommonButton,view_name = "NpcBuy" , node_name = CommonButtonType.NPC_BUY_BUY_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "这一次我们就先买一包，再次点击购买"},
				--{type = ClientGuideStepType.AutoClose,view_name = "Bag" , node_name = ""}
			},
		},]]
	[4]={   id = 4,                               --指引id,与索引对齐    VIP体验
			max_level = 60,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = false,               --切换主界面
			check_conditions = {                  --检测激活条件
				--{type = ClientGuideConditionType.HasTask,id = 52,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.BagItemCount,id = 4380  , value = 1,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.ModuleNotVisible,value = "Bag",op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 4, value = 1,op = ClientOpType.Low},
	            {type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
                {type = ClientGuideConditionType.VipLevel,value = 1,op = ClientOpType.Low},				
				
			},
			steps = {
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_BAG_BTN,is_modal = true,arrow = "up",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击按钮打开背包"},
				{type = ClientGuideStepType.Grid,view_name = "Bag" , node_name = CommonButtonType.BAG_ITEM_GRID, data = 4380,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "恭喜你获得VIP体验卡，请点击体验卡"},
				{type = ClientGuideStepType.CommonButton,view_name = "Bag" , node_name = CommonButtonType.ITEM_TIP_USE_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 0, sprite_content = "请再次点击使用，你获得30分钟的VIP时间"},
				{type = ClientGuideStepType.AutoClose,view_name = "Bag" , node_name = ""}
			},
		},
	--[[[5]={
			id = 5,                               --指引id,与索引对齐    吃药
			max_level = 60,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = false,               --切换主界面
			check_conditions = {                  --检测激活条件
			    {type = ClientGuideConditionType.UpLevel,value = 50,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.BagItemCount,id = 4206  , value = 1,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.ModuleNotVisible,value = "Bag",op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 5, value = 1,op = ClientOpType.Low},
				{type = ClientGuideStepType.AutoClose,view_name = "Bag" , node_name = ""},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
		
			},
			steps = {
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_BAG_BTN,is_modal = true,arrow = "up",is_show_sprite = true, sprite_dir = 6, sprite_content = "请点击背包按钮"},
				{type = ClientGuideStepType.Grid,view_name = "Bag" , node_name = CommonButtonType.BAG_ITEM_GRID, data = 4206,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击雪莲"},
				{type = ClientGuideStepType.CommonButton,view_name = "Bag" , node_name = CommonButtonType.ITEM_TIP_USE_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击使用，打BOSS和打架记得要吃雪莲哦"},
			},
		},]]
	[6]={
			id = 6,                               --指引id,与索引对齐    回收装备
			max_level = 60,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = false,               --切换主界面
			check_conditions = {                  --检测激活条件
			    {type = ClientGuideConditionType.RoleLevel,value = {54,60},op = ClientOpType.Equ},
				{type = ClientGuideConditionType.HasTask,id = 56,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.BagEquipCount,value = 1,op = ClientOpType.HighEqu},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 6, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},

				
			},
			steps = {
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_BAG_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "请点击背包按钮"},
				{type = ClientGuideStepType.CommonButton,view_name = "Bag" , node_name = CommonButtonType.BAG_RECYCLE_BTN, is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "你有多余的装备可回收，点击回收按钮"},
				{type = ClientGuideStepType.CommonButton,view_name = "Bag" , node_name = CommonButtonType.RECYCLE_GOTO_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击前往回收"},
				
			},
		},
	[7]={
			id = 7,                               --指引id,与索引对齐    回收装备
			max_level = 60,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = false,               --切换主界面
			ignore_close_module = "Recycle",      --指引忽略关闭的模块
			is_recycle_equip = true,              --是回收装备指引
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.RoleLevel,value = {54,60},op = ClientOpType.Equ},
				{type = ClientGuideConditionType.HasTask,id = 56,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.PreGuideID,id = 6,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.ModuleVisible,value = "Recycle",op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 7, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				
			},
			steps = {
			    {type = ClientGuideStepType.CommonButton,view_name = "Recycle" , node_name = CommonButtonType.RECYCLE_ONEKEY_BTN, is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击一键回收，将不需要的装备转换为经验和神盾"},
				{type = ClientGuideStepType.AutoClose,view_name = "Recycle" , node_name = ""},--自动关闭回收面板
				{type = ClientGuideStepType.AutoClose,view_name = "Bag" , node_name = ""},--自动关闭角色面板
			},
		},
	--[[[8]={
			id = 8,                               --指引id,与索引对齐    英雄穿戴
			max_level = 60,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
			   
				{type = ClientGuideConditionType.BagItemCount,id = 2  , value = 1,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.HeroHasDress,value = 1  ,op = ClientOpType.Low},
				{type = ClientGuideConditionType.HasTask,id = 29,op = ClientOpType.Equ},
			
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 8, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.HeroActiveId,value = 0,op = ClientOpType.High},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
			},
			steps = {
			   
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_ZHANSHEN_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 2, sprite_content = "穿戴英雄装备"},
				{type = ClientGuideStepType.CommonButton,view_name = "Zhanjiang" , node_name = "hero_bag",is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 0, sprite_content = "英雄装备要通过英雄背包穿戴"},
				{type = ClientGuideStepType.Grid,view_name = "Zhanjiang" , node_name = CommonButtonType.ZHANSHEN_BAG_ITEM_GRID, data = 2,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "选择穿戴装备"},
				{type = ClientGuideStepType.CommonButton,view_name = "Zhanjiang" , node_name = CommonButtonType.EQUIP_TIP_EUQIP_BTN, is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 0, sprite_content = "让英雄变得更强吧"},
				
				{type = ClientGuideStepType.AutoClose,view_name = "Zhanjiang" , node_name = ""}
			},
		},]]
	[9]={
			id = 9,                               --指引id,与索引对齐    英雄符文
			max_level = 60,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
			    
				{type = ClientGuideConditionType.HeroFuwenLevel,value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.AchieveNotGetAward,value = 413,op = ClientOpType.Equ},
				--{type = ClientGuideConditionType.HeroFuwenExp,value = 200  ,op = ClientOpType.HighEqu},
				--{type = ClientGuideConditionType.HasTask,id = 43,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.RoleLevel,value = {26,27},op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 9, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.HeroActiveId,value = 0,op = ClientOpType.High},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
			},
			steps = {
			   
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_FUNCNOTE_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 2, sprite_content = "英雄系统激活"},
				{type = ClientGuideStepType.Grid,view_name = "FuncNoteView" , node_name = CommonButtonType.FUNCNOTE_DATA_GRID, data = {413},is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "系统激活有解锁奖励，记得领取"},
				{type = ClientGuideStepType.Grid,view_name = "FuncNoteView" , node_name = CommonButtonType.FUNCNOTE_DATA_GRID, data = {413,1},is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "前往提升"},
				--{type = ClientGuideStepType.CommonButton,view_name = "Zhanjiang" , node_name = "hero_fuwen",is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 0, sprite_content = "英雄符文可提升英雄属性和技能等级"},
				{type = ClientGuideStepType.CommonButton,view_name = "Zhanjiang" , node_name = CommonButtonType.ZHANSHEN_FUWEN_UP_LEVEL_BTN, is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 0, sprite_content = "英雄符文可提升英雄属性和技能等级"},
				{type = ClientGuideStepType.AutoClose,view_name = "Zhanjiang" , node_name = ""},
				{type = ClientGuideStepType.AutoClose,view_name = "FuncNoteView" , node_name = ""},
			},
		},
	[10]={
			id = 10,                               --指引id,与索引对齐    翅膀
			max_level = 65,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			ignore_close_module = "FuncNoteView",      --指引忽略关闭的模块
			check_conditions = {                  --检测激活条件
			   
				{type = ClientGuideConditionType.WingExp,value = 30,op = ClientOpType.Low},
				{type = ClientGuideConditionType.WingLevel,value = 1,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.AchieveNotGetAward,value = 418,op = ClientOpType.Equ},
				--{type = ClientGuideConditionType.BagItemCount,id = 4091  , value = 3,op = ClientOpType.HighEqu},
				--{type = ClientGuideConditionType.ModuleNotVisible,value = "Role",op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 10, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.AchieveFinish,value = 418,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.ModuleVisible,value = "FuncNoteView",op = ClientOpType.Equ},

				
			},
			steps = {
			    {type = ClientGuideStepType.Grid,view_name = "FuncNoteView" , node_name = CommonButtonType.FUNCNOTE_DATA_GRID, data = {418},is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "翅膀系统开启，领取解锁奖励"},
				{type = ClientGuideStepType.Grid,view_name = "FuncNoteView" , node_name = CommonButtonType.FUNCNOTE_DATA_GRID, data = {418,1},is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "前往提升"},
				--{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_ROLE_BTN,is_modal = true,arrow = "up",is_show_sprite = true, sprite_dir = 2, sprite_content = "点击角色按钮打开角色界面"},
				--{type = ClientGuideStepType.TabButton,view_name = "Role" , node_name = "role_wing",is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "选择点击翅膀选项"},
				{type = ClientGuideStepType.CommonButton,view_name = "Role" , node_name = CommonButtonType.ROLE_WING_UP_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "翅膀可以培养，点击培养，提升翅膀提升战力"},
				{type = ClientGuideStepType.AutoClose,view_name = "Role" , node_name = ""},
				{type = ClientGuideStepType.AutoClose,view_name = "FuncNoteView" , node_name = ""},
			},
		},
	--[[[11]={
			id = 11,                              --指引id,与索引对齐    小飞翼
			max_level = 80,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_not_stop_move = true,              --强制指引不阻塞
			is_stop_path_end = true,              --人物停止移动就结束指引
			is_switch_main = false,               --切换主界面
			check_conditions = {                  --检测激活条件

				{type = ClientGuideConditionType.HasTask,id = 10,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.MovieGuideEnd,id = 3,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 11, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RolePathTaskId,id = 10, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
			},
			steps = {
			    
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.MAINUI_FLYSHOP_BTN,is_modal = true,arrow = "up",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击小飞鞋立即传送"},
				
			},
		},]]
	[12]={   
			id = 12,                               --指引id,与索引对齐    VIP体验烧猪
			max_level = 80,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = false,               --切换主界面
			ignore_close_module = "RewardGet",    --指引忽略关闭的模块
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.HasTask,id = 671,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.ModuleVisible,value = "RewardGet",op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 12, value = 1,op = ClientOpType.Low},
	            {type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},			
			},
			steps = {
			   
				{type = ClientGuideStepType.Grid,view_name = "RewardGet" , node_name = CommonButtonType.SMSZ_REWARD_GRID, data = 2,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "领取多倍奖励"},

			},
		},
	--[[[13]={
			id = 13,                               --指引id,与索引对齐    合击
			max_level = 70,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = false,               --切换主界面
			is_combine_skill = true,              --特殊的指引定义，定义这个变量只要使用了，就自动结束指引
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.CurScene,id = 148,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.CombineSkillCanUse,value = true,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 13, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.SelectBoss,value = true,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.SkillAutoUse,id = {81, 91, 101},value = false,op = ClientOpType.Equ},
				
			},
			steps = {
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.SKILL_BAR_COMMON_CELL,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "释放英雄合击"},
			},
		},	]]
	[14]={
			id = 14,                               --指引id,与索引对齐    战士合击自动设置 
			max_level = 80,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.Job,value = 1,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.SkillAutoUse,id = {81},value = false,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.HasTask,id = 29,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 14, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				
			},
			steps = {
				
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_ROLE_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 2, sprite_content = "设置技能自动释放"},
				{type = ClientGuideStepType.TabButton,view_name = "Role" , node_name = "role_skill", is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "技能组合，更有效率地战斗"},
				{type = ClientGuideStepType.Grid,view_name = "Role" , node_name = CommonButtonType.ROLE_SKILL_GRID, data = 81,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "勾选自动释放"},
				{type = ClientGuideStepType.AutoClose,view_name = "Role" , node_name = ""}
			},
		
		},
	[15]={
			id = 15,                               --指引id,与索引对齐    法师合击自动设置 
			max_level = 80,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.Job,value = 2,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.SkillAutoUse,id = {91},value = false,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.HasTask,id = 29,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 15, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				
			},
			steps = {
				
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_ROLE_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 2, sprite_content = "设置技能自动释放"},
				{type = ClientGuideStepType.TabButton,view_name = "Role" , node_name = "role_skill", is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "技能组合，更有效率地战斗"},
				{type = ClientGuideStepType.Grid,view_name = "Role" , node_name = CommonButtonType.ROLE_SKILL_GRID, data = 91,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "勾选自动释放"},
				{type = ClientGuideStepType.AutoClose,view_name = "Role" , node_name = ""}
			},
		
		},
	[16]={
			id = 16,                               --指引id,与索引对齐    道士合击自动设置 
			max_level = 80,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.Job,value = 3,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.SkillAutoUse,id = {101},value = false,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.HasTask,id = 29,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 16, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				
			},
			steps = {
				
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_ROLE_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 2, sprite_content = "设置技能自动释放"},
				{type = ClientGuideStepType.TabButton,view_name = "Role" , node_name = "role_skill", is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "技能组合，更有效率地战斗"},
				{type = ClientGuideStepType.Grid,view_name = "Role" , node_name = CommonButtonType.ROLE_SKILL_GRID, data = 101,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "勾选自动释放"},
				{type = ClientGuideStepType.AutoClose,view_name = "Role" , node_name = ""}
				
			},
		
		},
	
	[17]={
			id = 17,                               --指引id,与索引对齐    石墓烧猪
			max_level = 80,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = false,               --切换主界面
			ignore_close_module = "SmszView",    --指引忽略关闭的模块
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.HasTask,id = 671,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 17, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.PrevScene,id = 20,op = ClientOpType.Equ},
				
				
			},
			steps = {
				
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.SMSZ_BUILD_TD_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "一键摆放守卫"},
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.SMSZ_FLUSH_MONSTER_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "开始刷怪"},
				
				
			},
		
		},	
	[18]={
			id = 18,                               --指引id,与索引对齐    血符
			max_level = 45,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			ignore_close_module = "FuncNoteView",      --指引忽略关闭的模块
			check_conditions = {                  --检测激活条件AchieveFinish
				{type = ClientGuideConditionType.UpLevel,value = 42,op = ClientOpType.Equ},
			    {type = ClientGuideConditionType.EquipXf,value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.AchieveFinish,value = 414,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.ModuleVisible,value = "FuncNoteView",op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 18, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.AchieveNotGetAward,value = 414,op = ClientOpType.Equ},
				
			},
			steps = {
				{type = ClientGuideStepType.Grid,view_name = "FuncNoteView" , node_name = CommonButtonType.FUNCNOTE_DATA_GRID, data = {414},is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "血符系统开启，领取解锁奖励"},
				{type = ClientGuideStepType.Grid,view_name = "FuncNoteView" , node_name = CommonButtonType.FUNCNOTE_DATA_GRID, data = {414,1},is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "前往提升"},
				--{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_COMPOSE_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "激活血符"},
				{type = ClientGuideStepType.CommonButton,view_name = "Compose" , node_name = CommonButtonType.COMPOSE_XF_ACTIVATE_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "增加血上限"},
				{type = ClientGuideStepType.AutoClose,view_name = "Compose" , node_name = ""},
				{type = ClientGuideStepType.AutoClose,view_name = "FuncNoteView" , node_name = ""},
				
				
			},
		
		},	
	--[[[19]={
			id = 19,                               --指引id,与索引对齐    回收装备
			max_level = 45,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = false,               --切换主界面
			check_conditions = {                  --检测激活条件
			    {type = ClientGuideConditionType.HasTask,id = 44,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.BagEquipCount,value = 1,op = ClientOpType.HighEqu},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 19, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},

				
			},
			steps = {
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_BAG_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "请点击背包按钮"},
				{type = ClientGuideStepType.CommonButton,view_name = "Bag" , node_name = CommonButtonType.BAG_RECYCLE_BTN, is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "你有多余的装备可回收，点击回收按钮"},
				{type = ClientGuideStepType.CommonButton,view_name = "Bag" , node_name = CommonButtonType.RECYCLE_GOTO_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击前往回收"},
				
			},
		},
	[20]={
			id = 20,                               --指引id,与索引对齐    回收装备
			max_level = 66,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = false,               --切换主界面
			is_recycle_equip = true,
			ignore_close_module = "Recycle",      --指引忽略关闭的模块
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.HasTask,id = 44,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.PreGuideID,id = 19,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.ModuleVisible,value = "Recycle",op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 20, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				
			},
			steps = {
				{type = ClientGuideStepType.CommonButton,view_name = "Recycle" , node_name = CommonButtonType.RECYCLE_ONEKEY_BTN, is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击一键回收，将不需要的装备转换为经验和神盾"},
				{type = ClientGuideStepType.AutoClose,view_name = "Recycle" , node_name = ""},--自动关闭回收面板
				{type = ClientGuideStepType.AutoClose,view_name = "Bag" , node_name = ""},--自动关闭角色面板
			},
		},]]
	[21]={
			id = 21,                               --指引id,与索引对齐    经脉
			max_level = 80,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			ignore_close_module = "FuncNoteView",      --指引忽略关闭的模块
			check_conditions = {                  --检测激活条件
			   
				{type = ClientGuideConditionType.UpLevel,value = 74,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.AchieveFinish,value = 427,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.ModuleVisible,value = "FuncNoteView",op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 21, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.AchieveNotGetAward,value = 427,op = ClientOpType.Equ},
				
			},
			steps = {
				
				{type = ClientGuideStepType.Grid,view_name = "FuncNoteView" , node_name = CommonButtonType.FUNCNOTE_DATA_GRID, data = {427},is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "经脉系统开启，领取解锁奖励"},
				{type = ClientGuideStepType.Grid,view_name = "FuncNoteView" , node_name = CommonButtonType.FUNCNOTE_DATA_GRID, data = {427,1},is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "前往提升"},
				--{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_COMPOSE_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "激活血符"},
				{type = ClientGuideStepType.CommonButton,view_name = "Compose" , node_name = CommonButtonType.ROLE_MERIDIAN_ACTIVATE_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "提升经脉，增强属性"},
				{type = ClientGuideStepType.AutoClose,view_name = "Role" , node_name = ""},
				{type = ClientGuideStepType.AutoClose,view_name = "FuncNoteView" , node_name = ""},
			},
		},	
	--[[[22]={
			id = 22,                               --指引id,与索引对齐    经脉
			max_level = 70,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
			   
				{type = ClientGuideConditionType.HasTask,id = 55,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.RoleLevel,value = {50,70},op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 22, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},

				
			},
			steps = {
				{type = ClientGuideStepType.AutoOpen,view_name = "Equipment" , node_name = "equipment_compound"},
				--{type = ClientGuideStepType.TabButton,view_name = "Role" , node_name = "role_meridians",is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "选择点击翅膀选项"},
				{type = ClientGuideStepType.Grid,view_name = "Equipment" , node_name = "EQUIPBOOST_COMPOUND_LIST_VIEW",data = 1 ,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击合成武器"},
				{type = ClientGuideStepType.AutoClose,view_name = "Equipment" , node_name = ""},
			
			},
		},	
	[23]={
			id = 23,                               --指引id,与索引对齐    没任务活动指引
			max_level = 90,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
			   
				{type = ClientGuideConditionType.TaskCount,value = 3,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleLevel,value = {70,90},op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 23, value = 1,op = ClientOpType.Low},
				

				
			},
			steps = {
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" ,node_name = "NAV_ACTIVITY_BTN",data = 1 ,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "选择活动参与，更多经验与奖励等着你"},
				
				
			
			},
		},	
	[24]={
			id = 24,                               --指引id,与索引对齐    伏魔任务
			max_level = 80,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
			   
				{type = ClientGuideConditionType.HasTask,id = 708,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.RoleLevel,value = {70,80},op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 24, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.FumoTaskFinishCount,value = 1  ,op = ClientOpType.Low},

				
			},
			steps = {
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" ,node_name = "NAV_ACTIVITY_BTN",data = 1 ,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "卡级任务需要更多的经验"},
				{type = ClientGuideStepType.Grid,view_name = "Activity" , node_name = CommonButtonType.ACTIVITY_EVERYDAY_GRID, data = 3,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "伏魔任务海量经验等着你"},
				
			
			},
		},	
	[25]={
			id = 25,                               --指引id,与索引对齐    英雄祝福油
			max_level = 80,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
			    {type = ClientGuideConditionType.HasTask,id = 48,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.BagItemCount,id = 4234  , value = 1,op = ClientOpType.HighEqu},
				{type = ClientGuideConditionType.HeroHasWuqi,value = 1  ,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 25, value = 1,op = ClientOpType.Low},
				
			},
			steps = {
			   
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_ZHANSHEN_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 2, sprite_content = "英雄武器也可以祝福"},
				{type = ClientGuideStepType.CommonButton,view_name = "Zhanjiang" , node_name = "hero_bag",is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 0, sprite_content = "英雄也有单独的背包"},
				{type = ClientGuideStepType.Grid,view_name = "Zhanjiang" , node_name = CommonButtonType.ZHANSHEN_BAG_ITEM_GRID, data = 4234,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击祝福油"},
				{type = ClientGuideStepType.CommonButton,view_name = "Zhanjiang" , node_name = CommonButtonType.ITEM_TIP_USE_BTN, is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 0, sprite_content = "祝福增加幸运，可以打出更大伤害"},
				
				{type = ClientGuideStepType.AutoClose,view_name = "Zhanjiang" , node_name = ""}
			},
		},	]]
		
	[26]={
		   id = 26,                               --指引id,与索引对齐    寻宝
		   max_level = 95,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
		   is_hide_main = true,                  --主界面隐藏
		   check_conditions = {                  --检测激活条件
			{type = ClientGuideConditionType.RoleLevel,value = {68,100},op = ClientOpType.Equ},
			{type = ClientGuideConditionType.BagItemCount,id = 4271,value = 1,op = ClientOpType.HighEqu},
			{type = ClientGuideConditionType.XunBaoJifen,value = 1,op = ClientOpType.LowEqu},
			{type = ClientGuideConditionType.GuideSelfExeCount,id = 26, value = 1,op = ClientOpType.Low},
			
		},
		    steps = {
		    --{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_HP_MP_BTN,is_modal = true,arrow = "down"},
			{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_XUNBAO_BTN,is_modal = true,arrow = "up",is_show_sprite = true, sprite_dir = 6, sprite_content = "恭喜你获得了寻宝钥匙，打开寻宝按钮"},
			{type = ClientGuideStepType.CommonButton,view_name = "Explore" , node_name = CommonButtonType.XUNBAO_XUNBAO1_BTN,is_modal = true,arrow = "up",is_show_sprite = true, sprite_dir = 0, sprite_content = "点击寻宝一次，寻宝一次优先消耗钥匙"},
			--{type = ClientGuideStepType.CommonButton,view_name = "Role" , node_name = CommonButtonType.ROLE_CIRCLE_BTN,is_modal = true,arrow = "down"},
		},
	},	
	[27]={
		   id = 27,                               --指引id,与索引对齐    寻宝
		   max_level = 75,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
		   is_hide_main = true,                  --主界面隐藏
		   check_conditions = {                  --检测激活条件
			{type = ClientGuideConditionType.RoleLevel,value = {61,75},op = ClientOpType.Equ},
			{type = ClientGuideConditionType.HeroWingActive,id = 1,value = 2,op = ClientOpType.Equ},
			{type = ClientGuideConditionType.GuideSelfExeCount,id = 27, value = 1,op = ClientOpType.Low},
			
		},
		    steps = {
		    --{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_HP_MP_BTN,is_modal = true,arrow = "down"},
			{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.ZHANSHEN_WING_NAV_BTN,is_modal = true,arrow = "up",is_show_sprite = true, sprite_dir = 6, sprite_content = "英雄光翼已经激活"},
			{type = ClientGuideStepType.CommonButton,view_name = "HeroWing" , node_name = CommonButtonType.ZHANSHEN_WING_WEAR_BTN,is_modal = true,arrow = "up",is_show_sprite = true, sprite_dir = 0, sprite_content = "点击穿戴，英雄属性倍增"},
			{type = ClientGuideStepType.AutoClose,view_name = "HeroWing" , node_name = ""},--自动关闭回收面板
		},
	},	
	[28]={
		   id = 28,                               --指引id,与索引对齐    寻宝
		   max_level = 150,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
		   is_hide_main = true,                  --主界面隐藏
		   is_not_auto_task = true,              --指引结束不自动任务
		   is_stop_auto_fight = true,            --停止挂机
		   check_conditions = {                  --检测激活条件
			{type = ClientGuideConditionType.CurScene,id = 175,op = ClientOpType.Equ},
			{type = ClientGuideConditionType.SceneMonsterCount,id = 1465,value = 1,op = ClientOpType.Low},
			{type = ClientGuideConditionType.GuideSelfExeCount,id = 28, value = 1,op = ClientOpType.Low},
			{type = ClientGuideConditionType.SceneNpcCount, value = 2,op = ClientOpType.Equ},
			
		},
		    steps = {
		    {type = ClientGuideStepType.ClickNpc,npc_id = 192,scene_id = 175, x = 12, y = 35},
			{type = ClientGuideStepType.DelayTime, time = 2}
		},
	},	
	[29]={
		   id = 29,                               --指引id,与索引对齐    寻宝
		   max_level = 75,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
		   is_hide_main = true,                  --主界面隐藏
		   is_not_auto_task = true,              --指引结束不自动任务
		   is_stop_auto_fight = true,            --停止挂机
		   check_conditions = {                  --检测激活条件
			{type = ClientGuideConditionType.CurScene,id = 175,op = ClientOpType.Equ},
			{type = ClientGuideConditionType.SceneMonsterCount,id = 1474,value = 1,op = ClientOpType.Low},
			{type = ClientGuideConditionType.GuideSelfExeCount,id = 29, value = 1,op = ClientOpType.Low},
			{type = ClientGuideConditionType.PreGuideID,id = 28, value = 1,op = ClientOpType.Equ},
			{type = ClientGuideConditionType.SceneNpcCount, value = 2,op = ClientOpType.Low},
			{type = ClientGuideConditionType.SceneItemCount, value = 1,op = ClientOpType.Low},
			
		},
		    steps = {
		    {type = ClientGuideStepType.ClickNpc,npc_id = 193,scene_id = 175, x = 16, y = 39},
			{type = ClientGuideStepType.DelayTime, time = 2}
		},
	},	
	[30]={
			id = 30,                               --指引id,与索引对齐    锻造
			max_level = 60,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
			    {type = ClientGuideConditionType.AchieveFinish,value = 416,op = ClientOpType.Equ},
				--{type = ClientGuideConditionType.ModuleVisible,value = "FuncNoteView",op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 30, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},   
				{type = ClientGuideConditionType.AchieveNotGetAward,value = 416,op = ClientOpType.Equ},
				
			},
			steps = {
			   
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_FUNCNOTE_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 2, sprite_content = "锻造系统激活"},
				{type = ClientGuideStepType.Grid,view_name = "FuncNoteView" , node_name = CommonButtonType.FUNCNOTE_DATA_GRID, data = {416},is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "系统激活有解锁奖励，记得领取"},
				--{type = ClientGuideStepType.AutoClose,view_name = "Zhanjiang" , node_name = ""},
				{type = ClientGuideStepType.AutoClose,view_name = "FuncNoteView" , node_name = ""},
			},
		},
	[31]={
			id = 31,                               --指引id,与索引对齐    战士装备升级 
			max_level = 90,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.Job,value = 1,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.RoleEquip,value = 145,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.HasTask,id = 821,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 31, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				
			},
			steps = {
				
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_EQUIPBOOST_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 2, sprite_content = "有装备可以升级"},
				{type = ClientGuideStepType.TabButton,view_name = "Equipment" , node_name = "equipment_uplv",is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "选择升级界面"},
				{type = ClientGuideStepType.Grid,view_name = "Equipment" , node_name = CommonButtonType.EQUIPBOOST_UPLEVEL_GRID, data = 145,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "选择升级装备"},
				{type = ClientGuideStepType.CommonButton,view_name = "Equipment" , node_name = CommonButtonType.EQUIPBOOST_UPLEVEL_BTN, is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击升级"},
				{type = ClientGuideStepType.AutoClose,view_name = "Equipment" , node_name = ""}
			},
		
		},	
	[32]={
			id = 32,                               --指引id,与索引对齐    法师装备升级 
			max_level = 90,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.Job,value = 2,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.RoleEquip,value = 155,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.HasTask,id = 821,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 32, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				
			},
			steps = {
				
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_EQUIPBOOST_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 2, sprite_content = "有装备可以升级"},
				{type = ClientGuideStepType.TabButton,view_name = "Equipment" , node_name = "equipment_uplv",is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "选择升级界面"},
				{type = ClientGuideStepType.Grid,view_name = "Equipment" , node_name = CommonButtonType.EQUIPBOOST_UPLEVEL_GRID, data = 155,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "选择升级装备"},
				{type = ClientGuideStepType.CommonButton,view_name = "Equipment" , node_name = CommonButtonType.EQUIPBOOST_UPLEVEL_BTN, is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击升级"},
				{type = ClientGuideStepType.AutoClose,view_name = "Equipment" , node_name = ""}
			},
		
		},	
	[33]={
			id = 33,                               --指引id,与索引对齐    道士装备升级 
			max_level = 90,                       --指引存在的最大等级，只是作为优化性能检测,不作为激活条件
			is_switch_main = true,               --切换主界面
			check_conditions = {                  --检测激活条件
				{type = ClientGuideConditionType.Job,value = 3,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.RoleEquip,value = 165,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.HasTask,id = 821,op = ClientOpType.Equ},
				{type = ClientGuideConditionType.GuideSelfExeCount,id = 33, value = 1,op = ClientOpType.Low},
				{type = ClientGuideConditionType.RoleCircle,value = 1,op = ClientOpType.Low},
				
			},
			steps = {
				
				{type = ClientGuideStepType.CommonButton,view_name = "MainUi" , node_name = CommonButtonType.NAV_EQUIPBOOST_BTN,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 2, sprite_content = "有装备可以升级"},
				{type = ClientGuideStepType.TabButton,view_name = "Equipment" , node_name = "equipment_uplv",is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "选择升级界面"},
				{type = ClientGuideStepType.Grid,view_name = "Equipment" , node_name = CommonButtonType.EQUIPBOOST_UPLEVEL_GRID, data = 165,is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "选择升级装备"},
				{type = ClientGuideStepType.CommonButton,view_name = "Equipment" , node_name = CommonButtonType.EQUIPBOOST_UPLEVEL_BTN, is_modal = true,arrow = "down",is_show_sprite = true, sprite_dir = 6, sprite_content = "点击升级"},
				{type = ClientGuideStepType.AutoClose,view_name = "Equipment" , node_name = ""}
			},
		
		},		
}
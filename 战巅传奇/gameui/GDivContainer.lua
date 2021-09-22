--ui管理器： name是对应lua文件的名字，res=1表示这个ui需要加载资源， noBorder=1 表示有背景了， 
--noCache=1 表示UI不需要缓存，  btnClose=1，表示需要为ui添加关闭按钮。
--
local panel_all = {
	["panel_menu"] 			= 	{name = "ContainerMenuList",		closeDir = 1,	res=1, noBoader=1, },
	["main_compose"] 		= 	{name = "PanelCompose",		closeDir = 1,	res=1, noBoader=1,noCache=1,btnClose = 1},
	["menu_recycle"]		=	{name = "ContainerRecyle",		closeDir = 1,	res=1, noBoader=1, noCache=1,closeCall=1,btnClose = 1},
	["main_achieve"]		=	{name = "ContainerAttainment",		closeDir = 1,	res=1, noBoader=1, noCache=1,closeCall=1,btnClose = 1},
	["panel_quickset"] 		= 	{name = "ContainerQuickOperate",	closeDir = 1,	res=1, noBoader=1, noCache=1,btnClose = 1},
	["menu_bag"] 			= 	{name = "ContainerBag",			closeDir = 1,	res=1, noBoader=1,noCache=1,btnClose = 1,	startPosX=958,	startPosY=300},
	["main_avatar"]	 		= 	{name = "ContainerCharacter",		closeDir = 1,	res=1, noBoader=1,noCache=1,closeCall=1,btnClose = 0,	startPosX=368,	startPosY=118},
	["main_skill"]	 		= 	{name = "ContainerSkill",		closeDir = 1,	res=1, noBoader=1,noCache=1,closeCall=1,btnClose = 1},
	["panel_minimap"] 		= 	{name = "ContainerMapPreviewer",		closeDir = 1,	res=1, noBoader=1,	noCache=1,startPosX=988,	startPosY=580},
	["panel_npctalk"] 		= 	{name = "ContainerTalkNpc",		closeDir = 1,	noBoader=1,noCache = 1,btnClose = 1},
	["panel_relive"]		=	{name = "ContainerQuickRelive",		closeDir = 1,	noBoader=1, noBg = 1, noCache=1},
	--PanelCaiLiao
	["panel_cailiao"]		=	{name = "PanelCaiLiao",	    closeDir = 1,	res = 1, noBoader=1,noCache=1, btnClose = 1},
	
	["panel_depot"]			=	{name = "ContainerWareHouse",		closeDir = 1,	res = 1, noBoader=1,noCache=1,btnClose = 1},
	["main_friend"]			=	{name = "ContainerFriend",		closeDir = 1,	res=1, noBoader=1,noCache=1,btnClose = 1},
	["btn_main_rank"] 		= 	{name = "ContainerTable",		closeDir = 1,	res=1, noBoader=1,noCache=1, btnClose = 1},
	["panel_chart_yx"] 		= 	{name = "ContainerTableYX",		closeDir = 1,	noBg = 1,noCache=1, noBoader=1},
	["main_mail"]			= 	{name = "ContainerEMail",		closeDir = 1,	res=1, noBoader=1,noCache=1, btnClose = 1},
	["panel_trade"]			=	{name = "ContainerExchange",		closeDir = 1,	res=1, noBoader=1,btnClose = 1,closeCall=1,noCache=1},

	["btn_main_wing"] 		= 	{name = "ContainerFly",		closeDir = 1,	res=1, noBoader=1,noCache=1, btnClose = 1},
	--合成熔炉
	["main_furnace"] 		= 	{name = "ContainerStove",		closeDir = 1,	res=1, noBoader=1,noCache=1,btnClose = 0},
	["main_group"] 			= 	{name = "ContainerGroup",		closeDir = 1,	res=1, noBoader=1,noCache=1, btnClose = 1},

	["main_guild"]			= 	{name = "ContainerGang",		closeDir = 1,	res=1, noBoader=1, noCache=1, btnClose = 1},

	["extend_exploit"] 		= 	{name = "ContainerFeats",		closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1, closeCall=1},
	--锻造强化
	["main_forge"] 			= 	{name = "ContainerSmelt",		closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	["extend_breakup"] 		= 	{name = "ContainerBarrier",		closeDir = 1,	res=1,noBoader=1, noCache=1,closeCall=1,btnClose = 1},
	["panel_chat"] 			= 	{name = "ContainerIM",		closeDir = 0,	closeScale=1,	openScale=1,	res=1,noBoader=1, noCache=1,closeCall=1,noMask=1, pos="left"},
	
	["panel_playertalk"]	= 	{name = "ContainerNpcTalk",		closeDir = 0,	closeScale=1,	openScale=1,	 noMask=1, noBoader=1, noCache=1, closeCall=1, pos="left"},
	["panel_chumo"]			= 	{name = "PanelChuMo",		closeDir = 0,	closeScale=1,	openScale=1,	 noMask=1, noBoader=1, noCache=1, closeCall=1, pos="left"},

	["extend_world"]		=	{name = "ContainerActivityList",	closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1,	startPosX=788,	startPosY=440},

	["extend_mars"]			= 	{name = "ContainerWarProtecter",		closeDir = 1,	res=1,noBoader=1,noCache=1,closeCall=1,btnClose = 1},

	["btn_main_boss"] 		= 	{name = "ContainerBossMonster",		closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1,	startPosX=788,	startPosY=540},
	["panel_charge"] 		= 	{name = "ContainerRecharge",	closeDir = 1,	res=1,noBoader=1, noCache=1, closeCall=1,btnClose = 1},
	["panel_vip"] 			= 	{name = "ContainerVip",		closeDir = 1,	res=1,noBoader=1, noCache=1, closeCall=1,btnClose = 1},
	["extend_makeExp"]		= 	{name = "ContainerExp",		closeDir = 1,	res=1,noBoader=1,btnClose = 1},

	["main_official"] 		= 	{name = "ContainerPrestige",	closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	["menu_setting"] 		= 	{name = "ContainerSetting",		closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	["extend_kingWar"] 		= 	{name = "ContainerWarCity",	closeDir = 1,	res=1, noBoader=1,	noCache=1, btnClose = 1,	startPosX=748,	startPosY=540},
	["extend_worship"] 		= 	{name = "ContainerPray", 	closeDir = 1,	res=1,noBoader=1,	noCache=1, btnClose = 1},
	["main_consign"]		= 	{name = "ContainerConsignment",	    closeDir = 1,	res=1, noBoader=1, noCache=1, btnClose = 1,	startPosX=688,	startPosY=440},

	["panel_groupapply"]	= 	{name = "ContainerGroupApply",	closeDir = 1,	res=1, noBoader=1,noCache=1, btnClose = 1},
	["extend_offline"]		= 	{name = "ContainerHangUp",		closeDir = 1,	res=1,noBoader=1,btnClose = 1,noCache=1,},

	["panel_dart"]			= 	{name = "PanelDart",		closeDir = 1,	res=1,noBoader=1,noCache=1, btnClose = 1},
	["panel_mainTask"] 		= 	{name = "ContainerTask",	closeDir = 0, noMask=1, noBoader=1, noCache=1, closeCall=1, pos="left"},

	["panel_acttip"] 		= 	{name = "ContainerActivityMin",	closeDir = 1,	noBoader=1, noCache=1, closeCall=1,btnClose = 1},

	["extend_lottory"] 		= 	{name = "ContainerLottery",	    closeDir = 1,	res=1,noBoader=1, noCache=1, closeCall=1},

	["main_convert"] 		= 	{name = "ContainerLotteryExchange",	closeDir = 1,	noBoader=1, noCache=1, closeCall=1,btnClose = 1},

	["extend_store"] 		= 	{name = "ContainerMall",	closeDir = 1,	res=1,noBoader=1, noCache=1,closeCall=1,btnClose = 0,	startPosY=540},

	--奖励大厅
	["extend_awardHall"]   = 	{name = "ContainerReward",	closeDir = 1,	res=1,noBoader=1, noCache=1, closeCall=1,btnClose = 1},
	["extend_firstPay"]   = 	{name = "ContainerRechargeFirst",	closeDir = 1,	res=1,noBoader=1, noCache=1, closeCall=1,	startPosY=540},

	["panel_checkequip"]   = 	{name = "ContainerOtherCharacter",	closeDir = 1,	res=1,noBoader=1, noCache=1, closeCall=1,btnClose = 1},

	["extend_zhuanPan"]   = 	{name = "PanelZhuanPan",	closeDir = 1,	res=1,noBoader=1, noCache=1, closeCall=1,btnClose = 1},

	["panel_shaozhuaward"] = 	{name = "ContainerPigAward", closeDir = 1,	res=1,noBoader=1, noCache=1, closeCall=1,btnClose = 1},
	
	["extend_openServer"] = 	{name = "ContainerActivities", closeDir = 1,	res=1,noBoader=1, noCache=1, closeCall=1,btnClose = 1},
	["extend_activities"] = 	{name = "PanelCelebrationAct", closeDir = 1,	res=1,noBoader=1, closeCall=1,btnClose = 1},

	["menpai_chart"] 		= 	{name = "PanelMenPaiChart", closeDir = 1,	res=1,noBoader=1, noCache=1, closeCall=1,btnClose = 1},
	["menpai_store"] 		= 	{name = "PanelMenPaiStore", closeDir = 1,	res=1,noBoader=1, noCache=1, closeCall=1,btnClose = 1},

	["extend_heFu"] 		= 	{name = "ContainerWholeActivities", closeDir = 1,	res=1,noBoader=1,noCache=1,closeCall=1,btnClose = 1},
	["extend_strengthen"]   = 	{name = "ContainerConsolidate", closeDir = 1,	res=1,noBoader=1,noCache=1, closeCall=1,btnClose = 1},

	["extend_dailyPay"]     = 	{name = "ContainerRechageDaily", closeDir = 1,	res=1,noBoader=1,noCache=1, closeCall=1,btnClose = 1,	startPosY=540},
	["panel_levelTip"]      = 	{name = "ContainerLevelUp", closeDir = 1,	res=1,noBoader=1,noCache=1, closeCall=1},

	--投资计划
	["extend_invest"]		= 	{name = "ContainerEarnMoney", closeDir = 1,	res=1,noCache=1,noBoader=1,closeCall=1,btnClose = 1},
	["extend_events"]       = 	{name = "ContainerSuperActivities", closeDir = 1,	res=1,noCache=1, noBoader=1,closeCall=1,btnClose = 1},
	["extend_dice"]         = 	{name = "ContainerWarGhost", closeDir = 1,	res=1,noCache=1,noBoader=1,closeCall=1,btnClose = 1},
	["extend_download"]     = 	{name = "PanelDownLoad", closeDir = 1,	res=1,noBoader=1,closeCall=1,btnClose = 1},
	["panel_defend"]		= 	{name = "PanelDefend", closeDir = 1,	res=1, noBoader=1,noCache=1,closeCall=1,btnClose = 1},
	["main_puzzle"]       	= 	{name = "PanelBossPictrue", closeDir = 1,	res=1,noBoader=1,noCache=1, closeCall=1,btnClose = 1},

	["extend_superVip"]       = {name = "ContainerSuperVip", closeDir = 1,	res=1,noBoader=1,noCache=1, closeCall=1,btnClose = 1},
	["extend_hecheng"]      =   {name = "ContainerHeCheng", closeDir = 1,	res=1,noBoader=1,noCache=1, closeCall=1,btnClose = 1},
	["panel_quickAddEquip"] =	{name = "ContainerQuickEquip", closeDir = 1,	res=1,noBoader=1,noCache=1, closeCall=1,btnClose = 1},
	--地图传送 
	["container_npc_maplist"] =	{name = "ContainerNpcMapList", closeDir = 1,	res=1,noCache=1,noBoader=1,closeCall=1,btnClose = 1},
	--地图传送 (含BOSS展示、掉落、要求)
	["npc_map_v9"] =	{name = "ContainerNpcMapV9", closeDir = 1,	res=1,noCache=1,noBoader=1,closeCall=1,btnClose = 1},
	["npc_map_v11"] =	{name = "ContainerNpcTalkV11", closeDir = 1,	res=1,noCache=1,noBoader=1,closeCall=1,btnClose = 1},
	--转生 
	["container_reborn"] =	{name = "ContainerReborn", closeDir = 1,	res=1,noCache=1,noBoader=1,closeCall=1,btnClose = 1},
	--称号升级 
	["container_title"] =	{name = "ContainerTitle", closeDir = 1,	res=1,noCache=1,noBoader=1,closeCall=1,btnClose = 1},
	--装备洗炼 
	["container_equip_wash"] =	{name = "ContainerEquipWash", closeDir = 1,	res=1,noCache=1,noBoader=1,closeCall=1,btnClose = 1},
	--回城提示
	["container_back_to_home"] =	{name = "ContainerBackToHome",closeDir = 1,	noCache=1, noBoader=1,closeCall=1},
	--魂环 
	["container_hunhuan"] =	{name = "ContainerHunHuan", closeDir = 1,	res=1,noCache=1,noBoader=1,closeCall=1,btnClose = 1},
	--我的魂环 
	["container_my_hunhuan"] =	{name = "ContainerCharacter_HunHuan", closeDir = 1,	res=1,noCache=1,noBoader=1,closeCall=1,btnClose = 1},
	--我的足迹
	["container_my_zuji"] =	{name = "ContainerCharacter_ZuJi", closeDir = 1,	res=1,noCache=1,noBoader=1,closeCall=1,btnClose = 1},
	--攻略
	["container_help"] =	{name = "ContainerHelp", closeDir = 1,	res=1,noCache=1,noBoader=1,closeCall=1,btnClose = 1,	startPosX=668,	startPosY=540},
	
	--赞助礼包
	["extend_rechargeGift"] =	{name = "ContainerRechargeGift", closeDir = 1,	 res=1,noBoader=1,noCache=1,btnClose = 1,	startPosX=448,	startPosY=540},
	--透视礼包充值
	["extend_rechargeTouShi"] =	{name = "ContainerRechargeTouShi", closeDir = 1,	 res=1,noBoader=1,noCache=1,btnClose = 1},
	--充值点礼包(开服大礼)
	["extend_rechargePointGift"] =	{name = "ContainerRechargePointGift", closeDir = 1,	 res=1,noBoader=1,noCache=1,btnClose = 1,	startPosX=448,	startPosY=540},
	--连续充值礼包
	["extend_rechargeLianXuGift"] =	{name = "ContainerRechargeEveryDay", closeDir = 1,	 res=1,noBoader=1,noCache=1,btnClose = 1,	startPosX=448,	startPosY=540},
	
	
	
	
	
	--星座
	["panel_constellation"] =	{name = "ContainerConstellation", closeDir = 1,	noBoader=1,noCache=1,btnClose = 1},
	--剑鞘
	["panel_jianqiao"] =	{name = "ContainerJianQiao", closeDir = 1,	noBoader=1,noCache=1,btnClose = 1},
	--佛经
	["panel_fojing"] =	{name = "ContainerFoJing", closeDir = 1,	noBoader=1,noCache=1,btnClose = 1},
	--玄魂(6格)
	["panel_xuanhun"] =	{name = "ContainerXuanHun", closeDir = 1,	noBoader=1,noCache=1,btnClose = 1},
	--玄界破天等级世界
	["v4_panel_dengjishijie"] =	{name = "V4_ContainerDengJiShiJie", closeDir = 1,	noBoader=1,noCache=1,btnClose = 1},
	--玄界破天散人地图
	["v4_panel_sanrenditu"] =	{name = "V4_ContainerSanRenDiTu", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--玄界破天转生地图
	["v4_panel_zhuanshengditu"] =	{name = "V4_ContainerZhuanShengDiTu", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--玄界破天货币兑换
	["v4_panel_huobiduihuan"] =	{name = "V4_ContainerHuoBiDuiHuan", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--玄界破天称号地图
	["v4_panel_chenghaoditu"] =	{name = "V4_ContainerChengHaoDiTu", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--玄界破天封妖塔
	["v4_panel_fengyaota"] =	{name = "V4_ContainerFengYaoTa", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--玄界破天特殊地图
	["v4_panel_teshuditu"] =	{name = "V4_ContainerTeShuDiTu", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天鉴定系统
	["v4_panel_jiandingxitong"] =	{name = "V4_ContainerJianDingXiTong", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天首充地图
	["v4_panel_shouchongditu"] =	{name = "V4_ContainerShouChongDiTu", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--玄界破天藏酒山庄
	["v4_panel_CangJianShanZhuang"] =	{name = "V4_ContainerCangJianShanZhuang", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--玄界破天藏酒山庄
	["v4_panel_dajinditu"] =	{name = "V4_ContainerDaJinDiTu", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天技能强化
	["v4_panel_JiNengQiangHua"] =	{name = "V4_ContainerJiNengQiangHua",closeDir = 1,	 res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天解封系统
	["v4_panel_jiefengxitong"] =	{name = "V4_ContainerJieFengXiTong", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天切割系统
	["v4_panel_qiegexitong"] =	{name = "V4_ContainerQieGeXiTong", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天时装系统
	["v4_panel_shizhuangxitong"] =	{name = "V4_ContainerShiZhuangXiTong", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天魔刀锻造
	["v4_panel_MoDaoDuanZao"] =	{name = "V4_ContainerMoDaoDuanZao", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天攻城奖励
	["v4_panel_GongChengJiangLi"] =	{name = "V4_ContainerGongChengJiangLi", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天物价控制
	["v4_panel_WuJiaKongZhi"] =	{name = "V4_ContainerWuJiaKongZhi", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天实物兑换
	["v4_panel_ShiWuDuiHuan"] =	{name = "V4_ContainerShiWuDuiHuan", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1,	startPosX=904,	startPosY=424},
    --玄界破天实物兑换
	["v4_panel_chenghaoxitong"] =	{name = "V4_ContainerChengHaoXiTong", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天行会争夺战
	["v4_panel_hanghuizhengduozhan"] =	{name = "V4_ContainerHangHuiZhengDuoZhan", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天高级回收
	["v4_panel_gaojihuishou"] =	{name = "V4_ContainerGaoJiHuiShou", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天沙城专属
	["v4_panel_shachengzhuanshu"] =	{name = "V4_ContainerShaChengZhuanShu", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天等级系统
	["v4_panel_dengjixitong"] =	{name = "V4_ContainerDengJiXiTong", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天玄魂进阶
	["v4_panel_xuanhunjinjie_menu"] =	{name = "V4_ContainerXuanHunJinJie_Menu", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天玄魂进阶
	["v4_panel_xuanhunjinjie_xh"] =	{name = "V4_ContainerXuanHunJinJie_XH",closeDir = 1,	 res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天玄魂进阶
	["v4_panel_xuanhunjinjie_xz"] =	{name = "V4_ContainerXuanHunJinJie_XZ", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
    --玄界破天玄魂进阶
	["v4_panel_rmbhuishou"] =	{name = "V4_ContainerRMBHuiShou", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--玄界破天神秘人
	["v4_panel_shenmiren"] =	{name = "V4_ContainerShenMiRen", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--玄界破天翻牌
	["v4_panel_fanpai"] =	{name = "V4_ContainerFanPai", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--玄界破天转生系统
	["v4_panel_zhuanshengxitong"] =	{name = "V4_ContainerZhuanShengXiTong", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--玄界破天充值礼包
	["V4_panelchongzhilibao"] =	{name = "V4_ContainerChongZhiLiBao", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--玄界破天充值奖励
	["V4_panelchongzhijiangLi"] =	{name = "V4_ContainerChongZhiJiangLi", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--游龙决加群奖励
	["V8_ContainerJiaQunLiBao"] =	{name = "V8_ContainerJiaQunLiBao",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1,	startPosX=608,	startPosY=440},
	--游龙决加群奖励
	["V8_ContainerXiLian"] =	{name = "V8_ContainerXiLian",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--游龙决日常活动
	["V8_ContainerActivity"] =	{name = "V8_ContainerActivity",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--游龙决众神录
	["V8_ContainerZhongShen"] =	{name = "V8_ContainerZhongShen",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--游龙决神器
	["V8_ContainerShenQi"] =	{name = "V8_ContainerShenQi",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--游龙决神翼(11格)
	["V8_ContainerShenYi"] =	{name = "V8_ContainerShenYi",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--游龙决图鉴(6格)
	["V8_ContainerTuJian"] =	{name = "V8_ContainerTuJian",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--游龙决世界BOSS
	["V8_ContainerShiJieBoss"] =	{name = "V8_ContainerShiJieBoss",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--游龙决限时奖励
	["V8_ContainerXianShiJiangLi"] =	{name = "V8_ContainerXianShiJiangLi",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--游龙决大陆
	["V8_ContainerDaLu"] =	{name = "V8_ContainerDaLu",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--活动通知
	["v4_panel_huodong"] =	{name = "V4_ContainerHuoDong", closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--活动按钮
	--["v4_panel_huodonganniu"] =	{name = "V4_ContainerHuoDongAnNiu", closeDir = 1,	res=1,noBoader=1,pos="left",noBg=1,noMask=1,noCache=1,btnClose = 1},
	--神器
	["V9_ContainerShenQi"] =	{name = "V9_ContainerShenQi",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--BOSS列表
	["V9_ContainerBossList"] =	{name = "V9_ContainerBossList",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--封神之路
	["V9_FengShen"] =	{name = "V9_FengShen",  closeDir = 1,	res=1,noBoader=1,noCache=1,btnClose = 1},
	--合成
	["V11_ContainerHeCheng"] =	{name = "V11_ContainerHeCheng", closeDir = 1,	 res=1,noBoader=1,noCache=1,btnClose = 1},
		
}

local conexistPanels = {
	"panel_mainTask","panel_equiptips","panel_batch", "panel_relive"
}

local GDivContainer = class("GDivContainer", function()
    return cc.Layer:create()
end)

local cacheLength = 6

function GDivContainer:ctor()
	self.m_panelDict = {}   --保存panel创建对应的节点对象
	self.m_panelFiles = {}  --保存所有panel的require lua文件的对象
	self.m_panelCache = {}
	self.scale = GameConst.gameScale()

	self.existPanels = {}
	self.lastName = nil

	cc(self):addNodeEventListener(cc.NODE_EVENT, function(event)
		if event.name == "enter" then
			self:onEnter()
        elseif event.name == "exit" then
            self:closeAllPanels()
		end
    end)

    self.m_panelEffect = ccui.Layout:create()   --特效层UI。
	self.m_panelEffect:setTouchEnabled(false)
    self.m_panelEffect:setPosition(0,0)
	self.m_panelEffect:setContentSize(cc.size(display.width,display.height))
	self:addChild(self.m_panelEffect,1000);
end

function GDivContainer:onEnter()
	cc.EventProxy.new(GameSocket, self)
			:addEventListener(GameMessageCode.EVENT_OPEN_PANEL, handler(self, self.handleOpenEvent))
			:addEventListener(GameMessageCode.EVENT_CLOSE_PANEL, handler(self, self.handleCloseEvent))
			:addEventListener(GameMessageCode.EVENT_GESTURE_CLOSE, handler(self, self.handleGestureClose))
			:addEventListener(GameMessageCode.EVENT_HANDLE_ALL_TRANSLUCENTBG, handler(self, self.handleAllTranslucentBg))
			:addEventListener(GameMessageCode.EVENT_HANDLE_LAYERPANEL_VISIBLE, handler(self, self.handleGDivContainerVisible))
			-- :addEventListener(GameMessageCode.EVENT_NEWFUNC_ANIMA, handler(self,self.handleNewFuncAnima))
end

function GDivContainer:handleOpenEvent(event)
	local pName = event.str
	print("zzzzzzzz",pName)

	if PLATFORM_BANSHU then -- 版署包充值不可用
		if pName == "panel_charge" then
			return
		end
	end

	if not MAIN_IS_IN_GAME then
		return
	end

	-- 死亡状态
	if GameCharacter._mainAvatar and GameCharacter._mainAvatar:NetAttr(GameConst.net_dead) then
		if not (pName == "panel_relive" or pName == "panel_charge" or pName == "menu_setting" or pName == "extend_firstPay") then -- 只可打开复活和充值面板(增加能点开设置面板)
			return
		end
	end


	if GameBaseLogic.isNewFunc then return end   --标记新功能不能打开对话框

	GameCharacter.updateAttr()
	
	if pName and panel_all[pName] then
		if pName == "panel_mainTask" then  --打开的是npc对话窗口
			-- if GameBaseLogic.guiding then return end
			GameSocket:dispatchEvent( {name = GameMessageCode.EVENT_HANDLE_TIPS, visible = false}) --隐藏物品tips
			GameSocket:dispatchEvent( {name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "all", visible = false}) --隐藏alert提示面板
		end

		-------------合成屏蔽-------------
		if pName=="main_compose" then
			GameSocket:alertLocalMsg("合成功能暂未开放！", "alert")
			return
		end
		
		-------------充值屏蔽-------------
		-- if pName=="panel_chongzhi" then
		-- 	GameSocket:alertLocalMsg("充值功能暂未开放！", "alert")
		-- 	return
		-- end

		-------------未开放功能屏蔽-------------
		-- local infoTable ,state = GameUtilSenior.handleOpenPanelState(pName,(event.mParam and (event.mParam.tab and  {index = event.mParam.tab} or nil) or nil))
		-- if not state then
		-- 	GameSocket:alertLocalMsg(infoTable.name.."功能暂未开放，"..(infoTable.day and "开服第"..infoTable.day.."天" or (infoTable.level and infoTable.level.."级" or "转生等级"..infoTable.zslevel.."级")).."解锁", "alert")
		-- 	return
		-- end

		--判断是功能是否开放
		local opened, level, funcname = GameSocket:checkFuncOpened(pName)
		if not opened then
			if funcname~="离线挂机" then
				print("zzzzzzzzzzzzzz=================2",funcname)
				GameSocket:alertLocalMsg(funcname.."功能暂未开放，"..level.."级开放")
			end
			-- GameSocket:alertLocalMsg("功能暂未开放")
			return
		end

		self:setVisible(true);

		--------判断面板是否可以共存------------------------
		for k,v in pairs(self.m_panelDict) do
			if not table.indexof(conexistPanels, k) then
				self:closePanel(k)
			end
		end
		-- self.curName = pName
		table.insert(self.existPanels, pName)



		if self.m_panelDict[pName] then 
			self.m_panelDict[pName]:setVisible(true) 
			-- return print("I'm already exist !!!") 
		else
			self:openPanel(pName, event)
		end
		
		self:handleTranslucentBg()
		
		--上传页面打开日记
		GameCCBridge.doSdkStartPage(pName)
	end
end
------------------------黑色半透明背景处理------------------------
function GDivContainer:handleTranslucentBg(hideAll)
	for i,v in ipairs(self.existPanels) do
		if GameUtilSenior.isObjectExist(self.m_panelDict[v]) then
			-- print("handleTranslucentBg", i,v,#self.existPanels, GameUtilSenior.encode(self.existPanels), hideAll)
			if self.m_panelDict[v].translucentBg then
				if hideAll or i < #self.existPanels then
					self.m_panelDict[v].translucentBg:hide()
				else
					self.m_panelDict[v].translucentBg:show()
				end
			end
		else
			self.existPanels[i] = "remove"
		end
	end
	table.removebyvalue(self.existPanels, "remove", true)
	-- if table.removebyvalue(self.existPanels, "remove", true) then
	-- 	self:handleTranslucentBg(hideAll)
	-- end
end

function GDivContainer:closeAllPanels()
	for k,v in pairs(self.m_panelDict) do
		self:closePanel(k)
	end
end

function GDivContainer:createPanel(pName)

	local param = panel_all[pName]
	local panel = ccui.Widget:create() --创建面板
		:setContentSize(cc.size(display.width, display.height))
		:setTouchEnabled(true)
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)
		:hide()

	if not param.noBg then
		panel:addClickEventListener(function (pSender)
			if self.m_panelDict[pName] and not self.m_panelDict[pName].scaling then
				local xmlPanel = self.m_panelDict[pName].xmlPanel
				if xmlPanel.showTips then
					self.m_panelFiles[pName]:closeTopPanel()
				else
					if param.closeDir then
						self:closeWithAnimation(pName, param.closeDir)
					else
						-- self:closeAllPanels()
						self:closePanel(pName)
					end
				end
			end
		end)
	end

	if not param.noMask then
		panel.translucentBg = ccui.ImageView:create("bg_4", ccui.TextureResType.plistType) --半透明底
			:setScale9Enabled(true)
		 	:setContentSize(cc.size(display.width, display.height))
		 	:align(display.CENTER, display.cx, display.cy)
			:setOpacity(255 * 1)
		 	:addTo(panel)
	end
	

	panel.panelMain = ccui.Widget:create()
		:setContentSize(display.width,display.height)
		:align(display.CENTER, display.cx, display.cy)
		:addTo(panel)
		-- :setScale(self.scale)
	panel.defaultPos = panel.defaultPos or cc.p(display.cx, display.cy)
	return panel
end

function GDivContainer:addPanelBorder(panelMain, param)
	local mainSize = panelMain:getContentSize()
	local externalBg = ccui.ImageView:create("img_external_bg", ccui.TextureResType.plistType)
		:align(display.CENTER, mainSize.width * 0.5, mainSize.height * 0.5)
		:addTo(panelMain, 2)
		:setName("externalBg")

	local innerBg = ccui.ImageView:create("img_inner_bg1", ccui.TextureResType.plistType)
		:align(display.CENTER_BOTTOM, mainSize.width * 0.5, 5)
		:addTo(panelMain, 1)
		:setName("innerBg")

	if param.innerRes == 2 then
		local filepath = "ui/image/img_inner_bg2.jpg"
 		asyncload_callback(filepath, innerBg, function(filepath, texture)
 			innerBg:loadTexture(filepath):setPositionY(0)
 		end,true)
	end
end

function GDivContainer:openPanel(pName, extend)

	local param = panel_all[pName]
	if param then
		for i,v in ipairs(self.m_panelCache) do
			if v.key == pName then
				self.m_panelDict[pName] = v.panel
				self.m_panelDict[pName]:setPosition(self.m_panelDict[pName].defaultPos)
				local btnClose = self.m_panelDict[pName]:getWidgetByName("panel_close")
				if btnClose then
					btnClose.from = extend.from
					btnClose.mParam = extend.mParam
				end
				self:handleOpenAnimation(pName,extend)
				return
			end
		end

		self.m_panelFiles[pName] = require_ex("container."..param.name)
		print("need to load panel", pName, self.m_panelFiles[pName])
		local mPanel = self:createPanel(pName)
		if mPanel then
			if not param.noBoader then
				self:addPanelBorder(mPanel.panelMain, param) 
			end

			mPanel:setName(pName)
			self.m_panelDict[pName] = mPanel	

			if param.res then
				print("have res create")
				if MAIN_IS_IN_GAME then
					asyncload_frames("ui/sprite/"..(param.name=="ContainerWholeActivities" and "PanelCelebrationAct" or param.name),".png",function ()
						if MAIN_IS_IN_GAME then
							if self.m_panelDict[pName] then
								self:initPanelView(extend)
							end
						end
					end,self)
				end
			else
				print("not res create")
				self:initPanelView(extend)
			end
		else
			print("Create Panel Fail")
		end
		-- end
	end
end

function GDivContainer:initPanelView(extend)
	local pName = extend.str
	if self.m_panelFiles[pName].initView then
		self.m_panelDict[pName].xmlPanel =  self.m_panelFiles[pName].initView(extend)
		local mainSize = self.m_panelDict[pName].panelMain:getContentSize()
		if self.m_panelDict[pName].xmlPanel then
			self.m_panelDict[pName].xmlPanel:setTouchEnabled(true)
				:align(self.m_panelDict[pName].xmlPanel.mAlign or display.CENTER, mainSize.width * 0.5+((self.m_panelDict[pName].xmlPanel.mPos and self.m_panelDict[pName].xmlPanel.mPos.x) or 0),
				 mainSize.height * 0.5+((self.m_panelDict[pName].xmlPanel.mPos and self.m_panelDict[pName].xmlPanel.mPos.y) or 0))
				--:align(display.LEFT_CENTER,-1136,320)  --暂不显示
				:addTo(self.m_panelDict[pName].panelMain, 3 )
				-- :setName("xmlPanel")
			--print("initPanelView", pName)
			local conf = panel_all[pName]
			if conf.pos and conf.pos == "left" then
				local mPos = self.m_panelDict[pName].panelMain:convertToNodeSpace(cc.p(display.left, display.height * 0.5)) 
				self.m_panelDict[pName].xmlPanel:align(display.LEFT_CENTER, mPos.x, mPos.y)
			end
			
			self:initBtnClose(pName,extend)
			self:handleOpenAnimation(pName,extend)
		end
	end 
end

function GDivContainer:handleOpenAnimation(pName,extend)
	if not self.m_panelDict[pName] then return end
	self.m_panelDict[pName]:show()
	local basePanel = self.m_panelDict[pName].panelMain
	if panel_all[pName].noBoader then
		basePanel = self.m_panelDict[pName].xmlPanel
	end
	
	local openScale = panel_all[pName].openScale
	if not openScale then
		openScale = 0.2
	end
	 basePanel:setScale(openScale)
	 	:setOpacity(0.1)
	self.m_panelDict[pName].scaling = true

	if pName == "panel_equiptips" then GameBaseLogic.equipsTipsOn = true end
	if pName == "panel_chongzhi" then 
		GameBaseLogic.rechargeOn = true 
		if GameBaseLogic.checkMainTaskUsable() then GameBaseLogic.stopAutoFight() end
	end
	
	local toPosX = basePanel:getPositionX()
	local toPosY = basePanel:getPositionY()
	
	if panel_all[pName].startPosX then
		basePanel:setPositionX(panel_all[pName].startPosX)
	end
	if panel_all[pName].startPosY then
		basePanel:setPositionY(panel_all[pName].startPosY)
	end
	
	local panel = self.m_panelDict[pName]
	 basePanel:runAction(
	 	cca.seq({
	 		cca.spawn({
	 			cca.scaleTo(0.2, 1.0),
	 			cca.fadeIn(0.2),
				cca.moveTo(0.2,toPosX,toPosY)
	 		}),
	 		cca.cb(function ()
				self.m_panelDict[pName].scaling = false				
	 		end)}
	 	)
	)
	
	if not self.m_panelDict[pName] then return end
	if self.m_panelFiles[pName].onPanelOpen then self.m_panelFiles[pName].onPanelOpen(extend) end

	-- 通知服务器面板打开了
	GameSocket:PushLuaTable("gui.moduleGuide.checkGuide",GameUtilSenior.encode({actionid = "onPanelOpen", pName = pName}));

	GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_UPDATE_PANELDICT, panels = self.m_panelDict, pName = pName})
	self:setBlockedArea(self.m_panelDict[pName],pName)
	
	self.m_panelDict[pName].loaded = true -- 标记面板加载完成
end

function GDivContainer:setBlockedArea(panel,pName)
	if self.m_panelFiles[pName] and self.m_panelFiles[pName].getBlockedArea then
		local block = self.m_panelFiles[pName].getBlockedArea()
		if block then
			local blockArea = {}
			for _,v in ipairs(block) do
				local wBlock = panel:getWidgetByName(v)
				if wBlock then
					local anChor = wBlock:getAnchorPoint()
					local contentSize = wBlock:getContentSize()
					local mWidth = contentSize.width * self.scale
					local mHeight = contentSize.height * self.scale
					local orignX = wBlock:getWorldPosition().x - mWidth * anChor.x
					local orignY = wBlock:getWorldPosition().y - mHeight * anChor.y
					table.insert(blockArea,cc.rect(orignX,orignY,mWidth,mHeight))
				end
			end
			if #blockArea > 0 then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_GESTURE_BLOCK , block = blockArea})
			end
		end
	end
end

function GDivContainer:handleCloseEvent(event)   
	local pName = event.str
	if pName ~= "" then
		if pName == "all" then
			self:closeAllPanels()
		elseif event.anima then
			self:closeWithAnimation(pName, event.dir)
		else 
			self:closePanel(pName)
		end
	end
end

function GDivContainer:closeWithAnimation(pName,dir)
	local panel = self.m_panelDict[pName]
	if panel then
		local distance = 1000
		if dir == 0 then
			distance = -1000
		end
		--[[
		panel:runAction(
			cca.seq(
				{
					cca.moveTo(0.2, cc.p(panel.defaultPos.x+distance,panel.defaultPos.y)),
					cca.cb(function ()
						self:closePanel(pName)
					end)
				}
			)
		)
		]]
		
		local closeScale = panel_all[pName].closeScale
		if not closeScale then
			closeScale = 0.6
		end
		local basePanel = self.m_panelDict[pName].panelMain
		if panel_all[pName].noBoader then
			basePanel = self.m_panelDict[pName].xmlPanel
		end
		basePanel:runAction(
			cc.Sequence:create(
				cca.spawn(
					{cc.Sequence:create(
						--cc.EaseSineIn:create(cca.scaleTo(0.3,1.5))
						cc.EaseSineOut:create(cca.scaleTo(0.2,closeScale))
						--cc.EaseQuarticActionIn:create(cc.ScaleTo:create(0.5, 0.5))
						),
						
						cca.moveTo(0.2,panel.defaultPos.x+distance,panel.defaultPos.y)
					}
				),
				cca.callFunc(function ()
					self:closePanel(pName,true)
				end)
			)
		)
		--上传页面关闭日记
		GameCCBridge.doSdkEndPage(pName)
	end
end
------------------------增加面板缓存机制------------------------

function GDivContainer:updatePanelCache(pName)

	---------------------面板已存在缓存中，则重新排序---------------------
	for i,v in ipairs(self.m_panelCache) do
		if v.key == pName then 
			if i ~= #self.m_panelCache then
				local cache = v
				table.remove(self.m_panelCache, i)
				table.insert(self.m_panelCache,cache)				
			end
			v.panel:hide()
			return
		end
	end
	---------------------缓存面板达到上限，则去除老缓存面板---------------------
	if #self.m_panelCache >= cacheLength then
		local cache = self.m_panelCache[1]
		if GameUtilSenior.isObjectExist(cache.panel) then
			cache.panel:removeFromParent()
		end
		if panel_all[cache.key].res then
			remove_frames("ui/sprite/"..panel_all[cache.key].name,".png")
			cc.CacheManager:getInstance():releaseUnused(false)
		end
		table.remove(self.m_panelCache, 1)
	end
	---------------------面板不存在缓存中，加入缓存---------------------
	if self.m_panelDict[pName] then -- 缓存中插入面板
		self.m_panelDict[pName]:hide()
		table.insert(self.m_panelCache, {panel = self.m_panelDict[pName], key = pName})
	end
end

function GDivContainer:closePanel(pName,animalEnd)
	-- local panel = self.m_panelDict[pName]
	if self.m_panelDict[pName] then
		-- 检测面板是否可关闭
		if self.m_panelFiles[pName].checkPanelClose and not self.m_panelFiles[pName].checkPanelClose() then return end
		
		-- if not false and not panel_all[pName].noCache and self.m_panelDict[pName].loaded then
		if not CONFIG_TEST_MODE and not panel_all[pName].noCache and self.m_panelDict[pName].loaded then
			self:updatePanelCache(pName)
		else
			if GameUtilSenior.isObjectExist(self.m_panelDict[pName]) then
				--[[
				if not animalEnd then
					--第一次调用时,先显示动画
					local basePanel = self.m_panelDict[pName].panelMain
					if panel_all[pName].noBoader then
						basePanel = self.m_panelDict[pName].xmlPanel
					end
					if basePanel then
						basePanel:runAction(
							cc.Sequence:create(
								cca.spawn(
									{cc.Sequence:create(
										--cc.EaseSineIn:create(cca.scaleTo(0.3,1.5))
										cc.EaseSineOut:create(cca.scaleTo(0.2,0.6))
										--cc.EaseQuarticActionIn:create(cc.ScaleTo:create(0.5, 0.5))
										),
										
										cca.moveTo(0.2,1500,320)
									}
								),
								cca.callFunc(function ()
									self:closePanel(pName,true)
								end)
							)
						)
					end
					return
				end
				]]
				
				self.m_panelDict[pName]:removeFromParent()
			end
			if panel_all[pName].res then 
				remove_frames("ui/sprite/"..(panel_all[pName].name=="ContainerWholeActivities" and "PanelCelebrationAct" or panel_all[pName].name),".png")
				cc.CacheManager:getInstance():releaseUnused(false)
			end
		end

		if pName == "panel_equiptips" then GameBaseLogic.equipsTipsOn = false end
		if pName == "panel_chongzhi" then GameBaseLogic.rechargeOn = false end
		
		if self.m_panelFiles[pName] and self.m_panelFiles[pName].onPanelClose then
			if panel_all[pName].closeCall or GameUtilSenior.isObjectExist(self.m_panelDict[pName].xmlPanel) then
				self.m_panelFiles[pName].onPanelClose()
			end
		end
		GameSocket:PushLuaTable("gui.moduleGuide.checkGuide",GameUtilSenior.encode({actionid = "onPanelClose", pName = pName}));

		self.m_panelDict[pName] = nil

		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_GESTURE_BLOCK , block = {}})
		GameSocket:dispatchEvent({ name = GameMessageCode.EVENT_UPDATE_PANELDICT, panels = self.m_panelDict})

		-- GameMusic.play("music/closewin3.mp3")

		if table.indexof(self.existPanels, pName) then
			table.removebyvalue(self.existPanels, pName, true)
		end

		self:handleTranslucentBg()

		GDivDialog.handleAlertClose()
		
		--上传页面关闭日记
		GameCCBridge.doSdkEndPage(pName)
	end
end

function GDivContainer:handleGestureClose(event)
	if event and event.dir then
		if #self.existPanels > 0 and self.existPanels[#self.existPanels] then
			local pName = self.existPanels[#self.existPanels]
			if not panel_all[pName].noBg and not self.m_panelDict[pName].scaling then
				self:closeWithAnimation(self.existPanels[#self.existPanels], event.dir)
			end
		end
	end
end

function GDivContainer:getGuideWidget(pName,wName)
	-- print("getGuideWidget",pName,wName)
	if self.m_panelDict[pName] then 
		return GameUtilSenior.getChildFromNode(self.m_panelDict[pName], wName), self.m_panelDict[pName]:isVisible()
		-- return self.m_panelDict[pName]:getWidgetByName(wName), self.m_panelDict[pName]:isVisible()
	else
		for i,v in ipairs(self.m_panelCache) do
			if v.key == pName then
				return GameUtilSenior.getChildFromNode(v.panel, wName), v.panel:isVisible()
			end
		end		
	end
end

function GDivContainer:handleNewFuncAnima(event)
	self:setVisible((not event.isAnima))
end

function GDivContainer:handleAllTranslucentBg(event)
	self:handleTranslucentBg(not event.visible)
end

function GDivContainer:handleGDivContainerVisible(event)
	event.visible = event.visible and true or false;
	self:setVisible(event.visible);
end

function GDivContainer:initBtnClose(pName,extend)
	local btnClose = self.m_panelDict[pName].xmlPanel:getWidgetByName("panel_close") -- 为关闭按钮添加返回指定上级界面功能
	if not btnClose and panel_all[pName].btnClose then
		btnClose = self:addButtonClose(self.m_panelDict[pName].xmlPanel)
	end
	if btnClose then
		btnClose.from = extend.from
		btnClose.mParam = extend.mParam
		GUIFocusPoint.addUIPoint(btnClose,	function(pSender)
			-- self:closeAllPanels()
			--self:closePanel(pName)
			local param = panel_all[pName]
			if param.closeDir then
				self:closeWithAnimation(pName, param.closeDir)
			else
				-- self:closeAllPanels()
				self:closePanel(pName)
			end
			if pSender.from then -- 打开上级面板
				self:handleOpenEvent({str = pSender.from, mParam = pSender.mParam})
			end
		end) 
	end
end
----统一添加关闭按钮方法
function GDivContainer:addButtonClose(xmlPanel)
	if not xmlPanel:getChildByName("panel_close") then
		local btnClose = ccui.Button:create();
		btnClose:loadTextures("btn_panel_close","btn_panel_close","",ccui.TextureResType.plistType);
		btnClose:setName("panel_close")
		btnClose:setPressedActionEnabled(true)
		btnClose:setZoomScale(-0.12)
		xmlPanel:addChild(btnClose);
		local panelSize = xmlPanel:getContentSize()
		btnClose:setPosition(cc.p(panelSize.width-15,panelSize.height-18))
		return btnClose
	end
end

function GDivContainer:getEffectPanel()
	return m_panelEffect;
end

return GDivContainer
-- 视图定义
-- cannotbeclose为true 不能被ViewManager.Instance:CloseAllView()关闭
-- v_open_cond 功能开启判断cond_def定义里的条件,条件不成立不能打开
-- v_show_cond 功能开启显示,需单独判断
-- default_child 打开时默认显示的子视图key
-- name = ""时,打开面板时会打印栈,可用于查找打开面板的代码位置

ViewDef = ViewDef or {}

ViewDef.MainUi = {name = "主界面", cannotbeclose = true, --[[MainuiTaskBar:任务栏, MainuiRoleBar:头像栏, SpecialSkillIcon:必杀技能图标]]}

ViewDef.Role = {name = "角色主", default_child = "RoleInfoList", --[[btn_close_window:关闭按钮, RoleIntroQuickEquip:一键装备按钮]]
	RoleInfoList = {name = "角色", default_child = "Intro", remind_group_name = "RoleTabbar",
		Intro = {name = "总览", },
		GodEquip = {name = "神装", v_open_cond = "CondId16", remind_group_name = "GodEquipTabbar",},
		BiSha = {name = "必杀", default_child = "SuitAttr", v_open_cond = "CondId19", remind_group_name = "FuwenTabbar",
			SuitAttr = {name = "符文套装属性", },
			FuwenZhuling = {name = "符文注灵", },
		},
		NewReXueEquip = {name = "新热血神装",v_open_cond = "CondId22", remind_group_name = "ReXueCanWearView"},
		LuxuryEquip = {name = "豪装",v_open_cond = "CondId120"},
	},
	Inner = {name = "内功", v_open_cond = "CondId5", remind_group_name = "RoleInner", inner_equip_open_cond = "CondId6", --[[btn_1:提升按钮]]},
	ZhuanSheng = {name = "转生", v_open_cond = "CondId17", remind_group_name = "ZhuanShengTabbar", --[[btn_1:转生按钮]]
				  AddPoint = {name = "转生加点", v_open_cond = "CondId17", remind_group_name = "ZhuanShengTabbar",},},
	LunHui = {name = "轮回", v_open_cond = "CondId18", remind_group_name = "LunhuiTabbar",},
	Level = {name = "等级", remind_group_name ="LevelTabbar",},
	Deify = {name = "封神", v_open_cond = "CondId25", remind_group_name = "OfficeTabbar"},
}

ViewDef.GuardEquip = {name = "守护神装", v_open_cond = "CondId135", remind_group_name = "GuardEquip",}
ViewDef.GuardShop = {name = "守护商店", v_open_cond = "CondId136"}

ViewDef.Skill = {name = "技能", default_child = "SkillShow",
	SkillShow = {name = "技能"},
	SelectSkill = {name = "设置"},
}
ViewDef.SkillTip = {name = "学习技能提示"}

ViewDef.ChuanShiEquip = {name = "传世装备", default_child = "Show",
	Blood = {name = "血炼"},
	Show = {name = "展示"},
	Compose = {name = "合成"},
	Decompose = {name = "分解"},
}

ViewDef.ReXueShiEquip = {name = "热血装备tip", default_child = "EquipInfo",
	EquipInfo = {name = "装备"},
	Zhuling = {name = "注灵"},
	Fumo = {name = "附魔"},
}

ViewDef.RoleOtherAttr = {name = "角色其它属性", }

ViewDef.GodEqDecompose = {name = "神装分解", }

ViewDef.Achieve = {name = "成就", }

ViewDef.Shop = {name = "商城", default_child = "Prop", v_open_cond = "CondId76",
	Prop 		= {name = "钻石", },
	Bind_yuan 	= {name = "元宝", },
	Yongzhe 	= {name = "积分", },
}

ViewDef.Wing = {name = "翅膀", v_open_cond = "CondId82",	--[[WingActBtn:激活按钮, btn_jinjie:进阶]]}

ViewDef.Equipment = {name = "锻造", default_child = "Strength",v_open_cond = "CondId130",
	Strength 	= {name = "强化", v_open_cond = "CondId127", --[[btn_qianghua:强化按钮]]},
	Refine = {name = "精炼", v_open_cond = "CondId204"},
	Stone 	= {name = "镶嵌", v_open_cond = "CondId128",},
	Authenticate = {name = "鉴定", v_open_cond = "CondId129",},
	Fusion = {name = "融合", v_open_cond = "CondId8",},
}
ViewDef.EquipmentFusionRecycle = {"锻造-融合分解"}

ViewDef.BattleFuwen = {name = "战纹", v_open_cond = "CondId150",}
ViewDef.DecomposeZhanwen = {name = "分解", v_open_cond = "CondId150"}
ViewDef.ReplaceZhanwen = {name = "替换, 装备", v_open_cond = "CondId150"}
ViewDef.ShowAllZhanwen = {name = "总览", v_open_cond = "CondId150"}
ViewDef.ExchangeZhanwen = {name = "兑换", v_open_cond = "CondId150"}

ViewDef.EquipmentSuitAttr = {name = "锻造-套装属性"}

ViewDef.Welfare = {name = "福利大厅", default_child = "DailyRignIn", v_open_cond = "CondId77",
	DailyRignIn 	= {name = "每日签到"},
	OnlineReward	= {name = "在线奖励"},
	Findres 		= {name = "资源找回"},
	-- OfflineExp 		= {name = "离线经验"},
	Gift 			= {name = "激活码兑换"},
	-- UpdateAffiche 	= {name = "更新公告"},
	-- WechatAttention = {name = "微信关注"},
}

ViewDef.FindreTip = {name = "资源找回次数面板"}

ViewDef.LoginReward = {name = "登录奖励", v_open_cond = "CondId124"}

ViewDef.Explore = {name = "探索宝藏", default_child = "Xunbao", v_open_cond = "CondId24",
	Xunbao 	= {name = "探宝",},
	Fullserpro = {name = "全服进度",},
	RareTreasure = {name = "龙皇秘宝",},
	Exchange = {name = "积分兑换",},
	Storage = {name = "寻宝仓库",},	
	-- PrizeInfo 	= {name = "奖励详情",},
	Swap 	= {name = "男女互换",},
}

ViewDef.WangChengZhengBa = {name = "王城争霸", default_child = "EmpireGlory",v_open_cond = "CondId73",
	EmpireGlory  = {name = "王城荣耀",},
	SiegeRule    = {name = "攻城规则",},
	ApplySiege   = {name = "申请攻城",},
	SiegeRewards = {name = "攻城奖励",},
}

ViewDef.Guild = {name = "行会", default_child = "GuildView", v_open_cond = "CondId74",
	GuildView = {name = "行会", v_open_cond = "CondId74", remind_name = "GuildRedEnvelope",
		GuildJoinList       = {name = "加入行会", v_open_cond = "CondId63"},
		-- GuildCreate         = {name = "行会创建", v_open_cond = "CondId63"},
		GuildInfo           = {name = "行会信息", v_open_cond = "CondId62"},
		GuildMember         = {name = "行会成员", v_open_cond = "CondId62"},
		GuildBuild          = {name = "行会建设", v_open_cond = "CondId62"},
		GuildList           = {name = "行会列表", v_open_cond = "CondId62"},
		GuildStorage        = {name = "行会仓库", v_open_cond = "CondId62"},
		GuildActivity       = {name = "行会活动", v_open_cond = "CondId62"},
		GuildEvents         = {name = "行会事件", v_open_cond = "CondId62"},
		GuildRobRedEnvelope = {name = "行会红包", v_open_cond = "CondId62"},
		GuildJoinReqList    = {name = "行会申请", v_open_cond = "CondId62"},
		GuildAddMember      = {name = "添加成员", v_open_cond = "CondId62"},
	},
	OfferView = {name = "悬赏", v_open_cond = "CondId20", remind_name = "GuildOfferReward",
		GuildOffer = {name = "悬赏", v_open_cond = "CondId20"},
	}	
}
ViewDef.GuildImpeach = {name = "行会弹劾"}

ViewDef.HhjdTeam = {name = "行会禁地组队", v_open_cond = "CondId62"}

ViewDef.GuildAddMember = {name = "添加行会成员"}

ViewDef.Vip = {name = "vip", v_open_cond = "CondId92",}
ViewDef.VipTip = {name = "Vip升级提示"}
ViewDef.VipBoss = {name = "VipBoss"}
ViewDef.VipBossWin = {name = "VipBoss战斗胜利"}
ViewDef.VipBossLose = {name = "VipBoss战斗失败"}

ViewDef.ChargeFirst = {name = "首充", v_open_cond = "CondId51"}

ViewDef.ChargeEveryDay = {name = "每日充值", v_open_cond = "CondId90"}

ViewDef.Map = {name = "地图"}

ViewDef.Mail = {name = "邮件", v_open_cond = "CondId91"}

ViewDef.Setting = {name = "设置"}

ViewDef.NearTag = {name = "附近目标"}

ViewDef.RankingList = {name = "排行榜",  v_open_cond = "CondId71",default_child = "FightingCapacity",
	FightingCapacity = {name = "战力"},
	Rank 		= { name = "等级"},
	GodWing     = { name = "神翼"},
	Trial  	    = { name = "试炼"},
	Prestige 	= { name = "战鼓"},
}

ViewDef.Activity = {name = "日常活动",v_open_cond = "CondId79", default_child = "Active",
	Activity = {name = "日常",v_open_cond = "CondId79"},
	Active = {name = "活跃度",v_open_cond = "CondId90"},
	-- Offline = {name = "挂机",v_open_cond = "CondId83"},
}

-- 日常活动-主界面挂件
ViewDef.ActRanking = {name = "日常任务积分榜"}
ViewDef.ActZhenYing = {name = "日常阵营战"}
ViewDef.ActBossInspire = {name = "Boss鼓舞面板"}
ViewDef.ActWorldBoss = {name = "世界BOSS"}
ViewDef.ActGuildBoss = {name = "公会BOSS"}
ViewDef.Escort = {name = "护送镖车"}

ViewDef.Team = {name = "组队", default_child = "MyTeam",
	MyTeam 			= { name = "我的队伍"},
	NearTeam 		= { name = "附近队伍"},
	NearPlayer 		= { name = "附近玩家"},
	MyGoodFriend 	= { name = "我的好友"},
	MyGuild 		= { name = "我的行会"},
	TeamApplyList	= { name = "申请列表", remind_group_name = "TeamApplyListTabbar",},
}

ViewDef.Dungeon = {name = "副本", default_child = "Material",v_open_cond = "CondId67",
	Material 	= {name = "材料",v_open_cond = "CondId68", --[[CailiaoFuben1:副本-宝石, CailiaoFuben2:副本-龙魂, CailiaoFuben3:副本-羽毛, CailiaoFuben4:副本-铸魂,]]},
	Experience 	= {name = "经验",v_open_cond = "CondId69"},
	LianYu 		= {name = "炼狱", v_open_cond = "CondId205"}
}

ViewDef.SweepResult = {name = "扫荡结果"}

ViewDef.LianyuGuide = {name = "左边导航面板"}

ViewDef.LianyuReward = {name = "炼狱奖励面板"}

ViewDef.Boss = {name = "挑战BOSS", default_child = "MapInfo",--激战boss
	-- TypeBoss 		= {name = "BOSS类型"},
	MapInfo 	 	= {name = "地图信息"},
	RareBoss 		= {name = "稀有BOSS"},
	MoshaBoss 		= {name = "魔煞BOSS"},
	NoticeInfo 		= {name = "掉落信息"},
	PersonBoss 		= {name = "VIP专属", --[[btn_challenge:挑战按钮, PersonalBossLevel20:20级, PersonalBossLevel20~80:20~80级]]},
	-- WildBoss 		= {name = "野外BOSS"},
	-- BossHome 		= {name = "BOSS之家"},
	-- SecretBoss 		= {name = "秘境BOSS"},
	-- BossIntegral 	= {name = "BOSS积分", --[[BossIntegral1:boss纹章1, BossIntegral2:boss纹章2, BossIntegral3:boss纹章3, BossIntegral4:boss纹章4]]},
}

ViewDef.BossRewardPreview = {name = "BOSS奖励预览",}
ViewDef.CrossBoss = {name = "跨服BOSS",v_open_cond = "CondId75", default_child = "CrossBossInfo",
	CrossBossInfo = {name = "挑战"}, 
	FlopCard = {name = "翻牌"}, -- 跨服翻牌
	LuxuryEquipCompose = {name = "神豪装", default_child = "WanHaoCompose", remind_group_name = "HaoZhuangCanmposeTabbar", v_open_cond  = "CondId204",
		WanHaoCompose = {name = "万壕", remind_group_name = "WanHaoCanComposeTabbar", v_open_cond  = "CondId204"},
		JinHaoCompose = {name = "金壕", remind_group_name = "JinHaoCanComposeTabbar",  v_open_cond  = "CondId204"},
		XionghaoCompose = {name = "雄壕", remind_group_name = "XiongHaoCanComposeTabbar",  v_open_cond  = "CondId204"},
	},
}


ViewDef.BeastPalace = {name = "圣兽宫殿"} -- 跨服BOSS
ViewDef.PengLaiFairyland = {name = "蓬莱仙界", default_child = "PengLaiFairylandSub",
	PengLaiFairylandSub = {name = "蓬莱仙界"},
	LuckyFlopSub = {name = "幸运翻牌"},
}
ViewDef.FireVision = {name = "烈焰幻境", default_child = "FireVision",  -- 跨服BOSS
	FireVision =  {name = "烈焰幻境"},
	MarkBlessing = {name = "印记祈福"},
}
ViewDef.DragonSoul = {name = "龙魂圣域", default_child = "DragonSoul",  -- 跨服BOSS
	DragonSoul =  {name = "龙魂圣域"},
	MarkBlessing = {name = "心法祈福"},
}
ViewDef.RebirthHell = {name = "轮回地狱", default_child = "RebirthHell",  -- 跨服BOSS
	RebirthHell = {name = "轮回地狱"},
	RotaryTable = {name = "幸运转盘"},
}

ViewDef.PracticeWin = {name = "战斗胜利"}
ViewDef.PracticeLose = {name = "战斗失败"}


ViewDef.LuckyDraw = {name = "幸运抽奖"}

ViewDef.Meridians = {name = "经脉",  v_open_cond = "CondId23", --[[layout_up:激活/冲脉按钮]]}

ViewDef.PracticeIcon = {name = "历练图标", v_open_cond = "CondId85"}	-- 历练图标

ViewDef.Office = {name = "官职", v_open_cond = "CondId25" --[[OfficeActBtn:官职激活按钮]]}

ViewDef.CardHandlebook = {name = "车库", default_child = "CardView", v_open_cond = "CondId87",
	CardView = {name ="汽车", default_child = "DaibuCar", v_open_cond = "CondId87",
		DaibuCar = {name = "代步车"},
		PrivateCar = {name = "私家车"},
		SeniorCar = {name = "高级私家车"},
		LuxuryCar = {name = "豪华车"},
		KuCar = {name = "酷车一族"},
		AssembleCar = {name = "组装车"},
		PersonalityCar = {name = "个性车"},
		},
	Descompose = {name = "分解" ,v_open_cond = "CondId87",},
}

ViewDef.CardDescompose = {name = "图鉴分解"}

ViewDef.CardHandlebookCheck = {name = "图鉴详情"}

ViewDef.Preview = {name = "极品预览"}

ViewDef.Bag = {name = "背包", --[[btn_go_shop:快捷商店]]}

ViewDef.Storage = {name = "仓库", v_open_cond = "CondId95"}
ViewDef.StorageEncryption = {name = "仓库加密"}
ViewDef.StorageProtect = {name = "仓库保护"}
ViewDef.StorageUnlock = {name = "解除保护"}
ViewDef.StorageTempUnlock = {name = "临时解除保护"}
ViewDef.StorageResetPassword = {name = "修改保护密码"}

ViewDef.PerShop = {name = "随身商店", --[[BagShopXX:从上到下第XX个商品]]}

ViewDef.Recycle = {name = "回收", --[[btn_melting:熔炼]]}

ViewDef.Chat = {name = "聊天", default_child = "Synthesize",
	Synthesize = {name ="综合"},
	Nearby = {name ="附近"},
	World = {name ="世界"},
	Guild = {name ="行会"},
	Troops = {name ="队伍"},
	PrivateChat  = {name ="私聊"},
}

ViewDef.TransmitNpcDialog = {name = "传送员对话",}

ViewDef.SpecialNpcDialog = {name = "特殊npc对话框"}

ViewDef.NpcDialog = {name = "npc对话框"}

ViewDef.ClientCmd = {name = "客户端指令",}

ViewDef.GodFurnace = {name = "神炉", default_child = "TheDragon", v_open_cond = "CondId15", --[[GodFurnaceActBtn:激活门按钮]]
	TheDragon = {name = "血符", v_open_cond = "CondId9", remind_group_name = "TheDragonTabbar"},
	Shield = {name = "护盾", v_open_cond = "CondId10", remind_group_name = "ShieldTabbar"},
	GemStone = {name = "宝石", v_open_cond = "CondId11", remind_group_name = "GemStoneTabbar"},
	DragonSpirit = {name = "魂珠", v_open_cond = "CondId12", remind_group_name = "DragonSpiritTabbar"},
	ShenDing = {name = "神鼎", v_open_cond = "CondId19", remind_group_name = "ShenDingCanUpTabbar"},
}

ViewDef.SpecialRing = {name = "特戒", default_child = "Advanced", v_open_cond = "CondId145", remind_group_name = "SpecialRingView",
	Advanced = {name = "进阶", v_open_cond = "CondId146", remind_group_name = "SpecialRingSynthetic",},
	Fusion = {name = "融合", v_open_cond = "CondId147",},
	Part = {name = "分离", v_open_cond = "CondId148"},
}

ViewDef.HolySynthesis = {name = "圣物合成",}
ViewDef.SelectHolyItem = {name = "选择圣物"}
ViewDef.FireGodPower = {name = "烈焰神力", v_open_cond = "CondId13", remind_group_name = "FireGodPowerBtn"}
ViewDef.ResistGodSkill = {name = "抗暴神技", v_open_cond = "CondId14", remind_group_name = "HeartEquipBtn"}
ViewDef.HeartDecompose = {name = "心法分解"}

ViewDef.RefiningExp = {name = "经验炼制", --[[v_open_cond = "CondId64"]]}
ViewDef.RefiningTip = {name = "炼制上线提示"}

ViewDef.BuyTip = {name = "获取XX物品", v_open_cond = "CondId2"}
ViewDef.NewBuyTip = {name = "获取XX物品可购买", v_open_cond = "CondId2"}

ViewDef.FuwenDecompose = {name = "符文分解"}
ViewDef.FuwenExchange = {name = "符文兑换"}

ViewDef.Consign = {name = "寄售", default_child = "Buy", v_open_cond = "CondId96",
	Buy = {name = "购买"},
	Sell = {name = "出售"},
	Consign = {name = "寄卖"},
	RedDrill = {name = "红钻"},
}

ViewDef.RedDrillExchange = {name = "红钻兑换tip"}
ViewDef.RedDrilleTip = {name = "红钻获取提示"}

ViewDef.Prestige = {name = "威望", v_open_cond = "CondId88"}
ViewDef.PrestigeTask = {name = "威望任务", v_open_cond = "CondId100"}
ViewDef.PrestigeTaskTip = {name = "威望任务提示"}

ViewDef.ShenDing = {name = "活跃度", v_open_cond = "CondId61"}

ViewDef.ActOpenRemind = {name = "当前开启活动提醒功能"}

ViewDef.Society = {name = "社交", default_child = "Friend", v_open_cond = "CondId93",
	Friend 		= {name = "好友"},
	Enemy 		= {name = "仇人"},
	BlackList 	= {name = "黑名单"},
	ApplyList 	= {name = "申请列表", remind_group_name = "SocietyApplyListTabbar",},
	SearchAdd 	= {name = "搜索添加"},
}

ViewDef.Notice = {name = "公告"}
ViewDef.UserAgreement = {name = "用户协议"}
ViewDef.PrivacyPolicy = {name = "隐私保护政策"}

ViewDef.TimeLimitTask = {name = "限时任务"}
ViewDef.TimeLimitTaskRemind = {name = "限时任务"}

ViewDef.QuickBuy = {name = "快速购买"}
ViewDef.QuickTip = {name = "寻宝快速购买"}

ViewDef.Worship = {name = "膜拜"}

ViewDef.EquipTip = {name = "装备tip"}
ViewDef.EquipEffShowTip = {name = "装备特效展示tip"}
ViewDef.ItemTip = {name = "物品tip"}
ViewDef.CompareEquipTip = {name = "对比装备tip"}
ViewDef.CompareEquipEffShowTip = {name = "对比装备特效展示tip"}

ViewDef.BiShaPreview = {name = "必杀技预告", v_open_cond = "CondId72"}
ViewDef.BiShaRecView = {name = "必杀技领取"}

ViewDef.VipLimitView = {name = "vip不足"}

ViewDef.Tasks = {name = "任务", v_open_cond = "CondId104",} 
ViewDef.DailyTasks = {name = "日常任务", v_open_cond = "CondId60", --[[btn_receive_task:接受任务按钮, btn_receive_1:免费领取按钮]]} -- 日常任务(降妖除魔)
ViewDef.UnknownDarkHouse = {name = "未知暗殿", v_open_cond = "CondId99"}

ViewDef.ItemShow = {name = "获得珍品"}

ViewDef.FubenMulti = {name = "多人副本", v_open_cond = "CondId102"}

ViewDef.FubenCLSceneTip = {name = "场景副本提示"}

ViewDef.AwardEveryDay = {name = "每日奖励", v_open_cond = "CondId66",} --[[btn_go:进入按钮]]

ViewDef.Exchange = {name = "交易"}

ViewDef.Browse = {name = "Browse", default_child = "Role",
		Role = {name = "人物"},
		XingHun = {name = "星魂"},
	}

ViewDef.ExpAward = {name = "试炼经验奖励", v_open_cond = "CondId94",}

ViewDef.OpenServiceAcitivity = {name = "开服活动", default_child = "OpenServiceAcitivityLeveGift",v_open_cond = "CondId81",
	OpenServiceAcitivityLeveGift 				= {name = "等级礼包"},
	OpenServiceAcitivityMoldingSoulSports 		= {name = "铸魂竞技"},
	OpenServiceAcitivityMoldingSoulList 		= {name = "铸魂榜"},
	OpenServiceAcitivityGemStoneSports 			= {name = "宝石竞技"},
	OpenServiceAcitivityGemStoneList 			= {name = "宝石榜"},
	OpenServiceAcitivityDragonSpiritSports 		= {name = "龙魂竞技"},
	OpenServiceAcitivityDragonSpiritList 		= {name = "龙魂榜"},
	OpenServiceAcitivityWingSports 				= {name = "羽翼竞技"},
	OpenServiceAcitivityWingList 				= {name = "羽翼榜"},
	OpenServiceAcitivityCardHandlebookSports 	= {name = "图鉴竞技"},
	OpenServiceAcitivityCardHandlebookList 		= {name = "图鉴榜"},
	OpenServiceAcitivityCircleSports 			= {name = "转生竞技"},
	OpenServiceAcitivityCircleList 				= {name = "转生榜"},	
	OpenServiceAcitivityCharge 					= {name = "累计充值"},
	OpenServiceAcitivityLuckyDraw 				= {name = "幸运抽奖"},
	OpenServiceAcitivityBoss 					= {name = "全民BOSS"},
	OpenServiceAcitivityWangChengBaYe	 		= {name = "王城霸业"},
	OpenServiceAcitivityXunBao 					= {name = "开服寻宝"},
	OpenServiceAcitivityFinancial 				= {name = "超值理财"},
	OpenServiceAcitivityExploreRank				= {name = "寻宝榜"},
	OpenServiceAcitivityConsume 				= {name = "消费排行"},
	OpenServiceAcitivityRecharge 				= {name = "充值排行"},
}

ViewDef.OpenServiceAcitivity.GoldDraw = {name = "元宝转盘"}

ViewDef.OpenServiceAcitivityDrawRecord = {name = "全服抽奖记录"}

ViewDef.OpenServiceAcitivitySportsList = {name = "竞技榜（4—20）"}

ViewDef.OpenSerVeGift = {name = "开服超值礼包",v_open_cond = "CondId80",
	LimitTimeBuy = {name = "限时抢购"},
	SaleGift = {name = "特惠礼包"},
}

ViewDef.MergeServerDiscount = {name = "合服特惠", v_open_cond = "CondId105"}

ViewDef.GuideLevelUp = {name = "等级成长引导"}

ViewDef.BattleLineTip = {name = "战纹提示"}

-- ViewDef.BattleFuwen = {name = "战纹",
-- 	DecomposeZhanwen = {name = "分解"},
-- 	ReplaceZhanwen = {name = "替换, 装备"},
-- 	ShowAllZhanwen = {name = "总览"},
-- 	Exchange = {name = "兑换"},
-- }

ViewDef.FindBoss = {name = "发现BOSS"}

ViewDef.ActivityBrilliant1 = {name = "精彩活动",v_open_cond = "CondId103", view_index = 1}
ViewDef.ActivityBrilliant2 = {name = "精彩活动",v_open_cond = "CondId208", view_index = 2}
ViewDef.ActivityBrilliant3 = {name = "精彩活动",v_open_cond = "CondId209", view_index = 3}
ViewDef.ActivityBrilliant4 = {name = "精彩活动",v_open_cond = "CondId210", view_index = 4}

ViewDef.LimitCharge = {name = "限时充值",v_open_cond = "CondId113"}    				-- 限时充值
ViewDef.ActChargeFanli = {name = "充值返利",v_open_cond = "CondId114"}
ViewDef.ActCanbaoge = {name = "藏宝阁", v_open_cond = "CondId111"}
ViewDef.ActCanbaogeDuiHuan = {name = "藏宝阁兑换"}
ViewDef.ActBabelTower = {name = "通天塔", v_open_cond = "CondId112"}
ViewDef.AwardShowTip = {name = "奖励预览"}

ViewDef.CombineServAct = {name = "合服活动"}

ViewDef.Help = {name = "新手帮助"}

ViewDef.BossRefreshRemind = {name = "BOSS提醒",}

ViewDef.TreasureAttic = {name = "珍宝阁主界面", default_child = "ZhenBaoGe",v_open_cond = "CondId107",
	ZhenBaoGe = {name = "珍宝阁"},
	DragonBall = {name = "龙珠", 
		SuitAttr = {name = "龙珠套装属性"}
	}
}

ViewDef.Investment = {name = "天天福利", default_child = "DailyChange", v_open_cond = "CondId108",
	Investment = {name = "投资", v_open_cond = "CondId110",},
	DailyChange = {name = "充值", v_open_cond = "CondId90",},
	Everyrebate = {name = "返利", v_open_cond = "CondId13",},
	LuxuryGifts = {name = "豪礼", v_open_cond = "CondId16",},
	Blessing = {name = "祈福", remind_group_name = "BlessingTabbar", v_open_cond = "CondId117",}
}

ViewDef.RewardPreview = {name = "积分奖励预览"}
ViewDef.ShenqiView = {name = "神器"}
ViewDef.ChiyouView = {name = "蚩尤结界"}

ViewDef.ZhanjiangView = {name = "战宠", default_child = "ZhangChongView", v_open_cond = "CondId58",
	ZhangChongView = {name = "战宠"},
	ZhangChongComposeView = {name = "副装"},
	-- JingLingView = {name = "精灵"},
}

ViewDef.Fashion = {name = "装扮", default_child = "FashionChild",
	FashionChild = {name = "时装", default_child = "FashionPreview",
		FashionResolve = {name = "分解"},
		FashionExchange = {name = "兑换"},
		FashionPossession = {name = "拥有"},
		FashionPreview = {name = "预览"},
	},
	WuHuan = {name = "幻武", default_child = "WuHuanPreview",
		WuHuanResolve = {name = "分解"},
		WuHuanExchange = {name = "兑换"},
		WuHuanPossession = {name = "拥有"},
		WuHuanPreview = {name = "预览"},
	},
	ZhenQi = {name = "真气", remind_group_name = "FashionZhenQi", default_child = "ZhenQiChild",
		ZhenQiResolve = {name = "分解"},
		ZhenQiExchange = {name = "兑换",},
		ZhenQiChild = {name = "真气", remind_name = "FashionZhenQi",},
	},
	Title = {name = "称号",  remind_group_name = "FashionTitle", default_child = "TitlePreview",
		TitlePreview = {name = "全部"},
		TitlePossession = {name = "拥有", remind_name = "FashionTitle",},
		TitleCustom = {name = "定制"},
	},
}

ViewDef.FashionTitleTipView = {name = "时装称号"}

ViewDef.DiamondBackView = {name = "钻石回收", default_child = "OneEquipLimitView", v_open_cond = "CondId115",
	OneEquipLimitView = {name = "装备首爆", v_open_cond = "condId141",},
	BossFirstKillView = {name = "BOSS首杀", v_open_cond = "condId141",},
	SuitLimitBackView = {name = "套装回收", v_open_cond = "condId141",},
	OneForeverBackView = {name = "单件回收"},
	BackRecordView = {name = "回收记录"},
}

ViewDef.BlessingView = {name = "祈福",default_child = "Blessing",
	Fortune = {name = "运势", remind_group_name = "FortuneTabbar", v_open_cond = "CondId117",},
	--Blessing = {name = "祈福", remind_group_name = "BlessingTabbar", v_open_cond = "CondId117",},
}

ViewDef.MeiBaShouTao = {name = "无限手套", default_child = "HandCompose",
	HandCompose = {name = "手套打造"},
	HandAdd = {name = "手套增幅"},
}

ViewDef.CrossLand = {name = "CrossLand"}
ViewDef.Temples = {name = "Temples"}
ViewDef.LuxuryEquipUpgrade = {name = "LuxuryEquipUpgrade"}
ViewDef.LuxuryEquipTip = {name = "豪装提示"}

ViewDef.ZsVip = {name = "钻石会员", default_child = "VipChild", v_open_cond = "CondId2",
	VipChild = {name = "会员", v_open_cond = "CondId2"},
	Privilege = {name = "特权卡", v_open_cond = "CondId109"},
	Recharge = {name = "充值", v_open_cond = "CondId2"},
}

ViewDef.ItemTip1 = {name ="物品tip"}

ViewDef.HunHuan = {name = "魂环特惠"}
ViewDef.OutOfPrint = {name = "绝版抢购", v_open_cond = "CondId116"}

ViewDef.QieGeView = {name = "切割", default_child = "QieGe", v_open_cond = "CondId121",
			QieGe = {name = "切割", remind_group_name = "QieGeUpView"},
			Shenbi = {name = "神兵", remind_group_name = "QieGeShenBinView"},
		}

ViewDef.QieGeTipView = {name = "切割Tips"}
ViewDef.QieGeUpgrade = {name = "切割升级"}
ViewDef.XingHUnSuitTip = {name = "星魂Tips"}
ViewDef.ChargeGift = {name = "充值大礼包"}

ViewDef.QieGeSkillView = {name = "切割技能Tips"}

ViewDef.WelfareTurnbel = {name = "福利转盘Tips"}

ViewDef.MainBagView = { name = "背包", default_child = "BagView",
	BagView  = {name = "背包"},
	ComspoePanel = {name = "合成", v_open_cond = "CondId126", remind_group_name = "BagComposeView"},
}

--default_child = "RexueGodEquip"
ViewDef.MainGodEquipView = {name = "热血装备",  v_open_cond = "CondId133",
	RexueGodEquip = {name = "热血装备",  v_open_cond = "CondId133",remind_group_name = "RexueShenBinUpTabbar", remind_name = "RexueShenBinUp"},
	ReXueFuzhuang = {name = "副装",   v_open_cond = "CondId142", remind_group_name = "FuZhuangTabbar",
				MeiBaShouTao = {name = "灭霸手套", remind_group_name = "MiebaShouTaoTabbar", v_open_cond = "CondId142",},
				ZhanChongShenHZuang = {name = "战宠神装", v_open_cond = "CondId143", remind_group_name = "ZhanChongComposeTabbar"},
				WingShenZhuang = {name = "翅膀神装",  v_open_cond = "CondId144", remind_group_name = "WingComposeTabbar"},
				},
	RexueGodEquipDuiHuan = {name = "热血兑换", v_open_cond = "CondId133", remind_group_name = "GodEquipRexueDuiHuanTabbar", remind_name = "RexueShenBinDuiHuan"},
	RexueShenzhu = {name = "神铸", v_open_cond = "CondId14", remind_group_name = "ShenzhuTabbar"},
}

ViewDef.RexueShenge = {name = "神格"}

ViewDef.SpecialEquipTipShow = { name = "特殊装备Tips"}

ViewDef.ReXueSuitTip = {name = "套装属性"}

ViewDef.SpecialRingBag = {name = "特戒背包"}

ViewDef.DigOreAccount = {name = "小号"}
ViewDef.DigOreRob = {name = "挖矿掠夺"}
ViewDef.DigOreAward = {name = "挖矿奖励"}
ViewDef.DigOreRobAward = {name = "掠夺奖励"}

ViewDef.Experiment = {name = "试炼", default_child = "Trial",
	DigOre  = {name = "挖矿", v_open_cond = "CondId206",},
	Trial = {name = "试炼", default_child = "TrialChild", v_open_cond = "CondId66",
		TrialChild = {name = "试炼",},
		TrialWorld = {name = "试炼地图",},
	},
	Babel = {name = "通天塔", v_open_cond = "CondId150",  remind_group_name = "BabelTabbar"},
}
ViewDef.TrialInfo = {name = "试炼信息"}
ViewDef.TrialWin = {name = "试炼挑战成功"}
ViewDef.TrialLose = {name = "试炼挑战失败"}
ViewDef.TrialAddAwards = {name = "试炼额外奖励"}
ViewDef.TrialTip = {name = "炼功收益(上线提示)"}

ViewDef.BabelInfo = {name = "通天塔左边信息"}
ViewDef.BabelWin = {name = "通天塔成功面板"}
ViewDef.BabelTurnTable = {name = "通天塔转盘"}

ViewDef.TaskZhanChongEffect = {name = "战宠激活"}

ViewDef.TaskNewXiTongGuide = {name = "新系统引导"}

ViewDef.TaskShaChengGuide = {name = "沙城引导"}

ViewDef.TaskShaChengResultGuide = {name = "沙城结算引导"}

ViewDef.TaskEquipGetGuide  = {name = "装备引导"}

ViewDef.TaskEquipTiYanGuide = {name = "体验装备消失引导"}

ViewDef.GrapRobRedEnvelope = {name = "抢红包界面",  v_open_cond = "CondId149"}
ViewDef.GrapRobRedEnvelopeTip = {name = "抢红包提醒界面"}

ViewDef.ZsTaskView = {name = "钻石任务"}
ViewDef.DiamondPet = {name = "钻石萌宠", v_open_cond = "CondId139"}
ViewDef.DiamondPetOpenBox = {name = "钻石萌宠-开启宝箱", cannotbeclose = true}

ViewDef.ReXueBossRank = {name = "伤害排名"}

ViewDef.NewlyBossView = {name = "BOSS", default_child = "Wild",v_open_cond = "CondId78",
	Wild = {name = "野外", default_child = "WildBoss",
		WildBoss = {name = "野外BOSS"},
		GongDian = {name = "宫殿BOSS"},
		MayaBoss = {name = "玛雅神殿"},
		Specially = {name = "专属BOSS", v_open_cond = "CondId78",},
		CircleBoss = {name = "转生BOSS"},
	},
	Rare = {name = "稀有", default_child = "VipBoss",
		VipBoss = {name = "会员BOSS"}, 
		MiJing = {name = "龙皇秘境"}, 
		XhBoss = {name = "星魂BOSS"},
		MoyuBoss = {name = "魔域圣殿", v_open_cond = "CondId153",}, 
		ShenWei = {name = "神威秘境", v_open_cond = "CondId152",}, 
	},
	Drop = {name = "限时", default_child = "Chiyou",
		Chiyou = {name = "蚩尤结界"},
		FortureBoss = {name = "运势BOSS"},
		ReXue = {name = "热血霸者", v_open_cond = "CondId151",}, 
		-- Native = {name = "本服掉落"}, 
	},
}

ViewDef.BossTip = {name = "进入boss选择"}


ViewDef.SkillSpecialTip = {name = "特殊技能Tips显示"}

ViewDef.ShowExpTip = {name = "经验副本显示"}

ViewDef.ShowRewardExp = {name = "经验副本奖励"}

ViewDef.TiShuTask = {name = "天书任务"}

ViewDef.WearTitleTip = {name = "称号穿戴提示"}

ViewDef.JiYanView = {name = "经验珠"}


ViewDef.Horoscope = {name = "星魂", default_child = "HoroscopeView",v_open_cond = "CondId119", remind_group_name = "XingHunTabbar",
	 HoroscopeView = {name = "星魂"},
	 SlotStrengthen = {name = "星盘强化",},
	 Collection ={name = "星魂收藏", v_open_cond = "CondId122" },
}

--进阶
ViewDef.Advanced = {name = "进阶", default_child = "Moshu", v_open_cond = "CondId201",
	Moshu = {name = "魔书", v_open_cond = "CondId201", remind_group_name = "MoshuTabbar"},
	YuanSu = {name = "元素", v_open_cond = "CondId202", remind_group_name = "YuansuTababar"},
	ShengShou = {name = "圣兽", v_open_cond = "CondId203", remind_group_name = "ShengShouTabbar"},
}


ViewDef.AdVanced_Tips = { name = "资质"}

ViewDef.FunOpenGuideView = {name = "开启功能"}

ViewDef.ZsVipRedpacker = {name = "10亿红包"}
ViewDef.ZsVipRedpackerAlertAwardView = {name = "10亿红包奖励弹窗"}
-----------------------------------------------------------------------------
-- 界面打开状态变化时其它相关界面的坐标变化配置
OffsetPosCfg = {
	[ViewDef.MainBagView.BagView] = {
		{ViewDef.Storage, cc.p(0, 0)},	-- Bag打开中，如果仓库也打开中，则将界面坐标x轴+300
		{ViewDef.PerShop, cc.p(0, 0)},	-- Bag打开中，如果PerShop也打开中，则将界面坐标x轴+300
	},
	[ViewDef.Storage] = {
		{ViewDef.MainBagView.BagView, cc.p(0, 0)},		-- Storage打开中，如果Bag也打开中，则将界面坐标x轴-300
	},
	[ViewDef.PerShop] = {
		{ViewDef.MainBagView.BagView, cc.p(-70, -50)},
	},
	[ViewDef.HolySynthesis] = {
		{ViewDef.SelectHolyItem, cc.p(-275, 0)},
	},
	[ViewDef.SelectHolyItem] = {
		{ViewDef.HolySynthesis, cc.p(275, 0)},
	},
	[ViewDef.EquipTip] = {
		{ViewDef.CompareEquipTip, cc.p(236, 0)},
	},
	[ViewDef.CompareEquipTip] = {
		{ViewDef.EquipTip, cc.p(-236, 0)},
	},
	[ViewDef.EquipEffShowTip] = {
		{ViewDef.CompareEquipEffShowTip, cc.p(236, 0)},
	},
	[ViewDef.CompareEquipEffShowTip] = {
		{ViewDef.EquipEffShowTip, cc.p(-236, 0)},
	},
}

-- 界面打开状态变化时其它相关界面的显示变化配置
RelationOpenStateCfg = {
	[ViewDef.MainBagView.BagView] = {
		{ViewDef.Storage, false, false}, -- 背包关闭时[2]，仓库[1]关闭[3]
		{ViewDef.PerShop, false, false}, -- 背包关闭时[2]，商店[1]关闭[3]
	},
	[ViewDef.HolySynthesis] = {
		{ViewDef.SelectHolyItem, false, false},
	},
	[ViewDef.GodFurnace] = {
		{ViewDef.HolySynthesis, false, false},
	},
	[ViewDef.EquipTip] = {
		{ViewDef.CompareEquipTip, false, false},
	},
	[ViewDef.EquipEffShowTip] = {
		{ViewDef.CompareEquipEffShowTip, false, false},
	},
}
-----------------------------------------------------------------------------
local function init_view(node, def_str, parent_def)
	node.def_str = def_str
	node.child_group = {}	-- 子节点组
	node.view_key_t = {}	-- 从根节点开始的key顺序表
	for _, str in ipairs(parent_def and parent_def.view_key_t or {}) do
		table.insert(node.view_key_t, str)
	end
	table.insert(node.view_key_t, def_str)
	
	for k, v in pairs(node) do
		if type(v) == "table" and v.name then
			table.insert(node.child_group, v)
			
			init_view(v, k, node)
		end
	end
	
	node.parent_def = parent_def
end
for k, v in pairs(ViewDef) do
	init_view(v, k, nil)
end


NodeName = {
	MainuiTaskBar = "MainuiTaskBar", -- 主办界面任务栏
	MainuiRoleBar = "MainuiRoleBar", -- 主办界面头像栏
	MainuiRoleExp = "MainuiRoleExp", -- 主办界面角色经验
	GodFurnaceActBtn = "GodFurnaceActBtn", -- 神炉激活按钮
	RoleIntroQuickEquip = "RoleIntroQuickEquip", -- 人物总览一键装备
	WingActBtn = "WingActBtn", -- 翅膀激活
	BossIntegral1 = "BossIntegral1", -- boss纹章1
	BossIntegral2 = "BossIntegral2", -- boss纹章2
	BossIntegral3 = "BossIntegral3", -- boss纹章3
	BossIntegral4 = "BossIntegral4", -- boss纹章4
	OfficeActBtn = "OfficeActBtn", -- 官职激活按钮

	CailiaoFuben1 = "CailiaoFuben1", --材料副本-宝石
	CailiaoFuben2 = "CailiaoFuben2", --材料副本-龙魂
	CailiaoFuben3 = "CailiaoFuben3", --材料副本-羽毛
	CailiaoFuben4 = "CailiaoFuben4", --材料副本-铸魂

	PersonalBossLevel20 = "PersonalBossLevel20", --挑战BOSS-20级列表项
	PersonalBossLevel30 = "PersonalBossLevel30", --挑战BOSS-30级列表项
	PersonalBossLevel40 = "PersonalBossLevel40", --挑战BOSS-40级列表项
	PersonalBossLevel50 = "PersonalBossLevel50", --挑战BOSS-50级列表项
	PersonalBossLevel60 = "PersonalBossLevel60", --挑战BOSS-60级列表项
	PersonalBossLevel70 = "PersonalBossLevel70", --挑战BOSS-70级列表项
	PersonalBossLevel80 = "PersonalBossLevel80", --挑战BOSS-80级列表项

	SpecialSkillIcon = "SpecialSkillIcon", -- 必杀技图标

	BagShopXX = "BagShopXX", -- 背包商店第几个商品
}


--------------------------------------------------------------------------------------------------------------
ViewName = {	-------------------------- 要被抛弃的定义，不要用
}

TabIndex = {		-------------------------- 要被抛弃的定义，不要用
	role_intro = 10,								-- 人物-总览
	role_skill = 20,								-- 人物-技能
	role_skill_select = 200,						-- 人物-技能选择
	role_inner = 30,								-- 人物-内功
	role_ls_title = 41,								-- 人物-临时称号
	role_yj_title = 42,								-- 人物-永久称号
	role_tg_title = 43,								-- 人物-天关称号
	role_zhuansheng = 50,							-- 人物-转生
	role_lunhui = 60,							    -- 人物-轮回
	
	boss_can_kill = 10,								-- boss-可以击杀
	boss_wild = 20,									-- boss-野外 
	boss_personal = 30,								-- boss-个人
	boss_sky = 40,									-- boss-天之BOSS
	boss_fuwen = 50,								-- boss-符文
	boss_feixu = 60,								-- boss-神界废墟
	boss_mijing = 70,								-- boss-魔界秘境
	
	equipment_qianghua = 1,							-- 装备-强化
	equipment_affinage = 2,							-- 装备-精炼
	equipment_stone = 3,							-- 装备-镶嵌
	equipment_molding_soul = 4,						-- 装备-铸魂
	-- equipment_blood_mixing = 4,						-- 装备-血炼
	-- equipment_god = 5,								-- 装备-封神
	-- equipment_fuling = 6,							-- 装备-附灵
	-- equipment_fuling_shift = 7,						-- 装备-附灵转移
	equipment_refine = 5,							-- 装备-洗炼
	-- equipment_god_save = 5,							-- 装备-神佑
	compose_jade = 10,								-- 神炉-玉佩
	compose_shield = 20,							-- 神炉-护盾
	compose_gem = 30,								-- 神炉-宝石
	compose_soul_bead = 40,							-- 神炉-魂珠
	compose_hat = 50,								-- 神炉-斗笠
	compose_drum = 60,								-- 战鼓
	compose_ring = 600,								-- 神炉-特戒
	
	eqcompose_equip = 1,							-- 合成-装备合成
	eqcompose_stone = 2,							-- 合成-宝石合成
	eqcompose_god = 3,								-- 合成-神装合成
	eqcompose_dp_equip = 4,							-- 合成-装备分解
	eqcompose_cp_extant = 5,						-- 合成-传世合成
	eqcompose_dp_extant = 6,						-- 合成-传世分解
	eqcompose_pet = 7,								-- 合成-法神合成
	
	-- shop_mystical = 1,								-- 商城-神秘商店
	-- shop_prop = 2,									-- 商城-道具商店
	-- shop_bind_yuan = 3,								-- 商城-绑元商城
	welfare_daily_sign_in = 1,						-- 福利-每日签到
	welfare_login_reward = 2,						-- 登录奖励
	welfare_online_reward = 3,						-- 福利-在线奖励
	welfare_findres = 4,                            -- 福利-资源找回
	welfare_offline_exp = 5,						-- 福利-离线经验
	welfare_gift = 6,								-- 福利-激活码兑换
	welfare_update_affiche = 7,						-- 福利-更新公告
	welfare_wechat_attention = 8,					-- 福利-微信关注
	
	-- welfare_financing = 7,							-- 福利-超值理财
	vip_welfare = 1,								-- VIP-福利
	vip_privilege = 2,								-- VIP-特权
	
	guild_join_list = 1,							-- 行会-加入行会
	guild_create = 2,								-- 行会-行会创建
	guild_info = 3,									-- 行会-行会信息
	guild_member = 4,								-- 行会-行会成员
	guild_build = 5,								-- 行会-行会建设
	guild_list = 6,									-- 行会-行会列表
	guild_storage = 7,								-- 行会-行会仓库
	guild_activity = 8,								-- 行会-行会活动
	guild_events = 9,								-- 行会-行会事件
	guild_rob_red_envelope = 10,					-- 行会-行会红包
	guild_join_req_list = 11,						-- 行会-行会申请处理
	guild_add_member = 12,							-- 行会-添加成员
	
	wangchengzhengba_gcz = 1,						-- 王城争霸-攻城战
	wangchengzhengba_rewards = 2,					-- 王城争霸-攻城奖励
	wangchengzhengba_apply = 3,						-- 王城争霸-攻城申请
	wangchengzhengba_rule = 4,						-- 王城争霸-攻城规则
	
	hallow_god_epuip = 1,						 	-- 圣器-神器
	hallow_god_armer = 2,						 	-- 圣器-神甲
	hallow_accessory = 3,						 	-- 圣器-饰品
	hallow_bamboo_hat = 4,							-- 圣器-斗笠
	hallow_foot_print = 5,                          -- 圣器-足迹
	
	team_info = 1,									-- 组队-队伍成员
	team_near_t = 2,								-- 组队-附近队伍
	team_near_r = 3,								-- 组队-附近玩家
	team_friend = 4,								-- 组队-好友列表
	team_guild = 5,									-- 组队-行会成员
	team_apply = 6,									-- 组队-申请列表
	
	consign_buy_item = 10,							-- 寄售-购买寄售的商品
	consign_my_item = 20,							-- 寄售-寄售自己的商品
	
	setting_assist = 1,								-- 设置辅助
	setting_protect = 2,							-- 设置保护
	setting_fighting = 3,							-- 设置战斗
	setting_pick_up = 4,							-- 设置拾起
	
	openserviceacitivity_xunbao = 1,				-- 开服活动-超值寻宝
	openserviceacitivity_gift = 2,					-- 开服活动-特惠礼包
	openserviceacitivity_super_gift = 3,			-- 开服活动-超值礼包
	openserviceacitivity_financing = 4,				-- 开服活动-超值理财
	openserviceacitivity_boss = 5,					-- 开服活动-全民BOSS
	openserviceacitivity_consume_athletics = 6,		-- 开服活动-全民BOSS
	openserviceacitivity_level = 7,					-- 开服活动-等级竞技
	openserviceacitivity_officer = 8,				-- 开服活动-官印竞技
	openserviceacitivity_hero = 9,					-- 开服活动-战将竞技
	openserviceacitivity_wing = 10,					-- 开服活动-翅膀竞技
	openserviceacitivity_gem = 11,					-- 开服活动-宝石竞技
	openserviceacitivity_saintball = 12,			-- 开服活动-圣珠竞技
	openserviceacitivity_strength = 13,				-- 开服活动-强化竞技
	openserviceacitivity_douli = 14,				-- 开服活动-斗笠竞技
	openserviceacitivity_gongcheng = 15,			-- 开服活动-攻城战
	openserviceacitivity_achievement = 16,			-- 开服活动-建功立业
	openserviceacitivity_bind_gold_give = 17,		-- 开服活动-绑元送送送
	openserviceacitivity_charge = 100,				-- 开服活动-累计充值
	
	achieve_achievement = 10,						-- 成就-成就
	achieve_medal = 20,								-- 成就-勋章	
	
	combinedserv_accumulative = 1,					--合服活动-累计充值
	combinedserv_gongcheng = 2,					  	--合服活动-王城大战
	combinedserv_ybparty = 3,					  	--合服活动-元宝派对
	combinedserv_cbparty = 4,					  	--合服活动-翅膀派对
	combinedserv_bsparty = 5,					  	--合服活动-宝石派对
	combinedserv_zhparty = 6,					  	--合服活动-铸魂派对
    combinedserv_lhparty = 7,					  	--合服活动-龙魂派对
	combinedserv_fashion = 8,					  	--合服活动-绝版时装
	combinedserv_turntable = 9,					  	--合服活动-幸运大转盘

	
	-- fashion_sx = 10,									--时装生肖
	fashion_sz = 10,									--时装扮装
	fashion_hw = 20,									--幻武
	
	wing_wing = 1,										--翅膀-翅膀
	wing_compound = 2, 									--翅膀-影翼合成
	wing_preview = 3, 									--翅膀-影翼预览
	wing_ronghun = 10,									--翅膀-融魂
	
	wing_shenyu = 1,									--翅膀-融魂
	wing_sy_zhuanhuan = 2,									--翅膀-融魂
	wing_sy_hecheng = 3,									--翅膀-融魂
	
	explore_xunbao = 1,										--探索宝藏-探宝
	explore_storage = 2,									--探索宝藏-仓库
	explore_jf_exchange = 3,								--探索宝藏-积分兑换
	
	zhanjiang_zhanjiang = 1,							--战将-战将
	zhanjiang_ronghun = 10,								--战将-融魂
	
	dragon_wall = 10,									--九龙壁
	spiritua_tree = 20,									--封灵数
	
	suit_ad_strength = 1,						-- 套装加成 - 强化
	suit_ad_stone = 2,							-- 套装加成 - 宝石
	suit_ad_soul = 3,							-- 套装加成 - 铸魂
	suit_ad_god = 4,							-- 套装加成 - 封神
	suit_ad_legend = 5,							-- 套装加成 - 传世
	suit_ad_samsara = 6,						-- 套装加成 - 轮回
	
	lunhuiequip_shengjie = 1,					-- 轮回-升阶
	lunhuiequip_mohua = 2,					    -- 轮回-魔化
	
	specialring_left = 1,						-- 特戒-左边
	specialring_right = 2,						-- 特戒-右边
	specialring_soul = 3,						-- 特戒-戒魂
	
	crossbattle_entrance = 1,					-- 六界战场-入口
	crossbattle_equip = 2,						-- 六界战场-装备
	crossbattle_brand = 3,						-- 六界战场-翻牌
	
	equip_refine_normal = 1,					-- 普通洗炼
	equip_refine_peerless = 2,					-- 传世洗炼
	
	recycle_bag = 1,							--回收
	select_recycle_bag = 2,						--回收选择
}

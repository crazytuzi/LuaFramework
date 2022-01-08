--[[
******枚举*******

	-- by Stephen.tao
	-- 2013/11/25
]]

--掉落数据类型枚举
EnumDropType = 
{		
	GOODS 				= 1,					--物品
	ROLE 				= 2,					--角色
	COIN 				= 3,					--铜币
	SYCEE 				= 4,					--元宝
	GENUINE_QI 			= 5,					--真气
	EXP 				= 6,					--团队经验
	ROLE_EXP 			= 7,					--角色经验
	HERO_SCORE 			= 8, 					--群豪谱积分
	VIP_SCORE 			= 9, 					--VIP积分
	XIAYI 				= 10,					--侠义点
	FACTION_GX  		= 11,					--帮派个人贡献
	RECRUITINTEGRAL  	= 12,					--抽卡积分
	VESSELBREACH		= 14,					--经脉突破 精露资源类型
	CLIMBSTAR			= 15,					--无量山星星
	YUELI				= 16,					--阅历
	SHALU_VALUE			= 17,					--杀戮值
	TEMP_COIN			= 18,					--临时铜币
	TEMP_YUELI			= 19,					--临时阅历
	BIBLE				= 20,					--天书
	LOWHONOR			= 21,					--低阶荣誉令牌
	HIGHTHONOR			= 22,					--高阶荣誉令牌
	PUSH_MAP			= 126,					--体力
	LEVEL 				= 127,					--团队等级
}

--通用头部资源类型定义枚举
HeadResType = 
{
	GOODS 			= 1,					--物品
	ROLE 			= 2,					--角色
	COIN 			= 3,					--铜币
	SYCEE 			= 4,					--元宝
	GENUINE_QI 		= 5,					--真气
	EXP 			= 6,					--团队经验
	ROLE_EXP 		= 7,					--角色经验
	HERO_SCORE 		= 8, 					--群豪谱积分
	PUSH_MAP 		= 9,					--推图体力（关卡体力）
	QUNHAO 			= 10,					--群豪谱体力
	CLIMB 			= 11, 					--
	SKILL_POINT 	= 12,					--技能点
	XIAYI			= 13,					--侠义点
	FACTION_GX  	= 14,					--帮派个人贡献
	RECRUITINTEGRAL = 15,					--抽卡积分
	CLIMBDIAMOD 	= 16,					--无量山钻
	JIEKUANGLING 	= 17,					--劫矿令
	CLIMBSTAR 		= 18,					--无量山星星
	YUELI			= 19,					--阅历(天书)
	BAOZI			= 20,					--奇遇-包子
	LOWHONOR		= 21,					--低阶荣誉令牌
	HIGHTHONOR		= 22,					--高阶荣誉令牌
	ZHENBCY			= 51,					--珍本残页
	SHANBCY			= 52,					--善本残页
	QUANBCY			= 53,					--全本残页
	CHAOBCY			= 54,					--抄本残页
	CANBCY			= 55,					--残本残页
	LEVEL 			= 127,					--团队等级
}

--[[
	通用界面头部栏类型定义
]]
ModuleType = 
{
	"Mall", 			--购物中心（商城）
	"Bag",				--背包
	"Smithy",			--铁匠铺

	"RoleTransfer", 	--角色修炼
	"RoleTrain", 		--角色经脉
	"Task",				--成就
	"Notify",			--消息
	"Qiyu",				--奇遇
	"PVP",				--挑战
	"Arena",			--群豪谱
	"Climb",			--无量山
	"Climb_Soul",		--无量山
	"HandBook",			--图鉴
	"Bloodybattle", 	--血战
	"Leaderboard",		--排行榜
	"JifenShop",		--积分商城
	"YunYingHuoDong", 	--运营活动
	"Recruit",		--酒馆
	"SmithySell",		--装备出售
	"Hermit",		--归隐
	"BossFight",		--boos战
	"Faction",			--帮派
	"Jyt_Faction",		--帮派聚义厅
	"Rank_Faction",		--帮派排行榜
	"Zyt_Faction",		--帮派忠义堂
	"Friend",		    --帮派忠义堂
	"ZhengBa",
	"Wulin",
	"FactionMall",
	"WeekRace",			--周赛
	"Hs_Faction",		--帮派后山
	"PracticeFaction",	--帮派修炼场
	"InheritFaction",	--修炼场传承
	"PracticeXL",		--修炼场修炼
	"Employ",			--雇佣佣兵
	"Mining",			--采矿
	"LootMineral",		--劫矿	
	"ChooseMineral",	--选矿
	"Qimendun",			--奇门遁
	"QiYuan",			--祈愿
	"FactionFight",		--帮派战
    "FactionMessage",  --信息回顾
    "FactionFightMessage" ,--争锋
    "Gamble" ,			--赌石
	"TianShu",			--天书
    "Smriti",           --装备置换
    "youli",			--游历玩法
	"JingYao",			--精要主界面
	"JingyaoFenjie",	--精要分解界面
	"CangShuGe",		--天书商店
	"XiaKe",			--侠客商店
	"Honor",			--跨服商店
	"KFWLDH",			--跨服武林大会
	"HuanGong",			--角色换功
	"EquipChange",		--装备互换
	"None", 			--无
}
ModuleType = CreatEnumTable(ModuleType)

--卡牌数据类型枚举
EnumGameObjectType = 
{		
	"Role",			--弟子
	"Equipment",	--装备
	"Skill",		--武功
	"Strategy",		--阵法
	"Methods",		--口诀
	"Item",			--道具
}

EnumGameObjectType = CreatEnumTable(EnumGameObjectType)

--装备类型枚举
EnumSoulKind = 
{
	"Normal",			--普通角色魂
	"Master",			--主角角色魂
	"EXP",				--经验魂
}
EnumSoulKind = CreatEnumTable(EnumSoulKind)


--物品类型枚举
EnumGameItemType = 
{
	"Equipment",		--装备
	"Gem",				--宝石
	"Item",				--道具
	"Box",				--宝箱
	"Atlas", 			--图谱
	"Book", 			--秘籍
	"Soul",				--魂魄
	"Piece",			--碎片(装备)
	"Stuff",			--材料
	"Token",			--代币
	"RandomPack",		--随机礼包
	"SkyBook",			--天书
	"SkyBookPiece",		--天书碎片
	"SBStone",			--历练石--天书升级石
	"SBStonePiece",		--历练石碎片
	"HeadPicFrame",		--头像框碎片
	"Rubbish",			--垃圾
}

EnumGameItemType = CreatEnumTable(EnumGameItemType)

--装备类型枚举
EnumGameEquipmentType = 
{
	"Weapon",			--武器
	"Clothes",			--衣服
	"Ring",				--戒指
	"Belt", 			--腰带
	"Shoe",				--靴子
	"EquipmentTypeMax"	
}

EnumGameEquipmentType = CreatEnumTable(EnumGameEquipmentType)

--装备类型枚举
GameEquipmentTypeStr = 
{
	"武器",			--武器
	"衣服",			--衣服
	"戒指",			--戒指
	"腰带", 		--腰带
	"靴子",			--靴子
}


-- --道具类型枚举
-- EnumGameItemKind = 
-- {
-- 	"Normal",			--普通道具（无法在背包中使用）
-- 	"Used",				--可使用道具
-- 	"Box",				--礼包
-- }

-- EnumGameItemKind = CreatEnumTable(EnumGameItemKind)

--属性类型枚举
EnumAttributeType = 
{
	Blood = 1,			--气血
	Force = 2,			--武力
	Defence = 3,			--防御
	Magic = 4,			--内力
	Agility = 5,			--身法
	Ice = 6,				--冰
	Fire = 7,				--火
	Poison = 8,			--毒
	IceResistance = 9,    --冰抗
	FireResistance = 10,  	--火抗
	PoisonResistance = 11 , --毒抗 
	Crit = 12 ,				--暴击
	CritResistance = 13 ,	--暴抗
	Preciseness = 14 ,				--命中
	Miss = 15 ,						--闪避
	CritPercent = 16 ,				--暴击率
	PrecisenessPercent = 17 ,		--命中率
	BloodPercePercent = 18 ,		--气血%
	ForcePercePercent = 19 ,		--武力%
	DefencePercePercent = 20,		--防御%
	MagicPercePercent = 21,		--内力%
	AgilityPercePercent = 22,		--身法%
	IcePercePercent = 23,			--冰%
	FirePercePercent = 24,			--火%
	PoisonPercePercent = 25,		--毒%
	IceResistancePercent = 26,		--冰抗%
	FireResistancePercent = 27,	--火抗%
	PoisonResistancePercent = 28,	--毒抗%

	CritResistancePercent = 29 ,	--暴抗%
	MissPercent = 30 ,						--闪避%
	BonusHealing = 31,				--治疗加成

	Max = 32,

}

-- EnumAttributeType = CreatEnumTable(EnumAttributeType)

-- AttributeTypeStr = 
-- {
-- 	"气血",
-- 	"武力",
-- 	"防御",
-- 	"内力",
-- 	"身法",
-- 	"冰攻",
-- 	"火攻",
-- 	"毒攻",
-- 	"冰抗",
-- 	"火抗",
-- 	"毒抗",
-- 	"暴击",
-- 	"抗暴",
-- 	"命中",
-- 	"闪避",
-- 	"暴击率",
-- 	"命中率",
-- 	"气血",
-- 	"武力",
-- 	"防御",
-- 	"内力",
-- 	"身法",
-- 	"冰攻",
-- 	"火攻",
-- 	"毒攻",
-- 	"冰抗",
-- 	"火抗",
-- 	"毒抗",
-- 	"暴抗率",
-- 	"闪避率",
-- 	"治疗加成",
-- 	-- "当前气血",		---30
-- 	-- "攻击百分比",  ---31
-- }

AttributeTypeStr = localizable.AttributeTypeStr

--商店类型枚举 --1、商城；2、通用普通商店；3、天罡星商城；4、帮派商城……
EnumShopType = 
{		
	"Box",			--1、礼包；
	"Item",			--2、通用道具商店；
	"TianGang",		--3、天罡星商城；
	"Gang",		  	--4、帮派商城
}

EnumShopType = CreatEnumTable(EnumShopType)

--商城类型枚举
EnumMallType = 
{
	"NormalMall",		--普通商城
	"CardRoleMall",		--侠客商城
	"QunHaoMall",		--群豪商城
	"FactionMall",		--帮会商城
	"AdventureMall",	--天书商城
	"HonorMall",		--荣誉商城
}

EnumMallType = CreatEnumTable(EnumMallType)


-- 1、敌方单体；
-- 2、敌方全体；
-- 3、敌方横排；
-- 4、敌方竖排；
-- 5、敌方随机；
-- 6、敌方血最少；
-- 7、敌方防最少；
-- 8、我方随机；
-- 9、我方血最少；
-- 10、我方全体；
-- 11、自己；
--技能目标类型枚举 
EnumSkillTargetType = 
{		
	"DiFangDanTi",		
	"DiFangQuanTi",		    
	"DiFangHengPai",	
	"DiFangShuPai",		
	"DiFangSuiJi",
	"DiFangXueZuiShao",
	"DiFangFangZuiShao",
	"WoFangSuiJi",
	"WoFangXueZuiShao",
	"WoFangQuanTi",
	"ZiJi",
}
EnumSkillTargetType = CreatEnumTable(EnumSkillTargetType)

-- SkillTargetTypeStr = 
-- {		
-- 	"敌方单体",		
-- 	"敌方全体",		
-- 	"敌方横排",		
-- 	"敌方竖排",	
-- 	"敌方随机",		
-- 	"敌方血最少",		
-- 	"敌方防最少",		
-- 	"我方随机",	
-- 	"我方血最少",		
-- 	"我方全体",		
-- 	"自己",		
-- 	"敌方防最高",		
-- 	"敌方内力最高",		
-- 	"敌方内力最低",	
-- 	"敌方武力最高",		
-- 	"敌方武力最低",		
-- 	"我方武力最高",		
-- 	"我方武力最低",		
-- 	"我方内力最高",		
-- 	"我方内力最低",		
-- }
SkillTargetTypeStr = localizable.SkillTargetTypeStr

-- 1、主动技能；
-- 2、主动治疗；
-- 3、主动技能；
-- 4、被动属性；
-- 5、增益光环；
-- 6、减持光环；
-- 7、被动技能；
-- 8、主动技能；
--技能类型枚举 
EnumSkillType = 
{		
	"ZhuDongGongJi",		
	"ZhuDongZhiLiao",		    
	"ZhuDongJingHua",	
	"BeiDongShuXing",		
	"BeiDongZengYiGuangHuan",
	"BeiDongChiJianGuangHuan",
	"BeiDongJiNeng",
	"AnQi",
}

EnumSkillType = CreatEnumTable(EnumSkillType)

-- SkillTypeStr = 
-- {		
-- 	"主动技能",		
-- 	"主动治疗",		
-- 	"主动技能",		
-- 	"被动属性",	
-- 	"增益光环",		
-- 	"减持光环",		
-- 	"被动技能",		
-- 	"主动技能",		
-- }
SkillTypeStr = localizable.SkillTypeStr

-- SkillSexStr = 
-- {		
-- 	"异性",		
-- 	"同性",			
-- }
SkillSexStr = localizable.SkillSexStr

-- SkillEffectStr = 
-- {		
-- 	"吸怒",		
-- 	"减敌怒",		
-- 	"增己怒",		
-- 	"吸血",	
-- 	"反弹",		
-- 	"反击 ",		
-- 	"化解",		
-- 	"破阵 ",	
-- 	"复活",		
-- 	"净化 ",		
-- 	"致死",		
-- 	"免疫",	
-- 	"",
-- 	"",
-- 	"",
-- 	"",
-- 	"",
-- 	"",
-- 	"",
-- 	"乾坤",
-- 	"七伤",
-- 	[22]= "吸星大法",
-- 	[23]= "吸星大法",
-- 	[24]= "伤害递增",
-- 	[25]= "闪避释放技能",
-- }
SkillEffectStr = localizable.SkillEffectStr

-- SkillBuffHurtStr = 
-- {
-- 	"中毒",		
-- 	"灼烧",		
-- 	"破绽",		
-- 	"虚弱",		
-- 	"内伤",		
-- 	"迟缓",		
-- 	"失明",		
-- 	"神力",		
-- 	"防守",		
-- 	"混乱",		
-- 	"散功",		
-- 	"点穴",		
-- 	"眩晕",		
-- 	"冻结",		
-- 	"昏睡",		
-- 	"低落",		
-- 	"回血",	
-- 	"",
-- 	"",	
-- 	"痛饮",		
-- 	"逍遥游",		
-- 	"易筋",		
-- 	"背剑",		
-- 	"天池",		
-- 	"赏善",		
-- 	"罚恶",
-- 	"",
-- 	-- "",
-- 	-- "",
-- 	-- "",
-- 	-- "",
-- 	[31]="逆行经脉",
-- 	[33]="不死不休",		
-- 	[34]="不死不休",
-- 	[35]="寒毒",
-- 	[36]="寒毒",	
-- 	[37]="胆怯",


-- 	[40]= "普攻伤害",
-- 	[41]= "技能伤害",
-- 	[42]= "毒和火的持续伤害",
-- 	[43]= "负面状态概率",
-- 	[44]= "伤害",
-- 	[45]= "治疗量",
-- 	[46]= "增益属性状态效果",
-- 	[47]= "负面属性状态效果",
	
-- 	[50]= "流血",
-- 	[51]= "吸星大法",
-- 	[52]= "吸星大法",
-- 	[53]= "必中",
-- 	[54]= "技能反击",
-- 	[55]= "重伤",
-- }
SkillBuffHurtStr = localizable.SkillBuffHurtStr

--聊天类型枚举
EnumChatType = 
{		
	"Public"     ,  --公聊
	"Gang"	     ,	--帮派
	"GM" 	     ,  --GM频道
	"PrivateChat",	--私聊
	"Server",--跨服
	"FactionNotice", --帮派通告
	"VipDeclaration" --土豪发言
}

EnumChatType = CreatEnumTable(EnumChatType)

--[[
	随机商店类型定义
]]
QualityType = 
{
	"Ding", 		--1 丁
	"Bing", 		--2 丙
	"Yi", 			--3 乙
	"Jia", 			--4 甲
	"Max",	---
}

QualityType = CreatEnumTable(QualityType)
QualityHeroType = 
{
	"XiaKe", 			--1 侠客
	"DaXia", 			--2 大侠
	"Haoxia", 			--3 豪侠
	"Zongshi", 			--4 宗师
	"ChuanShuo", 		--4 传说
	"Max",	---
}

QualityHeroType = CreatEnumTable(QualityHeroType)

--[[
	随机商店类型定义
]]
RandomStoreType = 
{
	"Normal", 		--商城中的商店（普通随机商店）
	"QunHao",		--群豪谱随机商店
	"Xiyou",		--商城中的商店（稀有随机商店）
	"Zhenbao",		--商城中的商店（珍宝随机商店）
	"Role",			--侠魂商城
	"Gang_Normal",	--帮派商店（普通）
	"Gang_2",		--帮派商店（普通）
	"Gang_3",		--帮派商店（普通）
	"Honor",		--跨服荣誉商店
	"Honor_2",		--跨服精品商店
}

RandomStoreType = CreatEnumTable(RandomStoreType)

--可恢复资源枚举
EnumRecoverableResType = 
{		
	PUSH_MAP 	= 1,				--推图体力（关卡体力）
	QUNHAO 		= 2,				--群豪谱体力
	CLIMB 		= 3, 				--无量山体力
	SKILL_POINT = 4,				--技能点
	MOHEYA1 	= 5, 				--摩诃衍1
	MOHEYA2 	= 6, 				--摩诃衍2
	MOHEYA3 	= 7, 				--摩诃衍3
	NIUBILITY 	= 8, 				--点赞
	MINE 		= 9, 				--劫矿次数
	BAOZI		= 10,				--奇遇包子
	SHALU_COUNT	= 11,				--奇遇杀戮次数
}

--功能模块定义枚举
EnumServiceType = {
	LOGIN = 0x0d, 			--登录
	ROLE = 0x0e,			--角色
	BATTLE = 0x0f,			--战斗
	GOODS = 0x10,			--物品
	PUSH_MAP = 0x12,		--推图
	QUN_HAO = 0x13,			--群豪谱
	EVER_QUEST = 0x14,		--铜人阵
	ROLE_TRAIN = 0x15,		--角色培养
	MIJI = 0x16,			--秘籍
	CLIMB = 0x17,			--无量山
	GANG = 0x18,			--帮派
	MALL = 0x19,			--商城
	RECHARGE = 0x1A,		--充值
	CHAT = 0x1B,			--聊天
	REICUTE = 0x1C,			--招募
	TFSSAGE = 0x1D,			--消息
	SETTING = 0x1E,			--设置
	SKILL = 0x1F,			--技能（废弃，原团队技能）
	TASK = 0x20,			--成就，任务
	RECOVERY_POINT = 0x21,	--体力
	TREASURE = 0x22,		--江湖宝藏
	SPELL = 0x24,			--法术，角色技能
	DROP = 0x7E,			--掉落
	PUBLIC = 0x7F			--公共模块
}

--[[
活动类型定义枚举
]]
EnumActivitiesType = {
	DXCCC 						= 1,			--大侠冲冲冲
	XZWLZZ 						= 2,			--寻找武林至尊
	SSJHCGW 					= 3,			--谁是闯关王
	LOGON_REWARD 				= 4,			--登录奖励7日
	ONLINE_REWARD 				= 5,  			--在线奖励
	TEAM_LEVEL_UP_REWARD 		= 6,			--团队等级升级奖励
	JOIN_QQ_QUN					= 7,			--加入QQ群
	REPORT_BUG 					= 8, 			--提交bug
	VIP_GET 					= 9,			--送VIP
	INVITE 						= 10, 			--邀请好友

	-- 新增活动 从11开始
	LEIJICHONGZHI				= 11,			--累计充值
	DANGRICHONGZHI				= 12,			--当日充值
	DANBICHONGZHI				= 13,			--单笔充值
	LEIJIXIAOFEI				= 14,			--累计消费
	DANGRIXIAOFEI				= 15,			--当日消费
	LIANXUDENGLU				= 16,			--连续登陆
	ONLINE_REWARD_NEW			= 17,			--在线奖励
	TUANDUIDENGJI				= 18,			--团队等级升级奖励
	QIRIDENGLU					= 19,			--登录奖励7日
	ZHAOBUG						= 20,			--找bug
	YAOHAOYOU					= 21,			--邀请好友
	DUCHANG						= 22,			--赌场
	TEN_CARD					= 23,			--十连抽
	HAPPY_TOGETHER				= 24,			--普天同寝
	PAY_FOR_REDBAG				= 25,			--充值返红白
	EXCHANGE					= 26,			--兑换物品
	V8_PRIZE					= 27			--V8外礼包
}

-- 物品产出途径
-- EnumItemOutPutType = {"关卡", "群豪谱", "无量山", "摩诃崖", "护驾", "龙门镖局", "商店", "招募" ,"金宝箱", "银宝箱", "暂无途径产出"}
--                       1       2        3          4       5        6          7       8        9          10        11       12        13       14     15      16    17      18      19    			 20       21     22
-- EnumItemOutPutType = {"关卡", "群豪谱", "无量山", "摩诃崖", "护驾", "龙门镖局", "商店", "酒馆" ,"金宝箱", "银宝箱", "铜宝箱","VIP奖励","VIP礼包","活动","签到","成就","日常", "雁门关", "通过活动获取", "祈愿","藏书阁","游历"}
EnumItemOutPutType = localizable.EnumItemOutPutType

-- 武学的等级描述
-- EnumWuxueLevelType = {"一", "二" , "三", "四" , "五", "六", "七", "八", "九", "十", "十一", "十二", "十三", "十四", "十五", "十六", "十七"}
EnumWuxueLevelType = localizable.EnumWuxueLevelType

--added by wuqi
--天书重数
-- EnumSkyBookLevelType = {"一", "二" , "三", "四" , "五", "六", "七", "八", "九", "十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十"}
EnumSkyBookLevelType = localizable.EnumSkyBookLevelType

-- 武学一重：初探门径、武学二重：熟能生巧、武学三重：小有所成、武学四重：登堂入室、武学五重：炉火纯青、武学六重：登峰造极、武学七重：出神入化、武学八重：返璞归真、武学九重：一代宗师
-- EnumWuxueDescType   = {"初探门径","熟能生巧","小有所成","登堂入室","炉火纯青","登峰造极","出神入化","返璞归真","一代宗师","一代宗师","小隐于野","大隐于市","只是传说","近乎仙人","一代宗师","一代宗师","一代宗师","一代宗师"}
EnumWuxueDescType = localizable.EnumWuxueDescType

-- 秘籍的等级描述
-- EnumBookDescType   = {"普通","高级","专家","宗师","传说"}
EnumBookDescType = localizable.EnumBookDescType
-- 武学颜色
EnumWuxueColorType = 
{
	ccc3(72,88,255),--1
	ccc3(72,88,255),--2
	ccc3(72,88,255),--3
	ccc3(72,88,255),--4
	ccc3(72,88,255),--5
	ccc3(72,88,255),--6
	ccc3(72,88,255),--7
	ccc3(72,88,255),--8
	ccc3(72,88,255),--9
	ccc3(72,88,255),--10
	ccc3(72,88,255),--11
	ccc3(72,88,255),--12
	ccc3(72,88,255),--13
	ccc3(72,88,255),--14
	ccc3(72,88,255),--15
	ccc3(72,88,255),--16
	ccc3(72,88,255)--17
}

-- 武学等级对应的背景极及颜色索引
EnumWuxueBGType = 
{
	1, 2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 5
----1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17
}

-- 技能解锁对应的武学等级
EnumSkillLock = {1, 2, 4}


QiYuType = 
{
	"EatPig",		--吃猪
	"Invite",		--邀请码
	"EscortTran",		--押镖
	"Escorting",		--护驾
	"NewSign",		--签到
	"Gamble",		--赌石
	"Tmall",		--天猫
	"Max",
}

QiYuType = CreatEnumTable(QiYuType)

LianTiQualityNameStr = 
{
	localizable.LianTi_Quality_Name_1,
	localizable.LianTi_Quality_Name_2,
	localizable.LianTi_Quality_Name_3,
	localizable.LianTi_Quality_Name_4
}

ServerSwitchType = 
{
    Server		= 1,            --"服务器",
    Login		= 2,			--"登录",
    Pay			= 3,            --"充值",
    Register	= 4,            --"注册",
    LiBaoMa		= 5,            --"礼包码",
    WeiXin		= 6,			--"微信关注",
    EatPig		= 7,            --"御膳房",
    Invite		= 8,            --"邀请码",
    EscortTran	= 9,            --"龙门镖局",
    Escorting	= 10,            --"护驾",
    NewSign		= 11,            --"签到",
    MonthCard	= 12,            --"月卡",
    Tmall		= 16,            --"天猫",
    ServerChat 	= 17,			--跨服聊天
    GongLv	 	= 20,			--攻略
}

--quanhuan add RankListType
RankListType = {
	Rank_List_None = 0,
	Rank_List_Hero = 1,		--英雄榜
	Rank_List_Qunhao = 2,	--群豪榜
	Rank_List_Wuliang = 3,	--无量榜
	Rank_List_Xiake = 4,	--侠客榜
	Rank_List_Shengbin = 5,	--神兵榜
	Rank_List_fumo = 6,	    --附魔榜
	Rank_List_FactionLevel = 7,		--公会等级榜
	Rank_List_FactionPower = 8,		--公会战力榜
	Rank_List_ShaLu = 13,	--杀戮榜
	Rank_List_Max = 14
}

LineUpType = {
	LineUp_Main 			= 1,	--主阵容
	LineUp_BloodyBattle 	= 2,	--血战
	LineUp_Attack 			= 3,	--武林大会攻击阵容
	LineUp_Defense 			= 4,	--武林大会防守阵容
	LineUp_QunhaoDef		= 5,	--群豪谱防守
	LineUp_Mine1_Defense 	= 6,	--挖矿防守阵型1
	LineUp_Mine2_Defense	= 7,	--挖矿防守阵型2
	LineUp__MERCENARY_TEAM  = 8,	--我方派遣的雇佣队伍
	LineUp_HIRE_TEAM  		= 9,	--我方雇佣阵型
	LineUp_DOUBLE_1			= 10,	--双阵容 一
	LineUp_DOUBLE_2			= 11,	--双阵容 二
	LineUp_MAX				= 12,
}


EnumFightEffectType = {
	FightEffectType_NormalAttack = 40,		--普攻修正
	FightEffectType_SkillAttack = 41,		--技能修正
	FightEffectType_DotHurt = 42,			--dot伤害修正
	FightEffectType_DotPercent = 43,		--dot几率修正
	FightEffectType_HurtGain = 44,			--总伤害修正
	FightEffectType_BonusHealing = 45,		--治疗修正
	FightEffectType_GoodAttr = 46,		--有益属性修正值
	FightEffectType_BadAttr = 47,		--减益属性修正值
	FightEffectType_NoShanBi = 48,		--无视强制闪避
}
EnumFightAttributeType = {
	Immune = 1,					-- 免疫属性
	Effect_extra = 2,			-- 效果属性
	Be_effect_extra = 3,		--被动效果属性
}

EnumFightStrategyType = {
	StrategyType_PVE 			= 1,					--主阵型
	StrategyType_BLOOY 			= 2,					--雁门关
	StrategyType_CHAMPIONS_ATK 	= 3,					--挑战赛攻击
	StrategyType_CHAMPIONS_DEF 	= 4,					--挑战赛防守
	StrategyType_AREAN 			= 5,					--群豪谱防守
	StrategyType_MINE1_DEF 		= 6,					--挖矿1
	StrategyType_MINE2_DEF 		= 7,					--挖矿2
	StrategyType_MERCENARY_TEAM = 8,					--我方派遣的雇佣队伍
	StrategyType_HIRE_TEAM		= 9,					--我方雇佣阵型
	StrategyType_DOUBLE_1		= 10,					--双阵容 一
	StrategyType_DOUBLE_2		= 11,					--双阵容 二
	StrategyType_Max			= 12,
}

-------------------------------------------
--module(..., package.seeall)

local require = require;


require("cocos/cocos2d/Cocos2d")
require("i3k_math");
require("i3k_engine");


-------------------------------------------
-- global handler
g_i3k_game_handler 	= nil;

g_i3k_mmengine		= nil;
g_i3k_ui_mgr		= nil;
g_i3k_rpc_manager	= nil;
g_i3k_db			= nil;
g_i3k_open_time		= "";
g_syncTick			= 150;

EFS_NATIVE			= 0;
EFS_KIO				= 1;

EPP_0 = 0;
EPP_1 = 1;
EPP_2 = 2;
EPP_3 = 3;

eOS_TYPE_WIN32		= 1;
eOS_TYPE_IOS		= 2;
eOS_TYPE_OTHER		= 0;

-- 性别，男女
eGENDER_MALE		= 1;
eGENDER_FEMALE		= 2;

--弹出飘字类型
g_BATTLE_SHOW_EXP = 1
g_BATTLE_SHOW_BUFF = 2
g_BATTLE_SHOW_SUPERWEAPON = 3
--基础职业定义
g_BASE_PROFESSION_DAOKE = 1;
g_BASE_PROFESSION_JIANSHI = 2;
g_BASE_PROFESSION_QIANGHAO = 3;
g_BASE_PROFESSION_GONGSHOU = 4;
g_BASE_PROFESSION_YISHI = 5;
g_BASE_PROFESSION_QUANSHI = 8;

--物品类型
g_COMMON_ITEM_TYPE_EQUIP 		= 0
g_COMMON_ITEM_TYPE_BASE			= 1
g_COMMON_ITEM_TYPE_ITEM			= 2
g_COMMON_ITEM_TYPE_GEM			= 3
g_COMMON_ITEM_TYPE_BOOK			= 4
g_COMMON_ITEM_TYPE_PET_EQUIP	= 5 -- 宠物装备 
g_COMMON_ITEM_TYPE_HORSE_EQUIP	= 6 -- 骑战装备
g_COMMON_ITEM_TYPE_DESERT_EQUIP	= 150 -- 荒漠装备
g_COMMON_ITEM_TYPE_DESERT_ITEM	= 151 -- 荒漠道具
g_COMMON_ITEM_TYPE_ADD_ACTIVITY_TIMES = 81 --试炼次数
g_COMMON_ITEM_ADD_ACTIVITY_TIMES_ID = nil --试炼道具ID
g_MAX_CURRENCY_AMOUNT = 999999999 -- 铜钱最大数


--基础物品类型
g_BASE_ITEM_DIAMOND 				= 1		--元宝
g_BASE_ITEM_COIN					= 2		--铜钱
g_BASE_ITEM_SECT_MONEY				= 3		--帮贡
g_BASE_ITEM_ARENA_MONEY				= 4		--竞技场点数
g_BASE_ITEM_TOURNAMENT_MONEY		= 5		--会武币
g_BASE_ITEM_ESCORTT_MONEY			= 6		--劫镖金币
g_BASE_ITEM_CREDIT					= 7 	--角色商誉值
g_BASE_ITEM_MASTER_POINT            = 8     --师徒点
g_BASE_ITEM_EQUIP_ENERGY			= 31	--装备能量
g_BASE_ITEM_GEM_ENERGY				= 32	--宝石能量
g_BASE_ITEM_BOOK_ENERGY				= 33	--心法悟性
g_BASE_ITEM_EXP						= 1000	--经验
g_BASE_ITEM_VIT						= 10	--体力
g_BASE_ITEM_IRON					= 41	--玄铁
g_BASE_ITEM_HERB					= 42	--药草
g_BASE_ITEM_EMP                     = 43    --历练
g_BASE_ITEM_SPLITSP					= 11	--生产分解能量
g_BASE_ITEM_OFFLINE_POINT			= 45	--挂机点数
g_BASE_ITEM_WEAPONSOUL				= 47	--武运
g_BASE_ITEM_VIP						= 1001	--vip点数
g_BASE_ITEM_FEISHENG_EXP			= 1002	--飞升经验
g_BASE_ITEM_DIVIDEND                = 12    --红利
g_BASE_ITEM_PETCOIN                 = 46    -- 宠物赛跑货币
g_BASE_ITEM_DRAGON_COIN				= 13    --龙魂币
g_BASE_ITEM_FAME                    = 14    -- 武林声望
g_BASE_ITEM_SECT_HONOR				= 15	--帮派荣誉
g_BASE_ITEM_BUDO					= 16	--盟主令
g_BASE_ITEM_BAGUA_ENERGY			= 48	--八卦能量
g_BASE_ITEM_QIYUN					= 17	--奇遇气运
g_BASE_ITEM_SPIRIT_BOSS				= 49	--巨灵攻城护城勋章
g_BASE_ITEM_PET_EQUIP_SPIRIT		= 51	--宠物装备精华
g_BASE_ITEM_STEED_EQUIP_SPIRIT		= 53	--熔炼精华
g_BASE_ITEM_STONE_ENERGY			= 57	--密文能量
--g_BASE_ITEM_REGULAR					= 2000	--定期活动获取


--渠道
g_OPPO_CHANNEL = 2078		--	oppo渠道
--gm指令
g_SET_LEVEL					= 1 --设置角色等级
g_ADD_ITEM					= 2 --添加道具
g_ADD_EXP					= 3--添加经验
g_SET_TIME					= 4--修改时间
g_ADD_ROLE_PROPERTY			= 5--添加属性
g_SET_TRANSFER_LEVEL		= 6--转职等级
g_EQUIP_UPLEVEL				= 7--装备升级
g_OFFLINE_SPRITE_LEVEL		= 8--挂机精灵等级
g_JUMP_TASK					= 9--跳过任务
g_SET_SECT_LEVEL			= 10--帮派等级
g_SECT_ACTIVITY				= 11--帮派活跃
g_PERSON_ACTIVITY			= 12--个人活跃
g_UNDER_WEAR				= 13--内甲
g_PET_FEED_LEVEL			= 14--宠物喂养等级
g_CALL_BOSS					= 15--召唤boss
g_DIY_SKILL_LEVEL			= 16--自创武功等级
g_SET_EVIL_POINT			= 17--调整罪恶点
g_PRODUCE_LEVEL				= 18--生产等级
g_ADD_CHARM					= 19--添加魅力
g_ADD_WUXUN					= 20--增加武勋
g_ADD_HONOR					= 21--增加荣誉
g_UNDERSTAND_LEVEL			= 22--参悟等级
g_SUPER_WEAPON_PRO			= 23--神兵熟练度
g_ARTIFACT_STRENGTHEN		= 24--神器强化
g_ARTIFACT_REFINE			= 25--神器精炼
g_ADD_GROUP_POINT			= 26--增加分堂积分
g_WEAPON_SOUL_STEP			= 27--武魂品阶
g_STAR_LIGHT_SHAPE			= 28--星耀形状
g_ACTIVE_STAR_LIGHT			= 29--激活星耀
g_OPEN_GARRISON				= 30--开启驻地
g_SECT_BOSS_PROGRESS		= 31--帮派伏魔进度
g_DAILY_ACTIVITY			= 32--日常试炼
g_FIVE_UNIQUE_ACTIVITY		= 33--五绝试炼
g_EQUIP_STRENGTHEN			= 34--装备强化
g_WUDAOHUI_POINT			= 35--武道会积分
g_WUDAOHUI_HONOR			= 36--武道会荣誉
g_ADD_BL_EXP				= 37--封印经验
g_ADD_WIZZARD_PET_EXP		= 38--离线经验
g_ADD_PET_COEXP				= 39--宠物喂养经验
g_GM_CREATE_TEST			= 40--创建测试entity播放动作
g_GM_HIDE_TITLE_INFO		= 41--隐藏entity头顶相关
g_GM_ADD_ITEM_BY_NAME		= 42--通过物品名字加物品

g_GM_COMMAND =
{
	[1] = "@#setrolelevel %s",
	[2] = "@#add %s %s",
	[3] = "@#addexp %s",
	[4] = "@#settime %s",
	[5] = "@#addprop %s %s",
	[6] = "",
	[7] = "",
	[8] = "",
	[9] = "@#jumpmtask %s",
	[10] = "@#setsectlevel %s",
	[11] = "@#addsectvit %s",
	[12] = "",
	[13] = "",
	[14] = "",
	[15] = "@#worldboss %s",
	[16] = "",
	[17] = "",
	[18] = "",
	[19] = "@#addcharm %s",
	[20] = "@#addfeat %s",
	[21] = "@#addhonor %s",
	[22] = "",
	[23] = "@#addweaponmaster %s %s",
	[24] = "",
	[25] = "",
	[26] = "@#addsectwarscore %s",
	[27] = "",
	[28] = "",
	[29] = "",
	[30] = "",
	[31] = "@#addsectzoneboss %s",
	[32] = "",
	[33] = "",
	[34] = "",
	[35] = "@#addtournamentscore %s",
	[36] = "@#addtournamenthonor %s",
	[37] = "@#addblexp %s",
	[38] = "@#addwizzardpetexp %s",
	[39] = "@#addpetcoexp %s %s",
	[40] = "",
	[41] = "",
	[42] = "",
}


--副本地图类型
g_FIELD						= 0 --大地图
g_BASE_DUNGEON				= 1 --普通副本
g_FACTION_DUNGEON			= 2 --帮派副本
g_ARENA_SOLO				= 3 --单人竞技场
g_CLAN_ENCOUNTER			= 4 --宗门任务遭遇小战场
g_CLAN_MINE					= 5 --宗门抢矿小战场
g_ACTIVITY					= 6 --日常活动
g_CLAN_BATTLE_WAR			= 7	--宗门战
g_CLAN_BATTLE_HELP			= 8	--宗门支援战
g_TOURNAMENT				= 9 --4v4竞技(会武)
g_TAOIST					= 10 --正邪道场
g_Life 						= 11 --身世副本
g_TOWER						= 12 --爬塔副本
g_FORCE_WAR					= 13 --势力战
g_PLAYER_LEAD               = 14 --新手关引导
g_FACTION_TEAM_DUNGEON      = 15 --帮派团队本
g_WEAPON_NPC                = 16 --神兵绝技天隙副本
g_DEMON_HOLE             	= 17 --伏魔洞
g_RIGHTHEART                = 18 --正义之心
g_ANNUNCIATE                = 19 --江湖告急
g_FIGHT_NPC					= 20 --约战
g_DEFEND_TOWER				= 21 --守护类型，塔防
g_FACTION_WAR               = 22 --帮派战
g_QIECUO					= 23 --切磋
g_FACTION_GARRISON          = 24 --帮派驻地
g_Pet_Waken         		= 25 --宠物觉醒
g_BUDO						= 26 --武道会
g_GLOBAL_PVE				= 27 --跨服pve
g_HOME_LAND					= 28 --家园
g_SPIRIT_BOSS				= 29 --巨灵攻城副本
g_OUT_CAST	 				= 30 --外传副本
g_DEFENCE_WAR 				= 31 --城战副本
g_HOMELAND_HOUSE			= 32 --家园房屋
g_ILLUSORY_DUNGEON			= 33 --幻境副本
g_PET_ACTIVITY_DUNGEON		= 34 --宠物试炼副本
g_DESERT_BATTLE				= 35 --决战荒漠副本
g_AT_ANY_MOMENT_DUNGEON		= 36 --随时随地副本
g_MAZE_BATTLE				= 37 --天魔迷宫副本
g_DOOR_XIULIAN				= 38 --修炼之门副本
g_PRINCESS_MARRY			= 40 --公主出嫁副本
g_MAGIC_MACHINE				= 41 --神机藏海
g_HOMELAND_GUARD			= 42 --家园保卫战
g_FIVE_ELEMENTS				= 43 --五行轮转
g_GOLD_COAST				= 44 --黄金海岸
g_BIOGIAPHY_CAREER			= 45 --外传职业副本
g_LONGEVITY_PAVILION        = 46 --万寿阁
g_CATCH_SPIRIT				= 47 --鬼岛御灵
g_SPY_STORY 				= 48 --密探风云

--地图id
g_SPRING_MAP_ID				= 60012 -- 温泉地图id

-- 野外地图PK类型
g_FIELD_NORMAL				= 1 --普通
g_FIELD_SAFE_AREA			= 2 --安全区
g_FIELD_KILL				= 3 --不计杀戮

--玩家PK模式
g_PeaceMode					= 0--和平
g_FreeMode					= 1--自由
g_GoodAvilMode				= 2--善恶
g_FactionMode				= 3--帮派
g_SeverMode					= 4--服务器

--驭灵碎片交换状态
g_SpiritChange_None 		= 0
g_SpiritChange_Finish		= 1
g_SpiritChange_Fall			= 2
--内甲类型
g_XuanYin					= 1--玄阴
g_LieYang					= 2--烈阳
g_TaiXu						= 3--太虚

--神器深化属性
g_ATK						= 1--攻击
g_DEF						= 2--防御
g_HP						= 3--气血

--易略类型
g_Tian 						= 1 --天
g_Di 						= 2 --地
g_Ren 						= 3 --人
g_Pu 						= 4 --普
--神兵立即变身
promptlySuperMode 			= 1

g_Translucence				= "BBFFFFFF" --刺客半透明

g_OneMap					= 3 --托管范围全地图


-- 竞技场类型
g_Arena_4V4					= 1 --4v4龙虎乱斗
g_Arena_2V2					= 2	--2v2猛龙过江

-------升级类型
eShengbingUpLevel	= 1
eSuiCongUpLevel		= 2
g_ShengbingUpLevel	= 1
g_SuiCongUpLevel	= 2

--角色登录界面形象
eBaseFrom		= 1	--初级形象
eFullFrom		= 2	--正派形象
eFashFrom		= 3	--时装形象
eXieForm		= 4 --邪派形象

-- 属性显示相关
e_ProPShow_Inter		= 0
e_ProPShow_Percent		= 1

-- shortCut type
g_ShortCut_Fuli		= 1 --福利
g_ShortCut_Activity	= 2 --活动
g_ShortCut_RankList	= 3 --排行榜

-- 武魂外显类型
g_MARTIALSOUL_BASE			= 1 --基本
g_MARTIALSOUL_ADD			= 2 --追加

--时装类型
g_FashionType_Weapon	= 1 --武器
g_FashionType_Dress		= 2 --形象

-- 技能效果类型
eSE_Damage		= 1;	-- 伤害
eSE_Buff		= 2;	-- 祝福
eSE_DBuff		= 3;	-- 诅咒
eSE_PASSIVE		= 4;	-- 被动
eSE_AURA		= 5;	-- 光环

-- 内伤类型
eIE_ContinueDamage		= 0	--持续掉血
eIE_TriggerDamage		= 1 --引发内伤伤害
eIE_IgnoreDamage		= 2 --忽视掉血
--经脉潜能两种类型
eMP_AddProertyType		= 1;	-- 属性提升
eMP_AiTriggerType		= 2;	-- 触发技能
--寻路提示信息
g_FindWayTips_State		= 1    --寻路信息提示状态

------------------帮派相关-----------------------

--帮派职位
eFactionOwner			= 1 --帮主
eFactionSencondOwner 	= 2 --副帮主
eFactionElder			= 3 --长老
eFactionElite			= 4 --精英
eFactionPeple			= 5	--成员

--帮派仓库eventID 定义
eFactionWhPeaceAward			= 1 -- 和平区获得奖励 收入
eFactionWhBattleBossAward		= 2 -- 对战区击杀boss获得奖励 收入
eFactionWhBattleSuperBossAward	= 3 -- 对战区击杀超级BOSS获得奖励 收入
eFactionWhAllotAward			= 4 -- 分配奖励 分配
eFactionWhPirceChange			= 5 -- 价格变动记录 分配
eFactionWhFactionDonate			= 6 -- 帮派互助 收入


g_FACTION_GROUP_PHOTO	= "groupPhoto"	-- 帮派合照
--------------好友----------------------
RecommonFriendsNum		= 6 --推荐好友数量
------------------------------------------------
---------------界面图标ID-----------------------
BOUNDARY_ID_ONE           = 1       --商城
BOUNDARY_ID_TWO           = 2       --背包
BOUNDARY_ID_THREE         = 3       --福利
BOUNDARY_ID_FOUR          = 4       --邮件
BOUNDARY_ID_FIVE          = 5       --日程-活动
BOUNDARY_ID_SIX           = 6       --封测
BOUNDARY_ID_SEVEN         = 7       --首冲
BOUNDARY_ID_EIGHT         = 8       --科举
-------------------------------------------------

-------------佣兵出战类型定义
FIELD	 = 1--野外
DUNGEON	= 2--副本
FACTION_DUNGEON = 3--帮派副本
ARENA = 4--竞技场

--随从的星级图
ePet_StarIcon = {405,409,410,411,412,413}
--临时邮件数量上限
TEMP_EMAIL_COUNT = 50

--佣兵觉醒任务类型
g_TaskType	 		= 0 --无任务
g_TaskType1	 		= 1 --任务1
g_TaskType2 	 	= 2 --任务2
g_TaskType3	 		= 3 --任务3

--佣兵觉醒任务状态
g_TaskState	 		= 0 --无
g_TaskState1	 	= 1 --开启
g_TaskState2 	 	= 2 --完成

g_PetFriend_OpenLevel = 39 --宠物喂养开启等级

--------------------------------------------------
---装备部位相关 与配置表中的部位一一对应
eEquipCount			= 14 --装备部位总数
eEquipNumber		= 14 --可强化升星的部位总数
eEquipSharpen		= 8	 --可淬锋锤炼的部位总数
eEquipJumpLvl		= 8  --可以用装备升级卷轴的部位数

eEquipWeapon		= 1 --部位1武器
eEquipHand			= 2 --部位2护腕
eEquipClothes		= 3 --部位3胸甲
eEquipShoes			= 4 --部位4鞋子
eEquipHead			= 5 --部位5头盔
eEquipRing			= 6 --部位6戒指
eEquipSymbol		= 7 --部位7灵符
eEquipArmor			= 8 --部位8灵甲
eEquipFlying		= 9 --部位9飞升武器
eEquipFlyHand 		= 10 --部位10飞升护手
eEquipFlyClothes	= 11 --部位11飞升胸甲
eEquipFlyShoes		= 12 --部位12飞升鞋子
eEquipFlyHead		= 13 --部位13飞升项链
eEquipFlyRing		= 14 --部位14飞升戒指

eEquipNormal		= 1  --普通装备
eEquipFeisheng		= 2  --飞升装备
-----------------------------------------------------
--生产类型

eProductionWeapon	= 1	--生产类型武器
eProductionArmor	= 2 --生产类型防具
eProductionRing		= 3 --生产类型饰品
eProductionShenbing	= 4 --生产类型神兵
eProductionPet		= 5 --生产类型随从
eProductionDrug		= 6 --生产类型药品
eProductionNeiJia	= 7 --生产类型内甲
eProductionOther	= 8 --生产类型杂物


------------------------
--宗门相关

--创建宗门所需转职等级
eCREATEA_CLAN_NEED_TRANSFER_LVL = 2



CLAN_ORE_TYPE_IRON = 1	--铁矿
CLAN_ORE_TYPE_HERB = 2	--药草矿
CLAN_ORE_TYPE_THORPE = 3	--村庄矿

eCLAN_ORE_IRON	= 1149 --玄铁图标
eCLAN_ORE_HERB	= 1150 --药草图标
eCLAN_PRESTIGE = 1340	--宗门声望图标

--宗门战类型
CLAN_ROB_MINE	= 1	--夺矿战
CLAN_TASK_BATTLE = 2 --任务遭遇战
ClAN_ATTACK_BATTLE	= 3	--宗门战
CLAN_SUPPORT_BATTLE = 4	--宗门支援战

--宗门职位
CLAN_JOB_TYPE_OWNER = 1 --宗主
CLAN_JOB_TYPE_ELDER = 2 --客卿
CLAN_JOB_TYPE_MEMBER = 3 -- 成员

--副本扫荡劵
SWEEP_COUPON = 65615

--宗门的四个状态
CLAN_TYPE_GOOD  = 1	--正派
CLAN_TYPE_XIE	= 2 --邪派
CLAN_TYPE_FEMALE = 3 -- 女宗
CLAN_TYPE_PEOTECT = 4 --受保护

--宗门排行1：全服，0：本服
eClanRankMyServer = 1
eClanRankAllServer = 0


--宗门事件
eClanTaskThing = 1	--任务事件
eClanMemberThing = 2 --成员事件

--宗门事件具体类型定义

eClanGetClanTask		= 1		--接取宗门任务
eClanGiveUpTask		  	= 2		--放弃宗门任务
eClanFinishClanTask 	= 3		--完成宗门任务
eClanRefreshTask		= 4		--刷新宗门任务
eClanGetChild			= 5		--增加普通弟子

eClanUserAddClan		= 11	--批准加入宗门
eClanUserRemoveClan		= 12	--踢出宗门
eClanUserAppoinElder	= 13	--任命为元老
eClanUpLevel			= 14	--宗门升级
eClanExitClan			= 15	--退出宗门
eClanCancelElder		= 16	--降为成员

--宗门防守部队还是攻击部队
eClan_AttackTeam = 1
eClan_DefendTeam = 2

--宗门等级正派图片
eClan_LevelIcon = {1490,1491,1492,1493,1494,1495,1496,1497,1498,1499}
--宗门等级邪派图片
eClan_EvilLevelIcon = {1510,1511,1512,1513,1514,1515,1516,1517,1518,1519}

--夺矿界面相关的参数
eMY_MINE_DATA			 = 1	--我的占矿界面
eSEARCH_MINE_DATA 	 = 2	--搜索到的占矿界面
eBATTLE_OVER_DATA		 = 3	--夺矿结束界面
eSTART_SEARCH_DATA	 = 4	--开始夺矿之前的界面显示

--宗门战 战报类型
--(攻击)
eMY_ATTACK_WIN						= 1	--我进攻别人胜利
eMY_ATTACK_FAIL						= 2	--我进攻别人失败
eMY_ATTACK_BY_HELP_FAIL				= 3 --我进攻别人被支援，我败了
eMY_ATTACK_BY_HELP_WIN				= 4 --我进攻别人被支援，我赢了
eMY_ATTACK_TIME_OUT					= 5	--我进攻别人过期
eMY_HELP_WIN						= 6 --我支援别人胜利
eMY_HELP_FAIL						= 7	--我支援别人失败
eMY_HELP_TIME_OUT					= 8	--我支援别人过期

--（防守）
eMY_BY_ATTACK_FAIL					= 9	--我被人进攻失败了
eMY_BY_ATTACK_WIN					= 10 --我被人进攻胜利
eMY_BY_ATTACK_HELP_WIN				= 11 -- 我被人进攻有人支援胜利啦
eMY_BY_ATTACK_HELP_FAIl				= 12 -- 我被人进攻有人支援失败了
eMY_BY_ATTACK_TIME_OUT				= 13 -- 我被人进攻，过期未进攻



------------------------------------------------------
--PreCommand
ePreTypeCommonattack	= 0	--普通攻击
ePreTypeBindSkill1	= 1	--绑定技能1
ePreTypeBindSkill2	= 2	--绑定技能2
ePreTypeBindSkill3	= 3	--绑定技能3
ePreTypeBindSkill4	= 4	--绑定技能4
ePreTypeDodgeSkill	= 5	--轻功
ePreTypeUniqueSkill  = 10--绝技
ePreTypeDIYSkill	= 6	--自定义技能
ePreTypeClickMove	= 7	--点击移动
ePreTypeJoystickMove	= 8	--摇杆移动
ePreTypeResetMove	= 9	--强制复位
ePreTypeItemSkill	= 11 --技能道具
ePreGameTypeInstanceSkill = 12 --副本技能
ePreTypeTournamentSkill	= 13 --神器乱战技能
ePreTypeAnqiSkill	= 14 --暗器技能
ePreTypeSpiritSkill = 15 --精灵技能
------------------------------------------------------

-------------------------------------------------
--taskType

g_TASK_KILL				= 1;--杀怪
g_TASK_COLLECT 			= 2;--采集
g_TASK_USE_ITEM_AT_POINT	= 3;--定点使用道具
g_TASK_TOATL_DAYS			= 4;--累计天数登陆
g_TASK_REACH_LEVEL			= 5;--达到等级
g_TASK_NPC_DIALOGUE		= 6;--NPC对话
g_TASK_USE_ITEM 			= 7;--提交道具
g_TASK_GET_TO_FUBEN		= 8;--通关副本
g_TASK_GET_PET_COUNT		= 9;--拥有佣兵数量
g_TASK_POWER_COUNT			= 10;--战力达到
g_TASK_TRANSFER			= 11;--转职等级
g_TASK_NEW_NPC_DIALOGUE	= 12;--新npc对话
g_TASK_CLEARANCE_ACTIVITYPAD	= 13  --通关活动本
g_TASK_PERSONAL_ARENA  	= 14 --参与个人竞技场
g_TASK_SHAPESHIFTING	= 15;--护送NPC
g_TASK_CONVOY	= 16;--运送物件
g_TASK_ANSWER_PROBLEME	= 18;-- 答题
g_TASK_JOIN_FACTION		= 22 -- 加入帮派
g_TASK_GATE_POINT		= 23 --传送点
g_TASK_ENTER_FUBEN = 24 --进入副本
g_TASK_SUBMIT_ITEM = 25 --提交多项指定物品（消耗道具）
g_TASK_PASS_FUBEN = 26 --通关x副本（任意副本）
g_TASK_TOMORROW = 27 --第二天刷新
g_TASK_FIND_DIFFERENCE = 28 -- 找不同
g_TASK_PUZZLE_PICTURE = 29 -- 拼图
g_TASK_PLAY_SOCIALACT = 30 -- 使用社交动作
g_TASK_SORT_VERSE = 31 -- 拼诗句
g_TASK_LUCKYCHANCE = 32 -- 寻找有缘人
g_TASK_ANY_MOMENT_DUNGEON = 33 -- 通关随时副本
g_TASK_SCENE_MINE = 34 -- 布置场景
g_TASK_NPC_SOCIAL_ACTION = 35 -- 对NPC使用某表情
g_TASK_EXPOSE_LETTER = 36 -- 检视密信
g_TASK_MATCH_TOKEN = 37 -- 重合令牌
g_TASK_FIX_PORTRAYAL = 38 -- 修复画像
g_TASK_ROLE_FLYING = 39 -- 飞升

g_TASK_OWN_WEAPON = 41 -- 拥有神兵
g_TASK_OWN_HORSE = 42 -- 拥有坐骑
g_TASK_OWN_PET = 43 -- 拥有宠物
g_TASK_TEAM_WITH_ISOMERISM = 44 -- 异性组队
g_TASK_CHANGE_ITEM = 45 -- 交换物品
g_TASK_DELIVER_LETTERS = 46 -- npc送信
g_TASK_COLLECT_NPC	= 47 --采矿完成创建npc
----------------------------------------
--任务类型
TASK_CATEGORY_MAIN  = 1;--主线
TASK_CATEGORY_WEAPON = 2;--神兵
TASK_CATEGORY_PET = 3;--随从
TASK_CATEGORY_SECT = 4;--帮派
TASK_CATEGORY_SUBLINE = 5;--支线
TASK_CATEGORY_LIFE	  = 6; --身世
TASK_CATEGORY_SECRETAREA = 7; --秘境
TASK_CATEGORY_ESCORT = 8;	--帮派运镖
TASK_CATEGORY_MRG = 9 --结婚系列任务
TASK_CATEGORY_MRG_LOOP = 10 --结婚随机任务
TASK_CATEGORY_STELA = 11 --太玄碑文任务
TASK_CATEGORY_EPIC = 12 --史诗任务
TASK_CATEGORY_AWAKEN = 13 --宠物觉醒
TASK_CATEGORY_ADVENTURE = 14 --奇遇任务
TASK_CATEGORY_DRAGON_HOLE = 15 --龙穴任务
TASK_CATEGORY_FCBS = 16 --帮派商路任务
TASK_CATEGORY_CHESS = 17 --珍珑棋局任务
TASK_CATEGORY_POWER_REP = 18 -- 势力声望任务
TASK_CATEGORY_OUT_CAST = 19 -- 外传副本任务
TASK_CATEGORY_PETDUNGEON = 20 -- 宠物试炼任务
TASK_CATEGORY_FESTIVAL = 21 -- 节日限时活动
TASK_CATEGORY_JUBILEE = 22 --周年庆活动任务
TASK_CATEGORY_RING	= 23	--飞升环任务
TASK_CATEGORY_DETECTIVE = 24 -- 江湖侠探
TASK_CATEGORY_SWORDSMAN = 25 -- 大侠朋友圈
TASK_CATEGORY_GLOBALWORLD = 26  --赏金任务
TASK_CATEGORY_BIOGRAPHY = 27 -- 外传职业任务
TASK_CATEGORY_SPYSTORY = 28		--密探风云
TASK_CATEGORY_NEW_FESTIVAL = 29		--新节日活动任务


TASK_CATEGORY_LIMIT = 100 --限时任务 -- 后端没有


--TASK_CATEGORY_VERSE = 307 --咏诗任务

--人物功能
TASK_FUNCTION_NONE = 0 --无功能
TASK_FUNCTION_TRANSFER = 1  -- 转职
TASK_FUNCTION_GUTTERMAN = 2 -- 货郎
TASK_FUNCTION_TRANSPORT = 3 -- 运镖
TASK_FUNCTION_MESSAGEBOARD = 4 -- 留言板
TASK_FUNCTION_NPCEXCHANGE   = 10  --npc物品兑换
TASK_FUNCTION_MRG = 11
TASK_FUNCTION_MRG_LOOP = 12
TASK_FUNCTION_HOTEL = 13 -- 江湖客栈
--TASK_FUNCTION_MARTIAL_W = 14 --正武勋商城  赌博商店类型的的商店统一15
TASK_FUNCTION_GAMBLE = 15 --邪武勋商城
TASK_FUNCTION_TRANSFER_PRV = 16 --转职预览
TASK_FUNCTION_WEAPON_NPC = 17 --天隙
TASK_FUNCTION_RIGHTHEART_NPC = 18 --正义之心
TASK_FUNCTION_DEMONHOLE_KEY  = 19 --伏魔洞钥匙npc
TASK_FUNCTION_FIGHT_NPC  = 20 --约战
TASK_FUNCTION_FANXIAN = 21 --充值返现
TASK_FUNCTION_NPCTRANSFER = 22 --npc传送
TASK_FUNCTION_LEGEND = 23 --传世装备
TASK_FUNCTION_DEFEND_ENTER = 24 --守护npc进入
TASK_FUNCTION_DEFEND_RANK  = 25 --守护npc排行榜
TASK_FUNCTION_PRAY = 26  --祈福活动
TASK_FUNCTION_NPC_DUNGEON = 27 --npc副本
TASK_FUNCTION_EXP_TREE_SHAKE = 28 --经验果树摇一摇
TASK_FUNCTION_EXP_TREE_WATER = 29 --经验果树浇水或收获
TASK_FUNCTION_DESTROY_ITEM = 31 --销毁道具
TASK_FUNCTION_Degeneration = 32 --变性
TASK_FUNCTION_EQUIP_SHARPEN = 33 -- 装备淬锋
TASK_FUNCTION_SINGLE_DUNGEON = 34 -- 回归单人本
TASK_FUNCTION_PRAY_WORDS = 35  --对对碰祈福文字
TASK_FUNCTION_EXCHANGE_WORDS = 36  --对对碰兑换文字
TASK_FUNCTION_CHANGE_PRE = 37 --职业转换
TASK_FUNCTION_PET_RACE = 38 -- 宠物赛跑
TASK_FUNCTION_SPRING_HELP     = 40 --温泉帮助
TASK_FUNCTION_WOODENTRIPOD_REFINE  = 41  --神木鼎炼化
TASK_FUNCTION_FIND_MOONCAKE  = 42  --中秋活动找你妹
TASK_FUNCTION_NATIONAL_RAISE_FLAG  = 43  --国庆节加油
TASK_FUNCTION_ENTER_SECT_ZONE       = 44 -- 进入其他驻地
TASK_FUNCTION_LEAVE_MAP_COPY       = 45 -- 离开副本
TASK_FUNCTION_SECT_ZONE_DONATE_RANK = 46 -- 驻地捐献排行
TASK_FUNCTION_SECT_ZONE_ACTIVITY    = 47 -- 驻地活动NPC
TASK_FUNCTION_BID                   = 48 -- 拍卖行
TASK_BREAKSEAL_DONATE               = 49 --封印解除捐献
TASK_FUNCTION_CHRISTAMAS_WISH = 50  --圣诞许愿
TASK_FUNCTION_WISHES_LIST = 51  --圣诞愿望列表
TASK_FUNCTION_EQUIP_TRANS = 52	--装备转化
TASK_FUNCTION_NEWYEAR_RED = 53 --新年红包
TASK_FUNCTION_RIGHTHEART_FASTMATCH = 54 --正义之心快速匹配
TASK_FUNCTION_DEFEND_FASTMATCH = 55 --守护副本快速匹配
TASK_FUNCTION_NPC_FASTMATCH = 56 --NPC副本快速匹配
TASK_FUNCTION_EQUIP_TRANS_FROM_TO = 57 --装备转职业
TASK_FUNCTION_FIVE_TRANS  = 58  -- 五转之路
TASK_FUNCTION_DESTINY_ROLL = 59 -- 天命轮
TASK_FUNCTION_SINGLE_CHALLENGE = 60 -- 单人闯关
TASK_FUNCTION_POWER_REP_TASK	 = 61 -- 势力声望接取任务
TASK_FUNCTION_POWER_REP_COMMIT	 = 62 -- 势力声望提交道具
TASK_FUNCTION_FACTION_ASSIST = 63 -- 帮派助战
TASK_FUNCTION_CREATE_HOMELAND = 64 -- 家园创建
TASK_FUNCTION_CHESS_TASK = 65 -- 珍珑棋局任务接取
TASK_FUNCTION_CHESS_TASK_DESCRIPTION = 66 -- 珍珑棋局说明
TASK_FUNCTION_NPC_DONATE = 67 -- npc捐赠
TASK_FUNCTION_POWER_REP_HUAJIAN  = 68  -- 花间平诉头领标志(特殊，不需要在npc_dialogue中显示按钮)
TASK_FUNCTION_POWER_REP_SONGSHAN = 69  --  松山府头领标志(特殊，不需要在npc_dialogue中显示按钮)
TASK_FUNCTION_POWER_REP_FUBO     = 70  -- 伏波水庄头领标志(特殊，不需要在npc_dialogue中显示按钮)
TASK_FUNCTION_POWER_REP_HUKUO	 = 71  -- 虎阔军头领标志(特殊，不需要在npc_dialogue中显示按钮)
TASK_FUNCTION_POWER_REP_YINGLUAN = 72  -- 影乱山头领标志(特殊，不需要在npc_dialogue中显示按钮)
TASK_FUNCTION_FRAME_SHOP = 73 -- 武林商店NPC
TASK_FUNCTION_FAMILY_DONATE = 74 -- 驻地捐献NPC
TASK_FUNCTION_DEFENCE_WAR_TRANS = 75 -- 城战npc传送服务（打开小地图）
TASK_FUNCTION_DEFENCE_WAR_CAR	= 76 -- 城战工程车变身
TASK_FUNCTION_HOMELAND_PRODUCE = 77 -- 家园生产
TASK_FUNCTION_HOMELAND_RELEASE	= 78 -- 家园放生界面
TASK_FUNCTION_HOMELAND_RELEASE_RANK	= 79 -- 打开家园放生排行榜
TASK_FUNCTION_HOMELAND_ENTERHOUSE = 80 -- 家园房屋进入
TASK_FUNCTION_ENTER_HOMELAND = 81 -- 进入家园
TASK_FUNCTION_DEFENCE_WAR_REPAIR_TOWER	= 82 -- 城战箭塔修复
TASK_FUNCTION_PASS_EXAM_GIFT = 83 --登科有礼
TASK_FUNCTION_PET_DUNGEON = 84 --宠物试炼
TASK_FUNCTION_SWORN_FRIENDS = 85 --结拜
TASK_FUNCTION_REFRESH_RANKS = 86 --重新排辈
TASK_FUNCTION_BREAK_SWORN = 87 --解除结拜
TASK_FUNCTION_KICK_SWORN_FRIENDS = 88 --请离旧人
TASK_FUNCTION_SWORN_RULE = 89 --结拜规则
TASK_FUNCTION_FESTIVAL_LIMIT = 90 --节日限时任务
TASK_FUNCTION_POWER_REP_FURONG = 91 -- 势力声望芙蓉(特殊，不需要在npc_dialogue中显示按钮)
TASK_FUNCTION_LING_QIAN = 92 --灵签祈福
TASK_FUNCTION_SHAKE_TREE = 93 --春节摇钱树
TASK_FUNCTION_MARRY_UP_LVL = 97 --婚礼升级
TASK_FUNCTION_ROLE_FLYING = 98 --飞升
TASK_FUNCTION_GEM_EXCHANGE = 99 --宝石转化
TASK_FUNCTION_CITYWAY_EXP = 100 --城主之光
TASK_FUNCTION_FIVE_ELEMENTS = 101 --五行轮转
TASK_FUNCTION_DETECTIVE = 102 -- 江湖侠探开启
TASK_FUNCTION_SUBLINE_TASK = 103 -- 野外支线任务
TASK_FUNCTION_NEW_CAREER_DESC = 104 -- 外传职业描述
TASK_FUNCTION_NEW_CAREER_TASK = 105 -- 外传职业界面入口
TASK_FUNCTION_CATCH_SPIRIT = 106 -- 鬼岛御灵
TASK_FUNCTION_SPY_STORY = 107 -- 密探风云

TASK_SPRING_ROLL_MAIN = 110 -- 春节灯券主界面
TASK_SPRING_ROLL_BATTLE = 111 -- 春节灯券战斗
TASK_SPRING_ROLL_QUIZ = 112 -- 春节灯券猜谜
TASK_SPRING_ROLL_BUY = 113 -- 春节灯券购买
TASK_FUNCTION_COOK = 114 --烹饪界面
TASK_NEW_FESTIVAL_ACCEPT = 115 -- 新节日任务
TASK_NEW_FESTIVAL_COMMIT = 116 -- 新节日捐赠
--帮派共享任务标志时间
_FACTION_TIME_MARK  = 10*60

--神兵任务每天最多可完成个数
DAY_FINISH_WEAPON_COUNT = 3

--邀请类型
g_INVITE_TYPE_FRIEND = 1 --好友
g_INVITE_TYPE_TEAM = 2 --组队
g_INVITE_TYPE_FACTION = 3 --帮派
g_INVITE_TYPE_SOLO = 4 --切磋
g_INVITE_TYPE_FACTION_HELP = 5 --帮派求援
--邀请设置类型
g_INVITE_SET_FRIEND = 1 --好友
g_INVITE_SET_TEAM = 2 --组队
g_INVITE_SET_SOLO = 3 --切磋
--------------武决潜魂状态
g_WUJUE_SOUL_STATE_UNLOCK = 1
g_WUJUE_SOUL_STATE_UP_STAR = 2
g_WUJUE_SOUL_STATE_UP_RANK = 3
g_WUJUE_SOUL_STATE_MAX = 4
--------------------------------------------
--品级常量值
g_RANK_VALUE_UNKNOWN 	= 0
g_RANK_VALUE_WHITE 		= 1
g_RANK_VALUE_GREEN 		= 2
g_RANK_VALUE_BLUE 		= 3
g_RANK_VALUE_PURPLE 	= 4
g_RANK_VALUE_ORANGE 	= 5
g_RANK_VALUE_MAX 		= 10 --最大max品质框目前用于坐骑洗练红色文本显示

--装备底框常量
g_Equip_Shading_One = 1
g_Equip_Shading_Two = 2
g_Equip_Shading_Three = 3
g_Equip_Shading_Four = 4
g_Equip_Shading_Five = 5
g_Equip_Shading_Six = 6
g_Equip_Shading_Seven = 7
g_Equip_Shading_Eight = 8


--DIY技能ID
SKILL_DIY = 9999999
--------------------------------------------

eFashion_Face	=  0;
eFashion_Hair	=  5;
eFashion_Body	=  3;
eFashion_Weapon	=  1;
eFashion_FlyWeapon = 9
eFashion_FlyBody = 11

eFashionType_Weapon	= 1;
eFashionType_Dress	= 2;
eFashionType_Max	= 2;

-- 特权卡
MONTH_CARD 			= 1  -- 月卡
WEEK_CARD 			= 2  -- 周卡
SUPER_MONTH_CARD 	= 3  -- 逍遥卡（98月卡）

SPECIAL_CARD_NOT_NEED = 0   -- 无特权卡需求
SPECIAL_CARD_WEEK     = 1   -- 需要周卡
SPECIAL_CARD_MONTH    = 2   -- 需要月卡
SPECIAL_CARD_EIGHTER  = 3   -- 两者任意有一个即可
SPECIAL_CARD_BOTH     = 4   -- 两者都要有

g_Pay_Rank      = 1  --充值排行
g_Consume_Rank  = 2  --消费排行

--道具物品类型
UseItemDiamond			= 1		--元宝包
UseItemCoin				= 2		--铜钱包
UseItemExp				= 3		--经验丹
UseItemGift				= 4		--礼包
UseItemHp				= 6		--生命药水
UseItemVipHp			= 8		--VIP药品
UseItemChest			= 9		--抽奖宝箱
UseItemEquipEnergy		= 13	--装备能量丹
UseItemGemEnergy		= 14	--宝石能量丹
UseItemBookSpiration	= 15	--心法悟性丹
UseItemVit				= 16	--体力包
UseItemFashion    		= 17  --激活时装
UseItemLibrary			= 20    --藏书
UseItemEmpowerment		= 19	--历练
UseItemCard				= 21    --月卡体验
UseItemVipCard			= 22    --vip卡体验
UseItemFeats           	= 24    --增加武勋道具
UseItemSkill            = 25    --
UseItemMail				= 26	--信件道具
UseItemChip				= 27	--碎片（用来合成）
UseItemRune				= 29	--符文
UseItemEvil				= 30	--扣除善恶值
UseItemFirework         = 31    -- 烟花
UseItemRefine			= 32 	--精炼道具
UseItemOneTimes			= 33 	--限制使用
UseItemSpirit			= 34 	--修炼点数
UseItemResetTitleTime	= 35	--重置称号剩余时间
UseItemUniqueSkill		= 36	--激活绝技道具
UseItemVipExp           = 38    --vip经验道具
UseItemProduceSplitSp   = 39    --生产能量道具
UseItemBuffDrug         = 40    --buff药
UseItemGetEmoji			= 41	--表情包
UseItemWeaponSoul		= 42	--武运
UseItemGetChatBox		= 43	--聊天框
UseItemHeadPreview		= 44	--商城头像预览（只客户端使用，用于区分是否是头像道具）
UseItemHorseBook        = 45    --骑术书
UseItemPetBook          = 46    --宠物武学
UseItemEscortCar		= 47	--镖车皮肤
UseItemShowLove			= 48    -- 示爱道具类型
UseItemBaguaStone		= 51    -- 八卦原石道具类型
UseItemBaguaSacrifice	= 52    -- 八卦祭品道具类型
UseItemGodEquip			= 53	-- 神装礼包
UseItemDiaryDecorate	= 55	-- 激活心情日记装饰道具
UseItemPowerRep			= 56 	-- 势力声望
UseItemHomeLandEquip	= 57 	-- 家园装备道具
UseItemHorse			= 58 	-- 坐骑类型道具（只客户端使用）
UseItemPet				= 59	-- 宠物类型道具（只客户端使用）
UseItemSpiritBoss		= 61	-- 正义徽章道具
UseItemRelease			= 62 	-- 家园放生道具
UseItemFurniture		= 63	-- 家具道具
UseItemRegular          = 64    --定期活动道具
UseItemHouseSkin		= 65	-- 房屋皮肤解锁道具
UseItemSwornValue		= 66	-- 增加结拜金兰值道具
UseItemMetamorphosis	= 67	-- 幻形道具
UseItemWuJueExp			= 68    -- 武决经验道具
UseItemSteedEquipSpirit	= 69	-- 使用获得熔炼精华道具
UseItemCardPacket		= 70 -- 图鉴解锁道具类型
UseItemPetGuard 		= 74 	-- 守护灵兽经验道具
--UseItemPrayExp			= 76	-- 祈言经验道具
UseItemArrayStone		= 77	-- 阵法石能量道具
UseItemWarZoneCard		= 78	-- 战区卡片道具
useItemUpEquipLevel		= 79	--装备升级卷轴
UseItemNewPower			= 80	--新增势力声望道具
UseItemAddActivityTimes = 81	--添加试炼次数道具
--道具寻路类型
g_GO_NPC     = 1   --寻到NPC
g_GO_MONSTER = 2   --寻到怪物
--传送符ID
ConveyID = 65756

--文本配置表ID
g_UseItem_Need_Level	= 188
g_SaleBat_Equip_Desc	= 237
g_SaleBat_Gem_Desc		= 239
g_SaleBat_Book_Desc		= 238
g_SaleBat_Other_Desc	= 240

-------其他套装属性加成参数
g_AddArgs = 0.2


--心法类型
g_ZHIYE_XINFA		= 1
g_JIANGHU_XINFA		= 2
g_PEIBIE_XINFA		= 3
--心法效果类型
g_XINFA_COMBATTYPE 	= 11
g_XINFA_BEIDONG 	= 12

--技能升级图片Icon
g_UpSkill_NextEffect = 858
g_UpState_NextEffect = 859
g_UpState_NowEffect = 860
g_UpSkill_NowEffect = 861

----------------------------------------------
-- 客户端从1开始，服务器从0开始
g_NOTICE_TYPE_CAN_RECEIVE_NEW_MAIL		= 1
g_NOTICE_TYPE_CAN_REWARD_DAILY_TASK		= 2
G_NOTICE_TYPE_CAN_REWARD_CHALLENGE_TASK	= 3
g_NOTICE_TEST_BENEFIT = 4
--g_NOTICE_TYPE_CAN_REWARD_SING_IN = 4
--g_NOTICE_TYPE_CAN_REWARD_Dynamic_Activity = 4
g_NOTICE_TYPE_CAN_REWARD_ARENA			= 5
g_NOTICE_TYPE_CAN_REWARD_FIRST_PAYGIFT = 6
g_NOTICE_TYPE_CAN_REWARD_LUCKY_WHEEL		= 7
g_NOTICE_TYPE_CAN_FAME = 8
g_NOTICE_TYPE_CAN_PAY = 9
g_NOTICE_TYPE_CAN_GROUPBUY = 10
g_NOTICE_TYPE_CAN_GROUPBUY_RED = 11
g_NOTICE_TYPE_CAN_FALSHSALE = 12
g_NOTICE_TYPE_CAN_FALSHSALE_RED = 13
g_NOTICE_TYPE_CAN_FIGHT_NPC = 14 -- 约战NPC
g_NOTICE_TYPE_CAN_LUCK = 15  -- 服务器暂时无意义
g_NOTICE_TYPE_CAN_PAY_ACTIVITY = 16 -- 充值相关红点（服务器同步的动态配置活动，客户端的还需要自己算一下）
g_NOTICE_TYPE_MASTER = 17 -- 师徒
g_NOTICE_TYPE_FIVE_END_ACT = 18 --五绝秘藏
g_NOTICE_TYPE_GOLDEN_EGG = 19 --砸金蛋
g_NOTICE_TYPE_CAN_REWARD_WEEK_TASK = 21 --周常任务
g_NOTICE_TYPE_CAN_REWARD_WIZARD_GIFT = 22 --送财童子红点
--g_NOTICE_TYPE_CAN_Divination = 23 --挂签红点 --入口移植到活动
g_NOTICE_TYPE_CAN_WORLD_CUP = 24  --世界杯
g_NOTICE_TYPE_CAN_PARTNER_HUOBAN = 25	--伙伴
g_NOTICE_TYPE_CAN_PAY_DISCOUNT_GIFT = 26  	--折扣礼包购买
g_NOTICE_TYPE_MARRY_ACHIEVEMENT = 27 --姻缘成就
g_NOTICE_TYPE_SWORN = 28	-- 江湖回归
g_NOTICE_TYPE_LOTTERY = 29 -- 转盘 新 充值抽奖
g_NOTICE_TYPE_Gam	 = 29	--社交
g_NOTICE_TYPE_SWORN_ACHIEVEMENT = 30--金兰任务
g_NOTICE_TYPE_CROSS_FRIEND = 20000000 --跨服好友
g_NOTICE_TYPE_CAN_REWARD_TEST = 20170111

--------------------------------------------
--传送点功能
g_TRANSFERPOINT_NORMAL = 0
g_TRANSFERPOINT_ANNUNCIATE = 1 --江湖告急

--藏宝图情报点类型
g_KILL_MONSTER	= 1
g_DIALOGUE		= 2
g_DIG			= 3
g_SCRECT_BOX	= 4

--公告页面页签类型
g_Game_Notice	= 1 --公告
g_Game_Activity	= 2 --活动
g_Game_Update	= 3 --更新

-- 宠物赛跑 赛道类型
PET_RACE_ROAD_TYPE = 4
DANCE_NPC_TYPE = 5 -- 周年舞会npc类型

-- only valid in dev mode
eLoadAllNode		= tonumber("0x00000000", 16);
eDisLoadStaticNode	= tonumber("0x00000001", 16);
eDisLoadDynamicNode	= tonumber("0x00000002", 16);
eDisLoadSprNode		= tonumber("0x00000004", 16);
eDisLoadEffectNode	= tonumber("0x00000008", 16);
eDisLoadGroupNode	= tonumber("0x00000010", 16);
eDisLoadTerrain		= tonumber("0x00000020", 16);
eDisLoadTexture		= tonumber("0x00000040", 16);


-- scene load proirity
eLoadPriority_Zero	=  0;	-- 没有偏移，默认值
eLoadPriority_Neg1	= -1;	-- 加载距离减少一个加载块，3,2,1,0...
eLoadPriority_Neg2	= -2;	-- 加载距离减少两个加载块, 2,1,0,0
eLoadPriority_Neg3	= -3;	-- 加载距离减少两个加载块, 1,0,0,0

-- audio type
gAudioType_Action	= 1;
gAudioType_Effect	= 2;
gAudioType_Scene	= 3;
gAudioType_BGM		= 4;
gAudioType_UI		= 5;

gAudio_SceneFalloff		= 1.0;
gAudio_ActionFalloff	= 1.0;
gAudio_EffectFalloff	= 1.0;
gAudio_BGMFalloff		= 1.3;
gAudio_UIFalloff		= 1.0;


GAME_PLAT_IOS_IDENTIFIER = "i"
GAME_PLAT_ANDROID_IDENTIFIER = "a"

--房间的几种种类型
gRoom_Dungeon			= 1		-- 副本组队房间
gRoom_Tournament		= 2		-- 会武房间
gRoom_Force_War			= 3		-- 势力战房间
gRoom_NPC_MAP			= 4		-- NPC副本
gRoom_TOWER_DEFENCE		= 5		-- 守护副本类型

-- 副本类型（副本配置表-副本地图-难度类型）
DUNGEON_DIFF_NORMAL = 2  -- 普通难度
DUNGEON_DIFF_HARD   = 3  -- 困难
DUNGEON_DIFF_TEAM   = -1 -- 组队本
DUNGEON_DIFF_GOLD   = -2 -- 黄金副本
DUNGEON_DIFF_MASTER = -3 -- 师徒组队本

DAY_FIRST_LOGIN_FIRST_PAY = 1 -- 每天首次登陆 首冲
DAY_FIRST_LOGIN_PURCHASE = 2 -- 直购礼包

--角色信息变化sendtype三种状态
gRoelChangeInfo = 0
gRoleLogin = 1
gCreateRole = 2

--每日刷新时间点
gDay_Refresh_Time = 5;

--道具提示使用的类型编号(参考文档：道具提示使用.doc)
gShowTipItems = {
    [UseItemDiamond]        = true,
    [UseItemCoin]           = true,
    [UseItemExp]            = true,
    [UseItemGift]           = true,
    [UseItemVipHp]          = true,
    [UseItemChest]          = true,
    [UseItemEquipEnergy]    = true,
    [UseItemGemEnergy]      = true,
    [UseItemBookSpiration]  = true,
    [UseItemVit]            = true,
    [UseItemFashion]        = true,
    [UseItemCard]           = true,
    [UseItemVipCard]        = true,
    [UseItemFeats]          = true,
    [UseItemMail]           = true,
    [UseItemOneTimes]       = true,
    [UseItemUniqueSkill]    = true,
    [UseItemGetEmoji]       = true,
    [UseItemWeaponSoul]     = true,
    [UseItemGetChatBox]		= true,
	[UseItemEscortCar]		= true,
	[UseItemSpiritBoss]		= true,
	[UseItemRegular]		= true,
	[UseItemMetamorphosis]	= true,
	--后来加的需要提示的道具
	[UseItemEvil]			= true,
	[UseItemHeadPreview]	= true,
	[UseItemDiaryDecorate]	= true,
	[UseItemFurniture]		= true,
	[UseItemHouseSkin]		= true,
	[UseItemSteedEquipSpirit] = true,
	[UseItemArrayStone]		= true,
	[UseItemNewPower]		= true,
}

-- 单人副本类型
SINGLE_MAPCOPY_TASK   = 1 -- 剧情单人副本
SINGLE_MAPCOPY_NORMAL = 2 -- 普通难度单人副本
SINGLE_MAPCOPY_HARD   = 3 -- 困难单人副本

-- 战斗内甲冒字类型
NEIJIA_SUNHUI = 1 -- 内甲损毁
NEIJIA_XISHOU = 2 -- 内甲吸收
NEIJIA_XURUO  = 3 -- 内甲虚弱
NEIJIA_MAOZI_IMG =
{
    [NEIJIA_SUNHUI] = 3066,
    [NEIJIA_XISHOU] = 3077,
    [NEIJIA_XURUO ] = 3088
}

-- 三种类型的按钮对应的3张图片ID
SINGLE_MAPCOPY_BUTTON =
{
    [SINGLE_MAPCOPY_TASK]   = { unlocked = 2937, normal = 2938, selected = 2939},
    [SINGLE_MAPCOPY_NORMAL] = { unlocked = 2940, normal = 2941, selected = 2942},
    [SINGLE_MAPCOPY_HARD]   = { unlocked = 2943, normal = 2944, selected = 2945},
}

-- 定义玩家的师徒状态
e_State_Master_Unknown   = 0  --未知，数据不全
e_State_BeMaster_NoApptc = 1  --可以当师傅，没徒弟
e_State_BeApptc_NoMaster = 2  --可以当徒弟，没师傅
e_State_Master           = 3  --已经是师傅
e_State_Apprtc           = 4  --已经是徒弟

g_week_days =
{
    [1] = "周一",
    [2] = "周二",
    [3] = "周三",
    [4] = "周四",
    [5] = "周五",
    [6] = "周六",
    [0] = "周日",
}

g_weekTable = {
	[0] = "日",
	[1] = "一",
	[2] = "二",
	[3] = "三",
	[4] = "四",
	[5] = "五",
	[6] = "六",
}

g_auction_search =
{
    ["equip"] = {1,2,3,4,5,6,8},
    -- ["gen"] =   {11}, -- 暂时宝石都不可售卖，所以这个表中没有内容
    ["item"] =  {11,12,13,14,16,17,100},
    ["xinfa"] = {18}, -- 心法书表12改为18
}

-- 寄售行中分类中，区分职业的类型
g_auction_classType =
{
    [1] = true;
    [2] = true;
    [3] = true;
    [4] = true;
    [5] = true;
    [6] = true;
    [18] = true;
}

-- 寻宝大富翁事件类型
DICE_EVENT_NIL      = 0 -- 空事件
DICE_EVENT_EXP      = 1 -- 直接获取经验
DICE_EVENT_ITEM     = 2 -- 直接获得物品
DICE_EVENT_TRADE    = 3 -- 物物兑换支持元宝购买
DICE_EVENT_MONSTER  = 4 -- 击杀怪物得奖励
DICE_EVENT_FLOWER   = 5 -- 赠送玫瑰花
DICE_EVENT_THROW    = 6 -- 获得额外投掷次数
DICE_EVENT_SLOW     = 7 -- debuff行走变为1点
DICE_EVENT_THREE    = 8 -- debuff投掷骰子为3个，3-18点
DICE_EVENT_DEDUCT   = 9 -- 扣除一次投掷次数
DICE_EVENT_MONEY    = 10 -- 直接获得铜钱
DICE_EVENT_VIT      = 11 -- 直接获得体力


DICE_STATUS_DOING  = 0 -- 进行中
DICE_STATUS_FINISH = 1 -- 结束即领完奖
DICE_STATUS_REWARD = 2 -- 可以领奖
DICE_STATUS_GIVEUP = 3 -- 放弃

-- 获取分包状态错误码
EXT_PACK_STATE_NOT_EXIST   = 0
EXT_PACK_STATE_DOWNLOADING = 1
EXT_PACK_STATE_DONE        = 2
EXT_PACK_STATE_ERROR       = 3  -- 通知UI下载失败了
EXT_PACK_STATE_PAUSE       = 4 -- 暂停下载
-- 开始下载的回调错误码
EXT_PACK_DOWNLOAD_NOT_ENOUGH_MEM     = -4 -- 内存不足
EXT_PACK_DOWNLOAD_NOT_ENOUGH_SPACE   = -3 -- 空间不足
EXT_PACK_DOWNLOAD_NOT_WIFI           = -2 -- 非wifi环境
EXT_PACK_DOWNLOAD_FAILED             = -1 -- 下载失败
EXT_PACK_DOWNLOAD_NO_TASKS           = 0  -- 当前没有在下载
EXT_PACK_DOWNLOAD_DOWNLOADING        = 1  -- 正在下载整包
EXT_PACK_DOWNLOAD_UPDATING           = 2  -- 正在更新
EXT_PACK_DOWNLOAD_DONE               = 3  -- 下载更新全部完成

-- 帧率
FPS_LIMIT =
{
	30, 45, 60
}

-- 分堂推送相关类型
g_FACTION_FIGHT_PUSH_MATCHING = 0 -- 匹配中
g_FACTION_FIGHT_PUSH_WAITING = 1 -- 报名-对战的帮派
g_FACTION_FIGHT_PUSH_FIGHTING = 2 -- 进行中
g_FACTION_FIGHT_PUSH_DRAW = 3 -- 结束-平局
g_FACTION_FIGHT_PUSH_WIN = 4 -- 结束- 获胜
g_FACTION_FIGHT_PUSH_FAILED = 5 -- 结束- 失败
g_FACTION_FIGHT_PUSH_BYE = 6 -- 轮空
g_FACTION_FIGHT_PUSH_END = 7 -- 结束
g_FACTION_FIGHT_PUSH_GET_READY = 8 -- 做好准备
g_FACTION_FIGHT_PUSH_NO_FENTANG = 9 --  没加入分堂
g_FACTION_FIGHT_PUSH_NO_MATCH = 10 -- 分堂未报名

--聊天频道
global_system 	= 0 --系统频道
global_world 	= 1	--世界(综合)频道
global_sect 	= 2	--帮派频道
global_team		= 3	--队伍频道
global_recent 	= 4	--私聊
global_battle 	= 5	--战场
global_span     = 6 --跨服
global_invite   = 7 --江湖告急邀请
global_cross	= 8 --跨服好友私聊

-- 类型
g_HORSE_ROLE_TYPE 	= 1 --骑乘
g_HUG_ROLE_TYPE 	= 2 --相依相依相偎
g_SPRING_WATER_TYPE = 3 --鸭子（水上互动）
g_SPRING_LAND_TYPE 	= 4 --椅子（陆地互动）

--多人坐骑位置
g_HS_First			= 1--司机
g_HS_Second			= 2--乘客1
g_HS_Third			= 3--乘客2
g_HS_Fourth			= 4--乘客3

-- 坐骑皮肤,原版/追加皮肤
g_HS_TRADITIONAL	= 0 	-- 原版
g_HS_ADDITIONAL		= 1 	-- 追加

-- 坐骑皮肤类型
g_HS_SKIN_NORMAL	= 0		--普通
g_HS_SKIN_FIGHT		= 1		--骑战
g_HS_SKIN_MUL		= 2		--多人

--坐骑骑术
g_HS_SKILL_BORN  	= 1  	--先天骑术 
g_HS_SKILL_CAN_ACT  = 2   	--可激活 	
g_HS_SKILL_IN_USE   = 3 	--装备中 
g_HS_SKILL_CAN_USE  = 4 	--可装备
g_HS_SKILL_NOT_ACT  = 5 	--未激活
g_HS_SKILL_OPEN_STAR = 2    --骑术开启所需星级
--坐骑类型
g_SINGLE_STEED = 1 		 --单人坐骑
g_MORE_STEED = 2 		 --多人坐骑
g_STEED_STAR_VALUE_NUM = 9 --坐骑升星属性总条目数

-- 泡温泉水域类型
SPRING_TYPE_OTHER = 0
SPRING_TYPE_WATER = 1
SPRING_TYPE_LAND = 2

--多人骑乘
g_MULHORSE_ERROR		= 0   --错误
g_MULHORSE_OFFLINE		= -1  --对方已下线
g_MULHORSE_INVALID		= -2  --无效
g_MULHORSE_SELF_FULL	= -3  --自己坐骑已满
g_MULHORSE_OTHER_FULL	= -4  --对方坐骑已满
g_MULHORSE_SELF_RIDE	= -5  --自己已在坐骑上
g_MULHORSE_OTHER_RIDE	= -6  --对方已在坐骑上
g_MULHORSE_SELF_UNRIDE	= -7  --自己没在骑乘状态
g_MULHORSE_OTHER_UNRIDE = -8  --对方没在骑乘状态
g_MULHORSE_TIME_OUT		= -9  --超时
g_MULHORSE_TOO_FAR		= -20 --离得太远
g_MULHORSE_IN_FIGHT		= -21 --战斗状态
g_MULHORSE_LEAD			= -30 --指引状态
g_MULHORSE_BUSY			= -31 --正忙
g_MULHORSE_METAMORPHOSIS = -32 --幻形中
g_MULHORSE_WAS_BANED	= -33 --被拉黑且禁止互动
-- 相依相偎
g_HUG_ERROR			= 0   --错误
g_HUG_OFFLINE		= -1  --对方已下线
g_HUG_INVALID		= -2  --无效
g_HUG_SELF_STATE	= -3  --自己已在相依相偎状态
g_HUG_OTHER_STATE	= -4  --对方已在相依相偎状态
g_HUG_SELF_RIDE		= -5  --自己在骑乘状态
g_HUG_OTHER_RIDE 	= -6  --对方在骑乘状态
g_HUG_TIME_OUT		= -7  --超时
g_HUG_NOT_STAYWITH	= -8  --不在双人互动状态
g_HUG_NOT_FRIEND	= -9  --不是好友
g_HUG_MEMEDA		= -10 --在memeda状态
g_HUG_REFUSE		= -11 --对方拒绝15分钟邀请
g_HUG_Dead			= -12 --对方已经死亡
g_HUG_MULROLE_TEAM	= -13 --多人活动中，组队中
g_HUG_LEVEL			= -14 --等级不足
g_HUG_FISH			= -15 --对方正在钓鱼
g_HUG_TOO_FAR		= -20 --对方离得太远
g_HUG_IN_FIGHT		= -21 --对方正处于战斗状态
g_HUG_LEAD			= -30 --对方正处于指引状态
g_HUG_BUSY			= -31 --正忙
g_HUG_METAMORPHOSIS = -32 --幻形中

--成功动画类型 eUIID_WuJueDH
g_BREAK_SUCCESS_ANIMATION = 1
g_UPLEVEL_SUCCESS_ANIMATION = 2
g_ACTIVE_SUCCESS_ANIMATION = 3

STEED_MASTER_STATE = 1 --马术精通
STEED_SPIRIT_STATE = 2 --良驹之灵
STEED_EQUIP_STATE = 3 --骑战装备
--副本技能详情状态
g_FUBEN_SKILL_NORMAL	= 1 --原有兽穴
g_FUBEN_SKILL_HOMELAND	= 2 --家园保卫战

-- 武道会战队
g_FIGHT_TEAM_ALREADY_JOIN					= -1   --已有队伍
g_FIGHT_TEAM_CREATE_NAME_INVALID			= -2   --名字非法
g_FIGHT_TEAM_CREATE_NAME_DUPLICATE			= -3   --名字重复
g_FIGHT_TEAM_NO_IN							= -4   --已经不在队伍中
g_FIGHT_TEAM_OFFLINE						= -5   --不在线
g_FIGHT_TEAM_ALREADY_IN_TEAM				= -6   --已经在战队中
g_FIGHT_TEAM_CLASSTYPE_LIMIT				= -7   --同一职业玩家超过上限
g_FIGHT_TEAM_NOT_EXSIT						= -8   --战队已解散
g_FIGHT_TEAM_INVITE_INVALID					= -9   --邀请失败
g_FIGHT_TEAM_TEAN_FULL						= -10  --战队已满
g_FIGHT_TEAM_NOT_LEADER						= -11  --不是队长
g_FIGHT_TEAM_NOT_FIGHT_TIME					= -12  --不在报名时间段内
g_FIGHT_TEAM_ALREADY_INJOIN_STATE			= -13  --已经在报名状态
g_FIGHT_TEAM_ONLINE_MEMBER_LACK				= -14  --战队在线人数不足
g_FIGHT_TEAM_NOT_JOIN						= -15  --没有报名
g_FIGHT_TEAM_KICK_CD						= -16  --踢人cd中
g_FIGHT_TEAM_QUALIFYING_TIMES_LIMIT			= -17  --参加次数不足
g_FIGHT_TEAM_REFUSE							= -18  --cd拒绝了邀请
g_FIGHT_TEAM_FIGHTEND						= -19  --战斗结束
g_FIGHT_TEAM_MAXGUARD_COUNT					= -20  --观展人数超过上限
g_FIGHT_TEAM_NO_FIGHT 						= -21  --海选观战没有队伍
g_FIGHT_TEAM_OTHER_WAIT_MATCH				= -22  --队员有等待其他活动无法参加海选
g_FIGHT_TEAM_JOIN_TIMES_LIMIT				= -23  --对方加入战队次数不足
g_FIGHT_TEAM_MEMBER_HUG						= -24  --有队员中有人正在多人坐骑或相依相偎中

-- 武道会事件
g_FIGHT_TEAM_EVENTID	= 100 -- 进入64强事件

-- 日程表
g_SCHEDULE_COMMON_MAPID = 0
g_SCHEDULE_TYPE_ACT = 1				-- 活动本
g_SCHEDULE_TYPE_GROUP = 2			-- 组队本
g_SCHEDULE_TYPE_COMMON = 3			-- 普通本
g_SCHEDULE_TYPE_HARD = 4			-- 困难本
g_SCHEDULE_TYPE_TREASURE = 5		-- 宝藏图
g_SCHEDULE_TYPE_TOWER = 6			-- 五绝试炼
g_SCHEDULE_TYPE_KONGFU = 7			-- 自创武功
g_SCHEDULE_TYPE_SECTDUNG = 8		-- 帮派副本
g_SCHEDULE_TYPE_SECTDART = 9		-- 帮派运镖
g_SCHEDULE_TYPE_SECTTASK = 10		-- 帮派任务
g_SCHEDULE_TYPE_AREA = 11			-- 普通竞技
g_SCHEDULE_TYPE_TAOIST = 12			-- 正邪道场
g_SCHEDULE_TYPE_TOURNAMENT = 13		-- 会武
g_SCHEDULE_TYPE_FORCE_WAR = 14		-- 势力战
g_SCHEDULE_TYPE_PRODUCT = 15		-- 生产物品
g_SCHEDULE_TYPE_RESOLVE = 16		-- 分解装备
g_SCHEDULE_TYPE_WORldBOSS = 17		-- 击杀魔王
g_SCHEDULE_TYPE_NPC = 18			-- 物物交换
g_SCHEDULE_TYPE_MAR = 19			-- 姻缘任务
g_SCHEDULE_TYPE_ANSWER_QUE = 20 	-- 科举
g_SCHEDULE_TYPE_ZHENGYIZHIXIN = 21	-- 正义之心
g_SCHEDULE_TYPE_STELE = 22			-- 太玄碑文
g_SCHEDULE_TYPE_ANNUNCIATE = 23		-- 江湖告急
g_SCHEDULE_TYPE_SECT_GRAB = 24		-- 帮派夺旗战
g_SCHEDULE_TYPE_TOWER_DEFENCE = 25	-- 塔防
g_SCHEDULE_TYPE_ZHENGYIZHIXIN_2 = 26 --正义之心2
g_SCHEDULE_TYPE_Pray            = 27 --祈福活动
g_SCHEDULE_TYPE_DEMONHOLE       = 28 --伏魔洞
g_SCHEDULE_TYPE_EXPTREE       = 29   --经验果树
g_SCHEDULE_TYPE_SECTFIGHT      = 30  --帮派战
g_SCHEDULE_TYPE_HAPPY_MATCH    = 31  --开心对对碰
g_SCHEDULE_TYPE_DRIFT_BOTTLE = 32	 -- 漂流瓶
g_SCHEDULE_TYPE_PET_RACE     = 33    -- 宠物赛跑
g_SCHEDULE_TYPE_SPRING		 = 34    -- 温泉
g_SCHEDULE_TYPE_FACTION_ZONE = 35    -- 帮派驻地
g_SCHEDULE_TYPE_ROBBER_MONSTER = 36  -- 江洋大盗
g_SCHEDULE_TYPE_BREAK_SEAL     = 37  -- 服务器等级封印开启
g_SCHEDULE_TYPE_NEW_YEAR_RED     = 38  -- 新年红包
g_SCHEDULE_TYPE_GLOBAL_PVE    = 39  -- 跨服pve
g_SCHEDULE_TYPE_SINGLE_CHALLENGE    = 40  -- 单人闯关
g_SCHEDULE_TYPE_CHESS_TASK = 41		--珍珑棋局
g_SCHEDULE_TYPE_SPIRIT_BOSS	= 42 	--巨灵攻城
g_SCHEDULE_TYPE_PASS_EXAM_GIGT = 43 --登科有礼
g_SCHEDULE_TYPE_FACTION_FAIRY  = 44 --驻地精灵
g_SCHEDULE_TYPE_PET_DUNGEON  = 45 --宠物试炼
g_SCHEDULE_TYPE_DESERT		= 46 --决战荒漠
g_SCHEDULE_TYPE_MZAE_BATTLE = 47 --天魔迷宫
g_SCHEDULE_TYPE_LING_QIAN = 48 --灵签祈福
g_SCHEDULE_TYPE_SHAKE_TREE = 49 --摇钱树
g_SCHEDULE_TYPE_DIVINATION = 50 --挂签占卜
g_SCHEDULE_TYPE_PRINCESSMARRY = 51 --公主出嫁
g_SCHEDULE_TYPE_MAGIC_MACHINE = 52 --神机藏海
g_SCHEDULE_TYPE_FIVE_ELEMENTS = 53 --五行轮转
g_SCHEDULE_TYPE_DETECTIVE = 54 --江湖侠探
g_SCHEDULE_TYPE_SWORDSMAN = 55 --大侠朋友圈
g_SCHEDULE_TYPE_LONGEVITY_PAVILION  = 56 --万寿阁
g_SCHEDULE_TYPE_SPY_STORY = 57 --密探风云
g_SCHEDULE_TYPE_NEW_FESTIVAL = 58 --新节日活动
g_SCHEDULE_TYPE_SPRING_ROLL = 59 -- 春节灯券
g_SCHEDULE_TYPE_WEEK_DUNGEON = 60 --周本
g_SCHEDULE_TYPE_LINKAGE_ACTIVITY = 61 --美食节
--技能预设
g_PRESETTYPE_SKILL = 1  --常规
g_PRESETTYPE_UNIQUE = 2  --绝技
g_PRESETTYPE_DIY = 3  -- 自创武功
g_PRESETTYPE_ATTACK = 4  --普通
g_PRESETTYPE_ANQI = 5  --暗器

g_SKILLPRE_DIY_FRESHTYPE_PRE = 1
g_SKILLPRE_DIY_FRESHTYPE_CHANGE = 2
g_SKILLPRE_DIY_FRESHTYPE_SET = 3
g_SKILLPRE_DIY_FRESHTYPE_FORGET = 4

g_DIY_TYPE_SELF = 1
g_DIY_TYPE_BORROW = 2

g_PRE_NAME_SKILL = 1
g_PRE_NAME_SPIRITS = 2
--八卦易略技能加成效果类型
g_Yilue_SKILL_TYPE_1 = 1
g_Yilue_SKILL_TYPE_2 = 2
g_Yilue_SKILL_TYPE_3 = 3

g_CHANGE_SKILL = 1
g_CHANGE_PRESKILL = 2
g_CHANGE_PRESPIRITS = 3

g_CHANGE_SKILL_FAST = 1
g_CHANGE_SKILL_PASSIVE = 2

--有偿刷新最大次数
g_MAX_REFRESH_TIMES = 20;

g_DEVICE_BATTERY = 100 -- 电池电量
g_PLAYER_LEAD_MAP_ID = 100 -- 新手关引导

--房间附近的人
g_NEARBY_CROOM = 1
g_NEARBY_IFRIENDS = 2

--帮派助战类型
g_FACTION_ASSIST = 1
g_CROOM_ASSIST = 2

--会武类型
g_TOURNAMENT_4V4	= 1
g_TOURNAMENT_2V2	= 2
g_TOURNAMENT_WEAPON = 3 -- 神器乱战
g_TOURNAMENT_CHUHAN = 4 --楚汉之争


--势力战类型
g_FORCEWAR_NORMAL	= 1 --正邪势力战
g_FORCEWAR_CHAOS	= 2 --正邪混战
g_CHANNEL_COMBAT	= 3 --渠道对抗赛

-- 势力战对战双方类型定义
g_FORCEWAR_BLUE		= 1 -- 蓝方
g_FORCEWAR_RED		= 2 -- 红方


--匹配类型
g_TOURNAMENT_MATCH	= 1 -- 会武
g_FORCE_WAR_MATCH	= 2 -- 势力战
g_FIGHT_TEAM_MATCH	= 3 -- 武道会
g_DUNGEON_MATCH		= 4 -- 组队副本匹配
g_RIGHTHEART_MATCH	= 5 -- 正义之心匹配
g_DEFEND_MATCH		= 6 -- 守护副本匹配
g_NPC_MATCH			= 7 -- npc副本匹配
g_PRINCESS_MARRY_MATCH	= 8 -- 公主出嫁
g_MAGIC_MACHINE_MATCH	= 9	-- 神机藏海
g_LONGEVITY_PAVILION_MATCH = 10 --万寿阁

-- 跨服组队匹配类型
g_GLOBAL_MATCH_TEAM = {
	[g_DUNGEON_MATCH] = true,
	[g_RIGHTHEART_MATCH] = true,
	[g_DEFEND_MATCH] = true,
	[g_NPC_MATCH] = true,
}

g_CARD_PACKET =
{
	UNLOCK_TYPE_ITEM = 1, -- 图鉴 道具解锁,

	UNLOCK_CARD = 1, -- 解锁卡类型
	UNLOCK_CARD_BACK = 2, -- 解锁卡背类型
	-- 卡牌解锁类型
	TYPE_ITEM = 1, -- 道具解锁
	TYPE_WEAPON = 2, -- 神兵id对应星级解锁
	TYPE_MAIN_TASK = 3, -- 主线任务
	TYPE_CHENGJIU = 4, -- 成就
	TYPE_QIYUAN = 5, -- 奇缘，奇遇系统
}

--匹配等待类型
g_DUNGEON_WAIT = 1
g_TOURNAMENT_WAIT = 2
g_FORCE_WAR_WAIT = 3
g_FIGHT_TEAM_WAIT = 4

-- 武道会报名等待类型
g_FIGHTTEAM_QUALIFYING_MATCH = 1 -- 海选
g_FIGHTTEAM_TOURNAMENT_MATCH = 2 -- 锦标赛签到

-- 武道会赛事分组
g_FIGHT_TEAM_WUHUANG = 1
g_FIGHT_TEAM_WUDI = 2
-- 会武 特殊类型
g_DESERT_BATTLE_MATCH = 101 --决战荒漠
g_SPY_STORY_MATCH = 102 -- 密探风云
-- 锦标赛队长战队状态
f_FIGHT_RESULT_NOT_FIGHT	= 0 -- 未参加
f_FIGHT_RESULT_WIN			= 1 -- 胜利
f_FIGHT_RESULT_LOSE			= 2 -- 失败
f_FIGHT_RESULT_JOIN			= 3 -- 签到
f_FIGHT_RESULT_ENEMY_ERROR	= 4	-- 对方服务器异常

-- 锦标赛阶段
f_FIGHTTEAM_STAGE_QUALIFY	= 1 --海选赛阶段
--我要提升模块数值
g_skillLv_sum = 101 		     --武功等级总和
g_uniqueSkill_sum = 102 	     --武功境界等级总和
g_spirits_num = 103 		     --气功激活数量
g_spiritsLv_sum = 104 	         --已激活气功等级总和
g_qiHaiZhi_sum = 105 		     --经脉冲穴：气海值总和
g_potentialLv_sum = 106 	     --经脉潜能总等级
g_skillFormula_Lv = 107 		 --武诀等级
g_skillFormula_Jie_sum = 108 	 --武诀阶数
g_skillFormula_skillLv_sum = 109 --武诀技能能级总和
g_graspLv_sum = 201 	         --参悟等级总和
g_rarebookLv_sum = 202 	         --藏书等级总和
g_dmgtransferPoint_sum = 203 	 --乾坤总购买点数		
g_equip_BasePower_sum = 301      --已穿戴装备的战力（装备基础战力）
g_equip_Lv_avg = 302 			 --已穿戴装备的平均升级等级
g_equip_Grow_avg = 303 			 --已穿戴装备的平均强化等级	
g_equip_Diamond_avg = 304 		 --已穿戴装备的平均宝石等级
g_equip_ChuiLian_sum = 305 		 --已穿戴装备的锤炼星级总和
g_jadePower_sum = 306 			 --魂玉战力
g_shenqiPower_sum = 307 		 --神器战力
g_pet_num = 401 				 --宠物数量N
g_pet_skillLv_avg = 402 		 --平均技能等级（战力最高的前N个宠物等级平均值，若拥有宠物＜N，则以已拥有宠物数量求均值）
g_pet_Lv_avg = 403 				 --平均宠物等级（平均规则同上）
g_pet_starLv_avg = 404 			 --平均宠物星级（平均规则同上）
g_pet_break_avg = 405 			 --平均宠物突破等级（每个宠物突破等级加和）（平均规则同上）
g_pet_xinFa_avg = 406 			 --平均宠物心法等级（每个宠物心法等级加和）（平均规则同上）
g_pet_weiYang_sum = 407 		 --已拥有宠物喂养总等级	
g_pet_equip_power_avg = 408 	 --4类装备的平均战力（每类6件装备战力加和，若可穿戴的类<4,那么按实际数量计算均值）
g_pet_equip_UpLv_avg = 409 		 --宠物所有已穿戴装备升级平均值
g_pet_shiLianSkill_sum = 410 	 --宠物7个试练技能等级总和
g_pet_guardLv_avg = 411 		 --守护灵兽平均等级
g_pet_guardPotential_sum = 412 	 --守护灵兽潜能激活数量
g_shenBing_num = 501 			 --神兵数量N
g_shenBing_star_avg = 502 		 --神兵星级平均（已拥有神兵平均）
g_shenBing_lv_avg = 503 		 --神兵升阶等级平均（已拥有神兵平均）
g_shenBing_point_avg = 504 		 --神兵天赋已分配点数平均（已拥有神兵平均）
g_shenBing_skill_sum = 505 		 --当前装备的神兵技能等级和
g_shenBing_hun_sum = 506 		 --兵魂
g_shenBing_qiLing_sum = 507 	 --器灵修炼总等级
g_steed_num = 601 				 --坐骑数量N
g_steed_clean_avg = 602 		 --已拥有坐骑的平均洗练等级
g_steed_star_avg = 603	 		 --已拥有坐骑的平均星级
g_steed_break_avg = 604 		 --已拥有坐骑的平均突破等级
g_steed_skill_sum = 605 		 --已装备骑术技能等级和（先天和后天都算）
g_steed_skin = 606 				 --坐骑皮肤：无参数，不显示进度条
g_steed_master_sum = 607 		 --马术精通：激活的属性条数	
g_steed_spriteStar_sum = 608 	 --良驹之灵总星级
g_steed_skillLv_sum = 609 		 --良驹之灵技能等级和
g_steed_equipPower_sum = 610 	 --骑战装备战力
g_underWear_lv = 701 			 --当前装备的内甲等级
g_underWear_duanZao = 702 		 --当前装备的内甲锻造等级
g_underWear_point = 703 		 --当前装备的内甲已分配的点数
g_underWear_fuWen_sum = 704 	 --当前装备的内甲符文总等级（3页）
g_hideWeapon_num = 801 			 --暗器数量
g_hideWeapon_pinjie_avg = 802 	 --已拥有暗器的平均品阶
g_hideWeapon_fourSkill_sum = 803 --暗器4个技能等级之和
g_hideWeapon_lv_avg = 804 	     --已拥有暗器的平均等级
g_hideWeapon_huanHua_sum = 805 	 --暗器幻化：无参数，不显示进度条
g_martialSoul_lv_sum = 901 		 --武魂8个方位的等级和
g_martialSoul_jieShu_sum = 902 	 --武魂阶数
g_starFlare_sum = 903 		 	 --已装备星耀的战力
g_shendou_star_sum = 904 		 --神斗总星级
g_shendou_skill_sum = 905 		 --神斗技能等级总和
g_baGua_power = 1001 			 --已装备八卦的战力和（基础+套装）
g_baGua_qiangHuaLv_sum = 1002	 --已装备八卦的平均强化等级
g_baGua_yiluePoint = 1003 		 --易略购买点数
g_feisheng_upLv_avg = 1101		 --飞升装备平均升级等级
g_feisheng_qiangH_avg = 1102 	 --飞升装备平均强化等级
g_feisheng_stoneLv_avg = 1103	 --飞升装备镶嵌宝石平均等级
g_feisheng_shufuLv_avg = 1104 	 --飞升装备镶嵌宝石祝福平均等级
g_feisheng_sharpen_score = 1105  --飞升装备淬锋战力和
g_miZhu_power 				= 1201 --秘祝战力和

--我要变强模块战力
g_lvl_up_power	= 1
g_fac_skill_power	= 2
g_dress_smock_power	= 3
g_role_title_power	= 4
g_get_equip_power	= 5
g_role_streng_power	= 6
g_up_star_power	= 7
g_precious_stone_power	= 8
g_jade_up_power	= 9
g_jade_clean_power	= 10
g_skill_up_power	= 11
g_mental_up_power	= 13
g_unique_up_power	= 14
g_accompany_up_power	= 15
g_accompany_star_power	= 16
g_accompany_break_power	= 17
g_accompany_fix_power = 19
g_divine_up_power = 20
g_divine_star_power = 21
g_horse_clean_power = 22
g_horse_star_power = 23
g_collect_book = 24
g_see_truth = 25

g_equip_bare = 0
g_equip_grow = 1
g_equip_evo = 2
g_equip_grow = 3

g_pet_lvl = 1
g_pet_star = 2
g_pet_break = 3
g_pet_fix = 4

g_shenbing_lvl = 1
g_shenbing_star = 2

g_steed_clean = 1
g_steed_star = 2

g_experience_books = 1
g_experience_truth = 2

--默认线
g_DEFAULT_WORLD_LINE = -1
g_WORLD_KILL_LINE = 0 --争夺分线

g_SPLIT_HUNDRED     = 3 --百位
g_SPLIT_TEN         = 2 --十位
g_SPLIT_UNIT        = 1 --个位

--约战条件类型
f_CONDITION_LVL			= 1 --等级
f_CONDITION_POWER		= 2 --战力
f_CONDITION_XINFA		= 3 --心法总等级
f_CONDITION_SHENBING	= 4 --神兵总星级
f_CONDITION_STEEDALLSTART = 5 --坐骑总星级
f_CONDITION_CANGSHU     = 6 --藏书总星级
f_CONDITION_UNDERWEAR   = 7 --任意内甲等级

--约战npc状态
f_CONDITION_STATE_TRIGGER       = 1 --触发
f_CONDITION_STATE_OPEN          = 2 --打开
f_CONDITION_STATE_FIININSH      = 3 --完成

-- 江洋大盗 三种行为
g_ROBBER_SLEEP				= 1 -- 睡觉
g_ROBBER_WANDER				= 2 -- 游荡
g_ROBBER_TASK				= 3 --任务

-- 怪物类型
g_MONSTER_SPECIAL_NAME		= 1 --江洋大盗特殊名字

-- 职业名称
TYPE_SERIES_NAME = {
	[0] = "全系",
	[1] = "刀系",
	[2] = "剑系",
	[3] = "枪系",
	[4] = "弓系",
	[5] = "医系",
	[6] = "隐者",
	[7] = "符师",
	[8] = "拳师",
}

-- 拳师姿态
g_BOXER_NORMAL 		= 0	--平衡姿态
g_BOXER_ATTACK 		= 1	--攻击姿态
g_BOXER_DEFENCE 	= 2	--防御姿态
--拳师技能额外参数类型
g_BOXER_ADD_PROP			= 1 --姿态提升属性
g_BOXER_ADD_BUFF 			= 2 --添加buff
g_BOXER_ADD_PASSIVE 		= 3 --提升拳师被动
g_BOXER_ADD_ATR_CRI 		= 4 --提升命中和暴击
g_BOXER_ADD_UP_HP   		= 5 --根据伤害回复气血
g_BOXER_ADD_QUARD_BUFF 		= 7	--根据人数添加BUFF
--拳师姿态对应额外属性
g_BOXER_ADDTYPE = 
{
	[g_BOXER_ATTACK] = 1,
	[g_BOXER_DEFENCE] = 2
}
g_Own_And_Enemy				= 3 --技能特化周围友军和敌军数量之和
-- 魂玉附灵 五行
g_WUXING_NAME = {"金", "水", "木", "火", "土",} -- 根据配置表

--家园守卫战NPC类型（不可攻击）
g_HOMELAND_GUARD_NPC_TYPE = 1
--赏金任务状态
g_GLOBAL_WORLD_TASK_COMPLETE = 2 --完成
g_GLOBAL_WORLD_TASK_CANTAKE = 0 --可领取
g_GLOBAL_WORLD_TASK_HASTAKE = 1 --领取过
-- 势力声望 任务 接取1， 0未接取，2完成，3领过奖了
g_POWER_REP_TASK_STATE_UNACCEPT = 0
g_POWER_REP_TASK_STATE_ACCEPT = 1
g_POWER_REP_TASK_STATE_FINISHED = 2
g_POWER_REP_TASK_STATE_REWARDED = 3
--新节日任务 任务 接取1， 0未接取，2完成，3领过奖了
g_POWER_NEW_FESTIVAL_STATE_UNACCEPT = 0
g_POWER_NEW_FESTIVAL_STATE_ACCEPT = 1
g_POWER_NEW_FESTIVAL_STATE_FINISHED = 2
g_POWER_NEW_FESTIVAL_STATE_REWARDED = 3
-- 守卫副本NPC类型(不可攻击)
g_DEFENCE_NPC_TYPE = 3
-- 家园保卫战果树类型（不可攻击）
g_HOMELAND_GUARD_TREE_TYPE = 1

--守护副本提醒类型
g_DEFENCE_ALARM_BACK		= 1	--回防
g_DEFENCE_ALARM_LEFT		= 2	--左路
g_DEFENCE_ALARM_RIGHT		= 3	--右路

--伏魔洞boss的三种状态
g_DEMONHOLE_BOSS_STATE_NOREFRESH    = 0 --未刷新
g_DEMONHOLE_BOSS_STATE_REFRESH      = 1 --已刷新
g_DEMONHOLE_BOSS_STATE_DEAD         = 2 --死亡

--今日提示的类型
g_NPC_EXCHANGE_TYPE         = 1  --NPC物物兑换
g_FULI_EXCHANGE_TYPE        = 2  --福利里的运营兑换活动
g_LUCKY_WHELL_TYPE          = 3  --幸运大转盘
g_REFRESH_GOLDEN_EGG_TYPE   = 4  --刷新砸金蛋活动
g_GOLDEN_EGG_TYPE           = 5  --砸金蛋
g_DEBRIS_RECYCLE_TYPE       = 6  --碎片兑换
g_DONATE_GETFAME_TYPE       = 7  --捐赠获得武林声望
g_DRAGON_TASK_REFRESH		= 8  --龙穴任务刷新
g_FIVE_HEGEMONY_TYPE        = 9  --五绝争霸选技能
g_FACTION_BUSINESS_TASK		= 10 --帮派商路快速完成任务

--  设置输入模式
EDITBOX_INPUT_MODE_ANY           = 0            -- 任何文本的输入键盘,包括换行
EDITBOX_INPUT_MODE_EMAILADDR     = 1            -- 邮件地址 输入类型键盘
EDITBOX_INPUT_MODE_NUMERIC       = 2            -- 数字符号 输入类型键盘
EDITBOX_INPUT_MODE_PHONENUMBER   = 3            -- 电话号码 输入类型键盘
EDITBOX_INPUT_MODE_URL           = 4            -- URL 输入类型键盘
EDITBOX_INPUT_MODE_DECIMAL       = 5            -- 数字 输入类型键盘，允许小数点
EDITBOX_INPUT_MODE_SINGLELINE    = 6            -- 任何文本的输入键盘,不包括换行

--正派 邪派 普通
g_young_League = 0
g_justice_League = 1
g_evil_League = 2

--碎片回收种类
g_DEBRIS_PET = 1
g_DEBRIS_SHENBIN = 2
g_DEBRIS_STEED = 3
g_DEBRIS_ANQI = 4
g_DEBRIS_PET_GUARD = 5

--buff药使用提示类型
g_USE_HIGH_SLOTLVL  = 1
g_USE_LOW_SLOTLVL   = 2
g_USE_SAME_SLOTLVL  = 3

--buff药类型
g_NORMAL_BUFF_DRUG     = 1
g_FIGHT_LINE_BUFF_DRUG = 2

--争夺线buff药类型
g_FIGHT_LINE_CONTINUE_TIME     = 1
g_FIGHT_LINE_KILL_MOSNTER_COUNT = 2

--限制输入框的最大数字
g_edit_box_max = 100000

--折扣月卡ID
g_DISCOUNT_MONTH_CARD_ID = 13

--挂机精灵购买（续费）类型
g_TYPE_DIMOND	= 0
g_TYPE_REPLACE  = 1

--旅行精灵显示照片类型
g_Album			= 1
g_Share			= 2
g_tripGet		= 3

--圣诞贺卡打开类型
g_TYPE_Edit 	= 1
g_TYPE_Scan 	= 2
g_TYPE_Comment 	= 3

--新春福袋ui类型
g_TYPE_PRE 		= 1
g_TYPE_VALID 	= 2
g_TYPE_END 		= 3

--红包拿来活动时间段
e_Type_Show 	= 1
e_Type_Cost 	= 2
e_Type_Cashback = 3

--找你妹游戏类型
e_TYPE_MOONCAKE = 1
e_TYPE_DIGLETT	= 2
e_TYPE_PROTECTMELON = 3
e_TYPE_MEMORYCARD = 4
e_TYPE_KNIEFSHOOTING = 5

--summond 1是符灵卫 2是神兵分身
e_TYPE_FULINGWEI = 1
e_TYPE_WEAPON_CLONE = 2
e_WEAPON_TYPE_CALL_CLONE = 18--神兵特技类型：召唤分身
e_WEAPON_TYPE_ADD_PROPERTY 	= 20	--神兵特技类型：变身结束增加属性
-- 错误码提示
debug_error_tips_readonly = "变量:%s 为只读类型！不可外部修改"

g_ITEM_NUM_SHOW_TYPE_HIDE = 0 -- 隐藏数量
g_ITEM_NUM_SHOW_TYPE_OWN = 1 -- 显示拥有多少
g_ITEM_NUM_SHOW_TYPE_NEED = 2 -- 显示需要多少
g_ITEM_NUM_SHOW_TYPE_COMPARE = 3 -- 显示拥有和需要的比较

-- 家园种植类型
g_TYPE_PLANT_FLOWER = 1
g_TYPE_PLANT_WOOD = 2
g_TYPE_PLANT_FRUIT = 3

-- 家园植物状态
g_CROP_STATE_LOCK = -1 -- 未解锁的空地
g_CROP_STATE_UNLOCK = 0 -- 已解锁的空地
g_CROP_STATE_SEED = 1 -- 幼年阶段
g_CROP_STATE_STRONG = 2 -- 健壮阶段
g_CROP_STATE_MATURE = 3 -- 成熟阶段

-- 区域类型定义
g_NOTIN_ANY_AREA			= 0 -- 不在区域
g_HOMELAND_FISH_AREA	= 1 -- 钓鱼区域
g_GODMACHINE_NPC_PATH_AREA	= 2 -- 神机npc路径点区域
g_GODMACHINE_SLOW_AREA		= 3 -- 神机减速区域 
g_CATCH_SPIRIT_AREA			= 4 -- 驭灵区域
g_SPY_STORY_AREA			= 5 -- 密探风云区域

-- 家园装备类型
g_HOMELAND_WEAPON_EQUIP		= 1 --家园武器装备
g_HOMELAND_WEAPON_BAIT		= 2 --家园鱼饵部位

-- 家园钓鱼状态
g_THROW_STATE	= 1	-- 扔鱼钩
g_PACK_UP_STATE	= 2	-- 收鱼钩

-- 仓库类型
g_PERSONAL_WAREHOUSE	= 1 -- 个人仓库
g_PUBLIC_WAREHOUSE		= 2 -- 公共仓库
g_HOMELAND_WAREHOUSE	= 3 -- 家园仓库

-- 背包中道具可以存入仓库
g_NOT_PUTIN_WAREHUOSE	= 0	-- 不可存入
g_CAN_PUTIN_WAREHUOSE	= 1	-- 可存入个人仓库/公共仓库
g_CAN_PUTIN_HOMELAN_WAREHUOSE	= 2	-- 可存入家园仓库

-- 家园事件
g_HOMELAND_HISTORY_NURSE_OTHER	= 1 --他人护理
g_HOMELAND_HISTORY_NURSE_SELF	= 2 --自己护理
g_HOMELAND_HISTORY_WATER_OTHER	= 3 --他人浇水
g_HOMELAND_HISTORY_WATER_SELF	= 4 --自己浇水
g_HOMELAND_HISTORY_STEAL		= 5 --偷菜
g_HOMELAND_HISTORY_DECORATE		= 6 --放置装饰
g_HOMELAND_HISTORY_HARVEST		= 7 --收获
g_HOMELAND_HISTORY_EX_HARVEST	= 8 --额外收获
g_HOMELAND_HISTORY_REMOVE		= 9 --铲除
g_HOMELAND_HISTORY_ACTION_SELF	= 10 --自己与家园宠物互动
g_HOMELAND_HISTORY_ACTION_OTHER	= 11 --他人与家园宠物互动
g_HOMELAND_HISTORY_MOOD_REWARD	= 12 --家园宠物心情奖
g_HOMELAND_HISTORY_ACTION_PATCH	= 13 --家园宠物互动奖

-- 伙伴系统
-- 领取礼物类型
g_PARTNER_FRIEND_AWARD_TYPE		= 1 --友情礼
g_PARTNER_FRIEND_INVITE_TYPE	= 2 --邀请礼

g_SHEN_DOU_SKILL_MARTIAL_ID = 5 --武魂加持
g_SHEN_DOU_SKILL_STAR_ID = 6 --星耀加持
g_SHEN_DOU_SKILL_GOD_STAR_ID = 7 --神斗加持

--试炼状态
g_ACTIVITY_STATE	 = 1
g_WORLD_BOSS_STATE = 2
g_SPIRIT_MONSTER_STATE = 3
g_LONGEVITY_PAVILION_STATE = 4
g_PRINCESS_MARRY_STATE = 5
g_MAGIC_MACHINE_STATE = 6
g_TOWER_STATE		 = 7
g_TREASURE_STATE   = 8
g_PET_ACTIVITY_STATE = 9
g_EPIC_STATE		 = 10
g_SWORDSMAM_CIRCLE = 11
g_ROBBER_STATE		= 12

--竞技状态
g_ARENA_STATE		= 1
g_TAOIST_STATE		= 2
g_TOURNAMENT_STATE	= 3
g_FORCE_WAR_STATE	= 4
g_DEMON_HOLE_STATE	= 5 --伏魔洞
g_MAZE_BATTLE_STATE	= 6	--天魔迷宫
g_BATTLE_DESERT		= 7 --决战荒漠
g_BANGPAIZHAN		= 8 --帮派战
g_FIGHT_TEAM_STATE	= 9 --武道大会
g_GLOBAL_PVE_STATE	= 10 --跨服PvE
g_DEFENCE_WAR_STATE	= 11 --城战

--宠物试炼幸运事件
g_DOUBLEDROP	= 1 --双倍掉落
g_ADDALLLEVEL	= 2 --全技能精通加1
g_FORCEGATHER	= 3 --强制采集
g_ADDSPEED		= 4 --加速采集

--驭灵交换状态
g_SPIRIT_STATE_NORMAL = 0
g_SPIRIT_STATE_COMPLETE = 1
g_SPIRIT_STATE_FAIL = 2

-- 节日活动配置.xlsx 中配置的活动id
g_activity_show_perfect = 1 -- 十全十美
g_activity_show_world = 1   -- 世界告白

--世界杯
g_WORLD_CUP_32 = 32   --32强

--怪物类型
--g_MONSTER_TYPE_SPIRIT_BOSS		= 8 -- 巨灵攻城怪物类型


-- 城战 入口报名的几种状态值
g_DEFENCE_WAR_STATE_NONE 		= 0  -- 没有新赛季
g_DEFENCE_WAR_STATE_SIGN_WAIT 	= 1  -- 等待报名
g_DEFENCE_WAR_STATE_SIGN_UP		= 2  -- 报名中
g_DEFENCE_WAR_STATE_PVE_WAIT 	= 3  -- 竞速等待中 pve
g_DEFENCE_WAR_STATE_PVE 		= 4  -- 竞速占城中 pve
g_DEFENCE_WAR_STATE_NO_FIGHT 	= 5  -- 休战期
g_DEFENCE_WAR_STATE_BID 		= 6  -- 夺城竞标
g_DEFENCE_WAR_STATE_BID_SHOW 	= 7  -- 竞标公示
g_DEFENCE_WAR_STATE_PVP 		= 8  -- 夺城中 pvp
g_DEFENCE_WAR_STATE_PEACE 		= 9  -- 和平期

-- 城战怪物类型
g_DEFENCE_WAR_MONSTER_GUARD 	= 11  -- 巡逻守卫
g_DEFENCE_WAR_MONSTER_BOSS 		= 12  -- 大将军
g_DEFENCE_WAR_MONSTER_OUT_GATE 	= 13  -- 外城城门
g_DEFENCE_WAR_MONSTER_IN_GATE 	= 14  -- 内城城门
g_DEFENCE_WAR_MONSTER_TOWER 	= 15  -- 箭塔

-- 城战权限定义
g_DEFENCE_WAR_PERMISSION_SIGN 		= "defenceWarSign"      -- 城战报名
g_DEFENCE_WAR_PERMISSION_SIGN_CITY  = "defenceWarSignCity"  -- 城战 夺城报名
g_DEFENCE_WAR_PERMISSION_TRANS 		= "defenceWarTrans"		-- 城战 兵工厂变身
g_DEFENCE_WAR_PERMISSION_REPAIR		= "defenceWarRepair"	-- 城战修复箭塔
g_DEFENCE_WAR_PERMISSION_CITY_LIGHT	= "defenceWarCityLight"	-- 城主之光

-- citySign：表示每个城是否有帮派报名，0没有，1有，2本帮已报
g_DEFENCE_WAR_SIGN_NONE = 0
g_DEFENCE_WAR_SIGN_OTHER = 1
g_DEFENCE_WAR_SIGN_MINE = 2

-- 0无主城池，1没有帮派竞标，2有帮派竞标， 3本帮派已竞标
g_DEFENCE_WAR_BID_EMPTY = 0
g_DEFENCE_WAR_BID_NONE = 1
g_DEFENCE_WAR_BID_OTHER = 2
g_DEFENCE_WAR_BID_MINE = 3

-- 0战斗尚未结束，1战斗已结束
g_DEFENCE_WAR_ING = 0
g_DEFENCE_WAR_FINISH = 1

--任务变身的几种类型
g_TASK_TRANSFORM_STATE_PEOPLE		= 1	-- 普通任务变身
g_TASK_TRANSFORM_STATE_SUPER		= 2	-- 神兵变身	
g_TASK_TRANSFORM_STATE_ANIMAL		= 3 -- 坐骑变身
g_TASK_TRANSFORM_STATE_CARRY		= 4 -- 护送变身
g_TASK_TRANSFORM_STATE_CAR 			= 5 -- 攻城车变身
g_TASK_TRANSFORM_STATE_METAMORPHOSIS = 6 --幻形变身
g_TASK_TRANSFORM_STATE_SKULL 		= 7 -- 决战荒漠小骷髅变身
g_TASK_TRANSFORM_STATE_CHESS		= 8 -- 楚汉之争变身
g_TASK_TRANSFORM_STATE_SPY			= 9 -- 密探风云变箱子

g_DYNAMIC_ACTIVITY_TYPE = 31 --充值获得折扣礼包购买权
g_RANKLIST_HOMELAND_RELEASE = 39 --家园放生善缘值排行榜ID

--家园房屋家具类型
g_HOUSE_FLOOR_FURNITURE = 1
g_HOUSE_WALL_FURNITURE = 2
g_HOUSE_HANG_FURNITURE = 3
g_HOUSE_CARPET_FURNITURE = 4

--家园区域类型
g_HOUSE_WALL_AREA = 1
g_HOUSE_OTHER_AREA = 2

--装备锤炼技能类型
g_EQUIP_SKILL_TYPE_GEM_STRENGTHEN = 1 --提升宝石属性
g_EQUIP_SKILL_TYPE_WEAPON_BLESS = 2 --武器祝福
g_EQUIP_SKILL_TYPE_REVISE_WEAPON_BLESS_ARGUMENT = 3 --武器祝福参数修正
g_EQUIP_SKILL_TYPE_GOD_POWER_BLESS = 4 --神力祝福
g_EQUIP_SKILL_TYPE_LUCKY_BLESS = 5 --幸运祝福

--定期活动状态
g_TIMINGACTIVITY_STATE_NONE = 0          --无定期活动
g_TIMINGACTIVITY_STATE_PREVIEW = 1       --活动预告
g_TIMINGACTIVITY_STATE_OPEN = 2          --活动开启
g_TIMINGACTIVITY_STATE_RECEIVE = 3       --活动领取奖励

--神兵形象
g_WEAPON_FORM_NORMAL = 1 --默认神兵形象
g_WEAPON_FORM_ADVANCED = 2 --进阶形象（彼岸花）
g_WEAPON_FORM_AWAKE =3 --觉醒形象

--神兵状态
g_WEAPON_STATE_UNLOCK = 1 --神兵解锁
g_WEAPON_STATE_RESPONSE = 2 --神兵升级升阶
g_WEAPON_STATE_LOCK = 3 --神兵未解锁

--定期活动
 g_EXCHANGE_UI = 2 --兑换界面
 g_ACTIVITY_UI = 1 --活动

--兑换类型
g_EXCHANGE_NPC 		= 1 --npc兑换道具
g_EXCHANGE_ACTIVITY = 2 --活动兑换
--活动兑换类型
g_EXCHANGE_WANNENGCOIN	= 1	--鼠年纪念币兑换万能币
g_EXCHANGE_USEWN_GOODS 	= 2	--万能币兑换物品

--个人商店类型
g_SHOP_TYPE_ESCORT			= 1 --赏金商城
g_SHOP_TYPE_ARENA			= 2 --竞技商城
g_SHOP_TYPE_FACTION			= 3 --帮派商城
g_SHOP_TYPE_TOURNAMENT		= 4 --会武商城
g_SHOP_TYPE_MASTER			= 5 --师徒商城
g_SHOP_TYPE_PET				= 6 --龟龟商城
g_SHOP_TYPE_FAME			= 7 --武林商城

-- 帮派驻地精灵祝福权限
g_FACTION_SPIRIT_BLESS_PERMISSION = "garrisonSpirit"

--驻地精灵
g_SPIRIT_SEARCH_SHILL 		= 1 -- 在技能范围
g_SPIRIT_SEARCH_SHOW 		= 2 -- 指引范围
g_SPIRIT_SEARCH_NONE 		= 3 -- 没有
--宠物装备部位数
g_PET_EQUIP_PART_COUNT = 6
--骑战装备部位数
g_STEED_EQUIP_PART_COUNT = 6

-- 快速完成任务类型
g_QUICK_FINISH_TASK_TYPE_FACTION = 1 --帮派快速完成任务
g_QUICK_FINISH_TASK_TYPE_LONGXUE = 2 --龙穴
g_QUICK_FINISH_TASK_TYPE_SHENBING = 3 --神兵
g_QUICK_FINISH_TASK_TYPE_BUSINESS = 4 --帮派商路
g_QUICK_FINISH_TASK_TYPE_RING	  = 5 --飞升环任务
g_QUICK_FINISH_FIVE_UNIQUE		= 6 -- 秘境任务
--咏诗
g_TASK_VERSE_STATE_CHESS = 1
g_TASK_VERSE_STATE_REGULAR = 2 --定期活动咏诗
g_TASK_VERSE_STATE_FESTIVAL = 3 --节日限时活动
--咏诗背景图
TASK_VERSE_ICON = {
	[g_TASK_VERSE_STATE_REGULAR] = {title = 7606,  },
	[g_TASK_VERSE_STATE_CHESS]	 = {title = 7605,  },
	[g_TASK_VERSE_STATE_FESTIVAL] = {title = 7605,},
}

--旋转方向
g_TURN_LEFT = 1
g_TURN_RIGHT = 2

--移动方向
g_MOVE_DIRECTION_LEFT	= 1
g_MOVE_DIRECTION_RIGHT	= 2
g_MOVE_DIRECTION_UP		= 3
g_MOVE_DIRECTION_DOWN	= 4
--荒漠背包列数
g_DESEET_BAG_ROW_NUM = 3

--天魔迷宫宝箱类型
g_MAZE_MINE_TIMES_AREA = 1
g_MAZE_MINE_TIMES_LIMIT = 2

--组队buff类型
g_TEAM_BUFF_DAMAGE_ADD = 1--伤害增加加成
g_TEAM_BUFF_DAMAGE_SUB = 2--伤害减免加成
g_TEAM_BUFF_RESULT_EXP = 3--结算经验加成
g_TEAM_BUFF_RESULT_COIN = 4--结算金币加成
g_TEAM_BUFF_RESULT_ITEM = 5--结算道具加成
g_TEAM_BUFF_MONSTER_EXP = 6--怪物经验加成
--五绝争霸状态
g_FIVE_CONTEND_HEGEMONY_NONE 			= 0 --未开启状态
g_FIVE_CONTEND_HEGEMONY_PRESELECTION	= 1 --预选状态
g_FIVE_CONTEND_HEGEMONY_ACTIVITY		= 2	--开始活动状态
g_FIVE_CONTEND_HEGEMONY_SHOW 			= 3 --结果展示状态
--五绝争霸协议状态
g_HEGEMONY_PROTOCOL_STATE_SYNC			= 1 --进入同步
g_HEGEMONY_PROTOCOL_STATE_ROUND 		= 2	--切换回合
g_HEGEMONY_PROTOCOL_STATE_CHOOSE		= 3	--选择支持
-- 弹幕类型
g_SHOOT_MSG_TYPE_FACTION				= 0 --帮派弹幕
g_SHOOT_MSG_TYPE_HEGEMONY 				= 1 --五绝争霸弹幕类型
--答题类型
g_ANSWER_TYPE_KEJU						= 1	--科举
g_ANSWER_TYPE_MILLIONS					= 2 --百万答题
g_ANSWER_TYPE_HEGEMONY					= 3	--五绝争霸
-- 暗器皮肤心法生效类型
g_HIDE_WEAPON_SKIN_XINFA_EQUIPMENT		= 1 --装备生效
g_HIDE_WEAPON_SKIN_XINFA_PERMANENT		= 2 --解锁生效
g_WEAPON_WALEUP_SKILL_NEEDEQUIP_TYPE = 1 --需要装备此神兵
g_WEAPON_WALEUP_SKILL_EXPA_TYPE = 2 --经验A
g_WEAPON_WALEUP_SKILL_EXPB_TYPE = 3 --经验B
g_WEAPON_WALEUP_SKILL_EFFECT_TYPE = 4 --不需要装备此神兵
-- 骑战装备
g_STEED_EQUIP_TIPS_EQUIP = 1 -- 在部位上点击, 无对比
g_STEED_EQUIP_TIPS_BAG   = 2 -- 背包内点击，（此部位没装备）无对比形态
g_STEED_EQUIP_TIPS_BAG2  = 3 -- 背包内点击，此部位已经有别的装备了，有对比
g_STEED_EQUIP_TIPS_STOVE = 4 -- 熔炉界面
g_STEED_EQUIP_TIPS_NONE  = 5 -- 按钮都不显示
--飞鸽传书类型
g_PIGEON_LOCAL_SEVER	= 1 --本地发送
g_PIGEON_OTHER_SEVER	= 2 --跨服发送
-- 周年庆活动阶段2任务类型
g_JUBILEE_TASK_FINISH 	= 0 -- 完成接取任务可领取奖励
-- 周年庆活动阶段
g_JUBILEE_NOT_OPEN		= 0 -- 未开始
g_JUBILEE_STAGE1		= 1 -- 阶段1
g_JUBILEE_STAGE2		= 2 -- 阶段2
g_JUBILEE_COUNTDOWN		= 3 -- 阶段3倒计时
g_JUBILEE_COUNTDOWN_END = 4 -- 阶段3倒计时结束
g_JUBILEE_STAGE3		= 5 -- 阶段3
g_JUBILEE_END			= 6 -- 结束
-- 任务状态
g_TASK_STATE_ORIGIN		= 0 -- 未开始
g_TASK_STATE_ACESS		= 1 -- 接取
g_TASK_STATE_FINISH		= 2 -- 完成未领奖
g_TASK_STATE_REWAEDED	= 3 -- 完成并领取奖励
--npc自动寻路默认停止距离
g_MOVE_STOP_DISTANCE = 2
-- 矿物类型
g_TYPE_MINE_JUBILEE		= 19 --周年庆
g_TYPE_MINE_PRINCESSMARRY = 20 --公主出嫁
g_TYPE_MINE_HOMELANDGUARD = 21 --家园保卫战
g_TYPE_MINE_LONGEVITY_PAVILION = 22	-- 万寿阁
g_TYPE_MINE_SPY_STORY			= 23 -- 密探
-- 传送类型
g_TRANSPORT_TO_NPC				= 1		-- 传送到npc
g_TRANSPORT_TO_MINEPOINT		= 2		-- 传送到矿点
g_TRANSPORT_TO_MONSTER			= 3		-- 传送到怪物
g_TRANSPORT_TO_STELA 			= 4		-- 太玄碑文传送
g_TRANSPORT_TO_SPAWNMONSTER 	= 5		-- 怪物点
g_TRANSPORT_TO_ANYWHERE 		= 6		-- 随时副本传送
g_TRANSPORT_TO_JUBILEE 			= 7		-- 周年庆活动阶段3传送
g_TRANSPORT_TO_THUMBTACK 		= 33	-- 图钉传送
--公主出嫁事件类型
g_PRINCESS_MARRY_EVENT_ANIMATION 	 = 1 --动画
g_PRINCESS_MARRY_EVENT_MONSTER 		 = 2 --刷怪
g_PRINCESS_MARRY_EVENT_CLEARNPC 	 = 3 --改变马车状态
g_PRINCESS_MARRY_EVENT_CLEAROBSTACLE = 4 --空闲
g_PRINCESS_MARRY_EVENT_DIALOGUE 	 = 5 --对话
g_PRINCESS_MARRY_EVENT_GATHER  	 	 = 6 --采集
--武器显示类型
g_WEAPON_SHOW_TYPE		= 0 --显示装备武器
g_HEIRHOOM_SHOW_TYPE	= 1 --显示神器
g_FASTION_SHOW_TYPE		= 2 --显示时装武器
g_FLYING_SHOW_TYPE		= 3 --显示飞升武器
--胸甲显示类型
g_WEAR_NORMAL_SHOW_TYPE		= 0 --显示装备胸甲
g_WEAR_FASHION_SHOW_TYPE	= 2 --显示时装胸甲
g_WEAR_FLYING_SHOW_TYPE		= 3 --显示飞升胸甲
g_GEM_SALE_CONFIRM_LEVEL	= 10 --宝石出售二次确认界面最低宝石等级
--运镖抽奖id
g_FACTION_ESCORT_LUAK_ONE = 1 -- 运镖抽奖id
--cpr视频播放状态
g_VIDEO_FINISHED = 1 --播放完成
g_VIDEO_INTERRUPT = 2 --中途退出
--神机藏海事件类型
g_MAGIC_MACHINE_EVENT_MOVE = 1 --机关通道


--oppo活动状态
g_OPPO_OPEN_STATE					 = 1 -- 打开oppo活动
g_OPPO_UPDATA_FULI_STATE			 = 2 --刷新福利界面
g_OPPO_UPDATA_PRIVILEGE_STATE 		 = 3 --刷新oppo特权
g_OPPO_UPDATA_WELFARE_STATE 		 = 4 --刷新oppo福利

--装备开启或实现的功能
g_FACILITY_EQUIP_UPGRADE = 1
g_FACILITY_EQUIP_ENHANCEMENT = 2
g_FACILITY_GEM_NESTING = 3
g_FACILITY_GEM_BLESSING = 4
--装备类型
g_EQUIP_TYPE_GENERAL	= 1		--通用装备
g_EQUIP_TYPE_FEISHENG	= 2		--飞升装备
--自动工作类型
g_AUTO_STEED_REFINE  = 1 --坐骑自动洗练

--江湖侠探boss揭露状态
g_DETECTIVE_NOT_EXPOSE	= 0 --未揭露
g_DETECTIVE_EXPOSED		= 1 --已揭露
--江湖侠探boss追击状态
g_DETECTIVE_NOT_FIND	= 0 --没有追击
g_DETECTIVE_CHANSING	= 1 --正在追击
g_DETECTIVE_DEAD		= 2 --已死亡
--uiBaseChat
g_Battle_Base_Chat_Count = 50 --聊天最大上限
--黄金海岸地图类型
g_GOLD_COAST_PEACE = 1 --和平
g_GOLD_COAST_FIGHT = 2 --争夺
--元灵稀有碎片类型
g_SPIRIT_FRAGMENT_RARE = 2
--阵法石套装类型
g_ARRAY_STONE_SUIT_COEXIST = 1 -- 共存
g_ARRAY_STONE_SUIT_ONLY = 2 -- 唯一
g_ARRAY_STONE_SUIT_COMBINE = 3 -- 组合
g_ARRAY_STONE_SUIT_SUFFIX = 4 -- 后缀
--阵法石套装施加类型
g_STONE_SUIT_ADDITION_SELF = 1 -- 本套装内施加
g_STONE_SUIT_ADDITION_ALL = 2 -- 所有装备密文施加
--阵法石最大上阵数量
g_ARRAY_STONE_MAX_EQUIP = 17
--阵法石最大祈言孔位
g_ARRAY_STONE_PRAY_HOLE	= 7
g_SUIT_LEVEL_STRING = {18480, 18481, 18482, 18483, 18484, 18485, 18486, 18487, 18488}
----剧情漫画状态
g_plot_cartoon_princess_marry = 1 --公主出嫁 PRINCESS_MARRY
g_plot_cartoon_longevity_pavilion = 2 --万寿阁LONGEVITY_PAVILION 
g_plot_cartoon_longevity_pavilion_map = 3 --万寿阁小地图LONGEVITY_PAVILION_MAP
g_plot_cartoon_shenjicanghai_manhua = 4 --神机藏海漫画
--外传职业反悔状态
g_BIOGIAPHY_STATE_UNFINISH = 0 -- 未完成试炼
g_BIOGIAPHY_STATE_WITHINTIME = 1 -- 已免费转职，在反悔期限内
g_BIOGIAPHY_STATE_CONFESSED = 2 -- 已反悔过
g_BIOGIAPHY_STATE_OVERDUE = 3 -- 已过期
g_BIOGIAPHY_STATE_FINISH = 4 -- 已完成试炼，没有使用免费转职次数
--外传职业转职
g_BIOGRAPHY_TRANSFORM_FORWARD = 1 -- 正向转职
g_BIOGRAPHY_TRANSFORM_REGRET = 2 -- 反悔
-------------------------------------------

    AT_GM_MOD_ITEM                      = 1       --="gm修改道具"/>

    AT_PAY 		                       = 9     --="充值"/>
    AT_SYS_REWARD                       = 48     --="系统奖励"/>
    AT_WORLD_REWARD                     = 49     --="全服奖励"/>
    AT_LEVEL_UP                         = 50      --="升级"/>


    --<!-- 71-79之间保留用于记录商品售卖统计分析 -->
    AT_BUY_MALL_GOODS                   = 71     --="商城购买"/>
    AT_BUY_SHOP_GOOGS                   = 72     --="购买商店商品"/>
    AT_STROE_BUY                        = 73     --="杂货店"/>
    AT_BUY_SUIT                         = 74     --="购买套装"/>
    AT_GROUPUY_GOODS                    = 75    --限时团购
    AT_FLASHSALE_GOODS                  = 76    --限时特卖
    AT_BUY_COIN                         = 101     --="购买金币"/>
    AT_BUY_VIT                          = 102     --="购买体力"/>
    AT_USE_POTION                       = 103     --="使用药水"/>
    AT_BUY_LUCKY_WHEEL_DRAW_TIMES       = 104     --="购买幸运大转盘抽奖次数"/>
    AT_CHECKIN_TAKE                     = 105     --="签到"/>
    AT_TAKE_FIRST_PAY_GIFT_REWARD       = 106     --="首次储值领奖"/>
    AT_TAKE_PAY_GIFT_REWARD             = 107     --="领取储值奖励"/>
    AT_TAKE_CONSUME_GIFT_REWARD         = 108     --="领取消费奖励"/>
    AT_TAKE_UPGRADE_GIFT_REWARD         = 109     --="领取升级奖励"/>
    AT_BUY_INVESTMENT_FUND              = 110     --="购买基金"/>
    AT_TAKE_INVESTMENT_FUND_REWARD      = 111     --="领取基金奖励"/>
    AT_BUY_GROWTH_FUND                  = 112     --="购买成长基金"/>
    AT_TAKE_GROWTH_FUND_REWARD          = 113     --="领取成长基金"/>
    AT_TAKE_EXCHANGE_GIFT_REWARD        = 114     --="兑换活动"/>
    AT_TAKE_LOGIN_GIFT_REWARD           = 115     --="登入送礼活动"/>

    AT_BUY_NORMAL_MAPCOPY_TIMES         = 116     --="购买普通副本进入次数"/>
    AT_BUY_ACTIVITY_MAPCOPY_TIMES       = 117     --="购买活动副本进入次数"/>
    AT_SWEEP_PRIVATE_MAP                = 118     --="扫荡副本"/>
    AT_TAKE_VIP_REWARD                  = 119     --="领取vip奖励"/>
    AT_EXPAND_BAG_CELLS                 = 120     --="扩展背包"/>
    AT_SELL_BAG_EQUIP                   = 121     --="出售背包装备"/>
    AT_SELL_BAG_ITEM                    = 122     --="出售背包物品"/>
    AT_SELL_BAG_GEM                     = 123     --="出售背包宝石"/>
    AT_SELL_BAG_BOOK                    = 124     --="出售背包新法书"/>
    AT_BATCH_SELL_BAG_EQUIPS            = 125     --="批量出售背包装备"/>
    AT_BATCH_SELL_BAG_ITEMS             = 126     --="批量出售背包道具"/>
    AT_BATCH_SELL_BAG_GEMS              = 127     --="批量出售背包宝石"/>
    AT_BATCH_SELL_BAG_BOOKS             = 128     --="批量出售背包心法书"/>
    AT_USE_ITEM_GIFT_BOX                = 129     --="使用礼包"/>
    AT_USE_ITEM_COIN_BAG                = 130     --="使用金币包"/>
    AT_USE_ITEM_DIAMOND_BAG             = 131     --="使用宝石包"/>
    AT_USE_ITEM_EXP                     = 132     --="使用经验丹"/>
    AT_USE_ITEM_HP                      = 133     --="使用血瓶"/>
    AT_USE_ITEM_HP_POOL                 = 134     --="使用血池道具"/>
    AT_USE_ITEM_EQUIP_ENERGY            = 135     --="使用装备能量丹"/>
    AT_USE_ITEM_GEM_ENERGY              = 136     --="使用宝石能量丹"/>
    AT_USE_ITEM_SPIRIT_INSPIRATION      = 137     --="使用心法丹"/>
    AT_USE_ITEM_AS_VIT                  = 138     --="使用体力瓶"/>
    AT_USE_ITEM_FASHION                 = 139     --="使用时装包"/>
    AT_UP_WEAR_EQUIP                    = 140     --="穿装备"/>
    AT_DOWN_WEAR_EQUIP                  = 141     --="脱装备"/>
    AT_EQUIP_LEVEL_UP                   = 142     --="装备强化"/>
    AT_EQUIP_STAR_UP                    = 143     --="装备升星"/>
    AT_REPAIR_EQUIP                     = 144     --="修炼装备"/>
    AT_AUTO_UP_WEAR_EQUIP               = 145     --="批量穿装备"/>
    AT_GEM_LEVEL_UP                     = 146     --="宝石升级"/>
    AT_GEM_INLAY                        = 147     --="宝石镶嵌"/>
    AT_GEM_UNLAY                        = 148     --="宝石解镶嵌"/>
    AT_SKILL_LEVEL_UP                   = 149     --="技能等级提升"/>
    AT_SKILL_ENHANCE                    = 150     --="技能强化"/>
    AT_LEARN_SPIRIT                     = 151     --="学习心法"/>
    AT_SPIRIT_LEVEL_UP                  = 152     --="心法升级"/>
    AT_MAKE_WEAPON                      = 153     --="启动神兵"/>
    AT_WEAPON_LEVEL_UP                  = 154     --="神兵升级"/>
    AT_WEAPON_BUY_LEVEL                 = 155     --="神兵购买升级"/>
    AT_MAKE_PET                         = 156     --="启动佣兵"/>
    AT_PET_TRANSFORM                    = 157     --="佣兵转职"/>
    AT_PET_LEVEL_UP                     = 158     --="佣兵升级"/>
    AT_PET_BUY_LEVEL                    = 159     --="佣兵购买升级"/>
    AT_PET_STAR_UP                      = 160     --="佣兵升星"/>
    AT_PET_BREAK_SKILL_LEVEL_UP         = 161     --="佣兵技能突破"/>
    AT_TAKE_DAILY_TASK_REWARD           = 162     --="领取每日任务奖励"/>
    AT_TAKE_CHALLENGE_TASK_REWARD       = 163     --="领取挑战任务奖励"/>
    AT_TAKE_DAILY_ONLINE_GIFT           = 164     --="领取每日线上奖励"/>
    AT_LUCKY_WHEEL_ON_DRAW              = 165     --="幸运大转盘抽奖"/>

    AT_TAKE_MAIN_TASK_REWARD            = 166     --="领取主线任务奖励"/>
    AT_TAKE_WEAPON_TASK_REWARD          = 167     --="领取神兵任务奖励"/>
    AT_DIY_SKILL_BUY_TIMES              = 168     --="购买自创武功次数"/>
    AT_CLAN_SPLIT_SP_BUY                = 169     --="分解装备"/>
    AT_CLAN_MOVE_POSITION               = 170     --="宗门战之宗门迁移"/>
    AT_TELEPORT_NPC                     = 171     --="地图传送到NPC"/>
    AT_TELEPORT_MONSTER                 = 172     --="地图传送到怪物"/>
    AT_TELEPORT_MINERAL                 = 173     --="地图传送到矿"/>
    AT_ARENA_RESET_COOL                 = 174     --="竞技场清除冷却"/>
    AT_ARENA_BUY_TIMES                  = 175     --="竞技场购买次数"/>
    AT_TAKE_ARENA_SCORE_REWARD          = 176     --="竞技场领取积分奖励"/>
    AT_GIVE_FRIEND_FLOWER               = 177     --="给好友送花"/>
    AT_PUT_ON_EQUIP                     = 178     --="寄售装备"/>
    AT_PUT_ON_NORMAL_ITEMS              = 179     --="寄售道具"/>
    AT_PUT_OFF_AUCTION_ITEMS            = 180     --="取消寄售道具装备"/>
    AT_BUY_AUCTION_ITEMS                = 181     --="购买寄售道具装备"/>
    AT_EXPAND_AUCTION_CELLS             = 182     --="扩充寄售格子"/>
    AT_REFRESH_TREASURE_INFO            = 183     --="刷新藏宝图碎片"/>
    AT_BUY_TREASURE_PIECES              = 184     --="购买藏宝图碎片"/>
    AT_TREASURE_TOTAL_SEARCH            = 185     --="开启寻宝"/>
    AT_MEDAL_GROW                       = 186     --="宝物装裱"/>
    AT_TAME_HORSE                       = 187     --="驯服坐骑"/>
    AT_UP_STAR_HORSE                    = 188     --="坐骑升星"/>
    AT_ENHANCE_HORSE                    = 189     --="坐骑强化"/>
    AT_ACTIVATE_SHOW                    = 190     --="坐骑幻化"/>
    AT_LEARN_HORSE_SKILL                = 191     --="学习坐骑技能"/>
    AT_CLAN_BUY_DO_POWER                = 192     --="宗门购买行动力"/>
    AT_USE_CHAT_ITEM                    = 193     --="消耗大喇叭"/>

    AT_SYNC_END_MINE                    = 194     --="结束挖矿"/>
    AT_ADD_DROP_TO_BAG 			       = 195     --="拾取掉落和奖励物品到背包"/>
    AT_SWEEP_ADD_DROP_TO_BAG     	   = 196     --="领取扫荡掉落和奖励物品到背"/>
    AT_TAKE_MAIL_ATTACHMENT             = 197     --="领取信件附件"/>
    AT_TAKE_ALL_MAIL_ATTACHMENT         = 198     --="领取全部信件附件"/>
    AT_COMMON_MAPCOPY_ONSTART           = 199     --="进入普通副本扣体力"/>
    AT_ON_SELECT_REWARD_CARD            = 200     --="领取通关副本翻盘奖励"/>
    AT_SECT_MAPCOYP_ONSTART             = 201     --="进入帮派副本扣体力"/>
    AT_SECT_MAPCOYP_ONEND               = 202     --="帮派副本结束伤害奖励"/>
    AT_ARENA_MAPCOPY_ONEND              = 203     --="竞技场结束名次上升奖励"/>
    AT_REVIVE_IN_SITU                   = 204     --="原地复活"/>
    AT_TRANSFORM                        = 205     --="转职"/>
    AT_TRY_START_MINE                   = 206     --="挖矿"/>
    AT_TAKE_GIFT_PACKAGE_REWARD 		   = 207     --="礼包码兑换奖励"/>
    AT_USER_REFRESH_SHOP                = 208     --="用户刷新商店"/>
    AT_DEL_LOCKED_BAG_ITEMS             = 209     --="生产删除锁定道具"/>
    AT_TRY_REFRESH_VIT                  = 210     --="尝试刷新体力"/>
    AT_TRY_REFRESH_SPLIT_SP             = 211     --="尝试刷新分解能量"/>
    AT_USE_ITEM_CHEST_IMPL             =  212     --="使用抽奖宝箱"/>
    AT_USE_ITEM_AS_RECIPEREEL           = 213     --="使用配方卷轴"/>
    AT_WEAPON_STAR_UP                   = 214     --="神兵升星"/>
    AT_CREATE_NEW_SECT                  = 215     --="创建新帮派"/>
    AT_TRY_WORSHIP_SECT_MEMBER          = 216     --="尝试膜拜帮派成员"/>
    AT_TRY_OPEN_SECT_BANQUET            = 217     --="尝试开启帮派宴席"/>
    AT_TRY_JOIN_SECT_BANQUET            = 218     --="尝试参加帮派宴席"/>
    AT_SECT_TASK_FINISH_CB              = 219     --="完成帮派任务"/>
    AT_TEST_LOG_TASK                    = 220     --="提交任务道具"/>
    AT_SECT_TASK_RESET_CB               = 221     --="刷新帮派任务"/>
    AT_SECT_TASK_TAKE_SHARE_REWARDS     = 222     --="领取帮派共用任务奖励"/>
    AT_CHANGE_SECT_NAME_CB              = 223     --="修改帮派名称"/>
    AT_SECT_SEND_MAIL_CB                = 224     --="发送帮派资讯"/>
    AT_DIYSKILL_SLOT_UNLOCK             = 225     --="自创武功解锁槽位"/>
    AT_BUY_PRESTIGE                     = 226     --="购买声望"/>
    AT_CLAN_CREATE                      = 227     --="创建宗门"/>
    AT_CLAN_SHOUTU_SPEEDUP              = 228     --="宗门加速收徒"/>
    AT_CLAN_BIWU_SPEEDUP                = 229     --="宗门加速比武"/>
    AT_CLAN_BUSHI_START                 = 230     --="宗门布施开始"/>
    AT_OFFLINE_EXP                      = 231     --="离线领经验奖励"/>
    AT_CLAN_RUSH_TOLLGATE_TO_EXP        = 232     --="宗门经验提升精英弟子属性"/>
    AT_CLAN_RUSH_TOLLGATE_TO_ITEM       = 233     --="宗门道具提升精英弟子属性"/>
    AT_CLAN_ORE_BUILD_UPLEVEL           = 234     --="宗门矿升级"/>
    AT_ADD_CLAN_ORE                     = 235     --="宗门添加矿"/>
    AT_SYNC_ADD_ORE                     = 236     --="宗门矿添加物品"/>
    AT_CLAN_CHUANDAO_START              = 237     --="宗门传道开始"/>
    AT_CLAN_ORE_OCCUPY_FINISH           = 238     --="宗门占矿完成"/>
    AT_CLAN_SEARCH_ORE                  = 239     --="宗门夺矿搜索"/>
    AT_CLAN_ORE_HARRY_FIGHT_END         = 240     --="宗门矿遭遇战结束"/>
    AT_CLAN_BATTLE_KEEK                 = 241     --="宗门战侦查"/>
    AT_CLAN_SPLIT                       = 242     --="宗门分解"/>
    AT_ON_SUPER_ARENA_END               = 243     --="会武副本结算"/>
    AT_RESET_TRANS_TIME                 = 244     --="重置传送时间"/>
    AT_CHECK_CAN_TRANS_TO_BOSS          = 245     --="传送至BOSS"/>
    AT_RECEIVE_FRIEND_VIT               = 246     --="接收好友赠送的体力批量"/>
    AT_RECEIVE_FRIEND_VIT2              = 247     --="接收好友赠送的体力单个"/>
    AT_LOG_TREASURE_TASK                = 248     --="藏宝图任务消耗"/>
    AT_TAKE_TREASURE_NPC_REWARD         = 249     --="获取藏宝图NPC奖励"/>
    AT_TAKE_TREASURE_MAP_REWARD         = 250     --="获取藏宝图地图奖励"/>
    AT_GM_ADD_GAME_ITEM                 = 251     --="GM添加物品"/>
    AT_SEAL_NORMAL_MAKE                 = 252     --="龙印道具合成"/>
    AT_SEAL_DIAMOND_MAKE                = 253     --="龙印元宝合成"/>
    AT_SEAL_UPGRADE                     = 254     --="龙印升级"/>
    AT_SEAL_ENHANCE                     = 255     --="龙印洗练"/>
    AT_ADD_EXP_COIN                     = 256     --="获取经验正常历练币"/>
    AT_USE_ITEM_EXPCOIN_POOL            = 257     --="使用历练瓶"/>
    AT_EXTRACT_EXPCOIN                  = 258     --="提炼历练到历练瓶"/>
    AT_BWARENA_MAPCOPY_ONEND            = 259     --="正邪道场副本结束"/>
    AT_BWARENA_REFRESH_ENEMY            = 260     --="正邪道场刷新对手"/>
    AT_BWARENA_TAKE_SCORE_REWARD        = 261     --="正邪道场领取积分奖励"/>
    AT_BWARENA_BUY_TIMES                = 262     --="正邪道场购买次数"/>
    AT_RARE_BOOK_PUSH                   = 263     --="藏书道具存到书袋"/>
    AT_RARE_BOOK_POP                    = 264     --="书袋中取出藏书"/>
    AT_RARE_BOOK_UNLOCK                 = 265     --="解锁藏书"/>
    AT_RARE_BOOK_UPLVL                  = 266     --="藏书升级"/>
    AT_GRASP_IMPL                       = 267     --="参悟"/>
    AT_GRASP_RESET                      = 268     --="参悟CD重置"/>
    AT_CLAN_PRODUCE                     = 269     --="宗门生产"/>
    AT_ROLE_MEMEBER_USE_VIE             = 270     --="帮派成员消耗体力"/>
    AT_ACCELERATE_UPGRADE_COOLING       = 271     --="加快帮派升级冷却"/>
    AT_ADD_SECT_AURA_EXP                = 272     --="捐献帮派技能道具"/>
    AT_TAKE_WORSHIP_REWARD              = 273     --="获取膜拜奖励"/>
    AT_TAKE_PET_TASK_REWARD             = 274     --="获取随从任务奖励"/>
    AT_TAKE_BETA_ACTIVITY_REWARD        = 275     --="获取封测活动奖励"/>
    AT_USE_ITEM_MONTHLYCARD             = 276     --="使用月卡"/>
    AT_USE_ITEM_VIPCARD                 = 277     --="使用VIP体验卡"/>
    AT_TAKE_BRANCH_TASK_REWARD 		   = 278 	--="获取支线任务奖励"/>
    AT_CLIMB_TOWER_BUY_TIMES 		   = 279 	--="爬塔活动购买次数"/>
    AT_START_CLIMB_TOWER_COPY 		   = 280 	--="爬塔活动进入副本"/>
    AT_USER_ITEM_TOWER_FAME 			   = 281 	--="使用获取爬塔声望道具"/>
    AT_TAKE_TOWER_FAME_REWARD 		   = 282 	--="领取声望升级奖励"/>
    AT_REFRESH_SECT_DELIVER             = 283     --="刷新帮派运镖任务列表"/>
    AT_SECT_DELIVER_PROTECT             = 284     --="帮派运镖投保"/>
    AT_SECT_DELIVER_BEGIN               = 285     --="开始帮派运镖"/>
    AT_SAVE_WISH_SECT_DELIVER           = 286     --="帮派运镖祝福保存"/>
    AT_TAKE_SECRET_AREA_REWARD 		   = 287 	--="领取秘境任务奖励"/>
    AT_SWEEP_TOWER_MAP 				   = 288 	--="扫荡爬塔副本"/>
    AT_FINISH_SECT_DELIVER              = 289     --="领取帮派运镖奖励"/>
    AT_MERGE_BAG                        = 290     --="背包合并"/>
    AT_ROB_SUCCESS                      = 291     --="获取劫镖奖励"/>
    AT_USE_ITEM_FEAT_ADDER              = 292     --="使用增加武勋道具"/>
    AT_USE_ITEM_SKILL                   = 293     --="使用技能道具"/>
    AT_USE_ITEM_SKILL_FAIL              = 294     --="使用技能道具失败"/>
    AT_REMAIN_ACTIVITY_REWARD           = 295     --="领取七日留存奖励"/>
    AT_USE_ITEM_LETTER                  = 296     --="使用信件"/>
    AT_PIECE_COMPOSE                    = 297     --="碎片合成"/>
    AT_ROLE_RENAME                      = 298     --="角色改名"/>
    AT_TAKE_PET_LIFE_TASK_REWARD 	   = 299 	--="获取随从身世任务奖励"/>
    AT_ADD_MESSAGE_BOARD 	           = 300 	--="发布留言板"/>
    AT_TAKE_DAILY_PAY_GIFT_REWARD 	   = 301 	--="获取每日储值奖励"/>
    AT_TAKE_SCHEDULE_REWARD             = 302     --="获取日程表奖励"/>
    AT_UNLOCK_ARMOR_TYPE                = 303     --="解锁内甲类型"/>
    AT_USE_ITEM_EVIL_VALUE 			   = 304 	--="使用善恶值道具"/>
    AT_ARMOR_UPRANK                     = 305     --="内甲升阶"/>
    AT_ARMOR_LEVEL_UP                   = 306     --="内甲升级"/>
    AT_PUSH_RUNE_TO_RUNE_BAG            = 307     --="符文存入符文包"/>
    AT_POP_RUNE_TO_BAG                  = 308     --="符文取回背包"/>
    AT_ARMOR_RESET_TALENT               = 309     --="内甲重置天赋"/>
    AT_SOLT_GROUP_UNLOCK                = 310     --="内甲符文页解锁"/>
    AT_RUNE_WISH                        = 311     --="符文祝福"/>
    AT_WAREHOUSE_SAVE                   = 312     --="存入仓库"/>
    AT_WAREHOUSE_TAKE                   = 313     --="取出仓库"/>
    AT_MARRIAGE                         = 314     --="结婚"/>
    AT_DIVORCE                          = 315     --="离婚"/>
    AT_ITEM_EXCHANGE                    = 316     --="道具兑换"/>
    AT_MARRIAGE_SKILL_LEVEL_UP          = 317     --="结婚技能升级"/>
    AT_EXBAND_WAREHOUSE                 = 318     --="拓展仓库"/>
    AT_OPEN_SECT_GROUP_MAP              = 319     --="开启帮派团本"/>
    AT_UP_LEVEL_HORSE_SKILL             = 320     --="坐骑技能升级"/>
    AT_WEAPON_SKILL_LEVEL_UP            = 321     --="神兵技能升级"/>
    AT_WEAPON_TALENT_POINT_BUY          = 322     --="神兵天赋点购买"/>
    AT_WEAPON_TALENT_POINT_RESET        = 323     --="神兵天赋点重置"/>
    AT_SNATCH_RED_ENEVLOPE   	       = 324     --="抢红包"/>
    AT_PLAY_FIREWORK 				   = 325 	--="燃放烟花"/>
    AT_TAKE_MRGSERIES_TASK_REWARD       = 326     --="领取姻缘系列任务奖励"/>
    AT_TAKE_MRGLOOP_TASK_REWARD         = 327     --="领取姻缘环任务奖励"/>
    AT_SEND_GIFT                        = 328     --="发送礼物"/>
    AT_GET_GIFT                         = 329     --="接受礼物"/>
    AT_USE_ITEM_PROP_STRENGTH           = 330     --="使用属性强化道具"/>
    AT_FAME_UPGRADE     				   = 331     --="名望晋级"/>
    AT_FAME_TAKE_REWARD   			   = 332     --="名望领奖"/>
    AT_PET_SKILL_LEVEL_UP   			   = 333     --="随从技能升级"/>
    AT_WEAPON_USKILL_OPEN   			   = 334     --="神兵特技启动"/>
    AT_EQUIP_REFINE   			       = 335     --="装备精炼"/>
    AT_PET_SPIRIT_LVLUP				   = 336	--"随从武库心法升级"
    AT_PET_SPIRIT_LEARN				   = 337	--"随从心法重修"
    AT_BUY_OFFLINE_FUNC_POINT		   = 338	--="购买挂机精灵点"/>
    AT_TITLE_UNLOCKSLOT				   = 339	--"解锁称号槽"
    AT_USE_ITEM_OFFLINE_FUNC_POINT	   = 340	--"使用修炼点道具"
    AT_BUY_GAMBLE_SHOP_GOOGS            = 342	--"武勋商店购买商品"
    AT_USER_REFRESH_GAMBLE_SHOP         = 343 	--"刷新武勋商店"
    AT_TRANSFER_POINT_BUY               = 348	--购买乾坤点
    AT_TRANSFER_POINT_RESET             = 349	-- 重置乾坤点
    AT_TELEPORT_STELE                   = 352 	--地图传送到太玄碑文
    AT_UP_DEMON_FLOOR				   = 354 	--伏魔洞进入下一层
    AT_BUY_LEVEL_UP_REWARD              = 355 	--购买升级特惠活动奖励
    AT_LVLUP_TRANSFER_POINT			   = 363	--乾坤点升级
    AT_NPC_TRANSFER                     = 364 	--NPC传送
    AT_BUY_WIZARD_PET_TIME		       = 365	--="购买休闲宠物时间"/>
    AT_MAKE_LEGEND_COST		     	   = 368	--"传世装备打造
    AT_MAKE_LEGEND_SAVE	     	 	   = 369    --传世装备属性保存
    AT_MAKE_LEGEND_QUIT		     	   = 370	--传世装备属性舍弃
    AT_NPC_PRAY                         = 371    --祈福活动
    AT_UNLOCK_PRIVATE_WAREHOUSE		   = 378	--解锁私人仓库
    AT_PRODUCE_FUSION                   = 379    --"炼化炉炼化道具"
    AT_HEIRLOOM_STRENGTH				   = 380    --"神器精炼"
    AT_USE_ADD_VIPEXP_ITEM              = 384    --"使用VIP经验增加道具"
    AT_USE_ADD_PRODUCE_SPLITSP_ITEM     = 385    --"使用生产能量增加道具"
    AT_MULPLAY_LUCKYROLL                = 386    --"连续玩转盘奖励 (上面还有个单次次转盘)"/>
    AT_SEAL_DISPELLING                  = 387    -- 魂玉解封封印
    AT_REST_ACCELERATE                  = 388    -- 魂玉加速温养
    AT_ACT_FUSION_FURNACE               = 389    --"启动炼化炉"/>
    AT_WATER_EXPTREE                    = 390    -- 经验果树浇水
    AT_GEM_BLESS	                       = 393    -- 宝石祝福开启
    AT_TAKE_LUCKY_GIFT_REWARD           = 395    --"领取新登录活动奖励"
    AT_CREATE_FIGHT_GROUP               = 396    --创建分堂
    AT_RENAME_FIGHT_GROUP               = 397    --分堂改名
    AT_FASHION_ENHANCE                  = 398    --"时装精纺"/>
    AT_UNLOCK_HEADBORDER                = 403    --"解锁头像边框"/>
    AT_PET_RACE_VOTE                    = 415     -- 宠物赛跑投票
    AT_PET_RACE_SLOWDOWN                = 417     -- 宠物赛跑减速

    AT_SMASH_GOLDENEGG                  = 419     --热血夺宝砸金蛋
    AT_REFRESH_GOLDENEGG                = 420     --热血夺宝刷新
    AT_SPRING_BUFF_SERVER 			   = 421  --温泉世界祝福
    AT_SPRING_BUFF_SECT                 = 422  --温泉帮派祝福
    AT_SPRING_USE_DOUBLEACT			   = 423  --温泉使用双人动作
    AT_FRAGMENT_RECYCLE                 = 424  --碎片回收
    AT_USE_ITEM_BUFF_DRUG               = 425  --使用BUFF药
    AT_UNLOCK_EMOJI					   = 426  --解锁表情包
    AT_WEAPON_SOUL_PART_LVL_UP          = 434   --武魂方位升级
    AT_WEAPON_SOUL_GRADE_UP             = 435   --武魂升阶
    AT_WEAPON_SOUL_UNLOCK_SHOW          = 436   --武魂解锁形象
	AT_USE_ITEM_WEAPON_COIN_ADDER		= 437 	--使用加武运道具

	AT_TRIPOD_BUY_TIMES                 = 438   --神木鼎购买次数
	AT_TRIPOD_MERGE                     = 439   --神木鼎炼化
    AT_ACTIVE_QILING_POINT              = 440   -- 激活器灵节点
    AT_QILING_UP_RANK                   = 441   -- 器灵升阶
    AT_QILING_SKILL_UP_LEVEL            = 442   -- 器灵技能升级
    AT_NATIONAL_OIL                     = 444   -- 国庆活动加油
	AT_DICE_EXCHANGE                    = 455   -- 大富翁兑换
	AT_WEAPON_SOUL_PART_RESET			= 447	--武魂方位重置
	AT_WEAPON_SOUL_PART_SAVE_RESET		= 448	--武魂方位重置保存
	AT_WEAPON_SOUL_QUICK_ACTIVATE		= 449	--武魂星耀快速激活
	AT_CALL_BOSS						= 454   -- 召唤BOSS
	AT_SEND_SECT_RED_PACK				= 456	-- 帮派发红包
    AT_BUY_CYCLE_FUND                   = 458   -- 购买循环基金
	AT_PET_AWAKE_TASK_SUBMIT_ITEM		= 465	-- 佣兵觉醒任务提交道具
    AT_ROLE_USE_CHAT_BOX_ITEM			= 471   -- 聊天框
    AT_BUY_ROBBER_MONSTER               = 473   -- 刷新江洋大盗次数
	AT_BLACK_MARKET_PRICE 				= 474   -- 拍卖行竞拍消耗元宝
	AT_TELEPORT_SPAWN_MONSTER			= 476	-- 传送随机刷怪消耗道具
	AT_TELEPORT_ROBBER_MONSTER			= 479	-- 传送到江洋大盗
    AT_BREAK_LEVLE_DONATE               = 480	-- 打破封印等级捐献
	AT_REFRESH_HOLE_BUFF				= 481	-- 重置脉象
	AT_BREAK_HOLE						= 482	-- 冲穴
	AT_POTENTIAL_UPLEVEL				= 483	-- 潜能升级
	AT_CREATE_FIGHT_TEAM				= 484   -- 创建武道会战队
	AT_PET_RENAME						= 489 	-- 宠物重命名
	AT_HORSE_BOOK_PUSH                  = 490   -- 骑术书存到书袋
	AT_PET_BOOK_PUSH                    = 491   -- 兽决存到书袋
	AT_HORSE_BOOK_POP                   = 492   -- 书袋中取出骑术书
	AT_PET_BOOK_POP                     = 493   -- 袋中取出兽决
	AT_SIGN_MARRIAGE_CARD				 = 494	-- 点赞消耗
	AT_EQUIP_TRANSFER					= 497	-- 装备转化
	AT_STEED_BREAK                      = 500   -- 坐骑突破
	AT_HORSE_SHOW_FIGHT_ACTIVE			= 501	-- 坐骑皮肤激活骑战
	AT_HORSE_MASTER_ADDEXP				= 502	-- 坐骑马术精通加经验
	AT_HORSE_MASTER_UNLOCK				= 503	-- 坐骑马术精通解锁条目
	AT_WIZARD_WISH_OPERATE              = 504   -- 送宝童子求取
	AT_STAR_SPIRIT_OPERATE 	     		= 506   -- 星魂引星操作
	AT_STAR_SPIRIT_UPRANK 	     		= 507   -- 星魂升阶
	AT_MAIN_STAR_UPLEVEL 	     	 	= 508   -- 星魂主星升级
	AT_MAIN_STAR_REFRESH 	     	 	= 509   -- 星魂主星洗练
	AT_DRAGON_TASK_REFRESH				= 512	-- 龙穴任务刷新
	AT_USE_SHOW_LOVE_ITEM				= 515   -- 使用示爱道具
	AT_HORSE_SPIRIT_UPSTAR				= 517	-- 良驹之灵锤炼
	AT_HORSE_SPIRIT_SKILL_LVLUP			= 518	-- 良驹之灵技能升级
	AT_BUY_OFFLINE_WIZARD_EXP           = 525   -- 购买挂机精灵经验
	AT_START_WIZARD_TRIP				= 529    -- 开始精灵旅行
	AT_MORE_ROLE_DISCOUNT				= 537   -- 拼多多团购购买
	AT_FCBS_Task			 			= 541   --帮派商路
	AT_DIVINATION_COST					= 542	--挂签消耗
	AT_MOODDIARY_GIFT_SEND				= 549	--心情日记送礼消耗
	AT_PIGEON_POST_SEND					= 551	-- 飞鸽传书发消息
	AT_SGS_UP_LVL						= 552 	-- 魂玉附灵升阶
	AT_SGS_UP_EACH_OHER					= 553   -- 魂玉附灵五行相生升阶
	AT_SGS_RESET_ADDPOINT				= 554   -- 魂玉附灵重置加点
	AT_DIARY_DECORATE_ACTIVE			= 555	-- 激活心情日记装饰
	AT_COMMIT_POWER_REP					= 559   -- 势力声望捐赠
	AT_HOMELAND_CREATE					= 561	-- 家园创建
	AT_HOMELAND_UPLEVEL					= 562	-- 家园升级
	AT_HOMELAND_GROUND_UPLEVEL			= 563	-- 家园土地升级
	AT_HOMELAND_POOL_UPLEVEL			= 564	-- 家园池塘升级
	AT_HOMELAND_HARVEST					= 565	-- 家园收获
	AT_HOMELAND_STEAL					= 566	-- 家园偷菜
	AT_WORLD_CUP_CONDUCT_ANTE			= 567 	--世界杯押注
	AT_SEND_WORLD_BLESS					= 569	--世界告白
	AT_THUMB_TACK						= 570	-- 图钉传送
	AT_HOMELAND_RENAME					= 571	-- 家园改名
	AT_HOMELAND_PLANT					= 572	-- 家园种植
	AT_CONDUCT_DONATE				 	= 573	-- 佛诞节捐助
	AT_REWARD_DONANTE				 	= 574	-- 佛诞节领奖活动
	AT_HOMELAND_FISH				 	= 575	-- 家园钓鱼
	AT_USE_ITEM_HOMELAND_EQUIP		 	= 576	-- 使用家园装备
	AT_SOULSPELL_PROPS					= 579	-- 心决 修心
	AT_SOULSPELL_BREAK					= 580 	-- 心决 突破
	AT_UNLOCK_HOMELAND_WAREHOUSE	 	= 581   -- 解锁家园仓库
    AT_EXBAND_HOMELAND_WAREHOUSE		= 582	-- 扩展家园仓库
    AT_HOMELAND_WAREHOUSE_SAVE			= 583	-- 存入家园仓库
   	AT_HOMELAND_WAREHOUSE_TAKE			= 584	-- 取出家园仓库
    AT_UNLOCK_HORSESPIRIT_SHOWS			= 585	-- 解锁良驹之灵追加形象
	AT_MAKE_HIDEWEAPON					= 588	-- 合成暗器
	AT_HIDEWEAPON_UPRANK				= 589	-- 暗器升品
	AT_HIDEWEAPON_LEVEL_UP				= 590	-- 暗器升级
	AT_HIDEWEAPON_PSKILL_LEVEL_UP		= 591	-- 暗器被动技能升级
	AT_HIDEWEAPON_ASKILL_LEVEL_UP		= 592	-- 暗器主动技能升级
	AT_EQUIP_BREAK						= 596   -- 装备突破
	AT_USE_ITEM_GBCOIN_BAG				= 600	-- 正义徽章道具
	AT_DISCOUNT_BUY_POWER_GIFT			= 601	-- 购买充值获得折扣礼包活动购买
	AT_HIDEWEAPON_UNLOCK_SKIN			= 603	-- 暗器解锁皮肤
	AT_EQUIP_TEMPER						= 604	-- 装备锤炼
	AT_WEAPON_AWAKE						= 615   -- 神兵觉醒
	AT_WEAPON_AWAKE_SKILL_LVLUP			= 616 	-- 神兵觉醒技能升级
	AT_HOUSE_SKIN_UNLOCK				= 621	-- 房屋皮肤解锁
	AT_SECT_TASK_QUICK_FINISH_CB		= 640   -- 帮派任务快速完成
	AT_DRAGON_HOLE_QUICK_FINISH_TASK	= 641   -- 龙穴快速完成任务
	AT_WEAPON_TASK_QUICK_FINISH_TASK	= 642	-- 神兵快速完成任务
	AT_JOIN_SWORN						= 644	-- 加入结拜
	AT_SWORN_CHANGE_PREFIX				= 645	-- 结拜修改前缀消耗
	AT_SWORN_CHANGE_SUFFIX				= 646	-- 结拜修改后缀消耗
	AT_USE_SWORN_GIFT_ITEM				= 648	-- 使用结拜礼物
	AT_SKILL_FORMULA_UP_RANK			= 652   -- 武诀升阶
	AT_SKILL_FORMULA_SKILL_LEVEL_UP		= 653  	-- 武诀技能升级
	AT_USE_SKILL_FORMULA_EXP_ITEM		= 654	-- 使用武诀经验道具
	AT_USE_BAGUA_SACRIFACE				= 655	-- 八卦祭品拆分
	AT_USE_BAGUA_SACRIFACE_COMPOUND		= 656	-- 八卦祭品合成
	AT_STEED_EQUIP_WEAR					= 663   -- 骑战装备穿装备
	AT_STEED_EQUIP_DOWN		            = 664	-- 骑战装备脱装备
	AT_STEED_EQUIP_SUIT					= 665	-- 骑战装备激活套装
	AT_STEED_EQUIP_CREATE				= 666   -- 骑战装备制造
	AT_STEED_EQUIP_DESTORY				= 667	-- 骑战装备熔炼
	AT_USE_ITEM_FORGE_ENERGY			= 670  -- 骑战装备熔炉精华道具
	AT_USE_ITEM_GEM_EXCHANGE			= 671  -- 宝石转化
	AT_USE_SOARING_EXP_ITEMS			= 726	-- 使用飞升经验道具
	AT_ARRAY_STONE_PRAYER				= 734	-- 秘祝系统祈言
	AT_ARRAY_STONE_UNLOCK_HOLE			= 735	-- 秘祝系统解锁新孔位
	AT_ARRAY_STONE_USE_ENERGY_ITEM		= 739	-- 秘祝系统使用密文能量道具
	AT_ARRAY_STONE_DES_CIPHERTEXT		= 740	-- 秘祝系统回收密文
	AT_USE_WAR_ZONE_CARD_ITEM			= 741   -- 使用战区卡片道具
	
local ItemBuy = {
		AT_BUY_SHOP_GOOGS = true,
		AT_BUY_COIN		  = true,
		AT_BUY_VIT		  = true,
		AT_BUY_MALL_GOODS = true,
		AT_STROE_BUY	  = true,
	}

function i3k_dataeye_itemtype(id)
	return ItemBuy[id]
end


g_FLYING_OFFSET = 256






--神秘卡片
g_PERSONAL_WAR_ZONE_CARD_STATE 		= 1 --个人卡片
g_FACTION_WAR_ZONE_CARD_STATE 		= 2 --帮派卡片
g_LOG_WAR_ZONE_CARD_STATE			= 3 --卡片日志

--神秘卡片操作类型 
g_WAR_ZONE_CARD_ACTIVATION			= 1 --激活
g_WAR_ZONE_CARD_GIVE_UP 			= 2 --放弃
g_WAR_ZONE_CARD_FACTION_DONATE		= 3 --帮派捐献

--神秘卡片日志类型
g_WAR_ZONE_CARD_PERSONAL_LOG		= 1 --自己日志
g_WAR_ZONE_CARD_WAR_ZONE_LOG		= 2 --战区日志
--神秘卡片事件类型
g_WAR_ZONE_CARD_EVENT_TYPE_GET_MONSTERID 	= 1 --击败怪物获得
g_WAR_ZONE_CARD_EVENT_TYPE_GET_PLAYER		= 2 --击败玩家获得
g_WAR_ZONE_CARD_EVENT_TYPE_PLAYER 			= 3 --被玩家击败失去
g_WAR_ZONE_CARD_EVENT_TYPE_RECOVERY			= 4 --系统回收
g_WAR_ZONE_CARD_EVENT_TYPE_PLAYER_MONSTERID = 5 --玩家击败怪物获得
g_WAR_ZONE_CARD_EVENT_TYPE_PLAYER_PLAYER	= 6	--玩家击败玩家获得
--卡片类型
g_WAR_ZONE_CARD_EFECT_TYPE_EXP    			= 1 --加经验
g_WAR_ZONE_CARD_EFECT_TYPE_WEAPON 			= 2 --神兵增强
g_WAR_ZONE_CARD_EFECT_TYPE_DEVIL			= 3 -- 魔王伤害增加
g_WAR_ZONE_CARD_EFECT_TYPE_PROP_ADD			= 4 -- 属性增强 
g_WAR_ZONE_CARD_EFECT_TYPE_VIP_ADD			= 5 -- vip卡体验
g_WAR_ZONE_CARD_EFECT_TYPE_OFFLINE_EXP		= 6 -- 离线经验
g_WAR_ZONE_CARD_EFECT_TYPE_REWARD			= 7 -- 宝箱
--buff属性增加类型
g_WAR_ZONE_CARD_PROP_FIXED					= 1 -- 固定值
--打开龙魂币充值页签
g_CHANNEL_DIAMOD_TYPE						= 1 --元宝
g_CHANNEL_LONGHUNBI_TYPE					= 2 --龙魂币
--特殊购买
g_BUYCOLLECTCOIN_TYPE	=	1	--购买纪念金币
--添加挂载类型
g_ADD_LINK_CHILD_RIDE = 1 --坐骑挂载
g_ADD_LINK_CHILD_ESCORT = 2 --运镖挂载
-----------------------------------------

--绝技id
SKILL_SHOW_TYPE_JUEJI = 36
--骑术id
SKILL_SHOW_TYPE_QISHU = 45
--兽决id
SKILL_SHOW_TYPE_SHOUJUE = 46

FIRST_CLEAR_REWARD_TOURNAMENT = 1
FIRST_CLEAR_REWARD_SECT = 2
FIRST_CLEAR_REWARD_CITY = 3
--春节灯券跳转
OPEN_SPRING_ROLL_MAIN = 1
OPEN_SPRING_ROLL_BATTLE = 2
OPEN_SPRING_ROLL_QUIZ = 3
OPEN_SPRING_ROLL_BUY = 4
SPRING_ROLL_TYPE_BATTLE = 1
SPRING_ROLL_TYPE_QUIZ = 2
SPRING_ROLL_TYPE_BUY = 3

-- global function
function i3k_enum(tbl, index)
    local enumtbl = { };
    local enumindex = index or 0;
    for i, v in ipairs(tbl) do
        enumtbl[v] = enumindex + i;
    end

    return enumtbl;
end

function i3k_table_length(tbl)
    local len = 0;
    for i, v in pairs(tbl) do
        len = len + 1;
    end

    return len;
end

function i3k_truncate_string(s, n)
	local _cc = 1;
	local _cb = string.byte(s, n);
	if _cb == 91 then --'['
		local _ln = string.len(s);
		for k = n + 1, _ln do
			_cc = _cc + 1;

			local _cb1 = string.byte(s, k);
			if _cb1 == 93 then --']'
				break;
			end
		end
	else
		if _cb > 0 and _cb <= 127 then
			_cc = 1;
		elseif _cb >=192 and _cb < 223 then
			_cc = 2;
		elseif _cb >= 224 and _cb < 239 then
			_cc = 3;
		elseif _cb >= 240 and _cb <= 247 then
			_cc = 4;
		end
	end

	return string.sub(s, 1, n + _cc - 1), n + _cc - 1;
end


function i3k_format_pos_ignore_z(pos)
	return "(" .. pos.x .. ", " .. pos.y .. ")";
end


function i3k_format_pos(pos)
	return "(" .. pos.x .. ", " .. pos.y .. ", " .. pos.z .. ")";
end

function i3k_format_bool(val)
	if val then
		return "true";
	end

	return "false";
end

function i3k_clone(obj)
	local lookup_table = { };
	local function _copy(obj)
		if type(obj) ~= "table" then
			return obj;
		elseif lookup_table[obj] then
			return lookup_table[obj];
		end

		local new_table = { };
		lookup_table[obj] = new_table;
		for k, v in pairs(obj) do
			new_table[_copy(k)] = _copy(v);
		end

		return setmetatable(new_table, getmetatable(obj));
	end

	return _copy(obj);
end

local gEntityIdx = 99999;
function i3k_gen_entity_guid()
	local gid = gEntityIdx;

	gEntityIdx = (gEntityIdx + 1) % 99999999;

	return gid;
end

function i3k_gen_entity_cname(etype)
	local enames =
	{
		[eET_Player]		= "i3k_hero",
		[eET_Monster]		= "i3k_monster",
		[eET_Trap]			= "i3k_entity_trap",
		[eET_Pet]			= "i3k_pet",
		[eET_Mercenary]		= "i3k_mercenary",
		[eET_Car]			= "i3k_escort_car",
		[eET_NPC]			= "i3k_npc",
		[eET_ResourcePoint]	= "i3k_entity_resourcepoint",
		[eET_TransferPoint]	= "i3k_entity_transferpoint",
		[eET_MapBuff]		= "i3k_mapbuff",
		[eET_Skill]			= "i3k_skill_entity",
		[eET_MarryCruise]	= "i3k_marry_cruise",
        [eET_PetRace]       = "i3k_pet_race",
		[eET_ShowLoveItem]  = "i3k_show_love_item",
		[eET_Diglett]		= "i3k_diglett",
		[eET_Summoned]		= "i3k_summoneds",
		[eET_Crop]			= "i3k_crop",
		[eET_Mount]			= "i3k_entity_mount",
		[eET_Floor]			= "i3k_floor",
		[eET_Furniture]		= "i3k_furniture",
		[eET_WallFurniture] = "i3k_wall_furniture",
		[eET_CarpetFurniture]= "i3k_carpet_furniture",
		[eET_Common]			= "i3k_common",
		[eET_HouseSkin]		= "i3k_house_skin",
		[eET_HomePet]		= "i3k_home_pet",
		[eET_DisposableNPC]		= "i3k_npc_disposable",
		[eET_Capture]		= "i3k_capture",
		[eET_CatchSpirit]	= "i3k_catch_spirit",
		[eET_GhostFragment] = "i3k_ghost_fragment",
	};

	return enames[etype] or "(none)";
end

function i3k_gen_entity_guid_new(etype, gid)
	return etype .. "|" .. gid;
end

local g_i3k_attack_effect_guid = 1;
function i3k_gen_attack_effect_guid()
	local gid = g_i3k_attack_effect_guid;

	g_i3k_attack_effect_guid = (g_i3k_attack_effect_guid + 1) % 99999999;

	return gid;
end

local g_i3k_buff_guid = 1;
function i3k_gen_buff_guid()
	local gid = g_i3k_buff_guid;

	g_i3k_buff_guid = (g_i3k_buff_guid + 1) % 99999999;

	return gid;
end

function i3k_get_utf8_len(str)
	local _, count = string.gsub(str, "[^\128-\193]", "");

	return count;
end

-- 将字符串转换为数组
function i3k_get_split_str_list(str)
	local tab = {}
	for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do
		table.insert(tab, uchar)
	end
	return tab
end

-- 字符替换
--	@function: 屏蔽非法字符替换为"*"
	-- str 		校验目标字符串
	-- invalidCfg		非法字符配置 数据结构必须为set
	-- repl		替换字符 默认为 "*"
function i3k_get_replace_invalid_string(str, invalidCfg, repl)
	repl = repl or "*"
	local changeStr = i3k_clone(str)
	local spiltStr = i3k_get_split_str_list(changeStr)
	for _, v in ipairs(spiltStr) do
		if invalidCfg[v] then
			changeStr = string.gsub(changeStr, v, repl)
		end
	end
	return changeStr
end

function i3k_set_skilleffectfilter(isblock)
	g_i3k_mmengine:EnableEffectRender(not isblock);
	--[[
	if isblock then
		g_i3k_mmengine:SetEffectPriority(EPP_0);
	else
		g_i3k_mmengine:SetEffectPriority(EPP_3);
	end
	]]
end

g_DROPDOWNLIST_DEFAULT = 1
g_DROPDOWNLIST_DAILYTASK = 2
g_DROPDOWNLIST_HOMELAND_STRUCTURE = 3
g_DROPDOWNLIST_STRENGTHEN_SELF_IMPROVE = 4
g_DROPDOWNLIST_STRENGTHEN_SELF_OTHER = 5
g_DROPDOWNLIST_STRENGTHEN_SELF_DETAIL = 6

--获取下拉列表中的widget资源脚本
function i3k_getDropDownWidgetsMap(id)
	local dropDownListWidgetsMap = 
	{
		[g_DROPDOWNLIST_DEFAULT] = {"ui/widgets/rxphblbt", "ui/widgets/rxphblbt2"},
		[g_DROPDOWNLIST_DAILYTASK] = {"ui/widgets/rchqyt1", "ui/widgets/rchqyt2"},
		[g_DROPDOWNLIST_HOMELAND_STRUCTURE] = {"ui/widgets/jiayuanjzt", "ui/widgets/jiayuanjzt3"},
		[g_DROPDOWNLIST_STRENGTHEN_SELF_IMPROVE] = {"ui/widgets/wybq2lbt1", "ui/widgets/wybq2lbt2"},
		[g_DROPDOWNLIST_STRENGTHEN_SELF_OTHER] = {"ui/widgets/wybq2t3"},
		[g_DROPDOWNLIST_STRENGTHEN_SELF_DETAIL] = {"ui/widgets/wybq2t1", "ui/widgets/wybq2t2"},
	}
	return dropDownListWidgetsMap[id]
end


--我要变强
g_WANT_STRONG = 1
--类别为2的其他项，如我要升级，我要装备，我要材料等
g_WANT_OTHER = 2
--我要变强子类
g_WANT_STRONG_DETAIL = 3

function g_i3k_get_commend_mission()
	local level = g_i3k_game_context:GetLevel()
	for k,v in ipairs(i3k_db_want_improve_recommendFuncID) do
		if level >= v.levelmin and level <= v.levelmax then
			return v.recommendFuncIDs
		end
	end
	return nil
end

--不加锁的特殊情况
g_DO_NOT_SHOW_LOCK ={
	[g_BASE_ITEM_EQUIP_ENERGY] = true,
	[g_BASE_ITEM_GEM_ENERGY] = true,
	[g_BASE_ITEM_BOOK_ENERGY] = true,
	[g_BASE_ITEM_VIT] = true,
	[g_BASE_ITEM_EXP] = true,
	[g_BASE_ITEM_VIP] = true,
	[g_BASE_ITEM_FEISHENG_EXP] = true,
	[g_BASE_ITEM_DIVIDEND] = true,
}








--------------------------------------------------------------------------------
--获取红色值
function g_i3k_get_red_color()
	return g_COLOR_VALUE_RED
end

--获取白色值
function g_i3k_get_white_color()
	return g_COLOR_VALUE_WHITE
end

--获取绿色值
function g_i3k_get_green_color()
	return g_COLOR_VALUE_GREEN
end

--获取蓝色值
function g_i3k_get_blue_color()
	return g_COLOR_VALUE_BLUE
end

--获取紫色值
function g_i3k_get_purple_color()
	return g_COLOR_VALUE_PURPLE
end

--获取橙色值
function g_i3k_get_orange_color()
	return g_COLOR_VALUE_ORANGE
end

--获取灰色值
function g_i3k_get_grey_color()
	return g_COLOR_VALUE_GREY
end

local i3k_rank_colors_tbl =
{
	[g_RANK_VALUE_WHITE] = g_i3k_get_white_color,
	[g_RANK_VALUE_GREEN] = g_i3k_get_green_color,
	[g_RANK_VALUE_BLUE] = g_i3k_get_blue_color,
	[g_RANK_VALUE_PURPLE] = g_i3k_get_purple_color,
	[g_RANK_VALUE_ORANGE] = g_i3k_get_orange_color,
	[g_RANK_VALUE_MAX] = g_i3k_get_red_color,
}
--根据道具品级得到道具名字颜色
function g_i3k_get_color_by_rank(rank)
	local func = i3k_rank_colors_tbl[rank]
	return func and func() or g_i3k_get_grey_color()
end

--获取高亮红色值
function g_i3k_get_hl_red_color()
	return g_COLOR_VALUE_HL_RED
end

--获取高亮绿色值
function g_i3k_get_hl_green_color()
	return g_COLOR_VALUE_HL_GREEN
end

local i3k_rank_icon_frames_tbl =
{
	[g_RANK_VALUE_WHITE] = 101,
	[g_RANK_VALUE_GREEN] = 102,
	[g_RANK_VALUE_BLUE] = 103,
	[g_RANK_VALUE_PURPLE] = 104,
	[g_RANK_VALUE_ORANGE] = 105,
}
local i3k_fly_rank_icon_frames_tbl =
{
	[g_RANK_VALUE_WHITE] = 8488,
	[g_RANK_VALUE_GREEN] = 8489,
	[g_RANK_VALUE_BLUE] = 8490,
	[g_RANK_VALUE_PURPLE] = 8491,
	[g_RANK_VALUE_ORANGE] = 8492,
}
--根据道具品级得到对应品级图标框
function g_i3k_get_icon_frame_path_by_rank(rank, isFlyEquip)
	local iconId = i3k_rank_icon_frames_tbl[rank]
	if isFlyEquip then
		iconId = i3k_fly_rank_icon_frames_tbl[rank]
	end
	return g_i3k_db.i3k_db_get_icon_path(iconId or 106)
end

local i3k_pos_icon_equip_shading = {
	[eEquipWeapon]	= 399,
	[eEquipHand]	= 400,
	[eEquipClothes]	= 401,
	[eEquipShoes]	= 402,
	[eEquipHead]	= 403,
	[eEquipRing]	= 404,
	[eEquipSymbol] = 414,
	[eEquipArmor] = 415,
	[eEquipFlying] = 399,
	[eEquipFlyHand] 	= 400,
	[eEquipFlyClothes] = 401,
	[eEquipFlyShoes] 	= 402,
	[eEquipFlyHead] 	= 403,
	[eEquipFlyRing] 	= 404,
}
--设置背包左侧装备底框
function g_i3k_get_icon_frame_path_by_pos(pos)
	local iconId = i3k_pos_icon_equip_shading[pos]
	return g_i3k_db.i3k_db_get_icon_path(iconId or 399)
end

local i3k_pos_icon_pet_equip_shading = {
	[g_Equip_Shading_One]	= 7818,
	[g_Equip_Shading_Two]	= 7816,
	[g_Equip_Shading_Three]	= 7817,
	[g_Equip_Shading_Four]	= 7815,
}

--设置宠物背包左侧装备底框
function g_i3k_get_pet_equip_icon_frame_path_by_pos(pos)
	local iconId = i3k_pos_icon_pet_equip_shading[pos]
	return g_i3k_db.i3k_db_get_icon_path(iconId or 7814)
end

local i3k_pos_icon_steed_equip_shading = {
	[g_Equip_Shading_One]	= 399,
	[g_Equip_Shading_Two]	= 400,
	[g_Equip_Shading_Three]	= 401,
	[g_Equip_Shading_Four]	= 402,
	[g_Equip_Shading_Five]	= 403,
	[g_Equip_Shading_Six]	= 404,
}
--设置骑战装备底框
function g_i3k_get_steed_equip_icon_frame_path_by_pos(pos)
	local iconId = i3k_pos_icon_steed_equip_shading[pos]
	return g_i3k_db.i3k_db_get_icon_path(iconId or 399)
end
--获取条件颜色(用于 xxx/xxx 道具数量显示, 一般条件为True则为绿色，条件为Flase则为红色)
function g_i3k_get_cond_color(condition)
	return condition and g_COLOR_VALUE_GREEN or g_COLOR_VALUE_RED
end

--获取条件高亮颜色(用于 xxx/xxx 道具数量显示, 一般条件为True则为绿色，条件为Flase则为红色)
function g_i3k_get_cond_hl_color(condition)
	return condition and g_COLOR_VALUE_HL_GREEN or g_COLOR_VALUE_HL_RED
end

--获取任务的条件颜色，红色或绿色，亮色（根据UI需求）
function g_i3k_get_task_cond_color(condition)
	return condition and "hlgreen" or "hlred"
end

local i3k_color_name_map_tbl =
{
	[g_COLOR_VALUE_RED] = "red",
	[g_COLOR_VALUE_WHITE] = "white",
	[g_COLOR_VALUE_GREEN] = "green",
	[g_COLOR_VALUE_BLUE] = "blue",
	[g_COLOR_VALUE_PURPLE] = "purple",
	[g_COLOR_VALUE_ORANGE] = "orange",
	[g_COLOR_VALUE_GREY] = "grey"
}
--生成颜色修饰的富文本
function g_i3k_make_color_string(str, color, isLight)
	local colorname = i3k_color_name_map_tbl[color] or color
	if isLight then
		return "<c=" .. colorname .. ">"..str.."</c>"
	end
	return "<c=q" .. colorname .. ">"..str.."</c>"
end

--获取背包物品占用背包格子数目
function g_i3k_get_use_bag_cell_size(count, stack_max)
	return (stack_max > 0 and math.floor((count + stack_max - 1)/stack_max) or 0)
end

--获取道具销毁物品占用背包格子数目
function g_i3k_get_destroy_bag_cell_size(count, stack_max)
	return (stack_max > 0 and math.floor((count + stack_max - 1)/stack_max) or 1)
end

--从协议数据DBEquip获取客户端equip数据table
function g_i3k_get_equip_from_bean(beanEquip)
	return {equip_id = beanEquip.id,
	equip_guid = beanEquip.guid,
	attribute = beanEquip.addValues,
	naijiu = beanEquip.durability,
	refine = beanEquip.refine,
	legends = beanEquip.legends,
	smeltingProps = beanEquip.smeltingProps,
	hammerSkill = beanEquip.hammerSkill,
}
end

--从协议数据vector[DBEquip]获取客户端equip数据table和数组
function g_i3k_get_equips_from_bean(beanEquips)
	local equips = nil
	if beanEquips then
		equips = {}
		for i, e in pairs(beanEquips) do
			local equip = g_i3k_get_equip_from_bean(e)
			table.insert(equips, equip)
		end
	end
	return equips
end

--从equip数据中取id
function g_i3k_get_equip_id(equip)
	return equip.equip_id
end

--从equip数据中取guid
function g_i3k_get_equip_guid(equip)
	return equip.equip_guid
end

--从equip数据中取属性信息
function g_i3k_get_equip_attributes(equip)
	return equip.attribute
end

--从equip数据中取耐久度
function g_i3k_get_equip_durability(equip)
	return equip.naijiu
end

--测试通用物品是否有绑定锁
function g_i3k_common_item_has_binding_icon(id)
	return id > 65536 or id == 1 or id == 2
end



----时间日期相关函数
--获取GMT时间，参数是i3k_game_get_time()返回的和服务器一致的当前时间，或者服务器传送过来的所有其他时间
--os.date()参数使用的时间必须是i3k_game_get_time()或者服务器传送过来的时间，禁止使用os.time
function g_i3k_get_GMTtime(time)
	return time - 3600 * 8
end

--获取日(从1970-1-1开始的日数), 参数为i3k_game_get_time()返回的和服务器一致的当前时间
function g_i3k_get_day(time)
	return math.floor(time/86400)
end

function g_i3k_get_day_offset()
	return math.floor((i3k_game_get_time() - 18000)/86400)
end

function g_i3k_get_day_time_offset(offsetTime)
	return g_i3k_get_day_offset() * 86400 + offsetTime
end

--获取周(从1970-1-1开始的周数)，参数为g_i3l_get_day()返回的日数
function g_i3k_get_week(day)
	return math.floor((day-3)%7)
end

--获取周数(从1970-1-1开始的周数)，参数为g_i3k_get_day()返回的日数
function g_i3k_get_week_count(day)
	return math.floor((day-3)/7)
end
--获取当日时间的绝对值(从1970-1-1开始的到当日时间偏移的秒数), 参数为当日时间相对于0:00:00的偏移秒数
function g_i3k_get_day_time(offsetTime)
	offsetTime = offsetTime or 0
	return g_i3k_get_day(i3k_game_get_time())*86400+offsetTime
end

--获取唯一id
function g_i3k_get_unique_id(username, roleId)
	return username .. "_" .. roleId
end

--根据openid和渠道名生成username
function g_i3k_get_username(openId, channel)
	return string.lower(channel .. "_" .. openId)
end

function g_i3k_get_plat_id_by_channel(channel)
	local s = string.sub(channel, 1, 1)
	if s == "a" then
		return 1
	elseif s == "i" then
		return 0
	end
	return -1
end

function g_i3k_get_channel_name_by_channel(channel)
	return string.sub(channel, 2)
end


----[[
function g_i3k_get_ActDateRange(startTime,endTime)

	return g_i3k_isTimeLessThenOneYearFromNow(endTime) and g_i3k_get_ActDateStr(startTime) .. "-" .. g_i3k_get_ActDateStr(endTime) or "不限时"
end

function g_i3k_isTimeLessThenOneYearFromNow(time)
	--i3k_game_get_time()
	local curtime = i3k_game_get_time()
	return time - curtime < 365*24*3600 and time - curtime > 3*24*3600
end
function g_i3k_get_ActDateStr(time)
	local t = os.date("*t",g_i3k_get_GMTtime(time))
	return string.format("%.2d月%.2d日", t.month, t.day)
end

-- 不做偏移的时间，纯客户端显示时间
function g_i3k_get_YearAndMonthAndDayTime(time)
	local t = os.date("*t",time)
	return string.format("%d年%.2d月%.2d日", t.year, t.month, t.day)
end

function g_i3k_get_MonthAndDayHourAndMinTime(time)
	local t = os.date("*t",time)
	return string.format("%.2d月%.2d日 %.2d:%.2d", t.month, t.day, t.hour, t.min)
end
-- 不做偏移的时间，纯客户端显示时间
function g_i3k_get_commonDateStr(time)
	local t = os.date("*t",time)
	return string.format("%.2d月%.2d日", t.month, t.day)
end
function g_i3k_get_commonDateMonthAndDayStr(time)
	local t = os.date("*t",time)
	return string.format("%d月%d日", t.month, t.day)
end
--转化服务器发送来的时间需要转化，分时区
-- 不做偏移的时间，纯客户端显示时间数字显示,
function g_i3k_get_YearAndMonthAndDayTime_number(time)
	local t = os.date("*t",g_i3k_get_GMTtime(time))
	return string.format("%d.%.2d.%.2d", t.year, t.month, t.day)
end

--不做偏移的时间，纯客户端显示时间
function g_i3k_get_MonthAndDayTime(time)
	local t = os.date("*t",time)
	return string.format("%d月%d日 %.2d:%.2d", t.month, t.day, t.hour, t.min)
end

function g_i3k_get_YearMonthAndDayTime(time)
	time = time - 8 * 3600
	local t = os.date("*t",time)
	return string.format("%d年%d月%d日 %.2d:%.2d", t.year, t.month, t.day, t.hour, t.min)
end
--不做偏移的时间，纯客户端显示时间
function g_i3k_get_HourAndMin(time)
	time = time + (24 - 8) * 3600
	local t = os.date("*t", time)
	return string.format("%.2d:%.2d:%.2d", t.hour, t.min, t.sec)
end

function g_i3k_get_show_time(time)
	local t = os.date("*t",g_i3k_get_GMTtime(time))
	return string.format("%.2d月%.2d日%.2d:%.2d", t.month, t.day, t.hour, t.min)
end

--显示X年X月X日X时X分
function g_i3k_get_YearAndDayAndTime(time)
	local t = os.date("*t",g_i3k_get_GMTtime(time))
	return string.format("%d-%d-%d %d:%d", t.year, t.month, t.day,t.hour,t.min)
end

function g_i3k_get_YearAndDayTime(time)
	local t = os.date("*t",g_i3k_get_GMTtime(time))
	return string.format("%d年%d月%d日", t.year, t.month, t.day)
end

function g_i3k_get_show_short_time(time)
	local t = os.date("*t",g_i3k_get_GMTtime(time))
	return string.format("%.2d:%.2d",t.hour, t.min)
end
--]]

--返回当前年月日
function g_i3k_get_YearAndDayAndTime1(time)
	local t = os.date("*t",g_i3k_get_GMTtime(time))
	return t.year, t.month, t.day
end
function g_i3k_checkIsInDate(startTime, endTime)
    local nowTime = i3k_game_get_time()
    nowTime = nowTime - nowTime%86400
    local gmtTime = g_i3k_get_GMTtime(nowTime)
    return startTime <= gmtTime and endTime >= gmtTime
end
function g_i3k_checkDanceTime(startTime, endTime)
    local nowTime = i3k_game_get_time()
	local gmtTime = g_i3k_get_GMTtime(nowTime)
	print("now " .. nowTime)
	print("gmt "..gmtTime)
	print("sta "..startTime)
	print("end "..endTime)
    return startTime <= gmtTime and gmtTime <= endTime
end

function g_i3k_checkIsInTodayTime(startTime, endTime)
    local nowTime = i3k_game_get_time()%86400
    return startTime <= nowTime and endTime >= nowTime
end

function g_i3k_checkIsInDateByTimeStampTime(startTime, endTime)
    local nowTime = i3k_game_get_time()
    local timeStamp = g_i3k_get_GMTtime(nowTime)
    return startTime <= timeStamp and endTime >= timeStamp
end

--判断时间是否在一段时间段内  时间格式为 yyyy/mm/dd HH:MM:SS
function g_i3k_checkIsInDateByStringTime( startTime, endTime )
    local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
    local startY = string.sub(startTime, 1, 4)
    local startMon = string.sub(startTime, 6, 7)
    local startD = string.sub(startTime, 9, 10)
    local startH = string.sub(startTime, 12, 13)
    local startMin = string.sub(startTime, 15, 16)
    local startS = string.sub(startTime, 18, 29)
    local startTimeStamp = os.time({year = startY, month = startMon, day = startD, hour = startH, min = startMin, sec = startS})
    local endY = string.sub(endTime, 1, 4)
    local endMon = string.sub(endTime, 6, 7)
    local endD = string.sub(endTime, 9, 10)
    local endH = string.sub(endTime, 12, 13)
    local endMin = string.sub(endTime, 15, 16)
    local endS = string.sub(endTime, 18, 29)
    local endTimeStamp = os.time({year = endY, month = endMon, day = endD, hour = endH, min = endMin, sec = endS})
    return startTimeStamp <= timeStamp and endTimeStamp >= timeStamp
end

function g_i3k_get_current_weekday()
    local currtime = i3k_game_get_time()
    return tonumber(os.date("%w",g_i3k_get_GMTtime(currtime)))
end

--参数为8位数的日期，如19901006
function g_i3k_checkIsValidBirthday(time)
	local maxDaysofMonth = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
	if not time then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5390))
		return false
	end
	if string.len(time) < 8 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5391))
		return false
	end
	local year = string.sub(time, 1, 4)
	local month = string.sub(time, 5, 6)
	local day = string.sub(time, 7, 8)
	local endTime = os.date("*t", i3k_db_sworn_system.leastBirth)
	local beginTime = os.date("*t", i3k_db_sworn_system.maxBirth)
	local errTips = i3k_get_string(5392, string.format("%d.%d.%d", beginTime.year, beginTime.month, beginTime.day), string.format("%d.%d.%d", endTime.year, endTime.month, endTime.day))
	if tonumber(year) > endTime.year or tonumber(year) < beginTime.year then
		g_i3k_ui_mgr:PopupTipMessage(errTips)
		return false
	end
	local timeStamp = os.time({year = year, month = month, day = day, hour = 0, min = 0, sec = 0})
	if (not timeStamp) or timeStamp > i3k_db_sworn_system.leastBirth or timeStamp < i3k_db_sworn_system.maxBirth then
		g_i3k_ui_mgr:PopupTipMessage(errTips)
		return false
	end
	if tonumber(month) == 2 then
		local maxDay = 28
		if (tonumber(year) % 100 == 0) and (tonumber(year) % 400 == 0) or (tonumber(year) % 4 == 0) then
			maxDay = 29
		end
		if tonumber(day) > 29 then
			g_i3k_ui_mgr:PopupTipMessage(errTips)
			return false
		end
	else
		if tonumber(month) > 12 or tonumber(month) < 1 then
			g_i3k_ui_mgr:PopupTipMessage(errTips)
			return false
		end
		if tonumber(day) > maxDaysofMonth[tonumber(month)] then
			g_i3k_ui_mgr:PopupTipMessage(errTips)
			return false
		end
	end
	return timeStamp
end
local name_rule_desc = {
	[-1] = "名字格式错误",
	[-2] = "名字不能为空",
	[-3] = "名字长度不符合规则",
}

-- 名字格式匹配规则
function g_i3k_name_rule(name_str, limitLen)
	local len = string.len(name_str)

	if len == 0 then
		return -2,name_rule_desc[-2]
	end

	if tonumber(name_str) then
		return -1,name_rule_desc[-1]
	end

	local len = limitLen or  i3k_db_common.inputlen.factionlen
	local namecount = i3k_get_utf8_len(name_str)
	if namecount > len or namecount < 2  then
		return -3,name_rule_desc[-3]
	end

	return 1
end

---帮派名字格式匹配规则
function g_i3k_fightgroup_name_rule(name_str)
	local len = string.len(name_str)

	if len == 0 then
		return -2,name_rule_desc[-2]
	end

	if tonumber(name_str) then
		return -1,name_rule_desc[-1]
	end

	local namecount = i3k_get_utf8_len(name_str)
	if namecount > i3k_db_common.inputlen.fightGrouplen or namecount < 2  then
		return -3,name_rule_desc[-3]
	end

	return 1
end

--根据宗门的正邪获取宗门等级图片
function g_i3k_get_lvl_icon_by_clan_type(clanType)
	if clanType == CLAN_TYPE_GOOD then
		return eClan_LevelIcon
	else
		return eClan_EvilLevelIcon
	end
end

--根据矿的类型获取矿的icon
function g_i3k_get_ore_icon_by_ore_type(oreType)
	if oreType == CLAN_ORE_TYPE_IRON then
		return g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_IRON)
	elseif oreType == CLAN_ORE_TYPE_HERB then
		return g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_HERB)
	elseif oreType == CLAN_ORE_TYPE_THORPE then
		return g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_COIN)
	end
end

--根据矿的类型获取基础产出系数
function g_i3k_get_ore_produce_args(oreType)
	if oreType == CLAN_ORE_TYPE_IRON then
		return i3k_db_clan_mine_args.mine.iron_args
	elseif oreType == CLAN_ORE_TYPE_HERB then
		return i3k_db_clan_mine_args.mine.herb_args
	elseif oreType == CLAN_ORE_TYPE_THORPE then
		return i3k_db_clan_mine_args.mine.village_args
	end
end

--根据矿的类型获取升级所需的宗门声望和道具id和数量
function g_i3k_get_ore_up_lvl_args(oreType,level)
	local needFameCount = 0
	local itemid = 0
	local itemCount = 0
	if oreType == CLAN_ORE_TYPE_IRON then
		needFameCount = i3k_db_clan_mine_up_lvl[level].iron_clan_pres
		itemid = i3k_db_clan_mine_up_lvl[level].iron_itemID
		itemCount = i3k_db_clan_mine_up_lvl[level].iron_itemCount
	elseif oreType  == CLAN_ORE_TYPE_HERB then
		needFameCount = i3k_db_clan_mine_up_lvl[level].herb_clan_pres
		itemid = i3k_db_clan_mine_up_lvl[level].herb_itemID
		itemCount = i3k_db_clan_mine_up_lvl[level].herb_itemCount
	elseif oreType == CLAN_ORE_TYPE_THORPE then
		needFameCount = i3k_db_clan_mine_up_lvl[level].village_clan_pres
		itemid = i3k_db_clan_mine_up_lvl[level].village_itemID
		itemCount = i3k_db_clan_mine_up_lvl[level].village_itemCount
	end
	return needFameCount,itemid,itemCount
end

--根据头像框ID获取人物的头像背景图
--[[test尚未完成]]
function g_i3k_get_head_bg_path(transType, frameId)
    local originFrameId = 0
    if transType == 0  then
       originFrameId = 1943
    elseif transType == 1 then
        originFrameId = 1944
    elseif transType == 2 then
       originFrameId = 1945
    end
    local iconId = i3k_db_head_frame[frameId] and i3k_db_head_frame[frameId].iconId or originFrameId
    return g_i3k_db.i3k_db_get_icon_path(iconId)
end



-------------------------------------------
local function i3k_wrap_class(obj)
	local _metatable = { };
	function _metatable.__index(self, key)
		local ret = rawget(self, key);
		if (not ret) then
			ret = obj[key];

			if (type(ret) == "function") then
				return function(self, ...)
					return ret(obj, ...);
				end
			else
				return ret;
			end
		else
			return ret;
		end
	end

	local _proxy = { };
	function _proxy.__create(...)
		return obj(...);
	end

	setmetatable(_proxy, _metatable);

	return _proxy;
end

local _class = { };
function i3k_class(name, super)
	local cls	= nil;
	local stype = type(super);

	if stype ~= "function" and stype ~= "table" then
		stype = nil;
		super = nil;
	end

	if super and (super.__ctype == nil or super.__ctype == 1) then -- c++ native class
		cls = { };
		if super.__ctype then
			for k, v in pairs(super) do
				cls[k] = v;
			end
			cls.__create= super.__create;
		else
			cls.__create= function(...) return super:create(...) end;
		end
		cls.__cname		= name;
		cls.__ctype		= 1;
		cls.__super		= super;

		function cls.getName()
			return cls.__cname;
		end

		function cls.getSuper()
			return cls.__super;
		end

		cls.ctor = function(...) end

		function cls.new(...)
			--local inst = i3k_wrap_class(cls.__create(...));
			local inst = cls.__create(...);

			inst.__class = cls;
			for k, v in pairs(cls) do
				inst[k] = v;
			end

			if cls.__super and cls.__super.ctor then
				cls.__super.ctor(inst, ...);
			end
			inst.ctor(inst, ...);

			return inst;
		end

		function cls:super_call(fn, ...)
			local mt = getmetatable(self);
			local md = nil;
			while mt and not md do
				md = mt[fn];
				if not md then
					local index = mt.__index;
					if index and type(index) == "function" then
						md = index(mt, fn);
					elseif index and type(index) == "table" then
						md = index[fn];
					end
				end

				mt = getmetatable(mt);
			end

			if md then
				return md(...);
			end

			return nil;
		end
	else -- derive from lua class
		if super then
			cls = i3k_clone(super);
			cls.__super = super;
		else
			cls = { ctor = function() end };
		end

		cls.__cname = name;
		cls.__ctype = 2; -- lua
		cls.__index = cls;

		function cls.getName()
			return cls.__cname;
		end

		function cls.getSuper()
			return cls.__super;
		end
		function cls.new(...)
			local inst = setmetatable({ }, cls);
			inst.__class = cls;

			local bases = { };
			local __super = cls.__super;
			while __super ~= nil do
				table.insert(bases, __super);

				__super = __super.__super;
			end

			for k = #bases, 1, -1 do
				local __super = bases[k];
				if __super.ctor then
					__super.ctor(inst, ...);
				end
			end

			inst:ctor(...);

			return inst;
		end

		--[[
		cls = { };
		cls.__cname = name;
		cls.__ctype = 2;
		cls.ctor 	= function() end;
		cls.super	= super;
		cls.new		= function(...)
			local obj = { };
			setmetatable(obj, { __index = _class[cls] });
			do
				local create;
				create = function(c, ...)
					if c.super then
						create(c.super, ...);
					end
					if c.ctor then
						c.ctor(obj, ...);
					end
				end

				create(cls, ...);
			end
			obj.__class = cls;
			obj.__super = _class[super];

			return obj;
		end

		local vtbl = { };
		_class[cls] = vtbl;

		setmetatable(cls, { __newindex = function(t, k, v) vtbl[k] = v; end });

		if super then
			setmetatable(vtbl, { __index =
				function(t, k)
					local ret = _class[super][k];
					vtbl[k] = ret;

					return ret;
				end
			});
		end
		]]
	end

	return cls;
end


----------------------------------------------------------------
i3k_bit_op = { _data32 = { } };

function i3k_bit_op:_init()
	for i = 1, 32 do
		i3k_bit_op._data32[i] = 2 ^ (32 - i);
	end
end

function i3k_bit_op:_d2b(arg)
	local tr = { };
	for i = 1, 32 do
		if arg >= self._data32[i] then
			tr[i] = 1;
			arg = arg - self._data32[i];
		else
			tr[i] = 0;
		end
	end

	return tr;
end

function i3k_bit_op:_b2d(arg)
	local nr = 0;
	for i = 1, 32 do
		if arg[i] == 1 then
			nr = nr + 2 ^ (32 - i);
		end
	end

	return nr;
end

function i3k_bit_op:_xor(a, b)
	local op1 = self:_d2b(a);
	local op2 = self:_d2b(b);
	local trs = { };

	for i = 1, 32 do
		if op1[i] == op2[i] then
			trs[i] = 0;
		else
			trs[i] = 1;
		end
	end

	return self:_b2d(trs);
end

function i3k_bit_op:_and(a, b)
	local op1 = self:_d2b(a);
	local op2 = self:_d2b(b);
	local trs = { };

	for i = 1, 32 do
		if op1[i] == 1 and op2[i] == 1 then
			trs[i] = 1;
		else
			trs[i] = 0;
		end
	end

	return self:_b2d(trs);
end

function i3k_bit_op:_or(a, b)
	local op1 = self:_d2b(a);
	local op2 = self:_d2b(b);
	local trs = { };

	for i = 1, 32 do
		if op1[i] == 1 or op2[i] == 1 then
			trs[i] = 1;
		else
			trs[i] = 0;
		end
	end

	return self:_b2d(trs);
end

function i3k_bit_op:_not(a)
	local op = self:_d2b(a);
	local tr = { };

	for i = 1, 32 do
		if op[i] == 1 then
			tr[i] = 0;
		else
			tr[i] = 1;
		end
	end

	return self:_b2d(tr);
end

function i3k_bit_op:_rshift(a, n)
	local op = self:_d2b(a);
	local tr = self:_d2b(0);

	if n < 32 and n > 0 then
		for i = 1, n do
			for i = 31, 1, -1 do
				op[i + 1] = op[i];
			end

			op[1] = 0;
		end

		tr = op;
	end

	return self:_b2d(tr);
end

function i3k_bit_op:_lshift(a, n)
	local op = self:_d2b(a);
	local tr = self:_d2b(0);

	if n < 32 and n > 0 then
		for i = 1, n do
			for i = 1, 31 do
				op[i] = op[i + 1];
			end

			op[32] = 0;
		end

		tr = op;
	end

	return self:_b2d(tr);
end

-------------------------------------------
--queue
i3k_queue = i3k_class("i3k_queue")
function i3k_queue:ctor()
	self._first =  0;
	self._last 	= -1;
	self._value	= { };
end

function i3k_queue:push(value)
	self._last = self._last + 1;

	self._value[self._last] = value;
end

function i3k_queue:pop()
	local value = nil;

	if self._first <= self._last then
		value = self._value[self._first];

		self._value[self._first] = nil;
		self._first = self._first + 1;
	end

	return value;
end

function i3k_queue:pop_back()
	local value = nil;

	if self._first <= self._last then
		value = self._value[self._last];

		self._value[self._last] = nil;
		self._last = self._last - 1;
	end

	return value;
end

function i3k_queue:size()
	return i3k_table_length(self._value);
end

function i3k_queue:clear()
	self._first =  0;
	self._last	= -1;
	self._value = { };
end

---i3k_cyclic_queue
i3k_cyclic_queue = i3k_class("i3k_queue")
function i3k_cyclic_queue:ctor(size)
    self._first =  0;
    self._last  = 0;
    self._size = size;
    self._count = 0;
    self._value = { };
end

function i3k_cyclic_queue:push(value)
    local pos = self._last% self._size + 1
    if self._count == self._size then
        self:pop()
    end
    self._value[pos] = value;
    self._count = self._count + 1
    self._last = pos;
end

function i3k_cyclic_queue:pop()
    local value = nil;

    if self._count ~= 0 then
        local pos = self._first % self._size + 1
        value = self._value[pos];
        self._value[pos] = nil;

        self._count = self._count - 1
        self._first = pos;
    end

    return value;
end

function i3k_cyclic_queue:ipairs()
    local i = self._first

    return function()
        if i - self._first == self._count then
            return nil
        end
        local pos = i%self._size + 1
        i = i + 1

        return pos,self._value[pos]
    end
end

function i3k_cyclic_queue:clear()
    self._first = 0;
    self._last = 0;
    self._value = { };
    self._count = 0;
end

-------------------------------------------
--
i3k_coroutine = i3k_class("i3k_coroutine")
function i3k_coroutine.Create(main)
	local co = coroutine.create(main);
	if co then
		coroutine.resume(co);
	end
end

function i3k_coroutine.AsyncCall(func, ...)
	local cur = coroutine.running();
	func(function()
		coroutine.resume(cur);
	end, ...);

	coroutine.yield();
end

-------------------------------------------
function i3k_global_create(devMode)
	g_i3k_game_handler 	= Engine.GameHandler_Instance();
	if devMode then
		g_i3k_game_handler:SetDebugMode(1);
	end

	g_i3k_mmengine		= g_i3k_game_handler:GetMMEngine();
	g_i3k_rpc_manager	= g_i3k_game_handler:GetRPCManager();

	g_i3k_db			= require("i3k_db");
	g_i3k_db.i3k_db_create();
	g_i3k_open_time		= os.date();
	i3k_bit_op:_init();
end

function i3k_global_cleanup()
	g_i3k_game_handler 	= nil;

	--g_i3k_ui_mgr		= nil;
	g_i3k_mmengine		= nil;
	g_i3k_rpc_manager 	= nil;

	if g_i3k_db then
		--[[
		g_i3k_db.i3k_db_reload();

		i3k_game_unload_script("i3k_db");
		]]

		g_i3k_db = nil;
	end
end

function i3k_global_reload_db()
	if g_i3k_db then
		g_i3k_db.i3k_db_reload();

		i3k_game_unload_script("i3k_db");
	end

	g_i3k_db = require("i3k_db");
	g_i3k_db.i3k_db_preload();
end

function i3k_get_string(id, ...)
	if i3k_db_string then
		local fmt = i3k_db_string[id];
		if fmt then
			return string.format(fmt, ...);
		end
	end

	return "";
end

function i3k_get_prop_show(propid, propvalue)
	local style = i3k_db_prop_id[propid] and i3k_db_prop_id[propid].txtFormat or e_ProPShow_Inter
	if style == e_ProPShow_Percent then
		return tonumber(string.format("%.2f",propvalue/100)) .. "%"
	end
	return math.floor(propvalue)
end

--这个函数目前并没有用到，如果要使用，得注意在适当的时机对animate进行释放
--目前这个函数产生的所有的animate都会放在i3k_frame_ani_cache里面
--目前没有对这个i3k_frame_ani_cache进行管理
i3k_frame_anis = i3k_frame_anis or { }
i3k_frame_ani_cache = { }
function i3k_load_frame_ani(aniName)
	if not aniName then return nil end
	local cache = i3k_frame_ani_cache[aniName]
	if cache then
		return cache
	end
	require("frame_anis/" .. aniName)
	local aniData = i3k_frame_anis[aniName]

	local animation = cc.Animation:create()
	animation:setDelayPerUnit(aniData.interval or 0.2)
	for i, frame in ipairs(aniData.frames) do
		animation:addSpriteFrame(cc.SpriteFrame:create(frame.picture or aniData.picture or "", cc.rect(frame[1], frame[2], frame[3], frame[4])))
	end
	local animate = cc.Animate:create(animation)
	animate:retain()
	i3k_frame_ani_cache[aniName] = animate
	return animate , cc.p(aniData.anchorX, aniData.anchorY)
end

function i3k_get_host_port(addr)
	local i = string.find(addr, ":", 1);
	local host = ""
	local port = 0
	if i ~= nil then
		host = string.sub(addr, 1, i - 1);
		port = tonumber(string.sub(addr, i + 1, string.len(addr)));
	end
	return host or "", port
end

function i3k_update_recent_server_list(serverId)
	local cfg = g_i3k_game_context:GetUserCfg()
	local recentServerList = cfg:GetRecentServerList()
	for i = #recentServerList, 1, -1 do
		if recentServerList[i] == serverId then
			table.remove(recentServerList, i)
			break
		end
	end
	table.insert(recentServerList, 1, serverId)
	cfg:SetRecentServerList(recentServerList)
end

function i3k_role_info_change_string(sendType)
	local str = ""
	local data = {
		[1] = {key = "sendtype", name = sendType},
		[2] = {key = "playerid", name = g_i3k_game_context:GetRoleId()},
		[3] = {key = "rolename", name = g_i3k_game_context:GetRoleName()},
		[4] = {key = "rolelevel", name = g_i3k_game_context:GetLevel()},
		[5] = {key = "viplevel", name = g_i3k_game_context:GetVipLevel()},
		[6] = {key = "serverid", name = i3k_game_get_server_id()},
		[7] = {key = "laborunion", name = 0},
		[8] = {key = "servername", name = i3k_game_get_server_name(i3k_game_get_server_id())},
		[9] = {key = "roleCreateTime", name = g_i3k_game_context:GetRoleCreateTime()},
		[10] = {key = "roleLevelMTime", name = g_i3k_game_context:GetRoleLevelUpTime()},
	}
	for i, e in ipairs(data) do
		str = str == "" and string.format("%s=%s", e.key, e.name) or string.format("%s|%s=%s", str, e.key, e.name)
	end
	return str
end

function i3k_game_role_info_changed(sendType)
	local finalStr = i3k_role_info_change_string(sendType)
	g_i3k_game_handler:RoleInfoChanged(finalStr)
end

function i3k_role_pay_info_string(lvl, payLevelCfg, payCfg)
	local tmp_buyNum = payLevelCfg.buyNum
	local str = ""
	local data = {
		{key = "productId", name = payLevelCfg.id},
		{key = "productName", name = tmp_buyNum ~= 1 and tmp_buyNum..payCfg[lvl].name_desc or payCfg[lvl].name_desc },
		{key = "productDesc", name = string.format(payCfg[lvl].add_desc, payLevelCfg.worth)},
		{key = "price", name = payLevelCfg.price},
		{key = "coinNum", name = g_i3k_game_context:GetDiamond(false)},
		{key = "buyNum", name = tmp_buyNum},
		{key = "currency", name = payCfg[lvl].name_desc},
		{key = "rate", name = 10},
		{key = "extension", name = lvl},
		{key = "roleId",name = g_i3k_game_context:GetRoleId() },
		{key = "gsId",name = i3k_game_get_server_id() },
	}
	for i, e in ipairs(data) do
		str = str == "" and string.format("%s=%s", e.key, e.name) or string.format("%s|%s=%s", str, e.key, e.name)
	end
	return str
end

function i3k_game_role_pay_info(id, payLevelCfg)
	local finalStr = i3k_role_pay_info_string(payLevelCfg.level, payLevelCfg, i3k_db_channel_pay[id])
	i3k_game_set_ignore_next_pause_resume_state(true) --暂不启用 慎改
	g_i3k_game_handler:RolePay(finalStr)
end

function i3k_get_gender_desc(genderType)
	if genderType == 1 then
		return string.format("男")
	elseif genderType == 2 then
		return string.format("女")
	end
end

function i3k_get_class_desc(classType)
	local cfg = g_i3k_db.i3k_db_get_general(classType)
	return cfg.name
end

function i3k_get_transfer_type_desc(bwType)
	if bwType == 0 then
		return string.format("中立")
	elseif bwType == 1 then
		return string.format("正派")
	elseif bwType == 2 then
		return string.format("邪派")
	end
end

function i3k_get_power_desc(power)
	local min = math.modf(math.floor(power / 5000) * 5000)
	local max = math.modf((math.floor(power / 5000) + 1) * 5000 - 1)
	return min.."-"..max
end

--根据所需元宝个数得到所需元宝类型信息
function i3k_get_diamond_desc(needDiamond)
	local str = ""
	local lockDiamond = g_i3k_game_context:GetDiamond(false)
	if lockDiamond >= needDiamond then
		str = needDiamond.."绑定元宝"
	elseif lockDiamond == 0 then
		str = needDiamond.."元宝"
	else
		local num = needDiamond - lockDiamond
		str = string.format("%d%s%d%s",lockDiamond,"绑定元宝",num,"元宝")
	end
	return str
end

function i3k_get_auto_user_name(uid)
	math.randomseed(os.time())
	local name = "u_"..uid.."_"..math.random(1000)
	return name
end

--获取显示数量
function i3k_get_num_to_show(number)
	if number / 10^4 < 1 then
		return number
	elseif number / 10^8 > 1 then
		local i, f = math.modf(number /10^8)
		local f1 = string.sub(tostring(f), 3, 3)
		local f2 = string.sub(tostring(f), 4, 4)
		if f2 ~= "0" then
			return i.."."..f1..f2.."亿"
		elseif f1 ~= "0" then
			return i.."."..f1.."亿"
		else
			return i.."亿"
		end
	elseif number / 10^4 >= 1 then
		local i, f = math.modf(number / 10^4)
		f = string.format("%.4f", f)
		local f1 = string.sub(f, 3, 3)
		local f2 = string.sub(f, 4, 4)
		if f2 ~= "0" then
			return i.."."..f1..f2.."万"
		elseif f1 ~= "0" then
			return i.."."..f1.."万"
		else
			return i.."万"
		end
	end
end

function i3k_chat_state_BattleOrTeam()
	local isBattle = false
	if i3k_game_get_map_type() == g_FORCE_WAR or i3k_game_get_map_type() == g_PRINCESS_MARRY  then
		isBattle =  true;
	end
	return isBattle
end

function i3k_role_move_scope(pos, targetPos, speed)

	if pos and pos.x > -800000 and pos.x < 800000 and pos.y > -800000 and pos.y < 800000 and pos.z > -800000 and pos.z < 800000  then
		if targetPos and targetPos.x > -800000 and targetPos.x < 800000 and targetPos.y > -800000 and targetPos.y < 800000 and targetPos.z > -800000 and targetPos.z < 800000  then
			if speed and speed > 0 and speed < 3000 then
				return true;
			end
		end
	end

	return false;
end

function i3k_role_stop_move_scope(pos)

	if pos and pos.x > -800000 and pos.x < 800000 and pos.y > -800000 and pos.y < 800000 and pos.z > -800000 and pos.z < 800000  then
		return true;
	end

	return false;
end

local mrg_category = TASK_CATEGORY_MRG
local mrg_function_task = TASK_FUNCTION_MRG
function i3k_set_MrgTaskCategory(groupID)
	mrg_category = groupID ~= 0 and TASK_CATEGORY_MRG or TASK_CATEGORY_MRG_LOOP
	mrg_function_task = groupID ~= 0 and TASK_FUNCTION_MRG or TASK_FUNCTION_MRG_LOOP
end
function i3k_get_MrgTaskCategory()
	return mrg_category
end

function i3k_get_MrgTaskFunction()
	return mrg_function_task
end

function i3k_GetFactionThingDesc(id, operatorName, memberName, arg, name, arg2)
    local desc
    if id == 1 then
        desc = i3k_get_string(id + 11999,operatorName)
    elseif id == 2 then
        desc = i3k_get_string(id + 11999,operatorName,memberName)
    elseif id == 3 then
        desc = i3k_get_string(id + 11999,operatorName)
    elseif id == 4 then
        desc = i3k_get_string(id + 11999,operatorName,memberName)
    elseif id == 5 then
        desc = i3k_get_string(id + 11999,operatorName,memberName)
    elseif id == 6 then
        desc = i3k_get_string(id + 11999,operatorName,memberName)
    elseif id == 7 then
        desc = i3k_get_string(id + 11999,operatorName,memberName)
    elseif id == 8 then
        desc = i3k_get_string(id + 11999,operatorName,memberName)
    elseif id == 9 then
        desc = i3k_get_string(id + 11999,memberName,operatorName)
    elseif id == 10 then
        desc = i3k_get_string(id + 11999,arg)
    elseif id == 11 then
        desc = i3k_get_string(id + 11999,name,arg)
    elseif id == 12 then
        desc = i3k_get_string(id + 11999,operatorName,arg)
    elseif id == 13 then
        desc = i3k_get_string(id + 11999,operatorName,g_i3k_db.i3k_db_get_common_item_name(arg))
    elseif id == 14 then
        desc = i3k_get_string(id + 11999,operatorName,memberName)
    elseif id == 15 then
        desc = i3k_get_string(id + 11999,operatorName,i3k_db_faction_dine[arg].name)
    elseif id == 16 then
        desc = i3k_get_string(id + 11999,operatorName,i3k_db_faction_dine[arg].name)
    elseif id == 17 then
        desc = i3k_get_string(id + 11999,operatorName,i3k_db_dungeon_base[arg].desc)
    elseif id == 18 then
        desc = i3k_get_string(id + 11999,operatorName,i3k_db_dungeon_base[arg].desc)
    elseif id == 19 then
        local name  = g_i3k_db.i3k_db_get_common_item_name(arg)

        desc = i3k_get_string(id + 11999,operatorName,name)
    elseif id == 20 then
        desc = i3k_get_string(id + 11999,operatorName,i3k_db_dungeon_base[arg].desc)
    elseif id == 21 then
        desc = i3k_get_string(id + 11999,operatorName,arg,memberName)
    elseif id == 22 then
        desc = i3k_get_string(id + 11999,i3k_db_dungeon_base[arg].desc,memberName,operatorName)
    elseif id == 23 then
        if memberName == "" then
            desc = i3k_get_string(id + 11999,operatorName,memberName,i3k_db_dungeon_base[arg].desc)
            desc = string.gsub(desc,"占领的","")
        else
            desc = i3k_get_string(id + 11999,operatorName,memberName,i3k_db_dungeon_base[arg].desc)
        end
    elseif id == 24 then
        desc = i3k_get_string(id + 11999,i3k_db_dungeon_base[arg].desc)
	elseif id == 25 then
        desc = i3k_get_string(12024,operatorName,memberName)
	elseif id == 26 then
        desc = i3k_get_string(12025,operatorName,memberName)
	elseif id == 27 then
		local cityName = i3k_db_defenceWar_city[arg].name
		if g_i3k_db.i3k_db_get_defenceWar_is_pvp(arg2) then
			desc = i3k_get_string(5195, "夺城争锋", operatorName, cityName) -- 夺城，第二阶段
		else
			desc = i3k_get_string(5195, "竞速占城", operatorName, cityName) -- 占城，第一阶段
		end
	elseif id == 28 then
		local cityName = i3k_db_defenceWar_city[arg].name
		if g_i3k_db.i3k_db_get_defenceWar_is_pvp(arg2) then
			desc = i3k_get_string(5201, "夺城争锋") -- 夺城，第二阶段
		else
			desc = i3k_get_string(5201, "竞速占城") -- 占城，第一阶段
		end
	elseif id == 29 then
		local cityName = i3k_db_defenceWar_city[arg].name
		desc = i3k_get_string(5242)
	elseif id == 30 then
		local cityName = i3k_db_defenceWar_city[arg].name
		desc = i3k_get_string(5241)
	elseif id == 31 then
		local sectName = g_i3k_game_context:GetSectName()
		local cityName = i3k_db_defenceWar_city[arg].name
		local version = g_i3k_db.i3k_db_get_defence_war_batchID()
		local startTime = i3k_db_defenceWar_time[version].captureStartTime
		local timeText = g_i3k_get_MonthAndDayTime(startTime)
		desc = i3k_get_string(5170, cityName, timeText)
	elseif id == 32 then
		local sectName = g_i3k_game_context:GetSectName()
		if g_i3k_db.i3k_db_get_defenceWar_is_pvp(arg) then
			desc = i3k_get_string(5191, "夺城争锋", sectName) -- 夺城，第二阶段
		else
			desc = i3k_get_string(5191, "竞速占城", sectName) -- 占城，第一阶段
		end
	elseif id == 33 then
		local cfg = i3k_db_faction_spirit.blessingRewards[arg]
		desc = i3k_get_string(17483, operatorName, cfg.lifeTime/3600, cfg.expCount / 100)
    end
    return desc
end

-- 返回拆分后的整数数组
function i3k_get_split_inter(num)
	local tb = {} --存放拆分的数字
	repeat
        table.insert(tb, num%10)
		num = math.floor(num/10)
    until(num == 0)
	return tb
end

function i3k_get_split_server_state(state)
	local tb = i3k_get_split_inter(state)
	return tb[g_SPLIT_HUNDRED], tb[g_SPLIT_TEN], tb[g_SPLIT_UNIT]
end

function i3k_get_activity_is_open(openDay)
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	local isOpen = false
	for _,t in ipairs(openDay) do
		if t == week then
			isOpen = true
			break
		end
	end
	return isOpen
end

function i3k_get_activity_is_open_offset(openDay, offset)
	local totalDay = g_i3k_get_day_offset()
	local offset = offset or 0
	local week = math.mod(g_i3k_get_week(totalDay+offset), 7)
	local isOpen = false
	for _,t in ipairs(openDay) do
		if t == week then
			isOpen = true
			break
		end
	end

	return isOpen
end

-- 活动开启显示格式
function i3k_get_activity_open_desc(openDay)
	local text = string.format("每周")
	for k,t in pairs(openDay) do
		text = text..g_weekTable[t]
		if k~=#openDay then
			text = text.."、"
		else
			text = text.."开启"
		end
	end
	return text
end

-- 参数为秒数 通过时间转化为 00:00:00 这种格式显示
function i3k_get_time_show_text(t)
	local hour = math.modf(t/3600)
	local minute = math.modf(t%3600/60)
	local second = math.modf(t-hour*3600-60*minute)
	if hour < 10 then
		hour = "0"..hour
	end
	if minute < 10 then
		minute = "0"..minute
	end
	if second < 10 then
		second = "0"..second
	end
	return hour..":"..minute..":"..second
end

-- 参数为秒数 通过时间转化为 天:小时 或 小时:分钟 或 分钟:秒 这种格式显示
function i3k_get_time_show_text_simple(t)
	local str = ""
	local day = math.modf(t/(3600 * 24))
	local hour = math.modf((t - day*(3600 * 24)) /3600)
	if day > 0 then
		str = day.."天"
		if hour < 10 then
			hour = "0"..hour
		end
		str = str.." ".. hour.."时"
	else
		local minute = math.modf(t%3600/60)
		if hour > 0 then
			str = hour.."时"
			if minute < 10 then
				minute = "0"..minute
			end
			str = str.." ".. minute.."分"
		else
			local second = math.modf(t-hour*3600-60*minute)
			str = minute.."分"
			if second < 10 then
				second = "0"..second
			end
			str = str.." ".. second.."秒"
		end
	end
	return str
end

-- 通过配置开始时间和持续时间返回ui显示的结束时间
-- 参数startTime必须为09:00:00格式
-- 例如开启时间为 09:00:00 持续时间为3600 返回时间格式为: 09:00 10:00
function i3k_get_start_close_time_show(startTime, lifeTime)
	local openTime = string.sub(startTime, 1, 5)
	local hour = tonumber(string.sub(openTime, 1, #openTime-3))
	local min = tonumber(string.sub(openTime, #openTime-1, #openTime))
	local lifeMin = math.floor(lifeTime/60);
	local lifeHour = math.floor(lifeMin/60);
	local endMin = math.floor(lifeMin%60);
	local endHour =  math.floor(hour + lifeHour)
	if endMin + min >= 60 then
		endHour = endHour + 1;
		endMin = endMin + min - 60;
	else
		endMin = endMin + min
	end
	local closeTime = string.format("%02d:%02d", endHour, endMin)
	if endHour >= 24 then
		endHour = endHour - 24;
		closeTime = string.format("次日%02d:%02d", endHour, endMin)
	end
	return openTime, closeTime
end

-- 活动开启时间段描述,openTimes参数为 startTime，lifeTime
--显示为10:00 ~ 20:00,~~~
function i3k_get_activity_open_time_desc(openTimes)
	local openDesc = ""
	for i, e in ipairs(openTimes) do
		local openTime, closeTime = i3k_get_start_close_time_show(e.startTime, e.lifeTime)
		local desc = string.format("%s~%s", openTime, closeTime)
		openDesc = openDesc == "" and  string.format("%s", desc) or string.format("%s；%s", openDesc, desc)
	end
	return openDesc
end

-- 时间格式openDay = { 1, 2, 3, 4, 5, 6, 0, }
function i3k_get_is_in_open_day(openDay)
	local isOpenDay = false
	local totalDay = g_i3k_get_day(i3k_game_get_time())
	local week = math.mod(g_i3k_get_week(totalDay), 7)
	for _, t in ipairs(openDay) do
		if t == week then
			isOpenDay = true
			break
		end
	end
	return isOpenDay
end

-- 参数格式 openTimes = {
--     [1] = { startTime = '14:00:00', openTime = 50400, lifeTime = 3600},
--     [2] = { startTime = '20:00:00', openTime = 72000, lifeTime = 3600},
-- },
function i3k_get_is_in_open_time(openTimes)
    local nowTime = i3k_game_get_time()
    for i, e in ipairs(openTimes) do
        local inTime = nowTime >= g_i3k_get_day_time(e.openTime) and nowTime <= g_i3k_get_day_time(e.openTime + e.lifeTime)
        if inTime then
            return true
        end
    end
    return false
end

function i3k_get_is_in_open_time_offset(openTimes)
    local nowTime = i3k_game_get_time()
    for i, e in ipairs(openTimes) do
        local inTime = nowTime >= g_i3k_get_day_time_offset(e.openTime) and nowTime <= g_i3k_get_day_time_offset(e.openTime + e.lifeTime)
        if inTime then
            return true
        end
    end
    return false
end

function i3k_global_log_info(info)
	if not i3k_game_is_dev_mode() then
		return;
	end

	local fn = i3k_game_get_exe_path() .. "gclient.log";
	local f = io.open(fn, "a");
	if f == nil then
		return;
	end

	f:write(string.format("gclient runtime info at [%s]: %s\n", os.date("%d %b %Y %X"), info));

	f:close();
end

--内甲类型是否克制
function i3k_global_armor_forbear(entityArmorType, targetArmorType)
	if entityArmorType == g_XuanYin and targetArmorType == g_TaiXu then
		return true
	end

	if entityArmorType == g_LieYang and targetArmorType == g_XuanYin then
		return true
	end

	if entityArmorType == g_TaiXu and targetArmorType == g_LieYang then
		return true
	end

	return false
end

-- 获取势力战类型（正邪势力战，混战,渠道对抗赛）
function i3k_get_forcewar_type()
	local mapID = g_i3k_game_context:GetWorldMapID()
	return i3k_db_forcewar_fb[mapID].forceWarType
end

-- 获取是否是渠道对抗赛
function i3k_get_is_combat()
	if i3k_db_forcewar_fb[g_i3k_game_context:GetWorldMapID()] then
		return i3k_game_get_map_type() == g_FORCE_WAR and i3k_get_forcewar_type() == g_CHANNEL_COMBAT
	end
	return false
end

function i3k_check_heirloom_strength(num1, num2, total)
	if (num1 + num2) > total then
		num2 = math.abs(total - num1);
		return num2;
	end
	if (num1 + num2) == total then
		return num2;
	end
	return nil;
end

function i3k_getUserState(Timer)
	local serverTime = i3k_game_get_time()
	serverTime = i3k_integer(serverTime)
	if Timer < 0 then
		return "刚刚"
	elseif Timer == 0 then
		return "线上"
	else
		local count =  serverTime - Timer
		if count >= 3600 and count <= 3600 * 24 then
			--local nums = math.modf(count / 3600)
			local desc = "刚刚"
			--desc = string.format(desc,nums)
			return  desc
		elseif count > 3600 * 24  and count <= 3600* 24 * 7 then
			local nums = math.modf(count /(3600 * 24))
			local desc = "离线%s天"
			desc = string.format(desc,nums)
			return  desc
		elseif count > 3600 * 24 *7 then
			return "久未上线"
		elseif count < 3600 then
			local nums = math.modf(count / 60)
			local desc = "刚刚"
			--desc = string.format(desc,nums)
			return  desc
		end
	end
end

-- 根据buff配置判定是否是浮空buff
function i3k_get_is_floating_buff(buffCfg)
	return buffCfg.affectType == eBuffAType_Stat and buffCfg.affectID == eEBFloating
end


-- 10:00 分钟:秒
function i3k_get_format_time_to_show(time)
	local tm = time;
	local h = i3k_integer(tm / (60 * 60));
	tm = tm - h * 60 * 60;

	local m = i3k_integer(tm / 60);
	tm = tm - m * 60;

	local s = tm;
	surplusTime = h*60*60 + m*60 + s
	return string.format("%02d:%02d", m, s)
end

-- 将剩余秒数转换为剩余的天数、小时、分钟、秒
function i3k_get_rest_date(time)
	local day, hour, minute, second = 0, 0, 0, 0

	if time > 0 then
		day = math.floor(time / 86400)
		time = time - day * 86400

		hour = math.floor(time / 3600)
		time = time - hour * 3600

		minute = math.floor(time / 60)
		time = time - minute * 60

		second = time
	end

	return day, hour, minute, second
end

-- 将剩余秒数转换为	x天x小时x分钟x秒
function i3k_get_show_rest_time(secs)
	local day, hour, minute, second = i3k_get_rest_date(secs)

	if day > 0 then
		return string.format("%s天%s时%s分%s秒", day, hour, minute, second)
	elseif hour > 0 then
		return string.format("%s时%s分%s秒", hour, minute, second)
	elseif minute > 0 then
		return string.format("%s分%s秒",minute, second)
	else
		return string.format("%s秒", second)
	end
end

-- 将剩余秒数转换为	x天:x:x：x
function i3k_get_show_rest_time2(secs)
	local day, hour, minute, second = i3k_get_rest_date(secs)

	if day > 0 then
		return string.format("%s天%s:%s:%s", day, hour, minute, second)
	elseif hour > 0 then
		return string.format("%s:%s:%s", hour, minute, second)
	elseif minute > 0 then
		return string.format("%s:%s",minute, second)
	else
		return string.format("%ss", second)
	end
end

-- 2019-02-20 05:00:00 --> 02月20日 05:00
function i3k_get_show_time_format(time)
	local timeStr = string.split(time, " ")
	local YTD = string.split(timeStr[1], "-")
	local HMS = string.split(timeStr[2], ":")
	return string.format("%s月%s日 %s:%s", YTD[2], YTD[3], HMS[1], HMS[2])
end
-- 是否是神器乱战
function i3k_get_is_tournament_weapon()
	return g_i3k_db.i3k_db_get_tournament_type(g_i3k_game_context:GetWorldMapID()) == g_TOURNAMENT_WEAPON
end
--是否楚汉
function i3k_get_is_tournament_chu_han()
	return g_i3k_db.i3k_db_get_tournament_type(g_i3k_game_context:GetWorldMapID()) == g_TOURNAMENT_CHUHAN
end
-- 查询表中是否含有值，有的话返回index/key（可隐式转换成true），没有则返回false
function i3k_table_has(tab, val)
    for key, value in pairs(tab) do
        if value == val then
            return key
        end
    end
    return false
end
-- 返回值在表中的index/key，没有则返回nil
function i3k_table_find(tab, val)
    for key, value in pairs(tab) do
        if value == val then
            return key
        end
    end
end
-- 返回第一个pred为true的index/key，没有则返回nil
function i3k_table_find_if(tab, pred)
	for key, value in pairs(tab) do
        if pred(key, value) then
            return key, value
        end
    end
end
-- 返回所有pred为true的index/key，没有则返回nil
function i3k_table_find_if_all(tab, pred)
	local rlt = {}
	for key, value in pairs(tab) do
		if pred(key, value) then
			rlt[key] = value
        end
	end
	return rlt
end
-- 在数组中搜索最后一个值为val的index，没有则返回nil
function i3k_array_rfind(arr, val)
	for i = #arr, 1, -1 do
		if arr[i] == val then
			return i
		end
	end
end
-- 在数组中搜索最后一个pred为true的index，没有则返回nil
function i3k_array_rfind_if(arr, pred)
	for i = #arr, 1, -1 do
		if pred(i, arr[i]) then
			return i, arr[i]
		end
	end
end
function i3k_table_count_if(tbl, pred)
	local cnt = 0
	for key, value in pairs(tbl) do
		if pred(key, value) then
			cnt = cnt + 1
		end
	end
	return cnt
end
--数组随机，返回随机的idx及随机数组元素
function i3k_array_random(arr)
	if #arr > 0 then
		local idx = math.random(1, #arr)
		return idx, arr[idx]
	end
end
-- 把一个map转换为数组
function i3k_map_to_array(mapTable)
	local array = {}
	local insert = table.insert
	for _, v in pairs(mapTable) do
		insert(array, v)
	end
	return array
end
-- dumptree
function i3k_print_table(t)  
    local cache = { }
	-- local toPrint = function(msg)
	-- 	local net_log = i3k_get_net_log()
	-- 	net_log:Add(msg, true)
	-- end
    local toPrint = i3k_log
    local function getKeyStr(key)
    	local key = i3k_clone(key)
    	local keyType = type(key)
    	if keyType == "number" then
        	key = tonumber(key)
        elseif keyType == "string" then
        	key = tostring('"'..key ..'"')
        end
        return key
    end
    local function subPrintTable(t, indent)
        if cache[tostring(t)] then
            toPrint(indent.."*"..tostring(t))
        else
            cache[tostring(t)] = true
            local theType = type(t)
            if theType == "table" then
                for pos, val in pairs(t) do
                	pos = getKeyStr(pos)
                    if type(val) == "table" then
                        toPrint(indent..'['..pos..'] '..'= {')
                        subPrintTable(val, indent..string.rep(' ', string.len(pos) + 6))
                        toPrint(indent..string.rep(' ', string.len(pos) + 2)..'},')
                    elseif type(val) == "string" then
                    	toPrint(indent..'['..pos..'] = "'..val..'",')
                    elseif type(val) == "function" then
                    	toPrint(indent..'['..pos..'] = '..'"'.. tostring(val) ..'",')
                    else
                        toPrint(indent..'['..pos..'] = '..tostring(val)..",")
                    end
                end
            elseif theType == "string" then
            	toPrint(indent..'"' .. tostring(t) ..'"')
            else
                toPrint(indent..'"'.. tostring(t)..'"')
            end
        end
    end
    if type(t) == "table" then
        toPrint("printTable = \n{")
        subPrintTable(t, "\t")
        toPrint("}")
    else
    	subPrintTable(t, "\t")
    end
end
g_ENGINE_VERSION_1001 = 1001 --- 引擎版本 2019.5.20
g_ENGINE_VERSION_1003 = 1003 -- 2019.8.28 
function i3k_get_engine_version()
	if g_i3k_mmengine.GetEngineVersion then
		return g_i3k_mmengine:GetEngineVersion();
	end
	return 0;
end
function i3k_get_soaring_display_info(soaringDisplay)
	if soaringDisplay.skinDisplay == nil then
		i3k_init_soaring_display_info(soaringDisplay)
	end
	return soaringDisplay.weaponDisplay, soaringDisplay.skinDisplay
end
function i3k_init_soaring_display_info(soaringDisplay)
	if soaringDisplay.skinDisplay == nil then
		local weaponDisplay = soaringDisplay.weaponDisplay or 0
		soaringDisplay.skinDisplay = math.floor(weaponDisplay / g_FLYING_OFFSET)
		soaringDisplay.weaponDisplay = weaponDisplay % g_FLYING_OFFSET
	end
end
--获取帮派名称和名字平均字符长度
function i3k_get_name_len(name)
	if not name or #name == 0 then
		return 0
	end
	local num = 0
	for c in string.gmatch(name, ".[\128-\191]*") do   -- 迭代出每一个字符
		if #c == 3 then
			num = num+1
		end
	end
	local len = string.len(name)
	return((len - num * 3) * 3 / 2) + num * 3
end
--获取鬼岛御灵倒计时
function i3k_get_catch_spirit_countdown()
	local timeStamp = i3k_game_get_time()
	local time = string.split(i3k_db_catch_spirit_base.common.openTime, ":")
	local startTime = tonumber(time[1]) * 3600 + tonumber(time[2]) * 60 + tonumber(time[3])
	if timeStamp >= g_i3k_get_day_time(startTime) and timeStamp <= g_i3k_get_day_time(startTime) + i3k_db_catch_spirit_base.common.lastTime then
		return g_i3k_get_day_time(startTime) + i3k_db_catch_spirit_base.common.lastTime - timeStamp
	else
		return 0
	end
end
--获取阵法石下一次免费祈言的倒计时
--[[function i3k_get_next_stone_pray_countdown()
	local timeStamp = i3k_game_get_time()
	local countdown = (3600 * (5 + 24) - timeStamp % 86400) % 86400
	return i3k_get_string(18450, math.floor(countdown / 3600), math.floor(countdown % 3600 / 60), math.floor(countdown % 60))
end--]]
-- 是否可以进入副本（神兵乱战，决战荒漠，密探风云）
function i3k_can_dungeon_join(isTeamJoin, gameName, teamPersonNum, openLvl)
	--判断自己等级是否符合
	local hero = i3k_game_get_player_hero()--判断等级
	if hero and hero._lvl < openLvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(341, openLvl))
		return false
	end
	--判断是否存在副本房间
	local matchType, actType = g_i3k_game_context:getMatchState()
	if matchType ~= 0 then
		g_i3k_ui_mgr:PopupTipMessage(string.format("已有其他活动报名中"))
		return false
	end
	local room = g_i3k_game_context:IsInRoom()
	if room then
		if room.type == gRoom_Force_War then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(343, i3k_get_string(17653)))
			return false
		elseif room.type == gRoom_Dungeon then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(343, i3k_get_string(17654)))
			return false
		elseif room.type == gRoom_Tournament then
			local desc = string.format(i3k_get_string(17662, gameName))
			local callback = function (isOk)
				if isOk then
					g_i3k_ui_mgr:OpenUI(eUIID_TournamentRoom)
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_TournamentRoom, "aboutMyRoom", g_i3k_game_context:getTournameRoomLeader(), g_i3k_game_context:getTournameMemberProfiles())
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
			return false
		end
	end
	--组队进入相关
	local teamId = g_i3k_game_context:GetTeamId()
	if isTeamJoin then
		--判断是否处于无队状态
		if teamId == 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(340, teamPersonNum, gameName))
			return false
		end
		--判断是不是队长
		local leaderId = g_i3k_game_context:GetTeamLeader()
		local roleId = g_i3k_game_context:GetRoleId()
		if roleId ~= leaderId then--不是队长不能报名
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(342))
			return false
		end
		--判断是否都在线（如有不在线只弹提示不失败）
		if not g_i3k_game_context:IsAllTeamMemberIsConected() then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(346, i3k_get_string(17655)))
		end
	else
		if teamId ~= 0 then
			g_i3k_ui_mgr:PopupTipMessage("组队状态中")
			return false
		end
	end
	return true
end
--绝技，兽决，心法，骑术道具展示技能详细信息，return false代表不显示
function i3k_show_skill_item_description(scroll, id)
	scroll:setVisible(true)
	scroll:removeAllChildren()
	local SKILL_DESCRIPTION = "ui/widgets/jnxqt"
	local plane, realId = g_i3k_db.i3k_db_get_common_item_type(id)
	local item_cfg = g_i3k_db.i3k_db_get_common_item_cfg(id)
	if plane == g_COMMON_ITEM_TYPE_BOOK then -- 心法书
		local node = require(SKILL_DESCRIPTION)()
		local text = string.format("%s\n%s\n%s\n%s", i3k_get_string(18706), i3k_db_xinfa[item_cfg.xinfaID].effectDesc[1], i3k_get_string(18707), i3k_db_xinfa[item_cfg.xinfaID].effectDesc[#i3k_db_xinfa[item_cfg.xinfaID].effectDesc])
		node.vars.desc:setText(text)
		node.vars.desc:setRichTextFormatedEventListener(function ()
			local textUI = node.vars.desc
			local rootSize = node.vars.rootVar:getSize()
			local height = textUI:getInnerSize().height
			local width = rootSize.width
			height = rootSize.height > height and rootSize.height or height
			node.rootVar:changeSizeInScroll(scroll, width, height, true)
		end)
		scroll:addItem(node)
		return true
	elseif plane == g_COMMON_ITEM_TYPE_ITEM and item_cfg.args1 ~= -1 then -- 背包道具，args1 == -1表示已废弃
		if item_cfg.type == SKILL_SHOW_TYPE_JUEJI then -- 绝技
			local node = require(SKILL_DESCRIPTION)()
			local role_type = g_i3k_game_context:GetRoleType()
			local skillID = i3k_db_exskills[item_cfg.args1].skills[role_type]
			node.vars.desc:setText(i3k_db_skills[skillID].desc)
			node.vars.desc:setRichTextFormatedEventListener(function ()
				local textUI = node.vars.desc
				local rootSize = node.vars.rootVar:getSize()
				local height = textUI:getInnerSize().height
				local width = rootSize.width
				height = rootSize.height > height and rootSize.height or height
				node.rootVar:changeSizeInScroll(scroll, width, height, true)
			end)
			scroll:addItem(node)
			return true
		elseif item_cfg.type == SKILL_SHOW_TYPE_QISHU or item_cfg.type == SKILL_SHOW_TYPE_SHOUJUE then -- 骑术, 兽决
			local skillID = item_cfg.args1
			if skillID == 0 then
				return false
			end
			local node = require(SKILL_DESCRIPTION)()
			if item_cfg.type == SKILL_SHOW_TYPE_QISHU then
				local skill_cfg = i3k_db_steed_skill_cfg[skillID]
				local text = string.format("%s\n%s\n%s\n%s", i3k_get_string(18706), skill_cfg[1].skillDesc, i3k_get_string(18707), skill_cfg[#skill_cfg].skillDesc)
				node.vars.desc:setText(text)
			else
				local skill_cfg = i3k_db_suicong_spirits[skillID]
				local text = string.format("%s\n%s\n%s\n%s", i3k_get_string(18706), skill_cfg[1].desc, i3k_get_string(18707), skill_cfg[#skill_cfg].desc)
				node.vars.desc:setText(text)
			end
			node.vars.desc:setRichTextFormatedEventListener(function ()
				local textUI = node.vars.desc
				local rootSize = node.vars.rootVar:getSize()
				local height = textUI:getInnerSize().height
				local width = rootSize.width
				height = rootSize.height > height and rootSize.height or height
				node.rootVar:changeSizeInScroll(scroll, width, height, true)
			end)
			scroll:addItem(node)
			return true
		else
			return false
		end
	else
		return false
	end
end
function i3k_add_shop_show_item_desc(scroll, str)
	scroll:removeAllChildren()
	local node = require("ui/widgets/wptipst")()
	node.vars.desc:setText(str)
	node.vars.desc:setRichTextFormatedEventListener(function ()
		local textUI = node.vars.desc
		local rootSize = node.vars.rootVar:getSize()
		local height = textUI:getInnerSize().height
		local width = rootSize.width
		height = rootSize.height > height and rootSize.height or height
		node.rootVar:changeSizeInScroll(scroll, width, height, true)
	end)
	scroll:addItem(node)
end

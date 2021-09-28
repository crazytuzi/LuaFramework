--logtable.lua

g_all_table4create = 
{
["RoleLogin"] = 
	[[create table if not exists RoleLogin_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		userIP varchar(20),
		userequip varchar(20),
		type int(11) COMMENT '(1登陆 2登出 3角色创建)',
		phonenumber varchar(20),
		creattime datetime,
		optime datetime,
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["Recharge"] = 
	[[create table if not exists Recharge_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		Group_ID int(11),
		ProductId int(11),
		GameOrder varchar(20),
		CreateTime varchar(20),
		FinishTime varchar(20),
		OrigGem int(11),
		ChargeGem int(11),
		vipExp int(11),
		dailyCard int(11),
		monthCard int(11),
		Source int(11) COMMENT '(0	支付失败 1	支付完成 )',
		firstCharge int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["MoneyChange"] = 
	[[create table if not exists MoneyChange_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		SerialNumber varchar(20),
		source int(11) COMMENT '(1	充值 2	拍卖行交易 3	面对面交易 4	元宝贡献 5	装备熔炼 6	主线任务 7	支线任务 8	王城诏令 9	悬赏任务 10	勇闯天关 11	在线挖矿 12	怪物掉落 13	商城出售 14	白银灵匣 15	签到 16	在线奖励 17	拯救公主 18	月卡 19	多人守护 20	环式任务 21	膜拜 22	送花 23	元宝商城购买道具 24	绑元商城购买道具 25	王城诏令完美完成 26	王城诏令升星 27	高级镖车 28	镖车额外增加宝箱 29	赤金灵匣 30	兑换行会商城 31	熔炼商城兑换道具 32	神秘商店购买道具 33	装备强化 34	仙翼强化 35	套装碎片合成 36	NPC购买药水 37	矿石合成 38	勋章升级 )',
		Type int(11) COMMENT '(1	金币 2	绑定金币 3	元宝 4	绑定元宝 5	声望值 6	熔炼值 7	行会贡献值 8	行会贡献值)',
		PreNum int(11),
		AfterNum int(11),
		Changetype int(11) COMMENT '(1 产出   2 消耗 ) ',
		ChangeNum int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["ChatNote"] = 
	[[create table if not exists ChatNote_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		Type int(11),
		Message varchar(255),
		CreateTime varchar(20),
		PRIMARY KEY (recordID)
	)]],

["PropChange"] = 
	[[create table if not exists PropChange_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		SerialNumber varchar(20),
		operatorType int(11) COMMENT '(1产出 2消耗 3流转)',
		source int(11) COMMENT '(11	主线任务 2	支线任务 3	王城诏令 4	悬赏任务 5	勇闯天关 6	在线挖矿 7	怪物掉落 8	商城出售 9	白银灵匣 10	签到 11	在线奖励 12	活跃度 13	BOSS掉落 14	领地争霸每日领取 15	神秘商店 16	未知暗殿 17	赤金灵匣 18	装备熔炼 19	行会BOSS 20	多人守护 21	环式任务 22	膜拜 23	送花 24	拯救公主 25	元宝商城 26	月卡 27	绑元商城 28	怪物攻城 29	NPC出售 30	红包商城 31	勇闯炼狱 32	装备强化 33	仙翼强化 34	套装碎片合成 35	NPC购买药水 36	矿石合成 37	装备洗炼 38	装备祝福 39	熔炼商城兑换道具 40	神秘商店购买道具 41	勋章升级 42	焰火屠魔 43	战斗消耗 44	仙翼技能升级)',
		itemId int(11),
		itemName varchar(20),
		itemNumBefore int(11),
		itemOptNum int(11),
		itemNumAfter int(11),
		itemState int(11),
		superlative int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["MallTrade"] = 
	[[create table if not exists MallTrade_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		mallName int(11),
		GoodsID int(11),
		GoodsCount int(11),
		type int(11),
		amount int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["PvpInfo"] = 
	[[create table if not exists PvpInfo_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		pvpType int(11) COMMENT '(1	单服竞技场 2	跨服竞技场 )',
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		power int(11),
		rangeBefore int(11),
		rangeAfter int(11),
		result int(11) COMMENT '(1	胜利 2	失败)',
		careaId int(11),
		cuserId int(11),
		cpower int(11),
		crangeBefore int(11),
		crangeAfter int(11),
		creattime varchar(20),
		endTime varchar(20),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["CopyInfo"] = 
	[[create table if not exists CopyInfo_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int(11) unsigned NOT NULL,
		charactername varchar(20),
		rolelevel int(11),
		rolebattle int(11),
		duptype int(11) COMMENT '副本类型(1	龙纹传说 2	战神试炼 3	通天塔 4	天关守卫 )',
		fighttype int(11) COMMENT '挑战类型(1	普通 2	扫荡 )',
		dupId int(11),
		dupname varchar(20),
		teamID int(11),
		startTime varchar(20),
		endTime varchar(20),
		tackTime int(11),
		duplevel int(11),
		endstate int(11) COMMENT '结束状态(0失败 1中途退出 2通关)',
		dupgrade int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["MultipleWard"] = 
	[[create table if not exists MultipleWard_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		dupId int(11),
		dupname varchar(20),
		teamID int(11),
		createrID int(11),
		is_success int(11),
		memRole1 int(11),
		is_success1 int(11),
		memRole2 int(11),
		is_success2 int(11),
		memRole3 int(11),
		is_success3 int(11),
		memRole4 int(11),
		is_success4 int(11),
		beginTime varchar(20),
		endTime varchar(20),
		takeTime int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["Activities"] = 
	[[create table if not exists Activities_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		activitiID int(11) COMMENT '(1	世界BOSS 2	勇闯炼狱 3	落霞夺宝 4	怪物攻城 5	烟火屠魔)',
		activitiName varchar(20),
		beginTime varchar(20),
		endTime varchar(20),
		takeTime int(11),
		result int(11) COMMENT '(1.完成;2.失败;3.中途退出)',
		hurt int(11),
		hurtRank int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["Sign"] = 
	[[create table if not exists Sign_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		vip int(11),
		rewardtype int(11),
		rewardname varchar(20),
		rewardnum int(11),
		rewardDate varchar(20),
		getTime varchar(20),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["RedPack"] = 
	[[create table if not exists RedPack_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		source int(11),
		type int(11),
		packnum int(11),
		proptype int(11),
		propnum int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["Achievement"] = 
	[[create table if not exists Achievement_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(200),
		type int(11) COMMENT '1	成就,2	称号',
		achievename varchar(20),
		getachpoint int(11),
		getdate varchar(20),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["MapTransport"] = 
	[[create table if not exists MapTransport_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		sceneID int(11),
		lastSceneID int(11),
		enterTM varchar(20),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["LevelUp"] = 
	[[create table if not exists LevelUp_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		levelbefore int(11),
		levelafter int(11),
		uptime varchar(20),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],


["TaskInfo"] = 
	[[create table if not exists TaskInfo_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		type int(11) COMMENT '1	主线任务 2	王城诏令 3	猎魔任务（环式） 4	支线 5	悬赏',
		taskid int(11),
		taskname varchar(20),
		rolelevel int(11),
		useprop int(11) COMMENT '是否使用道具完成',
		taskendstate int(11) COMMENT '(1成功 2元宝 3满环)',
		curstar int(11),
		endtime varchar(20),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["RoleTrade"] = 
	[[create table if not exists RoleTrade_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int(11) unsigned NOT NULL,
		charactername varchar(20),
		SerialNumber varchar(20),
		opType int(11) COMMENT '(1	卖方 2	买方 )',
		money int(11),
		itemId int (11),
		itemNum int (11),
		itemQuality int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["Hegemony"] = 
	[[create table if not exists Hegemony_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		factionID int(11),
		type int(11) COMMENT '(1	领地争夺 2	中州争霸 3	沙城争霸) ',
		activityID varchar(20),
		manorID int(11) COMMENT '(领地争夺	蛇魔谷	1 领地争夺	机关洞	2 领地争夺	逆魔古刹	3 领地争夺	禁地	4 领地争夺	通天塔	5 领地争夺	铁血魔域	6 领地争夺	修罗天	7 中州霸业	城主	8 中州霸业	副城主	9 中州霸业	不败战神	10 中州霸业	无双道圣	11 中州霸业	至尊法神	12 沙城争霸	城主	13)',
		manorBelong int(11),
		endTime datetime,
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["SaleInfo"] = 
	[[create table if not exists SaleInfo_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		propID int(11),
		propNum int(11),
		moneyType int(11),
		price int(11),
		tradeSum int(11),
		operation int(11),
		tradetax int(11),
		tax int (11),
		tradeNO varchar(20),
		Date varchar(20),
		PRIMARY KEY (recordID)
	)]],

["DartInfo"] = 
	[[create table if not exists DartInfo_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		darttype int(11),
		finishType int(11),
		dartEndState int(11),
		dartNO varchar(20),
		startTime varchar(20),
		endTime datetime,
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["PKInfo"] = 
	[[create table if not exists PKInfo_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		battle int(11),
		school int(11),
		pattern int(11),
		targetRoleID int(11) unsigned NOT NULL,
		targetBattle int(11),
		targetSchool int(11),
		targetPattern int(11),
		sceneID int(11),
		pkvalue int(11),
		killTime varchar(20),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["Relation"] = 
	[[create table if not exists Relation_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		relationtype int(11),
		targetID int(11) unsigned NOT NULL,
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["Vitality"] = 
	[[create table if not exists Vitality_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		taskID int(11),
		taskName varchar(20),
		vitality int(11),
		updateDate datetime,
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["Princess"] = 
	[[create table if not exists Princess_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		charactername varchar(20),
		endLevel int(11),
		endBattle int(11),
		lastGates int(11),
		updateDate datetime,
		PRIMARY KEY (recordID)
	)]],

["Additive"] = 
	[[create table if not exists Additive_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		characterid int(11) unsigned NOT NULL,
		groupid int(11),
		additiveType int(11),
		additiveLvl int(11),
		addBattle int(11),
		addMaxHP int(11),
		addMaxAT int(11),
		addMaxDF int(11),
		addMaxMF int(11),
		addMaxSpeed int(11),
		updateDate datetime,
		PRIMARY KEY (recordID)
	)]],
["Flowers"] = 
	[[create table if not exists Flowers_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int(11) unsigned NOT NULL,
		charactername varchar(20),
		rvcharacterid int(11) unsigned NOT NULL,
		rvcharactername varchar(20),
		type int(11) COMMENT '(1	一朵 2	九朵 3	九十九朵 4	九百九十九朵)',
		times int(11),
		getvital int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],
["Strength"] = 
	[[create table if not exists Strength_%d
		(	
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int(11) unsigned NOT NULL,
		optime datetime,
		opprop int(11),
		origstrlevel int(11),
		costmoney int(11),
		costpropid int(11),
		costpropnum int(11),
		result int(11),
		afterstrlevel int(11),
		specialnum int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],
["Cleanup"] = 
	[[create table if not exists Cleanup_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int(11) unsigned NOT NULL,
		optime datetime,
		opprop int(11),
		propproperty varchar(100),
		costpropid int(11),
		costpropnum int(11),
		getprop varchar(100),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],

["AttackSha"] = 
	[[create table if not exists AttackSha_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int(11) unsigned NOT NULL,
		factorname varchar(20),
		donapropnum int(11),
		getvalue int(11),
		Date datetime,
		PRIMARY KEY (recordID,characterid)
	)]],
["Opactivities"] = 
	[[create table if not exists Opactivities_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int(11) unsigned NOT NULL,
		acid int(11),
		actarget int(11),
		status int(11) COMMENT '(0	未达成目标 1	达成目标 2	领取奖励)',
		endtime datetime,
		Date datetime,
		PRIMARY KEY (recordID,characterid)
	)]],
["Setting"] = 
	[[create table if not exists Setting_%d
		(
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int (11),
		school int (11),
		userequip varchar(20),
		DPI varchar(20),
		hangHP int(11) COMMENT '采集玩家设置的百分比数值 持续回复',
		hangHP1 int (11) COMMENT '采集玩家设置的百分比数值 瞬间回复',
		hangMP int(11) COMMENT '采集玩家设置的百分比数值',
		attack varchar(30) COMMENT '(按列排序，0，表示未勾选，1，表示勾选，2表示不存在)',
		pick varchar(30) COMMENT '{第1 个金币拾取，0 表示未勾选，1 表示 勾选
									第2~4个，表示品质拾取，1表示不拾取
									2 	白色，3，绿色，4，蓝色，5 紫色，6 橙色}',
		system varchar(30) COMMENT '{
					第1 个，画面质量， 0表示高画质，1表示流畅
					第2,3个 音量， 0表示关闭，1 表示开启
					第4个 80表示不限人数；20表示20人；50表示50人
					第5~8个  0表示关闭， 1表示开启
					第9个， 缩放比例，取小数0~20}',
		PRIMARY KEY (characterid)
	)]],
["Skill"] = 
	[[create table if not exists Skill_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int (11),
		charactername varchar(20),
		skillID int(11),
		skillLv int(11),
		skillExp int(11),
		skillKey int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],
["Digmine"] = 
	[[create table if not exists Digmine_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int (11),
		logout varchar(20),
		operate int (11),
		level int(11),
		digtime int(11),
		exp int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],
["EquipBless"] = 
	[[create table if not exists EquipBless_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int (11),
		equipID int (11),
		costid int (11),
		costnum int(11),
		is_success int(11) COMMENT'0是完美 1 是免费',
		beforeluck int(11),
		afterluck int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],
["EquipInherit"] = 
	[[create table if not exists EquipInherit_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid 		int(11),
		username 		varchar(20),
		groupid 		int(11),
		characterid 	int (11),
		itemID 			int (11),
		itemProp 		int (11),
		bItemID 		int(11),
		bitemProp	    int(11),
		is_success 		int(11) ,
		is_costItem 	int(11),
		costnum 		int (11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],
 ["DeadDrop"] =
	[[create table if not exists DeadDrop_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int (11),
		itemID int(11),
		itemNum int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],
["MonsterDrop"] = 
	[[create table if not exists MonsterDrop_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int (11),
		sceneID int(11),
		monsterID int(11),
		monsterName varchar(50),
		dropID int(11),
		dropNum int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],
["ExceptionExp"] = 
	[[create table if not exists ExceptionExp_%d
		(
		recordID int(11) unsigned NOT NULL AUTO_INCREMENT,
		channelid int(11),
		username varchar(20),
		groupid int(11),
		characterid int (11),
		exp int(11),
		curLv int(11),
		afterLv int(11),
		Date datetime,
		PRIMARY KEY (recordID)
	)]],
}

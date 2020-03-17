--[[
消息常量
请注明消息参数
lizhuangzhuang
2014年7月20日18:07:02
]]

--格式模板
--UserLvlUp = "UserLvlUp", --玩家升级 {lvl:等级}

--Read By YANTIELEI	Event's Name

_G.NotifyConsts = {
	StageClick = "StageClick", --舞台被点击 {button:鼠标1左键2右键,target:被点击对象的_target属性}
	StageMove = "StageMove",--鼠标在舞台上移动{x:x,y:y}
	StageFocusOut = "StageFocusOut",--舞台失去焦点
	
	PlayerAttrChange = "PlayerAttrChange", --玩家Me基本属性改变 {type:类型,val:值,oldVal:改变前的值}
	PlayerModelChange = "PlayerModelChange", --主玩家模型改变
	
	CreateRoleShowUIEffect = "CreateRoleShowUIEffect",
	CreateRoleHideUIEffect = "CreateRoleHideUIEffect",
	
	QuestAdd                  = "QuestAdd", --增加任务,{id:任务id}
	QuestRemove               = "QuestRemove", --减少任务,{id:任务id}
	QuestUpdate               = "QuestUpdate", --任务变化,(包括状态和进度,id:任务id}
	QuestRefreshList          = "QuestRefreshList", --任务列表刷新
	QuestFinish               = "QuestFinish", --任务完成:{id:任务id}
	QuestDayFinish            = "QuestDayFinish", -- 日环任务完成
	QuestDailyFullStar        = "QuestDailyFullStar", -- 日环任务升满星
	QuestDailyStateChange     = "QuestDailyStateChange", -- 日环状态变化
	QuestBreakRecommendChange = "QuestBreakRecommendChange", -- 任务断档推荐更新(如流水副本可用次数变化等)
	QuestLieMoFinish          = "QuestLieMoFinish", -- 猎魔任务完成
	QuestLieMoFullStar        = "QuestLieMoFullStar", -- 猎魔任务升满星
	QuestLieMoStateChange     = "QuestLieMoStateChange", -- 猎魔状态变化
	CreateRoleBtnStateChanged = "CreateRoleBtnStateChanged", --创角色按钮可用 
	
	BagAdd = "BagAdd", --背包增加, {type:背包类型,pos:位置}
	BagRemove = "BagRemove", --背包减少,{type:背包类型,pos:位置}
	BagUpdate = "BagUpdate", --背包更新,{type:背包类型,pos:位置}
	BagRefresh = "BagRefresh", --背包刷新,{type:背包类型}
	BagSlotOpen = "BagSlotOpen", --背包开启,{type:背包类型,oldSize:旧格子数,newSize:新格子数}
	BagItemCDUpdate = "BagItemCDUpdate",--背包物品CD改变,{type:背包类型}
	BagItemNumChange = "BagItemNumChange",--背包内(单指背包)物品数量变化,{id:物品id(表id)}
	BagItemUseNumChange = "BagItemUseNumChange",--物品使用数量变化,{id:物品id(表id)}
	
	EquipAttrChange = "EquipAttrChange",--装备的附加信息改变{id:物品cid}
	SuperHoleLvlUp = "SuperHoleLvlUp",--卓越孔升级{pos:装备位,index:孔索引}
	EquipSuperChange = "EquipSuperChange",--装备卓越信息改变{id:物品cid}
	SuperLibRefresh = "SuperLibRefresh",--装备卓越属性库刷新
	SuperLibRemove = "SuperLibRemove",--装备卓越属性库删掉 {id:id}
	EquipNewSuperChange = "EquipNewSuperChange",--新装备卓越信息改变{id:物品cid}
	EquipGroupLevel = "EquipGroupLevel",--套装升级
	EquipGroupActivation = "EquipGroupActivation",--套装养成

	
	MapChange        = "MapChange", -- 换地图 { mapType, elem }
	MapElementAdd    = "MapElementAdd", --增加地图元素 { mapType, elem }
	MapElementMove   = "MapElementMove", --移动地图元素 { mapType , elem }
	MapElementUpdate = "MapElementUpdate", --地图图标更新 { mapType, elem }
	MapElementRemove = "MapElementRemove", --移除一个地图元素 { mapType, elem }
	MapElementClear  = "MapElementClear", --清空地图元素 { mapType }

	TargetAttrChange = "TargetAttrChange", --选中目标(player or monster)属性变化, {type:属性名, value:属性值}
	TargetLockStateChange = "TargetLockStateChange", --选中目标(player or monster)锁定状态变化
	TargetBuffRefresh = "TargetBuffRefresh", --选中目标buff状态更新


	SkillPlayCD = "SkillPlayCD",--播放技能CD,{skillId:技能id,time:冷却时间}
	SkillShortCutRefresh = "SkillShortCutRefresh",--技能栏刷新
	SkillShortCutChange = "SkillShortCutChange",--技能栏改变,{skillId:技能id,pos:位置}
	SkillAdd = "SkillAdd",--技能增加,{skillId:技能id}
	SkillRemove = "SkillRemove",--删除技能,{skillId:技能id}
	SkillLearn = "SkillAdd",--技能学习,{skillId:技能id}
	SkillQuicklyLvlUp = "SkillQuicklyLvlUp",--快速升级技能
	SkillLvlUp = "SkillLvlUp",--技能升级,{skillId:技能id,oldSkillId:原技能id}
	ItemShortCutRefresh = "ItemShortCutRefresh",--技能栏物品刷新
	
	BuffRefresh = "BuffRefresh",--刷新Buff列表
	RefreshWaterdata = "RefreshWaterdata",--刷新流水副本数据

	-- 绝学   adder:hoxudong  date:2016/5/18 11:27:05 range: line78 ~ line81
	MagicSkillLearn = "MagicSkillLearn",   ---绝学技能学习   
	MagicSkillUpgrade = "MagicSkillUpgrade", ---绝学技能升级
	MagicSkillTupo = "MagicSkillTupo",     ---绝学技能突破
	-- 心法   adder:hoxudong  date:2016/5/30 15:18:05 range: line82 ~ line85
	XinfaSkillLearn = "XinfaSkillLearn",   ---心法技能学习   
	XinfaSkillUpgrade = "XinfaSkillUpgrade", ---心法技能升级
	XinfaSkillTupo = "XinfaSkillTupo",     ---心法技能突破

	-- 队伍
	TeamMemberAdd = "TeamMemberAdd", --队伍增加成员 body:index
	TeamMemberRemove = "TeamMemberRemove", --队伍移除成员 body:index
	TeamJoin = "TeamJoin", --主玩家进入队伍
	TeamQuit = "TeamQuit", --主玩家退出队伍
	MemberChange = "MemberChange", --队员信息更新 body:{ index = index, attrType = attrName, attrValue = attrValue } )
	MemberAppearanceChange = "MemberAppearanceChange", --队员外观更新 body: index
	PlayerNearby = "PlayerNearby", -- 附近玩家信息
	TeamNearby = "TeamNearby", -- 附近队伍信息
	
	ChatPrivateRefresh = "ChatPrivateRefresh",--聊天私人频道刷新,{roleId:发送者id}
	ChatPrivateNotice = "ChatPrivateNotice",--收到私聊通知
	ChatPrivateListRefresh = "ChatPrivateListRefresh",--私聊列表刷新
	ChatChannelRefresh = "ChatChannelRefresh",--聊天频道刷新
	ChatChannelNewMsg = "ChatNewMsg",--聊天频道中有新消息,显示提醒特效{channel:频道}

    SceneLineChanged = "SceneLinesChanged", --场景内线路列表刷新
	
	WuhunListUpdate = "WuhunListUpdate", --武魂列表更新 
	WuhunLevelUpUpdate = "WuhunLevelUpUpdate", --武魂进阶更新 
	WuhunUpdateFeed = "WuhunUpdateFeed",--武魂喂养
	WuhunLevelUpFail = "WuhunLevelUpFail", --武魂进阶更新 
	WuhunFushenChanged = "WuhunFushenChanged",--自己的武魂附身发生变化
	ChangeZhanShouModel = "ChangeZhanShouModel",--武魂切换
	
	WuhunChangeDrawModel = "WuhunChangeDrawModel",--在人物模型上添加或删除武魂显示和特效{Avatar:avatar,type:添加1删除2}
	
	MailListUpdate = "MailListUpdate",--邮件列表更新
	MailContentInfoUpdate = "MailContentInfoUpdate",--邮件内容跟新
	MailNumChanged = "MailNumChanged",--邮件有数量变化
	MailGetItem = "MailGetItem",--邮件有数量变化
	
	FriendChange = "FriendChange",--好友改变
	FriendOnlineChange = "FriendOnlineChange",--好友在线状态改变
	
	RemindRefresh = "RemindRefresh",--下方提醒刷新,{type:队列类型}

	AutoBattleSetInvalidate       = "AutoBattleSetInvalidate", --自动战斗设置改变，通知更新显示
	AutoBattleCfgChange           = "AutoBattleCfgChange", --自动战斗设置某项改变，通知更新显示{cfgName = cfgName, value = value}
	AutoBattleNormalSkillAdded    = "AutoBattleNormalSkillAdded", --自动战斗增加普通技能
	AutoBattleNormalSkillRemoved  = "AutoBattleNormalSkillRemoved", --自动战斗移除普通技能
	AutoBattleSpecialSkillAdded   = "AutoBattleSpecialSkillAdded", --自动战斗增加特殊技能
	AutoBattleSpecialSkillRemoved = "AutoBattleSpecialSkillRemoved", --自动战斗移除特殊技能
	
    -------交易--------
	DealMeState = "DealMeState", --主玩家交易状态改变
	DealMeItem  = "DealMeItem",  --主玩家交易物品改变 body:pos
	DealMeMoney = "DealMeMoney",  --主玩家交易金钱改变 body:money
	DealHeState = "DealHeState",  --交易对方状态改变
	DealHeItem  = "DealHeItem",  --交易对方物品改变 body:pos
	DealHeMoney = "DealHeMoney",  --交易对方金钱改变 body:money
	DealHeInfo  = "DealHeInfo",  --交易对方人物信息改变

	 -------坐骑--------
	MountLvUpInfoChanged   = "MountLvUpInfoChanged",--坐骑进阶进度刷新
	MountLvUpSucChanged    = "MountLvUpSucChanged",--坐骑成功进阶刷新
	MountUsePillChanged    = "MountUsePillChanged",--坐骑使用属性丹刷新
	MountRidedChanged      = "MountRidedChanged",--更改坐骑结果刷新
	MountRidedChangedState = "MountRidedChangedState",--更改骑乘状态刷新
	MountSucCancelZiDong   = "MountSucCancelZiDong",--取消自动进阶状态刷新
	MountFailCancelZiDong  = "MountFailCancelZiDong",--取消自动进阶状态刷新
	MountXingUpSucChanged  = "MountXingUpSucChanged",--星升级更新坐骑属性
	MountProgressUpdate    = "MountProgressUpdate",--进度条更新
	MountSkinTimeUpdate    = "MountSkinTimeUpdate",--坐骑皮肤时间刷新
	
	 -------属性丹--------
	LingShouSXDChanged     = "LingShouSXDChanged",--灵兽使用属性丹刷新
	ShenBingSXDChanged     = "ShenBingSXDChanged",--神兵使用属性丹刷新
	QiZhanSXDChanged       = "QiZhanSXDChanged",  --骑战使用属性丹刷新
	MountLSZZSXDChanged    = "MountLSZZSXDChanged",--灵兽坐骑使用资质属性丹刷新
	LingQiSXDChanged     = "LingQiSXDChanged",--灵器使用属性丹刷新
	MingYuSXDChanged     = "MingYuSXDChanged",--命玉使用属性丹刷新
	ArmorSXDChanged     = "ArmorSXDChanged",--宝甲使用属性丹刷新
	RealmSXDChanged     = "RealmSXDChanged",--境界使用属性丹刷新
	 -------灵兽坐骑--------
	MountLSLvUpInfoChanged   = "MountLSLvUpInfoChanged",--坐骑进阶进度刷新
	MountLSLvUpSucChanged    = "MountLSLvUpSucChanged",--坐骑成功进阶刷新
	--MountLSUsePillChanged    = "MountLSUsePillChanged",--坐骑使用属性丹刷新
	MountLSSucCancelZiDong   = "MountLSSucCancelZiDong",--取消自动进阶状态刷新
	MountLSFailCancelZiDong  = "MountLSFailCancelZiDong",--取消自动进阶状态刷新
	MountLSXingUpSucChanged  = "MountLSXingUpSucChanged",--星升级更新坐骑属性
	
	 -------封妖--------
	FengYaoLevelRefresh	= "FengYaoLevelRefresh",--封妖难度刷新
	FengYaoStateChanged	= "FengYaoStateChanged",--封妖选中刷新
	FengYaoListChanged	= "FengYaoListChanged",--封妖列表刷新
	FengYaoGetBox		= "FengYaoGetBox",--封妖获取宝箱刷新
	FengYaoBaoScoreAdd	= "FengYaoBaoScoreAdd",--封妖积分增加刷新
	FengYaoTastFinish	= "FengYaoTastFinish",--封妖任务完成刷新
	FengYaoKillMonsterNum	= "FengYaoKillMonsterNum",--封妖任务杀怪数目刷新
	FengYaoTimeLeft	= "FengYaoTimeLeft",--封妖任务杀怪剩余秒数
	
	-------等级奖励--------
	LevelAwardChange	= "LevelAwardChange",--等级奖励领取刷新
	
	-------离线奖励--------
	OutLineExpUpdata	= "OutLineExpUpdata",--离线奖励刷新
	
	-------激活码奖励--------
	GetCodeReward	= "GetCodeReward",--获取激活码奖励
	
	-------个人BOSS-------
	PersonalBossTime = "PersonalBossTime",		--时间刷新
	
	-------活跃度--------
	HuoYueDuListRefresh		= "HuoYueDuListRefresh",--活跃度列表刷新
    HuoYueDuLevelUpdata     ="HuoYueDuLevelUpdata", --仙阶等级刷新
    HuoYueDuInfoUpdata      ="HuoYueDuInfoUpdata",  --仙阶信息更新
	HuoYueDuChangeModel     ="HuoYueDuChangeModel",--仙阶模型更新
	
	-------今日必做--------
	JinRiBiZuoList			= "JinRiBiZuoList",--今日必做列表
	JinRiBiZuoListUpdata	= "JinRiBiZuoListUpdata",--今日必做列表完成刷新
	JinBiBiZuoUpdata		= "JinBiBiZuoUpdata",--今日必做单个活动刷新
	
	-------萌宠--------
	LovelyPetStateUpdata	= "LovelyPetStateUpdata",--萌宠状态刷新
	LovelyPetTimeUpdata		= "LovelyPetTimeUpdata",--萌宠剩余时间刷新
	
	--------礼包抽奖-------
	UpgradeStoneResult		= "UpgradeStoneResult", --进阶石

	-------全服红包--------
	RedPacketUpdata			= "RedPacketUpdata",--全服红包信息刷新.
	RedPacketListUpdata		= "RedPacketListUpdata",--全服红包列表刷新
	 
	-------商店---------
	BuyBackListRefresh = "BuyBackListRefresh", -- 回购列表物品变动
	HasBuyListRefresh = "HasBuyListRefresh", -- 限购物品变动

	-------打坐---------
	SitGainChange      = "SitGainChange",--打坐收益变化
	SitNearby          = "SitNearby",--附近打坐列表
	SitFormationChange = "SitFormationChange",--打坐阵型变化
	SitCancel          = "SitCancel",--打坐取消

	-------副本---------
	DungeonGroupChange = "DungeonGroupChange", -- 副本组有更新
	DungeonBossBianyi = "DungeonBossBianyi", -- 副本boss变异
	DungeonRank = "DungeonRank", -- 副本神话难度排行榜 body: dungeonGroup
	
	-----称号-------
	TitleNumChange = "TitleNumChange",  --称号信息的变化
	TitleGetItem = "TitleGetItem",  --获得称号
	TitleRemoveTime = "TitleRemoveTime";  --称号剩余时间
	TitleTipTime = "TitleTipTime",  --称号剩余时间

	------升品------- 
	EquipProductUpdata = "EquipProductUpdata",
	EquipInherEffect = "EquipInherEffect",
	
	------熔炼-------
	
	EquipSmeltingData = 'EquipSmeltingData',	--装备熔炼
	
	------帮派-------
	MyUnionInfoUpdate = "MyUnionInfoUpdate", --我的帮派信息
	UnionListUpdate =  "UnionListUpdate", --帮派列表
	ApplyGuildResult =  "ApplyGuildResult", --申请帮派
	CreateGuildSucc =  "CreateGuildSucc", --创建帮派成功
	ReplyGuildNumChanged =  "ReplyGuildNumChanged", --帮派申请人数变化
	OtherGuildInfoUpdate =  "OtherGuildInfoUpdate", --刷新其他帮派信息
	EditNoticeUpdate =  "EditNoticeUpdate", --刷新修改公告
	ChangeLeaderUpdate =  "ChangeLeaderUpdate", --转让盟主
	ChangeGuildMasterName =  "ChangeGuildMasterName", --盟主名字变化
	UpdateMyUnionMemInfo =  "UpdateMyUnionMemInfo", --刷新自己帮派信息 pos 帮贡
	UpdateGuildMemberList =  "UpdateGuildMemberList", --刷新帮派成员列表
	UpdateGuildEventList =  "UpdateGuildEventList", --刷新帮派事件列表
	UpdateGuildApplyList =  "UpdateGuildApplyList", --刷新帮派申请列表
	UpdateContribute =  "UpdateContribute", --刷新帮派捐献
	UpdateLevelUpMyGuildSkill =  "UpdateLevelUpMyGuildSkill", --刷新自己的帮派技能升级成功
	OpenGuildSkill =  "OpenGuildSkill", --帮派技能开启成功
	UpdateLvUpGuild =  "UpdateLvUpGuild", --升级帮派
	UpdateGuildInfo =  "UpdateGuildInfo", --更新帮派信息
	GuildTanHeQuanXian =  "GuildTanHeQuanXian", --弹劾权限
	GuildQueryCheckList =  "GuildQueryCheckList", --帮派仓库审核列表
	
	UnionAidInfoUpDate = "UnionAidInfoUpDate",  --更新帮派加持属性
	UnionAidLevelUpDate = "UnionAidLevelUpDate",  --更新帮派加持等级上升
	UnionAidInfo = "UnionAidInfo",  --洗炼属性返回
	----------帮派：帮派副本相关
	UnionDungeonListUpdate = "UnionDungeonListUpdate", -- 帮派副本列表更新
	GuildHellStratumUpdate = "GuildHellStratumUpdate", -- 帮派副本-地宫炼狱信息更新
	
	---------装备宝石 --------
	EquipGemUpdata = "EquipGemUpdata",
	
	-----------PK索引改变图标-----------
	UpPKStateIconUrlChange = "UpPKStateIconUrlChange",

	-------世界boss---------
	WorldBossUpdate   = "WorldBossUpdate", --世界boss更新
	WorldBossHurt     = "WorldBossHurt", --世界boss伤害信息更新
	WorldBossMyDamage = "WorldBossMyDamage", --世界boss我造成的伤害
	
	------ 野外BOSS--------
	FieldBossUpdate   = "FieldBossUpdate",  --- 野外BOSS信息更新
    ------秘境BOSS--------
	PalaceBossUpdate =   "PalaceBossUpdate",---  秘境BOSS信息更新

	-------凝练天机剑---------
	TianjijianTimeInfo = "TianjijianTimeInfo", --天机剑时间信息
	TianjijianKillInfo = "TianjijianKillInfo", --天机剑击杀信息
	
	-------道具合成---------
	ToolHeChengInfo = "ToolHeChengInfo", --道具合成信息
	
	-------解救冰奴---------
	JieFengBingNuInfo = "JieFengBingNuInfo", --解救冰奴信息
	
	-------查看他人详细信息---------
	OtherRoleXXInfo = "OtherRoleXXInfo", --其他人详细信息
	
	-------时装打扮信息---------
	FashionsDressInfo = "FashionsDressInfo", --时装打扮信息
	FashionsDressAdd = "FashionsDressAdd", --时装打扮信息
	
	-------境界---------
	JingJieBreakSuccess = "JingJieBreakSuccess", --境界升阶成功
	JingJieXiuLianProgress = "JingJieXiuLianProgress", --境界修炼进度改变
	JingJieBreakProgress = "JingJieBreakProgress", --境界突破进度改变
	JingJieSucCancelZiDongXL = "JingJieSucCancelZiDongXL", --主动取消境界自动修炼
	JingJieFailCancelZiDongXL = "JingJieFailCancelZiDongXL", --被动取消境界自动修炼
	JingJieSucCancelZiDongTP = "JingJieSucCancelZiDongTP", --主动取消境界自动突破
	JingJieFailCancelZiDongTP = "JingJieFailCancelZiDongTP", --被动取消境界自动突破
	
	RealmProgress = "RealmProgress", --境界灌注进度改变
	StrenthenUpdate = "StrenthenUpdate", --境界巩固改变
	RealmBreakSuccess = "RealmBreakSuccess",--境界升阶成功 
	RealmMaxUpdate = "RealmMaxUpdate",  --世界最高等阶更新
	RealmBreakProgress = "RealmBreakProgress", --境界进阶进度改变
	RealmModelChange = "RealmModelChange",  --境界使用图标改变
	
	
	-------宝甲------------------
	BaoJiaUpdate         	= "BaoJiaUpdate", --宝甲信息更新
	BaoJiaLevelUp        	= "BaoJiaLevelUp", --宝甲升级
	BaoJiaBlessing       	= "BaoJiaBlessing", --宝甲进阶祝福值更新
	
	-------灵力徽章---------
	ZhuLingProgress 			= "ZhuLingProgress", --注灵进度改变
	JuLingProgress				= "JuLingProgress", --聚灵数据变化
	KillLingLiUpdate			= "KillLingLiUpdate", --击杀怪物灵力数据变化
	GetShouYiUpdate 			= "GetShouYiUpdate", --获得聚灵后变化
	
	-------帮派祈福---------
	UnionPrayRefresh	 		= "UnionGetPrayRefresh", --帮派祈福信息刷新
	
	-------兵魂系统---------
	BingHunUpdate	 			= "BingHunUpdate", --兵魂更新
	
	-------妖丹妖狐---------
	UpdataBogeyPillChangeList = "UpdataBogeyPillChangeList",  --妖丹数量变化
	UpdataYaoHunChangeList = "UpdataYaoHunChangeList",  --妖丹数量变化
	
	ActivityState = "ActivityState",--活动状态改变{id:活动id}
	ActivityOnLineTime = "ActivityOnLineTime",--活动在线时间
	-------签到----------
	UpdataSignState = "UpdataSignState",  --签到某天按钮的变化
	UpdataTimeRewardNum = "UpTimeRewardNum", --更新抽奖次数
	GetRewardIndex = "GetRewardIndex", --抽中的物品
	TimeNumUpData = "TimeNumUpData", --倒计时更新
	UpDataEffect = 'UpDataEffect', --更新面板特效
	SignRewardUpData = 'SignRewardUpData', --领取签到奖励
	
	UpdateDiplomacy =  "UpdateDiplomacy", --同盟返回
	UpdateDiplomacyPlayer =  "UpdateDiplomacyPlayer", --请求同盟人员信息
	UpdateDiplomacyPlayerList =  "UpdateDiplomacyPlayerList", --请求同盟人员信息
	UpdateDiplomacyList =  "UpdateDiplomacyList", --请求申请同盟列表
	-----------竞技场 ---------------
	ArenaUpFirstRank = "ArenaUpFirstRank"; --排行123名
	ArenaUpChaObjectlist = "ArenaUpChaObjectlist"; --  挑战对象
	ArenaUpMyInfo = "ArenaUpMyInfo"; -- 我的信息
	ArenaRoleInfoChang = "ArenaRoleInfoChang"; -- 人物战斗信息发生变化
	ArenaSkInfoUpdata = "ArenaSkInfoUpdata";
	ArenaGetMyInfo = "ArenaGetMyInfo";  --我的信息改变
	--------仙缘洞府PK状态改变----------
	PkStateChange = "PkStateChange";
	CavePiLaoChange = 'CavePiLaoChange';
	CaveReward = 'CaveReward';
	CaveBossState = 'CaveBossState';	--BOSS状态
	CaveBossHurt  = 'CaveBossHurt';     --对boss的伤害
	CaveDamage  = 'CaveDamage';         --伤害总量
	-------- 排行榜
	RanklistAllRoleInfo = "RanlistAllRoleInfo",  -- 总排行
	RanklistRoleInfo = "RanklistRoleInfo", -- 本服角色排行
	RanklistRoleDetaiedInfo = "RanklistRoleDetaiedInfo", -- 人物基本信息
	RanklistMountDetaiedInfo = "RanklistMountDetaiedInfo ", -- 坐骑基本信息；
	RanklistLingshouDetaiedInfo = "RanklistLingshouDetaiedInfo ", -- 灵兽基本信息；
	-- RanklistLingzhenDetaiedInfo = "RanklistLingzhenDetaiedInfo ", -- 灵阵基本信息；
	RanklistShengbingDetaiedInfo = "RanklistShengbingDetaiedInfo", -- 神兵
	RanklistNewTianShenDetaiedInfo = "RanklistNewTianShenDetaiedInfo", -- 天神
	RanklistLingQiDetaiedInfo = "RanklistLingQiDetaiedInfo", -- 灵器
	RanklistMingYuDetaiedInfo = "RanklistMingYuDetaiedInfo", -- 玉佩
	RanklistArmorDetaiedInfo = "RanklistArmorDetaiedInfo", -- 宝甲
	AllTheServerListUpdata = "AllTheServerListUpdata", -- 全服角色 排行
	InterServerPvpListUpdata = "InterServerPvpListUpdata", -- 跨服pvp 排行
	InterServerPvpRongyaoUpdata = "InterServerPvpRongyaoUpdata", -- 跨服荣耀 排行
	InterServerKuafuRongyaoInfo = "InterServerKuafuRongyaoInfo", -- 跨服荣耀榜信息
	InterServerKuafuRongyaoReward = "InterServerKuafuRongyaoReward", -- 跨服荣耀榜领奖
	
	ISKuafuMianRank = "ISKuafuMianRank", -- 跨服主界面排行榜
	ISKuafuBossInfoRefresh = "ISKuafuBossInfoRefresh", -- 战斗中跨服BOSS信息刷新
	ISKuafuBossRankList = "ISKuafuBossRankList", -- 战斗中跨服BOSS排行
	ISKuafuBossBaoxiang = "ISKuafuBossBaoxiang", -- 战斗中跨服BOSS宝箱
	ISKuafuBossResultRankList = "ISKuafuBossResultRankList", -- 跨服boss结算
	ISKuafuBossAddBlood = "ISKuafuBossAddBlood", -- 跨服boss加血技能
	ISKuafuBossMemInfo = "ISKuafuBossMemInfo", -- 跨服boss资格信息
	
	ISKuafuArenaRankInfo = "ISKuafuArenaRankInfo", -- 跨服淘汰赛对阵信息
	
	-------系统设置面板
	SetSystemShowChange = 'SetSystemShowChange',--显示界面变化
	SetSystemFuncChange = 'SetSystemFuncChange',--功能按键变化
	SetSystemSkillChange = 'SetSystemSkillChange',--技能界面变化
	SetSystemDisabled = 'SetSystemDisabled',--应用置灰
	-------------圣器镶嵌
	HallowsUpData = 'HallowsUpData',			--圣器镶嵌
	-------打宝活力值------------
	SetDropValueLevel = "SetDropValueLevel",--设置打宝活力值消耗等级
	DropItemRecord = "DropItemRecord",--打宝活力值掉宝记录更新
	-------每日杀戮属性----------
	KillValueChange = "KillValueChange", -- 每日杀戮属性更新
	KillHistoryChange = "KillHistoryChange", -- 历史杀戮记录更新
	-------神兵------------------
	MagicWeaponLevelUp        = "MagicWeaponLevelUp", --神兵升级
	MagicWeaponModelChange    = "MagicWeaponModelChange", --神兵模型更新
	MagicWeaponPrfcncyLevelUp = "MagicWeaponPrfcncyLevelUp", --神兵熟练度升级
	MagicWeaponProficiency    = "MagicWeaponProficiency", --神兵熟练度更新
	MagicWeaponBlessing       = "MagicWeaponBlessing", --神兵进阶祝福值更新
	-------神兵兵灵------------------
	BingLingBlessing          = "BingLingBlessing", --神兵兵灵进阶信息
	-------灵器------------------
	LingQiLevelUp        = "LingQiLevelUp", --灵器升级
	LingQiModelChange    = "LingQiModelChange", --灵器模型更新
	LingQiPrfcncyLevelUp = "LingQiPrfcncyLevelUp", --灵器熟练度升级
	LingQiProficiency    = "LingQiProficiency", --灵器熟练度更新
	LingQiBlessing       = "LingQiBlessing", --灵器进阶祝福值更新
	-------玉佩------------------
	MingYuLevelUp        = "MingYuLevelUp", --玉佩升级
	MingYuModelChange    = "MingYuModelChange", --玉佩模型更新
	MingYuPrfcncyLevelUp = "MingYuPrfcncyLevelUp", --玉佩熟练度升级
	MingYuProficiency    = "MingYuProficiency", --玉佩熟练度更新
	MingYuBlessing       = "MingYuBlessing", --玉佩进阶祝福值更新
	-------新宝甲------------------
	ArmorLevelUp        = "ArmorLevelUp", --玉佩升级
	ArmorModelChange    = "ArmorModelChange", --玉佩模型更新
	ArmorPrfcncyLevelUp = "ArmorPrfcncyLevelUp", --玉佩熟练度升级
	ArmorProficiency    = "ArmorProficiency", --玉佩熟练度更新
	ArmorBlessing       = "ArmorBlessing", --玉佩进阶祝福值更新
	----------通天塔界面更新------------
	BabelUpData = 'BabelUpData', --切换面板或打开面板
	BabelInfoPanelOpen = 'BabelInfoPanelOpen', --通天塔信息面板打开
	BabelStory = 'BabelStory',  --通天塔剧情播放完毕
	BabelSweep = 'BabelSweep',  --服务器返回：返回扫荡
	BabelRankUpdate = 'BabelRankUpdate',       --排行榜更新
	----------诛仙阵界面更新------------
	GodDynastyUpData        = 'GodDynastyUpData',        --切换面板或打开面板
	GodDynastyInfoPanelOpen = 'GodDynastyInfoPanelOpen', --诛仙阵信息面板打开
	GodDynastyStory         = 'GodDynastyStory',         --诛仙阵剧情播放完毕
	GodDynastyRankUpdate    = 'GodDynastyRankUpdate',    --诛仙阵排行榜更新

	----------自动挂机------------------
	AutoHangStateChange = 'AutoHangStateChange',  --挂机状态变化 body:{state = isAutoHang}
	--------帮派战----------
	UnionWarAllinfo = "UnionWarAllinfo", -- 战场总信息
	UnionWarBuildingState = "UnionWarBuildingState", -- 建筑物状态
	UnionWarUpdataList = "UnionWarUpdataList", -- 排行list
	--------定时副本-------
	TimerDungeonMonsterChange = 'TimerDungeonMonsterChange', --没杀死一个怪物刷新
	TimerDungeonWaveChange = 'TimerDungeonWaveChange', --每过一波刷新
	TimerDungeonEnterNum = 'TimerDungeonEnterNum', --返回进入次数
	TimerDungeonTimeNum = 'TimerDungeonTimeNum', --返回倒计时
	
	---------//定时副本组队协议
	TimeDungeonTeamRooomData = 'TimeDungeonTeamRooomData',  --所有房间信息
	TimeDungeonTeamMyRoom = 'TimeDungeonTeamMyRoom',  --自己的房间信息
	TimeDungeonRoomPrepare = 'TimeDungeonRoomPrepare',  --点击准备的返回
	QuitTimeDungeonRoom = 'QuitTimeDungeonRoom',  --退出房间返回
	
	--------有人要干我？------
	HavePlayerFuckME = 'NowPlayerFuckME',  --有人打我？
	-------计时副本------
	ExDungeonInfoMonsterUpData = 'ExDungeonInfoMonsterUpData', --计时副本信息面板小怪刷新
	ExDungeonInfoBossUpData = 'ExDungeonInfoBossUpData', --计时副本信息面板BOSS刷新
	
	-----------新版极限挑战-----------
	ExtremitChallengeUpData = 'ExtremitChallengeUpData',			--自己的UI信息
	ExtremitChallengeRankData = 'ExtremitChallengeRankData',		--排行榜list
	ExtremitChallengeBossData = 'ExtremitChallengeBossData',		--BOOS信息面板刷新
	ExtremitChallengeMonsterData = 'ExtremitChallengeMonsterData',	--怪物信息面板刷新
	ExtremitChallengeRankNum = 'ExtremitChallengeRankNum',			--预估排名
	ExtremitChallengeBackReward = 'ExtremitChallengeBackReward',	--返回领奖

	------全服排行------
	AllTheServerLvlListUpdata = "AllTheServerLvlListUpdata",
	AllTheServerFightListUpdata = "AllTheServerFightListUpdata",

	-- 采集打断-----
	RoleInterruptAutoCast = "RoleInterruptAutoCast",
	
	-------通天塔秒伤-------
	BabelSecondHarm = 'BabelSecondHarm',
	
	-------北仓街积分刷新--------
	BeicangjieUpData = 'BeicangjieUpData',
	BeicangjieTimeUpData = 'BeicangjieTimeUpData',
	BeicangjieRank = 'BeicangjieRank',
	BeicangJieKill = 'BeicangJieKill',  --累计击杀
	--怪物刷新机制
	BeicangjieBossTime = 'BeicangjieBossTime',
	BeicangjieNewBoss = 'BeicangjieNewBoss',
	BeicangjieMonsterNum = 'BeicangjieMonsterNum',
	
	-----------怪物攻城-------------
	MonsterSiegeWave		 = 	'MonsterSiegeWave',			--波数信息刷新
	MonsterSiegeKillInfo	 =	'MonsterSiegeKillInfo',		--击杀信息
	MonsterSiegeMonsterData	 =	'MonsterSiegeMonsterData',	--怪物数量变动
	MonsterSiegeReward		 =	'MonsterSiegeReward',		--攻城奖励
	MonsterSiegeRank		 =	'MonsterSiegeRank',			--BOSS击杀榜
	
	--------------福神降临--------------
	MascotComeUpDate		 =	'MascotComeUpDate',			--福神降临副本内信息改变
	MascotComeType			 =	'MascotComeType',			--福神降临副本类型
	MascotComeTime			 =	'MascotComeTime',			--福神降临副本时间刷新
	MascotComeNotice		 =	'MascotComeNotice',			--福神降临副本notice信息
	MascotComeKillID		 =	'MascotComeKillID',			--福神降临副本死亡怪物ID
	
	-- 运营活动 --
	OperActActiveState = "OperActActiveState", -- 运营活动激活状态更新 body: 运营活动id
	OperActObtainState = "OperActObtainState", -- 运营活动奖励获取状态更新 body: 运营活动id
	OperActTime        = "OperActTime", -- 运营活动时间更新 body: 运营活动id
	OperActRewardNum   = "OperActRewardNum", -- 运营活动奖励物品更新 body: 运营活动id
	OperActBtnUpDate   = "OperActBtnUpDate", 

	---------至尊王城UI -----------
	SuperGloryUnionRoleList = "SuperGloryUnionRoleList"; -- 帮派人物更新
	SuperGloryAllInfo = "SuperGloryAllInfo";
	SuperGloryRoleInfo = "SuperGloryRoleInfo";
	---------帮派王城战 -----------
	CityUnionWarResult = "CityUnionWarResult";  -- 结果
	CityUnionWarJishaListUpdata = "CityUnionWarJishaListUpdata"; -- 击杀更新
	CityUnionWarAllInfoUpdata = "CityUnionWarAllInfoUpdata"; -- 总信息
	CityUnionWarSuperState = "CityUnionWarSuperState";--建筑物状态
	---------帮派地宫争夺战 -----------
	UnionDiGongInfoUpdate = "UnionDiGongInfoUpdate";  -- 地宫信息更新
	UnionDiGongBidListUpdate = "UnionDiGongBidListUpdate"; -- 地宫竞标列表更新
	UnionDiGongWarUpdate = "UnionDiGongWarUpdate"; -- 地宫争夺战信息更新
	-------------仓库装备-------
	UnionWareHouseItemUpdate = "UnionWareHouseItemUpdate";
	UnionWareHouseOperInfo = "UnionWareHouseOperInfo"; 
	-------------灵兽印记
	SpiritWarPrintItemAdd = "SpiritWarPrintItemAdd";  -- 物品增加
	SpiritWarPrintItemRemove = "SpiritWarPrintItemRemove";--  物品删除
	SpiritWarPrintItemUpdata = "SpiritWarPrintItemUpdata"; -- 物品更新
	SpiritWarPrintItemSwap = "SpiritWarPrintItemSwap"; --物品交换
	SpiritWarPrintDebris = "SpiritWarPrintDebris"; --碎片更新
	SpiritWarPrintShoping = "SpiritWarPrintShoping"; -- shoping结果
	SpiritWarPrintUpdateDongTianLv = "SpiritWarPrintUpdateDongTianLv"; --洞天等级更新
	-------------成就
	AchievementUpData = 'AchievementUpData'; --成就数据更新
	AchievementPointUpData = 'AchievementPointUpData'; --成就点数更新
	
	-------------主宰之路
	DominateRouteUpData = 'DominateRouteUpData'; --有新副本出现
	DominateRouteMopupUpData = 'DominateRouteMopupUpData'; --副本扫荡
	DominateRouteTimeUpData = 'DominateRouteTimeUpData'; --扫荡计时
	DominateRouteBoxUpData = 'DominateRouteBoxUpData'; --领取宝箱
	DominateRouteAddJingLi = 'DominateRouteAddJingLi'; --精力 恢复

	DominateQuicklySaodangBackUpData = 'DominateQuicklySaodangBackUpData'; --副本一键扫荡
	DominateRouteNewOpen = 'DominateRouteNewOpen'; --每通关一次后侦听是否有新开启为通关的副本
	
	-------------V计划
	VFlagChange = "VFlagChange"; -- V计划状态变化

	-------------翅膀升星
	WingStarLevelUp = 'WingStarLevelUp';  --翅膀升星
	WingStarUpData = 'WingStarUpData';  --翅膀升星进度变化
	-----------骑战副本--------
	QiZhanDungeonUpDate = "QiZhanDungeonUpDate";--收到副本信息
	QiZhanDungeonInfoUpDate = "QiZhanDungeonInfoUpDate";--收到副本追踪面板信息
	QiZhanDungeonRewardUpDate = "QiZhanDungeonRewardUpDate";--收到骑战副本累计奖励信息
	-----------牧野之战副本--------
	MakinoBattleDungeonUpDate = "MakinoBattleDungeonUpDate";           --收到副本信息
	MakinoBattleRewardStateChange = "MakinoBattleRewardStateChange";   --收到首次通过奖励状态改变
	MakinoBattleCurrentWaveAndRewardChange = "MakinoBattleCurrentWaveAndRewardChange";   --收到波数和奖励改变
	MakinoBattleCurrentHpChange = "MakinoBattleCurrentHpChange";   --NPC血量改变
	
	-----------挑战副本--------
	DekaronDungeonUpDate = "DekaronDungeonUpDate";--收到挑战副本信息
	DekaronDungeonInfoUpDate = "DekaronDungeonInfoUpDate";--收到挑战副本追踪面板信息
	------------ 炼化
	EquipRefinUpdata = "EquipRefinUpdata"; --炼化信息更新

	--------------装备打造
	EquipBuildOpenList = "EquipBuildOpenList";
	EquipDecompResult = "EquipDecompResult";
	EquipBuildResultUpdata = "EquipBuildResultUpdata";
	
	-------骑战------------------
	QiZhanUpdate           = "QiZhanUpdate", --骑战信息更新
	QiZhanLevelUp          = "QiZhanLevelUp", --骑战升级
	QiZhanBlessing         = "QiZhanBlessing", --骑战进阶祝福值更新
	ChangeQiZhanModel      = "ChangeQiZhanModel", --切换骑战更新
	
	-------流水副本(灵路试炼)------------------
	WaterDungeonBestWave    = "WaterDungeonBestWave", -- 我的最佳波数更新
	WaterDungeonBestExp     = "WaterDungeonBestExp", -- 我的最佳经验更新
	WaterDungeonBestMonster = "WaterDungeonBestMonster", -- 我的最多杀怪更新
	WaterDungeonTimeUsed    = "WaterDungeonTimeUsed", -- 我的已用次数更新
	WaterDungeonRank        = "WaterDungeonRank", -- 排行更新
	WaterDungeonWave        = "WaterDungeonWave", -- 当前波数更新
	WaterDungeonWaveMonster = "WaterDungeonWaveMonster", -- 当前波怪物数更新
	WaterDungeonTotalMonster = "WaterDungeonTotalMonster", -- 累计怪物数量
	WaterDungeonExp         = "WaterDungeonExp", -- 本次参加流水副本累计经验
	WaterDungeonBufferTime  = "WaterDungeonBufferTime", -- 本次参加流水副本buffer增加时间
	WaterDungeonLossExp     = "WaterDungeonLossExp", -- 流水副本损失经验

	--------- 祈愿
	WishInfoUpdata = "WishInfoUpdata", --祈愿信息更新


	----------------寄售行
	ConsignmentBuyItemInfo = "ConsignmentBuyItemInfo",  -- 浏览购买物品信息
	ConsignmentBagIteminfo = "ConsignmentBagIteminfo",  -- 寄售行背包click物品
	ConsignmentMyProfitInfo = "ConsignmentMyProfitInfo", -- 我的盈利信息
	ConsignmentMyUpItemInfo = "ConsignmentMyUpItemInfo",-- 我的寄售物品信息
	ConsignmentMyUpItemNum = "ConsignmentMyUpItemNum",-- 我的寄售物品信息

	----------VIP--------------
	VipExp              = "VipExp", -- VIP经验
	VipPeriod           = "VipPeriod", -- VIP期限
	VipLevelRewardState = "VipLevelRewardState", -- VIP等级奖励领取状态
	VipWeekRewardState  = "VipWeekRewardState", -- VIP周奖励领取状态
	VipBackInfo         = "VipBackInfo", -- 返还信息
	VipBackInfoChange   = "VipBackInfoChange", -- 返还信息变化
	VipJihuoEffect   	= "VipJihuoEffect", -- vip激活特效
	----------挖宝
	WabaoinfoUpdata = "WabaoinfoUpdata";
	WabaoinfoPointUpdata = "WabaoinfoPointUpdata";
	WabaoinfoCancel= "WabaoinfoCancel";
	---------奇遇任务副本-----------
	RandomQuestAdd             = "RandomQuestAdd",   -- 奇遇任务增加
	RandomDungeonStep          = "RandomDungeonStep",   -- 奇遇任务副本 步骤
	RandomDungeonSubject       = "RandomDungeonSubject", -- 奇遇任务副本 题目
	RandomDungeonProgress      = "RandomDungeonProgress", -- 奇遇任务副本 进度
	RandomDungeonZazenTime     = "RandomDungeonZazenTime", -- 奇遇任务副本 多倍打坐副本时间变化
	RandomDungeonQuestionState = "RandomDungeonQuestionState", -- 奇遇任务副本 上个问题是否答对状态变化
	RandomDungeonReward 	   = "RandomDungeonReward", -- 奇遇奖励返回
	-------七日奖励---------
	WeekSignUpData		=		'WeekSignUpData',  --七日奖励刷新
	----------家园
	HomesteadBuildInfo = "HomesteadBuildInfo", -- 建筑物信息
	HomesteadMyPupilList = "HomesteadMyPupilList", -- 弟子信息
	HomesteadPupilList = "HomesteadPupilList", -- 寻仙台弟子信息
	HomesteadUpdatTime = "HomesteadUpdatTime", -- 倒计时更新
	HomesteadUpdatRodList = "HomesteadUpdatRodList", -- 抢夺任务列表
	HomesteadMyQuestUpdata = "HomesteadMyQuestUpdata", -- 我的任务列表更
	HomesteadQuestlistUpdata = "HomesteadQuestlistUpdata", --任务殿 列表
	------------------------跨服PVP---------------------------
	KuafuPvpInfoUpdate = "KuafuPvpInfoUpdate",
	KuafuPvpMatchStart = "KuafuPvpMatchStart",	
	KuafuPvpUpFirstRank = "KuafuPvpUpFirstRank",
	KuafuPvpExitCatching = "KuafuPvpExitCatching",
	SmallMapChangeLineVisible = "SmallMapChangeLineVisible",
	-------------------------圣诞节----------------------------
	ChristmasDonateUpData = "ChristmasDonateUpData",			--圣诞节兑换信息
	ChristmasDonateResult = "ChristmasDonateResult",			--圣诞节兑换结果
	ChristmasDonateReward = "ChristmasDonateReward",			--圣诞节兑换领奖结果
	-------------------------转生----------------
	ZhuanshengChange = "ZhuanshengChange",
	--
	InterServerState = "InterServerState",
	
	------------------------运营活动---------------------------
	OperActivityInitInfo = "OperActivityInitInfo",
	OperActivityInitState = "OperActivityInitState",--活动状态
	UpdateOperActBtnIconState = "UpdateOperActBtnIconState",--4个按钮的领奖状态
	UpdateOperActAwardState = "UpdateOperActAwardState",--领奖状态
	UpdateOperActPowerList = "UpdateOperActPowerList",--战力排行列表
	UpdateTeamBuyInfo = "UpdateTeamBuyInfo",--团购
	UpdateGroupInfo = "UpdateGroupInfo",--单个活动信息
	UpdateGroupItemList = "UpdateGroupItemList",--刷新页签列表
	UpdataShouChong = "UpdataShouChong",--首冲状态
	OpenChildPanelByGroupId = "OpenChildPanelByGroupId",--打开子面板
	UpdateTeamBuyFirstInfo = "UpdateTeamBuyFirstInfo",--首冲团购
	--
	GMListRefresh = "GMListRefresh",--GM列表刷新body:{type=类型}
	GMChatRefresh = "GMChatRefresh",--GM聊天刷新 body:{channel=channel}

	---------------------高级精炼
	EquipSeniorJinglian = 'EquipSeniorJinglian', ---高级精炼成功
	EquipSeniorJinglianLacky = 'EquipSeniorJinglianLacky', ---高级精炼幸运值
	EquipSeniorJinglianLose = 'EquipSeniorJinglianLose', ---高级精炼失败
	--------------------------------跨天推
	AcrossDayInform = "AcrossDayInform",
	Youxi360Update = "Youxi360Update",

	--------------------累计充值
	AddExpenseMoney = "AddExpenseMoney",
	------------------------屠魔徽章---------------------------
	BossMedalBossNum = "BossMedalBossNum",
	BossMedalLevel = "BossMedalLevel",
	BossMedalStar = "BossMedalStar",
	BossMedalGrowValue = "BossMedalGrowValue",
	BossMedalAutoLvUp = "BossMedalAutoLvUp",
	------------------结婚-------------------
	MarryStateChange = "MarryStateChange",
	------------------------神武---------------------------
	ShenWuLevel = "ShenWuLevel", -- {lvl = lvl, oldLvl = oldLvl}
	ShenWuStar = "ShenWuStar", -- {star = star, oldStar = oldStar} 
	ShenWuStone = "ShenWuStone", -- {num = num, oldNum = oldNum}
	ShenWuStarRate = "ShenWuStarRate", -- {starRate = starRate, oldStarRate = oldStarRate}
	--改名
	ChangePlayerName = "ChangePlayerName",
	-- 灵兽魂魄
	ShouHunLevel = "ShouHunLevel",
	ShouHunStar = "ShouHunStar",
	ShouHunAutoLevelUp = "ShouHunAutoLevelUp",
	-- 灵诀
	LingJuePro = "LingJuePro",
	
	------NEW------
	-- 法宝
	FabaoChange = "FabaoChange",
	FabaoListChange = "FabaoListChange",
	FabaoDevourResult = "FabaoDevourResult";
	FabaoCombineResult = "FabaoCombineResult";
	FabaoRebornResult = "FabaoRebornResult";
	FabaoLearnResult = "FabaoLearnResult";
	FabaoPick = "FabaoPick";
	
	--宝石镶嵌
	GemInlayInfoChange = "GemInlayInfoChange",
	GemInlayResult = "GemInlayResult",
	GemInlayUnResult = "GemInlayUnResult",
	GemInlayUpgradeResult = "GemInlayUpgradeResult",
	GemInlayChangeResult = "GemInlayChangeResult",
	-- -------------跨服场景
	InterSerSceneQuestUpdata = "InterSerSceneQuestUpdata", --任务更新
	InterSerSceneTeamUpdata = "InterSerSceneTeamUpdata", --组队更新
	--装备升星
	EquipStarResult = "EquipStarResult",
	EquipOpenStarResult = "EquipOpenStarResult",
	----------------------装备融合----------------------  ---add:hoxuudong  date：2016/5/6 18:45:03
	
	EquipMergeResult = "EquipMergeResult",

	-------------------------图鉴------------------------------
	FumoLvUpResult = "FumoLvUpResult",

	---------------------------------星图----------------------------------
	XingtuLvUpResult = "XingtuLvUpResult",
	XingtuLvUpResultFail = "XingtuLvUpResultFail",

	--------------------------------装备套装---------------------------
	EquipGroupOpenSlot = "EquipGroupOpenSlot",
	EquipGroupActive = "EquipGroupActive",
	EquipGroupUpdate = "EquipGroupUpdate",

	---------------------------------转职--------------------------------
	ZhuanZhiSuccess = "ZhuanZhiSuccess",
	ZhuanZhiUpdate = "ZhuanZhiUpdate",

	---------------------------------洗练--------------------------------
	WashUpdate = "WashUpdate",
	WashActive = "WashActive",
	WashChange = "WashChange",
	---------------------------------传承---------------------------------
	RespSuccess = "RespSuccess",
	------------------------------金币BOSS--------------------------------
	GoldenBossGotReward = "GoldenBossGotReward",
	GoldenBossUpdateBoss = "GoldenBossUpdateBoss",
	GoldenBossOnScene = "GoldenBossOnScene",
	------------------------------目标领取--------------------------------
	GoalListChange = "GoalListChange",

	----------------------技能提示---------------------- adder:houxudong date:2016/7/27 23:31:00
	RedPointSkill = "RedPointSkill",
	RedPointMagicSkill = "RedPointMagicSkill",
	RedPointXinfaSkill = "RedPointXinfaSkill",

	----------------------左戒-----------------------------------------
	RingUpGrade = "RingUpGrade",
	RingTaskUpdate = "RingTaskUpdate",


	---------------------天神附体-------------------------------------
	TianShenUpdate = "TianShenUpdate",
	TianShenChangeModel="TianShenChangeModel",
    TianShenStarUpdate ="TianShenStarUpdate",
    TianShenActiveUpdate="TianShenActiveUpdate",
    TianShenLevelUpdate="TianShenLevelUpdate",
    


	---------------------大摆筵席--------------------------adder:houxudong date:2016/8/17 23:10:25
	ChooseLunchSuc = "ChooseLunchSuc",
	ChooseLunchFailMoney = "ChooseLunchFailMoney",
	ChooseLunchFailVip = "ChooseLunchFailVip",
	LunchBackExp= "LunchBackExp",

	--------------------装备收集---------------------------------
	EquipCollectUpdate = "EquipCollectUpdate",
	--------------------修为池---------------------------------
	XiuweiPoolUpdate = "XiuweiPoolUpdate",
	--------------------讨伐副本---------------------------------
	TaofaInfoUpdate = "TaofaInfoUpdate",
	TaofaMonsterInfo = "TaofaMonsterInfo",
	--------------------集会所任务 新屠魔 新悬赏---------------------------------
	AgoraUpdateItem = "AgoraUpdateItem",
	AgoraAbandonItem = "AgoraAbandonItem",
	AgoraUpdateAll = "AgoraUpdateAll",
	--------------------资质丹相关---------------------
	MountZZChanged = "MountZZChanged",
	MagicWeaponZZChanged = "MagicWeaponZZChanged",
	LingQiZZChanged = "LingQiZZChanged",
	MingYuZZChanged = "MingYuZZChanged",
	ArmorZZChanged = "ArmorZZChanged",
	RealmZZChanged = "RealmZZChanged",
	UseZZDChanged    = "UseZZDChanged",--使用资质丹刷新
	-------------------圣物相关------------------------
	RelicUpdata = "RelicUpdata",

	-------------------new TianShen--------------------
	newtianShenUpUpdata = 'newtianShenUpUpdata',  --天神更新
	tianShenLvUpUpdata = "tianShenLvUpUpdata",  --天神升级数据更新
	tianShenStarUpUpdata = "tianShenStarUpUpdata",  --天神升星数据更新
	tianShenRespUpdata = "tianShenRespUpdata",  --天神传承数据更新
	tianShenComUpdata = "tianShenComUpdata",  --天神合成数据更新
	tianShenOutUpdata = "tianShenOutUpdata",  --天神出站更新
	tianShenDisUpdata = "tianShenDisUpdata",  --天神摧毁

	-------------------wan Channel---------------------
	wanChannelUpdata = "wanChannelUpdata",     --wan特殊渠道领取奖励更新
}
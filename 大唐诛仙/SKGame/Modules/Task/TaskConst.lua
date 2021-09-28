TaskConst = {}

-- TaskConst.TaskState = {
-- 	None = 0,
-- 	NotCompleted = 1, --任务没完成
-- 	HasCompleted = 2, --任务已经完成
-- 	HasAccept = 3, --任务已经领取
-- 	CanAccept = 4, --任务可领取
-- 	NotAccept = 5,	--任务不可领取
-- 	HasCommit = 6 --任务已经提交（并且完成）
-- }

--"类型:
--1=主线
--2=支线
--3=每日任务
--4=环任务
--5=猎妖任务
--6=引导任务"


TaskConst.TaskType = {
	None = 0,
	MainLine = 1, --主线任务
	BranchLine = 2, --支线任务
	DailyTask = 3, --每日任务
	CycleTask = 4, --环任务
	HuntingMonster = 5, --猎妖任务
	GuideTask = 6 --引导任务
}

--对应taskConfig配置表中的Target的内容Item的字段属性

TaskConst.TaskTargetField = {
	TargetType = 1,
	TargetParam = 2,

}

--[类型，物品编号，数量，是否绑定]
TaskConst.TaskRewardField = {
	ItemType = 1,
	ItemId = 2,
	ItemCnt = 3,
	IsBinding = 4
}

TaskConst.TaskTargetType = {
	None = 0,
	NPCInteraction = 1, --NPC对话交互
	UpgradeLevel = 2, --玩家升级
	CopyPass = 3, --副本通关
	KillMonster = 4, --击杀怪物

	WearEquipment = 5, --穿戴装备
	StrengthenEquipment = 6, --强化某部位装备到N级(注灵)
	UseGodFightRune = 7, --使用N次斗神印

	ActiveSkill = 8, --激活技能
	UpgradeSkill = 9, --升级技能
	CollectItem = 10,  --采集物品
	SwitchModelGuide = 11, --模式切换引导 

	GetItem = 12, --任务物品获取
	UseMedicine = 13, --装备药品
	Decompose = 14, --进行N次分解
	Compose = 15, --进行N次合成
	BuyItem = 16, --去交易行购买N次物品

	OperateTeam = 17, --进行组队操作
	JoinFamily = 18, --加入一个家庭
	AddFriend = 19, --加入一个好友

	RankMatchCounter = 20, --侍魂殿匹配n次
	ChatGuide = 21, --聊天引导
	ClimbTower = 22, --大荒塔引导
	FriendGuide = 23, --好友引导
	DailyTaskCounter = 24 , --完成n次悬赏任务
	CycleTaskCounter = 25 , --完成n次环任务
	ClimbTowerCounter = 26 ,  --通关到大荒塔n层
	HuntingMonsterCounter = 27 , --完成n次猎妖令任务
	ConsignForSale = 29 --寄售任务
}

TaskConst.NPCInteractionType = {
	None = 0,
	DialogTest = 1, --[主]对话任务测试
	UpgradeLevel = 2, --[主]升级任务测试
	CopyPass = 3, --通关副本
	KillMonster = 4, --[主]打怪任务测试

	WearEquipment = 5, --穿戴装备
	StrengthenEquipment = 6, --强化某部位装备到N级
	UseGodFightRune = 7, --使用N次斗神印

	ActiveSkill = 8, --激活技能
	UpgradeSkill = 9, --[主]技能升级测试
	CollectItem = 10, --采集物品
	SwitchModelGuide = 11, --模式切换引导

	GetItem = 12, --任务物品获取
	UseMedicine = 13, --装备药品
	Decompose = 14, --进行N次分解
	Compose = 15, --进行N次合成
	BuyItem = 16, --去交易行购买N次物品

	OperateTeam = 17, --进行组队操作
	JoinFamily = 18, --加入一个家庭
	AddFriend = 19, --加入一个好友

	RankMatchCounter = 20, --天梯引导
	ChatGuide = 21, --聊天引导
	ClimbTower = 22, --大荒塔引导
	FriendGuide = 23, --好友引导
	DailyTaskCounter = 24 , --完成n次悬赏任务
	CycleTaskCounter = 25 , --完成n次环任务
	ClimbTowerCounter = 26 ,  --通关到大荒塔n层
	HuntingMonsterCounter = 27, --完成n次猎妖令任务
	ConsignForSale = 29 --寄售任务
}

TaskConst.TaskTypeIcon = {
	BranchLine = "3",
	MainLine= "2",
	GuildLine = "1"
}

TaskConst.DramaField = {
	NPCID = 1,
	DialogContent = 2
}

TaskConst.NPCTaskDialogType = {
	None = 0,
	DramaType = 1, --领取任务对白
	SubmitTaskType = 2, --交任务
	SubmitTaskDramaType = 3 --交任务剧情对白
}

TaskConst.RewardItemType = {
	Equipment = 1, -- 装备
	Item = 2, 	   -- 物品
	Coin = 3,	 -- 金币
	Diamond = 4,   -- 钻石
	Bind_Diamond = 5, --绑钻
	Contribution = 6, --工会贡献
	Honor = 7,		  --荣誉
	Experience = 8	  --经验
}


TaskConst.TaskState = {
	NotFinish = 0,
	Finish = 1
}

TaskConst.AutoSubmit = {
	IsAuto = 1,
	NotAuto = 0
}

TaskConst.SkillTaskCareerOrder = {
	ZhanShi = 1,
	FaShi = 2,
	AnWu = 3
}

TaskConst.PathMethod = {
	None = 0,
	WorldPath = 1, --世界寻路方式，通过传送门
	LocalPath = 2  --本地寻路方式，不通过传送门，直接本地传送
}

--任务界面口风琴组件界面一级分类数据
TaskConst.TopType = {
	[1] = {1 , "主线任务" , {}},
	[2] = {2 , "支线任务" , {}},
	[3] = {3 , "悬赏任务" , {}},
	[4] = {4 , "环任务" , {}},
	[5] = {5 , "猎妖任务" , {}},
	[6] = {6 , "引导任务" , {}}
}

--任务的逻辑阶段（完全属于策划思维中的逻辑阶段）
--各个阶段分别为：任务接取   任务进行中  任务提交
TaskConst.LogicalStage = {
	None = 0,
	Accept = 1, --任务接取
	Execute = 2, --任务进行中
	Submit = 3 --任务提交
}

--环任务总数
TaskConst.CycleTaskSum = 100

TaskConst.DailyNPCID = 1105
TaskConst.CycleNPCID = 1101
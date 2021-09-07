ChildrenEumn = ChildrenEumn or {}

-- 格子下标转换成类型值
ChildrenEumn.PosToIndex = {5,4,2,3,1}
-- 类型值转换会格子下标
ChildrenEumn.IndexToPos = {5,3,4,2,1}

-- 孩子发育阶段
ChildrenEumn.Stage = {
	Fetus = 1, -- 胎儿
	Childhood = 2, -- 幼儿
	Adult = 3, -- 成年
}

-- 孩子状态
ChildrenEumn.Status = {
	Idel = 0, -- 休息
	Follow = 1, -- 跟随
	Offline = 2, -- 跟随下线
}

-- 孕育方式
ChildrenEumn.EmbryoType = {
	Single = 1, -- 单人
	Couple = 2, -- 双人
}

-- 职业类型
ChildrenEumn.ClassesType = {
	Phy = 1, -- 物理
	Mag = 2, -- 魔法
	Aid = 3, -- 辅助
}

-- 职业性别映射base_id
ChildrenEumn.BaseId = {
	["1_0"] = 1002,
	["1_1"] = 1001,
	["2_0"] = 1006,
	["2_1"] = 1005,
	["3_0"] = 1004,
	["3_1"] = 1003,
	["4_0"] = 1010,
	["4_1"] = 1009,
	["5_0"] = 1012,
	["5_1"] = 1011,
	["6_0"] = 1008,
	["6_1"] = 1007,
}

-- 学习类型
ChildrenEumn.StudyName = {
	[1] = TI18N("力量"),
	[2] = TI18N("体质"),
	[3] = TI18N("敏捷"),
	[4] = TI18N("智慧"),
	[5] = TI18N("品德"),
}

-- 学习类型资质
ChildrenEumn.StudyTypeName = {
	[1] = TI18N("物攻"),
	[2] = TI18N("生命"),
	[3] = TI18N("速度"),
	[4] = TI18N("法力"),
	[5] = TI18N("物防"),
}

ChildrenEumn.StudyLevelName = {
	[1] = TI18N("基础"),
	[2] = TI18N("高级"),
}

ChildrenEumn.ChildRemindTitle = 
{
    [1] = TI18N("不提醒我"),
    [2] = TI18N("低于20提醒我"),
    [3] = TI18N("低于60提醒我"),
    [4] = TI18N("低于80提醒我")
}
ChildrenEumn.ChildHappinessTitle = 
{
  [1] = TI18N("郁郁寡欢"),
  [2] = TI18N("黯然失色"),
  [3] = TI18N("心神不定"),
  [4] = TI18N("眉开眼笑"),
  [5] = TI18N("兴高采烈")
}

ChildrenEumn.ChildrenHungryNovice = 
{
  [1] = 0,
  [2] = 20,
  [3] = 60,
  [4] = 80
}
DailyTaskConst = {}

DailyTaskConst.MaxCycleNum = 10 --一天最大环数

DailyTaskConst.MaxCycleNumAsVip = 12 --VIP一天最大环数

DailyTaskConst.FreeRefershNum = 3 --免费刷新上限

DailyTaskConst.MaxTaskItemNum = 4 --最大的任务个数

DailyTaskConst.MaxRewardNum = 2 --最大的奖励种类个数

DailyTaskConst.DifficultyLevel = 
{
	None = 0,
	Easy = 1,
	Normal = 2,
	Difficulty = 3,
	DifficultyII = 4,

}

--任务难度对应的背景框
--依次为简单、普通、困难、
DailyTaskConst.DifficultyBG =
{
	[DailyTaskConst.DifficultyLevel.Easy] = "zhuangshi5",
	[DailyTaskConst.DifficultyLevel.Normal] = "zhuangshi7",
	[DailyTaskConst.DifficultyLevel.Difficulty] = "zhuangshi6",
	[DailyTaskConst.DifficultyLevel.DifficultyII] = "zhuangshi6",
}

DailyTaskConst.DifficultyDesc = 
{
	[DailyTaskConst.DifficultyLevel.Easy] = "简单",
	[DailyTaskConst.DifficultyLevel.Normal] = "普通",
	[DailyTaskConst.DifficultyLevel.Difficulty] = "困难",
	[DailyTaskConst.DifficultyLevel.DifficultyII] = "地狱",
}

DailyTaskConst.DifficultyStar = 
{
	[DailyTaskConst.DifficultyLevel.Easy] = "zhuangshi2",
	[DailyTaskConst.DifficultyLevel.Normal] = "zhuangshi3",
	[DailyTaskConst.DifficultyLevel.Difficulty] = "zhuangshi4",
	[DailyTaskConst.DifficultyLevel.DifficultyII] = "zhuangshi4",
}


DailyTaskConst.StarItemBGURL = "zhuangshi"

DailyTaskConst.RefershConsumeCnt = 3

DailyTaskConst.RefershType = {
	Free = 1,
	Diamond = 2
}
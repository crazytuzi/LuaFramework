--[[
主线任务副本的公用方法
houxudong
2016年9月5日 16:33:25
]]

_G.TrunkDungeonUtil = {};

function TrunkDungeonUtil:GetTrunkDungeonNum(questId)
	if questId == QuestConsts.LastDungeonQuest then
		return 1;
	elseif questId == QuestConsts.LastDungeonQuestTwo then
		return 2;
	elseif questId == QuestConsts.LastDungeonQuestThree then
		return 3;
	elseif questId == QuestConsts.LastDungeonQuestFour then
		return 4;
	elseif questId == QuestConsts.LastDungeonQuestFive then
		return 5;
	end	
	return 0;
end

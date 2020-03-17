--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/11/11
    Time: 16:12
   ]]
_G.XianYuanUtil = {};

function XianYuanUtil:GetLeftTime()
	if not UIXianYuanCave.onLineTimeData then
		return 0
	end
	if not UIXianYuanCave.onLineTimeData[ActivityConsts.T_DaBaoMiJing] then
		return 0
	end
	local timeNum;
	timeNum = UIXianYuanCave.onLineTimeData[ActivityConsts.T_DaBaoMiJing].timeNum;
	local onLineMin = toint(timeNum/60);
	return onLineMin;
end

function XianYuanUtil:UpdateToQuest()
	if not FuncManager:GetFuncIsOpen(FuncConsts.DaBaoMiJing) then return; end
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_XianYuanCave, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;

	local timeAvailable = self:GetLeftTime();
	if QuestModel:GetQuest(questId) then
		if timeAvailable <= 0 then
			QuestModel:Remove(questId);
		else
			QuestModel:UpdateQuest( questId, 0, state, goals )
		end
	else
		if timeAvailable <= 0 then
			return;
		end
		QuestModel:AddQuest( questId, 0, state, goals )
	end
end
--[[
    Created by IntelliJ IDEA.
    组队经验副本
    User: Hongbin Yang
    Date: 2016/8/23
    Time: 22:34
   ]]



_G.TeamExpDungeonFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.teamExper, TeamExpDungeonFunc);

function TeamExpDungeonFunc:OnFuncOpen()
	local enterNum = TimeDungeonModel:GetEnterNum(); --今日剩余次数
	if not enterNum then return; end
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_Team_EXP_Dungeon, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	if QuestModel:GetQuest(questId) then
		QuestModel:UpdateQuest( questId, 0, state, goals )
	else
		QuestModel:AddQuest( questId, 0, state, goals )
	end
end

function TeamExpDungeonFunc:SetState(state)
	if state == FuncConsts.State_Open then
		self:OnFuncOpen();
	end
	self.state = state;
end

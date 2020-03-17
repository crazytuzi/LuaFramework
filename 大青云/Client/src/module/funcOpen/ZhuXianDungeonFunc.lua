--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/11/11
    Time: 18:27
   ]]

_G.ZhuXianDungeonFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.zhuxianDungeon, ZhuXianDungeonFunc);

function ZhuXianDungeonFunc:OnFuncOpen()
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_GodDynasty, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	if QuestModel:GetQuest(questId) then
		QuestModel:UpdateQuest( questId, 0, state, goals )
	else
		QuestModel:AddQuest( questId, 0, state, goals )
	end
end

function ZhuXianDungeonFunc:SetState(state)
	if state == FuncConsts.State_Open then
		self:OnFuncOpen();
	end
	self.state = state;
end
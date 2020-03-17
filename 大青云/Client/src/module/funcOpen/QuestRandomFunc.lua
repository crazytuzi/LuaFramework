--[[
    Created by IntelliJ IDEA.
    奇遇任务
    User: Hongbin Yang
    Date: 2016/9/5
    Time: 16:49
   ]]


_G.QuestRandomFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.QuestRandom, QuestRandomFunc);

function QuestRandomFunc:OnFuncOpen()
	if QuestModel:HasRandomQuest() == false and QuestModel.randomQuestFinishedCount < RandomQuestConsts:GetRoundsPerDay() then
		QuestModel:AddNoneRandomQuest();
	end
end

function QuestRandomFunc:SetState(state)
	if state == FuncConsts.State_Open then
		self:OnFuncOpen();
	end
	self.state = state;
end

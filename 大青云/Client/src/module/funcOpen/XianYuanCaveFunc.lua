--[[
仙缘洞府特效
wangyanwei
2015年4月22日15:00:00
]]

_G.XianYuanCaveFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.XianYuanCave,XianYuanCaveFunc);



function XianYuanCaveFunc:OnBtnInit()
	-- if self.button.initialized then
	-- 	if self.button.effect.initialized then
	-- 		self.button.effect:playEffect(0);
	-- 	else
	-- 		self.button.effect.init = function()
	-- 			self.button.effect:playEffect(0);
	-- 		end
	-- 	end
	-- end
end

function XianYuanCaveFunc:OnFuncOpen()
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_XianYuanCave, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	if QuestModel:GetQuest(questId) then
		QuestModel:UpdateQuest( questId, 0, state, goals )
	else
		QuestModel:AddQuest( questId, 0, state, goals )
	end
end

function XianYuanCaveFunc:SetState(state)
	if state == FuncConsts.State_Open then
		self:OnFuncOpen();
	end
	self.state = state;
end
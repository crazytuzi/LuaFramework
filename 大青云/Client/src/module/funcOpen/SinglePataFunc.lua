--[[
单人爬塔功能
houxudong
2016年9月12日 17:10:25
]]

_G.SinglePataFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.Babel,SinglePataFunc);

SinglePataFunc.timerKey = nil;


function SinglePataFunc:OnBtnInit()

	if self.button.initialized then
		if self.button.effect.initialized then
			-- self.button.effect:playEffect(0);   --暂时屏蔽
		else
			self.button.effect.init = function()
				-- self.button.effect:playEffect(0); 
			end
		end
	end
	self:RegisterTimes()
	self:InitRedPoint()
end

function SinglePataFunc:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timekey)
		self.timekey = nil;
	end
end

function SinglePataFunc:InitRedPoint()
	local width = self.button._width;
	self.timerKey = TimerManager:RegisterTimer(function()
		local isCan,enterNum = DungeonUtils:CheckPataDungen()
		-- local isCan2,enterNum2 = DungeonUtils:CheckGodDynastyDungen()
		-- local timeDungeonCanEnter,num4 = DungeonUtils:CheckQizhanDungen()
		-- local makinoBattleCanEnter,num6 = DungeonUtils:CheckMakinoBattleDungen( )
		local num = enterNum or 0
		if isCan then
			PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, num)
		else
			PublicUtil:SetRedPoint(self.button, RedPointConst.showNum, 0)
		end
	end,1000,0); 
end

function SinglePataFunc:OnFuncOpen()
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_Babel, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	if QuestModel:GetQuest(questId) then
		QuestModel:UpdateQuest( questId, 0, state, goals )
	else
		QuestModel:AddQuest( questId, 0, state, goals )
	end
end

function SinglePataFunc:SetState(state)
	if state == FuncConsts.State_Open then
		self:OnFuncOpen();
	end
	self.state = state;
end
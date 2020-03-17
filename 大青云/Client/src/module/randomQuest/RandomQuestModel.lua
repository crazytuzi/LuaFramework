--[[
奇遇任务 Model
2015年7月29日17:03:01
haohu
]]
--------------------------------------------------------------

_G.RandomQuestModel = Module:new()

RandomQuestModel.questId = nil
RandomQuestModel.dungeon = nil
RandomQuestModel.isTodayFinish = false
RandomQuestModel.isRandomQuest = false
RandomQuestModel.isRandomReward = false

function RandomQuestModel:AddQuest( qiyuId, state, round )
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_Random, qiyuId )
	self.questId = questId
	local goals = { { current_goalsId = 0, current_count = 0 } }
	local flag = {qiyuId = qiyuId, round = round}
	QuestModel:AddQuest( questId, flag, state, goals )
	self:sendNotification( NotifyConsts.RandomQuestAdd )
end

function RandomQuestModel:UpdateQuest( qiyuId, state, count )
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_Random, qiyuId )
	local goals = { { current_goalsId = 0, current_count = count } }
	QuestModel:UpdateQuest( questId, qiyuId, state, goals )
end

function RandomQuestModel:RemoveQuest( qiyuId )
	self.questId = nil
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_Random, qiyuId )
	QuestModel:FinishQuest( questId )
	local questVO = QuestModel:Remove( questId )
	--
	if questVO.round==t_consts[89].val1 then
		local cfg = t_qiyuzu[qiyuId];
		if cfg and cfg.step==3 then
			QuestGuideManager:DoTrunkBreak();
		end
	end
end

function RandomQuestModel:GetQuest()
	return QuestModel:GetQuest( self.questId )
end

function RandomQuestModel:IsTodayFinish()
	local RQFuncOpen = FuncManager:GetFuncIsOpen( FuncConsts.RandomQuest )
	return RQFuncOpen and self.questId == nil
end

-- RandomDungeon
function RandomQuestModel:GetDungeon()
	return self.dungeon
end

-- @ param dungeon: RandomDungeon
function RandomQuestModel:SetDungeon( dungeon )
	if dungeon == nil and self.dungeon ~= nil then
		self.dungeon:OnExit()
		self.dungeon = nil
		return
	end
	self.dungeon = dungeon
	self.dungeon:OnEnter()
end

function RandomQuestModel:GetDungeonStep()
	return self.dungeon and self.dungeon:GetStep()
end

function RandomQuestModel:SetDungeonStep(step)
	local dungeon = self.dungeon
	if not dungeon then return end
	if dungeon:SetStep( step ) then
		self:sendNotification( NotifyConsts.RandomDungeonStep )
	end
end

function RandomQuestModel:IsInDungeon()
	return self.dungeon ~= nil
end

function RandomQuestModel:GetStepSubject()
	local dungeon = self.dungeon
	return dungeon and dungeon:GetSubject()
end

function RandomQuestModel:SetStepSubject( subjectId )
	local dungeon = self.dungeon
	if not dungeon then return end
	local subject = RandomDungeonQuestion:new( subjectId )
	dungeon:SetSubject( subject )
	self:sendNotification( NotifyConsts.RandomDungeonSubject )
end

function RandomQuestModel:GetStepProgress()
	return self.dungeon and self.dungeon:GetProgress()
end

function RandomQuestModel:SetStepProgress(progress)
	local dungeon = self.dungeon
	if not dungeon then return end
	if dungeon:SetProgress( progress ) then
		self:sendNotification( NotifyConsts.RandomDungeonProgress )
	end
end

function RandomQuestModel:GetIsRandomQuest()
	return self.isRandomQuest;
end
function RandomQuestModel:SetIsRandomQuest(flag)
	self.isRandomQuest = flag;
end

function RandomQuestModel:GetIsRandomReward()
	return self.isRandomReward;
end
function RandomQuestModel:SetIsRandomReward(flag)
	self.isRandomReward = flag;
end

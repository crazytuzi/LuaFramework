--[[
卓越引导
lizhuangzhuang
2015年8月2日15:39:20
]]

_G.ZhuoyueGuideModel = Module:new();

--当前阶段id
ZhuoyueGuideModel.id = 0;
--当前阶段状态
ZhuoyueGuideModel.state = 0;

--最高阶段id
ZhuoyueGuideModel.maxId = 0;

--是否已添加到任务
ZhuoyueGuideModel.hasAddToQuest = false;

function ZhuoyueGuideModel:Init()
	for _,cfg in pairs(t_zhuoyueguide) do
		if cfg.id > self.maxId then
			self.maxId = cfg.id;
		end
	end
end

function ZhuoyueGuideModel:SetInfo(id,state)
	self.id = id;
	self.state = state;
	--加到任务追踪
	self:UpdateToQuest();
end

--同步到任务追踪
function ZhuoyueGuideModel:UpdateToQuest()
	--没到开启等级前,不同步
	if MainPlayerModel.humanDetailInfo.eaLevel < t_consts[92].val1 then
		return;
	end
	--
	local questId = QuestUtil:GenerateQuestId( QuestConsts.Type_Super, 0 );
	local goals = { { current_goalsId = 0, current_count = 0 } };
	local state = QuestConsts.State_Going;
	if self.id == 0 then
		if self.hasAddToQuest then
			QuestModel:Remove( questId );
			self.hasAddToQuest = false;
		end
	else
		if self.hasAddToQuest then
			QuestModel:UpdateQuest( questId, 0, state, goals )
		else
			QuestModel:AddQuest( questId, 0, state, goals )
			self.hasAddToQuest = true;
		end
	end
end

function ZhuoyueGuideModel:GetId()
	return self.id;
end

function ZhuoyueGuideModel:GetState()
	return self.state;
end

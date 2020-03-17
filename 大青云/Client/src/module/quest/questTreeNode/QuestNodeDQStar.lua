--[[
主界面任务追踪树节点：日环星级
2015年5月11日18:05:40
haohu
]]

_G.QuestNodeDQStar = QuestNode:new( QuestNodeConst.Node_DQStar )

-- content = dailyQuestVO;

function QuestNodeDQStar:GetLabel()
	local label = StrConfig['quest144']
	return string.format( "   %s", label ); -- 内容节点缩进一个字
end

-- 获取任务类型
function QuestNodeDQStar:GetQuestType()
	local quest = self:GetContent();
	return quest:GetType()
end

function QuestNodeDQStar:HasStar()
	return true
end

function QuestNodeDQStar:GetStar()
	local quest = self:GetContent()
	return quest:GetStarLvl()
end

function QuestNodeDQStar:HasAddStarBtn()
	return self:GetStar() < QuestConsts.QuestDailyMaxStar
end

function QuestNodeDQStar:HasAddStarEffect()
	local quest = self:GetContent()
	return quest:IsNeedStarPrompt()
end

function QuestNodeDQStar:OnRollOver()
--	TipsManager:ShowTips( TipsConsts.Type_Normal, StrConfig['quest402'], TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function QuestNodeDQStar:OnAddStarClick()
	local quest = self:GetContent()
	local questId = quest:GetId();
	if questId then
		QuestController:ReqAddStar( questId );
	end
end

function QuestNodeDQStar:OnAddStarRollOver(e)
	local itemRenderer = e.renderer
	if itemRenderer then
		itemRenderer:previewFullStar(true)
	end
	local tipsTxt = string.format( StrConfig['quest107'], QuestConsts:GetAddStarCost() );
	TipsManager:ShowTips( TipsConsts.Type_Normal, tipsTxt, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function QuestNodeDQStar:OnAddStarRollOut(e)
	local itemRenderer = e.renderer
	if itemRenderer then
		itemRenderer:previewFullStar(false)
	end
	TipsManager:Hide();
end
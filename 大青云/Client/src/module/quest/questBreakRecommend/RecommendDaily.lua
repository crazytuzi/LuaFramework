--[[
    Created by IntelliJ IDEA.
    断档推荐 日环
    User: Hongbin Yang
    Date: 2016/11/11
    Time: 15:16
   ]]


_G.RecommendDaily = QuestBreakRecommend:new()


function RecommendDaily:Init(param)
end

function RecommendDaily:GetType()
	return QuestConsts.RecommendType_Daily
end

function RecommendDaily:GetLabel()
	return string.format( StrConfig['quest605'], StrConfig["quest927"] )
end

function RecommendDaily:DoRecommend()
	local quest = QuestModel:GetDailyQuest()
	if not quest then return; end
	quest:OnTitleClick();
--	QuestGuideManager:DoDayGuide()
end

function RecommendDaily:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendDaily:CheckEnterCondition()
	return QuestModel.dqState ~= nil and QuestModel.dqState ~= QuestConsts.QuestDailyStateNone and QuestModel.dqState ~= QuestConsts.QuestDailyStateFinish and QuestModel:GetDailyQuest();
end

function RecommendDaily:IsAvailable()
	return self:CheckEnterCondition();
end
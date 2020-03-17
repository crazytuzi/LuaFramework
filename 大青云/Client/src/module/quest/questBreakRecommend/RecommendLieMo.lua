--[[
    Created by IntelliJ IDEA.
    
    User: Hongbin Yang
    Date: 2016/11/13
    Time: 20:15
   ]]



_G.RecommendLieMo = QuestBreakRecommend:new()


function RecommendLieMo:Init(param)
end

function RecommendLieMo:GetType()
	return QuestConsts.RecommendType_LieMo
end

function RecommendLieMo:GetLabel()
	return string.format( StrConfig['quest605'], StrConfig["quest936"] )
end

function RecommendLieMo:DoRecommend()
	local quest = QuestModel:GetLieMoQuest()
	if not quest then return; end
	quest:OnTitleClick();
--	QuestGuideManager:DoTaoFaGuide()
end

function RecommendLieMo:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendLieMo:CheckEnterCondition()
	return QuestModel.lmState ~= nil and QuestModel.lmState ~= QuestLieMoConsts.QuestLieMoStateNone and QuestModel.lmState ~= QuestLieMoConsts.QuestLieMoStateFinish and QuestModel:GetLieMoQuest();
end

function RecommendLieMo:IsAvailable()
	return self:CheckEnterCondition();
end
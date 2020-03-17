--[[
    Created by IntelliJ IDEA.
    任务断档推荐 仙阶
    User: Hongbin Yang
    Date: 2016/7/25
    Time: 10:15
   ]]


_G.RecommendHuoYueDu = QuestBreakRecommend:new()

RecommendHuoYueDu.funcId = nil

function RecommendHuoYueDu:Init(param)
	if #param < 2 then
		Error("quest break recommend config error")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendHuoYueDu:GetType()
	return QuestConsts.RecommendType_HuoYueDu
end

function RecommendHuoYueDu:GetLabel()
	local cfg = t_funcOpen[self.funcId]
	local name = cfg.name
	return string.format( StrConfig['quest604'], name )
end

function RecommendHuoYueDu:DoRecommend()
	FuncManager:OpenFunc( self.funcId )
end

function RecommendHuoYueDu:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendHuoYueDu:CheckEnterCondition()
	return true
end

function RecommendHuoYueDu:IsAvailable()
	return FuncManager:GetFuncIsOpen( self.funcId );
end
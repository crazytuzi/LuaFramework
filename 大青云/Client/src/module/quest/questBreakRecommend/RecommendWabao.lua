--[[
任务断档推荐 挖宝
2015年10月11日10:16:45
haohu
]]
-------------------------------------------------------------



_G.RecommendWabao = QuestBreakRecommend:new()

RecommendWabao.funcId = nil

function RecommendWabao:Init(param)
	if #param < 2 then
		Error("quest break recommend config error")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendWabao:GetType()
	return QuestConsts.RecommendType_Wabao
end

function RecommendWabao:GetLabel()
	local cfg = t_funcOpen[self.funcId]
	local name = cfg.name
	return string.format( StrConfig['quest604'], name )
end

function RecommendWabao:DoRecommend()
	FuncManager:OpenFunc( self.funcId )
end

function RecommendWabao:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendWabao:CheckEnterCondition()
	return true
end

function RecommendWabao:IsAvailable()
	return FuncManager:GetFuncIsOpen( self.funcId ) and not WaBaoModel:GetTodayFinish2()
end
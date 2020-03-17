--[[
任务断档推荐 悬赏
2015年10月11日10:16:45
haohu
]]
-------------------------------------------------------------


_G.RecommendFengyao = QuestBreakRecommend:new()

RecommendFengyao.funcId = nil

function RecommendFengyao:Init(param)
	if #param < 2 then
		Error("quest break recommend config error")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendFengyao:GetType()
	return QuestConsts.RecommendType_Fengyao
end

function RecommendFengyao:GetLabel()
	local cfg = t_funcOpen[self.funcId]
	local name = cfg.name
	return string.format( StrConfig['quest604'], name )
end

function RecommendFengyao:DoRecommend()
	FuncManager:OpenFunc( self.funcId )
end

function RecommendFengyao:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendFengyao:CheckEnterCondition()
	return true
end

function RecommendFengyao:IsAvailable()
	return FuncManager:GetFuncIsOpen( self.funcId ) and not FengYaoModel:GetTodayFinish()
end
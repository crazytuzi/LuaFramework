--[[
任务断档推荐：推荐灵光封魔
2015年6月10日17:29:58
haohu
]]
-------------------------------------------------------------

_G.RecommendTimeDungeon = QuestBreakRecommend:new()

RecommendTimeDungeon.funcId = nil

function RecommendTimeDungeon:Init(param)
	if #param < 2 then
		Error("quest break recommend config error")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendTimeDungeon:GetType()
	return QuestConsts.RecommendType_TimeDugeon
end

function RecommendTimeDungeon:GetLabel()
	local cfg = t_funcOpen[self.funcId]
	local name = cfg.name
	return string.format( StrConfig['quest604'], name )
end

function RecommendTimeDungeon:DoRecommend()
	FuncManager:OpenFunc( self.funcId )
end

function RecommendTimeDungeon:GetTipsTxt()
	local result, reason = TimeDungeonModel:GetIsOpenTimeDungeon()
	if not result and reason == -2 then -- 进入等级不足
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendTimeDungeon:IsAvailable()
	if not FuncManager:GetFuncIsOpen( self.funcId ) then -- 功能未开启
		return false
	end
	local result, reason = TimeDungeonModel:GetIsOpenTimeDungeon()
	if not result and reason == -3 then -- 进入次数不足
		return false
	end
	return true
end

function RecommendTimeDungeon:ListNotificationInterests()
	return {
		NotifyConsts.TimerDungeonEnterNum
	}
end
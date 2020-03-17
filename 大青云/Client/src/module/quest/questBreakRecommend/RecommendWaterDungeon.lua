--[[
任务断档推荐：流水副本
2015年6月26日11:20:03
haohu
]]
-------------------------------------------------------------

_G.RecommendWaterDungeon = QuestBreakRecommend:new()

RecommendWaterDungeon.funcId = nil

function RecommendWaterDungeon:Init(param)
	if #param < 2 then
		Error("quest break recommend config error RecommendType_WaterDungeon")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendWaterDungeon:GetType()
	return QuestConsts.RecommendType_WaterDungeon
end

function RecommendWaterDungeon:GetLabel()
	local cfg = t_funcOpen[FuncConsts.experDungeon]
	local name = cfg.name
	return string.format( StrConfig['quest604'], name )
end

function RecommendWaterDungeon:DoRecommend()
	FuncManager:OpenFunc( FuncConsts.experDungeon )
end

function RecommendWaterDungeon:GetTipsTxt()
	return StrConfig['quest701']
end

function RecommendWaterDungeon:IsAvailable()
	if not FuncManager:GetFuncIsOpen( FuncConsts.experDungeon ) then
		return false
	end
	if WaterDungeonModel:GetDayFreeTime() <= 0 then
		return false
	end
	return true
end

function RecommendWaterDungeon:ListNotificationInterests()
	return {
		NotifyConsts.WaterDungeonTimeUsed
	}
end
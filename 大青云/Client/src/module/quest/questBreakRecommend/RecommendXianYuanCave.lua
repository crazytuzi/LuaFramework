--[[
    Created by IntelliJ IDEA.
    任务断档推荐 锁妖塔
    User: Hongbin Yang
    Date: 2016/8/19
    Time: 16:49
   ]]


_G.RecommendXianYuanCave = QuestBreakRecommend:new()

RecommendXianYuanCave.funcId = nil

function RecommendXianYuanCave:Init(param)
	if #param < 2 then
		Error("quest break recommend config error")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendXianYuanCave:GetType()
	return QuestConsts.RecommendType_XianYuanCave;
end

function RecommendXianYuanCave:GetLabel()
	local cfg = t_funcOpen[FuncConsts.DaBaoMiJing]
	local name = cfg.name
	return string.format( StrConfig['quest604'], name )
end

function RecommendXianYuanCave:DoRecommend()
	FuncManager:OpenFunc( FuncConsts.DaBaoMiJing )
end

function RecommendXianYuanCave:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendXianYuanCave:CheckEnterCondition()
	return FuncManager:GetFuncIsOpen(FuncConsts.DaBaoMiJing)
end

function RecommendXianYuanCave:IsAvailable()
	return FuncManager:GetFuncIsOpen( FuncConsts.DaBaoMiJing ) and XianYuanUtil:GetLeftTime() > 0
end
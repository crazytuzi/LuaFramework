--[[
    Created by IntelliJ IDEA.
    断档推荐 讨伐
    User: Hongbin Yang
    Date: 2016/11/11
    Time: 15:16
   ]]


_G.RecommendGodDynasty = QuestBreakRecommend:new()

RecommendGodDynasty.funcId = nil

function RecommendGodDynasty:Init(param)
	if #param < 2 then
		Error("quest break recommend config error, RecommendGodDynasty")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendGodDynasty:GetType()
	return QuestConsts.RecommendType_GodDynasty
end

function RecommendGodDynasty:GetLabel()
	local cfg = t_funcOpen[FuncConsts.zhuxianDungeon]
	local name = cfg.name
	return string.format( StrConfig['quest605'], name )
end

function RecommendGodDynasty:DoRecommend()
	FuncManager:OpenFunc(FuncConsts.zhuxianDungeon)
end

function RecommendGodDynasty:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendGodDynasty:CheckEnterCondition()
	return FuncManager:GetFuncIsOpen(FuncConsts.zhuxianDungeon)
end

function RecommendGodDynasty:IsAvailable()
	return FuncManager:GetFuncIsOpen(FuncConsts.zhuxianDungeon) and DungeonUtils:CheckGodDynastyDungen()
end
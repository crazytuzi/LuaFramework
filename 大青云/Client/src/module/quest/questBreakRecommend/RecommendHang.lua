--[[
任务断档推荐：推荐挂机
2015年6月10日16:52:13
haohu
]]
-------------------------------------------------------------

_G.RecommendHang = QuestBreakRecommend:new()

RecommendHang.monsterId = nil -- 怪物坐标
RecommendHang.posId = nil -- 位置坐标

RecommendHang.isAvailable = true -- 是否显示

function RecommendHang:Init(param)
	if #param < 3 then
		Error("quest break recommend config error")
		return
	end
	self.monsterId = tonumber( param[2] )
	self.posId     = tonumber( param[3] )
end

function RecommendHang:GetType()
	return QuestConsts.RecommendType_Hang
end

function RecommendHang:GetLabel()
	local monsterCfg = t_monster[self.monsterId]
	if not monsterCfg then return "monster id error" end
	return string.format( StrConfig['quest602'], monsterCfg.name, monsterCfg.level ); 
end

function RecommendHang:DoRecommend()
	local pos = QuestUtil:GetQuestPos( self.posId )
	if not pos then return end
	local completeFunc = function()
		AutoBattleController:SetAutoHang();
	end
	MainPlayerController:DoAutoRun( pos.mapId, _Vector3.new( pos.x, pos.y, 0 ), completeFunc );
end

function RecommendHang:GetTipsTxt()
	return StrConfig['quest701']
end

-- 是否可用，判断在主界面追踪树显示
function RecommendHang:IsAvailable()
	return self.isAvailable
end

function RecommendHang:CanTeleport()
	return true
end

function RecommendHang:GetGoalPos()
	return QuestUtil:GetQuestPos( self.posId );
end

function RecommendHang:GetTeleportType()
	return MapConsts.Teleport_Recommend_Hang;
end
-- 传送完成
function RecommendHang:OnTeleportDone()
	self:DoRecommend();
end
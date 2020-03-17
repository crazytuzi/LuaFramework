--[[
任务断档推荐：推荐副本
2015年6月10日16:52:13
haohu
]]
-------------------------------------------------------------

_G.RecommendDungeon = QuestBreakRecommend:new()

RecommendDungeon.dungeonId = nil

function RecommendDungeon:Init(param)
	if #param < 2 then
		Error("quest break recommend config error")
		return
	end
	self.dungeonId = tonumber( param[2] )
end

function RecommendDungeon:GetType()
	return QuestConsts.RecommendType_Dungeon
end

function RecommendDungeon:GetLabel()
	local cfg = t_dungeons[self.dungeonId]
	local name = cfg.name
	return string.format( StrConfig['quest603'], name )
end

function RecommendDungeon:DoRecommend()
	FuncManager:OpenFunc( FuncConsts.Dungeon, false, self.dungeonId )
end

function RecommendDungeon:GetTipsTxt()
	return StrConfig['quest701']
end

function RecommendDungeon:IsAvailable()
	if not FuncManager:GetFuncIsOpen( FuncConsts.Dungeon ) then
		return false
	end
	if not self:CheckEnterCondition() then
		return false
	end
	return true
end

function RecommendDungeon:CheckEnterCondition()
	local cfg = t_dungeons[self.dungeonId]
	if not cfg then return
		string.format( "quest config missing:%s", self.dungeonId )
	end
	local group = cfg.group
	local dungeonGroup = DungeonModel:GetDungeonGroup( group )
	if not dungeonGroup then return end
	-- if not dungeonGroup:IsUnlocked() then -- 未解锁的通过配表控制，任务等级不超过副本解锁等级的，不应配置副本推荐
	-- 	return false, -1
	-- end
	-- if not dungeonGroup:IsAvailable() then -- 同上，通过配表控制，任务等级不超过副本可用等级的，不应配置副本推荐
	-- 	return false, -2
	-- end
	if not dungeonGroup:HasRestTimes() then
		return false, -3
	end
	return true
end

function RecommendDungeon:ListNotificationInterests()
	return {
		NotifyConsts.DungeonGroupChange,
	}
end

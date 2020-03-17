--[[
选中目标相关常量
郝户
2014年9月15日19:26:10
]]

_G.TargetConsts = {}

--选中目标类型(影响选中目标头像显示类型)
TargetConsts.TargetType = {
	Player = "player";
	Monster = "monster";
	Boss = "boss";
}

--目标类型与面板的映射
local targetPanelMap
function TargetConsts:GetTargetPanelMap()
	if not targetPanelMap then
		targetPanelMap = {
			[TargetConsts.TargetType.Player]  = UITargetPlayer,   -- 选中目标玩家
			[TargetConsts.TargetType.Monster] = UITargetMonster,  -- 选中怪物
			[TargetConsts.TargetType.Boss]    = UITargetBoss      -- 选中BOSS
		}
	end
	return targetPanelMap
end

--获取选中目标的类型
function TargetConsts:GetTargetType(charType, char)
	local targetTypeMap = {
		[enEntType.eEntType_Monster] = MonsterConsts:GetTargetMonsterType(char);
		[enEntType.eEntType_Player] = TargetConsts.TargetType.Player;
	}
	return targetTypeMap[charType];
end

-- 怪物掉落类型
TargetConsts.DropType_NoneOwn      = 0; -- 无归属
TargetConsts.DropType_LastHitOwn   = 1; -- 尾刀归属
TargetConsts.DropType_MaxDamageOwn = 2; -- 伤害排名归属
TargetConsts.DropType_FirstHitOwn  = 3; -- 首刀归属

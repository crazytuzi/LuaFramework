-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
wnd_defenceWarBattle = i3k_class("wnd_defenceWarBattle", ui.wnd_base)

-- 城战战斗界面
-- [eUIID_DefenceWarBattle]	= {name = "defenceWarBattle", layout = "zdchengzhan", order = eUIO_TOP_MOST,},
-------------------------------------------------------

local DEFENCE_WAR_MOSTER =
{
	[g_DEFENCE_WAR_MONSTER_GUARD] 		= 5302, --"击败巡逻守卫:%s/%s",
	[g_DEFENCE_WAR_MONSTER_BOSS] 		= 5209,
	[g_DEFENCE_WAR_MONSTER_OUT_GATE]	= 5206,
	[g_DEFENCE_WAR_MONSTER_IN_GATE] 	= 5207,
	[g_DEFENCE_WAR_MONSTER_TOWER] 		= 5208,
}

local DEFENCE_WAR_ATTACK_MOSTER =
{
	[g_DEFENCE_WAR_MONSTER_GUARD] 		= 5303, --"击败巡逻守卫:%s/%s",
	[g_DEFENCE_WAR_MONSTER_BOSS] 		= 5294,
	[g_DEFENCE_WAR_MONSTER_OUT_GATE]	= 5295,
	[g_DEFENCE_WAR_MONSTER_IN_GATE] 	= 5296,
	[g_DEFENCE_WAR_MONSTER_TOWER] 		= 5297,
}

local DEFENCE_WAR_DEFENSE = 1

function wnd_defenceWarBattle:ctor()

end

function wnd_defenceWarBattle:configure()
	local weight = self._layout.vars
	weight.unrideCar:onClick(self, self.onOnUnrideBt)
	self._forceType = g_i3k_game_context:GetForceType()
	weight.memberbt:onClick(self, self.onMemberBt)
end

function wnd_defenceWarBattle:refresh()
	self:updateScoreInfo(g_i3k_game_context:getDefenceWarScore())
	self:updateKillInfo(g_i3k_game_context:getDefenceWarKillInfo())
	self:updateTargetInfo()
	self:updateUnrideBtState()
end

function wnd_defenceWarBattle:updateScoreInfo(score)
	local weight = self._layout.vars
	local value = self._forceType ~= DEFENCE_WAR_DEFENSE
	weight.count:setVisible(value)
	weight.myCount:setVisible(value)

	if value then
		weight.count:setText(score)
	end
end

function wnd_defenceWarBattle:updateKillInfo(killMonsters, totalMonsters)
	local scroll = self._layout.vars.scroll

	scroll:removeAllChildren()
	for _, v in ipairs(self:sortTotalMonster(totalMonsters)) do
		local ui = require("ui/widgets/zdchengzhant")()
		local monsterType = v.monsterType
		local formatStr = self._forceType == DEFENCE_WAR_DEFENSE and DEFENCE_WAR_ATTACK_MOSTER[monsterType] or DEFENCE_WAR_MOSTER[monsterType]
		local killCount = killMonsters[monsterType] and killMonsters[monsterType] or 0
		ui.vars.label:setText(i3k_get_string(formatStr, killCount, v.totalCount))
		scroll:addItem(ui)
	end
end

function wnd_defenceWarBattle:sortTotalMonster(totalMonsters)
	local result = {}
	for k, v in pairs(totalMonsters) do
		table.insert(result, {monsterType = k, totalCount = v})
	end
	table.sort(result, function(a, b)
		return a.monsterType < b.monsterType
	end)

	return result
end

function wnd_defenceWarBattle:updateTargetInfo()
	local id = self._forceType == DEFENCE_WAR_DEFENSE and 5287 or 5205
	self._layout.vars.target:setText(i3k_get_string(id))
end

function wnd_defenceWarBattle:updataUnrideCarBtState(state)
	self._layout.vars.unrideCar:setVisible(state)
end

function wnd_defenceWarBattle:onOnUnrideBt()
	local fun = function(ok)
		if ok then
			i3k_sbean.city_war_cancle_use_car()
		end
	end

	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(5265), fun)
end

function wnd_defenceWarBattle:updateUnrideBtState()
	local value = g_i3k_game_context:defenceWarTransformState()
	self._layout.vars.unrideCar:setVisible(value)
end

function wnd_defenceWarBattle:updateBossBlood(curHp, maxHp)
	local weight = self._layout.vars
	weight.bossblood:setPercent(curHp / maxHp * 100)
end

function wnd_defenceWarBattle:onMemberBt()
	i3k_sbean.citywar_enter_member()
end

function wnd_create(layout, ...)
	local wnd = wnd_defenceWarBattle.new()
	wnd:create(layout, ...)
	return wnd;
end

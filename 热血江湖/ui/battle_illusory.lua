
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battle_illusory = i3k_class("wnd_battle_illusory",ui.wnd_base)

local POS_INDEX = 1  --控件在scroll的位置
local TIME_SECOND_1 = 10
local TIME_SECOND_2 = 20
local TIME_SECOND_3 = 3
local TIME_COUNTDOWN = i3k_db_illusory_dungeon_cfg.countDown

function wnd_battle_illusory:ctor()
	local mapID = g_i3k_game_context:GetWorldMapID()
	self._maxTime = i3k_db_illusory_dungeon[mapID].maxTime
end

function wnd_battle_illusory:configure()
	self._layout.vars.scroll:removeAllChildren()
end

--InvokeUIFunction
function wnd_battle_illusory:updateIllusoryTime(remainTime)
	local time = self._maxTime - remainTime
	local formatTime = function(time)
		local tm = time
		local h = i3k_integer(tm / (60 * 60))
		tm = tm - h * 60 * 60

		local m = i3k_integer(tm / 60)
		tm = tm - m * 60

		local s = tm
		return string.format("%02d:%02d:%02d", h, m, s);
	end
	self._layout.vars.time:setText(formatTime(time))

	-- self:updateTipsInfo(time)
	self:openBattleFight(time)
end

--InvokeUIFunction
function wnd_battle_illusory:updateBossScroll(monsterIDs, deadBossIDs)
	self._layout.vars.scroll:removeAllChildren()
	self._layout.vars.scroll:stateToNoSlip()

	local deadBoosSet = {}
	for _, bossID in ipairs(deadBossIDs) do
		deadBoosSet[bossID] = true
	end

	for index, monsterID in ipairs(monsterIDs or {}) do
		local ui = require("ui/widgets/zdhuanjingshiliant")()
		local str = i3k_db_monsters[monsterID].typeDesc
		if deadBoosSet[monsterID] then
			str = str .. "【已击杀】"
		end
		ui.vars.typeDesc:setText(str)
		ui.vars.title:setVisible(index == POS_INDEX)
		self._layout.vars.scroll:addItem(ui)
	end
end

function wnd_battle_illusory:updateTipsInfo(time)
	if time == TIME_SECOND_1 or time == TIME_SECOND_2 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5368, TIME_COUNTDOWN - time))
	end
end

--打开3,2,1倒计时ui
function wnd_battle_illusory:openBattleFight(time)
	if TIME_COUNTDOWN - time == TIME_SECOND_3 then
		g_i3k_ui_mgr:OpenUI(eUIID_BattleFight)
		g_i3k_ui_mgr:RefreshUI(eUIID_BattleFight)
	end
end

--InvokeUIFunction
--boss刷新提示
function wnd_battle_illusory:openBossRefreshTips(curMonsterID)
	local cfg = i3k_db_monsters[curMonsterID]
	if cfg then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5369, cfg.name))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_battle_illusory.new()
	wnd:create(layout, ...)
	return wnd;
end


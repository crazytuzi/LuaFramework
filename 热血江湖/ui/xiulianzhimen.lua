------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_xiulianzhimen_fuben = i3k_class("wnd_xiulianzhimen_fuben",ui.wnd_base)

local SPEED = 10

local BUFF_ITEM = "ui/widgets/hudxlzmtem"

function wnd_xiulianzhimen_fuben:ctor()
	self.buffs = {}
end

function wnd_xiulianzhimen_fuben:InitBuffs()
	if not next(self.buffs) then
		local widgets = self._layout.vars
		for i,v in ipairs(i3k_db_practice_door_common.buffids) do
			local UI = require(BUFF_ITEM)()
			local vars = UI.vars
			widgets.scroll:addItem(UI)
			vars.name:setText(i3k_db_team_buff[v].name)
			self.buffs[v] = {
				id = v,
				target = vars.target,
				cur = vars.current,
				name = vars.name,
				value = vars.value,
				curValue = 0,
				targetValue = 0,
			}
			local buff = self.buffs[v]
			function buff:Set(cur, target)
				self.curValue = cur or self.curValue
				self.targetValue = target or self.targetValue
				self.value:setText(math.floor(100 + self.curValue)..'%')
				self.target:setPercent(self.targetValue)
				self.cur:setPercent(self.curValue)
			end
			function buff:onUpdate(dTime)
				self.curValue = self.curValue + (self.targetValue - self.curValue) / 100 * SPEED
				if math.abs(self.targetValue - self.curValue) < 1 then
					self.curValue = self.targetValue
				end
				self:Set(self.curValue, self.targetValue)
			end
		end
	end
end

function wnd_xiulianzhimen_fuben:refresh()
	local buffs = g_i3k_game_context:GetPracticeGateData() or {}
	for k, v in pairs(self.buffs) do
		local value = g_i3k_db.i3k_db_get_practice_door_extra_buff_addition(v.id, buffs[k] or 0)
		local diff = value - v.targetValue
		if diff > 0 then
			local dataList = {}
			dataList.buffType = k
			dataList.buffValue = value - v.targetValue
			g_i3k_ui_mgr:RefreshUI(eUIID_BattleShowExp, g_BATTLE_SHOW_BUFF, dataList)
		end
		v:Set(nil, value)
	end
end

function wnd_xiulianzhimen_fuben:onUpdate(dTime)
	for i, v in ipairs(self.buffs) do
		v:onUpdate(dTime)
	end
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_xiulianzhimen_fuben.new()
	wnd:create(layout,...)
	return wnd
end
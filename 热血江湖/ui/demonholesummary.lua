module(..., package.seeall)

local require = require;

local ui = require("ui/taskBase");
local BASE = ui.taskBase
-------------------------------------------------------
wnd_demonhole_summary = i3k_class("wnd_demonhole_summary", ui.taskBase)

function wnd_demonhole_summary:ctor()
	self._cfg = {}
	self._bossState = -1
end

function wnd_demonhole_summary:configure()
	BASE.configure(self)
    BASE.setTabState(self, 1)
	local widgets = self._layout.vars
	
	self.name = widgets.name
	self.tagDesc = widgets.tagDesc
	self.expSpace = widgets.expSpace
	self.expValue = widgets.expValue
	self.floorNum = widgets.floorNum
	self.keyNum = widgets.keyNum
	self.bossDesc = widgets.bossDesc
	self.stateDesc = widgets.stateDesc
	
	widgets.checkResult:onClick(self, self.onCheckResult)
end

function wnd_demonhole_summary:refresh()
	local roleLvl = g_i3k_game_context:GetLevel()
	local curFloor, grade = g_i3k_game_context:GetDemonHoleFloorGrade()
	local mapId = g_i3k_game_context:GetWorldMapID()
	local fbCfg = i3k_db_demonhole_fb[grade][curFloor]
	self.name:setText(fbCfg.mapDesc)
	self.tagDesc:setText(i3k_get_string(i3k_db_demonhole_base.textId))
	self.expSpace:setText(i3k_get_string(3068, fbCfg.expSpace))
	local value = math.modf(i3k_db_exp[roleLvl].demonHoleBase * fbCfg.expRatio / 100)
	self.expValue:setText(value)
	self.expValue:setTextColor(g_i3k_get_hl_red_color())
	self.floorNum:setText(i3k_get_string(3069, curFloor, #i3k_db_demonhole_fb[grade]))
	self:updateKeyNum()
	self:updateBossState(g_i3k_game_context:GetDemonHoleBossState())
	self._cfg = fbCfg
end

function wnd_demonhole_summary:updateKeyNum()
	local havaKeyNum = g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_demonhole_base.keyId)
	self.keyNum:setText(i3k_get_string(3067, havaKeyNum))
end

function wnd_demonhole_summary:updateBossState(state)
	self.bossDesc:setVisible(state >= 0)
	self.stateDesc:setVisible(state >= 0)
	self._bossState = state
	local bossDescID = state >= g_DEMONHOLE_BOSS_STATE_REFRESH and 3077 or 3074
	self.bossDesc:setText(i3k_get_string(bossDescID))
	if state == g_DEMONHOLE_BOSS_STATE_REFRESH then
		self.stateDesc:setText(i3k_get_string(3075))
		self.stateDesc:setTextColor(g_i3k_get_hl_green_color())
	elseif state == g_DEMONHOLE_BOSS_STATE_DEAD then
		self.stateDesc:setText(i3k_get_string(3076))
		self.stateDesc:setTextColor(g_i3k_get_hl_red_color())
	end
end

function wnd_demonhole_summary:onUpdate(dTime)
	if self._cfg and self._cfg.bossRefreshTime > 0 and self._bossState == g_DEMONHOLE_BOSS_STATE_NOREFRESH then
		local world = i3k_game_get_world()
		local worldStartTime  = 0
		if world then
			worldStartTime = world:GetStartTime()
		end
		local tm = worldStartTime + self._cfg.bossRefreshTime - i3k_game_get_time()
		if tm > 0 then
			self.stateDesc:setText(self:getTimeStr(tm))
		else
			self.bossDesc:setText(i3k_get_string(3077))
			self.stateDesc:setText(i3k_get_string(3075))
			self.stateDesc:setTextColor(g_i3k_get_hl_green_color())
		end
	end
end

function wnd_demonhole_summary:getTimeStr(timeNum)
	local str = ""
	local leftMin = timeNum % (60 * 60)
	local min = math.modf(leftMin / 60)
	local sec = leftMin % 60
	if min ~= 0 then
		str = str..min.."分"
	end
	str = str..sec.."秒"
	return str
end

function wnd_demonhole_summary:onCheckResult(sender)
	i3k_sbean.demonhole_battle()
end

function wnd_create(layout)
	local wnd = wnd_demonhole_summary.new()
	wnd:create(layout)
	return wnd
end

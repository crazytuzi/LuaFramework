module(..., package.seeall)

local require = require;

local ui = require("ui/taskBase");
local BASE = ui.taskBase
-------------------------------------------------------
wnd_defend_summary = i3k_class("wnd_defend_summary", ui.taskBase)

function wnd_defend_summary:ctor()

end

function wnd_defend_summary:configure()
	BASE.configure(self)
    BASE.setTabState(self, 1)
	local widgets = self._layout.vars
	
	self.tagDesc = widgets.tagDesc
	self.numDesc = widgets.numDesc
	self.scoreDesc = widgets.scoreDesc	
	self.hpDesc	= widgets.hpDesc
	self.taskTitle = widgets.taskTitle
	self.other_sideImg = widgets.other_sideImg
end

function wnd_defend_summary:refresh()
	local mapType = i3k_game_get_map_type()
	if mapType == g_DOOR_XIULIAN then
		self:updatePracticeGateInfo()
	elseif mapType == g_HOMELAND_GUARD then
		self:updateHomeLandGuardInfo()
	else
	self:updatPercent()
	self:updateTargetHP()
	end
end
function wnd_defend_summary:updateHomeLandGuardInfo()
	self.tagDesc:setText(i3k_get_string(5544)..i3k_get_string(5546))
	self:UpdateMonsterCount()
	self.scoreDesc:hide()
	self.other_sideImg:hide()
	self.hpDesc:hide()
end
function wnd_defend_summary:updatePracticeGateInfo()
	local widgets = self._layout.vars
	local x, round = g_i3k_game_context:GetPracticeGateData()
	widgets.hpDesc:hide()
	widgets.scoreDesc:hide()
	widgets.other_sideImg:hide()
	widgets.tagDesc:setText(i3k_get_string(5457))
	widgets.numDesc:setText(i3k_get_string(5458, round or 0))
end

function wnd_defend_summary:updatPercent()
	local mapID = g_i3k_game_context:GetWorldMapID()
	local txtID = i3k_db_defend_cfg[mapID].leftDescID
	local info = g_i3k_game_context:getTowerDefenceTmpInfo()
	self.tagDesc:setText(i3k_get_string(15408))
	self.hpDesc:setText(i3k_get_string(txtID))
	self.scoreDesc:setText(i3k_get_string(15410, info.score))
	self.numDesc:setText(i3k_get_string(15409, info.count))
end

function wnd_defend_summary:updateTargetHP()
	local curHp, maxHp = g_i3k_game_context:getTowerDefenceTargetHp()
	local percent = curHp / maxHp * 100
	percent = percent <= 100 and percent or 100
	self._layout.vars.bloodBar:setPercent(percent)
end

function wnd_create(layout)
	local wnd = wnd_defend_summary.new()
	wnd:create(layout)
	return wnd
end
function wnd_defend_summary:UpdateMonsterCount()
	local count = g_i3k_game_context:GetHomeLandGuardMonsterCount()
	self.numDesc:setText(i3k_get_string(5547)..count)
end

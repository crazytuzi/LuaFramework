-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_back_defense = i3k_class("wnd_back_defense", ui.wnd_base)

function wnd_back_defense:ctor()
	self._recordTime = 0
	self._timeSpace = 0
end

function wnd_back_defense:configure()
	local widgets = self._layout.vars	
	
	widgets.defenseBtn:onClick(self, self.onDefenseBtn)
	widgets.leftBtn:onClick(self, self.onLeftBtn)
	widgets.rightBtn:onClick(self, self.onRightBtn)
end

function wnd_back_defense:onShow()
	local worldMpaID = i3k_game_context:GetWorldMapID()
	self._timeSpace = i3k_db_defend_cfg[worldMpaID].timeSpacing
end

function wnd_back_defense:onUpdate(dTime)
	if self._recordTime ~= 0 then
		self._recordTime = self._recordTime + dTime
		if self._recordTime > self._timeSpace then
			self._recordTime = 0
		end
	end
end

function wnd_back_defense:onDefenseBtn(sender)
	self:onCommonTips(g_DEFENCE_ALARM_BACK)
end

function wnd_back_defense:onLeftBtn(sender)
	self:onCommonTips(g_DEFENCE_ALARM_LEFT)
end

function wnd_back_defense:onRightBtn(sender)
	self:onCommonTips(g_DEFENCE_ALARM_RIGHT)
end

function wnd_back_defense:onCommonTips(tipsType)
	if self._recordTime == 0 then
		self._recordTime = 0.01
		i3k_sbean.send_towerdefence_tips(tipsType)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15416, math.ceil(self._timeSpace - self._recordTime)))
	end
end

function wnd_create(layout)
	local wnd = wnd_back_defense.new()
	wnd:create(layout)
	return wnd
end

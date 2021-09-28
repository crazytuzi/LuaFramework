
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_newYearRedEnvelope = i3k_class("wnd_newYearRedEnvelope",ui.wnd_base)

function wnd_newYearRedEnvelope:ctor()

end

function wnd_newYearRedEnvelope:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_newYearRedEnvelope:refresh(npcId)
	local widgets = self._layout.vars
	math.randomseed(tostring(os.time()):reverse():sub(1, 7))
	widgets.desc:setText(i3k_db_newYear_red.npcBlessing[npcId][math.random(1,3)])
	widgets.getBtn:onClick(self, self.getRed, npcId)
  	ui_set_hero_model(widgets.model, g_i3k_db.i3k_db_get_npc_modelID(npcId) )
  	widgets.model:playAction("stand",-1)
end

function wnd_newYearRedEnvelope:getRed(sender, npcId)
	local db = i3k_db_newYear_red
	local t = {}
	for i,v in ipairs(db.gift[1].rewards70Up) do
		t[v.id] = v.count
	end
	if not g_i3k_game_context:IsBagEnough(t) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17482))
	end
	i3k_sbean.new_year_red_packet_getReq(npcId)
	self:onCloseUI()
end

function wnd_create(layout, ...)
	local wnd = wnd_newYearRedEnvelope.new()
	wnd:create(layout, ...)
	return wnd;
end


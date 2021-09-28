-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_role_pk = i3k_class("wnd_role_pk",ui.wnd_base)

function wnd_role_pk:ctor()
end

function wnd_role_pk:configure()
	local widget = self._layout.vars

	self.PKLayer = widget.PKLayer
	self.btn1 = widget.btn1
	self.btn2 = widget.btn2
	self.btn3 = widget.btn3
	self.faction = widget.faction

	self.PKtext = widget.PKVale
	self.PKstatustext = widget.gd
	--local PKPanel = widget.PKPanel

	self.btn1:onClick(self, self.onbtn1)
	self.btn2:onClick(self, self.onbtn2)
	self.btn3:onClick(self, self.onbtn3)
	self.faction:onClick(self, self.onfaction)
	widget.close:onClick(self, self.onClose)
	
	self.desc = widget.da
end

function wnd_role_pk:onbtn1(sender)
	local hero = i3k_game_get_player_hero()
	if hero._PVPStatus ~= g_PeaceMode then
		i3k_sbean.set_attackmode(g_PeaceMode)--0:和平
	else
		g_i3k_ui_mgr:CloseUI(eUIID_PKMode);
	end
end

function wnd_role_pk:onbtn2(sender)
	local hero = i3k_game_get_player_hero()
	if hero._PVPStatus ~= g_GoodAvilMode then
		i3k_sbean.set_attackmode(g_GoodAvilMode)---2:善恶
	else
		g_i3k_ui_mgr:CloseUI(eUIID_PKMode);
	end
end

function wnd_role_pk:onbtn3(sender)
	local hero = i3k_game_get_player_hero()
	if hero._PVPStatus ~= g_FreeMode then
		i3k_sbean.set_attackmode(g_FreeMode)--1:自由
	else
		g_i3k_ui_mgr:CloseUI(eUIID_PKMode)
	end
end

function wnd_role_pk:onfaction(sender)
	local hero = i3k_game_get_player_hero()
	if hero._PVPStatus ~= g_FactionMode then
		i3k_sbean.set_attackmode(g_FactionMode)-- 3:帮派
	else
		g_i3k_ui_mgr:CloseUI(eUIID_PKMode)
	end
end



function wnd_role_pk:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_PKMode)
end

function wnd_role_pk:refresh()
	local hero = i3k_game_get_player_hero()
	if hero._PKvalue ~= -1 then
		local cfg = g_i3k_db.i3k_db_get_pk_cfg(hero._PKvalue)
		local text = i3k_get_string(115, cfg.punish1/100, cfg.punish2*100)
		self.PKtext:setText(hero._PKvalue)
		self.PKstatustext:setText(text)
	end

	if i3k_game_get_map_type() ~= 0 and g_i3k_game_context:GetWorldMapID() ~= i3k_db_crossRealmPVE_cfg.battleMapID then
		self.btn1:show()
		self.btn2:hide()
		self.btn3:hide()
	else
		self.btn1:show()
		self.btn2:show()
		self.btn3:show()
	end
	local lvl = g_i3k_game_context:GetLevel()
	local id = g_i3k_game_context:GetFactionSectId()---返回0时表示没有

	if lvl>=25 and g_i3k_game_context:GetFactionSectId()~=0 then
		self.faction:show()
	else
		self.faction:hide()
	end
	self.PKLayer:show()
	self:UpdatePkText(g_i3k_game_context:GetCurrentPKValue())
	
	self.desc:setText(i3k_get_string(920,i3k_db_common.pk.pkOpenlvl,i3k_db_common.pk.pkOpenlvl))
end

function wnd_role_pk:UpdatePkText(value)
	local cfg = g_i3k_db.i3k_db_get_pk_cfg(value)
	local text = i3k_get_string(115, cfg.punish1/100, cfg.punish2*100)
	self.PKtext:setText(value)
	self.PKstatustext:setText(text)
end

function wnd_role_pk:onshow()

end

function wnd_role_pk:onHide()
	self.PKLayer:hide()
end

function wnd_role_pk:onUpdate(dTime)

end

function wnd_create(layout)
	local wnd = wnd_role_pk.new()
		wnd:create(layout)
	return wnd
end

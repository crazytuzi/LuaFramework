-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_bonus_house = i3k_class("wnd_bonus_house", ui.wnd_base)

local BPHDRKT_WIDGET = "ui/widgets/bphdrkt"  

function wnd_bonus_house:ctor()
	
end

function wnd_bonus_house:configure()
	local widgets = self._layout.vars
	self._scrollWidget = {
		[1] = {iconID = 4861, func = self.onDineBtn, redVis = g_i3k_game_context:GetFactionDinePoint() > 0 }, --帮派宴席
		[2] = {iconID = 4862, func = self.onRedEnvelopeBtn, redVis = g_i3k_game_context:GetRedEnvelopePoint() > 0 }, --帮派红利
		[3] = {iconID = 4863, func = self.onDragonLuckyBtn, redVis = false}, --龙运福祉
		[4] = {iconID = 5030, func = self.onFactionSalaryBtn, redVis = false}, --帮派工资
		[5] = {iconID = 7481, func = self.onFactionBless, redVis = false}, --帮派祝福
	}
	self.scroll = widgets.scroll
	widgets.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_bonus_house:refresh()
	local widgets = self._layout.vars
	for i, e in ipairs(self._scrollWidget) do
		local node = require(BPHDRKT_WIDGET)()
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(e.iconID))
		node.vars.btn:onClick(self, e.func)
		node.vars.redPoint:setVisible(e.redVis)
		self.scroll:addItem(node)
	end
end


function wnd_bonus_house:onDineBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_FactionDineTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_FactionDineTips)
	self:onCloseUI()
end

function wnd_bonus_house:onRedEnvelopeBtn(sender)
	i3k_sbean.sect_red_pack_sync()
	self:onCloseUI()
end

function wnd_bonus_house:onDragonLuckyBtn(sender)
	i3k_sbean.sect_destiny_reward_sync()
	self:onCloseUI()
end

function wnd_bonus_house:onFactionSalaryBtn(sender)
	g_i3k_logic:OpenFactionSalary()	
	self:onCloseUI()
end

function wnd_bonus_house:onFactionBless(sender)
	local closeUI = function () self:onCloseUI() end
	g_i3k_logic:OpenFactionBlessing(closeUI)
end

function wnd_create(layout, ...)
	local wnd = wnd_bonus_house.new();
		wnd:create(layout, ...);
	return wnd;
end

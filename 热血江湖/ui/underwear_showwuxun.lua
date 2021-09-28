-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
--信件道具ui
-------------------------------------------------------

wnd_underwear_showWuXun = i3k_class("wnd_underwear_showWuXun",ui.wnd_base)

function wnd_underwear_showWuXun:ctor()
	
end

function wnd_underwear_showWuXun:configure()
	local widgets = self._layout.vars
	self.closeBtn = widgets.closeBtn
   
	self.Scroll = widgets.Scroll
	self.closeBtn:onClick(self, self.closeButton)
	
end

function wnd_underwear_showWuXun:refresh()
	local dataTab = {}
	for k,v in pairs(i3k_db_under_wear_wuxun) do
		table.insert(dataTab ,v)
	end
	table.sort(dataTab, function (a, b)
		return a.wuxunNum<b.wuxunNum
	end)
	for k,v in pairs(dataTab) do
		local annText = require("ui/widgets/njwxzft")() 
		annText.vars.text:setText(string.format("武勋[%d%s%s%d%s",v.wuxunNum,"]以上,","基础祝福值提升[",v.addWishNum,"]"))
		self.Scroll:addItem(annText)
	end
end

function wnd_underwear_showWuXun:closeButton(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Under_Wear_showWuXun)
end

function wnd_create(layout)
	local wnd = wnd_underwear_showWuXun.new()
		wnd:create(layout)
	return wnd
end

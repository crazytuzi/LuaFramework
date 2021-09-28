-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_red_envelope_detail = i3k_class("wnd_red_envelope_detail", ui.wnd_base)

local WIDGETHISTORY = "ui/widgets/bphbxqt"

function wnd_red_envelope_detail:ctor()
	self.history = {}
end

function wnd_red_envelope_detail:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
	self.des = widgets.des
	widgets.closeBtn:onClick(self, self.onClose)
end

function wnd_red_envelope_detail:refresh(history, packNum)
	self.history = {}
	self.des:setText(string.format("剩余数量：%s/%s", #history, packNum))
	self:sortHistory(history)
	self:showHistory()
end

function wnd_red_envelope_detail:sortHistory(history)
	for k, v in ipairs(history) do
		table.insert(self.history, v)
	end
	table.sort(self.history, function(a, b)
		return a.time < b.time
	end)
end

function wnd_red_envelope_detail:showHistory()
	for k, v in ipairs(self.history) do
		local _widget = require(WIDGETHISTORY)()
		_widget.vars.name:setText(v.roleName)
		_widget.vars.diamond:setText(v.takeNum)
		self.scroll:addItem(_widget)
	end
end

function wnd_red_envelope_detail:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RedEnvelopeDetail)
end

function wnd_create(layout, ...)
	local wnd = wnd_red_envelope_detail.new();
		wnd:create(layout, ...);
	return wnd;
end

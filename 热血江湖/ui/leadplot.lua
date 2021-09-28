-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_leadplot = i3k_class("wnd_leadplot", ui.wnd_base)

function wnd_leadplot:ctor()
	
end

function wnd_leadplot:configure()
	local widget = self._layout.vars
	self.plotheadicon = widget.plotheadicon
	self.plottext = widget.plottext
	self.dt2 = widget.dt2
	self.dt = widget.dt
	self.close = widget.closeBtn
	self.plotheadicon2 = widget.plotheadicon2
	self.close:onClick(self,self.onClose)
end

function wnd_leadplot:onShow()
	
end

function wnd_leadplot:refresh(headiconid, text)
	if text then
		self.plottext:setText(text)
	end
	if headiconid then
		self.dt:setVisible(headiconid ~= -1)
		self.dt2:setVisible(headiconid == -1)
		if headiconid ~= -1 then
			self.plotheadicon:setImage(g_i3k_db.i3k_db_get_head_icon_path(headiconid))
		else
			local name,headIcon = g_i3k_game_context:GetRoleNameHeadIcon()
			self.plotheadicon2:setImage(g_i3k_db.i3k_db_get_head_icon_path(headIcon, false))
		end
	end
end

function wnd_leadplot:onClose(sender)
	g_i3k_game_context:onFinishPlot()
	g_i3k_ui_mgr:CloseUI(eUIID_LeadPlot)
end

function wnd_create(layout, ...)
	local wnd = wnd_leadplot.new()
	wnd:create(layout, ...)
	return wnd;
end
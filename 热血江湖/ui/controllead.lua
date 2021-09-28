-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
controllead = i3k_class("controllead",ui.wnd_base)
function controllead:ctor()
	self._poptick = 0
end

function controllead:refresh()
	self._poptick = 0
end

function controllead:configure(...)
	self.screenSize = cc.Director:getInstance():getWinSize();
	self.frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
	local rootSize = self._layout.root:getContentSize();
	local widget = self._layout.vars
	
	self._layout.vars.close_btn:onClick(self,self.onCloseUI, function ()
		self.tCfg = i3k_db_leadtriggerUI[1]
		self.UIID = self.tCfg.winID

		if self.tCfg.trigbase then
			for k,v in pairs(self.tCfg.trigbase) do
				g_i3k_game_context:LeadTriBehaviou(v)
			end
		end
		local widget = nil;
		local ui = g_i3k_ui_mgr:GetUI(self.tCfg.winID)
		if self.tCfg.widgettype == 1 then
				
		elseif self.tCfg.widgettype == 2 then
			local scroll = ui:GetChildByVarName(self.tCfg.scrollviewname)
			local child = scroll:getChildAtIndex(self.tCfg.index);
			widget = child.vars[self.tCfg.widgetname]
		end
		widget:sendClick();
		g_i3k_game_context:LeadCheck(eLTEventClickTri);
	end)

end

function controllead:onShow()

end

function controllead:onHide()

end

function wnd_create(layout, ...)
	local wnd = controllead.new()
	wnd:create(layout, ...)
	return wnd
end

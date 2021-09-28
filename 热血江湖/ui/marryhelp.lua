-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_marryHelp = i3k_class("wnd_marryHelp", ui.wnd_base)

function wnd_marryHelp:ctor()
	
end

function wnd_marryHelp:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self.desc = self._layout.vars.desc
	self.scroll = self._layout.vars.scroll
	-- self.scroll:setBounceEnabled(false)
end

function wnd_marryHelp:refresh(cfg)
	if cfg then
		self.scroll:removeAllChildren()
		local title = require("ui/widgets/bzt2")()
		title.vars.text:setText(i3k_get_string(18559))
		title.vars.time:setText(i3k_get_string(18582)) 
		self.scroll:addItem(title)
		for i ,v in ipairs(cfg) do	
			local gzText = require("ui/widgets/bzt2")()
				gzText.vars.text:setText(v.marryName)
				gzText.vars.time:setText(v.marryTime..i3k_get_string(18585)) 
			self.scroll:addItem(gzText)
		end
	end
end

function wnd_create(layout,...)
	local wnd = wnd_marryHelp.new()
	wnd:create(layout,...)
	return wnd
end
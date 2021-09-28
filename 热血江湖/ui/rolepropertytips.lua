-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_rolePropertyTips = i3k_class("wnd_rolePropertyTips", ui.wnd_base)

function wnd_rolePropertyTips:ctor()
	
end

function wnd_rolePropertyTips:configure()
	local widgets = self._layout.vars
	self.desc = widgets.desc
	self.title = widgets.title
end

function wnd_rolePropertyTips:refresh(showId)
	local cfg = i3k_db_prop_id[showId]
	local title = cfg.desc
	if cfg.nameExt then
		title = title .. cfg.nameExt
	end
	self.title:setText(title)
	self.desc:setText(cfg.tips)
end

function wnd_create(layout)
	local wnd = wnd_rolePropertyTips.new()
	wnd:create(layout)
	return wnd;
end

-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_mask = i3k_class("wnd_mask", ui.wnd_base)

function wnd_mask:ctor()
end

function wnd_mask:configure(...)
	local screenSize = cc.Director:getInstance():getWinSize();
	local rootSize = self._layout.root:getContentSize();

	self:setPosition(ui_conv_point((screenSize.width - rootSize.width) / 2, (screenSize.height - rootSize.height) / 2));
end

function wnd_create(layout, ...)
	local wnd = wnd_mask.new();
		wnd:create(layout, ...);

	return wnd;
end


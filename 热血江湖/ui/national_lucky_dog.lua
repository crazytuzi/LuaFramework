-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_national_lucky_dog = i3k_class("wnd_national_lucky_dog", ui.wnd_base)

local LAYER_XINGYUNZHET = "ui/widgets/xingyunzhet"

function wnd_national_lucky_dog:ctor()

end

function wnd_national_lucky_dog:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
	self.scroll = self._layout.vars.scroll
end

function wnd_national_lucky_dog:refresh(luckyRole)
	self.scroll:removeAllChildren()
	for k, v in pairs(luckyRole or {}) do
		local item = require(LAYER_XINGYUNZHET)()
		item.vars.des:setText(i3k_get_string(16379, v, k))
		self.scroll:addItem(item)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_national_lucky_dog.new();
		wnd:create(layout, ...);
	return wnd;
end
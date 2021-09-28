module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_xinghun_sub_star_lock = i3k_class("wnd_xinghun_sub_star_lock", ui.wnd_base)

function wnd_xinghun_sub_star_lock:ctor()

end

function wnd_xinghun_sub_star_lock:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)

	self.name = widgets.name
	self.effect = widgets.effect
end

function wnd_xinghun_sub_star_lock:refresh(id)
	self.effect:removeAllChildren()
	local cfg = g_i3k_db.xinghun_getSubStarConfig(id, 1)
	if cfg then
		self.name:setText(cfg.name)
		local itemTb = g_i3k_game_context:xingHunSetProps(cfg.props)
		for _, v in ipairs(itemTb) do
            self.effect:addItem(v)
        end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_xinghun_sub_star_lock.new();
		wnd:create(layout, ...);
	return wnd;
end

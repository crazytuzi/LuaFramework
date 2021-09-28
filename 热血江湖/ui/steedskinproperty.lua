-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_steed_skin_property = i3k_class("wnd_steed_skin_property",ui.wnd_base)

local LAYER_ZQPFSXT = "ui/widgets/zqpfsxt"

function wnd_steed_skin_property:ctor()

end

function wnd_steed_skin_property:configure()
	local widgets = self._layout.vars
	self.scroll = widgets.scroll
end

function wnd_steed_skin_property:refresh()
	local propertyTb = g_i3k_game_context:getAllSteedSkinProperty()
	self.scroll:removeAllChildren()
	for k, v in pairs(propertyTb) do
		local des = require(LAYER_ZQPFSXT)()
		local _t = i3k_db_prop_id[k]
		local _desc = _t.desc
		_desc = _desc.." :"
		des.vars.desc:setText(_desc)
		des.vars.value:setText(i3k_get_prop_show(k, v))
		self.scroll:addItem(des)
	end
end

function wnd_create(layout)
	local wnd = wnd_steed_skin_property.new()
	wnd:create(layout)
	return wnd
end

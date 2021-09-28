module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_sworn_value_desc = i3k_class("wnd_sworn_value_desc", ui.wnd_base)

local JINLANZHI = "ui/widgets/jiebaijlzt"

function wnd_sworn_value_desc:ctor()
	
end

function wnd_sworn_value_desc:configure()
	self._layout.vars.ok_btn:onClick(self, self.onCloseUI)
end

function wnd_sworn_value_desc:refresh(value)
	self._layout.vars.desc:setText(i3k_get_string(5428))
	self._layout.vars.scroll:removeAllChildren()
	for k, v in ipairs(i3k_db_sworn_value) do
		local node = require(JINLANZHI)()
		node.vars.title_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_title_base[v.titleId].iconbackground))
		node.vars.need_value:setText(v.swornValue)
		node.vars.exp_addition:setText(i3k_get_string(5419)..(v.expAddition / 100).."%")
		node.vars.finish_icon:setVisible(value >= v.swornValue)
		self._layout.vars.scroll:addItem(node)
	end
end

function wnd_create(layout)
	local wnd = wnd_sworn_value_desc.new()
	wnd:create(layout)
	return wnd
end
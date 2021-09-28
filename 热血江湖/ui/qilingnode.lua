module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_qilingNode = i3k_class("wnd_qilingNode", ui.wnd_base)

function wnd_qilingNode:ctor()
end

function wnd_qilingNode:configure()
	local widgets = self._layout.vars
	self._layout.vars.close:onClick(self,self.onCloseUI)
end

function wnd_qilingNode:refresh(cfg)
	local widgets = self._layout.vars
	widgets.item_icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imgID))
	widgets.item_name:setText(cfg.name)

	local transAttr = cfg.transAttr
	local foreverAttr = cfg.foreverAttr
	self:setWeaponScroll(transAttr)
	self:setForeverScroll(foreverAttr)
end

-- 变身加持属性
function wnd_qilingNode:setWeaponScroll(transAttr)
	local widgets = self._layout.vars
	local scroll = widgets.scroll1
	self:setScrollData(scroll, transAttr)
end

-- 永久属性
function wnd_qilingNode:setForeverScroll(foreverAttr)
	local widgets = self._layout.vars
	local scroll = widgets.scroll2
	self:setScrollData(scroll, foreverAttr)
end

function wnd_qilingNode:setScrollData(scroll, data)
	scroll:removeAllChildren()
	for k, v in ipairs(data) do
		if v.id ~= 0 and v.count ~= 0 then
			local des = require("ui/widgets/qljht2")()
			local _t = i3k_db_prop_id[v.id]
			local _desc = _t.desc
			local icon = g_i3k_db.i3k_db_get_property_icon(v.id)
			des.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
			des.vars.desc:setText(_desc)
			des.vars.value:setText(i3k_get_prop_show(v.id, v.count))
			scroll:addItem(des)
		end
	end
end


function wnd_create(layout, ...)
	local wnd = wnd_qilingNode.new();
		wnd:create(layout, ...);
	return wnd;
end

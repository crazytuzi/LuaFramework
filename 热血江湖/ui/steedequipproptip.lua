-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steedEquipPropTip = i3k_class("wnd_steedEquipPropTip", ui.wnd_base)

function wnd_steedEquipPropTip:configure()
	local widgets 		= self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
end

function wnd_steedEquipPropTip:refresh()
	local props = g_i3k_game_context:GetSteedEquipTotalProps()
	self:setScroll(props)
end

function wnd_steedEquipPropTip:setScroll(data)
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()

	local prop = self:sortProp(data)
	for _, v in ipairs(prop) do
		local node = require("ui/widgets/qizhanzhuangbeitipst")()
		local id = v.id
		local value = v.value
		local cfg = i3k_db_prop_id[id]
		local icon = g_i3k_db.i3k_db_get_property_icon(id)
		node.vars.name:setText(cfg.desc)
		node.vars.value:setText(i3k_get_prop_show(id, value))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
		scroll:addItem(node)
	end
end

-- 参数为Key value形式，返回一个排序好的key数组
function wnd_steedEquipPropTip:sortProp(prop)
	local temp = {}
	for k, v in pairs(prop) do
		table.insert(temp, {id = k, value = v})
	end
	table.sort(temp, function(a, b)
		return a.id < b.id
	end)
	return temp
end

function wnd_create(layout)
	local wnd = wnd_steedEquipPropTip.new();
		wnd:create(layout);
	return wnd;
end

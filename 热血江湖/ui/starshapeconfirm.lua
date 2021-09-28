------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_star_shape_confirm = i3k_class("wnd_star_shape_confirm",ui.wnd_base)

local ITEM_WIDGET = "ui/widgets/xingweibgt"

local starPart	= "ui/widgets/xingweit2"
local starPoint	= "ui/widgets/xingyaot1"


function wnd_star_shape_confirm:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.ok:onClick(self, self.onOkBtn)
end

function wnd_star_shape_confirm:refresh(partID, shapeIndex, color)
	self.partID = partID
	self.shapeIndex = shapeIndex
	self:setNeedItem()
	local root = require(starPart)()
	local widgets = self._layout.vars
	widgets.partRoot:addChild(root)
	root.vars.rootGird:setSizePercent(1, 1)
	self:updateNewPart(shapeIndex, root, color)
end

function wnd_star_shape_confirm:updateNewPart(shapeIndex, shape, color)
	for i = 1,9 do
		shape.vars["x"..i]:hide()
	end
	local pos = i3k_db_star_soul_shape[shapeIndex].pos
	for k, v in pairs(pos) do
		local c = i3k_db_star_soul_colored_color[color].partIcon;
		shape.vars["x"..(v+1)]:show():setImage(g_i3k_db.i3k_db_get_icon_path(c))
	end
end

function wnd_star_shape_confirm:setNeedItem()
	local consume = i3k_db_martial_soul_cfg.mustChangeConsume
	local widgets = self._layout.vars
	widgets.scroll:removeAllChildren()
	local items = widgets.scroll:addItemAndChild(ITEM_WIDGET, 2, #consume)
	for i, v in ipairs(items) do
		local vars = v.vars
		local item = consume[i]
		local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(item.id))
		vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(item.id))
		vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item.id, g_i3k_game_context:IsFemaleRole()))
		vars.name:setText(g_i3k_db.i3k_db_get_common_item_name(item.id))
		vars.name:setTextColor(name_colour)
		vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
		if item.id == g_BASE_ITEM_DIAMOND or item.id == g_BASE_ITEM_COIN then
			vars.count:setText(item.count)
		else
			vars.count:setText(g_i3k_game_context:GetCommonItemCanUseCount(item.id) .."/".. (item.count))
		end
		vars.count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(item.id) >= item.count))
		vars.btn:onClick(self, self.onItemTips, item.id)
	end
end

function wnd_star_shape_confirm:onOkBtn(sender)
	local consume = i3k_db_martial_soul_cfg.mustChangeConsume
	local isEnough = true
	for i3,v3 in ipairs(consume) do
		if v3.count > g_i3k_game_context:GetCommonItemCanUseCount(v3.id) then
			isEnough = false
			break
		end
	end
	if isEnough then
		i3k_sbean.weaponsoul_mustset(self.partID, self.shapeIndex)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1738))
	end
end

function wnd_star_shape_confirm:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_star_shape_confirm.new()
	wnd:create(layout,...)
	return wnd
end
-------------------------------------------------------
module(..., package.seeall)

local require = require;
require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_equip_transform = i3k_class("wnd_equip_transform", ui.wnd_base)

local HUFUWIDGET = "ui/widgets/hufuzht"
local DESCWIDGET = "ui/widgets/hufuzht2"

function wnd_equip_transform:ctor()
	
end

function wnd_equip_transform:configure()
	self._layout.vars.close:onClick(self, self.onCloseUI)
end

function wnd_equip_transform:refresh(groupId)
	self._layout.vars.titleImage:setImage(i3k_db_icons[i3k_db_equip_transform_cfg[groupId].pictureId].path)
	self._groupId = groupId
	self:sortEquip()
	self._layout.vars.desc_scroll:removeAllChildren()
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		local textNode = require(DESCWIDGET)()
		textNode.vars.text:setText(i3k_get_string(i3k_db_equip_transform_cfg[groupId].helpTextId))
		ui._layout.vars.desc_scroll:addItem(textNode)
		g_i3k_ui_mgr:AddTask(self, {textNode}, function(ui)
			local textUI = textNode.vars.text
			local size = textNode.rootVar:getContentSize()
			local height = textUI:getInnerSize().height
			local width = size.width
			height = size.height > height and size.height or height
			textNode.rootVar:changeSizeInScroll(ui._layout.vars.desc_scroll, width, height, true)
		end, 1)
	end, 1)
end

function wnd_equip_transform:sortEquip()
	local bagSize, bagItems = g_i3k_game_context:GetBagInfo()
	self._layout.vars.scroll:removeAllChildren()
	for k, v in pairs(bagItems) do
		local id = k > 0 and k or -k
		if g_i3k_db.i3k_db_get_common_item_type(k) == g_COMMON_ITEM_TYPE_EQUIP and i3k_db_equip_transform[self._groupId][id] then
			if next(v.equips) ~= nil then
				for a, b in pairs(v.equips) do
					self:addHufuEquip(k, a)
				end
			end
		end
	end
end

function wnd_equip_transform:addHufuEquip(id, guid)
	local hufu = g_i3k_game_context:GetBagEquip(id, guid)
	local power = g_i3k_game_context:GetBagEquipPower(id, hufu.attribute, hufu.naijiu, hufu.refine, hufu.legends, hufu.smeltingProps)
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(id)
	local node = require(HUFUWIDGET)()
	self._layout.vars.scroll:addItem(node)
	node.vars.equipBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	node.vars.suo:setVisible(id > 0)
	node.vars.name:setText(equip_t.name)
	node.vars.power:setText("战力:"..power)
	node.vars.selectBtn:onClick(self, self.onHufuInfo, hufu)
end

function wnd_equip_transform:onHufuInfo(sender, hufu)
	if hufu then
		local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(hufu.equip_id)
		if g_i3k_game_context:isFlyEquip(equipCfg.partID) then
			g_i3k_ui_mgr:OpenUI(eUIID_FlyingEquipInfo)
			g_i3k_ui_mgr:RefreshUI(eUIID_FlyingEquipInfo, hufu, false, self._groupId)
		else
		g_i3k_ui_mgr:OpenUI(eUIID_EquipTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_EquipTips, hufu, false, self._groupId)
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_equip_transform.new()
	wnd:create(layout, ...)
	return wnd
end

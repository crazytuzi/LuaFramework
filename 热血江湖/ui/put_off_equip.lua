-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_put_off_equip = i3k_class("wnd_put_off_equip", ui.wnd_base)

local LegendsTab = {i3k_db_equips_legends_1, i3k_db_equips_legends_2, i3k_db_equips_legends_3}
function wnd_put_off_equip:ctor()

end

function wnd_put_off_equip:configure()
	self._layout.vars.cancel:onClick(self, function ()
		g_i3k_ui_mgr:CloseUI(eUIID_PutOffEquip)
	end)
end

function wnd_put_off_equip:onShow()

end

function wnd_put_off_equip:refresh(item)
	local equip = g_i3k_get_equip_from_bean(item.equip)
	local id = item.id
	local count = item.count
	local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	self._layout.vars.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	self._layout.vars.nameLabel:setTextColor(g_i3k_db.g_i3k_get_color_by_rank(rank))
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	self._layout.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	local equipPart = g_i3k_db.i3k_db_get_equip_type(id)
	self._layout.vars.typeLabel:setText(equipPart.partName)

	--self._layout.vars.superEquip:setVisible(equip.naijiu~=-1)
	if equip.naijiu ~= -1 then -- 水晶装备
		self._layout.vars.purpleTX:setVisible(rank == g_RANK_VALUE_PURPLE)
		self._layout.vars.orangeTX:setVisible(rank == g_RANK_VALUE_ORANGE)
	end
	local equipPower = g_i3k_game_context:GetBagEquipPower(id, equip.attribute, equip.naijiu, equip.refine, equip.legends, equip.smeltingProps)
	self._layout.vars.powerLabel:setText(equipPower)

	local equipOccupation = g_i3k_db.i3k_db_get_equip_occupation(id)
	self._layout.vars.zhiyeLabel:setText(equipOccupation and equipOccupation.name or "全系")
	local trans = g_i3k_db.i3k_db_get_equip_trans(id)
	self._layout.vars.transLabel:setText(trans.."转")
	local bwType = g_i3k_db.i3k_db_get_equip_bwtype(id)
	local bwText = bwType == 0 and "" or (bwType == 1 and "正" or "邪")
	self._layout.vars.bwLabel:setText(bwText)
	self._layout.vars.priceLabel:setText(item.price)

	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(item.id)
	self._layout.vars.levelLabel:setText(equip_t.levelReq .. "级")
	--设置中间显示属性
	local scroll = self._layout.vars.scroll
	local baseAttr = equip_t.properties
	local otherAttr = equip_t.ext_properties
	local equip_t =  g_i3k_db.i3k_db_get_equip_item_cfg(id)
	for i,e in ipairs(equip.legends) do
		if e ~= 0 then
			local layer = require("ui/widgets/sjzbt")()
			local widget = layer.vars
			local cfg = LegendsTab[i]
			local nCfg
			if i == 3 then
				nCfg = cfg[equip_t.partID][e]
			else
				nCfg = cfg[e]
			end
			widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(nCfg.icon))
			widget.desc:setText(nCfg.tips)
			scroll:addItem(layer)
		end
	end
	local baseNode = require("ui/widgets/zbtipst3")()
	scroll:addItem(baseNode)
	for i,v in pairs(baseAttr) do
		if v.type~=0 then
			local node = require("ui/widgets/zbtipst")()
			node.vars.desc:setText(g_i3k_db.i3k_db_get_attribute_name(v.type)..":")
			--node.vars.desc:setTextColor(g_i3k_db.i3k_db_get_attribute_text_color(v.type))
			node.vars.value:setText(v.value)
			--node.vars.value:setTextColor(g_i3k_db.i3k_db_get_attribute_value_color(v.type))
			scroll:addItem(node)
		end
	end
	local index = 0
	local attribute = g_i3k_get_equip_attributes(equip)
	for i,v in pairs(otherAttr) do
		if index==0 then
			local node = require("ui/widgets/zbtipst3")()
			node.vars.desc:setText(string.format("%s", "附加属性"))
			scroll:addItem(node)
		end
		index = index + 1
		if v.args~=0 then
			local node = require("ui/widgets/zbtipst")()

			if v.type == 1 then
				node.vars.desc:setText(g_i3k_db.i3k_db_get_attribute_name(v.args)..":")
				node.vars.value:setText(attribute[index] and "+"..attribute[index])
				local max = g_i3k_db.i3k_db_is_equip_ext_prop_sharpen_max(id, index, attribute[index])
				if max then
					node.vars.max_img:show()
				end
			elseif v.type == 2 then
				node.vars.desc:setText(i3k_db_skills[v.args].name.."等级 +")
				node.vars.value:setText(attribute[2])
			elseif v.type == 3 then
				node.vars.desc:setText(i3k_db_skills[v.args].name.."CD -")
				node.vars.value:setText(attribute[3])
			elseif v.type == 4 then
				node.vars.desc:setText(g_i3k_db.i3k_db_get_attribute_name(v.args)..":")
				node.vars.value:setText(attribute[4])
			end
			--node.vars.desc:setTextColor(g_i3k_db.i3k_db_get_attribute_text_color(v.args))
			--node.vars.value:setTextColor(g_i3k_db.i3k_db_get_attribute_value_color(v.args))
			scroll:addItem(node)
		end
	end
	self._layout.vars.nScroll:removeAllChildren()
	self._layout.vars.putOffBtn:onClick(self, self.putOff, item)
end

function wnd_put_off_equip:putOff(sender, item)
	local isEnough = g_i3k_game_context:IsBagEnough({[item.id] = item.count})
	if isEnough then
		local message = i3k_get_string(246, g_i3k_db.i3k_db_get_common_item_name(item.id))
		local callback = function (isOk)
			if isOk then
				i3k_sbean.putOffItem(item)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(message, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(252))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_put_off_equip.new()
	wnd:create(layout, ...)
	return wnd;
end

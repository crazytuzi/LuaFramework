-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_sale_equip = i3k_class("wnd_sale_equip", ui.wnd_base)

local LegendsTab = {i3k_db_equips_legends_1, i3k_db_equips_legends_2, i3k_db_equips_legends_3}
function wnd_sale_equip:ctor()

end

function wnd_sale_equip:configure()
	self._layout.vars.cancel:onClick(self, self.onCloseUI)
	self.priceInput = self._layout.vars.priceInput
	self.priceInput:setInputMode(EDITBOX_INPUT_MODE_NUMERIC)
	self.priceInput:addEventListener(function(eventType)
		local maxprice = 99999999
		if eventType == "ended" then
			local str = tonumber(self.priceInput:getText()) or ""
			if str =="" or str == 0 then
		    	str = 1
		    elseif str > maxprice then
		    	str = maxprice
		    end
		    price = str
		    self.priceInput:setText(price)
		end
	end)
	self._otherPlayerWidgets = {}
	for i=1, 5 do
		local node = {}
		node.root = self._layout.vars[string.format("root%d", i)]
		node.root:hide()
		node.gradeIcon = self._layout.vars[string.format("gradeIcon%d", i)]
		node.icon = self._layout.vars[string.format("icon%d", i)]
		node.nameLabel = self._layout.vars[string.format("nameLabel%d", i)]
		node.priceLabel = self._layout.vars[string.format("priceLabel%d", i)]
		node.btn = self._layout.vars[string.format("btn%d", i)]
		self._otherPlayerWidgets[i] = node
	end
end

function wnd_sale_equip:onShow()

end

function wnd_sale_equip:refresh(item, equip, logs)
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

	local equipPower = g_i3k_game_context:GetBagEquipPower(id, equip.attribute, equip.naijiu, equip.refine, equip.legends, equip.smeltingProps)
	self._layout.vars.powerLabel:setText(equipPower)

	local equipOccupation = g_i3k_db.i3k_db_get_equip_occupation(id)
	self._layout.vars.zhiyeLabel:setText(equipOccupation and equipOccupation.name or "全系")
	local trans = g_i3k_db.i3k_db_get_equip_trans(id)
	self._layout.vars.transLabel:setText(trans.."转")
	local bwType = g_i3k_db.i3k_db_get_equip_bwtype(id)
	local bwText = bwType == 0 and "" or (bwType == 1 and "正" or "邪")
	self._layout.vars.bwLabel:setText(bwText)

	self._layout.vars.putOnBtn:onClick(self, self.putOn, item)

	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(id)
	self._layout.vars.levelLabel:setText(equip_t.levelReq .. "级")
	local maxprice = equip_t.MaxPrice
	local minprice = equip_t.MinPrice
	local priceStr = ""
	if maxprice == 0 then
		self._layout.vars.noLimit:show()
	else
		priceStr = string.format("%s-%s元宝", minprice, maxprice)
		self._layout.vars.noLimit:hide()
	end
	self._layout.vars.PriceRange:setText(priceStr)
	--设置中间显示属性
	local equip = g_i3k_game_context:GetBagEquip(item.id, item.guid)
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

	for i,v in ipairs(logs) do
		local node = self._otherPlayerWidgets[i]
		local id = v.id
		node.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
		node.nameLabel:setTextColor(g_i3k_get_color_by_rank(rank))
		node.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		node.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
		local netEquip = v.equip and g_i3k_get_equip_from_bean(v.equip)
		local equipTable = {equip, netEquip}
		node.btn:onClick(self, self.checkEquipInfo, equipTable)
		node.priceLabel:setText(v.price)
		node.root:show()
	end
end

function wnd_sale_equip:checkEquipInfo(sender, equipTable)
	local equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equipTable[1].equip_id)
	if g_i3k_game_context:isFlyEquip(equipCfg.partID) then
		g_i3k_ui_mgr:OpenUI(eUIID_FlyingEquipInfo)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_FlyingEquipInfo, "updateTwoEquipInfo", equipTable[1], equipTable[2])
	else
	g_i3k_ui_mgr:OpenUI(eUIID_EquipTips)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_EquipTips, "updateTwoEquipInfo", equipTable[1], equipTable[2])
	end
end

function wnd_sale_equip:putOn(sender, item)
	local price = tonumber(self.priceInput:getText())
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(item.id)
	if price and price >= 1 then
		if ( equip_t.MaxPrice > 0 and price > equip_t.MaxPrice ) or price < equip_t.MinPrice then
			--提示超出出售价格范围
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15495))
			--return
		else
			--发协议上架
			i3k_sbean.putOnEquip(item.id, item.guid, price)
		end
	else
		--提示信息，写上价格
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(394))
	end
end

--[[function wnd_sale_equip:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_SaleEquip)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_sale_equip.new()
	wnd:create(layout, ...)
	return wnd;
end

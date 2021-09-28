-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_make_legend_equip = i3k_class("wnd_make_legend_equip", ui.wnd_base)

local WIDGETS_CSZBT		= "ui/widgets/cszbt"
local WIDGETS_CSZBT2	= "ui/widgets/cszbt2"
local WIDGETS_CSZBT3	= "ui/widgets/cszbt3"
local WIDGETS_CSZBT4	= "ui/widgets/cszbt4"
local WIDGETS_CSZBT5	= "ui/widgets/cszbt5"

local base_attribute_desc = "基础属性"
local add_attribute_desc = "附加属性"
local diamond_desc = "宝石"
local refine_desc = "精炼属性"

local LegendsTab = {i3k_db_equips_legends_1, i3k_db_equips_legends_2, i3k_db_equips_legends_3}

function wnd_make_legend_equip:ctor()
	self._widgets = {}
	self._id = 0
	self._guid = nil
	self._equip = {}
	self._equipCfg = {}
	self._legends = {}
	self._isMaking = false
	self._needItems = {}
end

function wnd_make_legend_equip:configure()
	local widgets = self._layout.vars
	local details = {}
	local details1 = {}
	details1.root				= widgets.root1
	details1.equipBg			= widgets.equipBg1
	details1.equipIcon			= widgets.equipIcon1
	details1.equipName			= widgets.equipName1
	details1.powerLabel			= widgets.powerLabel1
	details1.powerImg			= widgets.powerImg1
	details1.transformLabel		= widgets.transformLabel1
	details1.cType				= widgets.cType1
	details1.lvlLabel			= widgets.lvlLabel1
	details1.legendScroll		= widgets.legendScroll1
	details1.scroll				= widgets.scroll1
	details[1] = details1

	local details2 = {}
	details2.root				= widgets.root2
	details2.equipBg			= widgets.equipBg2
	details2.equipIcon			= widgets.equipIcon2
	details2.equipName			= widgets.equipName2
	details2.powerLabel			= widgets.powerLabel2
	details2.powerImg			= widgets.powerImg2
	details2.transformLabel		= widgets.transformLabel2
	details2.cType				= widgets.cType2
	details2.lvlLabel			= widgets.lvlLabel2
	details2.legendScroll		= widgets.legendScroll2
	details2.scroll				= widgets.scroll2
	details[2] = details2

	local needItem = {}
	needItem.itemIcon	= widgets.itemIcon
	needItem.itemName	= widgets.itemName
	needItem.itemBg 	= widgets.itemBg
	needItem.itemCount	= widgets.itemCount

	local progress = {}
	progress.root			= widgets.progressRoot
	progress.makeProgress	= widgets.makeProgress
	progress.progressCancel = widgets.progressCancel

	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.add_diamond:onClick(self, self.addDiamondBtn)
	widgets.add_coin:onClick(self , self.addCoinBtn)
	widgets.makeBtn:onClick(self, self.onMakeBtn)
	widgets.giveUpBtn:onClick(self, self.onGiveUpBtnBtn)
	widgets.saveBtn:onClick(self, self.onSaveBtn)
	widgets.progressCancel:onClick(self, self.onCancelMakeBtn)
	
	self._widgets.itemScroll		= widgets.itemScroll
	self._widgets.jiantou			= widgets.jiantou
	self._widgets.leftScroll		= widgets.leftScroll
	self._widgets.details			= details
	self._widgets.makeBtn			= widgets.makeBtn
	self._widgets.giveUpBtn			= widgets.giveUpBtn
	self._widgets.saveBtn			= widgets.saveBtn
	self._widgets.progress 			= progress
end

function wnd_make_legend_equip:refresh(equip, legends)
	self:updateMoney(g_i3k_game_context:GetDiamond(true), g_i3k_game_context:GetDiamond(false), g_i3k_game_context:GetMoney(true), g_i3k_game_context:GetMoney(false))
	local bagSize, bagItems = g_i3k_game_context:GetBagInfo()
	self:updateLeftScrol(bagItems)
	if equip and equip.id ~= 0 then
		self._id = equip.id
		self._guid = equip.guid
		self._equip = equip
		self._equipCfg = g_i3k_db.i3k_db_get_equip_item_cfg(equip.id)
		self._isMaking = true
		self:loadComparDetail(self._widgets.details[1], equip.durability, equip.addValues, equip.refine, equip.legends)
		self:updateRightComparDetail(legends, true)
		local cszbt = require(WIDGETS_CSZBT)()
		self:updateScrollWidget(cszbt.vars, equip.id, equip.guid, equip.legends)
		self._widgets.leftScroll:addItem(cszbt)
	else
		self:restComparUI()
	end
	self:updateNeedItem()
	self:updateFuncBtnVis()
	self:updateLeftBtnState(true)
end

function wnd_make_legend_equip:updateLeftScrol(bagInfo)
	self._widgets.leftScroll:removeAllChildren()
	local items = self:itemSort(bagInfo)
	for i,e in ipairs(items) do
		local itype = g_i3k_db.i3k_db_get_common_item_type(e.id)
		local rank = g_i3k_db.i3k_db_get_common_item_rank(e.id)
		if itype == g_COMMON_ITEM_TYPE_EQUIP and rank >= g_RANK_VALUE_PURPLE then--紫装或橙装，传世装备
			local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
			local cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
			for k=1,cell_count do
				local cszbt = require(WIDGETS_CSZBT)()
				local legendCount = self:getLegendCount(e.allLegends[k])
				--local itemCount = k == cell_count and e.count-(cell_count-1)*stack_count or stack_count
				self:updateScrollWidget(cszbt.vars, e.id, e.guids[k], e.allLegends[k])
				self._widgets.leftScroll:addItem(cszbt)
			end
		end
	end
end

function wnd_make_legend_equip:getLegendCount(legends)
	local count = 0
	for i, e in ipairs(legends) do
		if e ~= 0 then
			count = count + 1
		end
	end
	return count
end

function wnd_make_legend_equip:updateScrollWidget(widget, id, guid, legends)
	local equip = g_i3k_game_context:GetBagEquip(id, guid)
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(id)
	widget.equipName:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widget.equipName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	widget.equipLvl:setText(equip_t.levelReq.."级")
	widget.equipLvl:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= equip_t.levelReq))
	widget.equipGrade:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.equipIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widget.suo:setVisible(id>0)
	widget.id = id
	widget.count = count
	widget.guid = guid
	widget.cfg = equip_t
	widget.legends = legends
	local rankIndex = g_i3k_game_context:GetBagEquipIsSpecial(id, equip and equip.naijiu or self._durability)
	if rankIndex ~= 0 then
		local index = rankIndex == 1 and 2 or 1
		widget["an"..index]:show()
	end
	widget.equipBtn:onClick(self, self.onSelectEuqip, widget)
end

function wnd_make_legend_equip:itemSort(items)
	local sort_items = {}
	for k,v in pairs(items) do
		local guids = {}
		local allLegends = {}
		for kk, vv in pairs(v.equips) do
			table.insert(guids, kk)
			table.insert(allLegends, vv.legends)
		end
		table.insert(sort_items, { sortid = g_i3k_db.i3k_db_get_bag_item_order(k), id = v.id, count = v.count, guids = guids, allLegends = allLegends})
	end
	table.sort(sort_items,function (a,b)
		return a.sortid < b.sortid
	end)
	return sort_items
end

function wnd_make_legend_equip:onSelectEuqip(sender, widget)
	local callbackFunc = function()
		self._id = widget.id
		self._guid = widget.guid
		local equip = g_i3k_game_context:GetBagEquip(self._id, self._guid)
		self._equip = equip
		self._equipCfg = widget.cfg
		self:restComparUI()
		self:updateLeftBtnState()
		self:updateFuncBtnVis()
		self:loadComparDetail(self._widgets.details[1], equip.naijiu, equip.attribute, equip.refine, equip.legends)
	end
	if self._guid ~= widget.guid then
		if self._isMaking then
			local fun = function(isOk)
				if isOk then
					i3k_sbean.legend_quit(false, callbackFunc)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2("您正在打造，切换就会舍弃当前的打造结果，是否关闭切换", fun)
		else
			callbackFunc()
		end
	end
end

function wnd_make_legend_equip:updateRightComparDetail(legends, isSync)
	self._isMaking = true
	self._legends = legends
	local equip = self._equip
	local naijiu = isSync and equip.durability or equip.naijiu
	local attribute = isSync and equip.addValues or equip.attribute
	self:loadComparDetail(self._widgets.details[2], naijiu, attribute, equip.refine, legends)
	if not isSync then
		self:updateFuncBtnVis()
	end
end

function wnd_make_legend_equip:updateLeftBtnState(isJump)
	local index
	local allLeftNode = self._widgets.leftScroll:getAllChildren()
	for i, e in ipairs(allLeftNode) do
		local node = e.vars
		if node.guid == self._guid then
			index = i
			node.equipBtn:stateToPressed()
		else
			node.equipBtn:stateToNormal()
		end
	end
	if index and isJump then
		self._widgets.leftScroll:jumpToChildWithIndex(index)
	end
end

function wnd_make_legend_equip:loadComparDetail(details, naijiu, attribute, refine, legends)
	local id = self._id
	local cfg = self._equipCfg
	local total_power = g_i3k_game_context:GetBagEquipPower(id, attribute, naijiu, refine, legends)
	details.equipBg:show()
	details.equipIcon:show()
	details.equipName:show()
	details.powerLabel:show()
	details.transformLabel:show()
	details.cType:show()
	details.lvlLabel:show()
	details.powerImg:show()

	details.equipBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	details.equipIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	details.equipName:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	details.equipName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	details.powerLabel:setText(math.modf(total_power))
	details.lvlLabel:setText(cfg.levelReq.."级")
	details.lvlLabel:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= cfg.levelReq))
	
	local cTypeStr = g_i3k_game_context:GetTransformLvl() < cfg.C_require and "<c=red>"..cfg.C_require.."转</c>" or cfg.C_require.."转"
	local role1Str = ""
	if cfg.M_require == 1 then
		role1Str = cfg.M_require ~= g_i3k_game_context:GetTransformBWtype() and "<c=red>正</c>" or "正"
	elseif cfg.M_require == 2 then
		role1Str = cfg.M_require ~= g_i3k_game_context:GetTransformBWtype() and "<c=red>邪</c>" or "邪"
	end
	details.transformLabel:setText(cTypeStr.." "..role1Str)
	details.cType:setText(TYPE_SERIES_NAME[cfg.roleType])
	if cfg.roleType ~= 0 and cfg.roleType ~= g_i3k_game_context:GetRoleType() then
		details.cType:setTextColor(g_i3k_get_red_color())
	else
		details.cType:setTextColor(g_i3k_get_green_color())
	end
	self:setScrollLegends(details.legendScroll, legends, cfg.partID)
	self:setScrollData(details.scroll, cfg, naijiu, attribute, refine, legends)
end

function wnd_make_legend_equip:setScrollLegends(list, legends, partID)
	for i, e in ipairs(legends) do
		if e ~= 0 then
			local node = require(WIDGETS_CSZBT2)()
			local cfg = LegendsTab[i]
			local nCfg = i == 3 and cfg[partID][e] or cfg[e]
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(nCfg.icon))
			list:addItem(node)
		end
	end
end

function wnd_make_legend_equip:restComparUI()
	self._isMaking = false
	for _, e in ipairs(self._widgets.details) do
		e.equipBg:setImage(g_i3k_db.i3k_db_get_icon_path(106))
		e.equipIcon:hide()
		e.equipName:hide()
		e.powerLabel:hide()
		e.powerImg:hide()
		e.transformLabel:hide()
		e.cType:hide()
		e.lvlLabel:hide()
		e.legendScroll:removeAllChildren()
		e.scroll:removeAllChildren()
	end
end

function wnd_make_legend_equip:restLeftsate()
	local allLeftNode = self._widgets.leftScroll:getAllChildren()
	for i, e in ipairs(allLeftNode) do
		local node = e.vars
		node.equipBtn:stateToNormal()
	end
	self._id = nil
	self._guid = nil
end

function wnd_make_legend_equip:updateFuncBtnVis()
	self._widgets.makeBtn:setVisible(not self._isMaking)
	self._widgets.saveBtn:setVisible(self._isMaking)
	self._widgets.giveUpBtn:setVisible(self._isMaking)
end

function wnd_make_legend_equip:updateNeedItem()
	self._widgets.itemScroll:removeAllChildren()
	for i, e in ipairs(i3k_db_equips_legends_consume) do
		if e.itemId ~= 0 then
			local node = require(WIDGETS_CSZBT5)()
			node.vars.itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemId))
			node.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemId, g_i3k_game_context:IsFemaleRole()))
			if math.abs(e.itemId) == g_BASE_ITEM_DIAMOND or math.abs(e.itemId) == g_BASE_ITEM_COIN then
				node.vars.itemCount:setText(e.itemCount)
			else
				node.vars.itemCount:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.itemId).."/"..e.itemCount)
			end
			node.vars.itemCount:setTextColor(g_i3k_get_cond_color(e.itemCount < g_i3k_game_context:GetCommonItemCanUseCount(e.itemId)))
			node.vars.itemBtn:onClick(self, self.onItemTips, e.itemId)
			table.insert(self._needItems, {id = e.itemId, count = e.itemCount})
			self._widgets.itemScroll:addItem(node)
		end
	end
end

function wnd_make_legend_equip:isItemEnough()
	local count = 0
	for i, e in ipairs(self._needItems) do
		if g_i3k_game_context:GetCommonItemCanUseCount(e.id) >= e.count then
			count = count + 1
		end
	end
	return count >= #self._needItems
end

function wnd_make_legend_equip:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_make_legend_equip:addDiamondBtn(sender)
	g_i3k_logic:OpenChannelPayUI()
end

function wnd_make_legend_equip:addCoinBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

function wnd_make_legend_equip:onGiveUpBtnBtn(sender)
	if self._legends and self:getLegendCount(self._legends) >  self:getLegendCount(self._equip.legends) then
		local fun = function(isOk)
			if isOk then
				i3k_sbean.legend_quit()
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2("放弃将会舍弃当前更高的打造，确认舍弃？", fun)
	else
		i3k_sbean.legend_quit()
	end
end

function wnd_make_legend_equip:onMakeBtn(sender)
	if self._guid then
		if self:isItemEnough() then
			i3k_sbean.legend_make(self._id, self._guid, self._needItems)
		else
			g_i3k_ui_mgr:PopupTipMessage("所需物品不足")
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("你未选中任何要打造的装备")
	end
end

function wnd_make_legend_equip:onSaveBtn(sender)
	if self._legends and self:getLegendCount(self._equip.legends) > self:getLegendCount(self._legends) then
		local fun = function(isOk)
			if isOk then
				i3k_sbean.legend_save()
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2("保存将会舍弃当前的属性，确认保存？", fun)
	else
		i3k_sbean.legend_save()
	end
end

function wnd_make_legend_equip:onCloseUI(sender)
	if self._isMaking then
		local fun = function(isOk)
			if isOk then
				i3k_sbean.legend_quit(true)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2("关闭就会舍弃当前的打造结果，是否关闭介面", fun)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_MakeLegendEquip)
	end
end

function wnd_make_legend_equip:updateMoney(diamondF, diamondR, coinF, coinR)
	self._layout.vars.diamond:setText(diamondF)
	self._layout.vars.diamondLock:setText(diamondR)
	self._layout.vars.coin:setText(i3k_get_num_to_show(coinF))
	self._layout.vars.coinLock:setText(i3k_get_num_to_show(coinR))
end

function wnd_make_legend_equip:setScrollData(list, cfg, naijiu, attribute, refine, legends)
	local base_attribute = cfg.properties
	local expect_attribute = cfg.ext_properties
	--基础属性
	local des = require(WIDGETS_CSZBT4)()
	des.vars.desc:setText(base_attribute_desc)
	list:addItem(des)
	
	if next(base_attribute) then
		for k,v in ipairs(base_attribute) do
			if v.type ~= 0 then
				local des = require(WIDGETS_CSZBT3)()
				local _t = i3k_db_prop_id[v.type]
				local _desc = _t.desc
				local _value = v.value
				local Threshold = i3k_db_common.equip.durability.Threshold
				if naijiu ~= -1 and naijiu > Threshold then
					if legends[1] and legends[1] ~= 0 then
						_value = math.floor(_value * (1+i3k_db_equips_legends_1[legends[1]].count/10000))
					end
				end
				_value = math.modf(_value)
				_desc = _desc.." :"
				des.vars.desc:setText(_desc)
				des.vars.value:setText(i3k_get_prop_show(v.type, _value))
				list:addItem(des)
			end
		end
	end
	--附加属性
	if next(expect_attribute) then
		for k,v in ipairs(expect_attribute) do
			if v.type ~= 0 then
				if k == 1 then
					local des = require(WIDGETS_CSZBT4)()
					des.vars.desc:setText(add_attribute_desc)
					list:addItem(des)
				end
				local des = require(WIDGETS_CSZBT3)()
				if v.type == 1 then
					local _t = i3k_db_prop_id[v.args]
					des.vars.desc:setText(_t.desc)
					local value = attribute[k]
					local Threshold = i3k_db_common.equip.durability.Threshold
					if naijiu ~= -1 and naijiu > Threshold then
						if legends[2] and legends[2] ~= 0 then
							value = math.floor(value * (1+i3k_db_equips_legends_2[legends[2]].count/10000))
						end
					end
					des.vars.value:setText("+"..i3k_get_prop_show(v.args, value))
					list:addItem(des)
				elseif v.type == 2 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."等级 +"
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					list:addItem(des)
				elseif v.type == 3 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."CD -"
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					list:addItem(des)
				elseif v.type == 4 then
					local _t = i3k_db_skills[v.args]
					des.vars.desc:setText(name)
					des.vars.value:setText("10")
					list:addItem(_t.desc)
				end
			end
		end
	end
	
	--精炼属性
	if next(refine) then
		for k,v in pairs(refine) do
			if k == 1 then
				local des = require(WIDGETS_CSZBT4)()
				des.vars.desc:setText(refine_desc)
				list:addItem(des)
			end
			local des = require(WIDGETS_CSZBT3)()
			local _t = i3k_db_prop_id[v.id]
			des.vars.desc:setText(_t.desc)
			des.vars.value:setText("+"..i3k_get_prop_show(v.id, v.value))
			list:addItem(des)
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_make_legend_equip.new()
	wnd:create(layout)
	return wnd
end

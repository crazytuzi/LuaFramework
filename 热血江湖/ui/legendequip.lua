module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_legendEquip = i3k_class("wnd_legendEquip", ui.wnd_base)

local LAYER_ZBTIPST = "ui/widgets/zbtipst"
local LAYER_ZBTIPST3 = "ui/widgets/zbtipst3"
local LAYER_ZBTIPST2 = "ui/widgets/zbtipst2"
local LAYER_ZBTIPST6 = "ui/widgets/zbtipst6"

local base_attribute_desc = "基础属性"
local add_attribute_desc = "附加属性"
local diamond_desc = "宝石"
local refine_desc = "精炼属性"
local temper_desc = "锤炼属性"

local LegendsTab = {i3k_db_equips_legends_1, i3k_db_equips_legends_2, i3k_db_equips_legends_3}
local ITEMS_MAX_COUNT = 5

local STATE_ONE = 1
local STATE_TWO = 2
local STATE_TRE = 3
local STATE_FOU = 4


function wnd_legendEquip:ctor()
	self.timeCounter = 0
end

function wnd_legendEquip:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onClose)
	widgets.makeBtn:onClick(self, self.onMakeBtn)
end

function wnd_legendEquip:onClose(sender)
	if self._state == STATE_ONE then
		if not self._selectEquipFlag then
			self:onCloseUI()
		else
			local widgets = self._layout.vars
			widgets.selectedEquip:hide()
			self._selectEquipFlag = false
		end
	end
end

function wnd_legendEquip:onShow()
	-- TODO
	self._layout.vars.npcName:setText("神工")
	local npcModule = self._layout.vars.npcModule
	local modelId = 282
	ui_set_hero_model(npcModule, modelId)
	npcModule:playAction("chuanshi01")
	-- self._layout.vars.touchNpc:onClick(self, self.onClickNpc)
	-- self._layout.vars.npcTalkRoot:hide()
	math.randomseed(tostring(os.time()):reverse():sub(1, 7))
	self:updateState(STATE_ONE)
	self._layout.vars.consumeDesc:hide()
end


function wnd_legendEquip:updateNpcTalk()
	self._layout.vars.npcTalkRoot:show()
	self._layout.vars.npcTalk:setText(self:getNpcString())
end

function wnd_legendEquip:getNpcString()
	local index = 509200
	local rand = self:getDiffRandom(2)
	local state = self._state
	return i3k_db_dialogue[((state - 1) * 3 + rand + index)][1].txt
end

function wnd_legendEquip:getDiffRandom(range)
	local rand = math.random(0, range)
	if not self._random then
		self._random = rand
	else
		if rand == self._random then
			return self:getDiffRandom(range)
		end
	end
	self._random = rand
	return rand
end

function wnd_legendEquip:refresh(equip, legends) -- 如果上次有未保存，那么legends字段有数据
	if equip and equip.id ~= 0 then
		self.selectEquip = g_i3k_get_equip_from_bean(equip)
		self:makeSuccess(equip.id, equip.guid, equip.legends, legends)
		self._layout.vars.des4:hide()
		return
	end
	local bagSize, bagItems = g_i3k_game_context:GetBagInfo()
	self:updateScroll(bagItems)
end

function wnd_legendEquip:updateState(state)
	self:modelPlayAction(state)
	self._state = state
	self:updateNpcTalk()
	if state == STATE_FOU or state == STATE_TRE then
		state = state - 1
	end
	for i = 1, 3 do
		local stateName = "state"..i
		if state == i then
			self._layout.vars[stateName]:show()
		else
			self._layout.vars[stateName]:hide()
		end
	end
	self:updateDialogue(state)
end

function wnd_legendEquip:modelPlayAction(state)
	local anisNames = {"chuanshi02", "chuanshi02", "chuanshi02", "chuanshi03"}
	local npcModule = self._layout.vars.npcModule
	if state ~= 4 then
		g_i3k_coroutine_mgr:StopCoroutine(self.co1)
		npcModule:playAction(anisNames[state])
	else
		self.co1 = g_i3k_coroutine_mgr:StartCoroutine(function()
			npcModule:playAction("chuanshi03")
			g_i3k_coroutine_mgr.WaitForSeconds(3) --延时
			npcModule:playAction("chuanshi02")
			g_i3k_coroutine_mgr:StopCoroutine(self.co1)
			self.co1 = nil
		end)
	end
end

function wnd_legendEquip:onHide()
	g_i3k_coroutine_mgr:StopCoroutine(self.co1)
end

function wnd_legendEquip:updateDialogue(state)
	local widgetName = "dialogue"..state
	local index = 15401
	self._layout.vars[widgetName]:setText(i3k_get_string(index - 1 + state))
end


function wnd_legendEquip:itemSort(items)
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

-- 更新滚动条内，可以打造的物品
function wnd_legendEquip:updateScroll(bagItems)
	self._layout.vars.btn_scroll1:removeAllChildren()
	local items = self:itemSort(bagItems)
	local count = 0
	for i,e in ipairs(items) do
		local itype = g_i3k_db.i3k_db_get_common_item_type(e.id)
		local rank = g_i3k_db.i3k_db_get_common_item_rank(e.id)
		local itemCfg = g_i3k_db.i3k_db_get_common_item_cfg(e.id)
		if itype == g_COMMON_ITEM_TYPE_EQUIP and rank >= g_RANK_VALUE_PURPLE and not g_i3k_game_context:isFlyEquip(itemCfg.partID) then--紫装或橙装，传世装备
			local stack_count = g_i3k_db.i3k_db_get_bag_item_stack_max(e.id)
			local cell_count = g_i3k_get_use_bag_cell_size(e.count, stack_count)
			for k=1, cell_count do
				local widget = self:createScrollItem(e.id, e.guids[k], e.allLegends[k], count + 1)
				self._layout.vars.btn_scroll1:addItem(widget)
				count = count + 1
			end
		end
	end
	if count < ITEMS_MAX_COUNT then
		self:addOtherItem(self._layout.vars.btn_scroll1, ITEMS_MAX_COUNT - count)
	end

end
function wnd_legendEquip:addOtherItem(scroll, count)
	for k = 1, count do
		local item = require("ui/widgets/cszb2t1")()
		item.vars.countLabel:hide()
		scroll:addItem(item)
	end
end

-- 创建一个scroll中的item
function wnd_legendEquip:createScrollItem(id, guid, legends, tag)
	local equip = g_i3k_game_context:GetBagEquip(id, guid)
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(id)
	local item = require("ui/widgets/cszb2t1")()
	item.vars.suo:setVisible(id > 0)
	item.vars.countLabel:hide()
	item.vars.an11:hide()
	item.vars.an12:hide()
	if equip.naijiu and equip.naijiu ~= -1 then
		local rankIndex = g_i3k_game_context:GetBagEquipIsSpecial(id, equip.naijiu)
		local index = rankIndex == 1 and 2 or 1
		item.vars["an1"..index]:show()
	end
	item.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	item.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	local available = true -- TODO
	if not available then
		item.vars.is_show:show()
	end
	local data = {id = id, guid = guid, tag = tag}
	item.vars.bt:setTag(tag)
	item.vars.bt:onClick(self, self.onStateOneSelectBtn, data)
	return item
end

-- 判断进入下一个阶段
function wnd_legendEquip:onStateOneSelectBtn(sender, data)
	self:selectEquipShow(data.id, data.guid)
	self._selectEquipFlag = true
	local children = self._layout.vars.btn_scroll1:getAllChildren()
	for k, v in ipairs(children) do
		if v.vars.bt:getTag() == data.tag then
			v.vars.selectedImg:show()
		else
			v.vars.selectedImg:hide()
		end
	end
end

-- 选中了一个装备
function wnd_legendEquip:selectEquipShow(id, guid)
	local widgets = self._layout.vars
	widgets.selectedEquip:show()
	local equip = g_i3k_game_context:GetBagEquip(id, guid)
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(id)
	local itemid = equip.equip_id
	widgets.equip_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
	widgets.equip_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widgets.equip_name1:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	widgets.equip_name1:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	widgets.level1:setText(equip_t.levelReq.."级")
	widgets.level1:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetLevel() >= equip_t.levelReq))
	widgets.is_sale1:setText(g_i3k_db.i3k_db_get_common_item_can_sale(id) and id < 0 and "可交易" or "不可交易")
	widgets.is_free1:setText(id > 0 and "已绑定" or "未绑定")
	local partID = equip_t.partID
	widgets.part1:setText(i3k_db_equip_part[partID].partName)

	local roleName = TYPE_SERIES_NAME[equip_t.roleType]
	local C_require = equip_t.C_require
	local M_require = equip_t.M_require
	local roleStr = ""
	if M_require == 1 then
		roleStr = "转".."  正"
	elseif M_require == 2 then
		roleStr = "转".."  邪"
	elseif M_require == 0 then
		roleStr = "转"
	end
	widgets.role1:setText(roleName.."   "..C_require..roleStr)
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	self:setScrollLegends(scroll, equip.legends, partID)

	local base_attribute = equip_t.properties
	local expect_attribute = equip_t.ext_properties
	local naijiu = equip.naijiu
	local attribute = equip.attribute
	local refine = equip.refine
	local smeltingProps = equip.smeltingProps
	local hammerSkill = equip.hammerSkill
	self:setScrollData(scroll, base_attribute, expect_attribute, naijiu, attribute, refine, equip.legends, id, smeltingProps, hammerSkill)

	local total_power = g_i3k_game_context:GetBagEquipPower(id, attribute, naijiu, refine, equip.legends, smeltingProps)
	widgets.power_value1:setText(total_power)
	self._layout.vars.an11:hide()
	self._layout.vars.an12:hide()
	if naijiu and naijiu ~= -1 then
		widgets.naijiu1:show()
		widgets.naijiu1:setText("耐久:"..math.modf(naijiu/1000))
		local rankIndex = g_i3k_game_context:GetBagEquipIsSpecial(itemid, naijiu)
		local index = rankIndex == 1 and 2 or 1
		self._layout.vars["an1"..index]:show()
	else
		widgets.naijiu1:hide()
	end
	local data = {id = id, guid = guid, legends = equip.legends}
	widgets.submitBtnLabel:setText("提 交")
	widgets.submitBtn:onClick(self, self.onSubmitBtn, data)
end

function wnd_legendEquip:onSubmitBtn(sender, data)
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(data.id)
	if equip_t.legendsTips > 0 then
		local callback = function (isOk)
			if isOk then
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_LegendEquip, "gotoLegend", data)
			end
		end
		g_i3k_ui_mgr:ShowCustomMessageBox2("确认", "取消", i3k_get_string(equip_t.legendsTips), callback)
	else
		self:gotoLegend(data)
	end
	-- self._layout.vars.submitBtn:onClick(self, self.onMakeBtn)
	-- self._layout.vars.submitBtnLabel:setText("打 造")
end

function wnd_legendEquip:gotoLegend(data)
	local id = data.id
	local guid = data.guid
	local legends = data.legends
	local equip = g_i3k_game_context:GetBagEquip(id, guid)
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(id)
	local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	local consumeList = g_i3k_db.i3k_db_get_legend_consume_items_list(equip_t.levelReq, rank, equip_t.partID)
	-- TODO 切换ui
	self:updateState(STATE_TWO)
	self:setSupportScroll(consumeList)
	self:setSelectEquipInfo(id, guid, legends)
	self.selectEquip = equip
	self.selectEquipId = id
	self.selectEquipGuid = guid
	self.selectEquipLegends = legends
	self._layout.vars.selectedEquip:hide()
end

function wnd_legendEquip:setSupportScroll(itemList)
	self._layout.vars.btn_scroll2:removeAllChildren()
	local count = 0
	for _, v in pairs(itemList) do
		local item = self:createConsumeItem(v)
		self._layout.vars.btn_scroll2:addItem(item)
		count = count + 1
	end
	if count < ITEMS_MAX_COUNT then
		self:addOtherItem(self._layout.vars.btn_scroll2, ITEMS_MAX_COUNT - count)
	end
end

-- 创建一个传世装备打造消耗物品
function wnd_legendEquip:createConsumeItem(itemID)
	local item = require("ui/widgets/cszb2t1")()
	item.vars.suo:hide() --setVisible(itemID > 0)
	item.vars.countLabel:show()
	item.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
	item.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
	local bindCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
	local available = bindCount > 0
	if not available then
		-- 灰化图片
		item.vars.grade_icon:disableWithChildren()
		item.vars.item_icon:disableWithChildren()
	end
	item.vars.bt:setTag(itemID)
	item.vars.countLabel:setText("x"..bindCount)
	item.vars.bt:onClick(self, self.onSelectConsumeBtn, itemID)
	return item
end

-- 设置二阶段显示信息
function wnd_legendEquip:setSelectEquipInfo(itemID, guid, legends)
	local widgets = self._layout.vars
	widgets.back1Btn:onClick(self, self.backToState1Btn)
	widgets.selectEquipBase:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
	widgets.selectEquipIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID, g_i3k_game_context:IsFemaleRole()))
	widgets.selectEquipName:setText(g_i3k_db.i3k_db_get_common_item_name(itemID))
	widgets.selectEquipName:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemID)))
end

function wnd_legendEquip:backToState1Btn(sender)
	self:updateState(STATE_ONE)
	self.selectConsumeItem = nil
	self._layout.vars.consumeDesc:hide()
	self._layout.vars.selectedEquip:show()
end

function wnd_legendEquip:onSelectConsumeBtn(sender, itemID)
	self.selectConsumeItem = itemID
	local children = self._layout.vars.btn_scroll2:getAllChildren()
	for k, v in pairs(children) do
		if v.vars.bt:getTag() == itemID then
			v.vars.selectedImg:show()
			self._layout.vars.consumeDesc:show()
			local cfg = g_i3k_db.i3k_db_get_other_item_cfg(itemID)
			local descString = string.gsub(cfg.desc, "purple", "hlgreen")
			self._layout.vars.consumeDesc:setText(cfg.name.."——"..descString)
		else
			v.vars.selectedImg:hide()
		end
	end
end

-- 打造按钮
function wnd_legendEquip:onMakeBtn(sender)
	-- 如果没选中材料
	-- 如果道具数量不足
	-- 发协议
	if self._makeSuccessFlag then
		return
	end
	local itemID = self.selectConsumeItem
	if not itemID then
		g_i3k_ui_mgr:PopupTipMessage("未选择任何材料")
		return
	end
	local bindCount = g_i3k_game_context:GetCommonItemCanUseCount(itemID)
	if bindCount == 0 then
		g_i3k_ui_mgr:PopupTipMessage("道具数量不足")
		return
	end
	local id = self.selectEquipId
	local guid = self.selectEquipGuid
	local oldLegends = self.selectEquipLegends
	if not id or not guid then
		g_i3k_ui_mgr:PopupTipMessage("未选择任何装备")
		return
	end

	i3k_sbean.legend_make(id, guid, itemID, oldLegends)
	self._makeSuccessFlag = true
	self._layout.vars.makeBtn:hide()
end

function wnd_legendEquip:playMakeSuccess(id, guid, oldLegends, newLegends, giftReward)
	self:updateState(STATE_TRE)
	local widgets = self._layout.vars
	local anis = self._layout.anis.c_zbqh
	local callback = function()
		self:makeSuccess(id, guid, oldLegends, newLegends)
		self._makeSuccessFlag = nil
		self._layout.vars.makeBtn:show()
	end
	anis.play(callback)
	
	if giftReward == 0 then
		widgets.des4:hide()
		return
	end
	
	widgets.des4:show()
	widgets.des4:setText(i3k_get_string(1427))
end

-- 打造成功回调(数据都是协议带回来的)
function wnd_legendEquip:makeSuccess(id, guid, oldLegends, newLegends)
	self:updateState(STATE_FOU)
	self._layout.vars.selectedEquip:hide()
	local widgets = self._layout.vars
	widgets.giveUpBtn:onClick(self, self.onGiveUpBtn)
	widgets.giveUpBtn:show()
	widgets.saveBtn:onClick(self, self.onSaveBtn)


	for i = 1, 2 do
		local gradeIcon = "cmpGradeIcon"..i
		local icon = "cmpIcon"..i
		local name = "cmpName"..i
		widgets[gradeIcon]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widgets[icon]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		widgets[name]:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		widgets[name]:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(id)))
	end
	local equip_t = g_i3k_db.i3k_db_get_equip_item_cfg(id)
	local partID = equip_t.partID
	local scroll = widgets.cmpScroll1
	local equip = self.selectEquip
	-- 设置显示旧属性
	scroll:removeAllChildren()
	self:setScrollLegends(scroll, oldLegends, partID)
	local showBtnFlag = false
	for i,e in ipairs(oldLegends) do
		if e ~= 0 then
			showBtnFlag = true
		end
	end
	if not showBtnFlag then
		widgets.giveUpBtn:hide()
	end
	-- local base_attribute = equip_t.properties
	-- local expect_attribute = equip_t.ext_properties
	-- local naijiu = equip.naijiu
	-- local attribute = equip.attribute
	-- local refine = equip.refine
	-- self:setScrollData(scroll, base_attribute, expect_attribute, naijiu, attribute, refine, oldLegends)

	--设置显示新属性
	local scrollNew = widgets.cmpScroll2
	scrollNew:removeAllChildren()
	self:setScrollLegends(scrollNew, newLegends, partID)
	-- local base_attribute = equip_t.properties
	-- local expect_attribute = equip_t.ext_properties
	-- local naijiu = equip.naijiu
	-- local attribute = equip.attribute
	-- local refine = equip.refine
	-- self:setScrollData(scrollNew, base_attribute, expect_attribute, naijiu, attribute, refine, newLegends)
end

function wnd_legendEquip:onSaveBtn(sender)
	i3k_sbean.legend_save()
end

function wnd_legendEquip:onGiveUpBtn(sender)
	local msg = i3k_get_string(15468)
	local callback = function (isOk)
		if isOk then
			i3k_sbean.legend_quit()
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
end

-- 点击退出或者保存，跳转到第一个界面
function wnd_legendEquip:saveOrQuitCallback()
	self:updateState(STATE_ONE)
	self.selectConsumeItem = nil
	self._selectEquipFlag = nil
	self._layout.vars.consumeDesc:hide()
	i3k_sbean.legend_sync()
end

------------------------------------------------
function wnd_legendEquip:addScrollNullItem(scroll)
	local item = require("ui/widgets/cszb2t4")()
	scroll:addItem(item)
end


-- 设置显示传世装备属性
function wnd_legendEquip:setScrollLegends(scroll, legends, partID)
	local count = 0
	for i,e in ipairs(legends) do
		if e ~= 0 then
			count = count + 1
			local layer = require("ui/widgets/sjzbt")()
			local widget = layer.vars
			local cfg = LegendsTab[i]
			local nCfg
			if i == 3 then
				nCfg = cfg[partID][e]
			else
				nCfg = cfg[e]
			end
			widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(nCfg.icon))
			widget.desc:setText(nCfg.tips);
			scroll:addItem(layer)
		end
	end
	if count == 0 then
		self:addScrollNullItem(scroll)
	end
end

-- 设置显示通用装备的属性
function wnd_legendEquip:setScrollData(list, base_attribute, expect_attribute, naijiu, attribute, refine, legends,equipID, smeltingProps, hammerSkill)
	--基础属性
	local des = require(LAYER_ZBTIPST3)()
	des.vars.desc:setText(base_attribute_desc)
	list:addItem(des)

	if base_attribute and type(base_attribute) == "table" then
		for k,v in ipairs(base_attribute) do
			if v.type ~= 0 then
				local des = require(LAYER_ZBTIPST)()
				local _t = i3k_db_prop_id[v.type]
				local _desc = _t.desc
				local colour1 = _t.textColor
				local colour2 = _t.valuColor
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
				--des.vars.desc:setTextColor(colour1)
				des.vars.value:setText(i3k_get_prop_show(v.type, _value))
				--des.vars.value:setTextColor(colour2)
				list:addItem(des)
			end
		end
	end
	--附加属性
	if expect_attribute and type(expect_attribute) == "table" then
		for k,v in ipairs(expect_attribute) do
			if v.type ~= 0 then
				if k == 1 then
					local des = require(LAYER_ZBTIPST3)()
					des.vars.desc:setText(add_attribute_desc)
					list:addItem(des)
				end
				local des = require(LAYER_ZBTIPST)()
				local max = g_i3k_db.i3k_db_is_equip_ext_prop_sharpen_max(equipID, k, attribute[k])
				if max then
					des.vars.max_img:show()
				end
				if v.type == 1 then
					local _t = i3k_db_prop_id[v.args]
					local _desc = _t.desc
					local colour1 = _t.textColor
					local colour2 = _t.valuColor
					_desc = _desc
					des.vars.desc:setText(_desc)
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
					--des.vars.desc:setTextColor(colour1)
					--des.vars.value:setTextColor(colour2)
					des.vars.value:setText("10")
					list:addItem(des)
				elseif v.type == 3 then
					local _t = i3k_db_skills[v.args]
					local name = _t.name
					name = name.."CD -"
					des.vars.desc:setText(name)
					--des.vars.desc:setTextColor(colour1)
					--des.vars.value:setTextColor(colour2)
					des.vars.value:setText("10")
					list:addItem(des)
				elseif v.type == 4 then
					local _t = i3k_db_skills[v.args]
					local _desc= _t.desc
					des.vars.desc:setText(name)
					--des.vars.desc:setTextColor(colour1)
					--des.vars.value:setTextColor(colour2)
					des.vars.value:setText("10")
					list:addItem(_desc)
				end
			end
		end
	end

	--精炼属性
	if next(refine) then
		for k,v in pairs(refine) do
			if k == 1 then
				local des = require(LAYER_ZBTIPST3)()
				des.vars.desc:setText(refine_desc)
				list:addItem(des)
			end
			local des = require(LAYER_ZBTIPST)()
			local _t = i3k_db_prop_id[v.id]
			local _desc = _t.desc
			des.vars.desc:setText(_desc)
			des.vars.value:setText("+"..i3k_get_prop_show(v.id, v.value))
			list:addItem(des)
		end
	end

	--锤炼属性
	if smeltingProps and next(smeltingProps) then
		local des = require(LAYER_ZBTIPST3)()
		des.vars.desc:setText(temper_desc)
		list:addItem(des)
		for i, v in ipairs(smeltingProps) do
			local des = require(LAYER_ZBTIPST)()
			local _t = i3k_db_prop_id[v.id]
			local _desc = _t.desc
			des.vars.desc:setText(_desc)
			des.vars.value:setText("+"..i3k_get_prop_show(v.id, v.value))
			list:addItem(des)
		end
		if hammerSkill and next(hammerSkill) then
			for i, v in pairs(hammerSkill) do
				local cfg = i3k_db_equip_temper_skill[i][v]
				local layer = require(LAYER_ZBTIPST6)()
				layer.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
				layer.vars.desc:setText(cfg.name)
				list:addItem(layer)
			end
		end
	end
end

----------------------------------------
function wnd_create(layout)
	local wnd = wnd_legendEquip.new();
		wnd:create(layout);
	return wnd;
end

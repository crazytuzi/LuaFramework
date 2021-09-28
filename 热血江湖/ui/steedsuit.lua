-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/steedBase");

-------------------------------------------------------
wnd_steedSuit = i3k_class("wnd_steedSuit", ui.wnd_steedBase)

local RowitemCount = 1

local haveImg = 4700
local noHaveImg = 4699

local equipIcon = 8165
local bagIcon = 8164

function wnd_steedSuit:ctor()
	self.steed_equip = {}

	self._chooseStep = 0
	self._chooseRank = 0

	self._curSelectSuitID = nil
end

function wnd_steedSuit:configure()
	-- 重写父类
	ui.wnd_steedBase.configure(self)
	local widgets = self._layout.vars
	widgets.suitBtn:stateToPressed(true)

	widgets.autoWearBtn:onClick(self, self.onAutoWear)
	widgets.makeUpSuitBtn:onClick(self, self.onMakeUpSuit)
	widgets.stepBtn:onClick(self, function()
		widgets.levelRoot2:setVisible(not widgets.levelRoot2:isVisible())
	end)
	widgets.gradeBtn:onClick(self, function()
		widgets.levelRoot:setVisible(not widgets.levelRoot:isVisible())
	end)
	widgets.noHaveSuitBtn:onClick(self, function()
		widgets.markImg:setVisible(not widgets.markImg:isVisible())
		self._curSelectSuitID = nil
		self:updateSuitScroll()
	end)

	self:initSteedEquipWidget(widgets)
end

--初始化宠物装备控件
function wnd_steedSuit:initSteedEquipWidget(widgets)
	for i = 1, g_STEED_EQUIP_PART_COUNT do
		local equip_btn = "equip" .. i
		local equip_icon = "equip_icon" .. i
		local grade_icon = "grade_icon" .. i
		local is_select = "is_select" .. i
		local level_label = "qh_level" .. i
		local haveIcon = "haveIcon" .. i
		local equipLine = "equipLine" .. i

		self.steed_equip[i] = {
			equip_btn = widgets[equip_btn],
			equip_icon = widgets[equip_icon],
			grade_icon = widgets[grade_icon],
			is_select = widgets[is_select],
			level_label = widgets[level_label],
			haveIcon = widgets[haveIcon],
			equipLine = widgets[equipLine],
		}
	end
end

function wnd_steedSuit:refresh(suitID)
	self._curSelectSuitID = suitID

	self:setChoseScroll()
	self:updateSuitScroll()
	self:updateSteedRed() -- @Override
end

--设置分组下拉框
function wnd_steedSuit:setChoseScroll()
	local widgets = self._layout.vars
	widgets.filterScroll:removeAllChildren()
	widgets.filterScroll2:removeAllChildren()

	local step = self:getChooseStep()
	local rank = self:getChooseRank()
	widgets.gradeLabel:setText(i3k_db_steed_equip_quality[rank].name)
	widgets.gradeLabel2:setText(i3k_db_steed_equip_step[step].name)

	--阶位
	for i = 0, #i3k_db_steed_equip_step do
		local item = require("ui/widgets/qizhanzhuangbeit2")()
		item.vars.name:setText(i3k_db_steed_equip_step[i].name)
		item.vars.btn:onClick(self, function()
			self:choseSteedStep(i)
		end)
		widgets.filterScroll2:addItem(item)
	end

	--品质
	local rankVector = {}
	for k, v in pairs(i3k_db_steed_equip_quality) do
		table.insert(rankVector, {rank = k, data = v})
	end
	table.sort(rankVector, function(a, b)
		return a.rank < b.rank
	end)

	for _, v in ipairs(rankVector) do
		local item = require("ui/widgets/qizhanzhuangbeit2")()
		local rank = v.rank
		item.vars.name:setText(i3k_db_steed_equip_quality[rank].name)
		item.vars.btn:onClick(self, function()
			self:choseSteedRank(rank)
		end)
		widgets.filterScroll:addItem(item)
	end
end

function wnd_steedSuit:choseSteedStep(step)
	local widgets = self._layout.vars
	if self._chooseStep == step then
		return
	end

	self._chooseStep = step

	widgets.levelRoot2:setVisible(false)
	widgets.gradeLabel2:setText(i3k_db_steed_equip_step[step].name)

	self._curSelectSuitID = nil
	self:updateSuitScroll()
end

function wnd_steedSuit:choseSteedRank(rank)
	local widgets = self._layout.vars
	if self._chooseRank == rank then
		return
	end

	self._chooseRank = rank

	widgets.levelRoot:setVisible(false)
	widgets.gradeLabel:setText(i3k_db_steed_equip_quality[rank].name)

	self._curSelectSuitID = nil
	self:updateSuitScroll()
end

function wnd_steedSuit:getChooseStep()
	return self._chooseStep
end

function wnd_steedSuit:getChooseRank()
	return self._chooseRank
end

function wnd_steedSuit:updateSuitScroll()
	local widgets = self._layout.vars
	local step = self:getChooseStep()
	local rank = self:getChooseRank()
	local isShowNoHaveSuit = widgets.markImg:isVisible()

	local sortSuitCfg = {}
	for suitID, cfg in pairs(i3k_db_steed_equip_suit) do
		table.insert(sortSuitCfg, {suitID = suitID, cfg = cfg})
	end
	table.sort(sortSuitCfg, function(a, b)
		return a.suitID < b.suitID
	end)

	local suitData = g_i3k_game_context:GetSteedAllSuitsData()
	local filterSuitCfg = {}
	for _, v in ipairs(sortSuitCfg) do
		local cfgStep = v.cfg.step
		local cfgrank = v.cfg.quality
		if (cfgStep == step or step == 0) and (cfgrank == rank or rank == 0) then
			if isShowNoHaveSuit then
				if not suitData[v.suitID] then
					table.insert(filterSuitCfg, v)
				end
			else
				table.insert(filterSuitCfg, v)
			end
		end
	end

	local selectIndex = 0
	local selectSuitID = 0

	widgets.scroll:removeAllChildren()
	if #filterSuitCfg > 0 then
		local allBars = widgets.scroll:addChildWithCount("ui/widgets/qizhantaozhuangt1", RowitemCount, #filterSuitCfg)
		for i, v in ipairs(allBars) do
			local suitID = filterSuitCfg[i].suitID
			local cfg = filterSuitCfg[i].cfg
			local stateImgID = suitData[suitID] and haveImg or noHaveImg
			v.vars.state:setImage(g_i3k_db.i3k_db_get_icon_path(stateImgID))
			v.vars.colorPoint:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.imgID))
			v.vars.nameLabel:setText(cfg.name)
			v.vars.btn:onClick(self, function()
				self:selectSuit(i, suitID)
			end)
			--默认选中的套装
			if selectIndex == 0 then
				selectIndex = i
				selectSuitID = suitID
			end
		end
	end

	local isUseCurSelect = false
	if self._curSelectSuitID then
		for _, v in ipairs(filterSuitCfg) do
			if self._curSelectSuitID == v.suitID then
				isUseCurSelect = true
				break
			end
		end
	end
	
	--从骑战背包跳转骑战套装的suitID
	selectSuitID = isUseCurSelect and self._curSelectSuitID or selectSuitID

	for i, v in ipairs(filterSuitCfg) do
		if v.suitID == selectSuitID then
			selectIndex = i
			break
		end
	end

	widgets.noSuitRoot:setVisible(selectSuitID == 0)
	if selectSuitID ~= 0 then
		widgets.scroll:jumpToChildWithIndex(selectIndex)
		self:selectSuit(selectIndex, selectSuitID)
	end
end

function wnd_steedSuit:selectSuit(index, suitID)
	local widgets = self._layout.vars
	local allLayer = widgets.scroll:getAllChildren()

	self._curSelectSuitID = suitID

	for i, v in ipairs(allLayer) do
		if index == i then
			v.vars.btn:stateToPressed()
		else
			v.vars.btn:stateToNormal()
		end
	end

	self:setSuitUI(suitID)
	self:setSuitPropUI(suitID)
end

function wnd_steedSuit:setSuitUI(suitID)
	local needEquip = g_i3k_db.i3k_db_get_steed_equip_suit_need_equip(suitID)
	local wEquip = g_i3k_game_context:GetSteedWearEquipsData()
	local _, bagItems = g_i3k_game_context:GetBagInfo()

	for i, v in ipairs(self.steed_equip) do
		if i <= g_STEED_EQUIP_PART_COUNT then
			local equipID = needEquip[i]
			if equipID then
				v.equip_btn:enable()
				v.equip_icon:show()
				v.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
				v.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
				v.equip_btn:onClick(self, self.onSelectEquip, {partID = i, equipID = equipID})
				v.level_label:setText(g_i3k_db.i3k_db_get_common_item_name(equipID))

				--装备状态显示
				if wEquip[i] and wEquip[i] == equipID then
					v.haveIcon:show()
					v.haveIcon:setImage(g_i3k_db.i3k_db_get_icon_path(equipIcon))
					v.equipLine:show()
				elseif bagItems[equipID] then
					v.haveIcon:show()
					v.haveIcon:setImage(g_i3k_db.i3k_db_get_icon_path(bagIcon))
					v.equipLine:hide()
				else
					v.haveIcon:hide()
					v.equipLine:hide()
				end
			else
				v.equip_btn:disable()
				v.equip_icon:hide()
				v.grade_icon:setImage(g_i3k_get_steed_equip_icon_frame_path_by_pos(i))
				v.level_label:hide()
				v.haveIcon:hide()
				v.equipLine:hide()
			end
		else
			v.equip_icon:setImage()--一张灰化的图
			v.grade_icon:setImage(g_i3k_get_steed_equip_icon_frame_path_by_pos(i))
			v.level_label:hide()
			v.haveIcon:hide()
			v.equipLine:hide()
			v.equip_btn:onClick(self, function()
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1537))
			end)
		end
		v.is_select:hide()
	end
end

function wnd_steedSuit:setSuitPropUI(suitID)
	local widgets = self._layout.vars
	local scroll = widgets.scroll2
	scroll:removeAllChildren()

	local needEquipProps = g_i3k_game_context:GetSteedSuitNeedEquipProps(suitID)
	--装备属性
	if next(needEquipProps) then
		local header = require("ui/widgets/qizhantaozhuangt3")()
		header.vars.desc:setText(i3k_get_string(1634))
		scroll:addItem(header)

		for _, v in ipairs(needEquipProps) do
			if v.id ~= 0 then
				local ui = require("ui/widgets/qizhantaozhuangt2")()
				local _t = i3k_db_prop_id[v.id]
				ui.vars.desc:setText(_t.desc)
				ui.vars.value:setText(i3k_get_prop_show(v.id, v.count))
				local icon = g_i3k_db.i3k_db_get_property_icon(v.id)
				ui.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
				scroll:addItem(ui)
			end
		end
	end

	--套装属性
	local suitProps = g_i3k_game_context:GetOneSteedEquipSuitProps(suitID)
	local sortSuitProps = {}
	for k, v in pairs(suitProps) do
		table.insert(sortSuitProps, {id = k, count = v})
	end
	table.sort(sortSuitProps, function(a, b)
		return a.id < b.id
	end)
	if next(sortSuitProps) then
		local header = require("ui/widgets/qizhantaozhuangt3")()
		header.vars.desc:setText(i3k_get_string(1635))
		scroll:addItem(header)

		for _, v in ipairs(sortSuitProps) do
			if v.id ~= 0 then
				local ui = require("ui/widgets/qizhantaozhuangt2")()
				local _t = i3k_db_prop_id[v.id]
				ui.vars.desc:setText(_t.desc)
				ui.vars.value:setText(i3k_get_prop_show(v.id, v.count))
				local icon = g_i3k_db.i3k_db_get_property_icon(v.id)
				ui.vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(icon))
				scroll:addItem(ui)
			end
		end
	end

	self:setSuitBattPower(suitID)
	self:setSuitMakeBtnState(suitID)
end

function wnd_steedSuit:setSuitBattPower(suitID)
	local suitProps = g_i3k_game_context:GetOneSteedEquipSuitProps(suitID)
	--套装装备属性
	local parts = i3k_db_steed_equip_suit[suitID].parts
	for _, equipID in ipairs(parts) do
		local property = g_i3k_game_context:GetOneSteedEquipBaseProps(equipID)
		for id, count in pairs(property) do
			suitProps[id] = (suitProps[id] or 0) + count
		end
	end
	local power = g_i3k_db.i3k_db_get_battle_power(suitProps, true)
	self._layout.vars.battle_power:setText(power)
end

function wnd_steedSuit:setSuitMakeBtnState(suitID)
	local widgets = self._layout.vars
	local suitData = g_i3k_game_context:GetSteedAllSuitsData()
	local isHave = suitData[suitID]
	widgets.makeUpSuitLabel:setText(isHave and i3k_get_string(1636) or i3k_get_string(1581))
	widgets.makeUpSuitBtn:SetIsableWithChildren(not isHave)
end

function wnd_steedSuit:onMakeUpSuit(sender)
	local suitID = self._curSelectSuitID
	local needEquip = g_i3k_db.i3k_db_get_steed_equip_suit_need_equip(suitID)

	--此套装所需全部部件是否已经装备
	local isSuitAllEquip = true
	--此套装剩余需要穿戴的装备
	local remainNeedEquip = {}

	local wEquip = g_i3k_game_context:GetSteedWearEquipsData()
	for partID, equipID in pairs(needEquip) do
		if not wEquip[partID] or wEquip[partID] ~= equipID then
			isSuitAllEquip = false
			remainNeedEquip[partID] = equipID
		end
	end

	--未装备的部位，当前背包中是否持有
	local isInBag = true
	local _, bagItems = g_i3k_game_context:GetBagInfo()
	for partID, equipID in pairs(remainNeedEquip) do
		if not bagItems[equipID] then
			isInBag = false
		end
	end

	--全部装备
	if isSuitAllEquip then
		g_i3k_ui_mgr:OpenUI(eUIID_SteedSuitActive)
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedSuitActive, suitID)
	else
		if isInBag then
			local callback = function()
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSuit, "setSuitUI", suitID)
				g_i3k_ui_mgr:OpenUI(eUIID_SteedSuitActive)
				g_i3k_ui_mgr:RefreshUI(eUIID_SteedSuitActive, suitID)
			end
			local fun = (function(ok)
				if ok then
					i3k_sbean.dress_steed_equip(remainNeedEquip, callback)
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1637), fun)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1638))
		end
	end
end

--一键装备
function wnd_steedSuit:onAutoWear(sender)
	local suitID = self._curSelectSuitID
	local bestEquip = g_i3k_game_context:getAllSteedEquipPerSuit(suitID)

	if next(bestEquip) then
		local changeCnt = table.nums(bestEquip)
		local callback = function()
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_SteedSuit, "setSuitUI", suitID)
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1639, changeCnt))
		end
		local fun = (function(ok)
			if ok then
				i3k_sbean.dress_steed_equip(bestEquip, callback)
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1637), fun)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1523))
	end
end

function wnd_steedSuit:onSelectEquip(sender, data)
	--打开装备tips
	g_i3k_ui_mgr:OpenUI(eUIID_steedEquipPropCmp)
	g_i3k_ui_mgr:RefreshUI(eUIID_steedEquipPropCmp, data.equipID, g_STEED_EQUIP_TIPS_NONE)
end

function wnd_steedSuit:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1640))
end

function wnd_create(layout)
	local wnd = wnd_steedSuit.new();
		wnd:create(layout);
	return wnd;
end

-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/steedBase")

-------------------------------------------------------
wnd_steedEquip = i3k_class("wnd_steedEquip", ui.wnd_steedBase)

local RowitemCount = 5

function wnd_steedEquip:ctor()
	self.steed_equip = {}

	self._isChange = false
	self._poptick = 0
	self._target = 0
	self._base = 0

	self._chooseStep = 0
	self._chooseRank = 0

	self._wantMakeSuitID = nil
	local timeNow = i3k_game_get_time()
	g_i3k_game_context:setDayFirstLoginSteedEquip(timeNow)
end

function wnd_steedEquip:configure()
	-- 重写父类
	ui.wnd_steedBase.configure(self)

	local widgets = self._layout.vars

	widgets.equipBtn:stateToPressed(true)
	widgets.prosBtn:onClick(self, self.onOpenPropTips)
	widgets.activateSuitBtn:onClick(self, self.onOpenSuitUI)
	widgets.autoWearBtn:onClick(self, self.onAutoWear)
	widgets.stepBtn:onClick(self, function()
		widgets.levelRoot2:setVisible(not widgets.levelRoot2:isVisible())
	end)
	widgets.gradeBtn:onClick(self, function()
		widgets.levelRoot:setVisible(not widgets.levelRoot:isVisible())
	end)

	self.addIcon = widgets.addIcon
	self.powerValue = widgets.powerValue
	self.battle_power = widgets.battle_power

	self:initSteedEquipWidget(widgets)
end

--初始化宠物装备控件
function wnd_steedEquip:initSteedEquipWidget(widgets)
	for i = 1, g_STEED_EQUIP_PART_COUNT do
		local equip_btn = "equip" .. i
		local equip_icon = "equip_icon" .. i
		local grade_icon = "grade_icon" .. i
		local is_select = "is_select" .. i
		local level_label = "qh_level" .. i
		local red_tips = "tips" .. i

		self.steed_equip[i] = {
			equip_btn = widgets[equip_btn],
			equip_icon = widgets[equip_icon],
			grade_icon = widgets[grade_icon],
			is_select = widgets[is_select],
			level_label = widgets[level_label],
			red_tips = widgets[red_tips],
		}
	end
end

function wnd_steedEquip:refresh()
	self:updateUI()
	self:updateSteedRed() -- @Override
end

function wnd_steedEquip:updateUI()
	self:setChoseScroll()
	self:updateEquipUI()
	self:updateBagUI()
	self:updateSteedModel()
	self:setBattlePower()
end

--设置分组下拉框
function wnd_steedEquip:setChoseScroll()
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

function wnd_steedEquip:choseSteedStep(step)
	local widgets = self._layout.vars
	if self._chooseStep == step then
		return
	end

	self._chooseStep = step

	widgets.levelRoot2:setVisible(false)
	widgets.gradeLabel2:setText(i3k_db_steed_equip_step[step].name)

	self:updateBagUI()
end

function wnd_steedEquip:choseSteedRank(rank)
	local widgets = self._layout.vars
	if self._chooseRank == rank then
		return
	end

	self._chooseRank = rank

	widgets.levelRoot:setVisible(false)
	widgets.gradeLabel:setText(i3k_db_steed_equip_quality[rank].name)

	self:updateBagUI()
end

function wnd_steedEquip:getChooseStep()
	return self._chooseStep
end

function wnd_steedEquip:getChooseRank()
	return self._chooseRank
end

--设置装备信息
function wnd_steedEquip:updateEquipUI()
	local steedEquips = g_i3k_game_context:GetSteedWearEquipsData()
	for i, v in ipairs(self.steed_equip) do
		if i <= g_STEED_EQUIP_PART_COUNT then
			local equipID = steedEquips[i]
			if equipID then
				v.equip_btn:enable()
				v.equip_icon:show()
				v.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
				v.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
				v.equip_btn:onClick(self, self.onSelectEquip, {partID = i, equipID = equipID})
				v.level_label:hide()
			else
				v.equip_btn:disable()
				v.equip_icon:hide()
				v.grade_icon:setImage(g_i3k_get_steed_equip_icon_frame_path_by_pos(i))
				v.level_label:hide()
			end
		else
			v.equip_icon:setImage()--一张灰化的图
			v.grade_icon:setImage(g_i3k_get_steed_equip_icon_frame_path_by_pos(i))
			v.level_label:hide()
			v.equip_btn:onClick(self, function()
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1537))
			end)
		end
		v.red_tips:hide()
		v.is_select:hide()
	end
	self:updateSuitUI()
end

--设置背包信息
function wnd_steedEquip:updateBagUI()
	local widgets = self._layout.vars
	local step = self:getChooseStep()
	local rank = self:getChooseRank()

	local equipData = {}
	local equips = g_i3k_game_context:GetSteedBagEquipsData()
	for _, v in ipairs(equips) do
		local equipCfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(v.id)
		local cfgStep = equipCfg.stepID
		local cfgrank = equipCfg.rank
		if (cfgStep == step or step == 0) and (cfgrank == rank or rank == 0) then
			table.insert(equipData, v)
		end
	end

	local allBars = widgets.scroll:addChildWithCount("ui/widgets/qizhanzhuangbeit1", RowitemCount, #equipData)
	for i, v in ipairs(allBars) do
		local id = equipData[i].id
		local count = equipData[i].count
		local equipCfg = g_i3k_db.i3k_db_get_steed_equip_item_cfg(id)

		local wEquip = g_i3k_game_context:GetSteedWearEquipsData()
		local equipID = wEquip[equipCfg.partID]

		v.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		v.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		v.vars.item_count:setText(count)
		v.vars.suo:setVisible(id > 0)
		v.vars.bt:onClick(self, self.onSelectEquip, {partID = equipCfg.partID, equipID = id, isBag = true, haveEquipID = equipID})
		v.vars.is_show:setVisible(false)

		if equipID then
			local power = math.modf(g_i3k_game_context:GetOneSteedEquipPower(id))
			local wPower = math.modf(g_i3k_game_context:GetOneSteedEquipPower(equipID))
			v.vars.isUp:show()
			if wPower > power then
				v.vars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(175))
			elseif wPower < power then
				v.vars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
			else
				v.vars.isUp:hide()
			end
		else
			v.vars.isUp:show()
			v.vars.isUp:setImage(g_i3k_db.i3k_db_get_icon_path(174))
		end
	end
	widgets.noItemTips:setText(i3k_get_string(1522))
	widgets.noItemTips:setVisible(table.nums(equipData) == 0)
end

--设置套装信息
function wnd_steedEquip:updateSuitUI()
	local widgets = self._layout.vars
	local wEquip = g_i3k_game_context:GetSteedWearEquipsData()
	local suitData = g_i3k_game_context:GetSteedAllSuitsData()

	widgets.des:setVisible(table.nums(wEquip) ~= 0)
	widgets.activateSuitBtn:setVisible(table.nums(wEquip) ~= 0)

	local isCanClick = false
	local suitID, count = g_i3k_db.i3k_db_get_steed_equip_need_show_suitIdAndCount(wEquip, suitData)
	if suitID and count then
		local totalNum = #i3k_db_steed_equip_suit[suitID].parts
		isCanClick = count >= totalNum

		widgets.des:setText(string.format("[%s] %s/%s", i3k_db_steed_equip_suit[suitID].name, count, totalNum))
		widgets.des:setTextColor(isCanClick and "ff1bff66" or "ffd02020")
		widgets.des:enableOutline(isCanClick and "ff443676" or "ff9fb8ff")
	end

	if isCanClick then
		widgets.activateSuitBtn:SetIsableWithChildren(not suitData[suitID])
		widgets.suitBtnLabel:setText(suitData[suitID] and i3k_get_string(1612) or i3k_get_string(1613))
	else
		widgets.activateSuitBtn:disableWithChildren()
		widgets.suitBtnLabel:setText(i3k_get_string(1613))
	end

	self._wantMakeSuitID = suitID
end

function wnd_steedEquip:updateSteedModel()
	local widgets = self._layout.vars
	local showID = g_i3k_game_context:getSteedCurShowID()
	local cfg = i3k_db_steed_huanhua[showID]
	ui_set_hero_model(widgets.hero_module, cfg.modelId)
	widgets.hero_module:playAction("show")
	if cfg.modelRotation ~= 0 then
		widgets.hero_module:setRotation(cfg.modelRotation)
	end
end

function wnd_steedEquip:onSelectEquip(sender, data)
	if not data.isBag then
		for i, v in ipairs(self.steed_equip) do
			v.is_select:setVisible(i == data.partID)
		end
	end
	--打开装备tips
	local state = g_STEED_EQUIP_TIPS_NONE
	if data.isBag then
		if data.haveEquipID then
			state = g_STEED_EQUIP_TIPS_BAG2
		else
			state = g_STEED_EQUIP_TIPS_BAG
		end
	else
		state = g_STEED_EQUIP_TIPS_EQUIP
	end
	g_i3k_ui_mgr:OpenUI(eUIID_steedEquipPropCmp)
	g_i3k_ui_mgr:RefreshUI(eUIID_steedEquipPropCmp, data.equipID, state)
end

--打开属性详情面板
function wnd_steedEquip:onOpenPropTips(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SteedEquipPropTip)
	g_i3k_ui_mgr:RefreshUI(eUIID_SteedEquipPropTip)
end

--激活套装
function wnd_steedEquip:onOpenSuitUI(sender)
	local suitID = self._wantMakeSuitID
	g_i3k_logic:OpenSteedSuitUI(suitID)
end

--一键装备
function wnd_steedEquip:onAutoWear(sender)
	local bestEquip, replace_count = g_i3k_game_context:GetSteedBestEquipsInfo()
	if replace_count ~= 0 then
		local fun = (function(ok)
			if ok then
				i3k_sbean.dress_steed_equip(bestEquip)
			end
		end)
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1614), fun)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1523))
	end
end

--装备，卸下，更换调用此方法
--InvokeUIFunction
function wnd_steedEquip:changeBattlePower(newBattlePower, oldBattlePower)
	self._target = newBattlePower
	self._base = oldBattlePower

	self._isChange = self._target ~= self._base
	self._poptick = 0
end

--设置骑战装备战力
function wnd_steedEquip:setBattlePower()
	self._isChange = false
	self.addIcon:hide()
	self.powerValue:hide()
	local power = g_i3k_game_context:GetSteedEquipFightPower()
	self.battle_power:setText(power)
end

--战力变化时动画
function wnd_steedEquip:onUpdate(dTime)
	if self._isChange then
		self._poptick = self._poptick + dTime
		if self._poptick < 1 then
			local text = self._base + math.floor((self._target - self._base)*self._poptick)
			self.battle_power:setText(text)
			self.addIcon:show()
			self.powerValue:show()
			if self._target >= self._base then
				self.addIcon:setImage(g_i3k_db.i3k_db_get_icon_path(174))
				self.powerValue:setText("+"..self._target - self._base)
			else
				self.addIcon:setImage(g_i3k_db.i3k_db_get_icon_path(175))
				self.powerValue:setText(self._target - self._base)
			end
			self.powerValue:setTextColor(g_i3k_get_cond_color(self._target >= self._base))
		elseif self._poptick >= 1 and self._poptick < 2 then
			self.battle_power:setText(self._target)
			self.addIcon:hide()
			self.powerValue:hide()
		elseif self._poptick > 2 then
			self.addIcon:hide()
			self.powerValue:hide()
			self._isChange = false
		end
	end
end


function wnd_steedEquip:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1653))
end

function wnd_create(layout)
	local wnd = wnd_steedEquip.new();
		wnd:create(layout);
	return wnd;
end

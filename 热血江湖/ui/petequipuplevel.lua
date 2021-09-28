
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/petEquipProfile")
-------------------------------------------------------
wnd_petEquipUpLevel = i3k_class("wnd_petEquipUpLevel", ui.wnd_petEquipProfile)

--等级图片1~9/0
local LEVELICON = {109, 110, 111, 112, 113, 114, 115, 116, 117, 118}
--开放宠物装备部位数
local PET_EQUIP_PART_OPEN_CONT = #i3k_db_pet_equips_part

function wnd_petEquipUpLevel:ctor()
	self._partID = nil
	self._selectID = nil
	self._noMaxWidgets = nil
	self._upLvl = nil
end

function wnd_petEquipUpLevel:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)

	widgets.choseGroupBtn:onClick(self, function()
		widgets.choseGroupUI:setVisible(not widgets.choseGroupUI:isVisible())
	end)

	widgets.bag_btn:onClick(self, function()
		g_i3k_logic:OpenPetEquipUI(eUIID_PetEquipUpLevel)
	end)

	widgets.upLvl_btn:onClick(self, function()
		--g_i3k_logic:OpenPetEquipUpLevelUI(eUIID_PetEquipUpLevel)
	end)

	widgets.skill_btn:onClick(self, function()
		g_i3k_logic:OpenPetEquipUpSkillLevelUI(eUIID_PetEquipUpLevel)
	end)
	widgets.guard_btn:onClick(self, function()
		g_i3k_logic:OpenPetGuardUI(eUIID_PetEquipUpLevel)
	end)
	widgets.upLvl_btn:stateToPressed(true)

	widgets.help_btn:onClick(self, function()
		 g_i3k_ui_mgr:ShowHelp(i3k_get_string(1519))
	end)
	widgets.guard_btn:setVisible(g_i3k_game_context:GetLevel() >= i3k_db_pet_guard_base_cfg.showLvl)

	self:initPetEquipWidget(widgets)

	self.equipPoint = widgets.equipPoint
	self.upLvlPoint = widgets.upLvlPoint
	self.skillPoint = widgets.skillPoint
	self.guardPoint = widgets.guardPoint
	self.petScroll = widgets.petScroll
	self.pet_power = widgets.pet_power
	self.addIcon = widgets.addIcon
	self.powerValue = widgets.powerValue
	self.hero_module = widgets.hero_module
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
end

--初始化宠物装备控件
function wnd_petEquipUpLevel:initPetEquipWidget(widgets)
	for i = 1, g_PET_EQUIP_PART_COUNT do
		local equip_btn = "equip" .. i
		local equip_icon = "equip_icon" .. i
		local grade_icon = "grade_icon" .. i
		local is_select = "is_select" .. i
		local level_label = "qh_level" .. i
		local red_tips = "tips" .. i

		self.pet_equip[i] = {
			equip_btn = widgets[equip_btn],
			equip_icon = widgets[equip_icon],
			grade_icon = widgets[grade_icon],
			is_select = widgets[is_select],
			level_label = widgets[level_label],
			red_tips = widgets[red_tips],
		}
	end
end

function wnd_petEquipUpLevel:refresh()
	self:setChoseGroupScroll()
	self:updateEquipUI()
	self:refreshUpLvlUI()
	self:updatePetScroll(false)
	self:updateTabRedPoint()
end

--设置分组下拉框
function wnd_petEquipUpLevel:setChoseGroupScroll()
	local widgets = self._layout.vars
	widgets.choseGroupScroll:removeAllChildren()

	for i = 1, #i3k_db_pet_equips_group do
		local item = require("ui/widgets/xunyangbgt1")()
		item.vars.groupName:setText(i3k_db_pet_equips_group[i])
		item.vars.groupBtn:onClick(self, function()
			self:chosePetGroup(i)
		end)
		widgets.choseGroupScroll:addItem(item)
		self:setGroupRedPoint(i)
	end
end

function wnd_petEquipUpLevel:setGroupRedPoint(group)
	local widgets = self._layout.vars
	local allChildren = widgets.choseGroupScroll:getAllChildren()
	local ui = allChildren[group]
	if ui then
		ui.vars.red:setVisible(g_i3k_game_context:UpdatePetEquipGroupPoint(group))
	end
end

function wnd_petEquipUpLevel:chosePetGroup(group)
	local widgets = self._layout.vars
	if self._choosePetGroup == group then
		return
	end

	if not g_i3k_db.i3k_db_get_is_have_one_pet_in_group(group) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1547))
	end

	local equip = g_i3k_game_context:GetPetEquipsData(group)
	if not next(equip) then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1548, i3k_db_pet_equips_group[group]))
	end

	self._choosePetGroup = group
	g_i3k_game_context:SetPetEquipGroup(group)

	widgets.choseGroupUI:setVisible(false)
	widgets.groupLabel:setText(i3k_db_pet_equips_group[group])

	self:updateEquipUI()
	self:refreshUpLvlUI()
	self:updatePetScroll(false)
	self:updateTabRedPoint()
end

--刷新左侧装备UI
function wnd_petEquipUpLevel:updateEquipUI()
	local widgets = self._layout.vars
	local group = self:getChooseGroup()
	widgets.groupLabel:setText(i3k_db_pet_equips_group[group])

	self:updateProfile(group)
	self:updateWearEquipsData(group)
end

function wnd_petEquipUpLevel:updateWearEquipsData(group)
	local wEquip = g_i3k_game_context:GetPetEquipsData(group)
	local upLvls = g_i3k_game_context:GetPetEquipsLvlData(group)

	for i, v in ipairs(self.pet_equip) do
		if i <= PET_EQUIP_PART_OPEN_CONT then
			local equipID = wEquip[i]
			local upLvl = upLvls[i] or 0
			if equipID then
				v.equip_btn:onClick(self, self.onSelectEquip, i)
				if upLvl then
					v.level_label:setVisible(upLvl ~= 0)
					v.level_label:setText("+" .. upLvl)
				end
				v.red_tips:setVisible(g_i3k_game_context:UpdatePetEquipPartPoint(group, i))
			end
		end
	end
end

--刷新升级界面
function wnd_petEquipUpLevel:refreshUpLvlUI()
	self:defaultSelectEquip()
end

--默认选中装备
function wnd_petEquipUpLevel:defaultSelectEquip()
	self._partID = nil
	self._selectID = nil
	local group = self:getChooseGroup()
	local wEquip = g_i3k_game_context:GetPetEquipsData(group)
	for i = 1, #self.pet_equip do
		local equipID = wEquip[i]
		if equipID then
			self.pet_equip[i].is_select:show()
			self._partID = i
			self._selectID = i
			self:setEquipInfoUI(i)
			break
		end
	end
end

--选中装备
function wnd_petEquipUpLevel:onSelectEquip(sender, partID)
	if self._selectID == partID then
		return
	end
	for i=1, #self.pet_equip do
		self.pet_equip[i].is_select:setVisible(i == partID)
	end

	self._selectID = partID
	self._partID = partID
	self:setEquipInfoUI(partID)
end

function wnd_petEquipUpLevel:setEquipInfoUI(partID)
	local group = self:getChooseGroup()

	local wEquip = g_i3k_game_context:GetPetEquipsData(group)
	local equipID = wEquip[partID]

	local upLvls = g_i3k_game_context:GetPetEquipsLvlData(group)
	local upLvl = upLvls[partID] or 0

	local upGroupID = i3k_db_pet_equips_part[partID].group
	local maxUpLvl = g_i3k_db.i3k_db_get_pet_equip_up_max_lvl(upGroupID)

	--满级
	if upLvl >= maxUpLvl then
		local widgets = require("ui/widgets/xunyangzbsjm")()
		self:addNewNode(widgets)
		self:setEquipMaxDetail(equipID, partID, maxUpLvl, widgets.vars)
	else
		local widgets = require("ui/widgets/xunyangzbsj")()

		self._noMaxWidgets = widgets.vars
		self._upLvl = upLvl

		self:addNewNode(widgets)
		self:setEquipDetail(equipID, partID, upLvl, widgets.vars)
	end
end

--满级UI
function wnd_petEquipUpLevel:setEquipMaxDetail(equipID, partID, maxLvl, widgets)
	local upGroupID = i3k_db_pet_equips_part[partID].group
	local upLvlCfg = g_i3k_db.i3k_db_get_pet_equip_up_lvl_cfg(upGroupID, maxLvl)

	widgets.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
	widgets.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
	widgets.equip_name:setText(g_i3k_db.i3k_db_get_common_item_name(equipID))
	widgets.equip_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(equipID)))
	widgets.qh_level:setText("+" .. maxLvl)

	self:setNextLvlIcon(maxLvl, widgets)

	local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(equipID)

	local maxProps = {}
	for _, v in ipairs(upLvlCfg.props) do
		maxProps[v.propID] = (maxProps[v.propID] or 0) + v.propValue
	end

	widgets.scroll:stateToNoSlip()
	widgets.scroll:removeAllChildren()
	for _, v in ipairs(equipCfg.baseProp) do
		if v.propID ~= 0 then
			local ui = require("ui/widgets/xunyangzbsjmt")()
			local _temp = i3k_db_prop_id[v.propID]
			ui.vars.label:setText(_temp.desc..":")
			ui.vars.value:setText(v.propValue + (maxProps[v.propID] or 0))
			widgets.scroll:addItem(ui)
		end
	end
end

--升级UI
function wnd_petEquipUpLevel:setEquipDetail(equipID, partID, level, widgets)
	self:setEquipIcon(equipID, widgets)
	self:setNowLvlIcon(level, widgets)
	self:setNextLvlIcon(level + 1, widgets)

	self:setUpLvlLimitTips(partID, level, widgets)
	self:setEquipPropsScroll(equipID, partID, level, widgets)
	self:setEquipFightPower(equipID, partID, level, widgets)

	self:setNeedItem()
end

--升级显示文本
function wnd_petEquipUpLevel:setUpLvlLimitTips(partID, level, widgets)
	local group = self:getChooseGroup()
	local upGroupID = i3k_db_pet_equips_part[partID].group
	local nextUpLvlCfg = g_i3k_db.i3k_db_get_pet_equip_up_lvl_cfg(upGroupID, level + 1)

	local groupName = i3k_db_pet_equips_group[group]
	local skillCnt = nextUpLvlCfg.skillCnt
	local skillLvl = nextUpLvlCfg.skillLvl

	widgets.des:setVisible(skillCnt ~= 0 and skillLvl ~= 0)
	local isHaveLimit, haveSkillCnt = g_i3k_db.i3k_db_get_pet_equip_is_have_limit_and_skillCnt(group, partID, level + 1)
	widgets.des:setText(i3k_get_string(1549, groupName, nextUpLvlCfg.skillCnt, nextUpLvlCfg.skillLvl, haveSkillCnt, nextUpLvlCfg.skillCnt))
	widgets.des:setTextColor(g_i3k_get_cond_color(not isHaveLimit))
end

--设置装备属性
function wnd_petEquipUpLevel:setEquipPropsScroll(equipID, partID, level, widgets)
	local upGroupID = i3k_db_pet_equips_part[partID].group
	local curUpLvlCfg = g_i3k_db.i3k_db_get_pet_equip_up_lvl_cfg(upGroupID, level)
	local nextUpLvlCfg = g_i3k_db.i3k_db_get_pet_equip_up_lvl_cfg(upGroupID, level + 1)

	widgets.scroll1:removeAllChildren()
	widgets.scroll2:removeAllChildren()

	local equipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(equipID)

	local curProps = {}
	for _, v in ipairs(curUpLvlCfg.props) do
		curProps[v.propID] = (curProps[v.propID] or 0) + v.propValue
	end

	local nextProps = {}
	for _, v in ipairs(nextUpLvlCfg.props) do
		nextProps[v.propID] = (nextProps[v.propID] or 0) + v.propValue
	end

	widgets.scroll1:stateToNoSlip()
	for _, v in ipairs(equipCfg.baseProp) do
		if v.propID ~= 0 then
			local ui = require("ui/widgets/xunyangzbsjt1")()
			local _temp = i3k_db_prop_id[v.propID]
			ui.vars.label:setText(_temp.desc..":")
			ui.vars.value:setText(v.propValue + (curProps[v.propID] or 0))
			widgets.scroll1:addItem(ui)
		end
	end

	widgets.scroll2:stateToNoSlip()
	for _, v in ipairs(equipCfg.baseProp) do
		if v.propID ~= 0 then
			local ui = require("ui/widgets/xunyangzbsjt1")()
			local _temp = i3k_db_prop_id[v.propID]
			ui.vars.label:setText(_temp.desc..":")
			ui.vars.value:setText(v.propValue + (nextProps[v.propID] or 0))
			widgets.scroll2:addItem(ui)
		end
	end
end

--设置装备战力
function wnd_petEquipUpLevel:setEquipFightPower(equipID, partID, level, widgets)
	local group = self:getChooseGroup()
	local now_power = g_i3k_game_context:GetOnePetEquipTotalFightPower(group, equipID, partID, level)
	local next_power = g_i3k_game_context:GetOnePetEquipTotalFightPower(group, equipID, partID, level + 1)
	widgets.qh_equip_score1:setText(i3k_get_string(1550, math.modf(now_power)))
	widgets.qh_equip_score2:setText(i3k_get_string(1550, math.modf(next_power)))
end

--设置装备icon
function wnd_petEquipUpLevel:setEquipIcon(equipID, widgets)
	local euqipCfg = g_i3k_db.i3k_db_get_pet_equip_item_cfg(equipID)

	widgets.equip_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
	widgets.equip_bg2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equipID))
	widgets.qh_equip_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
	widgets.qh_equip_icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equipID, g_i3k_game_context:IsFemaleRole()))
	widgets.qh_equip_name1:setText(g_i3k_db.i3k_db_get_common_item_name(equipID))
	widgets.qh_equip_name2:setText(g_i3k_db.i3k_db_get_common_item_name(equipID))
	widgets.qh_equip_name1:setTextColor(g_i3k_get_color_by_rank(euqipCfg.rank))
	widgets.qh_equip_name2:setTextColor(g_i3k_get_color_by_rank(euqipCfg.rank))
end

function wnd_petEquipUpLevel:setNowLvlIcon(level, widgets)
	widgets.lv_icon1:setVisible(true)
	widgets.lv_icon2:setVisible(level >= 10)
	widgets.lv_icon5:setVisible(level >= 100)
	if level < 10 then
		widgets.lv_icon1:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[level == 0 and 10 or level]))
	elseif level <100 then
		local tag = level%10 == 0 and 10 or level%10
		widgets.lv_icon1:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[math.modf(level/10)]))
		widgets.lv_icon2:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
	else
		widgets.lv_icon5:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[math.modf(level/100)]))
		local tag = math.modf(level/10)%10 == 0 and 10 or math.modf(level/10)%10
		widgets.lv_icon1:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
		tag = level%10 == 0 and 10 or level%10
		widgets.lv_icon2:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
	end
end

function wnd_petEquipUpLevel:setNextLvlIcon(level, widgets)
	widgets.lv_icon3:setVisible(true)
	widgets.lv_icon4:setVisible(level >= 10)
	widgets.lv_icon6:setVisible(level >= 100)
	if level < 10 then
		widgets.lv_icon3:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[level]))
	elseif level <100 then
		local tag = level%10 == 0 and 10 or level%10
		widgets.lv_icon3:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[math.modf(level/10)]))
		widgets.lv_icon4:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
	else
		widgets.lv_icon6:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[math.modf(level/100)]))
		local tag = math.modf(level/10)%10 == 0 and 10 or math.modf(level/10)%10
		widgets.lv_icon3:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
		tag = level%10 == 0 and 10 or level%10
		widgets.lv_icon4:setImage(g_i3k_db.i3k_db_get_icon_path(LEVELICON[tag]))
	end
end

--设置升级所需消耗
function wnd_petEquipUpLevel:setNeedItem()
	local partID = self._partID
	local nextLvl = self._upLvl + 1
	local widgets = self._noMaxWidgets

	local upGroupID = i3k_db_pet_equips_part[partID].group
	local nextUpLvlCfg = g_i3k_db.i3k_db_get_pet_equip_up_lvl_cfg(upGroupID, nextLvl)
	local costItem = nextUpLvlCfg.costItem

	widgets.item_scroll:removeAllChildren()
	for i, e in ipairs(costItem) do
		local _layer = require("ui/widgets/xunyangzbsjt2")()
		local ui = _layer.vars
		local name_colour = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(e.id))
		ui.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(e.id))
		ui.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.id, g_i3k_game_context:IsFemaleRole()))
		ui.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(e.id))
		ui.item_name:setTextColor(name_colour)
		ui.icon_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.id))
		if math.abs(e.id) == g_BASE_ITEM_DIAMOND or math.abs(e.id) == g_BASE_ITEM_COIN then
			ui.item_count:setText(e.count)
		else
			ui.item_count:setText(g_i3k_game_context:GetCommonItemCanUseCount(e.id) .."/".. e.count)
		end
		ui.item_count:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(e.id) >= e.count))
		ui.bt:onClick(self, self.onItemTips, e.id)
		widgets.item_scroll:addItem(_layer)
	end
	widgets.upLvlBtn:onClick(self, self.onUpLvl, {partID = partID, nextLvl = nextLvl, costItem = costItem})
end

--升级
function wnd_petEquipUpLevel:onUpLvl(sender, data)
	local group = self:getChooseGroup()
	local costItem = data.costItem
	for _, v in ipairs(costItem) do
		if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1543))
		end
	end
	local isHaveLimit = g_i3k_db.i3k_db_get_pet_equip_is_have_limit_and_skillCnt(group, data.partID, data.nextLvl)
	if isHaveLimit then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1551))
	end
	i3k_sbean.pet_domestication_part_lvlup(group, data.partID, data.nextLvl, data.costItem)
end

--右侧面板动态添加节点
function wnd_petEquipUpLevel:addNewNode(layer)
	local widgets = self._layout.vars
	local nodeWidth = widgets.newRoot:getContentSize().width
	local nodeHeight = widgets.newRoot:getContentSize().height
	local old_layer = widgets.newRoot:getAddChild()
	if old_layer[1] then
		widgets.newRoot:removeChild(old_layer[1])
	end
	if layer then
		widgets.newRoot:addChild(layer)
		layer.rootVar:setContentSize(nodeWidth, nodeHeight)
	end
end

function wnd_petEquipUpLevel:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout, ...)
	local wnd = wnd_petEquipUpLevel.new()
	wnd:create(layout, ...)
	return wnd;
end


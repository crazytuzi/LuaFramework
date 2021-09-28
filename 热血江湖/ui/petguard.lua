------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/petEquipProfile')
------------------------------------------------------
wnd_pet_guard = i3k_class("wnd_pet_guard",ui.wnd_petEquipProfile)

local SELECT_BG = 706
local NORMAL_BG = 707

local ACTIVE_ICON = i3k_db_pet_guard_base_cfg.unlockedIconId
local LOCKED_ICON = i3k_db_pet_guard_base_cfg.lockedIconId

local SCROLL_WIDGET = "ui/widgets/shouhulingshout"
local SCROLL_RPOP = "ui/widgets/anqishengjit"
local SHENGJI = "ui/widgets/shouhulingshoushengji"
local JIHUO = "ui/widgets/shouhulingshoujh"
local ITEM_WIDGET = "ui/widgets/shouhulingshoushengjit"

local USE_ITEM_TIME_INTERVAL = 0.2 --长按道具使用间隔

local CLICK_ACTION = "shengji" --点击动画
local EXP_ACTION = "attackstand" --经验动画
local ACTIVE_ACTION = "attackstand" --激活动画
local DEFAULT_ACTION = "stand" --默认动画
function wnd_pet_guard:ctor()
	self.allTab = {}
	self.curSelectId = g_i3k_game_context:GetCurPetGuard()
	self.curRightNode = nil -- 当前右边部分节点
	self.allItems = {} --升级用的道具控件
	self._curItemId = nil --当前选中的
	self._isPress = false
	self._pressTime = 0
	self._isWaiting = false --等待协议返回
end

function wnd_pet_guard:configure()
	ui.wnd_petEquipProfile:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.guard_btn:stateToPressed()
	widgets.bag_btn:onClick(self, function()
		g_i3k_logic:OpenPetEquipUI(eUIID_PetGuard)
	end)
	widgets.upLvl_btn:onClick(self, function()
		g_i3k_logic:OpenPetEquipUpLevelUI(eUIID_PetGuard)
	end)
	widgets.skill_btn:onClick(self, function()
		g_i3k_logic:OpenPetEquipUpSkillLevelUI(eUIID_PetGuard)
	end)
	widgets.help_btn:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(17958))
		end)
	widgets.isHide:onClick(self, self.onIsHideClick)
	widgets.qiannengBtn:onClick(self, self.onPotentialClick)
	widgets.battleBtn:onClick(self, self.onBattleBtnClick)
	self.equipPoint = widgets.equipPoint
	self.upLvlPoint = widgets.upLvlPoint
	self.skillPoint = widgets.skillPoint
	self.guardPoint = widgets.guardPoint
	self.recycle_btn = widgets.recycle_btn
	self.scroll1 = widgets.scroll1
end

function wnd_pet_guard:refresh(selectId)
	self:updateScrollInfo()
	self.curSelectId = selectId or self.curSelectId
	self:onTabClick(nil, self.curSelectId)
end

function wnd_pet_guard:updateScrollInfo()
	local active = g_i3k_game_context:GetActivePetGuards()
	local battling = g_i3k_game_context:GetCurPetGuard()
	local petGuardInfo = i3k_clone(i3k_db_pet_guard)
	self.scroll1:removeAllChildren()
	for k, v in ipairs(petGuardInfo) do
		v.isUnlock = active[k] ~= nil
		v.id = k
		--未解锁守护灵兽为0级
		v.lvl = active[k] and active[k].lvl or 0
	end
	--依据等级降序，同等级依据ID升序
	local sortPetGuardInfo = function (a, b)
		return a.lvl == b.lvl and a.id < b.id or a.lvl > b.lvl
	end
	table.sort(petGuardInfo, sortPetGuardInfo)
	--未装备守护之灵时默认选中第一个
	if self.curSelectId == 0 and #petGuardInfo > 0 then
		self.curSelectId = petGuardInfo[1].id
	end
	for k, v in ipairs(petGuardInfo) do
		local ui = require(SCROLL_WIDGET)()
		local vars = ui.vars
		local isAllUnlock = g_i3k_db.i3k_db_get_is_pet_guard_potential_all_unlock(v.id)
		vars.name:setText(v.name)
		vars.btn:onClick(self, self.onTabClick, v.id)

		vars.selectBg:setImage(g_i3k_db.i3k_db_get_icon_path(v.id == self.curSelectId and SELECT_BG or NORMAL_BG))
		vars.lock:setVisible(not v.isUnlock)
		vars.lvl_icon:setVisible(v.isUnlock)
		vars.lvl_txt:setText(v.isUnlock and string.format("等级:%s级",v.lvl) or "")
		vars.isBattling:setVisible(battling == v.id)
		vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(isAllUnlock and v.adventuralIcon or v.icon))
		vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(isAllUnlock and i3k_db_pet_guard_base_cfg.specialIconBg or i3k_db_pet_guard_base_cfg.normalIconBg))
		self.allTab[v.id] = vars
		self.scroll1:addItem(ui)
	end
end

function wnd_pet_guard:updateRedPoint()
	for k, v in pairs(self.allTab) do
		v.red_point:setVisible(g_i3k_db.i3k_db_pet_guard_red(k))
	end
	self:updateTabRedPoint()
	local widgets = self._layout.vars
	widgets.potentialRed:setVisible(g_i3k_db.i3k_db_pet_guard_potential_red(self.curSelectId))
end
function wnd_pet_guard:updateRecycleBtn()
	local isShowRecycleBtn = g_i3k_db.i3k_db_get_is_pet_guard_potential_all_unlock(self.curSelectId)
	self.recycle_btn:setVisible(isShowRecycleBtn)
end

function wnd_pet_guard:setRightInfo()
	local active = g_i3k_game_context:IsPetGuardActive(self.curSelectId)
	self.allItems = {}--清空道具控件 防止更新道具数量的时候控件已经失效
	if active then
		self.curRightNode = require(SHENGJI)()
		self:addNewNode(self.curRightNode)
		self:setShengJiNode()
	else
		self.curRightNode = require(JIHUO)()
		self:addNewNode(self.curRightNode)
		self:setUnlockNode()
	end
end

function wnd_pet_guard:setShengJiNode()
	local widgets = self.curRightNode.vars
	local lvl = g_i3k_game_context:GetPetGuardLevel(self.curSelectId)
	local exp = g_i3k_game_context:GetPetGuardExp(self.curSelectId)
	local cfg = i3k_db_pet_guard_level[self.curSelectId][lvl]
	local nextCfg = i3k_db_pet_guard_level[self.curSelectId][lvl + 1]
	local nextProps = nextCfg and nextCfg.props
	widgets.value:setText(lvl)
	widgets.tips:setText(i3k_get_string(18069))
	if not nextCfg then
		widgets.needLevel:show()
		widgets.needLevel:setText(i3k_get_string(17947))
	else
		local petMaxLvl = g_i3k_game_context:GetPetsMaxLevel()
		if petMaxLvl < nextCfg.maxLvl then
			widgets.needLevel:show()
			widgets.needLevel:setText(i3k_get_string(17949, nextCfg.maxLvl))
		else
			widgets.needLevel:hide()
		end
	end
	if nextCfg then
		widgets.exp_slider:setPercent(exp / nextCfg.needExp * 100)
		widgets.exp_value:setText(string.format("%s/%s", exp, nextCfg.needExp))
	else
		widgets.exp_slider:setPercent(100)
		widgets.exp_value:setText(string.format("%s/%s", cfg.needExp, cfg.needExp))
	end
	widgets.scroll:removeAllChildren()
	for i,v in ipairs(cfg.props) do
		local prop = require(SCROLL_RPOP)()
		local vars = prop.vars
		vars.propertyName:setText(g_i3k_db.i3k_db_get_property_name(v.id))
		vars.propertyIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(v.id)))
		vars.valueMid:setText(i3k_get_prop_show(i, v.value))
		if nextCfg then
			vars.propertyValue:setText(i3k_get_prop_show(id, nextProps[i].value))
		else
			vars.propertyValue:hide()
		end
		widgets.scroll:addItem(prop)
	end
	if #widgets.item_scroll:getAllChildren() == 0 then--初始化的时候刷新btn 
		widgets.oneKeyUseBtn:onClick(self, self.onOneKeyUseBtnClick)
		widgets.item_scroll:removeAllChildren()
		local items = g_i3k_db.i3k_db_get_pet_guard_use_items()
		for i, v in ipairs(items) do
			local item = require(ITEM_WIDGET)()
			local vars = item.vars
			vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, g_i3k_game_context:IsFemaleRole()))
			vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			vars.value:setText(v.args1)
			vars.btn:onTouchEvent(self, self.onItemTouch, v.id)
			self.allItems[v.id] = {vars = vars}
			widgets.item_scroll:addItem(item)
		end
		self:updateItemsCount()
	end
end

function wnd_pet_guard:setUnlockNode()
	local widgets = self.curRightNode.vars
	local cfg = i3k_db_pet_guard[self.curSelectId]
	local itemId = cfg.needItemId
	widgets.desc:setText(cfg.des)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(cfg.needItemId, g_i3k_game_context:IsFemaleRole()))
	widgets.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(cfg.needItemId))
	widgets.btn:onClick(self, function() g_i3k_ui_mgr:ShowCommonItemInfo(itemId) end)
	widgets.name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
	widgets.activeBtn:onClick(self, self.onActiveBtnClick)
	self.allItems[itemId] = {needCount = cfg.needItemCount, vars = widgets}
	self:updateItemsCount()
end

function wnd_pet_guard:setMainInfo()
	local id = self.curSelectId
	local cfg = i3k_db_pet_guard[id]
	local widgets = self._layout.vars
	self:setModule(id)
	self:setSkill(id)
	local isBattling = id == g_i3k_game_context:GetCurPetGuard()
	local isActive = g_i3k_game_context:IsPetGuardActive(id)
	self:updateRecycleBtn()
	widgets.recycle_btn:onClick(self, self.onRecycleBtnClick, id)
	widgets.battleBtn:SetIsableWithChildren(not isBattling and isActive)
	widgets.battle_lable:setText(i3k_get_string(not isActive and 17950 or (isBattling and 17951 or 17952)))
	widgets.battle_bg:setVisible(g_i3k_game_context:IsPetGuardActive(self.curSelectId))
	self:updateBattlePower()
end

function wnd_pet_guard:updateBattlePower()
	local props = g_i3k_db.i3k_db_get_pet_guard_props(self.curSelectId)
	local power = g_i3k_db.i3k_db_get_battle_power(props)
	self._layout.vars.battle_power:setText(power)
end

function wnd_pet_guard:setModule(id)
	local widgets = self._layout.vars
	local modelID = i3k_db_pet_guard[id].modleId
	local path = i3k_db_models[modelID].path
	local uiscale = i3k_db_models[modelID].uiscale
	local isActive = g_i3k_game_context:IsPetGuardActive(id)
	widgets.module:setSprite(path)
	widgets.module:setSprSize(uiscale)
	widgets.modelBtn:onClick(self, self.onModelClick)
	self:PlayModleAction(DEFAULT_ACTION)
end

function wnd_pet_guard:setSkill(id)
	local cfg = i3k_db_pet_guard[id]
	local widgets = self._layout.vars
	for i=1,4,1 do
		local skillId = cfg['skillId'..i]
		local skillCfg = i3k_db_pet_guard_skills[skillId][1]
		widgets['skillBtn'..i]:onClick(self, self.onSkillBtnClick, skillId)
		widgets['skillIcon'..i]:setImage(g_i3k_db.i3k_db_get_icon_path(skillCfg.iconId))
	end
end

function wnd_pet_guard:updateItemsCount()
	for k, v in pairs(self.allItems) do
		if v.needCount then
			local have = g_i3k_game_context:GetCommonItemCanUseCount(k)
			v.vars.count:setTextColor(g_i3k_get_cond_color(have >= v.needCount))
			if k == g_BASE_ITEM_DIAMOND or k == g_BASE_ITEM_COIN then
				v.vars.count:setText(v.needCount)
			else
				v.vars.count:setText(have .."/".. v.needCount)
			end
		else
			v.vars.count:setText(g_i3k_game_context:GetCommonItemCanUseCount(k))
		end
	end
end

--右侧面板动态添加节点
function wnd_pet_guard:addNewNode(layer)
	local widgets = self._layout.vars
	local nodeWidth = widgets.new_root:getContentSize().width
	local nodeHeight = widgets.new_root:getContentSize().height
	local old_layer = widgets.new_root:getAddChild()
	if old_layer[1] then
		widgets.new_root:removeChild(old_layer[1])
	end
	if layer then
		widgets.new_root:addChild(layer)
		layer.rootVar:setContentSize(nodeWidth, nodeHeight)
	end
end

function wnd_pet_guard:onUpdate(dTime)
	if not self._isWaiting then
		if self._isPress and self._curItemId then
			self._pressTime = self._pressTime + dTime
			if self._pressTime > USE_ITEM_TIME_INTERVAL and g_i3k_game_context:GetCommonItemCanUseCount(self._curItemId) > 0 then
				self._pressTime = 0
				if g_i3k_db.i3k_db_get_pet_guard_can_use_item(self.curSelectId, self._curItemId) then
					self:setIsWaitingProtocol(true)
					i3k_sbean.pet_guard_lvl_up(self.curSelectId, {[self._curItemId] = 1})
				else
					self._isPress = false
					self._curItemId = nil
				end
			end
		else
			self._pressTime = 0
		end
	end
end

function wnd_pet_guard:setIsWaitingProtocol(state)
	self._isWaiting = state
end

function wnd_pet_guard:PopupTipMessage(msg)
	local ui = g_i3k_ui_mgr:GetUI(eUIID_PetGuard)
	g_i3k_ui_mgr:AddTask(ui, {}, function()
			g_i3k_ui_mgr:PopupTipMessage(msg)
		end,1)
end

function wnd_pet_guard:onActiveBtnClick(sender)
	local id = self.curSelectId
	local cfg = i3k_db_pet_guard[id]
	local have = g_i3k_game_context:GetCommonItemCanUseCount(cfg.needItemId)
	if have >= cfg.needItemCount then
		i3k_sbean.pet_guard_active(id)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1092))
	end
end

function wnd_pet_guard:onItemTouch(sender, eventType, id)
	if g_i3k_game_context:GetCommonItemCanUseCount(id) == 0 then
		if eventType == ccui.TouchEventType.ended then
			g_i3k_ui_mgr:ShowCommonItemInfo(id)
		end
		return
	end
	if eventType == ccui.TouchEventType.began then
		self._curItemId = id
		self._isPress = true
		self._pressTime = USE_ITEM_TIME_INTERVAL
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self._isPress = false
		self._curItemId = nil
	end
end

function wnd_pet_guard:onModelClick(sender)
	self:PlayModleAction(CLICK_ACTION)
end

function wnd_pet_guard:onGetExp()
	self:PlayModleAction(EXP_ACTION)
end

function wnd_pet_guard:onActive()
	self:PlayModleAction(ACTIVE_ACTION)
	end
function wnd_pet_guard:PlayModleAction(actionName)
	local widgets = self._layout.vars
	widgets.module:pushActionList(actionName, 1)
	widgets.module:pushActionList(DEFAULT_ACTION, -1)
	widgets.module:playActionList()
end

function wnd_pet_guard:onIsHideClick(sender)
	i3k_sbean.pet_guard_show(not g_i3k_game_context:GetPetGuardIsShow())
end

function wnd_pet_guard:UpdateIsShow()
	self._layout.vars.hideFlag:setVisible(not g_i3k_game_context:GetPetGuardIsShow())
end

function wnd_pet_guard:onTabClick(sender, id)
	self.curSelectId = id
	self:refreshAllInfo()
	self._layout.vars.potentialRed:setVisible(g_i3k_db.i3k_db_pet_guard_potential_red(id))
end

function wnd_pet_guard:refreshAllInfo()
	self:updateScrollInfo()
	self:setRightInfo()
	self:setMainInfo()
	self:updateRedPoint()
	self:UpdateIsShow()
end

function wnd_pet_guard:onSkillBtnClick(sender, skillId)
	g_i3k_ui_mgr:OpenUI(eUIID_PetGuardSkillInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetGuardSkillInfo, skillId)
end

function wnd_pet_guard:onBattleBtnClick(sender)
	i3k_sbean.pet_guard_change(self.curSelectId)
end

function wnd_pet_guard:onOneKeyUseBtnClick(sender)
	if g_i3k_db.i3k_db_get_pet_guard_can_one_key_use_item(self.curSelectId) then
		local items = g_i3k_db.i3k_db_get_pet_guard_one_key_use_items(self.curSelectId)
		i3k_sbean.pet_guard_lvl_up(self.curSelectId, items)
	end
end

function wnd_pet_guard:onPotentialClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_PetGuardPotential)
	g_i3k_ui_mgr:RefreshUI(eUIID_PetGuardPotential, self.curSelectId)
end
function wnd_pet_guard:onRecycleBtnClick(sender, id)
	local itemId = i3k_db_pet_guard[id].needItemId
	i3k_sbean.openDebrisRecycle(itemId, g_DEBRIS_PET_GUARD)
end
-------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_pet_guard.new()
	wnd:create(layout,...)
	return wnd
end

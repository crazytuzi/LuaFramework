------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_pet_guard_potential = i3k_class("wnd_pet_guard_potential",ui.wnd_base)

local PROP_WIDGET = "ui/widgets/shouhulingshouqnt1"

local COLOR_MAP = {
	LINE_BLUE = 8532		,--	蓝直线
	LINE_ORANGE = 8533		,--	橙直线

	CURVE_ORANGE_1 = 8534	,--	橙弧1
	CURVE_ORANGE_2 = 8535	,--	橙弧2
	CURVE_ORANGE_3 = 8536	,--	橙弧3
	CURVE_ORANGE_4 = 8537	,--	橙弧4

	CURVE_BLUE_1 = 8538		,-- 蓝弧1
	CURVE_BLUE_2 = 8539		,-- 蓝弧2
	CURVE_BLUE_3 = 8540		,-- 蓝弧3
	CURVE_BLUE_4 = 8541		,-- 蓝弧4
}

function wnd_pet_guard_potential:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.unlockBtn:onClick(self, self.onUnLockBtnClick)
	widgets.tips:setText(i3k_get_string(18070))
end

function wnd_pet_guard_potential:getIconId(potentialCfg, isUnlock, isCanUnlock)
	if isUnlock then
		return potentialCfg.unlocked
	elseif isCanUnlock then
		return potentialCfg.canUnlock
	else
		return potentialCfg.locked
	end
end

function wnd_pet_guard_potential:refresh(petGuardId, selectPotentialId)
	self.petGuardId = petGuardId or self.petGuardId
	self.selectPotentialId = selectPotentialId or self.selectPotentialId
	local widgets = self._layout.vars
	local cfg = i3k_db_pet_guard_potential[self.petGuardId]
	local active = g_i3k_game_context:GetActivePetGuards()[self.petGuardId]
	local defaultIndex = 999
	for k, v in pairs(cfg) do
		local index = g_i3k_db.i3k_db_get_pet_guard_potential_ui_map(v.x, v.y)
		local isUnlock = g_i3k_db.i3k_db_get_pet_guard_potential_is_unlock(self.petGuardId, k)
		local isCanUnlock = g_i3k_db.i3k_db_get_pet_guard_potential_can_unlock(self.petGuardId, k)
		widgets['suo'..index]:setVisible(not isUnlock)
		widgets['btn'..index]:onClick(self, self.onPotentialClick, index)
		widgets['btn'..index]:setTag(k)
		widgets['dian'..index]:setImage(g_i3k_db.i3k_db_get_icon_path(self:getIconId(v, isUnlock, isCanUnlock)))
		widgets['dian'..index]:setTag(isUnlock and 1 or 0)
		if isCanUnlock and not isUnlock and defaultIndex > index then
			self.selectPotentialId = k
			defaultIndex = index
		end
	end
	defaultIndex = defaultIndex == 999 and 1 or defaultIndex
	local isAllUnlock = g_i3k_db.i3k_db_get_is_pet_guard_potential_all_unlock(self.petGuardId)
	local petGuardCfg = i3k_db_pet_guard[self.petGuardId]
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(isAllUnlock and petGuardCfg.adventuralIcon or petGuardCfg.icon))
	widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(isAllUnlock and i3k_db_pet_guard_base_cfg.specialIconBg or i3k_db_pet_guard_base_cfg.normalIconBg))
	self:onPotentialClick(widgets['btn'..defaultIndex], defaultIndex)--默认点中第一个
	self:setLines()
end

function wnd_pet_guard_potential:setLines()
	local widgets = self._layout.vars
	for i = 1, 4 do
		local curve = widgets['curve'..i]
		local isUnlockAll = true
		local isFirstUnlock = false
		for i2 = 1, 5 do
			local index = g_i3k_db.i3k_db_get_pet_guard_potential_ui_map(i, i2)
			local point = widgets['dian'..index]
			local isUnlock = point:getTag() == 1
			if i2 == 1 then
				isFirstUnlock = isUnlock
			end
			if not isUnlock then
				isUnlockAll = false
				break
			end
		end
		curve:show()
		if isUnlockAll then
			curve:setImage(g_i3k_db.i3k_db_get_icon_path(COLOR_MAP['CURVE_ORANGE_'..i]))
		elseif isFirstUnlock then
			curve:setImage(g_i3k_db.i3k_db_get_icon_path(COLOR_MAP['CURVE_BLUE_'..i]))
		else
			curve:hide()
		end
	end
	for i = 1, 3 do
		for i2 = 1, 5 do
			local line = widgets['line'..i..i2]
			local index_p1 = g_i3k_db.i3k_db_get_pet_guard_potential_ui_map(i, i2)
			local index_p2 = g_i3k_db.i3k_db_get_pet_guard_potential_ui_map(i + 1, i2)
			local p1 = widgets['dian'..index_p1]
			local p2 = widgets['dian'..index_p2]
			local p1_unlock = p1:getTag() == 1
			local p2_unlock = p2:getTag() == 1
			if p1_unlock then
				line:show()
				if p2_unlock then
					line:setImage(g_i3k_db.i3k_db_get_icon_path(COLOR_MAP.LINE_ORANGE))
				else
					line:setImage(g_i3k_db.i3k_db_get_icon_path(COLOR_MAP.LINE_BLUE))
				end
			else
				line:hide()
			end
		end
	end
end

function wnd_pet_guard_potential:setDetail()
	local potentialId = self.potentialId
	local widgets = self._layout.vars
	local cfg = i3k_db_pet_guard_potential[self.petGuardId][potentialId]
	local active = g_i3k_game_context:GetActivePetGuards()[self.petGuardId]
	local preCond = cfg.unlockConditionId
	local isUnlock = g_i3k_db.i3k_db_get_pet_guard_potential_is_unlock(self.petGuardId, potentialId)
	local process = g_i3k_db.i3k_db_get_pet_guard_potential_unlock_process(self.petGuardId, potentialId)
	local potentialGroupCfg = i3k_db_pet_guard_potential[self.petGuardId]
	widgets.isActiveIcon:setVisible(isUnlock)
	widgets.des:setText(cfg.des)
	widgets.name:setText(cfg.name)
	local condStr = string.format(i3k_db_pet_guard_precondition[preCond].des, g_i3k_get_cond_hl_color(process >= 1))
	widgets.preConditionDes:setText(condStr)
	widgets.preConditionDes:setVisible(not isUnlock)
	widgets.unlockTxtRoot:setVisible(not isUnlock)
	widgets.preNodeDes:setVisible(not isUnlock and cfg.unlockPotentialGroupId[1] ~= 0)
	if cfg.unlockPotentialGroupId[1] ~= 0 then
		local preNodeStr = i3k_get_string(17953)
		for i, v in pairs(cfg.unlockPotentialGroupId) do
			local name = potentialGroupCfg[v].name
			local isPotentialUnlock = g_i3k_db.i3k_db_get_pet_guard_potential_is_unlock(self.petGuardId, v)
			preNodeStr = preNodeStr .. i3k_get_string(17954, g_i3k_get_cond_hl_color(isPotentialUnlock), name)
		end
		widgets.preNodeDes:setText(preNodeStr)
	end
	widgets.prop_scroll:removeAllChildren()
	widgets.unlockBtn:setVisible(not isUnlock and g_i3k_db.i3k_db_get_pet_guard_potential_can_unlock(self.petGuardId, potentialId) and true)
	local isAllUnlock = g_i3k_db.i3k_db_get_is_pet_guard_potential_all_unlock(self.petGuardId)
	for i, v in ipairs(cfg.props) do
		local ui = require(PROP_WIDGET)()
		local vars = ui.vars
		if v.id ~= 0 then
			vars.name:setText(g_i3k_db.i3k_db_get_property_name(v.id))
			vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(v.id)))
			local finalValue = v.value
			vars.value:setVisible(not isAllUnlock)
			vars.maxValue:setVisible(isAllUnlock)
			if isAllUnlock then
				finalValue = math.ceil(finalValue * i3k_db_pet_guard_base_cfg.allPotentialUnlockRatio / 10000)
				vars.maxValue:setText(finalValue)
			else
				vars.value:setText(finalValue)
			end
			vars.value:setText(i3k_get_prop_show(v.id, finalValue))
			widgets.prop_scroll:addItem(ui)
		end
	end
end

function wnd_pet_guard_potential:onUnlockSuccess(latentId)
	local cfg = i3k_db_pet_guard_potential[self.petGuardId][latentId]
	if cfg then
		local widgets = self._layout.vars
		local index = g_i3k_db.i3k_db_get_pet_guard_potential_ui_map(cfg.x, cfg.y)
		local dian = widgets['dian'..index]
		local dianPos = dian:getPosition()
		widgets.activeAnimation:setPosition(dianPos.x, dianPos.y)
		self._layout.anis.c_1.stop()
		self._layout.anis.c_1.play()
		if cfg.y == 1 or cfg.y == 5 then
			widgets['curve'..cfg.x]:setPercent(0)
			g_i3k_coroutine_mgr:StartCoroutine(function()
				local i = 1
				while i < 100 do
					i = i + 10
					widgets['curve'..cfg.x]:setPercent(i)
					g_i3k_coroutine_mgr.WaitForSeconds(0.01)
				end
			end)
		end
	end
end
function wnd_pet_guard_potential:onUnLockBtnClick(sender)
	local active = g_i3k_game_context:GetActivePetGuards()[self.petGuardId]
	if not active then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17955))
	else
		local process = g_i3k_db.i3k_db_get_pet_guard_potential_unlock_process(self.petGuardId, self.potentialId)
		if process >= 1 then
			i3k_sbean.pet_guard_unlock_latent(self.petGuardId, self.potentialId, 0, 0)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_PetGuardPotentialActive)
			g_i3k_ui_mgr:RefreshUI(eUIID_PetGuardPotentialActive, self.petGuardId, self.potentialId , process)
		end
	end
end

function wnd_pet_guard_potential:onPotentialClick(sender, index)
	local widgets = self._layout.vars
	local potentialId = sender:getTag()
	for i=1, 20 do
		widgets['sel'..i]:setVisible(index == i)
	end
	self.potentialId = potentialId
	self:setDetail()
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_pet_guard_potential.new()
	wnd:create(layout,...)
	return wnd
end

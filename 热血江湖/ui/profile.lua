-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_profile = i3k_class("wnd_profile",ui.wnd_base)

--开始点击事件和结束时间
local startTime
local endTime
--开始位置和结束位置
local startPos
local endPos
local dis --距离
local speed --速度 
local time --时间
local METAMORPHOSIS_TYPE = 1 --幻形类型
local EQUIP_BTN_TYPE = 1 --默认显示类型
local PAGETYPE_UPLEVEL 		= 1
local PAGETYPE_QIANGHUA 	= 2
local PAGETYPE_XIANGQIAN 	= 3
function wnd_profile:ctor()
	self.selectID 	= 0
	self.partID 	= 0
	self.wear_equip = {}
	--[[for i=1, eEquipCount do
		self.wear_equip[i] = {
		equip_btn	= nil, --装备button
		equip_icon	= nil, --装备Icon
		grade_icon	= nil, -- 装备品级框
		repair_icon	= nil, --装备修理
		is_select	= nil, --装备是否被选择
		level_label	= nil, --装备等级label
		red_tips	= nil} --装备红点
	end--]]
	
	self.role_lv		= nil --角色等级
	self.class_type		= nil --类型
	self.battle_power	= nil --战力
	self.hero_module	= nil --模型
	self.class_icon		= nil --角色类型图
	
	self.revolve = nil --旋转模型的btn
	self._weaponShowName =
	{
		{weaponType = g_WEAPON_SHOW_TYPE, name = 1697,},
		{weaponType = g_HEIRHOOM_SHOW_TYPE, name = 1698,},
		{weaponType = g_FASTION_SHOW_TYPE, name = 1699,},
		{weaponType = g_FLYING_SHOW_TYPE, name = 1700,},
	}
	self._propertyNode =
	{
		{clickFuc = self.onStrengTips, icon = 8485},
		{clickFuc = self.onUpStarTips, icon = 8484},
		{clickFuc = self.onSuitEquip, icon = 8486},
		{clickFuc = self.onRewardLog, icon = 9624},
		{clickFuc = self.openFootEffect, icon = 8487},
	}
	self.weaponShowState = false
	self.skinShowState = false
	self.equipTypeRoot = nil  		--装备显示类型root
	self._equipTypeButton = {}      --装备 飞升按钮
	self._equipShowType = 0 		--装备显示类型
	--四大页签和顶部双按钮红点
	self.qhRedPoint 		= nil
	self.starRedPoint 		= nil
	self.inlayRedPoint 		= nil
	self.temperRedPoint 	= nil
	self.isBag = false
end

function wnd_profile:configure()
end

function wnd_profile:initShowType(wEquips)
	for i=1, eEquipCount do
		local equip = wEquips[i].equip
		if equip then
			if i > eEquipArmor then
				self:setEquipBtnType(eEquipFeisheng)
				return
			else
				self:setEquipBtnType(eEquipNormal)
				return
			end
		end
	end
	self:setEquipBtnType(eEquipNormal)
end
function wnd_profile:defaultSelectEquip(showType, wEquips)
	local startPos = showType == eEquipNormal and eEquipWeapon or eEquipFlying
	local endPos = showType == eEquipNormal and eEquipArmor or eEquipFlyRing
	for i = startPos, endPos do
		local equip = wEquips[i].equip
		if equip then
			self.wear_equip[i].is_select:show()
			self.selectID = i;
			self.partID = i;
			if self.setRightView then
				self:setRightView(equip.equip_id, i)
			end
			if self.updateSlotGemImage then
				self:updateSlotGemImage(i)
				self:canSlotClicked()
			end
			break
		end
	end
	if self.updateFuncs then
		self:updateFuncs(self.partID)
	end
	for i=1, #self.wear_equip do
		self.wear_equip[i].is_select:setVisible(i == self.partID)
	end
end
function wnd_profile:showTopBtn(showBtn)
	if self.equipTypeRoot then
		self.equipTypeRoot:setVisible(showBtn)
		for i,v in ipairs(self._equipTypeButton) do
			v.btnWidget:setVisible(showBtn)
		end
	end
end

function wnd_profile:updateProfile(ctype, level, fightpower, wearEquips)
	local level_str = string.format("%s级",level)
	if self.role_lv then
		self.role_lv:setText(level_str)		
		--local _, count = string.gsub(ctype, "[^\128-\193]", "")
		--local str = count > 2 and ctype or string.sub(ctype, 1, 3) .. "  " .. string.sub(ctype, 4, 6)
		self.class_type:setText(ctype)
		local gcfg = g_i3k_db.i3k_db_get_general(g_i3k_game_context:GetRoleType())
		self.class_icon:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
		self.battle_power:setText(fightpower)
	end
	
	local feishengOpen = g_i3k_game_context:isFinishFlyingTask(1)
	self:showTopBtn(feishengOpen)
	for i,e in ipairs(self.wear_equip) do
		if g_i3k_game_context:isFlyEquip(i) and not feishengOpen then
			e.equip_btn:hide()
		else
			e.equip_btn:show()
		local equip = wearEquips[i] and wearEquips[i].equip
		if equip then
			e.equip_btn:enable()
			e.equip_icon:show()
				e.equip_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(equip.equip_id, g_i3k_game_context:IsFemaleRole()))
				if g_i3k_game_context:GetIsGlodCoast() then
					e.equip_icon:disable()
				end
			e.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(equip.equip_id))
		else
			e.equip_btn:disable()
			e.equip_icon:hide()
			e.grade_icon:setImage(g_i3k_get_icon_frame_path_by_pos(i))
			e.level_label:hide()
			e.red_tips:hide()
			end
		end
	end
	self:updateRecover()
	if self.strengthen then 
		self.strengthen:setVisible(g_i3k_game_context:TestStrengthenSelfShowState(true)) 
	end 
end

function wnd_profile:updateWearEquipSelect()
	for i=1,eEquipCount do
		self.wear_equip[i].is_select:hide()
	end
end

--还原时装
function wnd_profile:updateRecover()
	g_i3k_game_context:ResetTestFashionData()
	ui_set_hero_model(self.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(),g_i3k_game_context:getIsShowArmor())
end

function wnd_profile:updateRolePower()
	self.battle_power:setText(g_i3k_game_context:GetRolePower())
end

function wnd_profile:setDynamicEffect(id, Dresstype)
	local widgets = self._layout.vars
	local cfg = nil
	if Dresstype == METAMORPHOSIS_TYPE then
		cfg = i3k_db_metamorphosis[id]
	else	
		cfg = i3k_db_fashion_dress[id]
	end
	local iseffect = cfg and cfg.withEffect == 1
	widgets.dxpf:setVisible(iseffect and true or false)
	self.revolve[iseffect and 'disable' or 'enable'](self.revolve)
	if not iseffect then return; end
	local effectImg = cfg.effectImg
	for i = 1, 4 do
		widgets['qua'..i]:setVisible(effectImg[i] and effectImg[i]~= 0 and true or false)
		if effectImg and effectImg[i] then
			local img = widgets['qua'..i]
			img.image = effectImg[i]
			img:setImage(i3k_db.i3k_db_get_icon_path(img.image))
		end
	end
end

function wnd_profile:initEffectEvent()--初始化特效披风品质点击事件
	local widgets = self._layout.vars
	for i =1, 4 do
		widgets['qua'..i]:onTouchEvent(self,self.onShowEffectDes)
	end
end

function wnd_profile:onShowEffectDes(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		g_i3k_ui_mgr:OpenUI(eUIID_EffectFashionTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_EffectFashionTips, sender.image)
	else
		if eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			g_i3k_ui_mgr:CloseUI(eUIID_EffectFashionTips)
		end
	end
end

function wnd_profile:onShowBtn(sender)
	local cfg = i3k_db_fashion_dress[self.showingFashionId and self.showingFashionId or 0]
	local showAct = cfg and cfg.showAction
	self.hero_module.isEffectFashion = true
	local hero = i3k_game_get_player_hero()
	local curFashionId = g_i3k_game_context:GetCurFashion()
	local curFashionCfg = i3k_db_fashion_dress[curFashionId]
	if #hero._TestfashionID == 0 and cfg and cfg.showModleId and curFashionCfg and curFashionCfg.showModleId then
	 	g_i3k_game_context:SetTestFashionData(curFashionId)
	end
	if not showAct then return; end
	ui_set_hero_model(self.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(),g_i3k_game_context:getIsShowArmor())
	for i, v in ipairs(showAct) do
		self.hero_module:pushActionList(v, i == #showAct and -1 or 1)
	end
	self.hero_module:playActionList()
end


function wnd_profile:onRotateBtn(sender, eventType, isNotBreakCurAct)--isNotBreakCurAct 如果是true 就不打断当前动作
	if eventType == ccui.TouchEventType.began then
		self.rotate = self.hero_module:getRotation()
		self.hero_module:setRotation(self.rotate.y)
		startTime = i3k_game_get_time()
		startPos = sender:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
	else
		endPos = sender:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
		endTime = i3k_game_get_time()
		self:getRotate(isNotBreakCurAct)
		if eventType==ccui.TouchEventType.ended then
			self.index = 0
		end
	end
end

function wnd_profile:getRotate(isNotBreakCurAct)--是否屏蔽打断当前动作
	local btnPos = self.revolve:getPosition()
	local btnContentSize = self.revolve:getContentSize()
	local minPosX = btnPos.x - btnContentSize.width / 2
	local maxPosX = btnPos.x + btnContentSize.width / 2
	if endPos.x < minPosX then
		endPos.x = minPosX
	elseif endPos.x > maxPosX then
		endPos.x = maxPosX
	end
	dis = endPos.x - startPos.x
	time = endTime - startTime
	speed = dis / time
	local angel = self.rotate.y + math.rad(-dis)
	self.hero_module:setRotation(angel)
	if isNotBreakCurAct then return end
	self.index = self.index or 0
	local hero = i3k_game_get_player_hero()
	if math.abs(math.floor(speed)) > 1000 then --速度过快播放眩晕动作
		if self.index<1 then
			self.index = self.index + 1
			local action = i3k_db_common.engine.swoonEffect
			self.hero_module:pushActionList(getMappingAct(hero, action), 1)
			self.hero_module:pushActionList(getMappingAct(hero), -1)
			self.hero_module:playActionList()
		end
	end
end
function wnd_profile:wearingSevenEquipTips(sender)
	local tips = g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	g_i3k_logic:OpenLongyinUI()
end
function wnd_profile:onClickArtifact( sender )
	local tips = g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		g_i3k_ui_mgr:PopupTipMessage(tips)
		return
	end
	local heirloom = g_i3k_game_context:getHeirloomData()
	if heirloom.isOpen == 1 then
		g_i3k_logic:OpenArtufact1UI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15181))
	end
end
--设置武器外显
function wnd_profile:setChangeWeaponShow()
	local equips = g_i3k_game_context:GetWearEquips()
	local heirloom = g_i3k_game_context:getHeirloomData()
	local fashion = g_i3k_game_context:GetWearFashionData()
	if g_i3k_game_context:isFinishFlyingTask(1) or heirloom.isOpen == 1 or (fashion and fashion[g_FashionType_Weapon]) then
		self._layout.vars.weaponShowRoot:show()
		local weaponShowType = g_i3k_game_context:getCurWeaponShowType()
		self._layout.vars.showTypeText1:setText(self:getNameByWeaponType(weaponShowType))
		self._layout.vars.showTypeBg1:hide()
		--self:setWeaponShowTypeScroll()
	else
		self._layout.vars.weaponShowRoot:hide()
	end
end
function wnd_profile:onChangeWeaponShowBtn(sender)
	if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1817))
	end
	if self.weaponShowState then
		self.weaponShowState = false
		self._layout.vars.showTypeBg1:hide()
	else
		self.weaponShowState = true
		self._layout.vars.showTypeBg1:show()
		self:setWeaponShowTypeScroll()
	end
end

function wnd_profile:setWeaponShowTypeScroll()
	local weaponShowType = g_i3k_game_context:getCurWeaponShowType()
	self._layout.vars.showTypeText1:setText(self:getNameByWeaponType(weaponShowType))
	self._layout.vars.showTypeScroll1:removeAllChildren()
	if self.weaponShowState then
		for k, v in ipairs(self._weaponShowName) do
			local needAdd = false
			if v.weaponType == g_WEAPON_SHOW_TYPE then
				needAdd = true
			elseif v.weaponType == g_HEIRHOOM_SHOW_TYPE then
				local heirloom = g_i3k_game_context:getHeirloomData()
				if heirloom.isOpen == 1 then
					needAdd = true
				end
			elseif v.weaponType == g_FASTION_SHOW_TYPE then
				local fashion = g_i3k_game_context:GetWearFashionData()
				if fashion and fashion[g_FashionType_Weapon] then
					needAdd = true
				end
			elseif v.weaponType == g_FLYING_SHOW_TYPE then
				if g_i3k_game_context:isFinishFlyingTask(1) then
					needAdd = true
				end
			end
			if needAdd then
				local node = require("ui/widgets/bgsxt")()
				node.vars.levelLabel:setText(i3k_get_string(v.name))
				node.vars.levelBtn:onClick(self, self.onChangeWeaponTypeBtn, v.weaponType)
				self._layout.vars.showTypeScroll1:addItem(node)
			end
		end
	end
end

function wnd_profile:getNameByWeaponType(weaponType)
	for k, v in ipairs(self._weaponShowName) do
		if v.weaponType == weaponType then
			return i3k_get_string(v.name)
		end
	end
end

function wnd_profile:onChangeWeaponTypeBtn(sender, showType)
	if showType == g_i3k_game_context:getCurWeaponShowType() then
		self.weaponShowState = false
		self:setChangeWeaponShow()
	else
		i3k_sbean.weapondisplay_select(showType)
	end
end

function wnd_profile:changeWeaponShowHandler()
	self.weaponShowState = false
	self:setChangeWeaponShow()
	self:updateRecover()
end

function wnd_profile:setPropertyScroll()
	self._layout.vars.propertyScroll:removeAllChildren()
	for k, v in ipairs(self._propertyNode) do
		--飞升的要判断是否完成才会添加
		if not (k == 5 and not g_i3k_game_context:isFinishFlyingTask(1)) then
			local node = require("ui/widgets/bgt3")()
			node.vars.btn:onClick(self, v.clickFuc)
			node.vars.btn:setNormalImage(g_i3k_db.i3k_db_get_icon_path(v.icon))
			self._layout.vars.propertyScroll:addItem(node)
		end
	end
end

function wnd_profile:onStrengTips(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_RoleTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_RoleTips, g_i3k_db.i3k_db_get_streng_reward_info_for_type())
end

function wnd_profile:onUpStarTips(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_Danyao)
	g_i3k_ui_mgr:RefreshUI(eUIID_Danyao)
end

function wnd_profile:onSuitEquip(sender)
	local tips = g_i3k_game_context:GetNotEnterTips() or g_i3k_game_context:GetNotEnterMapIdTips()
	if tips then
		return g_i3k_ui_mgr:PopupTipMessage(tips)
	end
	g_i3k_logic:OpenSuitUI()
end

function wnd_profile:openFootEffect(sender)
	i3k_sbean.footeffect_sync()
end

function wnd_profile:onRewardLog(sender)
	i3k_sbean.item_history_sync()
end
--设置按钮UI控件值
function wnd_profile:setTopBtnWidgets(widgets)
	self.equipTypeRoot = widgets.bg_root
	self._equipTypeButton = {
		{rootWidget = widgets.eq_root, btnWidget = widgets.eq_btn},
		{rootWidget = widgets.fs_root, btnWidget = widgets.fs_btn},
	}
end

--初始化显示装备
function wnd_profile:initEquipBtnState(widgets, isBag)
	self.isBag = isBag and isBag or false
	self:setTopBtnWidgets(widgets)
	self:initEquipBtnClick()
	--self:setEquipBtnType(EQUIP_BTN_TYPE)
end
--初始化顶部页签
function wnd_profile:initEquipBtnClick()
	for i, e in ipairs(self._equipTypeButton) do
		e.btnWidget:onClick(self, self.onEquipTypeChange, i)
	end
end
function wnd_profile:onEquipTypeChange(sender, showType)
	if g_i3k_game_context:CheckEquipsIsNilByType(showType) and not self.isBag then
		if showType == eEquipNormal then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1810))
		else
			if g_i3k_game_context:GetIsGlodCoast() then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
			end
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1811))
		end
		return
	end
	self:setEquipBtnType(showType)
end
--根据穿戴装备的类型显示页签
function wnd_profile:changeShowType(pos)
	local typeID = g_i3k_game_context:isFlyEquip(pos) and eEquipFeisheng or eEquipNormal
	self:setEquipBtnType(typeID)
end
function wnd_profile:setEquipBtnType(showType)
	if self._equipShowType ~= showType then
		self._equipShowType = showType
		self:updateEquipBtnTypeChange(showType)
	end
	if self._equipShowType == eEquipNormal then
		self:defaultSelectEquip(eEquipNormal, g_i3k_game_context:GetWearEquips())
	else
		self:defaultSelectEquip(eEquipFeisheng, g_i3k_game_context:GetWearEquips())
	end
end
function wnd_profile:updateEquipBtnTypeChange(showType)
	for i, e in ipairs(self._equipTypeButton) do
		if showType == i then
			e.btnWidget:stateToPressed(true)
			e.rootWidget:show()
		else
			e.btnWidget:stateToNormal(true)
			e.rootWidget:hide()
		end
	end
end
function wnd_profile:initRedPoint(widgets)
	--升级，强化，镶嵌，锤炼
	self.qhRedPoint = widgets.strengRedPoint
	self.starRedPoint = widgets.starRedPoint
	self.inlayRedPoint = widgets.inlayRedPoint
	self.temperRedPoint = widgets.temperRedPoint
	--装备飞升
	self.eqRedPoint = widgets.eq_red
	self.fsRedPoint = widgets.fs_red
end
function wnd_profile:updatePageRedPoint(func)
	self.qhRedPoint:setVisible(g_i3k_game_context:qhRedPoint())
	self.starRedPoint:setVisible(g_i3k_game_context:starRedPoint())
	self.inlayRedPoint:setVisible(g_i3k_game_context:isHaveInlayRedPoint())
	self.temperRedPoint:setVisible(g_i3k_game_context:temperRedPoint())
	self.eqRedPoint:setVisible(func(g_i3k_game_context, eEquipWeapon, eEquipArmor))
	self.fsRedPoint:setVisible(func(g_i3k_game_context, eEquipFlying, eEquipFlyRing))
end
function wnd_create(layout)
	local wnd = wnd_profile.new()
		wnd:create(layout)
	return wnd
end

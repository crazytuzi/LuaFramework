-- @Author: zhouxiaoshu
-- @Date:   2019-08-02 17:24:11
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-04 15:17:32

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSuperHeroGodSkill = class("QUIDialogSuperHeroGodSkill", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetSuperGodStar = import("..widgets.QUIWidgetSuperGodStar")
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")
local QColorLabel = import("...utils.QColorLabel")
local QScrollView = import("...views.QScrollView")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QActorProp = import("...models.QActorProp")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

function QUIDialogSuperHeroGodSkill:ctor(options)
	local ccbFile = "ccb/Dialog_super_hero.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerGrade", callback = handler(self, self._onTriggerGrade)},
		{ccbCallbackName = "onTriggerPlus", callback = handler(self, self._onTriggerPlus)},
		{ccbCallbackName = "onTriggerSkill", callback = handler(self, self._onTriggerSkill)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSuperHeroGodSkill.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	self._actorId = options.actorId
	self._callBack = options.callback
	self._canGrade = false

    q.setButtonEnableShadow(self._ccbOwner.btn_skill)
    q.setButtonEnableShadow(self._ccbOwner.btn_special_skill)

	local progress = q.newPercentBarClippingNode(self._ccbOwner.sp_progress)
	self._progressWidth = self._ccbOwner.sp_progress:getContentSize().width
	self._progressStencil = progress:getStencil()

	self._ccbOwner.frame_tf_title:setString("神 技")

	self._ccbOwner.node_old_ssr_prop:setVisible(false)
	self._ccbOwner.node_new_ssr_prop:setVisible(false)
	self._ccbOwner.node_now_ssr_prop:setVisible(false)

	local aptitudeInfo = db:getActorSABC(self._actorId)
	if aptitudeInfo and aptitudeInfo.qc == "SS+" then
		self._isSSR = true
	else
		self._isSSR = false
	end

	self:_initView()
	self:initHeroInfo()
	self:updateHeroInfo()
end

function QUIDialogSuperHeroGodSkill:_initView()
	if self._isSSR then
		self._totalHeight = 380
	else
		self._totalHeight = 260
	end

	self._oldWidth = self._ccbOwner.node_old_mask:getContentSize().width
    self._oldHeight = self._ccbOwner.node_old_mask:getContentSize().height
    self._oldContent = self._ccbOwner.node_old_prop
    self._oldPrginalPosition = ccp(self._oldContent:getPosition())
    local oldLayerColor = CCLayerColor:create(ccc4(0,0,0,150), self._oldWidth, self._oldHeight)
    local oldClippingNode = CCClippingNode:create()
    oldLayerColor:setPositionX(self._ccbOwner.node_old_mask:getPositionX())
    oldLayerColor:setPositionY(self._ccbOwner.node_old_mask:getPositionY())
    oldClippingNode:setStencil(oldLayerColor)
    self._oldContent:removeFromParent()
    oldClippingNode:addChild(self._oldContent)
    self._ccbOwner.node_old:addChild(oldClippingNode)

    self._newWidth = self._ccbOwner.node_new_mask:getContentSize().width
    self._newHeight = self._ccbOwner.node_new_mask:getContentSize().height
    self._newContent = self._ccbOwner.node_new_prop
    self._newPrginalPosition = ccp(self._newContent:getPosition())
    local newLayerColor = CCLayerColor:create(ccc4(0,0,0,150), self._newWidth, self._newHeight)
    local newClippingNode = CCClippingNode:create()
    newLayerColor:setPositionX(self._ccbOwner.node_new_mask:getPositionX())
    newLayerColor:setPositionY(self._ccbOwner.node_new_mask:getPositionY())
    newClippingNode:setStencil(newLayerColor)
    self._newContent:removeFromParent()
    newClippingNode:addChild(self._newContent)
    self._ccbOwner.node_new:addChild(newClippingNode)

    self._nowWidth = self._ccbOwner.node_now_mask:getContentSize().width
    self._nowHeight = self._ccbOwner.node_now_mask:getContentSize().height
    self._nowContent = self._ccbOwner.node_now_prop
    self._nowPrginalPosition = ccp(self._nowContent:getPosition())
    local nowLayerColor = CCLayerColor:create(ccc4(0,0,0,150), self._nowWidth, self._nowHeight)
    local nowClippingNode = CCClippingNode:create()
    nowLayerColor:setPositionX(self._ccbOwner.node_now_mask:getPositionX())
    nowLayerColor:setPositionY(self._ccbOwner.node_now_mask:getPositionY())
    nowClippingNode:setStencil(nowLayerColor)
    self._nowContent:removeFromParent()
    nowClippingNode:addChild(self._nowContent)
    self._ccbOwner.node_now:addChild(nowClippingNode)
end

function QUIDialogSuperHeroGodSkill:viewDidAppear()
	QUIDialogSuperHeroGodSkill.super.viewDidAppear(self)

	self._touchLayer = QUIGestureRecognizer.new({color = false})
    self._touchLayer:attachToNode(self:getView(), self._nowWidth, self._nowHeight, -(self._nowWidth)/2, -(self._nowHeight + 25), handler(self, self._onTouchEvent))
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self._onTouchEvent))
end 

function QUIDialogSuperHeroGodSkill:viewWillDisappear()
	QUIDialogSuperHeroGodSkill.super.viewWillDisappear(self)

	if self._touchLayer then
		self._touchLayer:removeAllEventListeners()
	    self._touchLayer:disable()
	    self._touchLayer:detach()
    end
end

function QUIDialogSuperHeroGodSkill:initHeroInfo()
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_special_star:removeAllChildren()
	self._ccbOwner.node_star:removeAllChildren()
	self._ccbOwner.tf_special_skill_name:setVisible(false)
	self._ccbOwner.ccb_icon_effect:setVisible(false)

	self._itemAvatar = QUIWidgetEquipmentAvatar.new()
	self._ccbOwner.node_icon:addChild(self._itemAvatar)

    self._skillStar = QUIWidgetSuperGodStar.new()
    self._skillStar:setGrade(self._actorId)
    self._ccbOwner.node_star:addChild(self._skillStar)

	local size = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, size, {bufferMode = 1})
    self._scrollView:setVerticalBounce(true)
end

function QUIDialogSuperHeroGodSkill:updateHeroInfo()
	self:disableTouchSwallowTop()
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	if heroInfo == nil then return end
	self._heroInfo = heroInfo
	self._canGrade = false

	local godSkillRealLevel = heroInfo.godSkillGrade or 1
	self._godSkillTbl = db:getGodSkillById(self._actorId)
	local oldGodSkillConfig = self._godSkillTbl[godSkillRealLevel] or {}
	local newGodSkillConfig = self._godSkillTbl[godSkillRealLevel + 1]
	
	self._itemAvatar:retain()
	self._itemAvatar:removeFromParent()
	self._skillStar:retain()
	self._skillStar:removeFromParent()

    local gradeConfig = db:getGradeByHeroActorLevel(self._actorId, 0)
    self._soulNum = remote.items:getItemsNumByID(gradeConfig.soul_gem)
    self._isShowSuccessDialog = false -- 升级之后是否展示成果界面
	if self._isSSR and newGodSkillConfig then
		-- ss+ 并且 未满级
		self._maxUpLevel = 0 -- 可以升的最高级别
    	local needSoulNum = 0 -- 升的最高级别需要的碎片数量
		-- 星星
		self._ccbOwner.node_special_star:addChild(self._skillStar)

		local curConfigList = db:getGodSkillByIdAndShowLevel(self._actorId, oldGodSkillConfig.grade)
		local nextConfigList = db:getGodSkillByIdAndShowLevel(self._actorId, oldGodSkillConfig.grade + 1)
		if not nextConfigList then return end

		self._removeConfig = table.remove(curConfigList, 1)
		table.insert(curConfigList, nextConfigList[1])

		self._itemAvatar:setGodSkillInfo(self._actorId, nextConfigList[1].level)

		self._curConfigList = curConfigList
		self._curPoint = 0
		local maxIndex = #curConfigList
		for i, config in ipairs(curConfigList) do
			local node = self._ccbOwner["node_small_level_"..i]
			local line = self._ccbOwner["sp_line_"..i]
			if line then
				line:setVisible(false)
			end
			if node then
				node:removeAllChildren()
				if i == maxIndex then
					-- 当前阶段最后一个节点， 技能icon
					if config.level == godSkillRealLevel + 1 then
						-- 特效
						self._ccbOwner.ccb_icon_effect:setVisible(true)
						self._curPoint = i - 1
						self._ccbOwner.tf_btn_grade:setString("进 阶")
					end
					self._itemAvatar:setPositionY(-20)
					node:addChild(self._itemAvatar)
					self._itemAvatar:hideAllColor()
					local skillIds = string.split(config.skill_id, ";")
					local skillConfig = db:getSkillByID(skillIds[1])
					self._ccbOwner.tf_special_skill_name:setString(skillConfig.name)
					self._ccbOwner.tf_special_skill_name:setVisible(true)

					needSoulNum = needSoulNum + config.stunt_num
					if self._soulNum >= needSoulNum then
						if self._maxUpLevel < config.level then
							self._maxUpLevel = config.level
							self._isShowSuccessDialog = true
							self._oldGodSkillConfig = oldGodSkillConfig
							self._newGodSkillConfig = self._godSkillTbl[config.level]
						end
					end
				else
					local path = ""
					if config.level <= godSkillRealLevel then
						-- 已经激活
						path = QResPath("god_skill_activated")
						if line then
							line:setVisible(true)
						end
					elseif config.level == godSkillRealLevel + 1 then
						-- 即将激活的普通节点
						self._curPoint = i - 1
						path = QResPath("god_skill_next_activated")
						needSoulNum = needSoulNum + config.stunt_num
						if self._soulNum >= needSoulNum then
							if self._maxUpLevel < config.level then
								self._maxUpLevel = config.level
							end
						end
						self._ccbOwner.ccb_icon_effect:setVisible(false)
						self._ccbOwner.tf_btn_grade:setString("升 星")
					else
						needSoulNum = needSoulNum + config.stunt_num
						if self._soulNum >= needSoulNum then
							if self._maxUpLevel < config.level then
								self._maxUpLevel = config.level
							end
						end
					end
					if path and path ~= "" then
						local sprite = CCSprite:create(path)
						node:addChild(sprite)
					end
				end
				node:setVisible(true)
			end
		end

		self._ccbOwner.node_normal:setVisible(false)
		self._ccbOwner.node_special:setVisible(true)
	else
		self._itemAvatar:setGodSkillInfo(self._actorId, godSkillRealLevel)
		self._skillStar:setGrade(self._actorId)

		self._isShowSuccessDialog = true

		-- 技能icon
		self._ccbOwner.node_icon:addChild(self._itemAvatar)

		-- 星星
		self._ccbOwner.node_star:addChild(self._skillStar)

		self._ccbOwner.node_normal:setVisible(true)
		self._ccbOwner.node_special:setVisible(false)

		self._ccbOwner.tf_btn_grade:setString("进 阶")
	end
	self._itemAvatar:release()
	self._skillStar:release()

	-- 显示魂力精魄
    local itemBox = QUIWidgetItemsBox.new()
    itemBox:setGoodsInfo(gradeConfig.soul_gem, ITEM_TYPE.ITEM, 0)
    itemBox:hideSabc()
    itemBox:hideTalentIcon()
    itemBox:setScale(0.5)
	self._ccbOwner.node_hero_icon:removeAllChildren()
    self._ccbOwner.node_hero_icon:addChild(itemBox)

    local aptitudeInfo = db:getActorSABC(self._actorId)

    if newGodSkillConfig then
    	self._ccbOwner.tf_old_title_1:setString("攻    击：")
    	self._ccbOwner.tf_old_title_2:setString("生    命：")
    	self._ccbOwner.tf_old_title_3:setString("物    防：")
    	self._ccbOwner.tf_old_title_4:setString("法    防：")
    	self._ccbOwner.tf_old_title_5:setString("攻    击：")
    	self._ccbOwner.tf_old_title_6:setString("生    命：")
    	self._ccbOwner.tf_old_title_7:setString("物    防：")
    	self._ccbOwner.tf_old_title_8:setString("法    防：")
		self._ccbOwner.tf_old_prop_1:setString(string.format("+%d", (oldGodSkillConfig.attack_value or 0)))
		self._ccbOwner.tf_old_prop_2:setString(string.format("+%d", (oldGodSkillConfig.hp_value or 0)))
    	self._ccbOwner.tf_old_prop_3:setString(string.format("+%d", (oldGodSkillConfig.armor_physical or 0)))
		self._ccbOwner.tf_old_prop_4:setString(string.format("+%d", (oldGodSkillConfig.armor_magic or 0)))
    	self._ccbOwner.tf_old_prop_5:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.attack_percent or 0, true, 1))
		self._ccbOwner.tf_old_prop_6:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.hp_percent or 0, true, 1))
		self._ccbOwner.tf_old_prop_7:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.armor_physical_percent or 0, true, 1))
		self._ccbOwner.tf_old_prop_8:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.armor_magic_percent or 0, true, 1))
		if aptitudeInfo and aptitudeInfo.qc == "SS+" then
			self._ccbOwner.node_old_ssr_prop:setVisible(true)
			self._ccbOwner.tf_old_prop_9:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.physical_damage_percent_attack or 0, true, 1))
			self._ccbOwner.tf_old_prop_10:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.magic_damage_percent_attack or 0, true, 1))
			self._ccbOwner.tf_old_prop_11:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.physical_damage_percent_beattack_reduce or 0, true, 1))
			self._ccbOwner.tf_old_prop_12:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.magic_damage_percent_beattack_reduce or 0, true, 1))
		else
			self._ccbOwner.node_old_ssr_prop:setVisible(false)
		end

		self._ccbOwner.tf_new_title_1:setString("攻    击：")
    	self._ccbOwner.tf_new_title_2:setString("生    命：")
    	self._ccbOwner.tf_new_title_3:setString("物    防：")
    	self._ccbOwner.tf_new_title_4:setString("法    防：")
    	self._ccbOwner.tf_new_title_5:setString("攻    击：")
    	self._ccbOwner.tf_new_title_6:setString("生    命：")
    	self._ccbOwner.tf_new_title_7:setString("物    防：")
    	self._ccbOwner.tf_new_title_8:setString("法    防：")
		self._ccbOwner.tf_new_prop_1:setString(string.format("+%d", (newGodSkillConfig.attack_value or 0)))
		self._ccbOwner.tf_new_prop_2:setString(string.format("+%d", (newGodSkillConfig.hp_value or 0)))
    	self._ccbOwner.tf_new_prop_3:setString(string.format("+%d", (newGodSkillConfig.armor_physical or 0)))
		self._ccbOwner.tf_new_prop_4:setString(string.format("+%d", (newGodSkillConfig.armor_magic or 0)))
    	self._ccbOwner.tf_new_prop_5:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.attack_percent or 0, true, 1))
		self._ccbOwner.tf_new_prop_6:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.hp_percent or 0, true, 1))
		self._ccbOwner.tf_new_prop_7:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.armor_physical_percent or 0, true, 1))
		self._ccbOwner.tf_new_prop_8:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.armor_magic_percent or 0, true, 1))
		if aptitudeInfo and aptitudeInfo.qc == "SS+" then
			self._ccbOwner.node_new_ssr_prop:setVisible(true)
			self._ccbOwner.tf_new_prop_9:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.physical_damage_percent_attack or 0, true, 1))
			self._ccbOwner.tf_new_prop_10:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.magic_damage_percent_attack or 0, true, 1))
			self._ccbOwner.tf_new_prop_11:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.physical_damage_percent_beattack_reduce or 0, true, 1))
			self._ccbOwner.tf_new_prop_12:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.magic_damage_percent_beattack_reduce or 0, true, 1))
		else
			self._ccbOwner.node_new_ssr_prop:setVisible(false)
		end

	   	local value = self._soulNum/newGodSkillConfig.stunt_num
	   	if value > 1 then
	   		value = 1
	   	end
	    local progressStr = string.format("%d/%d", self._soulNum, newGodSkillConfig.stunt_num)
	    self._canGrade = value >= 1
	    self._progressStencil:setPositionX(value*self._progressWidth - self._progressWidth)
	    self._ccbOwner.tf_progress:setString(progressStr)
	    self._ccbOwner.node_tips:setVisible(self._canGrade)
    	self._ccbOwner.node_max:setVisible(false)
	else
		self._ccbOwner.tf_cur_title_1:setString("攻    击：")
    	self._ccbOwner.tf_cur_title_2:setString("生    命：")
    	self._ccbOwner.tf_cur_title_3:setString("物    防：")
    	self._ccbOwner.tf_cur_title_4:setString("法    防：")
    	self._ccbOwner.tf_cur_title_5:setString("攻    击：")
    	self._ccbOwner.tf_cur_title_6:setString("生    命：")
    	self._ccbOwner.tf_cur_title_7:setString("物    防：")
    	self._ccbOwner.tf_cur_title_8:setString("法    防：")
		self._ccbOwner.tf_cur_prop_1:setString(string.format("+%d", (oldGodSkillConfig.attack_value or 0)))
		self._ccbOwner.tf_cur_prop_2:setString(string.format("+%d", (oldGodSkillConfig.hp_value or 0)))
    	self._ccbOwner.tf_cur_prop_3:setString(string.format("+%d", (oldGodSkillConfig.armor_physical or 0)))
		self._ccbOwner.tf_cur_prop_4:setString(string.format("+%d", (oldGodSkillConfig.armor_magic or 0)))
    	self._ccbOwner.tf_cur_prop_5:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.attack_percent or 0, true, 1))
		self._ccbOwner.tf_cur_prop_6:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.hp_percent or 0, true, 1))
		self._ccbOwner.tf_cur_prop_7:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.armor_physical_percent or 0, true, 1))
		self._ccbOwner.tf_cur_prop_8:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.armor_magic_percent or 0, true, 1))
		if aptitudeInfo and aptitudeInfo.qc == "SS+" then
			self._ccbOwner.node_now_ssr_prop:setVisible(true)
			self._ccbOwner.tf_cur_prop_9:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.physical_damage_percent_attack or 0, true, 1))
			self._ccbOwner.tf_cur_prop_10:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.magic_damage_percent_attack or 0, true, 1))
			self._ccbOwner.tf_cur_prop_11:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.physical_damage_percent_beattack_reduce or 0, true, 1))
			self._ccbOwner.tf_cur_prop_12:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.magic_damage_percent_beattack_reduce or 0, true, 1))
		else
			self._ccbOwner.node_now_ssr_prop:setVisible(false)
		end

    	self._ccbOwner.node_grade:setVisible(false)
		self._ccbOwner.sp_arrow:setVisible(false)
		self._ccbOwner.node_new:setVisible(false)
		self._ccbOwner.node_old:setVisible(false)
    	self._ccbOwner.node_max:setVisible(true)
	end

    local skillIds = string.split(oldGodSkillConfig.skill_id, ";")
    local skillId = skillIds[1]
	local skillInfo = db:getSkillByID(skillId)
    self._ccbOwner.tf_name:setString(skillInfo.name)
    self._ccbOwner.tf_desc:setVisible(false)

	local text = QColorLabel:create(skillInfo.description or "", 320, nil, nil, 22, GAME_COLOR_LIGHT.normal)
	text:setAnchorPoint(ccp(0, 1))
	text:setPositionY(1)
	local totalHeight = text:getContentSize().height
	self._scrollView:clear()
	self._scrollView:addItemBox(text)
	self._scrollView:setRect(0, -totalHeight, 0, 0)
end


function QUIDialogSuperHeroGodSkill:_updatePropInfo(godSkillRealLevel)
	if not godSkillRealLevel or not self._isSSR or q.isEmpty(self._godSkillTbl) or q.isEmpty(self._curConfigList) then return end

	local oldGodSkillConfig = self._godSkillTbl[godSkillRealLevel] or {}
	local newGodSkillConfig = self._godSkillTbl[godSkillRealLevel + 1]

	if q.isEmpty(oldGodSkillConfig) or q.isEmpty(newGodSkillConfig) then return end

	-- 临时本地计算下剩余的碎片数量
	self._soulNum = self._soulNum - oldGodSkillConfig.stunt_num
	if self._soulNum < 0 then
		self._soulNum = 0
	end

	-- 刷新按钮的文字
	if newGodSkillConfig.level == self._curConfigList[#self._curConfigList].level then
		self._ccbOwner.ccb_icon_effect:setVisible(true)
		self._ccbOwner.tf_btn_grade:setString("进 阶")
	else
		self._ccbOwner.ccb_icon_effect:setVisible(false)
		self._ccbOwner.tf_btn_grade:setString("升 星")
	end

	-- 刷新属性列表
	-- self._ccbOwner.tf_old_title_1:setString("攻    击：")
	-- self._ccbOwner.tf_old_title_2:setString("生    命：")
	-- self._ccbOwner.tf_old_title_3:setString("物    防：")
	-- self._ccbOwner.tf_old_title_4:setString("法    防：")
	-- self._ccbOwner.tf_old_title_5:setString("攻    击：")
	-- self._ccbOwner.tf_old_title_6:setString("生    命：")
	-- self._ccbOwner.tf_old_title_7:setString("物    防：")
	-- self._ccbOwner.tf_old_title_8:setString("法    防：")
	self._ccbOwner.tf_old_prop_1:setString(string.format("+%d", (oldGodSkillConfig.attack_value or 0)))
	self._ccbOwner.tf_old_prop_2:setString(string.format("+%d", (oldGodSkillConfig.hp_value or 0)))
	self._ccbOwner.tf_old_prop_3:setString(string.format("+%d", (oldGodSkillConfig.armor_physical or 0)))
	self._ccbOwner.tf_old_prop_4:setString(string.format("+%d", (oldGodSkillConfig.armor_magic or 0)))
	self._ccbOwner.tf_old_prop_5:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.attack_percent or 0, true, 1))
	self._ccbOwner.tf_old_prop_6:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.hp_percent or 0, true, 1))
	self._ccbOwner.tf_old_prop_7:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.armor_physical_percent or 0, true, 1))
	self._ccbOwner.tf_old_prop_8:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.armor_magic_percent or 0, true, 1))
	self._ccbOwner.tf_old_prop_9:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.physical_damage_percent_attack or 0, true, 1))
	self._ccbOwner.tf_old_prop_10:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.magic_damage_percent_attack or 0, true, 1))
	self._ccbOwner.tf_old_prop_11:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.physical_damage_percent_beattack_reduce or 0, true, 1))
	self._ccbOwner.tf_old_prop_12:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.magic_damage_percent_beattack_reduce or 0, true, 1))

	-- self._ccbOwner.tf_new_title_1:setString("攻    击：")
--   	self._ccbOwner.tf_new_title_2:setString("生    命：")
--   	self._ccbOwner.tf_new_title_3:setString("物    防：")
--   	self._ccbOwner.tf_new_title_4:setString("法    防：")
--   	self._ccbOwner.tf_new_title_5:setString("攻    击：")
--   	self._ccbOwner.tf_new_title_6:setString("生    命：")
--   	self._ccbOwner.tf_new_title_7:setString("物    防：")
--   	self._ccbOwner.tf_new_title_8:setString("法    防：")
	self._ccbOwner.tf_new_prop_1:setString(string.format("+%d", (newGodSkillConfig.attack_value or 0)))
	self._ccbOwner.tf_new_prop_2:setString(string.format("+%d", (newGodSkillConfig.hp_value or 0)))
	self._ccbOwner.tf_new_prop_3:setString(string.format("+%d", (newGodSkillConfig.armor_physical or 0)))
	self._ccbOwner.tf_new_prop_4:setString(string.format("+%d", (newGodSkillConfig.armor_magic or 0)))
	self._ccbOwner.tf_new_prop_5:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.attack_percent or 0, true, 1))
	self._ccbOwner.tf_new_prop_6:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.hp_percent or 0, true, 1))
	self._ccbOwner.tf_new_prop_7:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.armor_physical_percent or 0, true, 1))
	self._ccbOwner.tf_new_prop_8:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.armor_magic_percent or 0, true, 1))
	self._ccbOwner.tf_new_prop_9:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.physical_damage_percent_attack or 0, true, 1))
	self._ccbOwner.tf_new_prop_10:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.magic_damage_percent_attack or 0, true, 1))
	self._ccbOwner.tf_new_prop_11:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.physical_damage_percent_beattack_reduce or 0, true, 1))
	self._ccbOwner.tf_new_prop_12:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.magic_damage_percent_beattack_reduce or 0, true, 1))


   	local value = self._soulNum / newGodSkillConfig.stunt_num
   	if value > 1 then
   		value = 1
   	end
    local progressStr = string.format("%d/%d", self._soulNum, newGodSkillConfig.stunt_num)
    self._progressStencil:setPositionX(value * self._progressWidth - self._progressWidth)
    self._ccbOwner.tf_progress:setString(progressStr)
    self._ccbOwner.node_tips:setVisible(value >= 1)
end

function QUIDialogSuperHeroGodSkill:_onTriggerGrade(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_grade) == false then return end
    app.sound:playSound("common_small")
    if not self._canGrade then
    	app.tip:floatTip("魂师碎片不足")
    	return
    end
    local actorId = self._actorId
    local gradeLevel = 0
    if not self._maxUpLevel or self._maxUpLevel == 0 then
	    local heroInfo = remote.herosUtil:getHeroByID(actorId)
	    gradeLevel = (heroInfo and heroInfo.godSkillGrade or 0) + 1
	else
		gradeLevel = self._maxUpLevel
	end

	self:enableTouchSwallowTop()
    app:getClient():godSkillgrade(actorId, gradeLevel, function(data)
		local heroInfo = remote.herosUtil:getHeroByID(actorId)
    	local valueTbl = {}
    	valueTbl[actorId] = heroInfo.godSkillGrade
	 	remote.activity:updateLocalDataByType(711, valueTbl)
        if self:safeCheck() then
        	if self._isSSR then
	        	self:_showLevelUpEffect(function()
	        		if self:safeCheck() then
	        			if self._isShowSuccessDialog then
				            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSuperHeroGradeSuccess",
				            	options = { actorId = self._actorId--[[, oldGodSkillConfig = self._oldGodSkillConfig, newGodSkillConfig = self._newGodSkillConfig]], callback = function()
				            		if self:safeCheck() then
				            			if self._isSSR and self._skillStar and self._actorId then
				            				self._skillStar:setGrade(self._actorId, true)
				            			end
				            		end
				            	end}},{isPopCurrentDialog = false})
			           	end
	           			self:updateHeroInfo()
	        		end
	        	end)
            else
	            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSuperHeroGradeSuccess",
	            	options = { actorId = self._actorId--[[, oldGodSkillConfig = self._oldGodSkillConfig, newGodSkillConfig = self._newGodSkillConfig]], callback = function()
	            		if self:safeCheck() then
	            			if self._isSSR and self._skillStar and self._actorId then
	            				self._skillStar:setGrade(self._actorId, true)
	            			end
	            		end
	            	end}},{isPopCurrentDialog = false})
       			self:updateHeroInfo()	
           	end
        end
    end, function()
    	self:disableTouchSwallowTop()
	end)
end

function QUIDialogSuperHeroGodSkill:_showLevelUpEffect(callback)
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	if heroInfo == nil or not self._isSSR then 
		print("QUIDialogSuperHeroGodSkill:_showLevelUpEffect(1)")
		if callback then
			callback()
		end
		return 
	end
	local godSkillRealLevel = heroInfo.godSkillGrade or 1

	local removeConfig = self._removeConfig -- 针对当前阶段没有点亮的情况
	local curConfigList = self._curConfigList
	if not curConfigList then 
		print("QUIDialogSuperHeroGodSkill:_showLevelUpEffect(2)")
		if callback then
			callback()
		end
		return 
	end

	local i = self._curPoint
	local maxIndex = #curConfigList

	local showPropFunc = function (index, _callback)
		if self:safeCheck() then
			print("[showPropFunc()]", index, _callback)
			self._ccbOwner.node_effect:removeAllChildren()
			local _oldConfig = curConfigList[index - 1] or removeConfig
			local _newConfig = curConfigList[index]
			if q.isEmpty(_newConfig) then
				if _callback then
					_callback()
				end
				return
			end
		    local propDic = {}
		    local propFields = QActorProp:getPropFields()
		    local propCount = 0
		    local tbl = {}
		    local notMergeTbl = {}
		    for key, value in pairs(_newConfig) do
		    	if propFields[key] then
	    			local addValue = value - (_oldConfig and _oldConfig[key] or 0)
	    			if addValue > 0 then
	    				propDic[key] = addValue
	    				local nameStr = propFields[key].uiMergeName or propFields[key].uiName or propFields[key].name
	    				if notMergeTbl[nameStr] then
            				propCount = propCount + 1
	    				elseif not tbl[nameStr] then
	    					if not tbl[nameStr] then
	    						tbl[nameStr] = {}
	    						table.insert(tbl[nameStr], addValue)
	    					end
	            			propCount = propCount + 1
	            		else
	            			local isFind = false
	            			for _, v in ipairs(tbl[nameStr]) do
	            				if v == addValue then
	            					isFind = true
	            					break
	            				end
	            			end
	            			if not isFind then
	            				notMergeTbl[nameStr] = true
	            				propCount = propCount + 1
	            			end
    					end
	            	end
		    	end
		    end
		    local distanceY = propCount * 20
		    local aniPropListView = QUIWidgetAnimationPlayer.new()
		    self._ccbOwner.node_effect:addChild(aniPropListView)
			aniPropListView:playAnimation("ccb/effects/propListView.ccbi", function(ccbOwner)
		        ccbOwner.node_all:setPositionY(distanceY)
	            ccbOwner.tf_title:setString("属性增长")
	            local showPropKeyList = {"attack_value", "hp_value", "armor_physical", "armor_magic", "attack_percent", "hp_percent", "armor_physical_percent", "armor_magic_percent", "physical_damage_percent_attack", "magic_damage_percent_attack", "physical_damage_percent_beattack_reduce", "magic_damage_percent_beattack_reduce"}
		        local index = 1
		        local tbl = {}
		        for _, key in ipairs(showPropKeyList) do
		            if propFields[key] and propDic[key] then
		                local node = ccbOwner["node_"..index]
		                if node then
		                    local nameStr = propFields[key].uiMergeName or propFields[key].uiName or propFields[key].name
		                    print(index, nameStr, key)
		                    local valueStr = ""
		                    if notMergeTbl[nameStr] then
		                    	nameStr = propFields[key].uiName or propFields[key].name
			                    valueStr = q.getFilteredNumberToString(propDic[key], propFields[key].isPercent, 2)
			                    ccbOwner["tf_name"..index]:setString(nameStr..": +"..valueStr)
			                    node:setVisible(true)
			                    index = index + 1
			                elseif not tbl[nameStr] then
		                		tbl[nameStr] = true
			                    valueStr = q.getFilteredNumberToString(propDic[key], propFields[key].isPercent, 2)
			                    ccbOwner["tf_name"..index]:setString(nameStr..": +"..valueStr)
			                    node:setVisible(true)
			                    index = index + 1
			                end
		                else
		                    break
		                end
		            end
		      	end
		        
		        while true do
		            local node = ccbOwner["node_"..index]
		            if node then
		                node:setVisible(false)
		                index = index + 1
		            else
		                break
		            end
		        end
		    end, function()
		        if aniPropListView ~= nil then
		            aniPropListView:disappear()
		            aniPropListView = nil
		        end
		    end)

		end
	end
	local willFunc = function (index, _callback)
		if self:safeCheck() then
			print("[willFunc()]", index, _callback)
			local node = self._ccbOwner["node_small_level_"..index]
			if node then
				if index < maxIndex then
					local path = QResPath("god_skill_next_activated")
					if path and path ~= "" then
						local sprite = CCSprite:create(path)
						node:addChild(sprite)
					end
				end
				
				if _callback then
					_callback()
				end
			end
		end
	end

	local activateFunc = function (index, _callback)
		if self:safeCheck() then
			print("[activateFunc()]", index, _callback)
			local node = self._ccbOwner["node_small_level_"..index]
			local line = self._ccbOwner["sp_line_"..index]
			if line then
				line:setVisible(true)
			end
			if node then
				if index == maxIndex then
					print("activateFunc end")
					if callback then
						callback()
					end
				else
					local path = QResPath("god_skill_activated")
					if path and path ~= "" then
						local sprite = CCSprite:create(path)
						node:addChild(sprite)
					end
				end
			end
		end
	end

	local activateEffectFunc = function (index, _callback)
		if self:safeCheck() then
			print("[activateEffectFunc()]", index, _callback)
			local node = self._ccbOwner["node_small_level_"..index]
			if node then
				if index ~= maxIndex then
					node:removeAllChildren()
					local fcaEffect = QUIWidgetFcaAnimation.new("fca/tx_shenjibaodian_effect", "res")
					fcaEffect:playAnimation("animation", false)
					fcaEffect:setEndCallback(function()
						print("activateEffectFunc effect end")
						fcaEffect:removeFromParent()

						willFunc(index + 1, _callback)
					end)
					node:addChild(fcaEffect)
				else
					willFunc(index + 1, _callback)
				end
			end
		end
	end
	
	self._func = function()
		print("[func()]")
		scheduler.performWithDelayGlobal(function()
			i = i + 1
			if curConfigList[i].level > godSkillRealLevel then
				print("func end ! ", i)
				if callback then
					callback()
				end
			elseif curConfigList[i].level == godSkillRealLevel and i == maxIndex then
				print("func end this is skill ! ", i)
				if callback then
					callback()
				end
			else
				activateEffectFunc(i, handler(self, self._func))
				showPropFunc(i)
				scheduler.performWithDelayGlobal(function()
					activateFunc(i)
					self:_updatePropInfo(curConfigList[i].level)
				end, 0.25)
			end
		end, 0.75)
		-- ps 这里的间隔0.75秒不能随意修改，太短的间隔，会让属性展示（飘绿字）被冲的速度变快，导致玩家看不清
	end
	self._func()
end

function QUIDialogSuperHeroGodSkill:_onTriggerPlus(event)
	if q.buttonEventShadow(event,self._ccbOwner.node_plus) == false then return end
    app.sound:playSound("common_increase")
    local config = db:getGradeByHeroActorLevel(self._heroInfo.actorId, 0)
    QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, config.soul_gem)
end

function QUIDialogSuperHeroGodSkill:_onTriggerSkill(event)
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGodSkill", 
        options = {actorId = self._actorId}},{isPopCurrentDialog = false})
end

function QUIDialogSuperHeroGodSkill:_backClickHandler()
	self:_onTriggerClose()
end 

function QUIDialogSuperHeroGodSkill:_onTriggerClose(e)
	if q.buttonEventShadow(e,self._ccbOwner.btn_close) == false then return end
	if e ~= nil then
    	app.sound:playSound("common_cancel")
	end
	self:playEffectOut()
end

function QUIDialogSuperHeroGodSkill:_onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
    elseif event.name == "began" then
        self._startY = event.y
        self._pageY = self._oldContent:getPositionY()
    elseif event.name == "moved" then
        local offsetY = self._pageY + event.y - self._startY
        if offsetY < self._oldPrginalPosition.y then
            offsetY = self._oldPrginalPosition.y
        elseif offsetY > (self._totalHeight - self._oldHeight + self._oldPrginalPosition.y) then
            offsetY = (self._totalHeight - self._oldHeight + self._oldPrginalPosition.y)
        else
        end
        self._oldContent:setPositionY(offsetY)
        self._newContent:setPositionY(offsetY)
        self._nowContent:setPositionY(offsetY)
    elseif event.name == "ended" then
    end
end

return QUIDialogSuperHeroGodSkill
-- @Author: zhouxiaoshu
-- @Date:   2019-08-07 16:04:56
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-04-07 16:08:00

local QUIDialog = import(".QUIDialog")
local QUIDialogSuperHeroGradeSuccess = class("QUIDialogSuperHeroGradeSuccess",QUIDialog)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetHeroHeadVibrate = import("..widgets.QUIWidgetHeroHeadVibrate")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QColorLabel = import("...utils.QColorLabel")

QUIDialogSuperHeroGradeSuccess.GRAY_COLOR = ccc3(253, 234, 183)
QUIDialogSuperHeroGradeSuccess.LIGHT_COLOR = ccc3(0, 197, 0)
QUIDialogSuperHeroGradeSuccess.EVENT_GRADE_SUCC = "EVENT_GRADE_SUCC"

function QUIDialogSuperHeroGradeSuccess:ctor(options)
	local ccbFile = "ccb/Battle_Dialog_shengjie.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogSuperHeroGradeSuccess.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page.topBar:setAllSound(false)

	q.setButtonEnableShadow(self._ccbOwner.btn_next)

    self._isEnd = false
	self._actorId = options.actorId
	self._callback = options.callback
    self._ccbOwner.sp_normal:setVisible(true)
    self:changeActorBg()

    local aptitudeInfo = db:getActorSABC(self._actorId)
    if aptitudeInfo and aptitudeInfo.qc == "SS+" then
		self._isSSRHero = true
	else
		self._isSSRHero = false
	end

    local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	local godSkillGrade = heroInfo.godSkillGrade or 2
	local godSkillTbl = db:getGodSkillById(self._actorId)
	local oldGodSkillConfig = options.oldGodSkillConfig or godSkillTbl[godSkillGrade-1] or {}
	local newGodSkillConfig = options.newGodSkillConfig or godSkillTbl[godSkillGrade]
    		

    self._ccbOwner.tf_old_prop_1:setString(self:dealNum(oldGodSkillConfig.attack_value or 0))
	self._ccbOwner.tf_old_prop_2:setString(self:dealNum(oldGodSkillConfig.hp_value or 0))
	self._ccbOwner.tf_old_prop_3:setString(self:dealNum(oldGodSkillConfig.armor_physical or 0))
	self._ccbOwner.tf_old_prop_4:setString(self:dealNum(oldGodSkillConfig.armor_magic or 0))

	self._ccbOwner.tf_old_prop_5:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.attack_percent or 0, true, 1))
	self._ccbOwner.tf_old_prop_6:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.hp_percent or 0, true, 1))
	self._ccbOwner.tf_old_prop_7:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.armor_physical_percent or 0, true, 1))
	self._ccbOwner.tf_old_prop_8:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.armor_magic_percent or 0, true, 1))
	
	if self._isSSRHero then
		self._ccbOwner.tf_old_prop_9:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.physical_damage_percent_attack or 0, true, 1))
		self._ccbOwner.tf_old_prop_10:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.magic_damage_percent_attack or 0, true, 1))
		self._ccbOwner.tf_old_prop_11:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.physical_damage_percent_beattack_reduce or 0, true, 1))
		self._ccbOwner.tf_old_prop_12:setString("+"..q.getFilteredNumberToString(oldGodSkillConfig.magic_damage_percent_beattack_reduce or 0, true, 1))
	end


	self._ccbOwner.tf_new_prop_1:setString(self:dealNum(newGodSkillConfig.attack_value or 0))
	self._ccbOwner.tf_new_prop_2:setString(self:dealNum(newGodSkillConfig.hp_value or 0))
	self._ccbOwner.tf_new_prop_3:setString(self:dealNum(newGodSkillConfig.armor_physical or 0))
	self._ccbOwner.tf_new_prop_4:setString(self:dealNum(newGodSkillConfig.armor_magic or 0))

	self._ccbOwner.tf_new_prop_5:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.attack_percent or 0, true, 1))
	self._ccbOwner.tf_new_prop_6:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.hp_percent or 0, true, 1))
	self._ccbOwner.tf_new_prop_7:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.armor_physical_percent or 0, true, 1))
	self._ccbOwner.tf_new_prop_8:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.armor_magic_percent or 0, true, 1))
	
	if self._isSSRHero then
		self._ccbOwner.tf_new_prop_9:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.physical_damage_percent_attack or 0, true, 1))
		self._ccbOwner.tf_new_prop_10:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.magic_damage_percent_attack or 0, true, 1))
		self._ccbOwner.tf_new_prop_11:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.physical_damage_percent_beattack_reduce or 0, true, 1))
		self._ccbOwner.tf_new_prop_12:setString("+"..q.getFilteredNumberToString(newGodSkillConfig.magic_damage_percent_beattack_reduce or 0, true, 1))
	end

    local skillIds = string.split(oldGodSkillConfig.skill_id, ";")
    local skillId = skillIds[1]
	local skillConfig = db:getSkillByID(skillId)
	local oldIcon = QUIWidgetHeroSkillBox.new()
    oldIcon:setLock(false)
    oldIcon:setSkillID(skillId)
    oldIcon:setGodSkillShowLevel(godSkillGrade-1, self._actorId)
    self._ccbOwner.old_head:addChild(oldIcon)
    self._ccbOwner.oldName:setString(skillConfig.name)

    local skillIds = string.split(newGodSkillConfig.skill_id, ";")
    local skillId = skillIds[1]
	local skillConfig = db:getSkillByID(skillId)
	local newIcon = QUIWidgetHeroSkillBox.new()
    newIcon:setLock(false)
    newIcon:setSkillID(skillId)
    newIcon:setGodSkillShowLevel(godSkillGrade, self._actorId)
	self._ccbOwner.new_head:addChild(newIcon)
    self._ccbOwner.newName:setString(skillConfig.name)

	local skillConfig = db:getSkillByID(skillId)
    self._ccbOwner.tf_skill_name:setString("神技："..skillConfig.name)
    local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
    skillDesc = QColorLabel.removeColorSign(skillDesc)
    self._ccbOwner.tf_skill_desc:setString(skillDesc)

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))
    self._animationStageIsEnd = true

    -- set hero avatar
    if self._actorId > 0 then
    	local db = db
		local info = db:getCharacterByID(tostring(self._actorId))
		local dialogDisplay = db:getDialogDisplay()[tostring(self._actorId)]
		local card = ""
		local x = 0
		local y = 0
		local scale = 1
		local rotation = 0
		local turn = 1

		if heroInfo and heroInfo.skinId and heroInfo.skinId > 0 then
			local skinConfig = remote.heroSkin:getHeroSkinBySkinId(tostring(self._actorId), heroInfo.skinId)
	        if skinConfig.fightEnd_card then
	        	card = skinConfig.fightEnd_card
				if skinConfig.fightEnd_display then
					local skinDisplaySetConfig = remote.heroSkin:getSkinDisplaySetConfigById(skinConfig.fightEnd_display)
					x = skinDisplaySetConfig.x or 0
					y = skinDisplaySetConfig.y or 0
					scale = skinDisplaySetConfig.scale or 1
					rotation = skinDisplaySetConfig.rotation or 0
					turn = skinDisplaySetConfig.isturn or 1
				end
	        end
		end

		if card == "" and dialogDisplay and dialogDisplay.break_card then
			card = dialogDisplay.break_card
			x = dialogDisplay.break_x
			y = dialogDisplay.break_y
			scale = dialogDisplay.break_scale
			rotation = dialogDisplay.break_rotation
			turn = dialogDisplay.break_isturn
		end
		if card == "" then
			card = "icon/hero_card/art_snts.png"
		end

		local frame = QSpriteFrameByPath(card)
		if frame then
			self._ccbOwner.sp_bg_mvp:setDisplayFrame(frame)
			self._ccbOwner.sp_bg_mvp:setPosition(x, y)
			self._ccbOwner.sp_bg_mvp:setScaleX(scale*turn)
			self._ccbOwner.sp_bg_mvp:setScaleY(scale)
			self._ccbOwner.sp_bg_mvp:setRotation(rotation)
		else
			assert(false, "<<<"..card..">>>not exist!")
		end
		self._ccbOwner.label_name_title:setString(info.title or "")
		self._ccbOwner.label_name:setString(info.name or "")
	end

    app.sound:playSound("hero_grow_up")
end

function QUIDialogSuperHeroGradeSuccess:dealNum(value)
	local num, unit = q.convertLargerNumber(value)
	return num..unit
end

function QUIDialogSuperHeroGradeSuccess:changeActorBg()
	local actorInfo = db:getActorSABC(self._actorId)
	local texture
    if actorInfo.lower == "b" then
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj1.jpg")
	elseif actorInfo.lower == "s" then
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj3.jpg")
	elseif actorInfo.lower == "ss" or self._isSSRHero then
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj4.jpg")
    else
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj2.jpg")
    end
    self._ccbOwner.bj:setTexture(texture)
end

function QUIDialogSuperHeroGradeSuccess:viewWillDisappear()
	QUIDialogSuperHeroGradeSuccess.super.viewWillDisappear(self)
	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	page.topBar:setAllSound(true)

	if self._schedulerHandler ~= nil then
		scheduler.unscheduleGlobal(self._schedulerHandler)
		self._schedulerHandler = nil
	end
end

function QUIDialogSuperHeroGradeSuccess:viewAnimationEndHandler(name)
	self._animationStageIsEnd = true
	self._animationStage = name
	if self._isSSRHero and name == "4" then
		self._isEnd = true
	elseif not self._isSSRHero and name == "3" then
		self._isEnd = true
	end
end

-------event--------------
function QUIDialogSuperHeroGradeSuccess:_onTriggerClose()
	if self._isEnd == false then return end
	self:playEffectOut()
end

function QUIDialogSuperHeroGradeSuccess:_backClickHandler()
	if self._isEnd then
		self:_onTriggerClose()
		return
	end
	if self._animationStageIsEnd then
		if self._animationStage == "1" then
			self._animationStageIsEnd = false
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "2" then
			self._animationStageIsEnd = false
			if self._isSSRHero then
				self._ccbOwner.node_btn_next:setVisible(false)
			else
				self._ccbOwner.node_btn_next:setVisible(true)
			end
			self._animationManager:runAnimationsForSequenceNamed("3")
		elseif self._animationStage == "3" then
			if self._isSSRHero then
				self._animationStageIsEnd = false
				self._animationManager:runAnimationsForSequenceNamed("4")
				self._ccbOwner.node_btn_next:setVisible(true)
			else
				self:_onTriggerClose()
			end
		elseif self._animationStage == "4" then
			self:_onTriggerClose()
		end
	end
end

function QUIDialogSuperHeroGradeSuccess:viewAnimationOutHandler()
	local callback = self._callback
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if callback ~= nil then
    	callback()
    end

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.class.__cname == "QUIPageMainMenu" then
    	page:checkGuiad()
	end
end

return QUIDialogSuperHeroGradeSuccess
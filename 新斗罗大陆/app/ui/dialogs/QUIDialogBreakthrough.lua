--
-- Author: Your Name
-- Date: 2014-06-18 17:55:35
--
local QUIDialog = import(".QUIDialog")
local QUIDialogBreakthrough = class("QUIDialogBreakthrough", QUIDialog)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QHeroModel = import("...models.QHeroModel")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QColorLabel = import("...utils.QColorLabel")

function QUIDialogBreakthrough:ctor(options)
	-- local ccbFile = "ccb/Dialog_HeroBreakthroughSuccess.ccbi";
	local ccbFile = "ccb/Battle_Dialog_tupo.ccbi"

	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 	callback = handler(self, QUIDialogBreakthrough._onTriggerClose)},
	}
	QUIDialogBreakthrough.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示
    CalculateUIBgSize(self._ccbOwner.bj)

	self._actorId = options.actorId
	self._oldHeroInfo = options.oldHeroInfo
	self._isEnd = false
	app.sound:playSound("hero_breakthrough")
    -- self:removeAll()
	self._ccbOwner.node_status2:setVisible(false)
	-- self._ccbOwner.btn_close:setVisible(false)

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))
    q.setButtonEnableShadow(self._ccbOwner.btn_data)

    self._heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    if self._heroInfo ~= nil then
    	local oldHeroInfo = self._oldHeroInfo
    	if q.isEmpty(oldHeroInfo) then
    		oldHeroInfo = remote.herosUtil:getOldHeroById(self._actorId)
    	end

		local slotId = QStaticDatabase:sharedDatabase():getBreakthroughHeroByHeroActorLevel(self._actorId, self._heroInfo.breakthrough).skill_id_3
		if slotId then
			for k, v in ipairs(oldHeroInfo.slots) do
				if v.slotId == slotId then
					table.remove(oldHeroInfo.slots, k)
					break
				end
			end
		end

    	local oldModel = QHeroModel.new(oldHeroInfo)
    	local newModel = QHeroModel.new(self._heroInfo)
    	
    	local oldBattleForce = oldModel:getBattleForce()
    	local newBattleForce = newModel:getBattleForce()
    	self:dealNum(oldBattleForce, newBattleForce, "battleforce")

    	local oldHpValue = math.floor(oldModel:getMaxHp())
    	local newHpValue = math.floor(newModel:getMaxHp())
    	self:dealNum(oldHpValue, newHpValue, "hp")

    	local oldAttackValue = math.floor(oldModel:getMaxAttack())
    	local newAttackValue = math.floor(newModel:getMaxAttack())
    	self:dealNum(oldAttackValue, newAttackValue, "attack")

		local oldHead = QUIWidgetHeroHead.new()
		self._ccbOwner.old_head:addChild(oldHead)
		oldHead:setHeroSkinId(oldHeroInfo.skinId)
		oldHead:setHero(self._actorId)
		oldHead:setLevel(oldHeroInfo.level)
		oldHead:setStar(oldHeroInfo.grade)
		oldHead:setBreakthrough(oldHeroInfo.breakthrough)
        oldHead:setGodSkillShowLevel(oldHeroInfo.godSkillGrade)

		self._ccbOwner.tf_skill_name:setString("")
		self._ccbOwner.tf_skill_desc:setString("")
		self._ccbOwner.node_skill:setCascadeOpacityEnabled(true)
		self._ccbOwner.node_skill:setOpacity(0)
		
		-- Set hero name
		local oldheroName = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId).name
		local breakthroughLevel = 0
		local color = nil
		breakthroughLevel,color = remote.herosUtil:getBreakThrough(oldHeroInfo.breakthrough)
		if color ~= nil then
			self._ccbOwner.oldName:setColor(BREAKTHROUGH_COLOR_LIGHT[color])
		end
		if breakthroughLevel > 0 then
			oldheroName = oldheroName .. " + " .. breakthroughLevel
		end
		self._ccbOwner.oldName:setString(oldheroName)


		local newheroName = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId).name
		breakthroughLevel,color = remote.herosUtil:getBreakThrough(self._heroInfo.breakthrough)
		local newHead = QUIWidgetHeroHead.new()
		newHead:setHeroSkinId(self._heroInfo.skinId)
		newHead:setHero(self._actorId)
		newHead:setLevel(self._heroInfo.level)
		newHead:setStar(self._heroInfo.grade)
        newHead:setGodSkillShowLevel(self._heroInfo.godSkillGrade)

		--xurui: 突破时添加钻石特效
		self._newLevel = breakthroughLevel
		self._newName = newheroName 
		self._ccbOwner.newName:setString("")
		if color ~= nil then
			self._ccbOwner.newName:setColor(BREAKTHROUGH_COLOR_LIGHT[color])
		end

		if breakthroughLevel == 0 then
			newHead:setBreakthrough(oldHeroInfo.breakthrough)
			self._ccbOwner.new_head:addChild(newHead)
		else
			self._newName = self._newName .. " + " .. breakthroughLevel
			self:setItemBoxEffect(newHead, color)
			-- self._ccbOwner.new_head:addChild(newHead)
		end

		self._isSaying = true
		self._itemEffectScheduler = scheduler.performWithDelayGlobal(function()
				self:wordTypewriterEffect(self._ccbOwner.newName, self._newName)
				if breakthroughLevel == 0 then
					self:itemFrameEffect(self._heroInfo.breakthrough, color, newHead)
				end
			end, 1.0)
    end

     -- set hero avatar
    if self._actorId > 0 then
    	local db = QStaticDatabase:sharedDatabase()
		local info = db:getCharacterByID(tostring(self._actorId))
		local dialogDisplay = db:getDialogDisplay()[tostring(self._actorId)]
		local card = ""
		local x = 0
		local y = 0
		local scale = 1
		local rotation = 0
		local turn = 1

		if self._heroInfo and self._heroInfo.skinId and self._heroInfo.skinId > 0 then
			local skinConfig = remote.heroSkin:getHeroSkinBySkinId(tostring(self._actorId), self._heroInfo.skinId)
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
		self:changeActorBg(self._actorId)
	end
    
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_HERO_BREAKTHROUGH})  
end

function QUIDialogBreakthrough:changeActorBg(actorId)
	local actorInfo = QStaticDatabase:sharedDatabase():getActorSABC(actorId)
	local texture
    if actorInfo.lower == "b" then
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj1.jpg")
	elseif actorInfo.lower == "s" then
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj3.jpg")
	elseif actorInfo.lower == "ss" then
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj4.jpg")
    else
    	texture = CCTextureCache:sharedTextureCache():addImage("res/map/battle_bj2.jpg")
    end
    self._ccbOwner.bj:setTexture(texture)
end

function QUIDialogBreakthrough:viewDidAppear()
	QUIDialogBreakthrough.super.viewDidAppear(self)
end

function QUIDialogBreakthrough:viewWillDisappear()
	QUIDialogBreakthrough.super.viewWillDisappear(self)
	if self._itemEffect ~= nil then
		self._itemEffect:disappear()
		self._itemEffect = nil
	end
end

function QUIDialogBreakthrough:dealNum(oldValue, newValue, str)
	local oldNum, oldWord = q.convertLargerNumber(oldValue)
	local newNum, newWord = q.convertLargerNumber(newValue)

	self._ccbOwner["tf_"..str.."_up"]:setString("")
	self._ccbOwner["sp_"..str]:setVisible(true)
	self._ccbOwner["tf_"..str.."_old"]:setString(oldNum..oldWord)
	self._ccbOwner["tf_"..str.."_new"]:setString(newNum..newWord)
end

function QUIDialogBreakthrough:setItemBoxEffect(newHead, color)
	if self._newLevel == 0 then 
		return 
	end
	self._itemEffect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.new_head:addChild(self._itemEffect)
	local ccbFile = "ccb/effects/HeroHeadzuan"..self._newLevel.."_"..self._newLevel..".ccbi"

	local path = QResPath("equipment_evolution_icon_"..color)
	local displayFrame
	if path then
		displayFrame = QSpriteFrameByPath(path)
	end
	self._itemEffect:playAnimation(ccbFile, function()
			self._itemEffect._ccbOwner.node_head:addChild(newHead)

			local index = 1 
			if displayFrame then
				while self._itemEffect._ccbOwner["sp_icon_"..index] do
					self._itemEffect._ccbOwner["sp_icon_"..index]:setDisplayFrame(displayFrame)
					index = index + 1
				end
	    	end

			for i=1, self._newLevel, 1 do
				self:getScheduler().performWithDelayGlobal(function ()
					app.sound:playSound("common_star")
				end, 0.3*(i-1)+1.3)
			end
		end, function()
		end, false)
end

function QUIDialogBreakthrough:itemFrameEffect(breaklevel, color, itemBox)
	local itemEffect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.new_head:addChild(itemEffect)
	local ccbFile = "ccb/effects/kuang_small.ccbi"
	itemEffect:playAnimation(ccbFile, function()
			itemEffect._ccbOwner.node_hero_frame:setVisible(true)
			itemEffect._ccbOwner["hero_effect_"..color]:setVisible(true)

			self:getScheduler().performWithDelayGlobal(function()
				itemBox:setBreakthrough(breaklevel)
				app.sound:playSound("common_star")
			end, 1/6)
		end, function ()
		end)
end

function QUIDialogBreakthrough:animationEndHandler(name)
	self._animationStage = name
end

function QUIDialogBreakthrough:skillHandler()
	self._animationStage = "3"
	local heroBreakthroughConfig = QStaticDatabase:sharedDatabase():getBreakthroughHeroByHeroActorLevel(self._actorId, self._heroInfo.breakthrough)
	if heroBreakthroughConfig and heroBreakthroughConfig.skill_id_3 ~= nil and heroBreakthroughConfig.skill_id_3 ~= "" then
		self._skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(self._actorId, heroBreakthroughConfig.skill_id_3)
		local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(self._skillId)
		if skillConfig ~= nil then
			self._animationManager:runAnimationsForSequenceNamed("3")
			self._ccbOwner.node_status2:setVisible(true)
			self:setIconPath(skillConfig.icon)
			local actionArrayIn = CCArray:create()
			actionArrayIn:addObject(CCFadeIn:create(0.5))
			actionArrayIn:addObject(CCCallFunc:create(function ()
			  	self._actionHandler = nil
			  	self:wordTypewriterEffect(self._ccbOwner.tf_skill_name, "新魂技："..skillConfig.name, function ()
			  		local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
			        skillDesc = QColorLabel.removeColorSign(skillDesc)
			        
			  		self:wordTypewriterEffect(self._ccbOwner.tf_skill_desc, skillDesc, function ()
						self._isEnd = true
			  		end)
			  	end)
			end))
			local ccsequence = CCSequence:create(actionArrayIn)
			self._actionHandler = self._ccbOwner.node_skill:runAction(ccsequence)
			return
		else
			self._isEnd = true
			self:_onTriggerClose()
		end
	else
		self._isEnd = true
		self:_onTriggerClose()
	end
end

function QUIDialogBreakthrough:wordTypewriterEffect(tf, word, callback)
	if tf == nil or word == nil then
		if callback ~= nil then callback() end
		return false
	end
	if self._typewriterCallback ~= nil then
		if callback ~= nil then callback() end
		return false
	end
	self._typewriterTF = tf
	self._typewriterWord = word
	self._typewriterCallback = callback

	self._sayPosition = 1
	self._typewriterSayWord = ""
	self._typewriterTF:setString(self._typewriterSayWord)
	self._delayTime = TUTORIAL_ONEWORD_TIME * 0.3
	self._isExist = true

	if self._typewriterHandler == nil then
		self._typewriterHandler = function ()
			if self._isExist ~= true then return end
			local c = string.sub(self._typewriterWord,self._sayPosition,self._sayPosition)
	        local b = string.byte(c)
	        local str = c
	        if b and b > 128 then
	           str = string.sub(self._typewriterWord,self._sayPosition,self._sayPosition + 2)
	           self._sayPosition = self._sayPosition + 2
	        end
            self._typewriterSayWord =  self._typewriterSayWord .. str
			self._typewriterTF:setString(self._typewriterSayWord)
        	self._sayPosition = self._sayPosition + 1

        	if self._sayPosition <= #self._typewriterWord then
		        self._typewriterTimeHandler = scheduler.performWithDelayGlobal(self._typewriterHandler,self._delayTime)
		    else
		        if self._typewriterCallback ~= nil then
		        	local callBack = self._typewriterCallback
		            self._typewriterCallback = nil
		            callBack()
		        end
		        self._typewriterTimeHandler = nil
		    end
		end
	end
	self._typewriterHandler()
end

function QUIDialogBreakthrough:setIconPath(path)
	self._ccbOwner.node_icon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIDialogBreakthrough:viewWillDisappear()
	QUIDialogBreakthrough.super.viewWillDisappear(self)
    self._isExist = false
    if self._actionHandler ~= nil then
    	self._ccbOwner.node_skill:stopAction(self._actionHandler)
    	self._actionHandler = nil
    end
    if self._typewriterTimeHandler ~= nil then
    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
    	self._typewriterTimeHandler = nil
    end

	if self._itemEffectScheduler ~= nil then
		scheduler.unscheduleGlobal(self._itemEffectScheduler)
		self._itemEffectScheduler = nil
	end
end

-------event--------------
function QUIDialogBreakthrough:_onTriggerClose()
	if self._isEnd == true then
		self:playEffectOut()
	else
		if self._animationStage == nil then
			self._animationStage = "1"
			self._animationManager:runAnimationsForSequenceNamed("2")
		elseif self._animationStage == "2" or self._animationStage == "1" then
			self:skillHandler()
		else
		    if self._typewriterTimeHandler ~= nil then
		    	scheduler.unscheduleGlobal(self._typewriterTimeHandler)
		    	self._typewriterTimeHandler = nil
		    end
		    if self._actionHandler ~= nil then
		    	self._ccbOwner.node_skill:stopAction(self._actionHandler)
		    	self._actionHandler = nil
		    end
		    local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
			local heroBreakthroughConfig = QStaticDatabase:sharedDatabase():getBreakthroughHeroByHeroActorLevel(self._actorId, heroInfo.breakthrough)
			if heroBreakthroughConfig and heroBreakthroughConfig.skill_id_3 ~= nil and heroBreakthroughConfig.skill_id_3 ~= "" then
				self._skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(self._actorId, heroBreakthroughConfig.skill_id_3)
				local skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(self._skillId)
				self._ccbOwner.node_skill:setOpacity(255)
				self._ccbOwner.tf_skill_name:setString("新魂技："..skillConfig.name)

			  	local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
		        skillDesc = QColorLabel.removeColorSign(skillDesc)
				self._ccbOwner.tf_skill_desc:setString(skillDesc)
			end

			self._ccbOwner.newName:setString(self._newName or "")

			self:getScheduler().performWithDelayGlobal(function()
					self._isEnd = true
				end, 1)
		end
	end
end

function QUIDialogBreakthrough:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogBreakthrough:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogBreakthrough
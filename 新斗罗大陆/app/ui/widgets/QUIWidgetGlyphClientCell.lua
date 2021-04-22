--
-- Author: Kumo.Wang
-- Date: Wed Apr 27 18:37:27 2016
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGlyphClientCell = class("QUIWidgetGlyphClientCell", QUIWidget)

local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRemote = import("...models.QRemote")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QFullCircleUiMask = import("..battle.QFullCircleUiMask")

QUIWidgetGlyphClientCell.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetGlyphClientCell:ctor(options)
	local ccbFile = "ccb/Widget_DiaoWen_client2.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetGlyphClientCell._onTriggerClick)}
	}

	QUIWidgetGlyphClientCell.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self.isAnimation = true --是否动画显示

	self._isUnLock = true
	self._isOnEnter = false
    self._isNeedShowEffect = false
    self._enabled = true

	self._scale = self._ccbOwner.node_symbol:getScale()

	self._ccbOwner.node_selected:setVisible(false)
	self._ccbOwner.tf_level:setString("")
	self._ccbOwner.tf_name:setString("")
	self._ccbOwner.tf_unlock_text_1:setString("")
	self._ccbOwner.tf_unlock_text_2:setString("")

	self._animationStage = "1"
	self._animationManager = tolua.cast(self:getCCBView():getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))
end

function QUIWidgetGlyphClientCell:onEnter()
	self._isOnEnter = true
	if self._isNeedShowEffect then
		self._isNeedShowEffect = false
		if not self._animationStage or self._animationStage == "1" then
			self._animationManager:runAnimationsForSequenceNamed("2")
			self._animationStage = "2"
		end
	end
end

function QUIWidgetGlyphClientCell:onExit()
	self._isOnEnter = false
	self._isNeedShowEffect = false

	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
end

function QUIWidgetGlyphClientCell:viewAnimationEndHandler(name)
	self._animationStage = name
	if name == "2" then
		self._animationManager:runAnimationsForSequenceNamed("1")
		self._animationStage = "1"
	end
end

function QUIWidgetGlyphClientCell:showEffect()
	if self._isOnEnter then
		if not self._animationStage or self._animationStage == "1" then
			self._animationManager:runAnimationsForSequenceNamed("2")
			self._animationStage = "2"
		end
	else
		self._isNeedShowEffect = true
	end
end

function QUIWidgetGlyphClientCell:setSkill( id, level, gradeLevel, isFirstLockSkill )
	self._skillId = id
	self._skillLevel = level
	self._gradeLevel = gradeLevel

	local skillConfig = QStaticDatabase.sharedDatabase():getGlyphSkillByIdAndLevel(id, level or 1)
	local texture = CCTextureCache:sharedTextureCache():addImage(skillConfig.icon)
    local sp = CCSprite:createWithTexture(texture)
    local size = self._ccbOwner.node_mask:getContentSize()
    local ccclippingNode = QFullCircleUiMask.new()
    ccclippingNode:setRadius(size.width/2)
    ccclippingNode:addChild(sp)
    self._ccbOwner.node_icon:addChild(ccclippingNode)

	if (not self._skillLevel or self._skillLevel == 0) and self._gradeLevel then
		self._isUnLock = true
		self._ccbOwner.node_level:setVisible(false)
		self._ccbOwner.tf_level:setString("")
		if isFirstLockSkill then
			if not self._tf_name_shadow then
				self._tf_name_shadow = setShadow5(self._ccbOwner.tf_name)
			end
			self._ccbOwner.tf_name:setString(skillConfig.glyph_name)
			local unlockLevel = gradeLevel + 1
			if not self._tf_unlock_text_shadow_1 then
				self._tf_unlock_text_shadow_1 = setShadow5(self._ccbOwner.tf_unlock_text_1)
			end
			if not self._tf_unlock_text_shadow_2 then
				self._tf_unlock_text_shadow_2 = setShadow5(self._ccbOwner.tf_unlock_text_2)
			end
			self._ccbOwner.tf_unlock_text_1:setString( self:_getTextByUnlockLevel(unlockLevel) )
			self._ccbOwner.tf_unlock_text_2:setString( "解锁" )
			self._ccbOwner.node_name:setVisible(true)
		else
			self._ccbOwner.tf_name:setString("")
			self._ccbOwner.tf_unlock_text_1:setString("")
			self._ccbOwner.tf_unlock_text_2:setString("")
			self._ccbOwner.node_name:setVisible(false)
		end
	else
		self._isUnLock = false
		self._ccbOwner.tf_unlock_text_1:setString("")
		self._ccbOwner.tf_unlock_text_2:setString("")
		self._ccbOwner.node_level:setVisible(true)
		self._ccbOwner.node_name:setVisible(true)
		self._ccbOwner.tf_level:setString(level)
		if not self._tf_name_shadow then
			self._tf_name_shadow = setShadow5(self._ccbOwner.tf_name)
		end
		self._ccbOwner.tf_name:setString(skillConfig.glyph_name)
	end
end

function QUIWidgetGlyphClientCell:_getTextByUnlockLevel( unlockLevel )
	if unlockLevel < 6 then
		return unlockLevel.."星"
	elseif unlockLevel < 11 then
		return (unlockLevel - 5).."月亮"
	elseif unlockLevel < 16 then
		return (unlockLevel - 10).."太阳"
	else
		return unlockLevel.."星"
	end
end

function QUIWidgetGlyphClientCell:getSkillId()
	return self._skillId
end

function QUIWidgetGlyphClientCell:makeNameFromNormalToGray()
	self._ccbOwner.tf_name:setColor(ccc3(255,255,255))
end

function QUIWidgetGlyphClientCell:makeNameFromGrayToNormal()
	self._ccbOwner.tf_name:setColor(ccc3(252,249,0))
end

function QUIWidgetGlyphClientCell:updateSkillLevel( level )
	if not level or level < 1 then return end
	self._skillLevel = level
	local skillConfig = QStaticDatabase.sharedDatabase():getGlyphSkillByIdAndLevel(self._skillId, level)
	self._isUnLock = false
	self._ccbOwner.tf_unlock_text_1:setString("")
	self._ccbOwner.tf_unlock_text_2:setString("")
	self._ccbOwner.node_level:setVisible(true)
	self._ccbOwner.tf_level:setString(level)
	if not self._tf_name_shadow then
		self._tf_name_shadow = setShadow5(self._ccbOwner.tf_name)
	end
	self._ccbOwner.tf_name:setString(skillConfig.glyph_name)
end

function QUIWidgetGlyphClientCell:setLevelVisible( boo )
	self._ccbOwner.node_level:setVisible( boo )
end

function QUIWidgetGlyphClientCell:setNameVisible( boo )
	self._ccbOwner.node_name:setVisible( boo )
end

function QUIWidgetGlyphClientCell:setEnabled( boo )
	self._enabled = boo
end

function QUIWidgetGlyphClientCell:_onTriggerClick( ... )
	if self._isUnLock then return end
	if not self._enabled then return end
	
	local args = { ... }
	if args[1] == "1" then
		--Down
		if self._scheduler then
			scheduler.unscheduleGlobal(self._scheduler)
			self._scheduler = nil
			self._ccbOwner.node_symbol:setScale( self._scale )
		end

		self._ccbOwner.node_symbol:setScale( self._scale * 0.9 )
		self._scheduler = scheduler.performWithDelayGlobal(function ()
			self._ccbOwner.node_symbol:setScale( self._scale )
		end, 1)
	else
		-- "32" up
		if self._scheduler then
			scheduler.unscheduleGlobal(self._scheduler)
			self._scheduler = nil
		end
		self._ccbOwner.node_symbol:setScale( self._scale )

		local ccbFile = "ccb/effects/diaowen_effect_lianxian.ccbi"
	    local aniPlayer = QUIWidgetAnimationPlayer.new()
	    self:getView():addChild(aniPlayer)
	    aniPlayer:playAnimation(ccbFile)
		self:dispatchEvent( {name = QUIWidgetGlyphClientCell.EVENT_CLICK, skillId = self._skillId, skillLevel = self._skillLevel} )
	end	
end

return QUIWidgetGlyphClientCell
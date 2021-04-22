local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGemstoneBreakthroughSuccess = class("QUIDialogGemstoneBreakthroughSuccess", QUIDialog)
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIDialogGemstoneBreakthroughSuccess.EVENT_CLOSE = "EVENT_CLOSE"

function QUIDialogGemstoneBreakthroughSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_tupo.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
	}
	QUIDialogGemstoneBreakthroughSuccess.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self.isAnimation = true

	self._isEnd = false
	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
	self._animationManager:connectScriptHandler(function()
			if self._isEnd == false then
				self._isEnd = true
			end
		end)

	if options ~= nil then 
		self._oldUIModel = options.oldUIModel
		self._newUIModel = options.newUIModel
		self._gemstonePos = options.pos
		self._successTip = options.successTip
		self._callback = options.callback
	end
	app.sound:playSound("common_level_up")

	for i=1,2 do
		self._ccbOwner["name"..i]:setString("")
		self._ccbOwner["old_prop"..i]:setString("")
		self._ccbOwner["new_prop"..i]:setString("")
		self._ccbOwner["arrow"..i]:setVisible(false)
	end

	self:setBreakthroughInfo()

    self._isSelected = false
    self:showSelectState()
    self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._successTip))
    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())
end

function QUIDialogGemstoneBreakthroughSuccess:viewDidAppear()
	QUIDialogGemstoneBreakthroughSuccess.super.viewDidAppear(self)
end

function QUIDialogGemstoneBreakthroughSuccess:viewWillDisappear()
	QUIDialogGemstoneBreakthroughSuccess.super.viewWillDisappear(self)
	self._animationManager:disconnectScriptHandler()
	if self._itemEffectScheduler ~= nil then
		scheduler.unscheduleGlobal(self._itemEffectScheduler)
		self._itemEffectScheduler = nil
	end

	if self._itemEffect ~= nil then
		self._itemEffect:disappear()
		self._itemEffect = nil
	end
end

function QUIDialogGemstoneBreakthroughSuccess:setBreakthroughInfo()
	local oldGemstoneInfo = self._oldUIModel:getGemstoneInfoByPos(self._gemstonePos)
	local newGemstoneInfo = self._newUIModel:getGemstoneInfoByPos(self._gemstonePos)
	local breakconfig1 = QStaticDatabase:sharedDatabase():getGemstoneBreakThroughByLevel(oldGemstoneInfo.info.itemId, oldGemstoneInfo.info.craftLevel)
	local breakconfig2 = QStaticDatabase:sharedDatabase():getGemstoneBreakThroughByLevel(newGemstoneInfo.info.itemId, newGemstoneInfo.info.craftLevel)
    self._advancedLevel = oldGemstoneInfo.info.godLevel or remote.gemstone.GEMSTONE_GODLEVLE_TEST
    local mixLevel = oldGemstoneInfo.info.mix_level or 0

	local oldGemstoneBox = QUIWidgetGemstonesBox.new()
	oldGemstoneBox:setGemstoneInfo(oldGemstoneInfo.info)
	oldGemstoneBox:setStateQualityVisible(false)
	oldGemstoneBox:setStrengthVisible(false)
	self._ccbOwner.old_head:addChild(oldGemstoneBox)

	local itemConfig = QStaticDatabase:sharedDatabase():getItemByID(oldGemstoneInfo.info.itemId)
    local level,color = remote.herosUtil:getBreakThrough(oldGemstoneInfo.info.craftLevel) 
    local name = itemConfig.name
	name = remote.gemstone:getGemstoneNameByData(name,self._advancedLevel,mixLevel)

    if level > 0 then
    	name = name .. "＋".. level
    end
	self._ccbOwner.tf_old_name:setString(name)
	self._ccbOwner.tf_old_name:setColor(BREAKTHROUGH_COLOR_LIGHT[color])


	local newGemstoneBox = QUIWidgetGemstonesBox.new()
	newGemstoneBox:setGemstoneInfo(newGemstoneInfo.info)
	newGemstoneBox:setStateQualityVisible(false)
	newGemstoneBox:setStrengthVisible(false)

    local level,color = remote.herosUtil:getBreakThrough(newGemstoneInfo.info.craftLevel) 
	self._newLevel = level
 	name = itemConfig.name
	self._newName = remote.gemstone:getGemstoneNameByData(name,self._advancedLevel,mixLevel)

    if level > 0 then
    	self._newName = self._newName .. "＋".. level
		newGemstoneBox:setBreakLevel(newGemstoneInfo.info.craftLevel)
		self:setItemBoxEffect(newGemstoneBox, color)
	else
    	newGemstoneBox:setBreakLevel(oldGemstoneInfo.info.craftLevel)
		self._ccbOwner.new_head:addChild(newGemstoneBox)
    end

	self._ccbOwner.tf_new_name:setString("")
	self._ccbOwner.tf_new_name:setColor(BREAKTHROUGH_COLOR_LIGHT[color])
	self._isSaying = true
	self._itemEffectScheduler = scheduler.performWithDelayGlobal(function()
			self:typeWriter(self._ccbOwner["tf_new_name"])
			if level == 0 then
				self:itemFrameEffect(newGemstoneInfo.info.craftLevel, color, newGemstoneBox)
			end
		end, 1.0)
	QPrintTable(breakconfig1)
	QPrintTable(breakconfig2)
		
	self._index = 1
	self:setTFValue("生    命", math.floor(breakconfig1.hp_value or 0), math.floor(breakconfig2.hp_value or 0))
	self:setTFValue("攻    击", math.floor(breakconfig1.attack_value or 0), math.floor(breakconfig2.attack_value or 0))
	self:setTFValue("命    中", math.floor(breakconfig1.hit_rating or 0), math.floor(breakconfig2.hit_rating or 0))
	self:setTFValue("闪    避", math.floor(breakconfig1.dodge_rating or 0), math.floor(breakconfig2.dodge_rating or 0))
	self:setTFValue("暴    击", math.floor(breakconfig1.critical_rating or 0), math.floor(breakconfig2.critical_rating or 0))
	self:setTFValue("格    挡", math.floor(breakconfig1.block_rating or 0), math.floor(breakconfig2.block_rating or 0))
	self:setTFValue("急    速", math.floor(breakconfig1.haste_rating or 0), math.floor(breakconfig2.haste_rating or 0))
	self:setTFValue("物理防御", math.floor(breakconfig1.armor_physical or 0), math.floor(breakconfig2.armor_physical or 0))
	self:setTFValue("法术防御", math.floor(breakconfig1.armor_magic or 0), math.floor(breakconfig2.armor_magic or 0))
	self:setTFValue("生命增加", (breakconfig1.hp_percent or 0), (breakconfig2.hp_percent or 0), true)
	self:setTFValue("攻击增加", (breakconfig1.attack_percent or 0), (breakconfig2.attack_percent or 0), true)
	self:setTFValue("物防增加", (breakconfig1.armor_physical_percent or 0), (breakconfig2.armor_physical_percent or 0), true)
	self:setTFValue("法防增加", (breakconfig1.armor_magic_percent or 0), (breakconfig2.armor_magic_percent or 0), true)
end

function QUIDialogGemstoneBreakthroughSuccess:setItemBoxEffect(newHead, color)
	if self._newLevel == 0 then 
		return 
	end

	self._itemEffect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.new_head:addChild(self._itemEffect)

	local path = QResPath("equipment_evolution_icon_"..color)
	local displayFrame
	if path then
		displayFrame = QSpriteFrameByPath(path)
	end
	
	local ccbFile = "ccb/effects/baoshi_zuan"..self._newLevel..".ccbi"
	self._itemEffect:playAnimation(ccbFile, function()
			self._itemEffect._ccbOwner.node_item:addChild(newHead)
			local index = 1 
			if displayFrame then
				while self._itemEffect._ccbOwner["sp_icon_"..index] do
					self._itemEffect._ccbOwner["sp_icon_"..index]:setDisplayFrame(displayFrame)
					index = index + 1
				end
	    	end
			for i=1, self._newLevel, 1 do
				local timeHandler = scheduler.performWithDelayGlobal(function ()
					app.sound:playSound("common_star")
				end, 0.3*(i-1)+1.3)
			end
		end, function()
		end, false)
end

function QUIDialogGemstoneBreakthroughSuccess:itemFrameEffect(breaklevel, color, itemBox)
	local itemEffect = QUIWidgetAnimationPlayer.new()
	self._ccbOwner.new_head:addChild(itemEffect)
	local ccbFile = "ccb/effects/kuang_small.ccbi"
	itemEffect:playAnimation(ccbFile, function(ccbOwner)	
			ccbOwner.node_baoshi_frame:setVisible(true)
			local effectName = "baoshi_effect_"
			ccbOwner[effectName..color]:setVisible(true)

			scheduler.performWithDelayGlobal(function()
				itemBox:setBreakLevel(breaklevel)
				app.sound:playSound("common_star")
			end, 1/6)
		end, function ()
		end)
end

function QUIDialogGemstoneBreakthroughSuccess:typeWriter(node)
	local delayTime = TUTORIAL_ONEWORD_TIME
	local word = ""
	local lineNum = 1
	local sayPosition = 1
	local startPosition = 1
	self._func = function()
		if self._isSaying == true then
			--local c = string.sub(self._newName,sayPosition,sayPosition)
			local c = q.SubStringUTF8(self._newName,sayPosition,sayPosition)
			local b = string.byte(c)
			local str = c
			if b and  b > 128 then
				str = q.SubStringUTF8(self._newName,sayPosition,sayPosition+ 1)
				sayPosition = sayPosition + 1
				word =  word .. str
			else
				word =  word .. c
			end
			sayPosition = sayPosition + 1
			node:setString(word)
		end
		if sayPosition <= #self._newName then
			self._time = scheduler.performWithDelayGlobal(self:safeHandler(handler(self, self._func)),delayTime)
		else
			self._isSaying = false
			if self._time ~= nil then
				scheduler.unscheduleGlobal(self._time)
				self._time = nil
			end
		end
	end
	self._func()
end

function QUIDialogGemstoneBreakthroughSuccess:setTFValue(name, oldValue, newValue, isPercent)
	print("self._index"..self._index)
	if self._index > 2 then return end
	local num = newValue - oldValue
	print(name.." =====" .. num)
	if num > 0 then
		print(" true"..name..oldValue ..newValue)
		if self._ccbOwner["name"..self._index] ~= nil then
			self._ccbOwner["name"..self._index]:setString(name.."：")
			if isPercent == true then
				self._ccbOwner["old_prop"..self._index]:setString(string.format("  %.2f%%",oldValue*100))
				self._ccbOwner["new_prop"..self._index]:setString(string.format("  %.2f%%",(newValue)*100))
			else
				self._ccbOwner["old_prop"..self._index]:setString("  "..oldValue)
				self._ccbOwner["new_prop"..self._index]:setString("  "..newValue)
			end
			self._ccbOwner["arrow"..self._index]:setVisible(true)
		end
		self._index = self._index + 1
	end
end

function QUIDialogGemstoneBreakthroughSuccess:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogGemstoneBreakthroughSuccess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogGemstoneBreakthroughSuccess:_backClickHandler()
	if self._isEnd == false then 
		-- self._isEnd = true
  --   	self._animationManager:runAnimationsForSequenceNamed("two")
		return 
	end
	self:_onTriggerClose()
end

function QUIDialogGemstoneBreakthroughSuccess:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogGemstoneBreakthroughSuccess:viewAnimationOutHandler()
	local callback = self._callback

    if self._isSelected == true then
        app.master:setMasterShowState(self._successTip)
    end
	self:dispatchEvent({name = QUIDialogGemstoneBreakthroughSuccess.EVENT_CLOSE})
    remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
    
	self:popSelf()
	if callback then
		callback()
	end
end

return QUIDialogGemstoneBreakthroughSuccess
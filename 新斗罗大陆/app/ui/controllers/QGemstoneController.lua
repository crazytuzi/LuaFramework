local QGemstoneController = class("QGemstoneController")
local QUIWidgetGemstonesBox = import("..widgets.QUIWidgetGemstonesBox")
local QUIViewController = import("..QUIViewController")
local QUIWidgetSparBox = import("..widgets.spar.QUIWidgetSparBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QGemstoneController:ctor(options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._gemstoneBoxs = {}
	self._sparBoxs = {}
	if options then
		self._isDisplay = options.isDisplay
	end
	self._count = 0
	self._sparCount = 0
end

function QGemstoneController:setBoxs(gemstoneBoxs, sparBoxs)
	self:removeBoxEvent()
	self._gemstoneBoxs = gemstoneBoxs or {}
	self._sparBoxs = sparBoxs or {}
	self:addBoxEvent()
end

function QGemstoneController:setHero(actorId)
	self._actorId = actorId
	self:refreshBox()
end

function QGemstoneController:setGemstones(gemstones, spars)
	self._gemstones = gemstones
	self._spars = spars
end

function QGemstoneController:refreshBox()
	self._count = 0
	self._sparCount = 0
	if not self._isDisplay then
		local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
		for index,gemstoneBox in ipairs(self._gemstoneBoxs) do
			local gemstoneInfo = UIHeroModel:getGemstoneInfoByPos(index)
			if gemstoneInfo.state ~= remote.gemstone.GEMSTONE_LOCK then
				self._count = self._count + 1
			end
			gemstoneBox:resetAll()
			gemstoneBox:setState(gemstoneInfo.state)
			if gemstoneInfo.info ~= nil then
				gemstoneBox:setGemstoneInfo(gemstoneInfo.info)
			end
			local redTips = gemstoneInfo.isCanBreak == true or gemstoneInfo.isBetter == true or gemstoneInfo.isCanWear == true 
			or gemstoneInfo.isCanMix == true or gemstoneInfo.isCanRefine == true
			gemstoneBox:setTips(redTips)
			gemstoneBox:setBreakTips(gemstoneInfo.isCanBreak == true or gemstoneInfo.isCanWear == true)
			gemstoneBox:setStrengthTips(gemstoneInfo.isCanWear == true)
			gemstoneBox:setDetailTips(gemstoneInfo.isBetter == true or gemstoneInfo.isCanWear == true)
			gemstoneBox:setMixTips(gemstoneInfo.isCanMix == true )
			gemstoneBox:setRefineTips(gemstoneInfo.isCanRefine == true )

		end

		for index, sparBox in ipairs(self._sparBoxs) do
			local sparInfo = UIHeroModel:getSparInfoByPos(index)
			if sparInfo.state ~= remote.spar.SPAR_LOCK then
				self._sparCount = self._sparCount + 1
			end
			sparBox:resetAll()
			sparBox:setState(sparInfo.state, index)
			sparBox:setIsSpar()
			if sparInfo.info ~= nil then
				sparBox:setGemstoneInfo(sparInfo.info, index)
			end

			local redTips = sparInfo.isCanGrade == true or sparInfo.isBetter == true or sparInfo.isCanWear == true  or sparInfo.isCanAbsorb == true 
			sparBox:setTips(redTips)
			sparBox:setGradeTips(sparInfo.isCanGrade == true or sparInfo.isCanWear == true)
			sparBox:setStrengthTips(sparInfo.isCanWear == true)
			sparBox:setDetailTips(sparInfo.isBetter == true or sparInfo.isCanWear == true)
			sparBox:setInheritTips(sparInfo.isCanAbsorb == true or sparInfo.isCanWear == true)
		end
	else
		for index, gemstoneBox in ipairs(self._gemstoneBoxs) do
			gemstoneBox:resetAll()
			if self._gemstones then
				local gemstoneInfo = self._gemstones[index]
				if gemstoneInfo then
					gemstoneBox:setState(remote.gemstone.GEMSTONE_WEAR)
					gemstoneBox:setGemstoneInfo(gemstoneInfo)
					gemstoneBox:setVisible(true)
				else
					gemstoneBox:setState(remote.gemstone.GEMSTONE_NONE)
					gemstoneBox:setStrengthVisible(false)
					gemstoneBox:cleanBox()
					gemstoneBox:setVisible(false)
				end
			else
				gemstoneBox:setState(remote.gemstone.GEMSTONE_NONE)
				gemstoneBox:setStrengthVisible(false)
				gemstoneBox:cleanBox()
				gemstoneBox:setVisible(false)
			end
		end
		for index, sparBox in ipairs(self._sparBoxs) do
			sparBox:resetAll()
			sparBox:setIsSpar()
			if self._spars then
				local sparInfo = self._spars[index]
				if sparInfo then
					sparBox:setState(remote.spar.SPAR_WEAR, index)
					sparBox:setGemstoneInfo(sparInfo)
					sparBox:setVisible(true)
				else
					sparBox:setState(remote.spar.SPAR_NONE, index)
					sparBox:setStrengthVisible(false)
					sparBox:setVisible(false)
				end
			else
				sparBox:setState(remote.spar.SPAR_NONE, index)
				sparBox:setVisible(false)
			end
		end
	end
end

function QGemstoneController:hideRedTip()
	for _,box in ipairs(self._gemstoneBoxs) do
		box:setTips(false)
	end
	for _,box in ipairs(self._sparBoxs) do
		box:setTips(false)
	end
end

function QGemstoneController:addBoxEvent()
	for _,box in ipairs(self._gemstoneBoxs) do
		box:addEventListener(QUIWidgetGemstonesBox.EVENT_CLICK, handler(self, self._onEvent))
	end
	for _,box in ipairs(self._sparBoxs) do
		box:addEventListener(QUIWidgetSparBox.EVENT_CLICK, handler(self, self._onEvent))
	end
end

function QGemstoneController:checkSuitEffect()
	local suit = {}
	local count = 0
	local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	for index,gemstoneBox in ipairs(self._gemstoneBoxs) do
		local gemstoneInfo = UIHeroModel:getGemstoneInfoByPos(index)
		if gemstoneInfo.info ~= nil then
	    	local gemstoneConfig = QStaticDatabase:sharedDatabase():getItemByID(gemstoneInfo.info.itemId)
			suit[gemstoneConfig.gemstone_set_index] = (suit[gemstoneConfig.gemstone_set_index] or 0) + 1
			count = count + 1
		end
	end
	--显示套装的特效
	local isShowSuitEffect = (table.nums(suit) == 1 and count == 4)
	for index,gemstoneBox in ipairs(self._gemstoneBoxs) do
		gemstoneBox:showSuitEffect(isShowSuitEffect)
	end
end

function QGemstoneController:removeBoxEvent()
	for _,box in ipairs(self._gemstoneBoxs) do
		if box.removeAllEventListeners then
			box:removeAllEventListeners()
		end
	end
	for _,box in ipairs(self._sparBoxs) do
		if box.removeAllEventListeners then
			box:removeAllEventListeners()
		end
	end
end

function QGemstoneController:getUnlockGemstoneCount()
	return self._count
end

function QGemstoneController:getUnlockSparCount()
	if app.unlock:checkLock("UNLOCK_ZHUBAO") == false then
		return 0
	end
	return self._sparCount
end
--
function QGemstoneController:_onEvent(event)
	if self._isDisplay then return end

	local UIHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	if event.boxType == 1 then
		local sparInfo = UIHeroModel:getSparInfoByPos(event.sparPos)
		if sparInfo.state == remote.spar.SPAR_CAN_WEAR then
			app.sound:playSound("common_common")
        	remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_HERO_EXP_CHECK})
	        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSparFastBag", 
	            options = {actorId = self._actorId, pos = event.sparPos}})
	    elseif sparInfo.state == remote.spar.SPAR_LOCK then
			local unlockLevel = remote.spar:getUnlockHeroLevelByIndex(event.sparPos)
			app.tip:floatTip("魂师"..unlockLevel.."级才能融合外附魂骨~")
	    else
			self:dispatchEvent(event)
		end
	elseif event.name == QUIWidgetGemstonesBox.EVENT_CLICK then
		local gemstoneInfo = UIHeroModel:getGemstoneInfoByPos(event.pos)
		if gemstoneInfo.state == remote.gemstone.GEMSTONE_CAN_WEAR then
			app.sound:playSound("common_common")
        	remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_HERO_EXP_CHECK})
	        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGemstoneFastBag", 
	            options = {canType = gemstoneInfo.canType, actorId = self._actorId, pos = event.pos}})
	    elseif gemstoneInfo.state == remote.gemstone.GEMSTONE_LOCK then
			local config = app.unlock:getConfigByKey("UNLOCK_GEMSTONE_"..event.pos)
			app.tip:floatTip("魂师大人，这个魂骨栏位将在魂师"..config.hero_level.."级解锁~")
	    else
			self:dispatchEvent(event)
		end
	end
end

return QGemstoneController

local QPromptTips = class("QPromptTips")

local QNotificationCenter = import("..controllers.QNotificationCenter")
local QUIWidgetItmePrompt = import("..ui.widgets.QUIWidgetItmePrompt")
local QUIWidgetItemsBox = import("..ui.widgets.QUIWidgetItemsBox")
local QUIWidgetMonsterHead = import("..ui.widgets.QUIWidgetMonsterHead")
local QUIWidgetMonsterPrompt = import("..ui.widgets.QUIWidgetMonsterPrompt")
local QUIWidgetChipPrompt = import("..ui.widgets.QUIWidgetChipPrompt")
local QStaticDatabase = import("..controllers.QStaticDatabase")
local QUIWidgetHeroSkillCell = import("..ui.widgets.QUIWidgetHeroSkillCell")
local QUIWidgetSkillPrompt = import("..ui.widgets.QUIWidgetSkillPrompt")
local QUIWidgetHeroInformation = import("..ui.widgets.QUIWidgetHeroInformation")
local QUIWidgetHeroPrompt = import("..ui.widgets.QUIWidgetHeroPrompt")
local QUIWidgetEnergyPrompt = import("..ui.widgets.QUIWidgetEnergyPrompt")
local QUIWidgetCurrencyPrompt = import("..ui.widgets.QUIWidgetCurrencyPrompt")
local QVIPUtil = import("..utils.QVIPUtil")

function QPromptTips:ctor(options)
	self._layer = options
	self.prompt = nil
end


--[[

  怪物悬浮提示

--]]

function QPromptTips:addMonsterEventListener()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetMonsterHead.EVENT_BEGAIN , QPromptTips.startMonsterPrompt, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetMonsterHead.EVENT_END , QPromptTips.stopMonsterPrompt, self)
end

function QPromptTips:removeMonsterEventListener()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetMonsterHead.EVENT_BEGAIN , QPromptTips.startMonsterPrompt, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetMonsterHead.EVENT_END , QPromptTips.stopMonsterPrompt, self)
	if self.prompt ~= nil then
		self.prompt:removeFromParent()
		self.prompt = nil
	end
end

function QPromptTips:startMonsterPrompt(data)
    printf("QUIWidgetMonsterHead.EVENT_BEGAIN trigger")
	if self.prompt ~= nil then 

		self:stopMonsterPrompt()
		self.prompt = nil
	end
	if data ~= nil then
		local target = data.eventTarget
		local info = data.info
		local config = data.config

		local headSize = target._ccbOwner.node_hero_image:getContentSize()
		local headScale = target._ccbOwner.node_hero_image:getScale()

		local position = target._ccbOwner.node_cd:convertToWorldSpaceAR(ccp(0, 0))
		if self.prompt == nil then
			self.prompt = QUIWidgetMonsterPrompt.new({info = info, size = headSize, scale = headScale, config = config})
			self._layer:addChild(self.prompt)
		end
		local promptSize = self.prompt.size
		local positionX = position.x + self.prompt.size.width/2 - headSize.width/2
		local positionY = position.y + self.prompt.size.height/2 + headSize.width/2 + self.prompt.skillChange
		self.prompt:setPosition(positionX, positionY)
	end
end

function QPromptTips:stopMonsterPrompt(event)
	if self.prompt ~= nil then
		self.prompt:removeFromParent()
		self.prompt = nil
	end
end

--[[

  物品悬浮提示

--]]

function QPromptTips:addItemEventListener(data)
	self.dialog = data
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetItemsBox.EVENT_BEGAIN , QPromptTips.startItemPrompt, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetItemsBox.EVENT_END , QPromptTips.stopItemPrompt, self)
end

function QPromptTips:removeItemEventListener()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetItemsBox.EVENT_BEGAIN , QPromptTips.startItemPrompt, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetItemsBox.EVENT_END , QPromptTips.stopItemPrompt, self)
	if self.prompt ~= nil then
		self.prompt:removeFromParent()
		self.prompt = nil
	end
end

function QPromptTips:startItemPrompt(data)
	if self.prompt ~= nil then 
		return 
	end

	if data ~= nil then
		local target = data.eventTarget
		local itemId = data.itemID
		local itemType = data.itemType

		if target._scrollContain ~= nil and target._scrollContain:getMoveState() then
			return
		end

		local size = target._ccbOwner.node_mask:getContentSize()
		local scaleX = target._ccbOwner.node_mask:getScaleX()
		local scaleY = target._ccbOwner.node_mask:getScaleY()

		local itemConfig = nil
		if itemType ~= ITEM_TYPE.HERO and itemId ~= nil then
			itemConfig = QStaticDatabase:sharedDatabase():getItemByID(itemId)
		end

		local position = target._ccbOwner.sprite_back:convertToWorldSpaceAR(ccp(0, 0))

		if itemType == ITEM_TYPE.HERO then
			local heroConfig = QStaticDatabase:sharedDatabase():getCharacterByID(itemId)
			if self.prompt == nil then
				self.prompt = QUIWidgetHeroPrompt.new(heroConfig)
				self._layer:addChild(self.prompt)
			end
			local promptSize = self.prompt.size
			local boxSize = target._ccbOwner.sprite_back:getContentSize()
			local positionY = position.y + promptSize.height/2 + boxSize.height/2
			-- if self.dialog.class ~= nil and self.dialog.class.__cname == "QUIDialogTavernAchieve" then
			-- 	self.prompt:setPosition(position.x, positionY - boxSize.height)
			-- else
				self.prompt:setPosition(position.x, positionY - boxSize.height)
			-- end
		elseif itemType == ITEM_TYPE.VIP or itemType == ITEM_TYPE.ENERGY or itemType == ITEM_TYPE.TEAM_EXP or itemType == ITEM_TYPE.ACHIEVE_POINT or remote.items:getWalletByType(itemType) then
			if self.prompt == nil then
				self.prompt = QUIWidgetCurrencyPrompt.new({type = itemType})
				self._layer:addChild(self.prompt)

				local promptSize = self.prompt.size
				local boxSize = target._ccbOwner.sprite_back:getContentSize()
				self.positionY = position.y + promptSize.height/2 + boxSize.height/4
				self.positionX = position.x + (promptSize.width/2 - boxSize.width/2)

				if self.dialog.class ~= nil then
					self.positionY = self.positionY
				elseif self.dialog.class ~= nil and self.dialog.class.__cname == "QUIDialogTavernAchieve" then
					self.positionY = self.positionY + 20
				elseif self.dialog.class ~= nil and self.dialog.class.__cname == "QUIDialogAwardsAlert" then
					self.positionY = self.positionY + 40
				else
					self.positionY = self.positionY + promptSize.height/2
				end
				position.x = math.min(CCDirector:sharedDirector():getWinSize().width - promptSize.width/2, position.x)
				position.x = math.max(0 + promptSize.width/2, position.x)
				self.prompt:setPosition(position.x, self.positionY)
			end
		elseif self.prompt == nil and itemConfig ~= nil and itemConfig.type == 3 then
			self.prompt = QUIWidgetChipPrompt.new({itemConfig = itemConfig, boxSize = size, scaleX = scaleX, scaleY = scaleY})
			self._layer:addChild(self.prompt)
			local promptSize = self.prompt.size
			local boxSize = target._ccbOwner.sprite_back:getContentSize()
			self.positionY = position.y + promptSize.height/2 + boxSize.height/4
			self.positionX = position.x + (promptSize.width/2 - boxSize.width/2)
			if self.dialog.class ~= nil and (self.dialog.class.__cname == "QUIDialogPreview" or self.dialog.class.__cname == "QUIDialogAwardsAlert") then

				self.positionX = position.x
				self.positionY = self.positionY
			elseif self.dialog.class ~= nil and self.dialog.class.__cname == "QUIDialogTavernAchieve" then
				self.positionX = position.x
				self.positionY = self.positionY
			else
				self.positionX = self.positionX - 20
				self.positionY = self.positionY
			end
			self.prompt:setPosition(self.positionX, self.positionY)

			self.positionX = math.min(CCDirector:sharedDirector():getWinSize().width - promptSize.width * 1 / 2, self.positionX)
				self.prompt:setPosition(self.positionX - 20, self.positionY)
		else
			if itemConfig == nil then return end
			if self.prompt == nil then
				self.prompt = QUIWidgetItmePrompt.new({itemConfig = itemConfig, boxSize = size, scaleX = scaleX, scaleY = scaleY})
				self._layer:addChild(self.prompt)
				local promptSize = self.prompt.size
				local boxSize = target._ccbOwner.sprite_back:getContentSize()
				self.positionX = position.x + (promptSize.width/2 - boxSize.width/2)
				self.positionY = position.y + promptSize.height/2 + boxSize.height/4

				-- nzhang: http://jira.joybest.com.cn/browse/WOW-8969
				self.positionY = math.min(CCDirector:sharedDirector():getWinSize().height - promptSize.height * 3 / 4, self.positionY)
				-- nzhang: http://jira.joybest.com.cn/browse/WOW-9106
				self.positionX = math.min(CCDirector:sharedDirector():getWinSize().width - promptSize.width * 1 / 2, self.positionX)
					self.prompt:setPosition(self.positionX - 20, self.positionY)
			end
		end
	end
end

function QPromptTips:stopItemPrompt(event)
	if self.prompt ~= nil then
		self.prompt:removeFromParent()
		self.prompt = nil
	end
end

--[[

  魂师悬浮提示

--]]

function QPromptTips:addHeroEventListener(data)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroInformation.EVENT_BEGAIN , QPromptTips.startHeroPrompt, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroInformation.EVENT_END , QPromptTips.stopHeroPrompt, self)
end

function QPromptTips:removeHeroEventListener()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroInformation.EVENT_BEGAIN , QPromptTips.startHeroPrompt, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroInformation.EVENT_END , QPromptTips.stopHeroPrompt, self)
	if self.prompt ~= nil then
		self.prompt:removeFromParent()
		self.prompt = nil
	end
end
--
function QPromptTips:startHeroPrompt(data)
	if self.prompt ~= nil then 

		self:stopHeroPrompt()
		self.prompt = nil
	end
	if data ~= nil then
		local target = data.eventTarget
		local actorId = data.actorId
		--
		--    local size = self.target._ccbOwner.node_mask:getContentSize()
		--    local scaleX = self.target._ccbOwner.node_mask:getScaleX()
		--    local scaleY = self.target._ccbOwner.node_mask:getScaleY()

		local heroInfo = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)

		local position = target._ccbOwner.sprite_back:convertToWorldSpaceAR(ccp(0, 0))
		if self.prompt == nil then
			self.prompt = QUIWidgetHeroPrompt.new(heroInfo)
			self._layer:addChild(self.prompt)
		end
		local promptSize = self.prompt.size
		local boxSize = target._ccbOwner.sprite_back:getContentSize()
		local positionX = position.x + promptSize.width/2 + boxSize.width/2
		self.prompt:setPosition(positionX, position.y)
	end
end

function QPromptTips:stopHeroPrompt(event)
	if self.prompt ~= nil then
		self.prompt:removeFromParent()
		self.prompt = nil
	end
end

--[[

  技能悬浮提示

--]]

function QPromptTips:addSkillEventListener()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSkillCell.EVENT_BEGAIN , QPromptTips.startSkillPrompt, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetHeroSkillCell.EVENT_END , QPromptTips.stopSkillPrompt, self)
end

function QPromptTips:removeSkillEventListener()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSkillCell.EVENT_BEGAIN , QPromptTips.startSkillPrompt, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetHeroSkillCell.EVENT_END , QPromptTips.stopSkillPrompt, self)
	if self.prompt ~= nil then
		self.prompt:removeFromParent()
		self.prompt = nil
	end
end

function QPromptTips:startSkillPrompt(data)
	if self.prompt ~= nil then 
		self:stopSkillPrompt()
		self.prompt = nil
	end
	if data ~= nil then
		local skillSlotInfo = data.skillSlotInfo
		local target = data.eventTarget
		local skillID = data.skillID
		local promptType = data.promptType

		local skillConfig = nil
		local skilldec = nil
		local isHave = false
		if skillSlotInfo ~= nil then
			isHave = true
		end
		skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(skillID)

		local position = target._ccbOwner.node_layout:convertToWorldSpaceAR(ccp(0, 0))
		if self.prompt == nil then
			self.prompt = QUIWidgetSkillPrompt.new({skillSlotInfo = skillSlotInfo, skillConfig = skillConfig, isHave = isHave, promptType = promptType})
			self._layer:addChild(self.prompt)
		end

		local dialog = app:getNavigationManager():getController(app.middleLayer):getTopDialog()

		local promptSize = self.prompt.size
		local boxSize = target._ccbOwner.node_layout:getContentSize()
		local positionX = position.x - promptSize.width/2 - boxSize.width/2
		local positionY = position.y 
		if dialog ~= nil and dialog.class ~= nil and dialog.class.__cname == "QUIDialogHeroDetailInfoNew" then
			positionX = position.x
			positionY = position.y + promptSize.height/2 + boxSize.width/2 + 10
		end
		
		positionX = math.max(promptSize.width/1.5, positionX)
		self.prompt:setPosition(positionX, positionY)
	end
end

function QPromptTips:stopSkillPrompt(event)
	if self.prompt ~= nil then
		self.prompt:removeFromParent()
		self.prompt = nil
	end
end


--[[

  体力悬浮提示

--]]

function QPromptTips:addEnergyEventListener()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetEnergyPrompt.EVENT_BEGAIN , QPromptTips.startEnergyPrompt, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QUIWidgetEnergyPrompt.EVENT_END , QPromptTips.stopEnergyPrompt, self)
end

function QPromptTips:removeEnergyEventListener()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetEnergyPrompt.EVENT_BEGAIN , QPromptTips.startEnergyPrompt, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QUIWidgetEnergyPrompt.EVENT_END , QPromptTips.stopEnergyPrompt, self)
	if self.prompt ~= nil then
		self.prompt:removeFromParent()
		self.prompt = nil
	end
end

function QPromptTips:startEnergyPrompt(data)
	if self.prompt ~= nil then 

		self:stopEnergyPrompt()
	end
	local maxEnergyBuyCount = QVIPUtil:getBuyVirtualCount(ITEM_TYPE.ENERGY)
	-- This is copied from system setting calculation
	local secondsToMaximum2 = (global.config.max_energy - remote.user.energy) * global.config.energy_refresh_interval
	local secondsElapsed = math.floor((q.time() * 1000 - remote.user.energyRefreshedAt)/1000)%global.config.energy_refresh_interval
	local secondsToMaximum = secondsToMaximum2 - secondsElapsed

	if self.prompt == nil then
		self.prompt = QUIWidgetEnergyPrompt.new({curEnergy=remote.user.energy, curEnergyBuyCount = remote.user.todayEnergyBuyCount,
			maxEnergyBuyCount = maxEnergyBuyCount, timeToNextEnergyPoint = global.config.energy_refresh_interval - secondsElapsed, timeToEnergyFull = secondsToMaximum}, isHave)
		self._layer:addChild(self.prompt)
	end
end

function QPromptTips:stopEnergyPrompt(event)
	if self.prompt ~= nil then
		self.prompt:removeFromParent()
		self.prompt = nil
	end
end

function QPromptTips:removeMyAppPrompt()
	-- if app.prompt ~= nil then
	-- 	app.prompt = nil
	-- end
end 

return QPromptTips

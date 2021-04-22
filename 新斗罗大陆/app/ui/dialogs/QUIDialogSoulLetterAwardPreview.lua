-- @Author: xurui
-- @Date:   2019-05-16 15:25:12
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-24 15:16:15
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulLetterAwardPreview = class("QUIDialogSoulLetterAwardPreview", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogSoulLetterAwardPreview:ctor(options)
	local ccbFile = "ccb/Dialog_Battle_Pass_view.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogSoulLetterAwardPreview.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._awards = options.awards
    end

    self._normalItem = {}
    self._eliteItem = {}
 	self._activityProxy = remote.activityRounds:getSoulLetter()
end

function QUIDialogSoulLetterAwardPreview:viewDidAppear()
	QUIDialogSoulLetterAwardPreview.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogSoulLetterAwardPreview:viewWillDisappear()
  	QUIDialogSoulLetterAwardPreview.super.viewWillDisappear(self)
end

function QUIDialogSoulLetterAwardPreview:setInfo()
	local normalAwards = {}
	local eliteAwards = {}
	for _, value in ipairs(self._awards) do
		if value.is_node then
			if value.normal_reward then
				remote.items:analysisServerItem(value.normal_reward, normalAwards)
			end
			if value.rare_reward1 then
				remote.items:analysisServerItem(value.rare_reward1, eliteAwards)
			end
			if value.rare_reward2 then
				remote.items:analysisServerItem(value.rare_reward2, eliteAwards)
			end
		end
	end

	local insertFunc = function(awards)
		local newAwards = {}
		for i, value in pairs(awards) do
			if value.id then
				if newAwards[value.id] then
					newAwards[value.id].count = newAwards[value.id].count + value.count
				else
					newAwards[value.id] = value
				end
			elseif value.typeName then
				if newAwards[value.typeName] then
					newAwards[value.typeName].count = newAwards[value.typeName].count + value.count
				else
					newAwards[value.typeName] = value
				end
			end
		end

		return newAwards
	end
	normalAwards = insertFunc(normalAwards)
	eliteAwards = insertFunc(eliteAwards)

	local realNormalAwards = {}
	local realEliteAwards = {}
	for i, value in pairs(normalAwards) do
		realNormalAwards[#realNormalAwards+1] = value
	end
	for i, value in pairs(eliteAwards) do
		realEliteAwards[#realEliteAwards+1] = value
	end
    table.sort(realNormalAwards, handler(self, self.sortAwards))
    table.sort(realEliteAwards, handler(self, self.sortAwards))

	local gap = 20
	local raw = 0
	local line = 0
	local maxRaw = 7
	for i, value in pairs(realNormalAwards) do
		if self._normalItem[i] == nil then
			self._normalItem[i] = QUIWidgetItemsBox.new()
			self._ccbOwner.node_normal_item:addChild(self._normalItem[i])
			self._normalItem[i]:setPromptIsOpen(true)
		end
		self._normalItem[i]:setGoodsInfo(value.id, value.typeName, value.count)
		local contentSize = self._normalItem[i]:getContentSize()
		self._normalItem[i]:setPositionX(raw * (contentSize.width + gap))
		self._normalItem[i]:setPositionY(- (line * (contentSize.width + gap)))

		raw = raw + 1
		if raw % maxRaw == 0 then
			raw = 0
			line = line + 1
		end
	end


	raw = 0
	line = 0
	for i, value in pairs(realEliteAwards) do
		if self._eliteItem[i] == nil then
			self._eliteItem[i] = QUIWidgetItemsBox.new()
			self._ccbOwner.node_elite_item:addChild(self._eliteItem[i])
			self._eliteItem[i]:setPromptIsOpen(true)
		end
		self._eliteItem[i]:setGoodsInfo(value.id, value.typeName, value.count)
		local contentSize = self._eliteItem[i]:getContentSize()
		self._eliteItem[i]:setPositionX(raw * (contentSize.width + gap))
		self._eliteItem[i]:setPositionY(- (line * (contentSize.width + gap)))

		raw = raw + 1
		if raw % maxRaw == 0 then
			raw = 0
			line = line + 1
		end
	end
end

function QUIDialogSoulLetterAwardPreview:sortAwards(a, b)
	local aColour = 1
	local bColour = 1
	if a.id then
		local itemConfig = db:getItemByID(a.id)
		aColour = itemConfig.colour
	else
		local config = remote.items:getWalletByType(a.typeName)
		aColour = config.colour
	end
	if b.id then
		local itemConfig = db:getItemByID(b.id)
		bColour = itemConfig.colour
	else
		local config = remote.items:getWalletByType(b.typeName)
		bColour = config.colour
	end

	if aColour ~= bColour then
		return aColour > bColour
	else
		return false
	end
end

function QUIDialogSoulLetterAwardPreview:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSoulLetterAwardPreview:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulLetterAwardPreview:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulLetterAwardPreview

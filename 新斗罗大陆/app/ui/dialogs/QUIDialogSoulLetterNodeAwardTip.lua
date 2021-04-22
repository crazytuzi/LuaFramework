-- @Author: xurui
-- @Date:   2019-05-16 17:26:39
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-27 17:47:57
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulLetterNodeAwardTip = class("QUIDialogSoulLetterNodeAwardTip", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogSoulLetterNodeAwardTip:ctor(options)
	local ccbFile = "ccb/Dialog_Battle_Pass_Ok.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerElite", callback = handler(self, self._onTriggerElite)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogSoulLetterNodeAwardTip.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._level = options.level
    end
 	self._activityProxy = remote.activityRounds:getSoulLetter()
end

function QUIDialogSoulLetterNodeAwardTip:viewDidAppear()
	QUIDialogSoulLetterNodeAwardTip.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogSoulLetterNodeAwardTip:viewWillDisappear()
  	QUIDialogSoulLetterNodeAwardTip.super.viewWillDisappear(self)
end

function QUIDialogSoulLetterNodeAwardTip:setInfo()
	local awardNum = 0
    local awards = {}

	local insertFunc = function(award)
		local newAwards = {}
		for _, value in ipairs(award) do
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

    local configDict = self._activityProxy:getAwardsConfig()
    for _, value in pairs(configDict) do
        if value.level <= self._level then
			if value.rare_reward1 then
				remote.items:analysisServerItem(value.rare_reward1, awards)
				awardNum = awardNum + 1
			end
			if value.rare_reward2 then
				remote.items:analysisServerItem(value.rare_reward2, awards)
				awardNum = awardNum + 1
			end
        end
    end
    awards = insertFunc(awards)

    local realAwards = {}
	for _, value in pairs(awards) do
		realAwards[#realAwards+1] = value
	end


    table.sort(realAwards, function(a, b)
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
	end)

	local gap = -5
	local raw = 0
	local maxRaw = 2
    for i = 1, 4 do
    	if realAwards[i] then
	    	local item = QUIWidgetItemsBox.new()
	    	self._ccbOwner.node_item:addChild(item)
	    	item:setGoodsInfo(realAwards[i].id, realAwards[i].typeName, realAwards[i].count)
			item:setPromptIsOpen(true)
	    	item:setScale(0.8)
			item:showBoxEffect("Widget_AchieveHero_light_orange.ccbi", false, 0, 0, 1.2)

			local contentSize = item:getContentSize()
			item:setPositionX(raw * (contentSize.width + gap))

			raw = raw + 1
		end
    end

    local richTextNode = QRichText.new(nil,420)
    richTextNode:setString({
        {oType = "font", content = "魂师大人，您的魂师手札已经提升到",size = 21,color = COLORS.a},
        {oType = "font", content = string.format("%s级", self._level), size = 21,color = COLORS.b},
        {oType = "font", content = "了，现在解锁精英手札，就能立即获得", size = 21,color = COLORS.a},
        {oType = "font", content = string.format("%s件", awardNum), size = 21,color = COLORS.b},
        {oType = "font", content = "超值奖励！", size = 21,color = COLORS.a},
    })
    richTextNode:setAnchorPoint(0, 1)
    self._ccbOwner.node_tf:addChild(richTextNode)
end

function QUIDialogSoulLetterNodeAwardTip:_onTriggerElite(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_elite) == false then return end
	app.sound:playSound("common_small")

	self:popSelf()

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivitySoulLetterActiveEliteNew"})
end

function QUIDialogSoulLetterNodeAwardTip:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulLetterNodeAwardTip:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulLetterNodeAwardTip

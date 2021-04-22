-- @Author: liaoxianbo
-- @Date:   2020-08-24 19:27:57
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-27 10:44:52
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulLetterAwardPreviewNew = class("QUIDialogSoulLetterAwardPreviewNew", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QListView = import("...views.QListView")
local QUIWidgetQlistviewItem = import("..widgets.QUIWidgetQlistviewItem")

function QUIDialogSoulLetterAwardPreviewNew:ctor(options)
	local ccbFile = "ccb/Dialog_Battle_Pass_Preview_New.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogSoulLetterAwardPreviewNew.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._activityProxy = remote.activityRounds:getSoulLetter()

    if options then
    	self._callBack = options.callBack
    	self._awards = options.awards
    end

    self._realNormalAwards = {}
    self._realEliteAwards = {}
 	self._activityProxy = remote.activityRounds:getSoulLetter()

 	self:setInfo()
 	self:setFinalAvatar()
 	self:initListViewNormal()
 	self:initListViewElite()
end

function QUIDialogSoulLetterAwardPreviewNew:viewDidAppear()
	QUIDialogSoulLetterAwardPreviewNew.super.viewDidAppear(self)

	
end

function QUIDialogSoulLetterAwardPreviewNew:viewWillDisappear()
  	QUIDialogSoulLetterAwardPreviewNew.super.viewWillDisappear(self)

end

function QUIDialogSoulLetterAwardPreviewNew:setFinalAvatar( )
	local finalAward = self._activityProxy:getFinalAward()

	if q.isEmpty(finalAward) == false then
		local award = {}
		self._finalAward = finalAward
		remote.items:analysisServerItem(finalAward.rare_reward1, award)
		local itemConfig = db:getItemByID(award[1].id)
		local skins = string.split(itemConfig.content, "^") --tonumber(skins[2])
	    local skinConfig = remote.heroSkin:getSkinConfigDictBySkinId(tonumber(skins[2]))
	    if q.isEmpty(skinConfig) == false then
	    	local characterConfig = db:getCharacterByID(skinConfig.character_id)
	        self._ccbOwner.node_avatar:removeAllChildren()
	        self._skinAvatar = QUIWidgetHeroInformation.new()
	        self._ccbOwner.node_avatar:addChild(self._skinAvatar)
		    self._skinAvatar:setAvatarByHeroInfo({skinId = skinConfig.skins_id}, skinConfig.character_id, 1)
		    self._skinAvatar:setNameVisible(false)
		end
	end
end

function QUIDialogSoulLetterAwardPreviewNew:setInfo()
	local normalAwards = {}
	local eliteAwards = {}
	for _, value in ipairs(self._awards) do
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

    self._realNormalAwards = {}
    self._realEliteAwards = {}
	for i, value in pairs(normalAwards) do
		self._realNormalAwards[#self._realNormalAwards+1] = value
	end
	for i, value in pairs(eliteAwards) do
		self._realEliteAwards[#self._realEliteAwards+1] = value
	end
    table.sort(self._realNormalAwards, handler(self, self.sortAwards))
    table.sort(self._realEliteAwards, handler(self, self.sortAwards))

end

function QUIDialogSoulLetterAwardPreviewNew:initListViewNormal()
	if not self._awardsListViewleft then
        local function showItemInfo(x, y, itemBox, listView)
            app.tip:itemTip(itemBox._itemType, itemBox._itemID)
        end
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._realNormalAwards[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end

	           	self:setItemInfo(item, itemData)

				list:registerItemBoxPrompt(index, 1, item._itemNode, nil, showItemInfo)

	            info.item = item
	            info.size = CCSizeMake(80,80)
	            return isCacheNode
	        end,
	        spaceX = 0,
	        spaceY = 5,
	        ignoreCanDrag = false,
	        isVertical = false,
	        enableShadow = false,
	        totalNumber = #self._realNormalAwards 
 		}
 		self._awardsListViewleft = QListView.new(self._ccbOwner.layout_normal, cfg)  	
	else
		self._awardsListViewleft:reload({totalNumber = #self._realNormalAwards})
	end
end

function QUIDialogSoulLetterAwardPreviewNew:initListViewElite()
	if not self._awardsListViewRight then
        local function showItemInfo(x, y, itemBox, listView)
            app.tip:itemTip(itemBox._itemType, itemBox._itemID)
        end
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local itemData = self._realEliteAwards[index]
	            local item = list:getItemFromCache()
	            if not item then
	                item = QUIWidgetQlistviewItem.new()
	                isCacheNode = false
	            end

	           	self:setItemInfo(item, itemData)

				list:registerItemBoxPrompt(index, 1, item._itemNode, nil, showItemInfo)

	            info.item = item
	            info.size = CCSizeMake(80,80)
	            return isCacheNode
	        end,
	        multiItems = 2,
	        spaceX = 0,
	        spaceY = -5,
	        ignoreCanDrag = false,
	        isVertical = false,
	        enableShadow = false,
	        totalNumber = #self._realEliteAwards 
 		}
 		self._awardsListViewRight = QListView.new(self._ccbOwner.layout_hight, cfg)  	
	else
		self._awardsListViewRight:reload({totalNumber = #self._realEliteAwards})
	end
end

function QUIDialogSoulLetterAwardPreviewNew:sortAwards(a, b)
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
	elseif a.id and b.id then
		return a.id > b.id		
	else
		return false
	end
end

function QUIDialogSoulLetterAwardPreviewNew:setItemInfo( item, itemData )
	if not item._itemNode then
		item._itemNode = QUIWidgetItemsBox.new()
		item._itemNode:setPosition(ccp(80/2,80/2))
		item._itemNode:setScale(0.8)
		item._ccbOwner.parentNode:addChild(item._itemNode)
		item._ccbOwner.parentNode:setContentSize(CCSizeMake(80,80))
	end

	item._itemNode:setPromptIsOpen(true)
	item._itemNode:setGoodsInfo(itemData.id, itemData.typeName, itemData.count)
end

function QUIDialogSoulLetterAwardPreviewNew:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSoulLetterAwardPreviewNew:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulLetterAwardPreviewNew:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulLetterAwardPreviewNew

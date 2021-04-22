--
-- Author: Your Name
-- Date: 2014-10-21 18:30:20
--
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogAwardsTip = class("QUIDialogAwardsTip", QUIDialog)
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogAwardsTip:ctor(options)
  	local ccbFile = "ccb/Dialog_Panjun_jiangli.ccbi"
  	local callbacks = {}
  	QUIDialogAwardsTip.super.ctor(self, ccbFile, callbacks, options)

  	if options then
		self._awards = options.awards
		self._title = options.title
		self._callBack = options.callBack
	end
	self._avatar = self._ccbOwner.node_avatar
	if options and options.otherRole then
		self._ccbOwner.node_avatar:setVisible(false)
		self._ccbOwner.node_avatar_rongrong:setVisible(true)

		self._avatar = self._ccbOwner.node_avatar_rongrong
	end

	self._avatarPosX = self._avatar:getPositionX()

	self:setAwardsItem()
	self:setTitle()

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")

    self._isEnd = false
	scheduler.performWithDelayGlobal(function ()
		self._isEnd = true
	end, 0.5)
end

function QUIDialogAwardsTip:viewDidAppear()
	QUIDialogAwardsTip.super.viewDidAppear(self)
    self._animationManager:connectScriptHandler(function(name)
    	self:close()
    end)
end

function QUIDialogAwardsTip:viewWillDisappear()
	QUIDialogAwardsTip.super.viewWillDisappear(self)
end


function QUIDialogAwardsTip:setAwardsItem()
	if next(self._awards) == nil then return end 

	local awardsNum = #self._awards
	local gap = 30
	if awardsNum == 3 then
		gap = 25
	elseif awardsNum == 4 then
		gap = 20
	end
	local startPositionX = - (awardsNum-1)*(100+gap)/2
	if (startPositionX - 50) < self._avatarPosX then
		self._avatar:setPositionX(startPositionX - 50)
	end
	local index = 1
	while index <= awardsNum do
		local itemBox = QUIWidgetItemsBox.new()
		local itemType = remote.items:getItemType(self._awards[index].typeName or self._awards[index].type)
		itemBox:setGoodsInfo(self._awards[index].id, itemType, self._awards[index].count)
		self._ccbOwner.item_node:addChild(itemBox) 
		local contentSize = itemBox:getContentSize()
		itemBox:setPositionX(startPositionX+(index-1)*(100+gap))
		index = index + 1
	end
end

function QUIDialogAwardsTip:setTitle()
	if self._title ~= nil then
		self._ccbOwner.tf_title:setString(self._title)
	end
end

function QUIDialogAwardsTip:_backClickHandler()
	if self._isEnd == true then
		self:close()
	end
end

function QUIDialogAwardsTip:close()
    self:popSelf()
	
	if self._callBack then
		self._callBack()
	end
end

return QUIDialogAwardsTip

-- @Author: liaoxianbo
-- @Date:   2020-08-04 15:39:10
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-17 11:19:38
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMazeExploreGainReward = class("QUIDialogMazeExploreGainReward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogMazeExploreGainReward:ctor(options)
	local ccbFile = "ccb/Dialog_MazeExplore_getAwards.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogMazeExploreGainReward.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    	self._awards = options.awards or {}
    	self._des = options.des
    end
    QPrintTable(self._awards)
    self:initView()
end

function QUIDialogMazeExploreGainReward:viewDidAppear()
	QUIDialogMazeExploreGainReward.super.viewDidAppear(self)

	-- self:addBackEvent(false)
end

function QUIDialogMazeExploreGainReward:viewWillDisappear()
  	QUIDialogMazeExploreGainReward.super.viewWillDisappear(self)

	-- self:removeBackEvent()
end

function QUIDialogMazeExploreGainReward:initView( )
	self._ccbOwner.tf_txt:setString(self._des or "")
	-- self._awards = db:getluckyDrawById(self._luckyDrawId)

	local itemBoxs = {}
	local index = 1
	local width = 0
	local gap = 30
	local contentSize
	for _, award in pairs(self._awards) do
		itemBoxs[index] = QUIWidgetItemsBox.new()
		-- QPrintTable(award)
		if award.id then
			itemBoxs[index]:setGoodsInfo(tonumber(award.id), award.typeName, tonumber(award.count))
		else
			itemBoxs[index]:setGoodsInfo(nil, award.typeName, tonumber(award.count))
		end
		itemBoxs[index]:setPromptIsOpen(true)
		itemBoxs[index]:showEffect()
		itemBoxs[index]:setGloryTowerType(false)
		self._ccbOwner.node_item:addChild( itemBoxs[index] )

		contentSize = itemBoxs[index]:getContentSize()
		itemBoxs[index]:setPositionX(width)
		width = width + contentSize.width + gap
		index = index + 1
	end
	if contentSize then
		local posX = self._ccbOwner.node_item:getPositionX()
		self._ccbOwner.node_item:setPositionX(posX - width/2 + (contentSize.width + gap)/2)
	end
end

function QUIDialogMazeExploreGainReward:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMazeExploreGainReward:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogMazeExploreGainReward:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogMazeExploreGainReward

 -- @Author: xurui
-- @Date:   2019-08-30 14:41:31
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-09-02 19:14:41
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRankAwardRecord = class("QUIDialogRankAwardRecord", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetRankAwardRecordClient = import("..widgets.QUIWidgetRankAwardRecordClient")

function QUIDialogRankAwardRecord:ctor(options)
	local ccbFile = "ccb/Dialog_rank_award.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogRankAwardRecord.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._recordList = {}
    if options then
    	self._callBack = options.callBack
    	self._recordList = options.record or {}
    end
end

function QUIDialogRankAwardRecord:viewDidAppear()
	QUIDialogRankAwardRecord.super.viewDidAppear(self)

	self:setClient()
end

function QUIDialogRankAwardRecord:viewWillDisappear()
  	QUIDialogRankAwardRecord.super.viewWillDisappear(self)

end

function QUIDialogRankAwardRecord:setClient()
	local positionY = 0
	local gapY = 10
	for index, value in ipairs(self._recordList) do
		if index > 5 then break end
		local client = QUIWidgetRankAwardRecordClient.new()
		self._ccbOwner.node_client:addChild(client)
		client:setInfo(value, index)
		client:setPositionY(-positionY)
		local contentSize = client:getContentSize()
		positionY = positionY + contentSize.height + gapY
	end
end

function QUIDialogRankAwardRecord:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogRankAwardRecord:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogRankAwardRecord:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogRankAwardRecord


-- @Author: xurui
-- @Date:   2016-10-21 14:40:02
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-11-05 11:34:43
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogWorldBossRecord = class("QUIDialogWorldBossRecord", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetWorldBossRecordClient = import("..widgets.QUIWidgetWorldBossRecordClient")
local QScrollView = import("...views.QScrollView") 

function QUIDialogWorldBossRecord:ctor(options)
	local ccbFile = "ccb/Dialog_Panjun_Boss_zhanbao.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogWorldBossRecord.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("战 报")
	self:initScrollView()
end

function QUIDialogWorldBossRecord:viewDidAppear()
	QUIDialogWorldBossRecord.super.viewDidAppear(self)

	remote.worldBoss:requestWorldBossLog(function ()
		self:setRecordInfo()
	end)
end

function QUIDialogWorldBossRecord:viewWillDisappear()
	QUIDialogWorldBossRecord.super.viewWillDisappear(self)
end

function QUIDialogWorldBossRecord:initScrollView()
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {bufferMode = 2, sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)
	self._scrollView:setGradient(true)
	self._scrollView:replaceGradient(self._ccbOwner.top_shadow, self._ccbOwner.bottom_shadow, nil, nil)
end

function QUIDialogWorldBossRecord:setRecordInfo()
	local itemContentSize, buffer = self._scrollView:setCacheNumber(7, "widgets.QUIWidgetWorldBossRecordClient")

	local logInfos = remote.worldBoss:getWorldBossLog()

	if table.nums(logInfos) > 0 then
		self._ccbOwner.node_no:setVisible(false)
	else
		self._ccbOwner.node_no:setVisible(true)
	end

	table.sort( logInfos, function(a, b)
			return a.bossLevel > b.bossLevel
		end )

	local row = 0
	local line = 0
	local offsetX = 5
	local offsetY = 38
	for i = 1, #logInfos do
		local positionX = 0
		local positionY = -itemContentSize.height * line

		self._scrollView:addItemBox(positionX, positionY, {logInfos = logInfos[i], index = i})

		line = line + 1
	end
	local totalWidth = itemContentSize.width
	local totalHeight = itemContentSize.height * line
	self._scrollView:setRect(0, -totalHeight, 0, totalWidth)
end

function QUIDialogWorldBossRecord:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogWorldBossRecord:onTriggerHomeHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

function QUIDialogWorldBossRecord:_backClickHandler()
  	app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogWorldBossRecord:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_close) == false then return end
  	app.sound:playSound("common_close")
    self:playEffectOut()
end

function QUIDialogWorldBossRecord:viewAnimationOutHandler()
    self:popSelf()
end

return QUIDialogWorldBossRecord
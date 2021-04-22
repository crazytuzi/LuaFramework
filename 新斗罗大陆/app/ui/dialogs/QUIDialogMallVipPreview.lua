--
-- Author: xurui
-- Date: 2015-04-24 16:59:09
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMallVipPreview = class("QUIDialogMallVipPreview", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView") 
local QUIWidgetMallVipPreviewBox = import("..widgets.QUIWidgetMallVipPreviewBox")

function QUIDialogMallVipPreview:ctor(options)
	local ccbFile = "ccb/Dialog_GiftPreview.ccbi"
	local callBacks = {
			{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)}
		}
	QUIDialogMallVipPreview.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
	self._ccbOwner.frame_tf_title:setString("礼包预览")
	if options ~= nil then
		self._itemInfo = options.itemInfo
	end
	self._contentSize = self._ccbOwner.sheet_layout:getContentSize()
	self._itemBox = {}
	self:setScrollView()
	self:setItemBox()
end

function QUIDialogMallVipPreview:viewDidAppear()
	QUIDialogMallVipPreview.super.viewDidAppear(self)
	self.prompt = app:promptTips()
	self.prompt:addItemEventListener(self)
end

function QUIDialogMallVipPreview:viewWillDisappear()
  	QUIDialogMallVipPreview.super.viewWillDisappear(self)
  	self.prompt:removeItemEventListener()
  	self:cleanItemBox()
end

function QUIDialogMallVipPreview:cleanItemBox()
	if next(self._itemBox) then
		for k, value in pairs(self._itemBox) do
			self._itemBox[k]:removeFromParent()
			self._itemBox[k] = nil
		end
	end
end

function QUIDialogMallVipPreview:setScrollView()
	self._itemWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._itemHeight = self._ccbOwner.sheet_layout:getContentSize().height

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._itemWidth, self._itemHeight), {sensitiveDistance = 10})
	self._scrollView:setGradient(false)
end

function QUIDialogMallVipPreview:setItemBox()
	self._itemInfos = {}
	local info = QStaticDatabase:sharedDatabase():getItemByID(self._itemInfo.id)
	self._itemInfos = string.split(info.content, ";")

	self._totalHeight = 0
	self._totalWidth = 0
	for i = 1, #self._itemInfos, 1 do
		local itemInfos = string.split(self._itemInfos[i], "^")

		self._itemBox[i] = QUIWidgetMallVipPreviewBox.new()
		self._itemBox[i]:setItemBoxInfo(itemInfos)
		self._scrollView:addItemBox(self._itemBox[i])

	    local contentSize = self._itemBox[i]:getContentSize()
	    self._itemBox[i]:setPosition(0, -contentSize.height * (i-1))

		self._totalHeight = self._totalHeight + self._itemBox[i]:getContentSize().height
	end
	self._scrollView:setRect(0, -self._totalHeight - 10, 0, self._totalWidth)
    self._scrollView:setContentSize(self._totalWidth, self._totalHeight + 10)
end

function QUIDialogMallVipPreview:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMallVipPreview:_backClickHandler()
    self:_onTriggerClose()
end

function  QUIDialogMallVipPreview:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

return QUIDialogMallVipPreview
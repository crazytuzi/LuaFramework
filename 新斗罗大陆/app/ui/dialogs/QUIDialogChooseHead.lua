--
-- Author: Qinyuanji
-- Date: 2014-11-19 
-- This class is the dialog for changing avatar, it includes QUIWidgetChooseHead.

local QUIDialog = import(".QUIDialog")
local QUIDialogChooseHead = class("QUIDialogChooseHead", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetChooseHead = import("..widgets.QUIWidgetChooseHead")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QScrollView = import("...views.QScrollView")

QUIDialogChooseHead.MOVEMENT_MINIMUM_PIXEL = 10

function QUIDialogChooseHead:ctor(options)
	local ccbFile = "ccb/Dialog_ChooseHead.ccbi";
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogChooseHead._onTriggerClose)},
	}
	QUIDialogChooseHead.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self:_initHeroPageSwipe()
end

-- Init page size and touch layer area
function QUIDialogChooseHead:_initHeroPageSwipe()
	self._ccbOwner.desc:setVisible(false)
	self._widgetChooseHead = QUIWidgetChooseHead.new({parent = self}) 
	self._widgetChooseHead:addEventListener( QUIWidgetChooseHead.CLICK_AVATAR_HEAD, handler(self, self._avatarChange))

	self._pageWidth = self._ccbOwner.sheet_layout:getContentSize().width
	self._pageHeight = self._ccbOwner.sheet_layout:getContentSize().height

	self._scrollView = QScrollView.new(self._ccbOwner.sheet, CCSize(self._pageWidth, self._pageHeight), {sensitiveDistance = 10})
	self._scrollView:setVerticalBounce(true)

	self._widgetChooseHead:setPositionX(self._pageWidth/2)
	self._scrollView:addItemBox(self._widgetChooseHead)
	self._scrollView:setRect(0, -self._widgetChooseHead:getContentHeight(), 0, self._pageWidth)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogChooseHead:viewDidAppear()
	QUIDialogChooseHead.super.viewDidAppear(self)
    
end

function QUIDialogChooseHead:viewWillDisappear()	
	QUIDialogChooseHead.super.viewWillDisappear(self)
	
end 

function QUIDialogChooseHead:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogChooseHead:_avatarChange(event)
	if event.newAvatarId == nil then return end
	
	local newAvatar = remote.headProp:getAvatar(event.newAvatarId, nil)
    remote.headProp:changeAvatarRequest(newAvatar, nil, function (data)
    		if self:safeCheck() then
				app.tip:floatTip("恭喜您, 成功修改头像")
    			self:_onTriggerClose()
    		end
		end)
end

function QUIDialogChooseHead:isMoving( ... )
	return self._isMoving
end

function QUIDialogChooseHead:_onScrollViewMoving()
	self._isMoving = true
end

function QUIDialogChooseHead:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogChooseHead:_onTriggerCancel()
	self:_onTriggerClose()
end

function QUIDialogChooseHead:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogChooseHead:_onTriggerClose(e)
	if e ~= nil then 
		app.sound:playSound("common_cancel")
	end
    self:playEffectOut()
end

return QUIDialogChooseHead

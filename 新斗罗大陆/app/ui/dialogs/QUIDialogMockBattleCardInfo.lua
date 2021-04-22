-- 大师赛选择卡片的信息界面
-- Author: Qinsiyang
-- 
--
local QUIDialog = import(".QUIDialog")
local QUIDialogMockBattleCardInfo = class("QUIDialogMockBattleCardInfo", QUIDialog)
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QMockBattle = import("..network.models.QMockBattle")
local QUIViewController = import("..QUIViewController")

local QListView = import("...views.QListView")
local QUIWidgetMockBattleCardInfo = import("..widgets.QUIWidgetMockBattleCardInfo")
local QScrollView = import("...views.QScrollView") 



function QUIDialogMockBattleCardInfo:ctor(options)
	local ccbFile = "ccb/Dialog_MockBattle_CardInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMockBattleCardInfo.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
    self._ccbOwner.frame_tf_title:setString("当前卡组")

	self.chooseInfo = options.info
	self._isDouble = options.isDouble or false

    self._isMoving = false

end

function QUIDialogMockBattleCardInfo:viewDidAppear()
    QUIDialogMockBattleCardInfo.super.viewDidAppear(self)
end


function QUIDialogMockBattleCardInfo:viewAnimationInHandler()
    self:setSelfInfo()
end

function QUIDialogMockBattleCardInfo:viewWillDisappear()
    QUIDialogMockBattleCardInfo.super.viewWillDisappear(self)
end


function QUIDialogMockBattleCardInfo:setSelfInfo()
    local scrollSize = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, scrollSize, {bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setVerticalBounce(true)
    self._scrollView:setHorizontalBounce(false)
    local item = QUIWidgetMockBattleCardInfo.new({isDouble = self._isDouble})
    item:setInfo(self.chooseInfo)
    item:setTouchHandle( handler(self, self.getMoveState))
    self._scrollView:addItemBox(item)
    self._scrollView:setRect(0, -item:getContentSize().height, 0, scrollSize.width)
    -- self._scrollView:moveTo(0, 0, false)

    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
end

function QUIDialogMockBattleCardInfo:getMoveState()
    return self._isMoving
end

function QUIDialogMockBattleCardInfo:_onScrollViewBegan()
	self._isMoving = false
end

function QUIDialogMockBattleCardInfo:_onScrollViewMoving()
	self._isMoving = true
end


function QUIDialogMockBattleCardInfo:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	if event ~= nil then 
		app.sound:playSound("common_cancel")
	end
    self:playEffectOut()
    if self._backCallback then
    	self._backCallback()
    end
end

function QUIDialogMockBattleCardInfo:_backClickHandler()
	--代码
    self:playEffectOut()
end


function QUIDialogMockBattleCardInfo:onTriggerBackHandler()
    self:playEffectOut()
    if self._backCallback then
    	self._backCallback()
    end
end

return QUIDialogMockBattleCardInfo
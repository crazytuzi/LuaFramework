-- @Author: zhouxiaoshu
-- @Date:   2019-08-12 15:16:23
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-08-27 14:41:03

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogVipLevelUpSuccess = class("QUIDialogVipLevelUpSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QCircleUiMask = import("..battle.QCircleUiMask")

local ANI_TIME = 1.5

function QUIDialogVipLevelUpSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_vip_up.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogVipLevelUpSuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._callback = options.callback
    self._isEnd = false

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:stopAnimation()
    self:setInfo()
end

function QUIDialogVipLevelUpSuccess:viewDidAppear()
	QUIDialogVipLevelUpSuccess.super.viewDidAppear(self)
end

function QUIDialogVipLevelUpSuccess:viewWillDisappear()
	QUIDialogVipLevelUpSuccess.super.viewWillDisappear(self)
	
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
end

function QUIDialogVipLevelUpSuccess:setInfo()
    local sprite = CCSprite:createWithTexture(self._ccbOwner.sp_circle:getTexture())
    self._expCircle = QCircleUiMask.new({hideWhenFull = true})
    self._expCircle:setMaskSize(sprite:getContentSize())
    self._expCircle:addChild(sprite)
    self._ccbOwner.node_circle:addChild(self._expCircle)
    self._ccbOwner.sp_circle:setVisible(false)
    self._ccbOwner.node_vip_level:setVisible(false)
    self._ccbOwner.node_tips:setVisible(false)
    self._ccbOwner.tf_exp:setVisible(false)

    local vipLevel = QVIPUtil:VIPLevel()
    local vipExp = QVIPUtil:cash(vipLevel+1)
    self._ccbOwner.tf_vip_level:setString(vipLevel)
    self._ccbOwner.tf_exp:setString(tostring(remote.user.totalRechargeToken) .. "/" .. vipExp)

	local progress = 0
    local width = self._ccbOwner.sp_circle:getContentSize().width/2
    self._expCircle:update(1-progress/100)
	self._scheduler = scheduler.scheduleGlobal(function ()
		progress = progress + 1
        local curAngle = progress*3.6
        local posX = width*math.sin(math.rad(curAngle))
        local posY = width*math.cos(math.rad(curAngle))
        self._ccbOwner.node_effect:setPosition(ccp(posX, posY))
        self._ccbOwner.node_effect:setRotation(curAngle-18)
        self._expCircle:update(1-progress/100)
        self._expCircle:setInverted(true)
        if progress >= 100 then
			scheduler.unscheduleGlobal(self._scheduler)
			self:showVipLevelUpAni()
    	end
	end, 0.015)
end

function QUIDialogVipLevelUpSuccess:showVipLevelUpAni()
    self._ccbOwner.node_vip_level:setVisible(true)
    self._ccbOwner.sp_circle:setVisible(true)
    self._ccbOwner.node_tips:setVisible(true)
    self._ccbOwner.tf_exp:setVisible(true)
    self._ccbOwner.node_effect:setVisible(false)

    self._animationManager:runAnimationsForSequenceNamed("Default Timeline")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))
end

function QUIDialogVipLevelUpSuccess:animationEndHandler()
    self._isEnd = true
end

function QUIDialogVipLevelUpSuccess:_backClickHandler()
    if self._isEnd then
        self:_onTriggerClose()
    end
end

function QUIDialogVipLevelUpSuccess:_onTriggerClose(event)
  	if event then
        app.sound:playSound("common_close")
    end
	self:playEffectOut()
end

function QUIDialogVipLevelUpSuccess:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogVipLevelUpSuccess

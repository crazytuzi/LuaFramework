-- @Author: liaoxianbo
-- @Date:   2020-03-01 12:45:42
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-21 16:00:46
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpiritFirePoint = class("QUIWidgetSoulSpiritFirePoint", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")

QUIWidgetSoulSpiritFirePoint.EVENT_POINT_CLICK = "EVENT_POINT_CLICK"

function QUIWidgetSoulSpiritFirePoint:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_firePoint.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerTouchPoint", callback = handler(self, self._onTriggerTouchPoint)},
    }
    QUIWidgetSoulSpiritFirePoint.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._pointColor = 1
end

function QUIWidgetSoulSpiritFirePoint:onEnter()
end

function QUIWidgetSoulSpiritFirePoint:onExit()
end


function QUIWidgetSoulSpiritFirePoint:getContentSize()
end

function QUIWidgetSoulSpiritFirePoint:setPointInfo(treetype,pointInfo)
	self._touchPoint = pointInfo.cell_id
	self._treeType = treetype

	self._pointColor = pointInfo.color or 1
	local bigpoinRes = QResPath("soulspirit_bigpoint_res")[self._pointColor] or {}
	QSetDisplaySpriteByPath(self._ccbOwner.sp_point_unlock,bigpoinRes[1])
	QSetDisplaySpriteByPath(self._ccbOwner.sp_point_lock,bigpoinRes[2])
	QSetDisplaySpriteByPath(self._ccbOwner.sp_point_light,bigpoinRes[3])

	if self._touchPoint == 0 then
		-- self:showFireLoopEffect(1)
		self._ccbOwner.btn_click:setEnabled(false)
		self._ccbOwner.sp_point_unlock:setVisible(false)
		self._ccbOwner.sp_point_lock:setVisible(false)
		self._ccbOwner.tf_point_num:setVisible(false)
		self._ccbOwner.sp_point_light:setVisible(true)
		return
	end
	-- self._ccbOwner.tf_point_num:setVisible(true)
	-- self._ccbOwner.tf_point_num:setString(self._touchPoint)
	self._ccbOwner.tf_point_num:setVisible(false)
	

	self:showState()
end

function QUIWidgetSoulSpiritFirePoint:showState()
	
	if self._touchPoint == 0 then
		return
	end

	local isLocked = remote.soulSpirit:checkBigPointCanUpgrade(self._treeType,self._touchPoint)

	-- self._ccbOwner.btn_click:setEnabled(isLocked)

	local state = remote.soulSpirit:getMainSoulSpiritFireState(self._treeType,self._touchPoint)
	if state == remote.soulSpirit.FIRE_TATE_ACTIVITE then
		self._ccbOwner.sp_point_unlock:setVisible(false)
		self._ccbOwner.sp_point_lock:setVisible(false)
		self._ccbOwner.sp_point_light:setVisible(true)
		-- self:showFireLoopEffect()
	else
		if isLocked then
			self:showFireLockEffect()
		end
		self._ccbOwner.sp_point_unlock:setVisible(not isLocked)
		self._ccbOwner.sp_point_lock:setVisible(isLocked)
		self._ccbOwner.sp_point_light:setVisible(false)			
	end
end

function QUIWidgetSoulSpiritFirePoint:showChooseState(isShow)
	self._ccbOwner.sp_chooseTate:setVisible(isShow)
end
-- self:_createAnimation( "ccb/effects/chenghao_1.ccbi", 0, 0, 1, node )
function QUIWidgetSoulSpiritFirePoint:ShowBaoZhaAnimation()
	local colorNum = self._pointColor
	if tonumber(colorNum) and colorNum > 3 then
		colorNum = 3
	end
	local hallEffect = QResPath("soulspirit_bigpoint_effect")[colorNum] or {}

    local fcaAnimation = QUIWidgetFcaAnimation.new(hallEffect[2], "res")

	fcaAnimation:playAnimation("animation", false)
	self._ccbOwner.node_boom_effect:addChild(fcaAnimation)
	fcaAnimation:setEndCallback(function( )
		fcaAnimation:removeFromParent()
		self:showFireLoopEffect()
	end)
end

function QUIWidgetSoulSpiritFirePoint:showFireLoopEffect( )
	local colorNum = self._pointColor
	if tonumber(colorNum) and colorNum > 3 then
		colorNum = 3
	end
	if not self._loopfcaAnimation then
		local hallEffect = QResPath("soulspirit_bigpoint_effect")[colorNum] or {}
		if hallEffect[3] then
			self._ccbOwner.node_loop_effect:removeAllChildren()
		    self._loopfcaAnimation = QUIWidgetFcaAnimation.new(hallEffect[3], "res")
			self._loopfcaAnimation:playAnimation("animation", true)
			self._ccbOwner.node_loop_effect:addChild(self._loopfcaAnimation)
		end
	end
end

function QUIWidgetSoulSpiritFirePoint:showFireLockEffect( )
	local colorNum = self._pointColor
	if tonumber(colorNum) and colorNum > 3 then
		colorNum = 3
	end
	
	if not self._lockfcaAnimation then
		local hallEffect = QResPath("soulspirit_bigpoint_effect")[colorNum] or {}

	    self._lockfcaAnimation = QUIWidgetFcaAnimation.new(hallEffect[4], "res")
		self._lockfcaAnimation:playAnimation("animation", true)
		self._ccbOwner.node_loop_effect:addChild(self._lockfcaAnimation)
	end
end

function QUIWidgetSoulSpiritFirePoint:_onTriggerTouchPoint()
	if self._touchPoint then
		self:dispatchEvent({name = QUIWidgetSoulSpiritFirePoint.EVENT_POINT_CLICK,bigPoint = self._touchPoint})
	end
end

return QUIWidgetSoulSpiritFirePoint

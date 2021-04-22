--
-- Author: wkwang
-- Date: 2014-08-22 17:30:59
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetLoadBar = class("QUIWidgetLoadBar", QUIWidget)
local QSkeletonViewController = import("...controllers.QSkeletonViewController")

function QUIWidgetLoadBar:ctor(options)
	local ccbFile = "ccb/Widget_LoginPressBar.ccbi"
	print("ccbFile = "..ccbFile)
	local callBacks = {}
	QUIWidgetLoadBar.super.ctor(self, ccbFile, callBacks, options)

	self._size = self._ccbOwner.node_bar:getContentSize()
	self._ccbOwner.node_bar:setPreferredSize(CCSize(display.ui_width, self._size.height))
	self._ccbOwner.node_bar_bg:setPreferredSize(CCSize(display.ui_width, self._size.height))
	self._size = self._ccbOwner.node_bar:getContentSize()        --xurui:重新获取进度条大小

	self._masklayer = CCLayerColor:create(ccc4(0,0,0,150),self._size.width,self._size.height)
	self._masklayer:setAnchorPoint(ccp(0,0.5))
	local ccclippingNode = CCClippingNode:create()
	ccclippingNode:setStencil(self._masklayer)
	self._ccbOwner.node_bar:retain()
	self._ccbOwner.node_bar:removeFromParent()
	self._ccbOwner.node_bar:setPosition(0, 0)
	ccclippingNode:addChild(self._ccbOwner.node_bar)
	self._ccbOwner.node_bar:release()
	ccclippingNode:setPosition(-self._size.width/2, 0)
	self._ccbOwner.node_mask:addChild(ccclippingNode)

	self:setPercent(0)
	self:resetAll()
end

function QUIWidgetLoadBar:resetAll()
    if CCNode.wakeup then
        self:wakeup()
    end
	self._masklayer:setScaleX(0)
	self._ccbOwner.node_light:setVisible(false)
	self._ccbOwner.percentNode:setVisible(false)
	self._ccbOwner.tip:setVisible(false)
end

function QUIWidgetLoadBar:setPercent(percent)
    if CCNode.wakeup then
        self:wakeup()
    end
	self._masklayer:setScaleX(percent)
	self._ccbOwner.node_light:setVisible(true)
	self._ccbOwner.tf_percent:setString(string.format("%d",percent*100).."%")
	local width = self._ccbOwner.node_bar:getContentSize().width
   	self._ccbOwner.node_light:setPositionX(self._ccbOwner.node_bar:getPositionX() + width * (percent - 0.5))
end

function QUIWidgetLoadBar:_onFrame(dt)
    -- self._fca:updateAnimation(dt)
end

function QUIWidgetLoadBar:setTip(tip)
	self._ccbOwner.tip:setString(tip)
end

function QUIWidgetLoadBar:setTipVisible(visible)
	self._ccbOwner.tip:setVisible(visible)
end

function QUIWidgetLoadBar:setPercentVisible(visible)
	self._ccbOwner.percentNode:setVisible(visible)
end

return QUIWidgetLoadBar
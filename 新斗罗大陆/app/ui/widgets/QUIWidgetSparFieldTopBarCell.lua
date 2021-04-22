
local QUIWidgetTopBarCell = import("..widgets.QUIWidgetTopBarCell")
local QUIWidgetSparFieldTopBarCell = class("QUIWidgetSparFieldTopBarCell", QUIWidgetTopBarCell)
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetSparFieldTopBarCell:ctor(options)
	local ccbFile = "ccb/Widget_tap.ccbi"
	local callBacks = {
        {ccbCallbackName = "onPlus", callback = handler(self, QUIWidgetSparFieldTopBarCell._onPlus)}
    }
	QUIWidgetSparFieldTopBarCell.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    self:showSunWarBattleBuff()
end

function QUIWidgetSparFieldTopBarCell:showSunWarBattleBuff( num )
	if num and num > 0 then
		self._ccbOwner.node_buff_up:setVisible(true)
		self._ccbOwner.node_fire:setVisible(true)
		self._ccbOwner.tf_buff_num:setString(num.."%")
	else
		self._ccbOwner.node_buff_up:setVisible(false)
		self._ccbOwner.node_fire:setVisible(false)
		self._ccbOwner.tf_buff_num:setString("")
	end
end

function QUIWidgetSparFieldTopBarCell:showTipsAnimation(value)
	local ccbFile = "ccb/effects/zhanchang_fire_boom.ccbi"
	local aniPlayer = QUIWidgetAnimationPlayer.new()
    self._ccbOwner.node_fire_boom:addChild(aniPlayer)
    aniPlayer:playAnimation(ccbFile, function ()
    	QUIWidgetSparFieldTopBarCell.super.showTipsAnimation(self,value)
		if value > 0 then
			local icon = self:getIcon()
			local arr = CCArray:create()
			arr:addObject(CCScaleTo:create(8/30, 1.6, 1.6))
			arr:addObject(CCScaleTo:create(2/30, 0.9, 0.9))
			arr:addObject(CCScaleTo:create(3/30, 1, 1)) 
			icon:runAction(CCSequence:create(arr))
		end
    end)
end

return QUIWidgetSparFieldTopBarCell
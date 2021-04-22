
local QUIWidgetTopBarCell = import("..widgets.QUIWidgetTopBarCell")
local QUIWidgetSunWarTopBarCell = class("QUIWidgetSunWarTopBarCell", QUIWidgetTopBarCell)
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

function QUIWidgetSunWarTopBarCell:ctor(options)
	QUIWidgetSunWarTopBarCell.super.ctor(self, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
    self:showSunWarBattleBuff()
end

function QUIWidgetSunWarTopBarCell:onEnter( ... )
end

function QUIWidgetSunWarTopBarCell:showSunWarBattleBuff( num )
	if num and num > 0 then
		self._ccbOwner.node_buff_up:setVisible(true)
		self._ccbOwner.node_fire:setVisible(true)
		self._ccbOwner.tf_buff_num:setString(num.."%")
	else
		self._ccbOwner.node_buff_up:setVisible(false)
		self._ccbOwner.node_fire:setVisible(false)
		self._ccbOwner.tf_buff_num:setString("")
	end

	if ENABLE_PVP_FORCE then
		self._ccbOwner.node_buff_up:setPositionX(125)
	else
		self._ccbOwner.node_buff_up:setPositionX(85)
	end
end

function QUIWidgetSunWarTopBarCell:showTipsAnimation(value)
	if remote.sunWar:getIsBuffEffectPlaying() then
		remote.sunWar:setIsBuffEffectPlaying(false)
		local pos, ccbFile = remote.sunWar:getFireBoomURL()
		local aniPlayer = QUIWidgetAnimationPlayer.new()
	    self._ccbOwner.node_fire_boom:addChild(aniPlayer)
	    aniPlayer:playAnimation(ccbFile, function ()
	    	QUIWidgetSunWarTopBarCell.super.showTipsAnimation(self,value)
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
end

return QUIWidgetSunWarTopBarCell
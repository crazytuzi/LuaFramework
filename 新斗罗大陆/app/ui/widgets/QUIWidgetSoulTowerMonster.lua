-- @Author: liaoxianbo
-- @Date:   2020-04-10 15:56:53
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-25 18:00:03
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulTowerMonster = class("QUIWidgetSoulTowerMonster", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")

function QUIWidgetSoulTowerMonster:ctor(options)
	local ccbFile = "ccb/Widget_SoulTower_boss.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetSoulTowerMonster.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	
end

function QUIWidgetSoulTowerMonster:resetAll( )
	self._ccbOwner.sp_dead:setVisible(false)
	self._ccbOwner.node_boss:setVisible(false)
	self._ccbOwner.tf_name:setVisible(false)
end

function QUIWidgetSoulTowerMonster:setMonserInfo(bossId,floorInfo)

	self:resetAll()

	self._historyFloor,self._historyWave = remote.soultower:getHistoryPassFloorWave()

	self._bossId = bossId
	self._floorInfo = floorInfo
	local maxFloor = remote.soultower:getMaxFloor()
	local floorDungenNum = remote.soultower:getMaxFloorDungenNum()
	if self._historyFloor > self._floorInfo.floor 
		or (self._historyFloor == self._floorInfo.floor and self._historyWave >= floorDungenNum) and maxFloor ~= self._floorInfo.floor then --已通关

		self._ccbOwner.sp_dead:setVisible(true)
	else
		self._ccbOwner.node_boss:setVisible(true)	
		self._ccbOwner.node_boss:removeAllChildren()
		local bossWidget = QUIWidgetHeroInformation.new()
		self._ccbOwner.node_boss:addChild(bossWidget)
		bossWidget:setAvatarByHeroInfo({}, self._bossId, 1)
		bossWidget:setNameVisible(false)
		bossWidget:setScaleX(-1)		
	end
end

function QUIWidgetSoulTowerMonster:showBossDeathEffect(index,callback,hideCallBack)
	self._ccbOwner.node_boss:setVisible(true)
	self._ccbOwner.node_boss:removeAllChildren()
	local bossWidget = QUIWidgetHeroInformation.new()
	self._ccbOwner.node_boss:addChild(bossWidget)
	bossWidget:setAvatarByHeroInfo({}, self._bossId, 1)
	bossWidget:setNameVisible(false)
	bossWidget:setScaleX(-1)
	local bossIndex = index
	bossWidget:getAvatar():setAutoStand(false)
	bossWidget:getAvatar():displayWithBehavior(ANIMATION_EFFECT.DEAD)
	bossWidget:getAvatar():setDisplayBehaviorCallback(function()
		if hideCallBack then
			hideCallBack()
		end
		if bossIndex == 3 then
			local dur1 = q.flashFrameTransferDur(25)
			scheduler.performWithDelayGlobal(function ()
				if callback then
					callback()
				end
			end,dur1)			

		end
	end)
end

function QUIWidgetSoulTowerMonster:onEnter()
end

function QUIWidgetSoulTowerMonster:onExit()
end

function QUIWidgetSoulTowerMonster:getContentSize()
end

return QUIWidgetSoulTowerMonster

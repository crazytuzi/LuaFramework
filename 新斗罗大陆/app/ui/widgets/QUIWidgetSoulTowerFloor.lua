-- @Author: liaoxianbo
-- @Date:   2020-04-10 15:53:36
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-02 16:23:59
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulTowerFloor = class("QUIWidgetSoulTowerFloor", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

QUIWidgetSoulTowerFloor.SOULTOWER_BTN_CLICK  = "SOULTOWER_BTN_CLICK"

function QUIWidgetSoulTowerFloor:ctor(options)
	local ccbFile = "ccb/Widget_soultower_floor.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetSoulTowerFloor.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._isChoose = false
end

function QUIWidgetSoulTowerFloor:resetAll( )
	self._ccbOwner.node_lock:setVisible(false)
	self._ccbOwner.node_jindu:setVisible(false)
	self._ccbOwner.sp_frame:setVisible(false)
	self._ccbOwner.sp_done:setVisible(false)
end

function QUIWidgetSoulTowerFloor:getFloorInfo( )
	local isLock,historyFloor,historyWave = remote.soultower:getHistoryLockFloorWave()
	local maxFloor = remote.soultower:getMaxFloor()
	local maxDungen = remote.soultower:getMaxFloorDungenNum()
	local compareDungen = historyWave + 1
	for _,v in pairs(self._allFloorInfo or {}) do
		if isLock == false and historyFloor == maxFloor and maxDungen == historyWave then
			compareDungen = historyWave
		end
		if v.dungeon == compareDungen then
			return v
		end
	end

	return nil
end

function QUIWidgetSoulTowerFloor:setFloorInfo(info)
	self:resetAll()
	-- self._floorInfo = info
	self._allFloorInfo = info

	self._floorInfo = self:getFloorInfo()
	if q.isEmpty(self._floorInfo) then
		return
	end
	
	if self._floorInfo.show_pic then
		QSetDisplaySpriteByPath(self._ccbOwner.sp_btBg,self._floorInfo.show_pic)
	end
	local size = self._ccbOwner.bg_mask:getContentSize()
	local lyImageMask = CCLayerColor:create(ccc4(0,0,0,150), size.width, size.height)
	local ccclippingNode = CCClippingNode:create()
	lyImageMask:setPositionX(self._ccbOwner.bg_mask:getPositionX())
	lyImageMask:setPositionY(self._ccbOwner.bg_mask:getPositionY())
	lyImageMask:ignoreAnchorPointForPosition(self._ccbOwner.bg_mask:isIgnoreAnchorPointForPosition())
	lyImageMask:setAnchorPoint(self._ccbOwner.bg_mask:getAnchorPoint())
	ccclippingNode:setStencil(lyImageMask)
	ccclippingNode:setInverted(false)
	self._ccbOwner.sp_btBg:retain()
	self._ccbOwner.sp_btBg:removeFromParent()
	ccclippingNode:addChild(self._ccbOwner.sp_btBg)
	self._ccbOwner.sp_btBg:release()
	self._ccbOwner.node_bg:addChild(ccclippingNode)
	
	self:updateFloorInfo()
end

function QUIWidgetSoulTowerFloor:updateFloorInfo( )
	if q.isEmpty(self._floorInfo) then
		return
	end
	local isLock,historyFloor,historyWave = remote.soultower:getHistoryLockFloorWave()
	local isUnlock = false
	if historyFloor > self._floorInfo.floor then -- 通关
		self._ccbOwner.node_lock:setVisible(false)
		self._ccbOwner.sp_done:setVisible(true)
		self._ccbOwner.node_jindu:setVisible(false)
		self._ccbOwner.layer_mask:setVisible(false)
	elseif historyFloor == self._floorInfo.floor then -- 解锁
		local isShowDone = historyWave < remote.soultower:getMaxFloorDungenNum()
		self._ccbOwner.node_lock:setVisible(false)
		self._ccbOwner.sp_done:setVisible(not isShowDone)
		self._ccbOwner.node_jindu:setVisible(isShowDone)
		self._ccbOwner.tf_proess:setString(historyFloor.."-"..historyWave)
		self._ccbOwner.layer_mask:setVisible(false)
	else --未解锁
		self._ccbOwner.node_lock:setVisible(true)
		self._ccbOwner.sp_done:setVisible(false)
		self._ccbOwner.node_jindu:setVisible(false)
		self._ccbOwner.layer_mask:setVisible(true)
		isUnlock = true
	end

	remote.soultower:showFloor(self._ccbOwner.node_ceng,self._floorInfo.floor,30,isUnlock)	
end

function QUIWidgetSoulTowerFloor:setSelect(flag)
	self._ccbOwner.sp_frame:setVisible(flag)
	self._ccbOwner.sp_nochoose:setVisible(not flag)
	self._isChoose = flag
	if flag then
		self._ccbOwner.node_content:setScale(1.05)
		self._ccbOwner.node_content:setPositionX(157)
		self._ccbOwner.node_ceng:setPosition(ccp(148,-55))
	else
		self._ccbOwner.node_content:setScale(1)
		self._ccbOwner.node_content:setPositionX(137)
		self._ccbOwner.node_ceng:setPosition(ccp(138,-60))
	end
end

function QUIWidgetSoulTowerFloor:getIsChoose( )
	return self._isChoose
end

function QUIWidgetSoulTowerFloor:onEnter()
end

function QUIWidgetSoulTowerFloor:onExit()
end

function QUIWidgetSoulTowerFloor:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetSoulTowerFloor:_onTriggerClick( )
	print("点击的层次--",self._floorInfo.floor)
	self:dispatchEvent({name = QUIWidgetSoulTowerFloor.SOULTOWER_BTN_CLICK,floorInfo = self._floorInfo})
end

return QUIWidgetSoulTowerFloor

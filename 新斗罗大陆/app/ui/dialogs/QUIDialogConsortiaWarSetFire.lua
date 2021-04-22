-- @Author: liaoxianbo
-- @Date:   2020-08-26 15:26:46
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-01 10:52:29
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogConsortiaWarSetFire = class("QUIDialogConsortiaWarSetFire", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetConsortiaWarSetFire = import("..widgets.QUIWidgetConsortiaWarSetFire")

function QUIDialogConsortiaWarSetFire:ctor(options)
	local ccbFile = "ccb/Dialog_ConsortiaWar_SetFire.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogConsortiaWarSetFire.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.frame_tf_title:setString("集火设置")
    self._callBack = options.callBack
    
    self._enemyHall = {}
    local attackOrderList = remote.consortiaWar:getAttackOrderList()
    self._attackOrderList = {}
    self._orderIndex = 0
	for _,v in pairs(attackOrderList) do
		if not self._attackOrderList[v.hallId] then
			self._attackOrderList[v.hallId] = {} 
		end
		self._attackOrderList[v.hallId].hallId = v.hallId
		self._attackOrderList[v.hallId].order = v.order 
		self._orderIndex = self._orderIndex + 1
	end
end

function QUIDialogConsortiaWarSetFire:viewDidAppear()
	QUIDialogConsortiaWarSetFire.super.viewDidAppear(self)
	 self:setInfo()
end

function QUIDialogConsortiaWarSetFire:viewWillDisappear()
  	QUIDialogConsortiaWarSetFire.super.viewWillDisappear(self)
end

function QUIDialogConsortiaWarSetFire:setInfo()
	QPrintTable(self._attackOrderList)
	self._ccbOwner.node_hall:removeAllChildren()
	local grap = 3
	for i = 1, 4 do
		local hallInfo = remote.consortiaWar:getEnemyHallInfoByHallId(i)
		if not self._enemyHall[hallInfo.hallId] then
			local hall = QUIWidgetConsortiaWarSetFire.new()
			hall:addEventListener(QUIWidgetConsortiaWarSetFire.EVENT_CLICK_SETORDER, handler(self, self._setHallClickHandler))
			self._ccbOwner.node_hall:addChild(hall)
			hall:setPositionX((hall:getContentSize().width + grap)*(i-1))
			self._enemyHall[hallInfo.hallId] = hall
		end
		if self._attackOrderList[hallInfo.hallId] and self._attackOrderList[hallInfo.hallId].order then
 			self._enemyHall[hallInfo.hallId]:setInfo(hallInfo,self._attackOrderList[hallInfo.hallId].order)
 		else
 			self._enemyHall[hallInfo.hallId]:setInfo(hallInfo)
 		end
	end
end

function QUIDialogConsortiaWarSetFire:_setHallClickHandler(event)
	local hallId = event.hallId
	if not self._enemyHall[hallId] then return end
	local orderIndex = nil
	if q.isEmpty(self._attackOrderList[hallId]) then
		self._attackOrderList[hallId] = {}
		self._attackOrderList[hallId].hallId = hallId
		if self._orderIndex < 4 then
			self._orderIndex = self._orderIndex + 1
		end
		orderIndex = self._orderIndex
		self._enemyHall[hallId]:setOrderIndex(self._orderIndex)		
		self._attackOrderList[hallId].order = self._orderIndex
	else
		orderIndex = self._attackOrderList[hallId].order
		self._enemyHall[hallId]:setOrderIndex("")	
		self._attackOrderList[hallId] = {}
		if self._orderIndex >= 1 then
			self._orderIndex = self._orderIndex - 1	
		end
	end


	if orderIndex then
		for _,v in pairs(self._attackOrderList) do
			if hallId ~= v.hallId then
				if v.order and orderIndex and v.order > orderIndex then
					v.order = v.order - 1
					self._enemyHall[v.hallId]:setOrderIndex(v.order)
				end
			end
		end	
	end
end


function QUIDialogConsortiaWarSetFire:_onTriggerOK( )
	if self._orderIndex < 4 then
		app.tip:floatTip("还有堂口未设置")
		return
	end
	remote.consortiaWar:consortiaWarSetAttackOrderRequest(self._attackOrderList,function( )
		app.tip:floatTip("宗门战集火设置成功")
		self:_onTriggerClose()
	end)
end

function QUIDialogConsortiaWarSetFire:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogConsortiaWarSetFire:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogConsortiaWarSetFire:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogConsortiaWarSetFire

--
-- Author: Your Name
-- Date: 2014-11-28 15:12:46
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogActivityInstance = class("QUIDialogActivityInstance", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIWidgetActivityInstance = import("..widgets.QUIWidgetActivityInstance")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollContain = import("..QScrollContain")


function QUIDialogActivityInstance:ctor(options)
	local ccbFile = "ccb/Dialog_TimeMachine_choose.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, QUIDialogActivityInstance._onTriggerClose)},

	}
	QUIDialogActivityInstance.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true
    self.instanceId = options.instanceId
    self._btnContain = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, direction = QScrollContain.directionY})
    self._btnContain:setIsCheckAtMove(true)

    if self.instanceId ~= nil then
    	self:initPage()
    end
    self._ccbOwner.frame_tf_title:setString("难度选择")
end

function QUIDialogActivityInstance:viewDidAppear()
	QUIDialogActivityInstance.super.viewDidAppear(self)

	self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, handler(self, self._userUpdateHandler))
end

function QUIDialogActivityInstance:viewWillDisappear()
  	QUIDialogActivityInstance.super.viewWillDisappear(self)
    self._userEventProxy:removeAllEventListeners()
    if self._btnContain ~= nil then 
        self._btnContain:disappear()
        self._btnContain = nil
    end
end

function QUIDialogActivityInstance:initPage()
	local line = 3
	local posX = 80
	local posY = -63 
	local cellWidth = 140
	local cellHeight = -136
	local index = 1
	local unlockHeight = 0
    local size = self._btnContain:getContentSize()
    size.height = 0
	self:removeAllCell()
	self._config = remote.activityInstance:getInstanceListById(self.instanceId)
	self._maxCount = remote.activityInstance:getAttackMaxCountByType(self._config[1].instance_id)
	if #self._config > 0 then
		local dungeonConfig = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self._config[1].dungeon_id)
		self._ccbOwner.tf_energy:setString(dungeonConfig.energy)
	end
	self:_userUpdateHandler()
	for _,value in pairs(self._config) do
		local instanceCell = QUIWidgetActivityInstance.new()
		instanceCell:setInfo(value, index)
		instanceCell:setPosition(ccp(posX, posY))
		instanceCell:addEventListener(QUIWidgetActivityInstance.EVENT_END, handler(self, self.cellClickHandler))
		table.insert(self._cells, instanceCell)
		self._btnContain:addChild(instanceCell)
		if instanceCell:getIsPass() then
			unlockHeight = size.height
		end
		if index%line == 0 then
			posX = 80
			posY = posY + cellHeight
			size.height = size.height + math.abs(cellHeight)
		else
			posX = posX + cellWidth
		end
		index = index + 1
	end
    self._btnContain:setContentSize(size.width, size.height)
    self._btnContain:moveTo(0,unlockHeight)
end

function QUIDialogActivityInstance:_userUpdateHandler()
	self._config = remote.activityInstance:getInstanceListById(self.instanceId)
	self._attackCount = remote.activityInstance:getAttackCountByType(self._config[1].instance_id)
	if self._attackCount >=  self._maxCount then
		self._ccbOwner.tf_count:setString("")
		self._ccbOwner.tf_count_tips:setString("今日挑战次数已用完")
		self._ccbOwner.tf_count_tips:setColor(UNITY_COLOR_LIGHT.red)
	else
		self._ccbOwner.tf_count:setString((self._maxCount - self._attackCount).."/"..self._maxCount)
		self._ccbOwner.tf_count_tips:setString("今日剩余挑战次数：")
		self._ccbOwner.tf_count_tips:setColor(UNITY_COLOR.brown)
	end
end

function QUIDialogActivityInstance:removeAllCell()
	if self._cells ~= nil then
		for _,cell in pairs(self._cells) do
			cell:removeFromParent()
			cell:removeAllEventListeners()
		end
	end
	self._cells = {}
end

function QUIDialogActivityInstance:cellClickHandler(event)
	if self._btnContain:getMoveState() == true then return end
	local cell = event.cell
	if cell:getIsPass(true) == false then return end
	if self._attackCount >= self._maxCount then
    	app.tip:floatTip("今日次数已用完")
		return
	end
	app.sound:playSound("battle_level")
	self._config = remote.activityInstance:getInstanceListById(self.instanceId)
	if #self._config > 0 then
		local needEnergy = QStaticDatabase:sharedDatabase():getDungeonConfigByID(self._config[1].dungeon_id).energy
		if remote.user:checkPropEnough("energy", needEnergy) == false then
			return 
		end
		if (self._config[1].attack_num - remote.activityInstance:getAttackCountByType(self._config[1].instance_id)) > 0 then
			self:viewAnimationOutHandler()
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogActivityDungeon", options = {info = event.info}})
		else
        	app.tip:floatTip("今日次数已用完")
		end
	end
end

function QUIDialogActivityInstance:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogActivityInstance:_onTriggerClose()
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogActivityInstance:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogActivityInstance
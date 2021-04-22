--
-- Author: wkwang
-- Date: 2014-07-28 19:39:30
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogEliteBoxAlert = class("QUIDialogEliteBoxAlert", QUIDialog)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")

QUIDialogEliteBoxAlert.EVENT_GET_SUCC = "EVENT_GET_SUCC"

function QUIDialogEliteBoxAlert:ctor(options)
	local ccbFile = "ccb/Dialog_ChestAward.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOk", callback = handler(self,self._onTriggerOk)},
    }
    QUIDialogEliteBoxAlert.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self.isAnimation = true
    self._ccbOwner.frame_tf_title:setString("宝箱奖励")
	self._ccbOwner.btn_ok:setVisible(false)
	self._ccbOwner.btn_cancel:setVisible(false)
	self._ccbOwner.btn_close:setVisible(false)
	if self._ccbOwner.tf_redpacket_tips then
		self._ccbOwner.tf_redpacket_tips:setVisible(false)
	end
	self._items = {}
	self._awards = {}

	if options ~= nil then
    	self._instanceIntId = options.instanceIntId
	    if options.instance_id ~= nil and options.index ~= nil then
	    	self._instance_id = options.instance_id
	    	self._index = options.index
	    	local mapBoxDropConfig = QStaticDatabase:sharedDatabase():getMapAchievement(self._instance_id)
			if options.starNum ~= nil and options.starNum >= tonumber(mapBoxDropConfig["box"..self._index]) and options.isGet ~= true then
				self._ccbOwner.btn_ok:setVisible(true)
				self._ccbOwner.btn_cancel:setVisible(true)
			else
				self._ccbOwner.btn_close:setVisible(true)
			end
	    	self._ccbOwner.tf_num:setString(mapBoxDropConfig["box"..self._index])
	    	local config = QStaticDatabase:sharedDatabase():getLuckyDraw(mapBoxDropConfig["index"..self._index])
	    	if config ~= nil then
	    		local i = 1
	    		local gap = 120 * 4
	    		if config["type_4"] ~= nil then
	    			gap = gap/4
    			elseif config["type_3"] ~= nil then
	    			gap = gap/3
    			elseif config["type_2"] ~= nil then
	    			gap = gap/2
    			elseif config["type_1"] ~= nil then
	    			gap = gap/1
	    		end
	    		while true do
	    			if config["type_"..i] ~= nil and i <= 4 then
	    				table.insert(self._awards, {id = config["id_"..i], typeName = config["type_"..i], count = config["num_"..i]})
	    				self._items[i] = QUIWidgetItemsBox.new()
	    				self._items[i]:setPositionX((i-1) * gap + gap/2)
	    				self._ccbOwner.node_goods:addChild(self._items[i])
	    				self._items[i]:setGoodsInfo(config["id_"..i],config["type_"..i],config["num_"..i])
   	 					self._items[i]:setPromptIsOpen(true)

	    				i = i + 1
	    			else
	    				break
	    			end
	    		end
	    		self._ccbOwner.node_goods:setPositionX(-(#self._items * gap)/2)
	    	end
	    end
	end
end

function QUIDialogEliteBoxAlert:viewDidAppear()
	QUIDialogEliteBoxAlert.super.viewDidAppear(self)
	self.prompt = app:promptTips()
	self.prompt:addItemEventListener(self)
end

function QUIDialogEliteBoxAlert:viewWillDisappear()
  	QUIDialogEliteBoxAlert.super.viewWillDisappear(self)
 	self.prompt:removeItemEventListener()
 end

function QUIDialogEliteBoxAlert:_backClickHandler()
    self:_close()
end

function QUIDialogEliteBoxAlert:_onTriggerCancel(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_cancel_bg) == false then return end
	app.sound:playSound("common_cancel")
    self:_close()
end

function QUIDialogEliteBoxAlert:_onTriggerOk(event)
	if q.buttonEventShadow(event,self._ccbOwner.button_close) == false then return end
	app.sound:playSound("common_cancel")
    self:_close()
end

function QUIDialogEliteBoxAlert:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.button_close) == false then return end
	app.sound:playSound("common_cancel")
    self:_close()
end

function QUIDialogEliteBoxAlert:_close()
    self:playEffectOut()
end

function QUIDialogEliteBoxAlert:viewAnimationOutHandler()
	local awards = self._awards
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER, nil, self)
    if self._isGet == true then
  		local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
    		options = {awards = awards}},{isPopCurrentDialog = false} )
    	dialog:setTitle("恭喜您获得副本宝箱奖励")
    end
end

function QUIDialogEliteBoxAlert:_onTriggerConfirm(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_ok_sp) == false then return end
	app.sound:playSound("common_confirm")
    app:getClient():luckyDrawMap(self._instanceIntId, self._index,function(data)
    		self:_onTriggerClose()
    		self:dispatchEvent({name = QUIDialogEliteBoxAlert.EVENT_GET_SUCC,data = data})
    		self._isGet = true --标识是否是因为领取而关闭
        end,nil)
end

return QUIDialogEliteBoxAlert
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogVivoGameCenter = class("QUIDialogVivoGameCenter", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIDialogVivoGameCenter.STATE_DEFAULT = 0		--默认
QUIDialogVivoGameCenter.STATE_GET = 1		--领取奖励
QUIDialogVivoGameCenter.STATE_GOTO = 2		--前往
QUIDialogVivoGameCenter.STATE_GETTEN = 3	--已领取


function QUIDialogVivoGameCenter:ctor(options)
	local ccbFile = "ccb/Dialog_Vivo_GameCenter.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerGet", callback = handler(self, self._onTriggerGet)},
		{ccbCallbackName = "onTriggerGoto", callback = handler(self, self._onTriggerGoto)},
    }
    
    QUIDialogVivoGameCenter.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	q.setButtonEnableShadow(self._ccbOwner.btn_get)
	q.setButtonEnableShadow(self._ccbOwner.btn_goto)
	self.isAnimation = true --是否动画显示
	self._state = QUIDialogVivoGameCenter.STATE_DEFAULT 
	self._platformId = options.platformId or 7

end

function QUIDialogVivoGameCenter:viewDidAppear()
	QUIDialogVivoGameCenter.super.viewDidAppear(self)
	self:setInfo()
end

function QUIDialogVivoGameCenter:viewWillDisappear()
  	QUIDialogVivoGameCenter.super.viewWillDisappear(self)
end

function QUIDialogVivoGameCenter:resetAll()
	self._ccbOwner.node_get:setVisible(false)
	self._ccbOwner.node_goto:setVisible(false)
	self._ccbOwner.node_getten:setVisible(false)
end

function QUIDialogVivoGameCenter:setInfo()

	self._channelConfig = remote.activity:getActivityTargetChannelConfigByChannelId(self._platformId)
	if self._channelConfig == nil then
		return
	end
	self:updateInfoByState()
	self:setPrize()
end

function QUIDialogVivoGameCenter:updateInfoByState()
	local prizePosY = 0

	local getten = remote.activity:checkGettenAwardByById(self._channelConfig.id)
	local getB = FinalSDK.isFromGameCenter()
	if getten then
		self._state = QUIDialogVivoGameCenter.STATE_GETTEN
	elseif getB then
		self._state = QUIDialogVivoGameCenter.STATE_GET
	else
		self._state = QUIDialogVivoGameCenter.STATE_GOTO
	end

	self._ccbOwner.node_get:setVisible(false)
	self._ccbOwner.node_goto:setVisible(false)
	self._ccbOwner.node_getten:setVisible(false)

	if self._state == QUIDialogVivoGameCenter.STATE_GET then
		prizePosY= self._ccbOwner.node_get_pos:getPositionY()
		self._ccbOwner.node_get:setVisible(true)
	elseif self._state == QUIDialogVivoGameCenter.STATE_GOTO then
		prizePosY= self._ccbOwner.node_goto_pos:getPositionY()
		self._ccbOwner.node_goto:setVisible(true)
	elseif self._state == QUIDialogVivoGameCenter.STATE_GETTEN then
		prizePosY= self._ccbOwner.node_getten_pos:getPositionY()
		self._ccbOwner.node_getten:setVisible(true)
	else
		prizePosY= self._ccbOwner.node_goto_pos:getPositionY()
		self._ccbOwner.node_goto:setVisible(true)		
	end
	self._ccbOwner.node_prize:setPositionY(prizePosY)
end

function QUIDialogVivoGameCenter:itemClickHandler(event)
    local itemType = remote.items:getItemType(event.itemID) or ITEM_TYPE.ITEM
	app.tip:itemTip(itemType, event.itemID , true)
end

function QUIDialogVivoGameCenter:setPrize()

    local awardsTbl = string.split(self._channelConfig.reward, ";")
    self._awards = {}

    for i, v in pairs(awardsTbl) do
        if v ~= "" then
            local reward = string.split(v, "^")
            local itemType = ITEM_TYPE.ITEM
            if tonumber(reward[1]) == nil then
                itemType = remote.items:getItemType(reward[1])
            end
            table.insert(self._awards, {id = reward[1], typeName = itemType, count = tonumber(reward[2])})
        end
    end

	for i=1,3 do
		local data = self._awards[i]
		self._ccbOwner["tf_prize_name_"..i]:setVisible(false)
		self._ccbOwner["node_prize_icon_"..i]:setVisible(false)
		if data then
			self._ccbOwner["tf_prize_name_"..i]:setVisible(true)
			self._ccbOwner["node_prize_icon_"..i]:setVisible(true)
			local item = QUIWidgetItemsBox.new()
			item:setScale(0.7)
			self._ccbOwner["node_prize_icon_"..i]:addChild(item)
			item:addEventListener(QUIWidgetItemsBox.EVENT_CLICK, handler(self, self.itemClickHandler))
			item:setGoodsInfo(data.id, data.typeName, data.count)
			if data.effect then
				item:showBoxEffect("effects/leiji_light.ccbi",true, 0, 0, 0.6)
			end

			local nameStr = item:getItemName()
			self._ccbOwner["tf_prize_name_"..i]:setString(nameStr)

		end
	end
end


function QUIDialogVivoGameCenter:_onTriggerGet(event)
    app.sound:playSound("common_small")
    print("_onTriggerGet")
    remote.activity:activityChannelGetRewardRequest(self._channelConfig.id ,function(data)
		if self:safeCheck() then
	    	self:updateInfoByState()
	    end
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
			options = {awards = self._awards}},{isPopCurrentDialog = false} )
    end )
end

function QUIDialogVivoGameCenter:_onTriggerGoto(event)
    app.sound:playSound("common_small")
    print("_onTriggerGoto")
    FinalSDK:openGameCenter()
    self:_onTriggerClose()
end


function QUIDialogVivoGameCenter:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogVivoGameCenter:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogVivoGameCenter:viewAnimationOutHandler()
	local callback = self._callBack
	
	self:popSelf()
	if callback then
		callback()
	end

end


return QUIDialogVivoGameCenter
--
-- Author: Kumo.Wang
-- 宗门红包成就奖励信息
--

local QUIDialog = import(".QUIDialog")
local QUIDialogRedpacketAchievementInfo = class("QUIDialogRedpacketAchievementInfo", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")

function QUIDialogRedpacketAchievementInfo:ctor(options)
	local ccbFile = "ccb/Dialog_Society_Redpacket_Achievement_Info.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
	}
	QUIDialogRedpacketAchievementInfo.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true
    self._ccbOwner.frame_tf_title:setString("福袋成就")
    -- local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    -- page.topBar:setAllSound(false)

    self._config = options.config or {}

    self:_init()
end

function QUIDialogRedpacketAchievementInfo:viewDidAppear()
	QUIDialogRedpacketAchievementInfo.super.viewDidAppear(self)
end 

function QUIDialogRedpacketAchievementInfo:viewWillDisappear()
	QUIDialogRedpacketAchievementInfo.super.viewWillDisappear(self)
end 

function QUIDialogRedpacketAchievementInfo:_reset()
	self._ccbOwner.node_title:setVisible(false)
	self._ccbOwner.node_item:removeAllChildren()
	self._ccbOwner.tf_tips:setVisible(false)
	self._ccbOwner.sp_done:setVisible(false)
	self._ccbOwner.node_btn:setVisible(false)
	local index = 1
	while true do
		local tfTitle = self._ccbOwner["tf_prop_title_"..index]
		local tfValue = self._ccbOwner["tf_prop_value_"..index]
		if tfTitle then
			tfTitle:setVisible(false)
		end
		if tfValue then
			tfValue:setVisible(false)
		end

		if tfTitle or tfValue then
			index = index + 1
		else
			break
		end
	end
end

function QUIDialogRedpacketAchievementInfo:_init()
	self:_reset()
	if not self._config or not next(self._config) then return end

	if self._config.head_default then
		local path = remote.redpacket:getHeadTitlePathById(self._config.head_default)
		if path then
	    	local sprite = CCSprite:create(path)
	    	if sprite then
	    		self._ccbOwner.node_title_img:addChild(sprite)
	    	end
		end
		local index = 1
		local achievePropDic = remote.redpacket:getAchieveDoneAchievementProps(self._config.type, self._config.id)
		local keyList = remote.redpacket.unionRedpacketAchievePropKeyDic[self._config.type]
		for _, key in ipairs(keyList) do
	        if achievePropDic[key] then
	           	---------- achievePropDic[key] = {name = QActorProp._field[key].name, num = tonumber(config[key])} -----------
	            local tfTitle = self._ccbOwner["tf_prop_title_"..index]
				local tfValue = self._ccbOwner["tf_prop_value_"..index]
				if tfTitle then
					tfTitle:setString(achievePropDic[key].name..":")
					tfTitle:setVisible(true)
				end
				if tfValue then
					local numStr = achievePropDic[key].num
	                if achievePropDic[key].isPercent then
	                    numStr = (achievePropDic[key].num * 100).."%"
	                end
					tfValue:setString("+"..numStr)
					tfValue:setVisible(true)
				end
				index = index + 1
	        end
	    end
		self._ccbOwner.node_title:setVisible(true)
		self._ccbOwner.node_btn:setVisible(true)
	elseif self._config.lucky_draw then
		local id, typeName, count = remote.redpacket:getLuckyDrawItemInfoById(self._config.lucky_draw)
		-- print(id, typeName, count)
		local itemBox = QUIWidgetItemsBox.new()
		itemBox:setPromptIsOpen(true)
		itemBox:setGoodsInfo(id, typeName, count)
		self._ccbOwner.node_item:addChild(itemBox)
		self._ccbOwner.node_item:setVisible(true)
	end

	local isDone = remote.redpacket:checkAchieveDoneByTypeAndId(self._config.type, self._config.id)
	if isDone then
		self._ccbOwner.sp_done:setVisible(true)
	else
		self._ccbOwner.tf_tips:setString("发放福袋的钻石额度达到"..self._config.condition.."后解锁")
		self._ccbOwner.tf_tips:setVisible(true)
	end
end

function QUIDialogRedpacketAchievementInfo:_onTriggerGo()
	app.sound:playSound("common_small")
	app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)

	local titleType = remote.headProp.TITLE_LUCKYBAG_P_TYPE
	if self._config.type == remote.redpacket.TOKEN_REDPACKET then
		titleType = remote.headProp.TITLE_LUCKYBAG_P_TYPE
	else
		titleType = remote.headProp.TITLE_LUCKYBAG_A_TYPE
	end
	local curPaket, nextPaket = remote.headProp:getRedPacketTitleLockInfo(titleType)
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPersonalSetting", options = {tab = "TAB_TITLE", selectId = nextPaket.id}})
end

function QUIDialogRedpacketAchievementInfo:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogRedpacketAchievementInfo:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogRedpacketAchievementInfo:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogRedpacketAchievementInfo

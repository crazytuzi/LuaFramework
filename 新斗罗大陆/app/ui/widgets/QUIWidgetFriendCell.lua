--
-- Author: wkwang
-- Date: 2014-10-21 10:41:36
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFriendCell = class("QUIWidgetFriendCell", QUIWidget)
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

QUIWidgetFriendCell.EVENT_CLICK = "EVENT_CLICK"
QUIWidgetFriendCell.EVENT_GET_CLICK = "EVENT_GET_CLICK"

function QUIWidgetFriendCell:ctor(options)
	local ccbFile = "ccb/Widget_Friendliebao_Client.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerGift", callback = handler(self, QUIWidgetFriendCell._onTriggerGift)},
        {ccbCallbackName = "onTriggerGet", callback = handler(self, QUIWidgetFriendCell._onTriggerGet)},
        {ccbCallbackName = "onTriggerAdd", callback = handler(self, QUIWidgetFriendCell._onTriggerAdd)},
        {ccbCallbackName = "onTriggerAgree", callback = handler(self, QUIWidgetFriendCell._onTriggerAgree)},
        {ccbCallbackName = "onTriggerRefuse", callback = handler(self, QUIWidgetFriendCell._onTriggerRefuse)},
        {ccbCallbackName = "onTriggerDelete", callback = handler(self, QUIWidgetFriendCell._onTriggerDelete)},
        {ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetFriendCell._onTriggerClick)},
    }
	QUIWidgetFriendCell.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetFriendCell:onEnter()
end

function QUIWidgetFriendCell:onExit()
end

function QUIWidgetFriendCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetFriendCell:setInfo(info, typeName,index)
	self._info = info
	self._posIndex = index
	self._ccbOwner.node_btn_gift:setVisible(false)
	self._ccbOwner.node_btn_get:setVisible(false)
	self._ccbOwner.node_btn_add:setVisible(false)
	self._ccbOwner.node_btn_agree:setVisible(false)
	self._ccbOwner.node_btn_refuse:setVisible(false)
	self._ccbOwner.node_btn_delete:setVisible(false)
	-- self._ccbOwner.btn_click:setVisible(false)
	self._ccbOwner.node_send:setVisible(false)
	self._ccbOwner.node_soulTrial:removeAllChildren()
	self._ccbOwner.node_soulTrial:setVisible(false)
	self._gap = 5
	if typeName == remote.friend.TYPE_LIST_FRIEND then
		self:friendHandler()
	elseif typeName == remote.friend.TYPE_LIST_SUGGEST then
		self:suggestFriendHandler()
	elseif typeName == remote.friend.TYPE_LIST_BLACKLIST then
		self:blacklistFriendHandler()
	elseif typeName == remote.friend.TYPE_LIST_APPLY then
		self:applyFriendHandler()
	end
	self:updateInfo()
	self:_autoLayout()
end

function QUIWidgetFriendCell:friendHandler()
	self._ccbOwner.node_btn_gift:setVisible(true)
	self._ccbOwner.node_btn_get:setVisible(self._info.existGift == true and remote.friend:checkEnergyIsMax())
	if self._info.alreadySendGift == true then
		self._ccbOwner.btn_gift:setEnabled(false)
		makeNodeFromNormalToGray(self._ccbOwner.node_btn_gift)
	else
		self._ccbOwner.btn_gift:setEnabled(true)
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn_gift)
	end
	-- self._ccbOwner.node_send:setVisible()
	-- self._ccbOwner.btn_click:setVisible(true)

	local sp = remote.soulTrial:getSoulTrialTitleSpAndFrame(self._info.soulTrial)
	self._gap = 65
	self._ccbOwner.node_soulTrial:removeAllChildren()
	if sp then
		self._ccbOwner.node_soulTrial:addChild(sp)
		-- sp:setAnchorPoint(ccp(0, 0.5))
		self._ccbOwner.node_soulTrial:setVisible(true)
	else
		self._ccbOwner.node_soulTrial:setVisible(false)
	end
end

function QUIWidgetFriendCell:_autoLayout()
	local nodes = {}
	table.insert(nodes, self._ccbOwner.tf_level)
	table.insert(nodes, self._ccbOwner.node_soulTrial)
	table.insert(nodes, self._ccbOwner.tf_name)
	table.insert(nodes, self._ccbOwner.node_vip)
	q.autoLayerNode(nodes, "x", self._gap)
end

function QUIWidgetFriendCell:suggestFriendHandler()
	self._ccbOwner.node_btn_add:setVisible(true)
	local sp = remote.soulTrial:getSoulTrialTitleSpAndFrame(self._info.soulTrial)
	self._gap = 65
	self._ccbOwner.node_soulTrial:removeAllChildren()
	if sp then
		self._ccbOwner.node_soulTrial:addChild(sp)
		-- sp:setAnchorPoint(ccp(0, 0.5))
		self._ccbOwner.node_soulTrial:setVisible(true)
	else
		self._ccbOwner.node_soulTrial:setVisible(false)
	end
end

function QUIWidgetFriendCell:blacklistFriendHandler()
	self._ccbOwner.node_btn_delete:setVisible(true)
end

function QUIWidgetFriendCell:applyFriendHandler()
	self._ccbOwner.node_btn_agree:setVisible(true)
	self._ccbOwner.node_btn_refuse:setVisible(true)
	local sp = remote.soulTrial:getSoulTrialTitleSpAndFrame(self._info.soulTrial)
	self._gap = 65
	self._ccbOwner.node_soulTrial:removeAllChildren()
	if sp then
		self._ccbOwner.node_soulTrial:addChild(sp)
		-- sp:setAnchorPoint(ccp(0, 0.5))
		self._ccbOwner.node_soulTrial:setVisible(true)
	else
		self._ccbOwner.node_soulTrial:setVisible(false)
	end
end

function QUIWidgetFriendCell:updateInfo()
	self._ccbOwner.tf_vip:setString(self._info.vipLevel or 0)
	self._ccbOwner.tf_name:setString(self._info.nickname or "")
	self._ccbOwner.tf_level:setString("LV."..self._info.teamLevel)
    local num,unit = q.convertLargerNumber(self._info.force or 0)
    self._ccbOwner.tf_battleForce:setString(num..(unit or ""))
	if self._info.consortiaId == nil or self._info.consortiaId == "" then
		self._ccbOwner.tf_uion_name:setString("没有宗门")
	else
		self._ccbOwner.tf_uion_name:setString(self._info.consortiaName or "")
	end
	if self._info.passLeaveTime ~= nil and self._info.passLeaveTime > 0 then
		local passLeaveTime = self._info.passLeaveTime/1000
		self._ccbOwner.tf_state:setColor(UNITY_COLOR.dark)
		if passLeaveTime > DAY then
			self._ccbOwner.tf_state:setString("离线1天以上")
		elseif passLeaveTime > HOUR then
			self._ccbOwner.tf_state:setString(string.format("离线%s小时", math.floor(passLeaveTime/HOUR)))
		else
			self._ccbOwner.tf_state:setString(string.format("离线%s分", math.floor(passLeaveTime/MIN)))
		end
	else
		self._ccbOwner.tf_state:setColor(UNITY_COLOR.green)
		self._ccbOwner.tf_state:setString("在线")	
	end
	if self._avatar == nil then
    	self._avatar = QUIWidgetAvatar.new(self._info.avatar)
    	self._avatar:setSilvesArenaPeak(self._info.championCount)
    	self._ccbOwner.node_avatar:addChild(self._avatar)
	else
		self._avatar:setInfo(self._info.avatar)
		self._avatar:setSilvesArenaPeak(self._info.championCount)
	end
end

function QUIWidgetFriendCell:_onTriggerGift(event)
	-- if q.buttonEventShadow(event, self._ccbOwner.btn_gift) == false then return end
    app.sound:playSound("common_small")
	remote.friend:apiUserSendFriendGiftRequest(self._info.user_id, function ()
		app.tip:floatTip("赠送成功~")
	end)
end

function QUIWidgetFriendCell:_onTriggerGet(event)
	-- if q.buttonEventShadow(event, self._ccbOwner.btn_get) == false then return end
    app.sound:playSound("common_small")
	-- self:dispatchEvent({name = QUIWidgetFriendCell.EVENT_GET_CLICK, info = self._info})
	local friendCtlInfo = remote.friend:getFriendCtlInfo()
	if friendCtlInfo.today_get_gift_times < remote.friend:getMaxEnergy() then
		remote.friend:apiUserGetFriendGiftRequest({self._info.user_id}, false, function ()
			app.tip:floatTip("成功领取"..FRIEND_GIFT_COUNT.."点体力")
		end)
	else
		app.tip:floatTip("今日获取好友体力已满！")
	end
end

function QUIWidgetFriendCell:_onTriggerAdd(event)
	-- if q.buttonEventShadow(event, self._ccbOwner.btn_add) == false then return end
    app.sound:playSound("common_small")
    if remote.friend:checkIsFriendByUserId(self._info.user_id) == true then
		app.tip:floatTip("你们已经成为好友！")
    	return
	end
	remote.friend:apiUserApplyFriendRequest(self._info.user_id, nil, function ()
		app.tip:floatTip("已发送好友申请！")
	end)
end

function QUIWidgetFriendCell:_onTriggerAgree(event)
	-- if q.buttonEventShadow(event, self._ccbOwner.btn_agree) == false then return end
    app.sound:playSound("common_small")
	if remote.friend:getMaxCount() > remote.friend:getFriendCount() then
		local userId = self._info.user_id
		remote.friend:apiUserAcceptFriendApplyRequest(userId, true, function ()
			app.tip:floatTip("添加好友成功！")
		end,function (data)
			if data.error == "FRIEND_OTHERSIDE_TOO_MANY" then
				remote.friend:apiUserAcceptFriendApplyRequest(userId, false)
				remote.friend:deleteFriendByTypeAndId(remote.friend.TYPE_LIST_APPLY, userId)
			end
		end)
	else
		app.tip:floatTip("好友列表已满！")
	end
end

function QUIWidgetFriendCell:_onTriggerRefuse(event)
	-- if q.buttonEventShadow(event, self._ccbOwner.btn_refuse) == false then return end
    app.sound:playSound("common_small")
	remote.friend:apiUserAcceptFriendApplyRequest(self._info.user_id, false)
end

function QUIWidgetFriendCell:_onTriggerDelete(event)
	-- if q.buttonEventShadow(event, self._ccbOwner.btn_delete) == false then return end
    app.sound:playSound("common_small")
	remote.friend:apiUserDeleteBlackFriendRequest(self._info.user_id)
end

function QUIWidgetFriendCell:_onTriggerClick()
    app.sound:playSound("common_small")
	self:dispatchEvent({name = QUIWidgetFriendCell.EVENT_CLICK, info = self._info,posIndex = self._posIndex})
end

return QUIWidgetFriendCell
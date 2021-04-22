-- @Author: zhouxiaoshu
-- @Date:   2019-04-28 16:26:56
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-26 18:47:46
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetConsortiaWarHall = class("QUIWidgetConsortiaWarHall", QUIWidget)

local QNavigationController = import("....controllers.QNavigationController")
local QUIViewController = import("...QUIViewController")
local QChatDialog = import("....utils.QChatDialog")
local QUIWidgetFcaAnimation = import("...widgets.actorDisplay.QUIWidgetFcaAnimation")

QUIWidgetConsortiaWarHall.EVENT_CLICK_HALL = "EVENT_CLICK_HALL"
QUIWidgetConsortiaWarHall.EVENT_CLICK_SELF = "EVENT_CLICK_SELF"
QUIWidgetConsortiaWarHall.FIREFLAG_POS = {
	ccp(0,140),
	ccp(0,90),
	ccp(0,50),
}
function QUIWidgetConsortiaWarHall:ctor(options)
	local ccbFile = "ccb/Widget_UnionWar_building.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
		{ccbCallbackName = "onTriggerSelf", callback = handler(self, self._onTriggerSelf)},
    }
    QUIWidgetConsortiaWarHall.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._touchState = true
	self._curState = remote.consortiaWar:getStateAndNextStateAt()
	self._ccbOwner.node_jihuoFlag:setVisible(false)
end

function QUIWidgetConsortiaWarHall:onEnter()
end

function QUIWidgetConsortiaWarHall:onExit()
end

function QUIWidgetConsortiaWarHall:setInfo(info, isMe, showLeader)
	self._hallId = info.hallId
	self._isMe = isMe
	for i = 1, 4 do
		if self._hallId == i then
			self._ccbOwner["shadow_"..i]:setVisible(true)
		else
			self._ccbOwner["shadow_"..i]:setVisible(false)
		end
	end
	local totalCount = 0
	if self._curState == remote.consortiaWar.STATE_READY or self._curState == remote.consortiaWar.STATE_READY_END then
		totalCount = remote.consortiaWar:getReadyHallTotalFlags(self._hallId)
	elseif self._isMe then
		totalCount = remote.consortiaWar:getHallTotalFlags(true, self._hallId)
	else
		totalCount = remote.consortiaWar:getHallTotalFlags(false, self._hallId)
	end
	self._ccbOwner.tf_flag_count:setString("x"..totalCount)
	self._ccbOwner.sp_blue_flag:setVisible(isMe)
	self._ccbOwner.sp_red_flag:setVisible(not isMe)

	local isMeInHall = false
	local aliveCount = 0
	local leaderName = "空缺"
	for i, member in pairs(info.memberList or {}) do
		if member.isLeader then
			leaderName = member.memberFighter.name
		end
		if not member.isBreakThrough then
			aliveCount = aliveCount + 1
		end
		if remote.user.userId == member.memberId then
			isMeInHall = true
		end
	end
	self._ccbOwner.node_self:setVisible(isMeInHall)

	local picType = 1
	if self._curState == remote.consortiaWar.STATE_FIGHT or self._curState == remote.consortiaWar.STATE_FIGHT_END then
		if aliveCount >= 5 then
			picType = 1
		elseif aliveCount >= 1 then
			picType = 2
		else
			picType = 3
		end
	end
	self._ccbOwner.node_jihuoFlag:setPosition(QUIWidgetConsortiaWarHall.FIREFLAG_POS[picType])
	self._ccbOwner.sp_break:setVisible(info.isBreakThrough)

	local hallPic, hallEffect = remote.consortiaWar:getHallResByHallId(self._hallId, picType, self._isMe)
	if hallPic then
        local icon = CCTextureCache:sharedTextureCache():addImage(hallPic)
		self._ccbOwner.sp_image:setTexture(icon)
	end
	if hallEffect then
		local avatar = QUIWidgetFcaAnimation.new(hallEffect, "res")
        self._ccbOwner.node_effect:removeAllChildren()
        self._ccbOwner.node_effect:addChild(avatar)
	end

	local numStr = string.format("%d/%d", aliveCount, remote.consortiaWar:getHallMemberCount())
	self._ccbOwner.tf_num:setString(numStr)

	local hallConfig = remote.consortiaWar:getHallConfigByHallId(self._hallId)
	self._ccbOwner.tf_tang:setString(hallConfig.name.."人数：")

	self._ccbOwner.node_leader_tips:removeAllChildren()
	if showLeader then
		local leaderStr = string.format("%s堂主：\n%s", hallConfig.name, leaderName)
		self._wordWidget = QChatDialog.new()
		self._wordWidget:setScale(0.8)
		self._wordWidget:setString(leaderStr)
		self._ccbOwner.node_leader_tips:addChild(self._wordWidget)
		if self._hallId % 2 == 0 then
			self._wordWidget:setPositionX(-80)
			self._wordWidget:setScaleX(-1)
		else
			self._wordWidget:setPositionX(80)
			self._wordWidget:setScaleX(1)
		end
	end
end

function QUIWidgetConsortiaWarHall:showSetFireFlag(b)
    self._ccbOwner.node_jihuoFlag:setVisible(b)
end
function QUIWidgetConsortiaWarHall:setTouchEnable(state)
	self._touchState = state
end

function QUIWidgetConsortiaWarHall:hideHallInfo()
    self._ccbOwner.node_info:setVisible(false)
end

function QUIWidgetConsortiaWarHall:getContentSize()
	local size = CCSize(200, 200)
	return size
end

function QUIWidgetConsortiaWarHall:_onTriggerClick(event)
	if not self._touchState then return end
	
    local node = self._ccbOwner.sp_image
    if q.buttonEvent(event, node) == false then return end
    app.sound:playSound("common_small")

    self:dispatchEvent({name = QUIWidgetConsortiaWarHall.EVENT_CLICK_HALL, hallId = self._hallId})
end

function QUIWidgetConsortiaWarHall:_onTriggerSelf(event)
	if not self._touchState then return end
	
    if q.buttonEvent(event, self._ccbOwner.btn_self) == false then return end
    app.sound:playSound("common_small")

    self:dispatchEvent({name = QUIWidgetConsortiaWarHall.EVENT_CLICK_SELF, hallId = self._hallId})
end

return QUIWidgetConsortiaWarHall

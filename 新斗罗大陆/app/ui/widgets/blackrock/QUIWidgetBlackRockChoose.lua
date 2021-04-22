local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetBlackRockChoose = class("QUIWidgetBlackRockChoose", QUIWidget)
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")

QUIWidgetBlackRockChoose.CLICK_JOIN = "CLICK_JOIN"

function QUIWidgetBlackRockChoose:ctor(options)
	local ccbFile = "ccb/Widget_Black_mountain_choose.ccbi"

	QUIWidgetBlackRockChoose.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetBlackRockChoose:setInfo(team)
	self._team = team
	local leader = self._team.leader or {}
	self._ccbOwner.tf_roomNum:setString("NO."..(self._team.symbol or 0))
	self._ccbOwner.tf_level:setString("LV."..(leader.level or 0))
	self._ccbOwner.tf_level:setPositionX(self._ccbOwner.tf_roomNum:getPositionX() + self._ccbOwner.tf_roomNum:getContentSize().width+3)
	self._ccbOwner.tf_name:setString(leader.name)
	self._ccbOwner.tf_name:setPositionX(self._ccbOwner.tf_level:getPositionX() + self._ccbOwner.tf_level:getContentSize().width)

	if self._comeBackIcon ~= nil then
		self._comeBackIcon:removeFromParent()
		self._comeBackIcon = nil
	end
	if self._team.isPlayComeBack then
        self._comeBackIcon = CCSprite:create("ui/dl_wow_pic/sp_comeback.png")
        local node = self._ccbOwner.tf_name:getParent()
        self._comeBackIcon:setAnchorPoint(ccp(0, 0.5))
        self._comeBackIcon:setPositionX(self._ccbOwner.tf_name:getPositionX() + self._ccbOwner.tf_name:getContentSize().width)
        self._comeBackIcon:setPositionY(self._ccbOwner.tf_name:getPositionY())
        node:addChild(self._comeBackIcon)
    end

	local force = leader.topnForce or 0
	local num,uint = q.convertLargerNumber(force)
	self._ccbOwner.tf_force:setString(num..(uint or ""))
	self._ccbOwner.tf_server:setString((leader.game_area_name or ""))
	self._ccbOwner.tf_team:setString("队伍人数："..(self._team.memberCnt or 0).."/3")
	if (self._team.memberCnt or 0) >= 3 then
		self._ccbOwner.tf_team:setColor(UNITY_COLOR.red)
	else
		self._ccbOwner.tf_team:setColor(UNITY_COLOR.green)
	end

	self._ccbOwner.node_noActive:setVisible(false)
	if self._team.password == nil or self._team.password == ""  then
		self._ccbOwner.node_mima:setVisible(false)

		local leaderLastActiveAt = self._team.leaderLastActiveAt
		if leaderLastActiveAt and q.serverTime()*1000 >= leaderLastActiveAt + remote.blackrock.noActiveTimeForMsec then
			-- 不活跃
			self._ccbOwner.node_noActive:setVisible(true)
		end
	else
		self._ccbOwner.node_mima:setVisible(true)
	end
	if self._avatar == nil then
    	self._avatar = QUIWidgetAvatar.new(leader.avatar)
    	self._avatar:setSilvesArenaPeak(leader.championCount)
    	self._ccbOwner.node_avatar:addChild(self._avatar)
	else
		self._avatar:setInfo(leader.avatar)
		self._avatar:setSilvesArenaPeak(leader.championCount)
	end
end

function QUIWidgetBlackRockChoose:getContentSize()
	return self._ccbOwner.sp_bg:getContentSize()
end

return QUIWidgetBlackRockChoose
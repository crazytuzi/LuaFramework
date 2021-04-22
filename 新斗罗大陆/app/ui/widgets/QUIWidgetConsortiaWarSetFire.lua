-- @Author: liaoxianbo
-- @Date:   2020-08-26 15:28:39
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-08-26 17:25:21
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetConsortiaWarSetFire = class("QUIWidgetConsortiaWarSetFire", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

QUIWidgetConsortiaWarSetFire.EVENT_CLICK_SETORDER = "EVENT_CLICK_SETORDER"

function QUIWidgetConsortiaWarSetFire:ctor(options)
	local ccbFile = "ccb/Widget_ConsortiaWar_SetFire.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
    }
    QUIWidgetConsortiaWarSetFire.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self._curState = remote.consortiaWar:getStateAndNextStateAt()
end

function QUIWidgetConsortiaWarSetFire:onEnter()
end

function QUIWidgetConsortiaWarSetFire:onExit()
end


function QUIWidgetConsortiaWarSetFire:setInfo(info,order)
	self._hallId = info.hallId
	self._isMe = false
	local totalCount = 0
	if self._curState == remote.consortiaWar.STATE_READY or self._curState == remote.consortiaWar.STATE_READY_END then
		totalCount = remote.consortiaWar:getReadyHallTotalFlags(self._hallId)
	elseif self._isMe then
		totalCount = remote.consortiaWar:getHallTotalFlags(true, self._hallId)
	else
		totalCount = remote.consortiaWar:getHallTotalFlags(false, self._hallId)
	end
	self._ccbOwner.tf_flag_count:setString("x"..totalCount)
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
	local hallPic, hallEffect = remote.consortiaWar:getHallResByHallId(self._hallId, 1, false)
	if hallPic then
        local icon = CCTextureCache:sharedTextureCache():addImage(hallPic)
		self._ccbOwner.sp_war_hall:setTexture(icon)
	end


	local numStr = string.format("%d/%d", aliveCount, remote.consortiaWar:getHallMemberCount())
	self._ccbOwner.tf_num:setString(numStr)

	local hallConfig = remote.consortiaWar:getHallConfigByHallId(self._hallId)
	self._ccbOwner.tf_tang:setString(hallConfig.name.."人数：")

	self:setOrderIndex(order or "")
end

function QUIWidgetConsortiaWarSetFire:setOrderIndex(index)
	self._ccbOwner.tf_orderNum:setString(index)
end

function QUIWidgetConsortiaWarSetFire:_onTriggerSelect( )
	app.sound:playSound("common_small")
	self:dispatchEvent({name = QUIWidgetConsortiaWarSetFire.EVENT_CLICK_SETORDER, hallId = self._hallId})
end

function QUIWidgetConsortiaWarSetFire:getContentSize()
	return self._ccbOwner.sp_normal:getContentSize()
end

return QUIWidgetConsortiaWarSetFire

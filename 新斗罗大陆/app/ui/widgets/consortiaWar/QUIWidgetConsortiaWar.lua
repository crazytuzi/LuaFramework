-- @Author: zhouxiaoshu
-- @Date:   2019-04-28 16:18:39
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-05-12 14:58:52

local QUIWidget = import("..QUIWidget")
local QUIWidgetConsortiaWar = class("QUIWidgetConsortiaWar", QUIWidget)
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")
local QUIViewController = import("....ui.QUIViewController")
local QUIWidgetHeroTitleBox = import("..QUIWidgetHeroTitleBox")

QUIWidgetConsortiaWar.EVENT_BATTLE = "EVENT_BATTLE"
QUIWidgetConsortiaWar.EVENT_VISIT = "EVENT_VISIT"
QUIWidgetConsortiaWar.EVENT_QUICK_BATTLE = "EVENT_QUICK_BATTLE"

function QUIWidgetConsortiaWar:ctor(options)
	local ccbFile = "ccb/Widget_UnionWar.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerPress", callback = handler(self, self._onTriggerPress)},
        {ccbCallbackName = "onTriggerVisit", callback = handler(self, self._onTriggerVisit)},
        {ccbCallbackName = "onTriggerAutoFight", callback = handler(self, self._onTriggerAutoFight)},
	}
	QUIWidgetConsortiaWar.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:resetData()
end

function QUIWidgetConsortiaWar:onEnter()
	QUIWidgetConsortiaWar.super.onEnter(self)
end

function QUIWidgetConsortiaWar:onExit()
	QUIWidgetConsortiaWar.super.onExit(self)
end

function QUIWidgetConsortiaWar:resetData()
	self._ccbOwner.node_auto_fight:setVisible(false)
	self._ccbOwner.node_leader:setVisible(false)
	self._ccbOwner.tf_battleforce:setString("0")
	self._ccbOwner.tf_union_name:setString("")
	self._ccbOwner.tf_user_name:setString("")
	self._ccbOwner.tf_flag_count:setString("x 0")
	self._ccbOwner.node_head1:removeAllChildren()
	self._ccbOwner.node_head2:removeAllChildren()
	self._avatar1 = nil
	self._avatar2 = nil
end

--设置信息
function QUIWidgetConsortiaWar:setFlagInfo(info, isMe)
	self:resetData()
	self._isFlag = true
	self._ccbOwner.sp_red_flag:setVisible(not isMe)
	self._ccbOwner.sp_blue_flag:setVisible(isMe)
	self._ccbOwner.tf_user_name:setString("宗门战旗")
	self._ccbOwner.tf_union_name:setString(info.gameAreaName or "")
	self._ccbOwner.tf_battleforce:setString(0)
	self._ccbOwner.tf_flag_count:setString("x "..(info.pickFlagCount or 0))

	self:updateFlagAni(isMe, info.pickFlagCount)
end

--设置信息
function QUIWidgetConsortiaWar:setInfo(memberInfo, isMe)
	self:resetData()
	self._memberInfo = memberInfo
	if not memberInfo or not memberInfo.memberFighter then
		return
	end
	local fighter = memberInfo.memberFighter 
	local force = fighter.force or 0
	local num,unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_battleforce:setString(num..unit)
	self._ccbOwner.tf_union_name:setString(memberInfo.gameAreaName or "")
	self._ccbOwner.tf_user_name:setString(fighter.name or "")
	self._ccbOwner.tf_flag_count:setString("x "..(memberInfo.remainFlagCount or 0))
	self._ccbOwner.node_leader:setVisible(memberInfo.isLeader)

	local flagNum = memberInfo.remainFlagCount or 0
	if app.unlock:checkLock("UNLOCK_CONSORTIA_CLEANOUT", false) and flagNum > 0 then
		self._ccbOwner.node_auto_fight:setVisible(true and not isMe)
	else
		self._ccbOwner.node_auto_fight:setVisible(false)
	end

	local showHeroInfo = fighter.showHeroInfo or {}
	if showHeroInfo[1] then
		local actorId = showHeroInfo[1].actorId
		if actorId == 0 then
			actorId = 1001
		end
		self._avatar1 = QUIWidgetActorDisplay.new(actorId, {heroInfo = showHeroInfo[1]})
		self._ccbOwner.node_head1:addChild(self._avatar1)
	end
	if showHeroInfo[2] then
		local actorId = showHeroInfo[2].actorId
		if actorId == 0 then
			actorId = 1002
		end
		self._avatar2 = QUIWidgetActorDisplay.new(actorId, {heroInfo = showHeroInfo[2]})
		self._ccbOwner.node_head2:addChild(self._avatar2)
	end

	if memberInfo.isBreakThrough then
		makeNodeFromNormalToGray(self._ccbOwner.node_head1)
		makeNodeFromNormalToGray(self._ccbOwner.node_head2)
		if self._avatar1 then
			self._avatar1:getActor():getSkeletonView():pauseAnimation()
		end
		if self._avatar2 then
			self._avatar2:getActor():getSkeletonView():pauseAnimation()
		end
	end

	self:setIsSelf(remote.user.userId == fighter.userId)
	self:showTitle(fighter.title, fighter.soulTrial)
end

--设置下标
function QUIWidgetConsortiaWar:updateFlagAni(isMe, pickFlagCount)
	local flagAniName = "zm_qi_h"
	if isMe then
		flagAniName = "zm_qi_l"
	end
	for i = 1, 4 do
		self._ccbOwner["node_flag_"..i]:removeAllChildren()
		if i <= pickFlagCount/2 then
			local flagAni = QSkeletonActor:create(flagAniName)
    		flagAni:playAnimation("animation", true)
    		flagAni:setScale(0.6)
			self._ccbOwner["node_flag_"..i]:addChild(flagAni)
		end
	end
end

--设置下标
function QUIWidgetConsortiaWar:setIndex(index)
	self._index = index
end

--设置是否自己
function QUIWidgetConsortiaWar:setIsSelf(isSelf)
	self._ccbOwner.node_high:setVisible(not isSelf)
	self._ccbOwner.node_self:setVisible(isSelf)
end

--翻转
function QUIWidgetConsortiaWar:setAvatarScaleX(scaleX)
	self._ccbOwner.node_head1:setScaleX(scaleX)
	self._ccbOwner.node_head2:setScaleX(scaleX)
end

function QUIWidgetConsortiaWar:setShowInfo(isShow)
	self._ccbOwner.node_self:setVisible(isShow)
	self._ccbOwner.node_high:setVisible(isShow)
end

function QUIWidgetConsortiaWar:showTitle(title, soulTrial)
	local titleBox = QUIWidgetHeroTitleBox.new()
	titleBox:setTitleId(title, soulTrial)
	self._ccbOwner.chenghao:removeAllChildren()
	self._ccbOwner.chenghao:addChild(titleBox)
end

function QUIWidgetConsortiaWar:_onTriggerPress()
	self:dispatchEvent({name = QUIWidgetConsortiaWar.EVENT_BATTLE, index = self._index, isFlag = self._isFlag, info = self._memberInfo})
end

function QUIWidgetConsortiaWar:_onTriggerVisit()
	self:dispatchEvent({name = QUIWidgetConsortiaWar.EVENT_VISIT, index = self._index, isFlag = self._isFlag, info = self._memberInfo})
end

function QUIWidgetConsortiaWar:_onTriggerAutoFight()
	self:dispatchEvent({name = QUIWidgetConsortiaWar.EVENT_QUICK_BATTLE, index = self._index, isFlag = self._isFlag, info = self._memberInfo})
end

return QUIWidgetConsortiaWar

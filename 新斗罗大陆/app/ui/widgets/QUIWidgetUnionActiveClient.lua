-- @Author: xurui
-- @Date:   2016-11-08 18:57:30
-- @Last Modified by:   xurui
-- @Last Modified time: 2017-06-12 19:25:12
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetUnionActiveClient = class("QUIWidgetUnionActiveClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetUnionActiveClient:ctor(options)
	local ccbFile = "ccb/Widget_society_gonghuihuoyue.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClickToken", callback = handler(self, self._onTriggerClickToken)},
		{ccbCallbackName = "onTriggerClickUnionMoney", callback = handler(self, self._onTriggerClickUnionMoney)},
	}
	QUIWidgetUnionActiveClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:resetAll()
end

function QUIWidgetUnionActiveClient:onEnter()
end

function QUIWidgetUnionActiveClient:onExit()
end

function QUIWidgetUnionActiveClient:resetAll()
	self._ccbOwner.tf_union_post:setString("")
	self._ccbOwner.tf_union_active:setString("")
	self._ccbOwner.tf_taken_num:setString("")
	self._ccbOwner.tf_unionMoney_num:setString("")
end

function QUIWidgetUnionActiveClient:setInfo()
	-- 拉取宗门活跃信息
	remote.union.unionActive:requestGetUnionActiveWeekInfo(function()
			self:setClientInfo()
		end)
end

function QUIWidgetUnionActiveClient:setClientInfo()
	local info = remote.union.unionActive:getUnionActiveInfo()

	local myOfficialPosition = remote.user.userConsortia.rank
	local postName = "成员"
	if myOfficialPosition == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
		postName = "副宗主"
	elseif myOfficialPosition == SOCIETY_OFFICIAL_POSITION.BOSS then
		postName = "宗主"
	elseif myOfficialPosition == SOCIETY_OFFICIAL_POSITION.ELITE then
		postName = "精英"
	end
	self._ccbOwner.tf_union_post:setString(postName)

	self._ccbOwner.tf_union_active:setString(info.consortiaWeekActiveness or 0)
	self._ccbOwner.tf_taken_num:setString(info.addUpToken or 0)
	self._ccbOwner.tf_unionMoney_num:setString(info.addUpConsortiaMoney or 0)
end

function QUIWidgetUnionActiveClient:_onTriggerClickToken()
	app.tip:floatTip("箱子里全是闪闪的钻石，这是给予宗门成员活跃的奖励", 120, -40)
end

function QUIWidgetUnionActiveClient:_onTriggerClickUnionMoney()
	app.tip:floatTip("满满的宗门币奖励，周一凌晨五点可以来领取哦", 120, -40)
end

return QUIWidgetUnionActiveClient
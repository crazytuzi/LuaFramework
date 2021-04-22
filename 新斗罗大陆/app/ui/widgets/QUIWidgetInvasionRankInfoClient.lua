-- @Author: xurui
-- @Date:   2016-12-12 10:29:09
-- @Last Modified by:   xurui
-- @Last Modified time: 2016-12-23 10:58:10
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetInvasionRankInfoClient = class("QUIWidgetInvasionRankInfoClient", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetInvasionRankInfoClient:ctor(options)
	local ccbFile = "ccb/Widget_Panjun_Main_xinxi.ccbi"
	local callBack = {
		-- {ccbCallbackName = "", callback = handler(self, self._)},
	}
	QUIWidgetInvasionRankInfoClient.super.ctor(self, ccbFile, callBack, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if not app:isNativeLargerEqualThan(1, 2, 1) then
		setShadow5(self._ccbOwner.tf_title1)
		setShadow5(self._ccbOwner.tf_title2)
		setShadow5(self._ccbOwner.tf_rank1)
		setShadow5(self._ccbOwner.tf_rank2)
		setShadow5(self._ccbOwner.tf_currency_num1)
		setShadow5(self._ccbOwner.tf_currency_num2)
	end

	self:resetAll()
end

function QUIWidgetInvasionRankInfoClient:onEnter()
end

function QUIWidgetInvasionRankInfoClient:onExit()
end

function QUIWidgetInvasionRankInfoClient:resetAll()
	self._ccbOwner.tf_title1:setString("")
	self._ccbOwner.tf_title2:setString("")
	self._ccbOwner.tf_rank1:setString("")
	self._ccbOwner.tf_rank2:setString("")
	self._ccbOwner.tf_currency_num1:setString("")
	self._ccbOwner.tf_currency_num2:setString("")
	self._ccbOwner.node_currency1:setVisible(false)
	self._ccbOwner.node_currency2:setVisible(false)
end

function QUIWidgetInvasionRankInfoClient:setInfo(title1, rank1, awards1, title2, rank2, awards2)
	self._ccbOwner.tf_title1:setString(title1 or "")
	self._ccbOwner.tf_title2:setString(title2 or "")

	if rank1 == nil or rank1 == 0 then
		self._ccbOwner.tf_rank1:setString("（尚未进榜）")
	else
		self._ccbOwner.tf_rank1:setString((rank1 or "") .. "名")
	end
	if rank2 == nil or rank2 == 0 then
		self._ccbOwner.tf_rank2:setString("（尚未进榜）")
	else
		self._ccbOwner.tf_rank2:setString((rank2 or "") .. "名")
	end

	if awards1 == nil or next(awards1) == nil then
		self._ccbOwner.node_currency1:setVisible(false)
	else
		self._ccbOwner.node_currency1:setVisible(true)
		self._ccbOwner.tf_currency_num1:setString(awards1[1].count)
	end
	if awards2 == nil or next(awards2) == nil then
		self._ccbOwner.node_currency2:setVisible(false)
	else
		self._ccbOwner.node_currency2:setVisible(true)
		self._ccbOwner.tf_currency_num2:setString(awards2[1].count)
	end
end

return QUIWidgetInvasionRankInfoClient
-- @Author: xurui
-- @Date:   2019-08-30 11:03:22
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-10-31 10:53:12
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetRankAward = class("QUIWidgetRankAward", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

QUIWidgetRankAward.EVENT_CLICK_RECIVED = "EVENT_CLICK_RECIVED"
QUIWidgetRankAward.EVENT_CLICK_RECORD = "EVENT_CLICK_RECORD"

function QUIWidgetRankAward:ctor(options)
	local ccbFile = "ccb/Widget_rank_service.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerRecive", callback = handler(self, self._onTriggerRecive)},
		{ccbCallbackName = "onTriggerRecord", callback = handler(self, self._onTriggerRecord)},
    }
    QUIWidgetRankAward.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetRankAward:onEnter()
end

function QUIWidgetRankAward:onExit()
end

function QUIWidgetRankAward:setInfo(info, rankConfig)
	self._info = info
	self._record = remote.rank:getRecordById(info.index)

	self._ccbOwner.tf_desc:setString(info.desc or "")

	self._ccbOwner.node_avatar:removeAllChildren()

	local userInfo = self._record.completeUsersInfo or {}
	if q.isEmpty(userInfo) then
		self._ccbOwner.tf_name:setString("无")
		self._ccbOwner.btn_record:setVisible(false)
	else
		self._ccbOwner.tf_name:setString(userInfo.name or "")
		local avatar = QUIWidgetAvatar.new(userInfo.avatar or (-1))
		avatar:setSilvesArenaPeak(userInfo.championCount)
		self._ccbOwner.node_avatar:addChild(avatar)
		self._ccbOwner.btn_record:setVisible(true)
	end

	self._ccbOwner.node_item:setVisible(false)
	if self._info.type_1 then
		self._ccbOwner.node_item:setVisible(true)
		if self._itemBox  == nil then
			self._itemBox = QUIWidgetItemsBox.new()
			self._ccbOwner.node_award:addChild(self._itemBox)
		end
		local typeName = ITEM_TYPE.ITEM
		if self._info.id_1 == nil then
			typeName = remote.items:getItemType(self._info.type_1)
		end
		self._itemBox:setGoodsInfo(self._info.id_1, typeName, 0)
		self._ccbOwner.tf_item_num:setString("x"..(self._info.num_1 or 0))
	end

	local isComplete = false
	if self._record and self._record.completeUsersInfo and self._record.isReward ~= true then
		isComplete = true
	end
	local isRecived = self._record.isReward
	if isRecived then
		self._ccbOwner.node_btn_recive:setVisible(false)
		self._ccbOwner.sp_ishave:setVisible(true)
		self._ccbOwner.tf_none:setVisible(false)
	elseif isComplete then
		self._ccbOwner.node_btn_recive:setVisible(true)
		self._ccbOwner.sp_ishave:setVisible(false)
		self._ccbOwner.tf_none:setVisible(false)
	else
		self._ccbOwner.node_btn_recive:setVisible(false)
		self._ccbOwner.sp_ishave:setVisible(false)
		self._ccbOwner.tf_none:setVisible(true)
	end
end

function QUIWidgetRankAward:_onTriggerRecive()
	self:dispatchEvent({name = QUIWidgetRankAward.EVENT_CLICK_RECIVED, info = self._info})
end

function QUIWidgetRankAward:_onTriggerRecord()
	self:dispatchEvent({name = QUIWidgetRankAward.EVENT_CLICK_RECORD, info = self._info})
end

function QUIWidgetRankAward:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

return QUIWidgetRankAward

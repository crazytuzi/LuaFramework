--
-- Author: Kumo.Wang
-- 宗门红包发送界面cell
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetRedpacketSendCell = class("QUIWidgetRedpacketSendCell", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetRedpacketSendCell:ctor(options)
	local ccbFile = "ccb/Widget_Society_Redpacket_send.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
	}
	QUIWidgetRedpacketSendCell.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetRedpacketSendCell:onEnter()
end

function QUIWidgetRedpacketSendCell:onExit()
end

function QUIWidgetRedpacketSendCell:setSelectedState(b)
	self._ccbOwner.sp_on:setVisible(b)
	self._ccbOwner.sp_off:setVisible(not b)
end

function QUIWidgetRedpacketSendCell:setInfo(param)
	self:_resetAll()

	self._param = param
	self._config = param.itemData or {}
	self._type = param.redpacketType
	if not self._config or not next(self._config) then return end

	local idOrType = self._config.use_type
	local num = self._config.use_num
	local itemBox = QUIWidgetItemsBox.new()
	if self._type == remote.redpacket.TOKEN_REDPACKET then
		if tonumber(self._config.id) == remote.redpacket.FREE_TOKEN_REDPACKET_ID_1 then
			if remote.user.userConsortia.free_red_packet_count and remote.user.userConsortia.free_red_packet_count > 0 then
				self._ccbOwner.tf_freeTime:setVisible(true)
				num = 0
			end
		elseif tonumber(self._config.id) == remote.redpacket.FREE_TOKEN_REDPACKET_ID_2 then
			if remote.user.userConsortia.free_red_packet2_count and remote.user.userConsortia.free_red_packet2_count > 0 then
				self._ccbOwner.tf_freeTime:setVisible(true)
				num = 0
			end
		elseif tonumber(self._config.id) == remote.redpacket.FREE_TOKEN_REDPACKET_ID_3 then
			if remote.user.userConsortia.free_red_packet3_count and remote.user.userConsortia.free_red_packet3_count > 0 then
				self._ccbOwner.tf_freeTime:setVisible(true)
				num = 0
			end
		end
		if tonumber(idOrType) then
			itemBox:setGoodsInfo(tonumber(idOrType), ITEM_TYPE.ITEM, num)
		else
			itemBox:setGoodsInfo(nil, idOrType, num)
		end
    elseif self._type == remote.redpacket.ITEM_REDPACKET then
    	if tonumber(idOrType) then
			num = remote.items:getItemsNumByID(tonumber(idOrType))
			itemBox:setGoodsInfo(tonumber(idOrType), ITEM_TYPE.ITEM, num)
		else
			num = remote.items:getNumByIDAndType(nil, idOrType)
			itemBox:setGoodsInfo(nil, idOrType, num)
		end
	elseif self._type == remote.redpacket.CONSORTIA_WAR_REDPACKET then
		if remote.user.userConsortia.free_red_packet4_count and remote.user.userConsortia.free_red_packet4_count > 0 then
			self._ccbOwner.tf_freeTime:setVisible(true)
			num = 0
		end
		if tonumber(idOrType) then
			itemBox:setGoodsInfo(tonumber(idOrType), ITEM_TYPE.ITEM, num)
		else
			itemBox:setGoodsInfo(nil, idOrType, num)
		end
    end
	
	self._ccbOwner.node_icon:addChild(itemBox)

	if self._config.unlock_vip and self._config.unlock_vip > 0 then
		self._ccbOwner.tf_vip:setString("VIP "..self._config.unlock_vip)
		self._ccbOwner.tf_vip:setVisible(true)
	end
end

function QUIWidgetRedpacketSendCell:_resetAll()
	self._ccbOwner.tf_freeTime:setVisible(false)
	self._ccbOwner.sp_on:setVisible(false)
	self._ccbOwner.sp_off:setVisible(true)
	self._ccbOwner.tf_vip:setVisible(false)
	self._ccbOwner.node_icon:removeAllChildren()
end

function QUIWidgetRedpacketSendCell:getName()
	return "QUIWidgetRedpacketSendCell"
end

function QUIWidgetRedpacketSendCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetRedpacketSendCell

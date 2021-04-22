--
-- Author: nie
-- Date: 2016-01-12 20:44:32
--
local QUIWidget = import(".QUIWidget")
local QUIWidgetChooseServerItem = class("QUIWidgetChooseServerItem", QUIWidget)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

QUIWidgetChooseServerItem.EVENT_SELECT = "EVENT_SELECT"

function QUIWidgetChooseServerItem:ctor(options)
	local ccbFile = "ccb/Widget_ChooseServer_Item.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerChoose", callback = handler(self, QUIWidgetChooseServerItem._onTriggerChoose)},	
	}
	QUIWidgetChooseServerItem.super.ctor(self,ccbFile,callBacks,options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if not options then
    	options = {}
    end
    self._isNotShowAvatar = options.isNotShowAvatar
end

function QUIWidgetChooseServerItem:setInfo(itemInfo)
	-- status: 游戏服类型, 类型有:1-正常;2-新开;3-火爆;4-维护;
	-- 5-停服;6-合服;7-即将开启
	-- 9-已配服;10-待配服;11-待开服
	if not itemInfo or type(itemInfo) ~= "table"then
		return
	end
	self._serverInfo = itemInfo
	self._isOpen = true

	self._ccbOwner.tf_open_time:setVisible(false)
	self._ccbOwner.sp_red_rect:setVisible(false)
	self._ccbOwner.serverStatus2:setVisible(false)
	self._ccbOwner.serverStatus3:setVisible(false)
	self._ccbOwner.serverStatus4:setVisible(false)
	self._ccbOwner.serverStatus7:setVisible(false)
	self._ccbOwner.node_dazhe:removeAllChildren()
	
	--具体状态 请查看 游戏服列表接口

	if itemInfo.is_hot_blood then
		self._ccbOwner.sp_red_rect:setVisible(true)
		local ccbProxy = CCBProxy:create()
	    local ccbOwner = {}
	    local dazheWidget = CCBuilderReaderLoad("Widget_dazhe.ccbi", ccbProxy, ccbOwner)
	    ccbOwner.chengDisCountBg:setVisible(false)
	    ccbOwner.lanDisCountBg:setVisible(false)
	    ccbOwner.ziDisCountBg:setVisible(false)
	    ccbOwner.hongDisCountBg:setVisible(true)
	    ccbOwner.discountStr:setString("超级")
	    self._ccbOwner.node_dazhe:addChild(dazheWidget)

	elseif itemInfo.status then
		if itemInfo.status == 2 then
			self._ccbOwner.serverStatus2:setVisible(true)
		elseif itemInfo.status == 3 then
			self._ccbOwner.serverStatus3:setVisible(true)
		elseif itemInfo.status == 4 or itemInfo.status == 5 or itemInfo.status == 6 then
			makeNodeFromNormalToGray(self._ccbOwner.serverStatus4)
			self._ccbOwner.serverStatus4:setVisible(true)
		elseif itemInfo.status == 9 or itemInfo.status == 11 or itemInfo.status == 10 then
			makeNodeFromNormalToGray(self._ccbOwner.serverStatus7)
			self._ccbOwner.serverStatus7:setVisible(true)
		else
			self._ccbOwner.serverStatus3:setVisible(true)
		end
	end

	if itemInfo.name then
		self._ccbOwner.serverName:setString(itemInfo.name)
	end
	if itemInfo.server_name then
		self._ccbOwner.serverName:setString(itemInfo.server_name)
	end
	
	if itemInfo.open_time then
		self._isOpen = q.serverTime() >= tonumber(itemInfo.open_time)
        local dateTime = q.date("*t", tonumber(itemInfo.open_time)/1000)
    	local timeStr = string.format("%d年%02d月%02d日%02d点开启", dateTime.year, dateTime.month, dateTime.day, dateTime.hour)
		self._ccbOwner.tf_open_time:setString(timeStr)
		self._ccbOwner.tf_open_time:setVisible(true)
		self._ccbOwner.serverStatus7:setVisible(true)
		self._ccbOwner.node_dazhe:removeAllChildren()
	end	

	if not itemInfo.avatar or self._isNotShowAvatar then
		self._ccbOwner.teamLvNode:setVisible(false)
		self._ccbOwner.node_avatar:setVisible(false)
	else

		if not itemInfo.teamLv then
			self._ccbOwner.teamLvNode:setVisible(false)
		else
			self._ccbOwner.teamLv:setString(itemInfo.teamLv)
			self._ccbOwner.teamLvNode:setVisible(true)
		end
		self._ccbOwner.node_avatar:setVisible(true)
		if not self._head then
			local head = QUIWidgetAvatar.new(itemInfo.avatar)
	    	head:setSilvesArenaPeak(itemInfo.championCount)
			self._ccbOwner.node_avatar:addChild(head)
			self._head = head
		else
			self._head:setInfo(itemInfo.avatar)
			self._head:setSilvesArenaPeak(itemInfo.championCount)
		end
	end
end


function QUIWidgetChooseServerItem:getContentSize(  )
	return self._ccbOwner.btnChooseServer:getContentSize()
end

function QUIWidgetChooseServerItem:_onTriggerChoose(event)
	if self._isOpen then
		self:dispatchEvent({name = QUIWidgetChooseServerItem.EVENT_SELECT, serverInfo = self._serverInfo})
	end
end

function QUIWidgetChooseServerItem:onCleanup()
	self:removeAllEventListeners()
end

return QUIWidgetChooseServerItem
--
-- Author: Kumo.Wang
-- 宗门红包领奖记录cell
--

local QUIWidget = import(".QUIWidget")
local QUIWidgetRedpacketRecordCell = class("QUIWidgetRedpacketRecordCell", QUIWidget)

local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIWidgetRedpacketRecordCell:ctor(options)
	local ccbFile = "ccb/Widget_Society_Redpacket_Record.ccbi"
	local callBacks = {}
	QUIWidgetRedpacketRecordCell.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetRedpacketRecordCell:onEnter()
end

function QUIWidgetRedpacketRecordCell:onExit()
end

function QUIWidgetRedpacketRecordCell:setInfo(param)
	self:_resetAll()
	if not param then return end

	self._param = param
	-- QPrintTable(self._param)

	self:_setHeroHead()
	self:_setAwardInfo()
end

function QUIWidgetRedpacketRecordCell:_setHeroHead()
    local avatarWidget = QUIWidgetAvatar.new()
    avatarWidget:setInfo(self._param.avatar)
    avatarWidget:setSilvesArenaPeak(self._param.championCount)
    self._ccbOwner.node_head:addChild(avatarWidget)
end

function QUIWidgetRedpacketRecordCell:_setAwardInfo()
    self._ccbOwner.tf_playerName:setString(self._param.nickname or "")
    self._ccbOwner.tf_playerName:setVisible(true)
    if not self._param.message or self._param.message == "" then
    	self._ccbOwner.tf_playerWords:setString(remote.redpacket.DEFAULT_GAIN_MESSAGE)
    else
    	self._ccbOwner.tf_playerWords:setString(self._param.message)
    end
    self._ccbOwner.tf_playerWords:setVisible(true)
    self._ccbOwner.tf_bonusNumber:setString(self._param.item_num or "")
    self._ccbOwner.tf_bonusNumber:setVisible(true)
    self._ccbOwner.node_icon:setVisible(true)
    self._ccbOwner.node_line:setVisible(not self._param.isLast)

    local rankType
    if self._param.isMax then
    	rankType = remote.redpacket.ONE_STATE
    -- elseif self._param.isMin then
    -- 	rankType = remote.redpacket.LAST_ONE_STATE
    end

    if rankType then
	    local path = remote.redpacket:getNumberOnePathByType(rankType)
		if path then
			local sprite = CCSprite:create(path)
	    	if sprite then
	    		self._ccbOwner.node_numberOne:addChild(sprite)
	    	end
		end
	end
end

function QUIWidgetRedpacketRecordCell:_resetAll()
	self._ccbOwner.tf_playerName:setVisible(false)
	self._ccbOwner.tf_playerWords:setVisible(false)
	self._ccbOwner.node_icon:setVisible(false)
	self._ccbOwner.tf_bonusNumber:setVisible(false)
	self._ccbOwner.node_line:setVisible(false)
	self._ccbOwner.node_head:removeAllChildren()
	self._ccbOwner.node_numberOne:removeAllChildren()
end

function QUIWidgetRedpacketRecordCell:getName()
	return "QUIWidgetRedpacketRecordCell"
end

function QUIWidgetRedpacketRecordCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

return QUIWidgetRedpacketRecordCell

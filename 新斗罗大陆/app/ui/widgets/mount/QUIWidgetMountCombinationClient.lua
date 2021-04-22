-- @Author: xurui
-- @Date:   2016-09-30 17:00:35
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-14 16:43:49
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMountCombinationClient = class("QUIWidgetMountCombinationClient", QUIWidget)

local QUIWidgetMountSmallCard = import(".QUIWidgetMountSmallCard")
local QUIViewController = import("...QUIViewController")
local QRichText = import("....utils.QRichText")

 QUIWidgetMountCombinationClient.EVENT_CLICK_CARD = "EVENT_CLICK_CARD"

function QUIWidgetMountCombinationClient:ctor(options)
	local ccbFile = "ccb/Widget_Weapon_tujian_11.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickLeft", callback = handler(self, self._onTriggerClickLeft)},
		{ccbCallbackName = "onTriggerClickRight", callback = handler(self, self._onTriggerClickRight)},
	}
	QUIWidgetMountCombinationClient.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

  	self._cardClient = {}
end

function QUIWidgetMountCombinationClient:setInfo(mount)
	self._mountIds = {}
	local isActice = true

	-- 激活方式
	local isTwice = mount.condition_num or 2
	if isTwice == 2 then
		local mountIds = string.split(mount.condition, ";")
		for i = 1, 2 do
			self._mountIds[i] = tonumber(mountIds[i])
			if self._cardClient[i] == nil then
				self._cardClient[i] = QUIWidgetMountSmallCard.new()
				self._ccbOwner["node_card"..i]:addChild(self._cardClient[i])
			end
			local mountId = self._mountIds[i]
			if db:checkHeroShields(mountId) then
				mountId = nil
			end
			self._cardClient[i]:setCardInfo(mountId, self._mountIds[1])
			if mountId ~= nil then
				isActice = isActice and remote.mount:checkMountHavePast(mountId)
			else
				isActice = false
			end
		end
		self._ccbOwner["node_mount1"]:setPositionX(136)
		self._ccbOwner["node_mount2"]:setVisible(true)
	else
		self._mountIds[1] = tonumber(mount.condition)
		if self._cardClient[1] == nil then
			self._cardClient[1] = QUIWidgetMountSmallCard.new()
			self._ccbOwner["node_card1"]:addChild(self._cardClient[1])
		end
		local mountId = self._mountIds[1]
		if db:checkHeroShields(mountId) then
			mountId = nil
		end
		self._cardClient[1]:setCardInfo(mountId, mountId)
		if mountId ~= nil then
			isActice = remote.mount:checkMountHavePast(mountId)
		else
			isActice = false
		end
		self._ccbOwner["node_mount1"]:setPositionX(246)
		self._ccbOwner["node_mount2"]:setVisible(false)
	end

	--set name and prop
	self._ccbOwner.frame_tf_title:setString(mount.name or "")
	local prop = mount.prop
	table.sort( prop, function(a, b)
		if a.isPercent ~= b.isPercent then
			return a.isPercent == true
		else
			return false
		end
	end )
	for i = 1, 4 do
		if prop[i] ~= nil then
			local buffName = string.gsub(prop[i].name, "玩家对战", "PVP")
			if prop[i].isPercent then
				self._ccbOwner["tf_prop_"..i]:setString(buffName.."+"..(prop[i].value * 100).."%")
			else
				self._ccbOwner["tf_prop_"..i]:setString(buffName.."+"..prop[i].value)
			end
		else
			self._ccbOwner["tf_prop_"..i]:setString("")
		end
		if isActice then
			self._ccbOwner["tf_prop_"..i]:setColor(GAME_COLOR_LIGHT.normal)
		else
			self._ccbOwner["tf_prop_"..i]:setColor(GAME_COLOR_LIGHT.notactive)
		end
	end
end

function QUIWidgetMountCombinationClient:getIndex()
	return self._index
end

function QUIWidgetMountCombinationClient:_onTriggerClickLeft()
	if not self._mountIds[1] then return end
	local mountId = self._mountIds[1]
	if db:checkHeroShields(mountId) then return end
	local isHave = remote.mount:checkMountHavePast(mountId)
	self:dispatchEvent({name = QUIWidgetMountCombinationClient.EVENT_CLICK_CARD, mountId = mountId, isHave = isHave})
end

function QUIWidgetMountCombinationClient:_onTriggerClickRight()
	if not self._mountIds[2] then return end
	local mountId = self._mountIds[2]
	if db:checkHeroShields(mountId) then return end
	local isHave = remote.mount:checkMountHavePast(mountId)
	self:dispatchEvent({name = QUIWidgetMountCombinationClient.EVENT_CLICK_CARD, mountId = mountId, isHave = isHave})
end

function QUIWidgetMountCombinationClient:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
	return CCSize(size.width, size.height)
end

return QUIWidgetMountCombinationClient
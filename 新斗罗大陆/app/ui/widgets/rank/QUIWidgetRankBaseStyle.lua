local QUIWidget = import("..QUIWidget")
local QUIWidgetRankBaseStyle = class("QUIWidgetRankBaseStyle", QUIWidget)
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")
local QUnionAvatar = import("....utils.QUnionAvatar")
local QStaticDatabase = import("....controllers.QStaticDatabase")
local QUIWidgetFloorIcon = import("...widgets.QUIWidgetFloorIcon")

function QUIWidgetRankBaseStyle:ctor(ccbFile, callBacks, options)
	QUIWidgetRankBaseStyle.super.ctor(self, ccbFile, callBacks, options)

	local index = 1
	while (true) do
		if self._ccbOwner["tf_"..index] ~= nil then
			self._ccbOwner["tf_"..index]:setString("")
		else
			break
		end
		index = index + 1
	end
	self._ccbOwner.sp_soulTrial:setVisible(false)
end

function QUIWidgetRankBaseStyle:setTFByIndex(index, str)
	if self._ccbOwner["tf_"..index] ~= nil then
		self._ccbOwner["tf_"..index]:setString(str)
	end
end

function QUIWidgetRankBaseStyle:setSpByIndex(index, b)
	if self._ccbOwner["sp_"..index] ~= nil then
		self._ccbOwner["sp_"..index]:setVisible(b)
	end
end

function QUIWidgetRankBaseStyle:setSpSpriteFrameByIndex(index, spriteFrame, scale)
	if self._ccbOwner["sp_"..index] ~= nil then
		self._ccbOwner["sp_"..index]:setDisplayFrame(spriteFrame)
		if scale then
			self._ccbOwner["sp_"..index]:setScale(scale)
		end
	end
end

function QUIWidgetRankBaseStyle:getNodeByIndex(index)
	return self._ccbOwner["node_"..index]
end

function QUIWidgetRankBaseStyle:getChildByName(name)
	return self._ccbOwner[name]
end

function QUIWidgetRankBaseStyle:setVIP(vip)
	if self._ccbOwner.tf_vip ~= nil then
		if vip ~= nil then
			self._ccbOwner.tf_vip:setString("VIP "..vip)
		else
			self._ccbOwner.tf_vip:setString("")
		end
	end
end

function QUIWidgetRankBaseStyle:setBadgeWithPassCount(node, passCount)
	local config = QStaticDatabase:sharedDatabase():getBadgeByCount(tonumber(passCount))
    local badge = nil
    if config then
    	badge = CCTextureCache:sharedTextureCache():addImage(config.alphaicon)
    	local badgeSp = CCSprite:createWithTexture(badge)
    	badgeSp:setPositionX(badgeSp:getContentSize().width/2)
    	node:addChild(badgeSp)
    	node:setContentSize(badgeSp:getContentSize())
    else
    	node:removeAllChildren()
    	node:setContentSize(CCSize(0,0))
    end
end

function QUIWidgetRankBaseStyle:setAvatar(avatar)
	if self._avatarWidget == nil then
		if self._ccbOwner.node_avatar ~= nil then
			self._ccbOwner.node_avatar:removeAllChildren()
			self._avatarWidget = QUIWidgetAvatar.new()
			self._ccbOwner.node_avatar:addChild(self._avatarWidget)
		end
	end
	if self._avatarWidget ~= nil then
		self._avatarWidget:setInfo(avatar)
	end
end

function QUIWidgetRankBaseStyle:setAvatarByIndex(avatar,index)
	if self._avatarWidget == nil then
		self._avatarWidget = {}
	end
	if self._avatarWidget[index] == nil then
		local parentNode = nil
		if index == 1 then
			parentNode = self._ccbOwner.node_avatar1
		elseif index == 2 then
			parentNode = self._ccbOwner.node_avatar2
		elseif index == 3 then
			parentNode = self._ccbOwner.node_avatar3
		end
		if parentNode ~= nil then
			parentNode:removeAllChildren()
			self._avatarWidget[index] = QUIWidgetAvatar.new()
			parentNode:addChild(self._avatarWidget[index])
		end
	end
	if self._avatarWidget[index] ~= nil then
		self._avatarWidget[index]:setInfo(avatar)
	end
end

function QUIWidgetRankBaseStyle:setUnionAvatar(avatar, consortiaWarFloor)
	if self._unionAvatarWidget == nil then
		if self._ccbOwner.node_avatar ~= nil then
			self._ccbOwner.node_avatar:removeAllChildren()
			self._unionAvatarWidget = QUnionAvatar.new()
			self._ccbOwner.node_avatar:addChild(self._unionAvatarWidget)
		end
	end
	if self._unionAvatarWidget ~= nil then
		self._unionAvatarWidget:setInfo(avatar)
		self._unionAvatarWidget:setConsortiaWarFloor(consortiaWarFloor)
	end
end

function QUIWidgetRankBaseStyle:setUnionAvatarPosition(posX, posY)
	if self._unionAvatarWidget ~= nil and posX and posY then
		self._unionAvatarWidget:setPosition(posX, posY)
	end
end


function QUIWidgetRankBaseStyle:setSoulTrial(soulTrial)
	local sp = self._ccbOwner.sp_soulTrial
	if not sp then return end

	local _, frame = remote.soulTrial:getSoulTrialTitleSpAndFrame(soulTrial)
	
    if frame then
        sp:setDisplayFrame(frame)
        sp:setVisible(true)
    else
        sp:setVisible(false)
    end
end

function QUIWidgetRankBaseStyle:setFloor(floor, scale, iconType )
	if self._floorWidget == nil then
		if self._ccbOwner.node_floor ~= nil then
			self._ccbOwner.node_floor:removeAllChildren()
			self._floorWidget = QUIWidgetFloorIcon.new()
			self._floorWidget:setScale(scale or 1)
			self._ccbOwner.node_floor:addChild(self._floorWidget)
		end
	end
	if self._floorWidget ~= nil then
		self._floorWidget:setInfo(floor, iconType)
	end
end

function QUIWidgetRankBaseStyle:getAvatarPosByIndex(index)
	local pos = cc.p(0,0)
	local parentNode = nil
	if index == 1 then
		parentNode = self._ccbOwner.node_avatar1
	elseif index == 2 then
		parentNode = self._ccbOwner.node_avatar2
	elseif index == 3 then
		parentNode = self._ccbOwner.node_avatar3
	end
	if parentNode then
		pos.x = parentNode:getPositionX()
		pos.y = parentNode:getPositionY()

		pos = parentNode:convertToWorldSpace(pos)
	end
	return pos
end

function QUIWidgetRankBaseStyle:autoLayout()
	
end

return QUIWidgetRankBaseStyle
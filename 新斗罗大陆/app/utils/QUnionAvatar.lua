-- Author: qinyuanji
-- Date: 2015/07/08
-- This class is the avatar wrapper to implement the avatar and frame customized.

local QUIWidgetAvatar = import("..ui.widgets.QUIWidgetAvatar")
local QUnionAvatar = class("QUnionAvatar", QUIWidgetAvatar)

function QUnionAvatar:setAvatarType()
	self._isUnion = true
end

function QUnionAvatar:getDefaultAvatar(avatarId)
	return db:getUnionIcons()[avatarId] or db:getDefaultUnion()
end

function QUnionAvatar:getDefaultFrame(frameId)
	return db:getUnionFrames()[frameId] or db:getDefaultUnionFrame()
end

function QUnionAvatar:setConsortiaWarFloor(floor)
	if not floor or floor == 0 then
        return
    end

    self._ccbOwner.node_union:setVisible(true)
    local rankInfo = remote.consortiaWar:getRankInfo(floor)
    local texture = CCTextureCache:sharedTextureCache():addImage(rankInfo.frame_icon)
    if texture then
        self._unionFrame = CCSprite:createWithTexture(texture)
        self._unionFrame:setPositionY(10)
        self._ccbOwner.node_avatar:addChild(self._unionFrame)
        self._unionFloor = floor
        if self._frame then
            self._frame:setVisible(false)
        end
    end

    self._ccbOwner.tf_frame_name:setString(rankInfo.name or "")
    local colorInfo = remote.consortiaWar:getColorByBigFloor(rankInfo.total_dan)
	self._ccbOwner.tf_frame_name:setColor(colorInfo[1])
	setShadowByFontColor(self._ccbOwner.tf_frame_name, colorInfo[2])
end

return QUnionAvatar
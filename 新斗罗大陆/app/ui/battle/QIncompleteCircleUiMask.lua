-- **************************************************
-- Author               : wanghai
-- FileName             : QIncompleteCircleUiMask.lua
-- Description          : 存储能量显示
-- Create time          : 2019-12-05 11:39
-- Last modified        : 2019-12-05 11:39
-- **************************************************

local QIncompleteCircleUiMask = class("QIncompleteCircleUiMask", function() return display.newNode() end)

local QCircleUiMask = import(".QCircleUiMask")

function QIncompleteCircleUiMask:ctor()
    local sprite_bg = CCSprite:create(QResPath("fight_storage_inbar"))
    local sprite = CCSprite:create(QResPath("fight_storage_outbar"))
    local size = sprite_bg:getContentSize()
    self._storage = QCircleUiMask.new()
    self._storage:setMaskSize(CCSize(size.width * 2, size.height * 2))
    self._storage:addChild(sprite)
    self._storage._stencil:setRotationX(-45)
    self._storage:update(0)

    self:addChild(self._storage)
    self:addChild(sprite_bg)
end

function QIncompleteCircleUiMask:update(percent)
    self._storage:update(percent * 0.85)
end

return QIncompleteCircleUiMask


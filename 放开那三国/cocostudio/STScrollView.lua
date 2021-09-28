-- Filename: STScrollView.lua
-- Author: bzx
-- Date: 2015-04-25
-- Purpose: 

STScrollView = class("STScrollView", function ()
	local ret = STNode:create()
    local subnode = CCScrollView:create()
    ret:setSubnode(subnode)
    return ret
end)

ccs.combine(STLayer, STScrollView)

function STScrollView:ctor( ... )
    STLayer.ctor(self)
    self._innerNodeSize = nil
    self._bounceable = true
    self._borderCheckSchedule = nil
    self._borderListener = nil
end

function STScrollView:create()
    local ret = STScrollView.new()
    return ret
end

function STScrollView:setInnerSize(innerNodeSize)
    self._innerNodeSize = innerNodeSize
    self._subnode:setContentSize(innerNodeSize)
    self:setContentOffset(ccp(0, self:getViewSize().height - self:getContentSize().height))
end

function STScrollView:getInnerSize( ... )
    return self._innerNodeSize
end

function STScrollView:setContentSize(nodeSize)
    self._nodeSize = nodeSize
    if self._bg ~= nil then
        self._bg:setContentSize(nodeSize)
    end
    self:setViewSize(CCSizeMake(nodeSize.width, nodeSize.height))
end

function STScrollView:getContentSize(  )
    return self._nodeSize
end

function STScrollView:setViewSize( viewSize )
   self._nodeSize = viewSize
   self._subnode:setViewSize(viewSize)
end

function STScrollView:getViewSize( ... )
	return self._subnode:getViewSize()
end

function STScrollView:setBounceable( bounceable )
    self._bounceable = bounceable
	self._subnode:setBounceable(bounceable)
end

function STScrollView:isBounceable( ... )
    return self._bounceable
end

function STScrollView:setContentOffset( offset )
	self._subnode:setContentOffset(offset)
end

function STScrollView:setDirection( direction )
	self._subnode:setDirection(direction)
end

function STScrollView:getContentOffset( ... )
    return self._subnode:getContentOffset()
end

function STScrollView:setContentOffsetInDuration(offset, dt)
    self._subnode:setContentOffsetInDuration(offset, dt)
end

function STScrollView:getContainer( ... )
    return self._subnode:getContainer()
end

function STScrollView:setClippingToBounds( clippingToBounds )
    self._subnode:setClippingToBounds(clippingToBounds)
end

function STScrollView:setBorderListener( borderListener)
    self._borderListener = borderListener
    if self._borderCheckSchedule == nil then
        local checkBorder = function ( ... )
            local offset = self._subnode:getContentOffset()
            local contentSize = self._subnode:getContentSize()
            local viewSize = self._subnode:getViewSize()
            local left = offset.x < 0
            local right = offset.x + contentSize.width > viewSize.width
            local up = offset.y + contentSize.height > viewSize.height
            local down = offset.y < 0
            self._borderListener(left, right, up, down)
        end
        checkBorder()
        self._borderCheckSchedule = schedule(self._subnode, checkBorder, 1 / 60)
    end
end

-- function STScrollView:setTouchEnabled( touchEnabled )
--     STNode.setTouchEnabled(self, touchEnabled)
--     self:setTouchEnabled(touchEnabled)
-- end
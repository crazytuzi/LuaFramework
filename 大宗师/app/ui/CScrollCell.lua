--
-- Created by IntelliJ IDEA.
-- User: 004
-- Date: 13-3-28
-- Time: 下午3:19
-- To change this template use File | Settings | File Templates.
--

local CScrollCell = class("CScrollCell", function()
    return display.newNode()
end)

function CScrollCell:onTouch(obj)
    
     if (self.bIsEnable) then
         if (type(self.touchListener) == "function") then
             self:touchListener(obj)
             
         end
     end
end

function CScrollCell:printIndex( index )
    -- body
    self.sprite:printIndex(index)
end

function CScrollCell:setAnchorPoint(p)
    self.sprite:setAnchorPoint(p)
end
--
function CScrollCell:setEnable(b)
    if b then
        self.sprite:setColor(ccc3(255, 255, 255))
    else
        self.sprite:setColor(ccc3(100, 100, 100))
    end
    self.bIsEnable = b
end

function CScrollCell:setTouchEnabled(b)
    self.bIsEnable = b
end

function CScrollCell:isEnabled()
    return self.bIsEnable
end

function CScrollCell:getData()
    return self.sprite:getData()
end

function CScrollCell:addChildEx(s)
    self.sprite:addChild(s)
end

function CScrollCell:getContentSize()
    return self.sprite:getContentSize()
end

function CScrollCell:setTouchListener(listener)
    self.touchListener = listener
end

function CScrollCell:getBoundingBox()
    return self.sprite:getBoundingBox()
end

function CScrollCell:setColor(color)

    if (self.bIsEnable and self.sprite.setColor) then
        self.sprite:setColor(color)
    end
end

function CScrollCell:setDel(del)
    self.bDel = true
end

function CScrollCell:isDel()
    return self.bDel
end


function CScrollCell:ctor(sprite)
    self.sprite = sprite
    if(tolua.type(sprite) == "CCNode") then
        sprite:printIndex(1)
    end
    sprite:setPosition(0, 0)
    self:addChild(self.sprite)

    self.bIsEnable = true

--    self:setAnchorPoint(CCPointMake(0.5, 0.5))
--    self:setContentSize(sprite:getContentSize())

end

return CScrollCell


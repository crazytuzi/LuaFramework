-- BuffDamageEntry

local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"

-- @basePosition 这里指的是基准点的位置，因为现在只支持居中对齐，所以basePosition指的是中心点的位置
-- @items 需要对齐的子项，是个table
-- @align 对齐方式

local function _autoAlign(basePosition, items, align)
    
    -- 先统计总共的宽度，因为这里居中对齐不需要考虑高度
    local totalWidth = 0
    for i=1, #items do
        totalWidth = totalWidth + items[i]:getContentSize().width
    end
    
    local function _convertToNodePosition(position, item)

        -- print("position.x: "..position.x.." position.y: "..position.y)

        -- 默认是以ccp(0, 0.5)为标准
        local anchorPoint = item:getAnchorPoint()
        return ccp(position.x + anchorPoint.x * item:getContentSize().width, position.y + (anchorPoint.y - 0.5) * item:getContentSize().height)

    end
    
    if align == ALIGN_CENTER then

        -- 然后返回一个函数，用来获取每一项节点的位置（通过index）
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x - totalWidth/2 + _width, 0), items[index])

        end
        
    elseif align == ALIGN_LEFT then
        
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x + _width, 0), items[index])

        end
        
    elseif align == ALIGN_RIGHT then
        
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x - totalWidth + _width, 0), items[index])

        end

    else
        
        assert(false, "Now we don't support other align type :"..align)
        
    end

end

local BuffDamageEntry = class("BuffDamageEntry", require "app.scenes.battle.entry.DamageEntry")

function BuffDamageEntry.create(...)
    return BuffDamageEntry.new("battle/tween/tween_damage.json", ...)
end

function BuffDamageEntry:ctor(tweenJson, buff, ...)
    
    BuffDamageEntry.super.ctor(self, tweenJson, ...)
    -- 登记一下buff
    self._buff = buff
    
    self._node:setPositionX(self._node:getPositionX() + math.random(-50, 50))
    self._node:setPositionY(self._node:getPositionY() + math.random(-50, 50))
    
end

function BuffDamageEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)
    
    local displayNode = node
    
    if not displayNode then
        
        if tweenNode == "txt" then
        
            displayNode = BuffDamageEntry.super.createDisplayWithTweenNode(self, tweenNode, frameIndex, tween, node)

            -- buff冒血需要加上类型文字
            local buffPic = self._buff.buff_tween_pic
            if buffPic ~= "0" then

                local _t = displayNode

                displayNode = display.newNode()
                local parent = _t:getParent()
                _t:retain()
                _t:removeFromParent()
                displayNode:addChild(_t)
                _t:release()

                local sprite = display.newSprite(G_Path.getBattleTxtImage(buffPic..'.png'))
                displayNode:addChild(sprite)

                local getPosition = _autoAlign(ccp(0, 0), {sprite, _t}, ALIGN_CENTER)
                sprite:setPosition(getPosition(1))
                _t:setPosition(getPosition(2))

                parent:addChild(displayNode, _t:getZOrder())

            end

            return displayNode
        
        end
        
    else
        
        return BuffDamageEntry.super.createDisplayWithTweenNode(self, tweenNode, frameIndex, tween, node)
        
    end
    
end

return BuffDamageEntry

local RebelBossCommonFunc = class("RebelBossCommonFunc")

function RebelBossCommonFunc._updateLabel(target, name, params)
    if not target then
        return
    end
    assert(target)
    local label = target:getLabelByName(name)
    assert(label, "label name = " .. name)
    if not params then
        return
    end
    if params.stroke ~= nil then
        label:createStroke(params.stroke, params.size and params.size or 1)
    end
   
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end 
end

function RebelBossCommonFunc._updateImageView(target, name, params)
    if not target then
        return
    end
    local img = target:getImageViewByName(name)
    assert(img, "img name = " .. name)
    if not params then
        return
    end
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end 
end

local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"

-- @basePosition 这里指的是基准点的位置，因为现在只支持居中对齐，所以basePosition指的是中心点的位置
-- @items 需要对齐的子项，是个table
-- @align 对齐方式
function RebelBossCommonFunc._autoAlignNew(basePosition, items, align)
    -- 先统计总共的宽度，因为这里居中对齐不需要考虑高度
    local totalWidth = 0
    for i=1, #items do
        totalWidth = totalWidth + items[i]:getContentSize().width
    end
    
    local function _convertToNodePosition(positionX, positionY, item)
        -- 默认是以ccp(0, 0.5)为标准
        local anchorPoint = item:getAnchorPoint()
        return positionX + anchorPoint.x * item:getContentSize().width, positionY + (anchorPoint.y - 0.5) * item:getContentSize().height
    end
    
    if align == ALIGN_CENTER or align == "C" then
        -- 然后返回一个函数，用来获取每一项节点的位置（通过index）
        return function(index)
            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end
            return _convertToNodePosition(basePosition.x - totalWidth/2 + _width, 0, items[index])
        end       
    elseif align == ALIGN_LEFT or align == "L" then       
        return function(index)
            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end
            return _convertToNodePosition(basePosition.x + _width, 0, items[index])
        end
    elseif align == ALIGN_RIGHT or align == "R" then
        return function(index)
            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end
            return _convertToNodePosition(basePosition.x - totalWidth + _width, 0, items[index])
        end
    else
        assert(false, "Now we don't support other align type :"..align)
    end
end

return RebelBossCommonFunc
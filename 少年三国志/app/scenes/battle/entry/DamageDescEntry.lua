-- DamageDescEntry

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

local DamageDescEntry = class("DamageDescEntry", require "app.scenes.battle.entry.TweenEntry")

function DamageDescEntry.create(...)
    return DamageDescEntry.new("battle/tween/tween_word.json", ...)
end

function DamageDescEntry:ctor(json, data, objects, battleField, isCritical, isDouble, isPierce, isRecoverDesc, isHitback, isSuckHP)
    DamageDescEntry.super.ctor(self, json, data, objects, battleField)
    -- 暴击
    self._isCritical = isCritical
    -- 双倍
    self._isDouble = isDouble
    -- 破防
    self._isPierce = isPierce
    -- 生命之光
    self._isRecoverDesc = isRecoverDesc
    -- 反弹
    self._isHitback = isHitback
    -- 吸血
    self._isSuckHP = isSuckHP
    
    self._battleField:addToDamageSpNode(self._node)
    self._node:setPosition(self._node:getParent():convertToNodeSpace(self._objects:convertToWorldSpaceAR(ccp(0, 295))))
end

function DamageDescEntry:createDisplayWithTweenNode(tweenNode, frameIndex, tween, node)
    
    local displayNode = node
    
    if not displayNode then
        if tweenNode == "name" then
            
            displayNode = display.newNode()
            
            local _label = {
                -- 是否暴击，self._data表示changeHp，数量大于0表示加血，暴击使用的不同
                self._isCritical and (self._data > 0 and G_Path.getBattleTxtImage("baoji_lv.png") or G_Path.getBattleTxtImage("baoji.png")),
                -- 是否双倍
                self._isDouble and (self._data > 0 and G_Path.getBattleTxtImage("shuangbei_lv.png") or G_Path.getBattleTxtImage("shuangbei.png")),
                -- 是否破防
                self._isPierce and G_Path.getBattleTxtImage("pofang.png"),
                -- 是否是生命之光（加血文字）
                self._isRecoverDesc and G_Path.getBattleTxtImage("shengmingzhiguang.png"),
                -- 反弹
                self._isHitback and G_Path.getBattleTxtImage("fantan.png"),
                -- 吸血
                self._isSuckHP and G_Path.getBattleTxtImage("xixue_lv.png"),
            }
            
            -- 剔除空余的，顺便添加到displayNode里
            local _tLabel = {}
            for i=1, 6 do
                if _label[i] then
                    local label = display.newSprite(_label[i])
                    _tLabel[#_tLabel+1] = label
                    displayNode:addChild(label)
                end
            end
            
            -- 排个位置
            local getPosition = _autoAlign(ccp(0, 0), _tLabel, ALIGN_CENTER)
            for i=1, #_tLabel do
                _tLabel[i]:setPosition(getPosition(i))
            end
            
        end
        
        displayNode:setCascadeOpacityEnabled(true)
        displayNode:setCascadeColorEnabled(true)
    end
    
    if displayNode then
        self._node:addChild(displayNode, tween.order or 0)
    end

    return displayNode
end

return DamageDescEntry



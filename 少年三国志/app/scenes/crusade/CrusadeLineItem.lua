
local CrusadeLineItem = class("CrusadeLineItem")

--对应解锁的站位，表现形式为：
--对应位置上的据点被击败，该线条出现发光效果
local Unlock_Positions = {
    line1 = {1,4},
    line2 = {2,5},
    line3 = {3,6},
    line4 = {4,5},
    line5 = {5,6},
    line6 = {4,7},
    line7 = {5,8},
    line8 = {6,9},
    line9 = {7,8},
    line10 = {8,9},
    line11 = {7,10},
    line12 = {8,11},
    line13 = {9,12},
    line14 = {10,11},
    line15 = {11,12},
    line16 = {10},
    line17 = {11},
    line18 = {12},
}

function CrusadeLineItem:ctor(index, widget)

    self._index  = index or 1
    self._widget = widget or nil
    self._unlockPos = Unlock_Positions["line"..index]

end


function CrusadeLineItem:_isAnyPosUnlocked( )
    
    for i=1, #self._unlockPos do
        local heroInfo = G_Me.crusadeData:getHeroInfo(self._unlockPos[i])
        --是否被击败
        if heroInfo and heroInfo.hp_rate <= 0  then
            return true
        end
    end

    return false
end

function CrusadeLineItem:updateLight(pos)

    if self._widget then

        if self:_isAnyPosUnlocked() then
            self._widget:loadTexture("ui/crusade/line_shown.png")
        else
            self._widget:loadTexture("ui/crusade/line_normal.png")

        end

--[[
        --抗锯齿 -- 怎么没用呢
        local texture = tolua.cast(target, "CCSprite")

        local _sprite = self._widget:getVirtualRenderer()
        if device.platform == "wp8" or device.platform =="winrt" then
            _sprite = tolua.cast(_sprite, "cc.Sprite")
        else
            _sprite = tolua.cast(_sprite,"CCSprite")
        end

        _sprite:getTexture():setAntiAliasTexParameters()
]]
    
    end

end

function CrusadeLineItem:setVisible(visible)
    
    if self._widget then
        self._widget:setVisible(visible)
    end

end

return CrusadeLineItem



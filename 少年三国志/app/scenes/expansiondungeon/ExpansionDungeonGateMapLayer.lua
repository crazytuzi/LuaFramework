local ExpansionDungeonGateMapLayer = class("ExpansionDungeonGateMapLayer", UFCCSNormalLayer)

local MOVE_DIRECTION = {
    UP = 1, -- 向上移动
    DOWN = 2, -- 向下移动
}

local MOVE_SPEED = 30

function ExpansionDungeonGateMapLayer.create(nMapId, ...)
    nMapId = nMapId or 1
    return ExpansionDungeonGateMapLayer.new("stagemap/ex_stagemap_" .. nMapId .. ".json", nil, ...)
end

function ExpansionDungeonGateMapLayer:ctor(json, param, ...)
    self._nCurPosY = 0
    self._bMoveEnabled = true
    self._bMoveTouch = false

    local temp = self:getRootWidget():getContentSize()
    self:setContentSize(CCSize(temp.width, temp.height))

    self._imgBg = tolua.cast(self:getImageViewByName("ImageView_Bg"):getVirtualRenderer(), CCSPRITE)

    self.super.ctor(self, json, param, ...)
end

function ExpansionDungeonGateMapLayer:onLayerEnter()
    self:registerTouchEvent(false,false,0)
end

function ExpansionDungeonGateMapLayer:onLayerExit()
    self:unregisterTouchEvent()
end

function ExpansionDungeonGateMapLayer:setMoveEnabled(bEnabled)
    self._bMoveEnabled = bEnabled
end

function ExpansionDungeonGateMapLayer:getMoveTouch()
    return self._bMoveTouch
end

function ExpansionDungeonGateMapLayer:onTouchBegin(xPos, yPos)
    self._nCurPosY = yPos
    return true
end

function ExpansionDungeonGateMapLayer:onTouchMove(xPos, yPos)
    if self._bMoveEnabled == true then
        if math.abs(self._nCurPosY  -  yPos) > 20  then
            if self._nCurPosY - yPos > 0 then
                self:_moveLayer(MOVE_DIRECTION.DOWN)
            else
                self:_moveLayer(MOVE_DIRECTION.UP)
            end
            self._nCurPosY = yPos
            self._bMoveTouch = true
        end
    end
end

function ExpansionDungeonGateMapLayer:onTouchEnd(xPos, yPos)
    self._bMoveTouch = false
end

function ExpansionDungeonGateMapLayer:updatePosition(nPosY)
    self:_setPos(nPosY)
end

function ExpansionDungeonGateMapLayer:_setPos(nPosY)
    local tRect = self._imgBg:getCascadeBoundingBox()
    local nScale = nPosY / tRect.size.height
    if nScale < 0.2 then
        nScale = 0
    end
    if nPosY == 0 or nScale > 0.8 then
        while self:_moveLayer(MOVE_DIRECTION.DOWN) do
            -- to do nothing
        end
    else
        self:setScale(1 + 0.3 * nScale)
        tRect = self._imgBg:getCascadeBoundingBox()
        local lenth = (CCDirector:sharedDirector():getWinSize().height - tRect.size.height) * nScale
        self:setPositionY(lenth)   
    end
end

function ExpansionDungeonGateMapLayer:_moveLayer(nDirection)
    local isMove = false
    local nPosY = self:getPositionY()
    local nWinHeight = CCDirector:sharedDirector():getWinSize().height
    local tRect = self._imgBg:getCascadeBoundingBox()
    local nRealHeight = tRect.size.height
    local nRealPosY = tRect.origin.y
    local nHideHeight = nRealHeight - nWinHeight

    if nDirection == MOVE_DIRECTION.DOWN then
        if nRealHeight + nRealPosY > nWinHeight then
            if nRealHeight + nRealPosY - MOVE_SPEED < nWinHeight then
                local nSpeed = nRealHeight + nRealPosY - nWinHeight
                nPosY = nPosY - nSpeed 
            else
                nPosY = nPosY - MOVE_SPEED
            end
            isMove = true
        end
    else
        if nPosY < 0 then
            if nPosY + MOVE_SPEED > 0 then
                nPosY = 0
            else
                nPosY = nPosY + MOVE_SPEED
            end
            isMove = true
        end
    end

    if isMove then
        self:setScale(1+0.3*math.abs(nPosY / nHideHeight))
        self:setPositionY(nPosY)        
    end

    return isMove
end


return ExpansionDungeonGateMapLayer
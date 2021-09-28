local DungeonMapLayer = class("DungeonMapLayer", UFCCSNormalLayer)

function DungeonMapLayer.create(mapId, ...)
    return DungeonMapLayer.new("stagemap/stagemap_" .. mapId .. ".json", nil, ...)
end

function DungeonMapLayer:ctor(json, func, ...)
    self.super.ctor(self, json, func, ...)
    self:registerTouchEvent(false,false,0)
    local temp = self:getRootWidget():getContentSize()
    self:setContentSize(CCSize(temp.width,temp.height))
    self.PosY = 0
    self.speed = 30
    self.isMove = true
    self._moveTouch = false

end

function DungeonMapLayer:setIsMove(isMove)
    self.isMove = isMove
end

function DungeonMapLayer:onTouchBegin(xPos,yPos)
    self.PosY = yPos
    return true
end

-- 得到当前是否在移动
function DungeonMapLayer:getTouchMove()
    return self._moveTouch
end

function DungeonMapLayer:onTouchEnd(xPos,yPos)
    self._moveTouch = false
end

function DungeonMapLayer:setPos(yPos)
    local sprite = self:getImageViewByName("ImageView_Bg"):getVirtualRenderer()
    sprite = tolua.cast(sprite, CCSPRITE)
   
     local rect = sprite:getCascadeBoundingBox()
     local scale = yPos/rect.size.height
     
    if scale < 0.2 then
         scale = 0
     end
        

     local num = 0
     if yPos == 0 or scale > 0.8 then 
         while(self:moveLayer(1) == true) do
            num = num + 1
         end
     else
        self:setScale(1+0.3*scale)
        rect = sprite:getCascadeBoundingBox()
        local lenth = (CCDirector:sharedDirector():getWinSize().height - rect.size.height)*scale
        self:setPositionY(lenth)  
    end
end

function DungeonMapLayer:onLayerEnter()
    
end

function DungeonMapLayer:onTouchMove(xPos,yPos)
    if self.isMove == true then
        if math.abs(self.PosY  -  yPos) > 20  then
            self:moveLayer(self.PosY  -  yPos)
            self.PosY = yPos
            self._moveTouch = true
            G_Me.dungeonData:setMapLayerPosYAndScale(self:getPositionY(),self:getScale())
        end
    end
        

    --self:setPositionY(yPos)
end

function DungeonMapLayer:moveLayer(dir)
    local _y = self:getPositionY()
     
     local sprite = self:getImageViewByName("ImageView_Bg"):getVirtualRenderer()
     sprite = tolua.cast(sprite, CCSPRITE)
     local rect = sprite:getCascadeBoundingBox()
     local lenth = rect.size.height -CCDirector:sharedDirector():getWinSize().height


     local move = false
     --  向下滑动
     if dir > 0 and rect.size.height+rect.origin.y > CCDirector:sharedDirector():getWinSize().height then
         if rect.size.height+rect.origin.y-self.speed < CCDirector:sharedDirector():getWinSize().height then
                _y = _y -rect.size.height-rect.origin.y +CCDirector:sharedDirector():getWinSize().height
         else
            _y = _y -self.speed
         end
         move = true
     -- 向上滑动
     elseif dir < 0 and self:getPositionY() < 0 then
         if  self:getPositionY()+self.speed > 0 then
            _y = 0
         else
             _y = _y +self.speed
         end
          move = true
     end
     
     if move == true  then
        self:setScale(1+0.3*math.abs(_y/lenth))
        self:setPositionY(_y)
     end

     return move
end
return DungeonMapLayer


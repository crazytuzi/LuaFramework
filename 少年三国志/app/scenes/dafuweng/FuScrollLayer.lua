
local FuScrollLayer = class("FuScrollLayer", UFCCSNormalLayer)
FuScrollCell = require("app.scenes.dafuweng.FuScrollCell")

function FuScrollLayer.create(idList,...)
    return FuScrollLayer.new("ui_layout/dafuweng_MainMoveLayer.json",idList, ...)
end

function FuScrollLayer:ctor(json,idList,...)

    self.super.ctor(self, json,...)

    -- self:setContentSize(CCSize(640 ,500))
    self:registerTouchEvent(false,true,0)

    self.isMove = false
    self.inTouch = false

    self._idList = idList
    self._itemList = {}
    self._basePanel = self:getPanelByName("Panel_base")
    local rect = self._basePanel:getContentSize()
    self._totalWidth = rect.width
    self._totalHeight = rect.height
    
    self._rectX = 348
    self._rectY = 427
    self._centerX = 320
    self._baseY = self._totalHeight/2

    self._offsetX = 180
    self._offsetY = (self._totalHeight-400)*0.5+20
    self._minX = self._centerX - self._offsetX*1.5
    self._maxX = self._centerX + self._offsetX*1.5

    self._speed = 40/self._offsetX

    self._choosedId = -1
end

function FuScrollLayer:onLayerEnter()
    self.super:onLayerEnter()
    self.isMove = false
    self:updateView()
end

function FuScrollLayer:setCallBack(container,_start,_end)
    self._container = container
    self._startCallBack = _start
    self._endCallBack = _end
end

function FuScrollLayer:setContentHeight(height)
    self:setContentSize(CCSize(640 ,height))
    self._totalHeight = height
    -- self._baseY = (self._totalHeight-400)/4+200
    self._baseY = self._totalHeight/2+30
end

function FuScrollLayer:onLayerExit()
    self:_removeTimer()
end

function FuScrollLayer:refreshItems()
    for k , v in pairs(self._itemList) do 
        v:refreshView()
    end
end

function FuScrollLayer:setContainer(container)
    self._container = container
end

function FuScrollLayer:initItems()
    --dump(self._idList)
    local index = 0
    local posList = {math.pi/2,math.pi,math.pi*3/2,0}
    for k , v in pairs(self._idList) do 
        index = index + 1
        local item = FuScrollCell.new()
        item:updateView(v)
        table.insert(self._itemList,#self._itemList+1,item)
        self._basePanel:addChild(item)
        local x = posList[index]
        self:refreshItem(item,x)
    end
end

function FuScrollLayer:refreshItem(item,x)
    local finO = self._centerX*(1+math.sin(x))
    item:setZOrder(finO)

    local maxScale = (self._totalHeight-400)/283*0.1+0.9
    local per = (finO*0.2/self._centerX+0.6)*maxScale
    item:setScale(per)

    item:setPositionXY(self._centerX-self._offsetX*math.cos(x)-self._rectX*per/2,self._baseY-self._offsetY*math.sin(x)-self._rectY*per/2)
    -- item:setOpacity(finO*255/self._centerX)
    item.degree = x
    local temp = 255*(3+math.sin(x))/4
    local grayColor = ccc3(temp, temp, temp) 
    item:setColor(grayColor)

    if self:compareNum(x,math.pi/2) then 
        self._choosedId = item:getType()
    end
end

function FuScrollLayer:compareNum(x,y)
    return math.abs(x-y) < 0.001
end

function FuScrollLayer:getVirPosX(item)
    local posx,posy = item:getPosition()
    local scale = item:getScale()
    return posx + self._rectX*scale/2
end

function FuScrollLayer:updateView()
    self:initItems()
end

function FuScrollLayer:getChoosed()
    return self._choosedId
end

function FuScrollLayer:adapterLayer()
    
end

function FuScrollLayer:checkDst(dst)
    -- dst = dst < self._minX and dst + self._maxX - self._minX or dst  
    -- dst = dst > self._maxX and dst - self._maxX + self._minX or dst  
    -- return dst
    dst = dst < 0 and dst + math.pi*2 or dst  
    dst = dst > math.pi*2 and dst - math.pi*2 or dst  
    return dst
end


function FuScrollLayer:_removeTimer()
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end
end

function FuScrollLayer:onTouchBegin(x,y)
    if self.isMove  then
        return
    end
    if self.inTouch then
        return
    end
    self.inTouch = true
    -- print("onTouchBegin :  x= "..x..",y="..y)
    -- self:_removeTimer()
    self.m_nTouchBegin = self:getParent():convertToNodeSpace(ccp(x,y))    
    self._lastX = self.m_nTouchBegin.x
    
    local start =  G_WP8.CCRectContainPt(self:boundingBox(), self.m_nTouchBegin)
    --local start = self:boundingBox():containsPoint(self.m_nTouchBegin)
    if start then
        self:_movStart()
    end

    return start
end



function FuScrollLayer:onTouchMove(x,y)
    -- print("onTouchMove :  x= "..x..",y="..y)
    if self.isMove  then
        return
    end    
    if not self.inTouch then
        return
    end
    local pt = self:getParent():convertToNodeSpace(ccp(x,y)) 
    local deltaX = pt.x - self._lastX
    self._lastX = pt.x
    -- for k,v in pairs(self._itemList) do
    --     local posx = self:getVirPosX(v)
    --     local dst = posx+deltaX
    --     dst = self:checkDst(dst)
    --     -- v:setPosition(ccp(dst,posy))
    --     self:refreshItem(v,dst)
    -- end

    self:moveAll(deltaX)


end

function FuScrollLayer:onTouchCancel(x,y)
    self:onTouchEnd(x, y)
end


function FuScrollLayer:onTouchEnd(x,y)
        if self.isMove  then
            return
        end 
        if not self.inTouch then
            return
        end
        self.inTouch = false
        local pt = self:getParent():convertToNodeSpace(ccp(x,y))
        local deltaX = pt.x - self._lastX
        self:moveAll(deltaX)

        local fDist = math.abs(pt.x - self.m_nTouchBegin.x)

        if fDist < 5 then
            self:_movEnd()
            self:moveAll(self.m_nTouchBegin.x - pt.x)
            self._container:enterGame()
            return
        end

        local leftDis = (math.pi/2 - (fDist/self._offsetX))%(math.pi/2)

        self:onMove(leftDis,pt.x > self.m_nTouchBegin.x)
end

function FuScrollLayer:moveAll(deltaX)
    self:moveAllDegree((deltaX/self._offsetX))
end

function FuScrollLayer:moveAllDegree(deltaX)
    for k,v in pairs(self._itemList) do
        local degree = v.degree
        local dst = degree+deltaX
        -- print(degree,deltaX,dst,math.sin(dst))
        dst = self:checkDst(dst)
        self:refreshItem(v,dst)
    end
end

function FuScrollLayer:onMove(dis,right)
    if dis == 0 then
        self:_movEnd()
        return
    end
    self.isMove = true
    self._leftDis = dis
    self._dir = right
    if not self._timer then
        self._timer = G_GlobalFunc.addTimer(0.05,handler(self,self._moving))
    end
end

function FuScrollLayer:_moving()
    -- print("self._leftDis "..self._leftDis.."  "..self._speed)
    if self._leftDis > self._speed then
        local dis = self._dir and self._speed or 0-self._speed
        self:moveAllDegree(dis)
        self._leftDis = self._leftDis - self._speed
    elseif self._leftDis > 0 then
        local dis = self._dir and self._leftDis or 0-self._leftDis
        self:moveAllDegree(dis)
        self._leftDis = 0
        self:_movEnd()
        self:stopMove()
    end
end

function FuScrollLayer:stopMove()
    self:_removeTimer()
    self.isMove = false
    self._leftDis = 0
end

function FuScrollLayer:_movStart()
    if self._startCallBack then
        self._startCallBack(self._container)
    end
end

function FuScrollLayer:_movEnd()
    if self._endCallBack then
        self._endCallBack(self._container)
    end
end



return FuScrollLayer


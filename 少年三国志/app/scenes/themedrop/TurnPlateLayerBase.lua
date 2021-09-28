
local TurnPlateLayerBase = class("TurnPlateLayerBase", UFCCSNormalLayer)

-- local TurnNode = require("app.scenes.common.turnplate.TurnNode")




--local self._angles = {55, 90, 125, 200, 270, 340}


function TurnPlateLayerBase:init(size, angles, startIndex)
    self._angles = angles
    self._startIndex = startIndex
    self._showList = {}
    self:setContentSize(CCSize(size.width,size.height))
    
    self.isMove = false

    -- 圆心
    self.m_nCenter = ccp(size.width*0.5,size.height*0.5)
 
    -- 椭圆长轴
    self.m_longAxis = size.width*0.45
    
    -- 椭圆短轴
    self.m_shortAxis = self.m_longAxis*0.85
    

    --zorder起点
    self.m_ZStart = 0
    
    -- 最小Y轴
    self.YMin =  self.m_nCenter.y - self.m_shortAxis
    
    -- 最大Y轴
    self.YMax = self.m_nCenter.y + self.m_shortAxis
    
    self:registerTouchEvent(false,true,0)
    
    self._knightsLayer = display.newNode()

    self:addChild(self._knightsLayer)

    
    -- for touch
    self.m_nTouchBegin = ccp(0,0)
    self.m_nTouchMove = false 
    
    self._nRate = 3
end

-- @desc 检查是否回滚回去
function TurnPlateLayerBase:judgeNeedMoveBack(dir, step)
    --print("judgeNeedMoveBack " .. dir .. "," ..  step .. "," .. tostring(self.isMove)  )
    if self.isMove == true then
        return 
    end
    self.isMove = true
    -- 计算下一个位置的角速度

    for k,v in pairs(self._showList) do

        v.speed,v.pos,v.EndAngle = self:_calcAngleSpeed(v,v.pos,dir, step)
    end
    
    self._timer = G_GlobalFunc.addTimer(0.05,handler(self,self._moveBackAnimation))
end

-- function TurnPlateLayerBase.create(size)
--     local _layer = TurnPlateLayerBase.new()
--     _layer:init(size)
--     return _layer
-- end


function TurnPlateLayerBase:addNode(node, pos)
    node.pos = pos
    node.angle = self:_calcStartAndEndAngle(pos, 1)
    node.EndAngle = node.angle

    self._knightsLayer:addChild(node)
    
    table.insert(self._showList,node)

    self:_arrange()
end

function TurnPlateLayerBase:_refresh()
    
    for k,v in pairs(self._showList) do

        v.angle = self:_calcStartAndEndAngle(v.pos, 1)

    end

    self:_arrange()
end

function TurnPlateLayerBase:getOrderList()
    local _list = self:_orderByY()
    return _list
end




--根据节点当前角度angle计算位置, 缩放, zorder
function TurnPlateLayerBase:_arrange()
    --self:arrangeAngle()
    self:_arrangePosition()
    self:_arrangeScale()
    self:_arrangeZOrder()
end

function TurnPlateLayerBase:onLayerExit()
    self:_removeTimer()
end


-- @desc 设置位置
function TurnPlateLayerBase:_arrangePosition()
    for k,v in pairs(self._showList) do
        local fAngle = math.fmod(v.angle, 360.0)
        local x = math.cos(fAngle/180.0*3.14159)*self.m_longAxis + self.m_nCenter.x
        local y = math.sin(fAngle/180.0*3.14159)*self.m_shortAxis*0.5 + self.m_nCenter.y
        v:setPosition(ccp(x, y))

        self:onMove()
    end
end

-- @desc 重新设置z轴
function TurnPlateLayerBase:_arrangeZOrder()
    local ZMax = self.m_ZStart + #self._showList

    local _list = self:_orderByY()

    for k,v in pairs(_list) do
        v:setZOrder(ZMax)
        ZMax = ZMax + 1
    end
end

function TurnPlateLayerBase:_orderByY()
    local _list = {}
    for k,v in pairs(self._showList) do
        table.insert(_list,v)
    end
    table.sort(_list,function(p1,p2)
        return p1:getPositionY() > p2:getPositionY()
    end)
    return _list
end

function TurnPlateLayerBase:_arrangeScale ()
     for k,v in pairs(self._showList) do
        local fy = v:getPositionY() 
        if fy < 0 then fy = 0 end
        local fScale = fy /(self.m_shortAxis*2)
        v:setImageScale(1- 1*fScale)
    end
end

--当自动滑动的过程中,根据速度修改卡牌的角度, 当卡牌到达目标角度时,返回,停止
function TurnPlateLayerBase:_moveShow()
    local finished = true
    for k,v in pairs(self._showList) do  
        if v.speed ~= 0 then
            --print( k .. " " .. math.abs(v.angle - v.EndAngle) .. " ---" .. math.abs(v.speed))

            if math.abs(v.angle - v.EndAngle) <= math.abs(v.speed)
              or  (v.speed <0 and v.angle <= v.EndAngle ) 
              or (v.speed >0 and v.angle >= v.EndAngle ) then 
                v.angle = v.EndAngle
                v.speed = 0
            else
                v.angle = v.angle+v.speed
                finished = false
            end

        end
    end
    return finished
end

-- @desc 计算角速度
--自动滑动的时候, 需要知道现在要往哪个方向(dir)滑动多少格(step), 然后计算出一个速度, 然后在movieShow里修改angle
function TurnPlateLayerBase:_calcAngleSpeed(sprite,pos,dir, step)
    if step == nil then
        step = 1  --滑多少格
    end
    local temp = pos + dir*step
    local len = #self._angles
    if temp > len then 
        temp = temp - len 
    end
    
    if temp  < 1 then 
        temp = temp + len 
    end
    local _startAngle,_endAngle = self:_calcStartAndEndAngle(pos,dir, step)

    if _endAngle > sprite.angle and dir < 0 or step == 0 then
        _endAngle = _endAngle - 360
    end
    --[[
    if step == 0 then
        _endAngle = _endAngle - 360
    end
    ]]

    --sprite.angle = _startAngle
    local subValue = _endAngle - sprite.angle

    return subValue/self._nRate,temp,_endAngle
end

-- @desc 计算下一个位置的角度
-- @return param1 开始角度 @param2终点角度
function TurnPlateLayerBase:_calcStartAndEndAngle(index,dir,step)
    if step == nil then
        step = 1
    end


    local startIndex = self._startIndex + index 
    if startIndex > #self._angles then
        startIndex = startIndex - #self._angles
    end


    local endIndex = startIndex + dir*step 
    if endIndex > #self._angles then
        endIndex = endIndex -  #self._angles
    end
    if endIndex < 1 then
        endIndex = endIndex +  #self._angles
    end


    local startAngle = self._angles[startIndex]
    local endAngle  = self._angles[endIndex]


    if dir == 1 then
        if startAngle > endAngle then
            if startAngle - 360 < 0 then
                endAngle = endAngle + 360
            else
                startAngle = startAngle - 360
            end
        else
      
        end
    else
        if startAngle < endAngle then
            if endAngle - 360 < 0 then
                startAngle = startAngle + 360
            else
                endAngle = endAngle - 360
            end
        end
    end
    return startAngle, endAngle
    -- if dir == 1 then
    --     if index == 1 then
    --         return 270,340
    --     elseif index == 2 then
    --         return 340,415
    --     elseif index == 3 then
    --         return 55,90
    --     elseif index == 4 then
    --         return 90,125
    --     elseif index == 5 then
    --         return  125,200
    --     else
    --         return 200,270
    --     end  
    -- else
    --     if index == 1 then
    --         return 270,200
    --     elseif index == 2 then
    --         return 340,270
    --     elseif index == 3 then
    --         return 415,340
    --     elseif index == 4 then
    --         return 90,55
    --     elseif index == 5 then
    --         return  125,90
    --     else
    --         return 200,125
    --     end  
    -- end

end

-- @desc 点击武将
function TurnPlateLayerBase:onClick(pt)
   local _list = self:_orderByY()
   
   for k,v in pairs(_list) do
        if v:containsPt(pt) then
     
            if self:onClickNode(v) then
                return
            end


        end

   end
   
   return nil 
end

function TurnPlateLayerBase:_removeTimer()
    if self._timer then
        G_GlobalFunc.removeTimer(self._timer)
        self._timer = nil
    end
end

function TurnPlateLayerBase:onTouchBegin(x,y)
    if self.isMove  then
        return
    end

    -- self:_removeTimer()
    
    self.m_nTouchBegin = self:getParent():convertToNodeSpace(ccp(x,y))    

   -- return self:boundingBox():containsPoint(self.m_nTouchBegin)
    return G_WP8.CCRectContainPt(self:boundingBox(), self.m_nTouchBegin)
end



function TurnPlateLayerBase:onTouchMove(x,y)
    if self.isMove  then
        return
    end    

    self._nRate = 3

    local pt = self:getParent():convertToNodeSpace(ccp(x,y)) 
    local deltaX = pt.x - self.m_nTouchBegin.x
    for k,v in pairs(self._showList) do
        local  startAngle, endAngle = self:_calcStartAndEndAngle(v.pos, deltaX > 0 and 1 or -1, 1)
        local percent = math.abs(deltaX/300)
        if percent > 1 then percent = 1 end  

        v.angle = startAngle + (endAngle - startAngle)*percent

    end

    self:_arrange()
    self:onMove()


end

function TurnPlateLayerBase:onTouchCancel(x,y)
    self:onTouchEnd(x, y)
end


function TurnPlateLayerBase:onTouchEnd(x,y)

        local pt = self:getParent():convertToNodeSpace(ccp(x,y))

        --self:judgeNeedMoveBack()
        local fDist = math.abs(pt.x - self.m_nTouchBegin.x)
        --print("fdist=" .. fDist)
        if fDist > 10 then 
            local step = 1
            local dir = (pt.x - self.m_nTouchBegin.x)/math.abs(pt.x - self.m_nTouchBegin.x)
            self:judgeNeedMoveBack(dir, step)
            return
        else
            --这个时候可能位置有点移动, 修正一下
            self:_refresh()



            self:onMoveStop("refresh")
            self:onClick(ccp(x,y))
        
        end

end

function TurnPlateLayerBase:onMoveStop(reason)
    
end

function TurnPlateLayerBase:_moveBackAnimation()
    local key = table.keys(self._showList)
    if self:_moveShow() then
        self:_removeTimer()
        self.isMove = false
        --print("end animation")
        G_SoundManager:playSound(require("app.const.SoundConst").GameSound.UI_SLIDER)

        self:onMoveStop("back")
    end
    self:_arrange()
end


function TurnPlateLayerBase:moveStep(nDir, nStep)
    -- body
end

function TurnPlateLayerBase:getNodeList()
    return self._showList
end

return TurnPlateLayerBase

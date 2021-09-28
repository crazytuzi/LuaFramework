local TurnplateLayer = require("app.scenes.common.turnplate.TurnplateLayer")
local PetTurnplateLayer = class("PetTurnplateLayer", TurnplateLayer)
local EffectNode = require "app.common.effects.EffectNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

--6个圆圈的角度

local openCount = 3
local txtUrl = {"ui/text/txt/zc_btn_shengji.png","ui/text/txt/zc_btn_shengxing.png","ui/text/txt/zc_btn_shenlian.png",}
local roundImgUrl = {"ui/pet/tuteng_shengji.png","ui/pet/tuteng_shengxing.png","ui/pet/tuteng_shenlian.png",}
local btnUrl = {"ui/pet/btn_yc_normal.png","ui/pet/btn_yc_down.png",}
local defaultImgUrl = {"ui/pet/zc_btn_wenhao_normal.png","ui/pet/zc_btn_wenhao.png",}
local roundEffectName = {"effect_shoulan_b","effect_shoulan_a"}

local angles = {55, 90, 125, 200, 270, 340}

function PetTurnplateLayer:init(size,container)
    self.super.init(self, size, angles, 0)

    -- -- 椭圆短轴
    -- self.m_shortAxis = self.m_longAxis*0.85
    -- -- 最小Y轴
    -- self.YMin =  self.m_nCenter.y - self.m_shortAxis
    -- -- 最大Y轴
    -- self.YMax = self.m_nCenter.y + self.m_shortAxis

    self._size = size
    self._container = container

    self._effectList = {}
    for i = 1 , 2 do
        local effect = EffectNode.new(roundEffectName[i])
        container:getImageViewByName("Image_bg"):addNode(effect)
        effect:setPosition(ccp(0,0))
        effect:setScale(0.5)
        effect:play()
        self._effectList[i] = effect
    end
    local roundImg = ImageView:create()
    roundImg:setPosition(ccp(0,-33))
    roundImg:setScale(0.5)
    container:getImageViewByName("Image_bg"):addChild(roundImg)
    self._roundImg = roundImg
    self._roundImg:setVisible(false)
    -- self._roundImg:loadTexture(roundImgUrl[1])
    -- self._scaleY = 0.4
    -- self._plateImg = ImageView:create()
    -- self._plateImg:loadTexture("ui/pet/yuanhuan.png")
    -- self._plateImg:setPosition( self.m_nCenter)
    -- self._plateImg:setScaleY(self._scaleY)
    -- self:addChild(self._plateImg,1)
    self._knightsLayer:setZOrder(2)
    
    local pos = ccp(0,17)
    for i=1,6 do
        local img = ImageView:create()
        img.developeType = i
        img.showState = 0
        local typeImg = ImageView:create()
        img.showLabelImg = typeImg
        typeImg:setPosition(pos)
        img:addChild(typeImg)
        local typeLabel = GlobalFunc.createGameLabel("",26,ccc3(0xe3,0x71,0x33),ccc3(0x25,0x25,0x37))
        typeLabel:setScaleY(0.85)
        img.showLabel = typeLabel
        typeLabel:setPosition(pos)
        img:addChild(typeLabel)
        self:addNode(img, i)
    end
    self:updateButtons(1)
end

function PetTurnplateLayer:updateButtons(state)
    for k,v in pairs(self._showList) do
        local st = v.angle == 270 and 2 or state
        self:updateButton(v,st)
    end
    self._effectList[1]:setVisible(state==1)
    self._effectList[2]:setVisible(state==2)
    if state == 1 then
        self:roundShow()
    else
        self:roundHide()
    end
end

function PetTurnplateLayer:updateButton(img,state)
    if img.showState ~= state then
        img.showState = state
        local developeType = img.developeType
        img:loadTexture(btnUrl[state])
        if developeType <= openCount then
            img.showLabelImg:loadTexture(txtUrl[developeType])
            img.showLabel:setText(G_lang:get("LANG_PET_DEVELOP_TYPE"..developeType))
            img.showLabelImg:setVisible(state==2)
            img.showLabel:setVisible(state==1)
        else
            img.showLabelImg:loadTexture(defaultImgUrl[state])
            img.showLabel:setVisible(false)
        end
    end
end

function PetTurnplateLayer:_arrangeZOrder()

    local _list = self:_orderByY()

    for k,v in pairs(_list) do
        local y = v:getPositionY()
        v:setZOrder(self._size.height - y)
    end
end

function PetTurnplateLayer:setImg(img)
    self._knightsLayer:addChild(img,self._size.height/2)
    img:setPositionXY(self.m_nCenter.x,self.m_nCenter.y-70)
end

function PetTurnplateLayer:onLayerExit()

    self.super.onLayerExit(self)
end

function PetTurnplateLayer:roundShow()
    local node = self:getFront()
    if node and node.developeType <= openCount then
        self._roundImg:stopAllActions()
        self._roundImg:loadTexture(roundImgUrl[node.developeType])
        self._roundImg:setOpacity(0)
        self._roundImg:setVisible(true)
        self._roundImg:runAction(
            CCSequence:createWithTwoActions(CCFadeIn:create(0.5),CCCallFunc:create(function()
                  self._roundImg:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.8,200), CCFadeTo:create(0.8,255))))
         end)))
    end
end

function PetTurnplateLayer:roundHide()
    local node = self:getFront()
    if node and node.developeType <= openCount then
        self._roundImg:stopAllActions()
        self._roundImg:runAction(CCFadeOut:create(0.5))
    end
end

-- @desc 设置位置
function PetTurnplateLayer:_arrangePosition()
    for k,v in pairs(self._showList) do
        local fAngle = math.fmod(v.angle, 360.0)
        local x = math.cos(fAngle/180.0*3.14159)*self.m_longAxis + self.m_nCenter.x
        local y = math.sin(fAngle/180.0*3.14159)*self.m_shortAxis*0.68 + self.m_nCenter.y
        v:setPosition(ccp(x, y))
    end
end

function PetTurnplateLayer:onMove()

end

function PetTurnplateLayer:getFront()
    local _list = self:getOrderList()
    for k,v in ipairs(_list) do
        if v.angle == 270 then
            --取到最前面那个
            return v
        end
    end
    return nil
end

function PetTurnplateLayer:onMoveStop(reason)

        local node = self:getFront()
        if node then
            self._container:checkLayer(node.developeType)  
            self:updateButtons(1)
        end
end

function PetTurnplateLayer:onTouchBegin(x,y)
    if self.isMove  then
        return
    end
    
    self.m_nTouchBegin = self:getParent():convertToNodeSpace(ccp(x,y))    
    local state = G_WP8.CCRectContainPt(self:boundingBox(), self.m_nTouchBegin)
    if state then
        self:startTouch()
    end
    return state
end

function PetTurnplateLayer:onTouchEnd(x,y)

        local pt = self:getParent():convertToNodeSpace(ccp(x,y))

        --self:judgeNeedMoveBack()
        local fDist = math.abs(pt.x - self.m_nTouchBegin.x)
        --print("fdist=" .. fDist)
        if fDist > 10 then 
            local step = 1
            local dir = (pt.x - self.m_nTouchBegin.x)/math.abs(pt.x - self.m_nTouchBegin.x)
            while not self:checkNode(dir,step) do
                step = step + 1
            end
            self:judgeNeedMoveBack(dir, step)
            return
        else
            --这个时候可能位置有点移动, 修正一下
            self:_refresh()

            -- self:onMoveStop("refresh")
            self:onClick(ccp(x,y))
        
        end

end

function PetTurnplateLayer:checkNode(dir,step)
    local curPos = 5
    dir = dir > 0 and 1 or -1
    local pos = curPos - step*dir
    pos = pos > 6 and pos - 6 or pos
    pos = pos < 1 and pos + 6 or pos
    for k , v in pairs(self._showList) do 
        if v.pos == pos then
            return v.developeType <= openCount
        end
    end
    return true
end

function PetTurnplateLayer:_calcAngleSpeed(sprite,pos,dir, step)
    local speed,pos,EndAngle = self.super._calcAngleSpeed(self,sprite,pos,dir, step)
    return speed/2 , pos , EndAngle
end

function PetTurnplateLayer:startTouch()
    self._container:hideLayer()
    self:updateButtons(2)
end

function PetTurnplateLayer:_arrangeScale ()
     for k,v in pairs(self._showList) do
        local fy = v:getPositionY() - self.YMin
        if fy < 0 then fy = 0 end
        local fScale = fy /(self.m_shortAxis*2)
        v:setScale(1- 0.6*fScale)
    end
end

-- @desc 点击
function PetTurnplateLayer:onClick(pt)
   local _list = self:getOrderList()
   local clickNode = nil
   local basePanel = self._container:getPanelByName("Panel_click")
   if basePanel then
        local imagePt = basePanel:convertToNodeSpace(  pt  )
        local size = basePanel:getContentSize()
        local w = size.width
        local h = size.height
        local rect = CCRectMake(0,0, w, h)
        if G_WP8.CCRectContainPt(rect, imagePt) then
            self._container:goList()
            return
        end
   end
   for k,v in pairs(_list) do
        local imagePt = v:convertToNodeSpace(  pt  )
        local size = v:getContentSize()
        local w = size.width*v:getScaleX()
        local h = size.height*v:getScaleY()
        local rect = CCRectMake(-w/2, -h/2, w, h)
        if G_WP8.CCRectContainPt(rect, imagePt) then
            local _angle = v.angle
            if v.developeType > openCount then
                G_MovingTip:showMovingTip(G_lang:get("LANG_PET_DEVELOP_NOT_OPEN"))
                self:onMoveStop("refresh")
                return
            end
            if _angle < 0 then _angle = _angle + 360 end
            if _angle > 360 then _angle = _angle - 360 end
            local n = #angles
            for k , v in pairs(angles) do 
                if _angle == v then
                    local dir , step = 0 , 0
                    if k == 3 or k == 4 then
                        dir = 1
                        step = 5 - k
                    else
                        dir = -1
                        step = k > 3 and k - 5 or k + 1
                    end
                    if step ~= 0 then
                        self:judgeNeedMoveBack(dir, step)
                        return
                    end
                end
            end

        end

   end
   self:onMoveStop("refresh")
end

function PetTurnplateLayer:rollTo(index)
    local _list = self:getOrderList()
    local deltaPos = 0
    for k,v in ipairs(_list) do
        if v.developeType == index then
            deltaPos = 5 - v.pos
        end
    end
    
    for k,v in ipairs(_list) do
        v.pos = v.pos + deltaPos
        v.pos = v.pos < 1 and v.pos + 6 or v.pos
        v.pos = v.pos > 6 and v.pos - 6 or v.pos
        v.angle = angles[v.pos]
        v.EndAngle = v.angle
        v.speed = 0
    end
    self:_arrange()
    self:updateButtons(1)
end

function PetTurnplateLayer:judgeNeedMoveBack(dir, step)
    if self.isMove == true then
        return 
    end
    self.super.judgeNeedMoveBack(self,dir,step)
    self:updateButtons(2)
end

return PetTurnplateLayer

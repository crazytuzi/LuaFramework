-- HeroGodTurnplateLayer.lua
-- 化神拖动列表

local TurnplateLayer = require("app.scenes.common.turnplate.TurnplateLayer")
local HeroGodTurnplateLayer = class("HeroGodTurnplateLayer", TurnplateLayer)
local EffectNode = require "app.common.effects.EffectNode"
local HeroGodCommon = require "app.scenes.herofoster.god.HeroGodCommon"
local KnightConst = require("app.const.KnightConst")

HeroGodTurnplateLayer.CELL_COUNT = 15

HeroGodTurnplateLayer.icons = {1, 1, 1, 1, 2, 1, 1, 1, 1, 2, 1, 1, 1, 1, 3}
HeroGodTurnplateLayer.effects = {'a','a','a', 'a', 'b', 'a', 'a', 'a', 'a', 'b', 'a', 'a', 'a', 'a', 'c'}

function HeroGodTurnplateLayer:init(container, nowGodLevel,quality)

    self._container = container
    self._lightImages = {}
    self._lightEffects = {}
    self._pivotalPos = 6 -- 关键位置，移动的时候用
	local baseAng = 270
	local distance = 15.8
	self._angles = {}
	for i = 1, HeroGodTurnplateLayer.CELL_COUNT + 1 do
		self._angles[i] = (i - 4.5) * distance + baseAng
	end

	local size = CCSizeMake(840, 300)

	self.super.init(self, size, self._angles, 0)

	 -- 圆心
    self.m_nCenter = ccp(size.width*0.5,size.height*0.5 + 140)
 
    -- 椭圆长轴
    self.m_longAxis = size.width*0.52
    
    -- 椭圆短轴
    self.m_shortAxis = self.m_longAxis*0.85

	-- 拖动列表中所有的cell初始化
	for i = 1, HeroGodTurnplateLayer.CELL_COUNT + 1 do

        local node = CCNode:create()
		
		if i > 1 then
            local lightImageView = ImageView:create()
            node:addChild(lightImageView)
            self._lightImages[i - 1] = lightImageView
		    lightImageView:loadTexture(string.format("ui/yangcheng/light_%d_off.png", HeroGodTurnplateLayer.icons[i - 1]))

            local effect = EffectNode.new("effect_huashen_deng_" .. HeroGodTurnplateLayer.effects[i - 1])
            effect:play()
            self._lightEffects[i - 1] = effect
            node:addChild(effect)

            local jie, ji = HeroGodCommon.getDisplyLevel2(i - 1)
            local display
            if ji == 0 then
                display = HeroGodCommon.getDisplyLevel4(i - 1, quality)
            else
                display = G_lang:get("LANG_GOD_JIESHU_LEVEL", {level = ji})
            end

            local levelLabel = GlobalFunc.createGameLabel(display,20,ccc3(0xfe,0xf6,0xd8), Colors.strokeBrown)
            levelLabel:setPositionXY(-5, - 42)
            if ji == 0 then
                levelLabel:setColor(Colors.getColor(quality))
            end
            node:addChild(levelLabel)
        end
		self:addNode(node, i)
	end

    self:updateLightStatus(nowGodLevel)
end

function HeroGodTurnplateLayer:updateLightStatus(nowGodLevel)
    for i = 1, HeroGodTurnplateLayer.CELL_COUNT do
        self._lightImages[i]:setVisible(nowGodLevel < i)
        self._lightEffects[i]:setVisible(nowGodLevel >= i)
    end

    local toPos = nowGodLevel == 0 and 1 or nowGodLevel

    toPos = toPos + 3

    if toPos >= #self._showList - 1 then
        toPos = #self._showList - 1
    end

    self:scrollTo(toPos)
end

function HeroGodTurnplateLayer:addNode(node, pos)
    node.pos = pos
    node.angle = self:_calcStartAndEndAngle(pos, 1)
    node.EndAngle = node.angle

    self._knightsLayer:addChild(node)

    if self._showList[pos] then
        self._showList[pos]:removeFromParentAndCleanup(true)
        self._showList[pos] = nil
    end
    
    self._showList[pos] = node

    self:_arrange()
end

function HeroGodTurnplateLayer:onMove()

end

function HeroGodTurnplateLayer:setImageScale(s)

	self:getRootWidget():setScale(s)
end

function HeroGodTurnplateLayer:_arrangeScale()
    for k,v in ipairs(self._showList) do
        local x, y = v:getPosition()
        if y >= self.m_nCenter.y then
        	v:setVisible(false)
        else
        	v:setVisible(true)
        end

    end
end

-- @desc 检查是否回滚回去
function HeroGodTurnplateLayer:judgeNeedMoveBack(dir, step, immediately)
    --print("judgeNeedMoveBack " .. dir .. "," ..  step .. "," .. tostring(self.isMove)  )
    if self.isMove == true then
        return 
    end
    self.isMove = true
    -- 计算下一个位置的角速度

    local isBack = false

    if self._showList[2].angle > self._angles[2] and self._showList[2].angle < self._angles[7] then
    	isBack = true
    elseif self._showList[HeroGodTurnplateLayer.CELL_COUNT + 1].angle > self._angles[2] 
        and self._showList[HeroGodTurnplateLayer.CELL_COUNT + 1].angle < self._angles[7] then
    	isBack = true
    end

    if not isBack then
        self._pivotalPos = self._pivotalPos + dir * step * -1
    end

    for k,v in pairs(self._showList) do

    	if not isBack then
        	v.speed,v.pos,v.EndAngle = self:_calcAngleSpeed(v,v.pos, dir, step)
        else
        	v.speed,v.pos,v.EndAngle = self:_calcAngleSpeed(v,v.pos, dir * -1, 0)
        end
        v.StartAngle = v.angle
    end

    if not immediately then
        self._timer = G_GlobalFunc.addTimer(0.05,handler(self,self._moveBackAnimation))
    else
        for k,v in pairs(self._showList) do
             v.angle = v.EndAngle
        end
       
        self:_arrange()
        self.isMove = false
    end
end

function HeroGodTurnplateLayer:scrollTo(idx)

    if idx == 0 then idx = 1 end
    
    if idx > self._pivotalPos or idx <= self._pivotalPos - 3 then
        if idx <= 6 then idx = 6 end
        local step = self._pivotalPos - idx
        local dir = math.abs(step) / step
        step = math.abs(step)

        self:judgeNeedMoveBack(dir, step, true)
    end
end

function HeroGodTurnplateLayer:onTouchBegin(x,y)
    if self.isMove  then
        return
    end

    -- self:_removeTimer()
    
    self.m_nTouchBegin = self:getParent():convertToNodeSpace(ccp(x,y))    

   -- return self:boundingBox():containsPoint(self.m_nTouchBegin)
    return G_WP8.CCRectContainPt(self:boundingBox(), self.m_nTouchBegin)
end

function HeroGodTurnplateLayer:onTouchMove(x,y)
    if self.isMove  then
        return
    end    
    local ptx, pty = self:getParent():convertToNodeSpaceXY(x,y) 
    local deltaX = ptx - self.m_nTouchBegin.x
    for k,v in pairs(self._showList) do
        local  startAngle, endAngle = self:_calcStartAndEndAngle(v.pos, deltaX > 0 and 1 or -1, 1)
        local percent = math.abs(deltaX/300)
        if percent > 0.9 then percent = 0.9 end

        v.angle = startAngle + (endAngle - startAngle)*percent

        -- if startAngle > endAngle then
        --     if v.angle < endAngle then
        --         -- v.pos = v.pos - 1
        --         -- if v.pos < 1 then
        --         --     v.pos = #self._showList
        --         -- end
        --         -- local  startAngle, endAngle = self:_calcStartAndEndAngle(v.pos, deltaX > 0 and 1 or -1, 1)
        --         -- v.StartAngle = startAngle
        --         -- v.EndAngle = endAngle
        --     end
        -- end

        -- print("pos:" .. v.pos .. " startAngle: " .. startAngle .. " endAngle:" .. endAngle .. " angle:" .. v.angle)

    end

    self:_arrange()
    self:onMove()
end

function HeroGodTurnplateLayer:onTouchEnd(x,y)

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

function HeroGodTurnplateLayer:onClick(pt)
   
   for k,v in ipairs(self._lightImages) do
   		local imagePt = v:convertToNodeSpace(  pt  )
        local size = v:getContentSize()
        local w = size.width*v:getScaleX()
        local h = size.height*v:getScaleY()
        local rect = CCRectMake(-w/2, -h/2, w, h)
        if G_WP8.CCRectContainPt(rect, imagePt) then
            local y = v:getPositionY()
            if y < self.m_nCenter.y then
                self._container:lightOnClick(k)
            end
        end
   end
   
   return nil 
end

function HeroGodTurnplateLayer:getWorldWorldSpaceXYByIndex(index)
    if index == 0 then index = KnightConst.KNIGHT_GOD_RED_MAX_LEVEL end
    local lightImage = self._lightImages[index]
    local x, y = lightImage:convertToWorldSpaceXY(0, 0)
    return x, y
end

return HeroGodTurnplateLayer
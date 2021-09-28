local TreasureComposeItem = class("TreasureComposeItem",function ()
    return CCSPageCellBase:create("ui_layout/treasure_TreasureComposeItem.json")
end)

require("app.cfg.treasure_compose_info")
require("app.cfg.treasure_info")
local EffectNode = require "app.common.effects.EffectNode"
local TreasureComposeFragmentItem = require("app.scenes.treasure.cell.TreasureComposeFragmentItem")

--半径,固定的
local radius = 180
--圆心坐标   固定的
local x,y = 320,288

function TreasureComposeItem:ctor(layer,_id,...)
    self._nameLabel = self:getLabelByName("Label_treasureName")
    self._nameLabel:createStroke(Colors.strokeBlack,1)
    self._itemImage = self:getButtonByName("Button_item")
    self._idNames = {"fragment_id_1","fragment_id_2","fragment_id_3","fragment_id_4","fragment_id_5","fragment_id_6",}
    -- self:updatePage(fragmentList)
    self._treasureTypeImage = self:getImageViewByName("Image_treasureType")
    --碎片IDList
    self._layer = layer
    self._fragmentIdList = {}
    --碎片Item控件
    self._fragmentList = {}
    self._id = _id
    self:registerBtnClickEvent("Button_item",function()
        local compose_info = treasure_compose_info.get(self._id)
        require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_TREASURE, compose_info.treasure_id)
        end)
end

--检查碎片是否足够合成
function TreasureComposeItem:checkFragmentEnough()
   if self._fragmentIdList == nil or #self._fragmentIdList == 0 then
        return false
   end
   for i,v in ipairs(self._fragmentIdList) do
        local fragment = G_Me.bagData.treasureFragmentList:getItemByKey(v)
        if fragment == nil or fragment["num"]==0 then
            return false
        end 
   end
   return true
end

-- 检查碎片是否可以合成两次或以上
function TreasureComposeItem:checkFragmentComposeTwiceEnough()
   return self:calFragComposeTimes() >= 2
end

-- 检查碎片可以合成几次
function TreasureComposeItem:calFragComposeTimes(  )
    local num = 0

    if self._fragmentIdList == nil or #self._fragmentIdList == 0 then
        return num
   end

   for i,v in ipairs(self._fragmentIdList) do
        local fragment = G_Me.bagData.treasureFragmentList:getItemByKey(v)
        if fragment ~= nil then
            if num > 0 and fragment["num"] < num then
                num = fragment["num"]
            elseif num == 0 then
                num = fragment["num"]
            end
        else
            num = 0
            return num
        end 
   end
   return num
end

function TreasureComposeItem:isBasic()
    local compose = treasure_compose_info.get(self._id)
    local treasure = treasure_info.get(compose.treasure_id)
    return treasure.is_basic == 1
end

--[[
    animationFlag :第一次进入时，播放动画
    ]]
function TreasureComposeItem:updatePage( animationFlag,_id)
    self:clearAll()
    if _id then
        self._id = _id
    end
    if self.timer ~= nil then
        GlobalFunc.removeTimer(self.timer)
        self.timer = nil
    end
    local compose = treasure_compose_info.get(self._id)
    local treasure = treasure_info.get(compose.treasure_id)
    self._itemImage:loadTextureNormal(G_Path.getTreasurePic(treasure.res_id),UI_TEX_TYPE_LOCAL)
    self._itemImage:setScale(0.4)
    self._nameLabel:setColor(Colors.qualityColors[treasure.quality])
    self._nameLabel:setText(treasure.name)

    self._treasureTypeImage:loadTexture(G_Path.getTreasureTypeImage(treasure.type))
    if self._fragmentList ~= nil then
        for i,v in ipairs(self._fragmentList)do
            v:removeFromParentAndCleanup(true)
        end
        self._fragmentList = {}
    end

    if self._fragmentIdList ~= nil then
        self._fragmentIdList = {}
    end

    if self._fragmentIdList == nil or #self._fragmentIdList == 0 then
        for i,v in ipairs(self._idNames) do
            if compose[v]~= nil and compose[v] > 0 then
                self._fragmentIdList[#self._fragmentIdList+1] = compose[v]
            end
        end
    end
    
    if self._fragmentIdList == nil or #self._fragmentIdList == 0 then
        return
    end 
    

    self.angles = {}
    if #self._fragmentIdList == 2 then
       self.angles = {0,180}
    elseif #self._fragmentIdList == 3 then
        self.angles = {-30,-150,90}
    elseif #self._fragmentIdList == 4 then
        self.angles = {0,90,180,270}
    elseif #self._fragmentIdList == 5 then
        self.angles = {18,90,162,234,306}
    elseif #self._fragmentIdList == 6 then
        self.angles = {30,90,150,210,270,330}
    elseif #self._fragmentIdList == 7 then
        local diff = 360/7
         self.angles = {90-3*diff,90-2*diff,90-diff,90,90+diff,90+2*diff,90+3*diff}
    elseif #self._fragmentIdList == 8 then
        local diff = 360/8
        for i=1,8 do
            self.angles[i] = diff*(i-1)
        end 
    end 
 
    for i=1,#self.angles do
        if self._fragmentList[i] == nil then
            self._fragmentList[i] = TreasureComposeFragmentItem.new(self._fragmentIdList[i])
            local fragmentWidth = self._fragmentList[i]:getContentSize().width
            local fragmentHeight = self._fragmentList[i]:getContentSize().height
            local x01 = x+radius*math.cos(math.rad(self.angles[i])) - fragmentWidth/2
            local y01 = y+radius*math.sin(math.rad(self.angles[i])) - fragmentHeight/2
            self._fragmentList[i]:setPosition(ccp(x01,y01))
            self:getRootWidget():addChild(self._fragmentList[i])
            --注册点击事件
            self:registerBtnClickEvent(self._fragmentList[i]:getButtonName(),function() 
                local fragmentId = self._fragmentIdList[i]
                --判断碎片数量
                --为0时 进入夺宝界面

                local fragment = G_Me.bagData.treasureFragmentList:getItemByKey(fragmentId)

                if fragment == nil or fragment["num"] ==0 then
                    uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.treasure.TreasureRobScene").new(fragmentId))
                else
                    local treasure = treasure_info.get(self._id)
                    require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_TREASURE_FRAGMENT, fragmentId)
                end 
            end )
        else
            --只需要刷新
            self._fragmentList[i]:loadTextureAndNum()
        end
    end
    -- self:_setFragmentButtonEvent()

    uf_funcCallHelper:callNextFrame(function ( ... )
        if animationFlag then
            GlobalFunc.flyFromWidget(self._fragmentList, self._itemImage, 0.4, 20, nil)
        end
    end)
    
    --抛出 是否播放合成按钮 呼吸消息
    --uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TREASURE_COMPOSE_BTN_ANIMATION, nil, false,self:checkFragmentEnough())

    if self:checkFragmentEnough() then
        self:playBgAnimation()
    else 
        self:stopBgAnimation()
    end
end


--上面的按钮点击事件
function TreasureComposeItem:_setFragmentButtonEvent()
    for i,v in ipairs(self._fragmentList) do
        self:registerBtnClickEvent(v:getButtonName(),function() 
            local fragmentId = self._fragmentIdList[i]
            --判断碎片数量
            --为0时 进入夺宝界面

            local fragment = G_Me.bagData.treasureFragmentList:getItemByKey(fragmentId)

            if fragment == nil or fragment["num"] ==0 then
                uf_sceneManager:pushScene(require("app.scenes.treasure.TreasureRobScene").new(fragmentId))
            else
                local treasure = treasure_info.get(self._id)
                require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_TREASURE_FRAGMENT, fragmentId)
            end 
        end )
    end 
end 

function TreasureComposeItem:playFragmentEffect(fragmentId)
    if fragmentId == nil or type(fragmentId) ~= "number" then
         return
     end
     -- self:updatePage()
     for i,v  in ipairs(self._fragmentList) do
         if v:getFragmentId() == fragmentId then
             local EffectNode = require "app.common.effects.EffectNode"
             self.effectNode = EffectNode.new("effect_prepare_compose", function(event, frameIndex)
                if event == "finish" then
                    self.effectNode:removeFromParentAndCleanup(true)
                    self.effectNode = nil
                end
                     end)      
             self.effectNode:play()
             local pt = self.effectNode:getPositionInCCPoint()
             local size = v:getContentSize()
             self.effectNode:setPosition(ccp(pt.x+size.width/2, pt.y+size.height/2))
             v:addNode(self.effectNode)
             v:playNumChangeAnimation()
         end
    end
end


function TreasureComposeItem:playFragmentLightAnimation(callback)
    self._composeCallback = callback
    if self._fragmentList == nil then
        return
    end

    local actions = {}
    local delayAction =  CCDelayTime:create(0.2)
    self._fragmentEffectList = {}
    for i=1,#self._fragmentList do 
        local action = CCCallFunc:create(function() 
            local effect = EffectNode.new("effect_prepare_compose")
            table.insert(self._fragmentEffectList,effect)
            effect:play()
            local pt = effect:getPositionInCCPoint()
            local size = self._fragmentList[i]:getContentSize()
            effect:setPosition(ccp(pt.x+size.width/2, pt.y+size.height/2))
            self._fragmentList[i]:addNode(effect)
         end)
        table.insert(actions, action)

        table.insert(actions, delayAction)
    end

    table.insert(actions, CCCallFunc:create(function() 
         --baoza       --
         -- self:playComposeAnimation(callback)
         self:playRoundAnimation()
         end))

    local sequence = transition.sequence(actions)
    self:getWidgetByName("ImageView_bg"):runAction(sequence)

end


--销毁
function TreasureComposeItem:clearAll()
    if self.timer ~= nil then
        GlobalFunc.removeTimer(self.timer)
        self.timer = nil
    end
    self:getWidgetByName("ImageView_bg"):stopAllActions()
    if self._fragmentEffectList ~= nil and #self._fragmentEffectList ~= 0 then
        for i,v in ipairs(self._fragmentEffectList) do
            v:removeFromParentAndCleanup(true)
        end
        self._fragmentEffectList = {}
    end
    if self.effectComposeNode ~= nil then
        self.effectComposeNode:removeFromParentAndCleanup(true)
        self.effectComposeNode = nil
    end
    if self.effectBgNode ~= nil then
        self.effectBgNode:removeFromParentAndCleanup(true)
        self.effectBgNode = nil
    end

    if self.effectNode ~= nil then
        self.effectNode:removeFromParentAndCleanup(true)
        self.effectNode = nil
    end
end


--合成时播放动画
function TreasureComposeItem:playComposeAnimation()
    local bg = self:getImageViewByName("ImageView_bg")
    self.effectComposeNode = EffectNode.new("effect_explode_light", function(event, frameIndex)
        if event == "finish" then
            self.effectComposeNode:removeFromParentAndCleanup(true)
            self.effectComposeNode = nil
            self:updatePage()
            if self._composeCallback ~= nil then
                self._composeCallback()
            end
        elseif event == "appear" then
            --播放声音特效
            G_SoundManager:playSound(require("app.const.SoundConst").GameSound.TREASURE_COMPOSE)
            if self._fragmentEffectList ~= nil and #self._fragmentEffectList ~= 0 then
                for i,v in ipairs(self._fragmentEffectList) do
                    v:removeFromParentAndCleanup(true)
                end
                self._fragmentEffectList = {}
            end
            
            --设置播放动画结束
        end
            end)      
    self.effectComposeNode:play()

    local pt = self.effectComposeNode:getPositionInCCPoint()
    local size = bg:getContentSize()
    self.effectComposeNode:setPosition(ccp(pt.x, pt.y))
    bg:addNode(self.effectComposeNode,100)
end

--背景呼吸动画
function TreasureComposeItem:playBgAnimation()
    local bg = self:getImageViewByName("ImageView_bg")
    self.effectBgNode = EffectNode.new("effect_compose_bg", function(event, frameIndex)
            
            end)      
    self.effectBgNode:play()
    local pt = self.effectBgNode:getPositionInCCPoint()
    local size = bg:getContentSize()
    self.effectBgNode:setPosition(ccp(pt.x, pt.y))
    bg:addNode(self.effectBgNode)
end

--停止背景呼吸动画
function TreasureComposeItem:stopBgAnimation()
    if self.effectBgNode ~= nil then
        self.effectBgNode:removeFromParentAndCleanup(true)
        self.effectBgNode = nil
    end
end

--[[
    x' = xcosa + y sina
    y' = ycosa - x sina

    y = sin(Pi*x/d)
]]
--圆心永远在顺时针方向
function TreasureComposeItem:playRoundAnimation()
    --需要时间
    self._time = 0.3
    self._frames = self._time*30
    --当前帧
    self._currentFrame = 1;

    self._isBack = false
    --起始点坐标    
    self._startPoints={}
    for i,v in ipairs(self._fragmentList) do
        v:showNumLabel(false)
        --k 斜率
        local __x,__y = v:getPosition()
        local width = v:getContentSize().width
        __x = __x + width/2
        __y = __y + width/2
        local k = (__y-y)/(__x-x)

        --坐标系旋转角度
        local angle = 0
        if __x < x then
            angle = math.atan(k)+math.pi
        elseif __x > x then
            angle = math.atan(k)
        else
            if __y > y then
                angle = math.pi*0.5
            else
                angle = math.pi*1.5
            end
        end
        local _t ={x = __x,y=__y,angle = angle}
        table.insert(self._startPoints,_t)
    end

    self._currentTime = 0
    self.timer = GlobalFunc.addTimer(1/30, handler(self,self.setRoundPositionByFrame))
end


--[[
    x' = xcosa + y sina
    y' = ycosa - x sina

    y = sin(Pi*x/d)
]]
function TreasureComposeItem:setRoundPositionByFrame()
    if self._currentFrame == self._frames then
        self._currentFrame = 1   --设置为默认
        --回来路径
        self._isBack = true
        --先把所有的隐藏掉
        if self.timer ~= nil then
            GlobalFunc.removeTimer(self.timer)
            self.timer = nil
        end
        if self._fragmentList == nil or #self._fragmentList == 0 then
            return
        end
        for i,v in ipairs(self._fragmentList) do
            v:setVisible(false)
        end
        self:playComposeAnimation()
        return
    elseif self._currentFrame == 0 then
        --game over
        if self.timer ~= nil then
            GlobalFunc.removeTimer(self.timer)
            self.timer = nil
        end
        return
    end
    --每帧移动的x像素，未进行坐标转换之前的
    if self._fragmentList == nil or #self._fragmentList == 0 then
        return
    end
    for i,v in ipairs(self._fragmentList) do
        local _t = self._startPoints[i]
        local distance = math.pow((_t.y-y)*(_t.y-y)+(_t.x-x)*(_t.x-x),1/2)
        local _diff = math.abs(distance/self._frames)
        local width = v:getContentSize().width
        local currentX = distance - self._currentFrame*_diff
        local currentY = 50*math.sin(math.pi/distance*(currentX))

        local width = v:getContentSize().width
        local __currentX = 0
        local __currentY = 0
        __currentX = currentX*math.cos(_t.angle)+currentY*math.sin(_t.angle)+x-width/2
        __currentY = -currentY*math.cos(_t.angle)+currentX*math.sin(_t.angle)+y-width/2
        v:setPosition(ccp(__currentX,__currentY))
    end
    if self._isBack == true then
        self._currentFrame = self._currentFrame - 1
    else
        self._currentFrame = self._currentFrame + 1
    end
end


--[[
    引导时检查碎片,首先,必须是3个碎片合成的宝物,并且只有2种类碎片
]]
function TreasureComposeItem:checkFragmentForGuide()
    if self._fragmentIdList == nil or #self._fragmentIdList ~= 3 then
        return false
    end
    local currentNum =  0
    for i,v in ipairs(self._fragmentIdList) do
        local fragment = G_Me.bagData.treasureFragmentList:getItemByKey(v)
        if fragment ~= nil and fragment["num"] ~=0 then
            currentNum = currentNum + 1
        end
    end
    __Log("拥有碎片种类:%s",currentNum)
    if currentNum == 2 then
        return true
    else
        return false
    end
end

--长度必须为3,刚好是第3个
function TreasureComposeItem:getFragmentIconRectForGuide()
    if not self:checkFragmentForGuide() then
        return CCRectMake(0,0,0,0)
    end
    if self._fragmentList == nil or #self._fragmentList ~= 3 then
        return CCRectMake(0,0,0,0)
    end
    for i,v in ipairs(self._fragmentList) do
        local id = v:getFragmentId()
        local fragment = G_Me.bagData.treasureFragmentList:getItemByKey(id)
        if v and self.convertToWorldSpaceXY then
            if fragment == nil or fragment["num"] == 0 then
                local x,y = self:convertToWorldSpaceXY(v:getPosition())
                local width = v:getContentSize().width
                local height = v:getContentSize().height
                __Log(" 新手引导x = %s,y=%s,width=%s,height = %s",x,y,width,height)
                return CCRectMake(x,y,width,height)
            end 
        end 
    end
    return CCRectMake(0,0,0,0)
end

return TreasureComposeItem

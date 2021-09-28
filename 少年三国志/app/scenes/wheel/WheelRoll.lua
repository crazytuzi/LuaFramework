
local WheelRoll = class("WheelRoll", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local EffectNode = require "app.common.effects.EffectNode"
require("app.cfg.wheel_info")

function WheelRoll:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    -- self:setClickClose(true)
    self._id = 1
    self._baseY = 400-275-54
    self._baseScale = 1.2
    self._yMove = 90
    self._itemList ={}
    self._end = false

    self:getImageViewByName("Image_jixu"):setVisible(false)
    self:initWheel()
    self:adaptLayer()
    self:regisgerWidgetTouchEvent("Panel_click", function ( widget, param )
        if param == TOUCH_EVENT_ENDED then -- 点击事件
            if self._end then
                G_topLayer:resumeStatus()
                if self._callback then
                    self._callback()
                end
                self:close()
            end
        end
    end)
end

function WheelRoll.create(id,award,money,callback,...)
    local layer = WheelRoll.new("ui_layout/wheel_WheelRoll.json",require("app.setting.Colors").modelColor,...) 
    layer:setId(id,award,money,callback)
    return layer
end

function WheelRoll:setId(id,award,money,callback)
    self._id = id
    self._award = award
    self._money = money
    self._callback = callback
    self:updateWheel()
end

function WheelRoll:onLayerEnter()
    -- self:closeAtReturn(true)
    -- EffectSingleMoving.run(self:getImageViewByName("Image_jixu"), "smoving_wait", nil , {position = true} )
    G_topLayer:hideTemplate()
    self:wheelMove(function ( )
        self:roll(self._award[#self._award])
        for i =1,10 do
            self:awardAppear(i)
        end
    end)
end

function WheelRoll:adaptLayer()
    local height = display.height
    self:getPanelByName("Panel_bigWheel"):setPosition(ccp(0,self._baseY))
end

function WheelRoll:wheelMove(func)
    local scale = self._baseScale
    local time = 0.25
    local move = CCMoveBy:create(time,ccp(-(640*(scale-1)/2),self._yMove))
    local scaleTo = CCScaleBy:create(time,scale)
    local action = CCSpawn:createWithTwoActions(move, scaleTo)
    local action2 = CCSequence:createWithTwoActions(action,CCCallFunc:create(function()
                    if func then
                        func()
                    end
          end)) 
    self:getPanelByName("Panel_bigWheel"):runAction(action2)
end

function WheelRoll:roll(dst)
    local info = wheel_info.get(self._id)
    local index = 5
    if dst ~= 8 then
        index = info["position_"..dst]
    end
    local time = 3.0
    local rand = math.random(-15,15)
    __Log("roll to "..index-1)
    local rot = 2160+(9-index)*45+rand

    self._rollEffect = EffectNode.new("effect_lp_light")     
    self._rollEffect:setPosition(ccp(214,211))
    self._rollEffect:play()
    self:getPanelByName("Panel_stop"):addNode(self._rollEffect,10)

    local rollAction = CCEaseExponentialOut:create(CCRotateTo:create(time,rot))
    self._wheelImg:runAction(CCSequence:createWithTwoActions(rollAction,CCCallFunc:create(function()
        self._rollEffect:stop()
        self._rollEffect:removeFromParentAndCleanup(true)
        self:setClickClose(true)
        self._end = true
        self:getImageViewByName("Image_jixu"):setVisible(true)
        EffectSingleMoving.run(self:getImageViewByName("Image_jixu"), "smoving_wait", nil , {position = true} )
    end)))

    for i = 1 , 8 do 
        local rollAction2 = CCEaseExponentialOut:create(CCRotateTo:create(time,-rot))
        self._wheelItemList[i]:runAction(rollAction2)
    end
end

function WheelRoll:awardAppear(index)
    local time = 0.5
    local delayTime = (index-1)*0.3
    local info = wheel_info.get(self._id)
    local awardIndex = self._award[index]
    local item = nil
    if awardIndex == 8 then
        item = GlobalFunc.createIcon({type=G_Goods.TYPE_GOLD,value=0,size=self._money[index],click=false,name=false})
    else
        item = GlobalFunc.createIcon({type=info["type_"..awardIndex],value=info["value_"..awardIndex],size=info["size_"..awardIndex],click=false,name=false,numType=3})
    end
    -- table.insert(self._itemList,#self._itemList+1,item)
    self._itemList[index] = item
    local startpos = ccp(320-48*self._baseScale*0.8,461*self._baseScale+self._baseY+self._yMove-(155-96)/2*self._baseScale*0.8)
    local endpos = ccp(16+((index-1)%5)*128,0-math.floor((index-1)/5)*110+self._baseY+30)
    item:setPosition(startpos)
    item:setVisible(false)
    item:setScale(0.8*self._baseScale)
    local move = CCMoveTo:create(time,endpos)
    local scale = CCScaleTo:create(time,1)
    self:getPanelByName("Panel_base"):addChild(item)
    local delayAction = CCDelayTime:create(delayTime)
    local arr = CCArray:create()
    arr:addObject(delayAction)
    arr:addObject(CCCallFunc:create(function()
        self._itemList[index]:setVisible(true)
        self._itemList[index]:getImageViewByName("Image_board"):runAction(CCRotateTo:create(time,3600))
    end))
    arr:addObject(CCSpawn:createWithTwoActions(move,scale))

    arr:addObject(CCCallFunc:create(function()
        local effect = EffectNode.new("effect_lp_jl", 
                function(event, frameIndex)
                    if event == "finish" then
                        -- effect:stop()
                        -- effect:removeFromParentAndCleanup(true)
                        if awardIndex == 8 or info["if_effect_"..awardIndex] == 1 then
                            local node = EffectNode.new("effect_around1")     
                            node:setScale(1.7) 
                            node:setPosition(ccp(5,-5))
                            node:play()
                            self._itemList[index]:getImageViewByName("Image_board"):addNode(node,10)
                        end
                    end
                end)
        effect:setPosition(ccp(62,96))
        effect:play()
        self._itemList[index]:addNode(effect)
    end))
    item:runAction(CCSequence:create(arr))
end

function WheelRoll:initWheel()
    local wheel = CCSItemCellBase:create("ui_layout/wheel_MyWheel.json")
    self:getPanelByName("Panel_bigWheel"):addChild(wheel)
    self._wheelImg = wheel:getImageViewByName("Image_wheel")
    self._wheelPanel = wheel:getPanelByName("Panel_wheel")
    self._wheelStop = wheel:getPanelByName("Panel_stop")
    wheel:getPanelByName("Panel_buttom"):setVisible(false)
    self._gold = wheel:getLabelByName("Label_gold")
    self._gold:createStroke(Colors.strokeBrown, 1)
    wheel:getLabelByName("Label_goldTit"):createStroke(Colors.strokeBrown, 1)
    self._wheelItemList = {}
    for i = 1, 8 do 
        self._wheelItemList[i] = self:getImageViewByName("Image_item"..i)
    end
    self._wheel = wheel
end

function WheelRoll:updateWheel()
    local wheel = self._wheel
    local info = wheel_info.get(self._id)
    if self._id == 1 then
        self:getImageViewByName("Image_wheel"):loadTexture("ui/wheel/lunpan_putong.png")
        self:getImageViewByName("Image_middi"):loadTexture("ui/wheel/middle_lan.png")
        self:getImageViewByName("Image_arrow"):loadTexture("ui/wheel/zhizhen_putong.png")
        self:getButtonByName("Button_mid"):loadTextureNormal("ui/wheel/middle_putong.png")
        self:getImageViewByName("Image_item5"):loadTexture("ui/wheel/icon_bg_haohua.png")
    else
        self:getImageViewByName("Image_wheel"):loadTexture("ui/wheel/lunpan_haohua.png")
        self:getImageViewByName("Image_middi"):loadTexture("ui/wheel/middle_hong.png")
        self:getImageViewByName("Image_arrow"):loadTexture("ui/wheel/zhizhen_haohua.png")
        self:getButtonByName("Button_mid"):loadTextureNormal("ui/wheel/middle_haohua.png")
        self:getImageViewByName("Image_item5"):loadTexture("ui/wheel/icon_bg_haohua.png")
    end

    for i = 1, 7 do 
        local g = G_Goods.convert(info["type_"..i], info["value_"..i])
        local index = info["position_"..i]
        wheel:getImageViewByName("Image_icon"..index):loadTexture(g.icon)
        wheel:getImageViewByName("Image_ball"..index):loadTexture(G_Path.getEquipIconBack(g.quality))
        wheel:getLabelByName("Label_num"..index):setText("x"..GlobalFunc.ConvertNumToCharacter3(info["size_"..i]))
        wheel:getLabelByName("Label_num"..index):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_num"..index):setScale(1/0.8)
        wheel:getButtonByName("Button_border"..index):loadTextureNormal(G_Path.getEquipColorImage(g.quality))
    end

    self._gold:setText(self._id == 1 and G_Me.wheelData.pool or G_Me.wheelData.pool2)
    
    wheel:getLabelByName("Label_pool"):createStroke(Colors.strokeBrown, 1)
    local g = G_Goods.convert(G_Goods.TYPE_GOLD, 0)
    wheel:getImageViewByName("Image_icon"..5):loadTexture(g.icon)
    wheel:getImageViewByName("Image_ball"..5):loadTexture(G_Path.getEquipIconBack(g.quality))
    wheel:getLabelByName("Label_num"..5):setText("x".."50%")
    wheel:getLabelByName("Label_num"..5):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_num"..5):setScale(1/0.8)
    wheel:getButtonByName("Button_border"..5):loadTextureNormal(G_Path.getEquipColorImage(g.quality))
end

function WheelRoll:onClickClose( ... )
    -- local top = require("app.scenes.wheel.WheelAwardTen").create(self._id,self._award,self._money)
    -- uf_sceneManager:getCurScene():addChild(top)
    G_topLayer:resumeStatus()
    if self._callback then
        self._callback()
    end
    self:close()
    return true
end

return WheelRoll


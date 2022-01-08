
local EatPigLayer = class("EatPigLayer", BaseLayer)

function EatPigLayer:ctor()
    self.super.ctor(self)
    self:init("lua.uiconfig_mango_new.qiyu.EatPigLayer")
    -- QiyuManager:SengQueryEatPigMsg()
end

function EatPigLayer:onShow()
    print("EatPigLayer onShow")
    self.super.onShow(self)
      
    self:RefreshBtn()

end

function EatPigLayer:initUI(ui)
    self.super.initUI(self,ui)
    self.eatBtn1 = TFDirector:getChildByPath(ui, 'eatBtn1')
    self.eatBtn1.panelEffect = TFDirector:getChildByPath(self.eatBtn1, 'panel_effect')
    self.eatBtn1:setVisible(false)
    self.eatTip1 = TFDirector:getChildByPath(ui, 'eatTip1')

    self.eatBtn2 = TFDirector:getChildByPath(ui, 'eatBtn2')
    self.eatBtn2.panelEffect = TFDirector:getChildByPath(self.eatBtn2, 'panel_effect')
    self.eatBtn2:setVisible(false)
    self.eatTip2 = TFDirector:getChildByPath(ui, 'eatTip2')
    self.eatBtn2:setVisible(false)

    self.eatBtn3 = TFDirector:getChildByPath(ui, 'eatBtn3')
    self.eatBtn3.panelEffect = TFDirector:getChildByPath(self.eatBtn3, 'panel_effect')
    self.eatBtn3:setVisible(false)

    self.pigImg = TFDirector:getChildByPath(ui, "pigImg")
end

function EatPigLayer:registerEvents(ui)
    self.super.registerEvents(self)
    self.eatBtn1:addMEListener(TFWIDGET_CLICK, audioClickfun(self.eatBtnClickHandle),1)
    self.eatBtn2:addMEListener(TFWIDGET_CLICK, audioClickfun(self.eatBtnClickHandle),1)
    self.eatBtn3:addMEListener(TFWIDGET_CLICK, audioClickfun(self.eatBtnClickHandle),1)
    self.eatBtn1.logic = self
    self.eatBtn2.logic = self
    self.eatBtn3.logic = self
    TFDirector:addMEGlobalListener("eatPigInfo", function() self:RefreshBtn() end)
    
    if not self.nTimerId then
        self.nTimerId = TFDirector:addTimer(1000, -1, nil, function(event)
            -- print("eat pig")
            self:RefreshBtn()
        end) 
    end

end

function EatPigLayer:removeEvents()
    TFDirector:removeMEGlobalListener("eatPigInfo")
    if self.nTimerId then
        TFDirector:removeTimer(self.nTimerId)
        self.nTimerId = nil
    end
    self.super.removeEvents(self)
end

function EatPigLayer:RefreshBtn()
    self.eatBtn1:setVisible(true)
    self.eatBtn2:setVisible(true)
    self.eatBtn3:setVisible(true)

    if self.effect then
        self.effect:removeFromParent()
        self.effect = nil
    end

    --disable all buttons
    self.eatBtn1:setGrayEnabled(true)
    self.eatBtn1:setTouchEnabled(false)
    self.eatBtn2:setGrayEnabled(true)
    self.eatBtn2:setTouchEnabled(false)
    self.eatBtn3:setGrayEnabled(true)
    self.eatBtn3:setTouchEnabled(false)

    local enabledDiet = DietData:getCurrentDiet()
    if enabledDiet then
        -- print("QiyuManager.lastDietTime : ",QiyuManager.lastDietTime)
        local status = enabledDiet:getStatus(QiyuManager.lastDietTime, MainPlayer:getNowtime())
        if enabledDiet.id == 1 and status == 2 then
            self.eatBtn1:setGrayEnabled(false)
            self.eatBtn1:setTouchEnabled(true)
            self:addeffect("btn_common",self.eatBtn1)
        elseif enabledDiet.id == 2 and status == 2 then
            self.eatBtn2:setGrayEnabled(false)
            self.eatBtn2:setTouchEnabled(true)
            self:addeffect("btn_common",self.eatBtn2)
        elseif enabledDiet.id == 3 and status == 2 then
            self.eatBtn3:setGrayEnabled(false)
            self.eatBtn3:setTouchEnabled(true)
            self:addeffect("btn_common",self.eatBtn3)
        end

        if status ~= 2 then
            self:stopPigEffect()
        end
    end

    -- local tipImg = {"ui_new/qiyu/sjwd.png", "ui_new/qiyu/kyyc.png", "ui_new/qiyu/yyc.png", "ui_new/qiyu/sjgl.png"}
    -- self.eatTip1:setTexture(tipImg[DietData:objectByID(1):getStatus(QiyuManager.lastDietTime)])
    -- self.eatTip2:setTexture(tipImg[DietData:objectByID(2):getStatus(QiyuManager.lastDietTime)])

    if self.logic then
        self.logic:redraw()
    end   
end

function EatPigLayer:addeffect(effectName, btn)
    if self.effect == nil then
        ModelManager:addResourceFromFile(2, effectName, 1)
        local effect = ModelManager:createResource(2, effectName)
        effect:setAnimationFps(GameConfig.ANIM_FPS)
        ModelManager:playWithNameAndIndex(effect, "", 0, 1, -1, -1)
        btn:addChild(effect , 100)
        self.effect = effect
    end

    self:addPigEffect(btn)
end

function EatPigLayer:addPigEffect(btn)
    if self.pig_effect == nil then
        local eftID = "pantaoeft"
        ModelManager:addResourceFromFile(2, eftID, 1)
        local effect = ModelManager:createResource(2, eftID)
        effect:setPosition(ccp(btn.panelEffect:getSize().width / 2 + 2, btn.panelEffect:getSize().height / 2))
        ModelManager:playWithNameAndIndex(effect, "", 0, 1, -1, -1)
        btn.panelEffect:addChild(effect)
        print("addPigEffect---------------------->")
        self.pig_effect = effect
    end
end

function EatPigLayer:stopPigEffect()
    if self.pig_effect then
        print("stopPigEffect----------------->")
        self.pig_effect:removeFromParent()
        self.pig_effect = nil
    end
end

function EatPigLayer.eatBtnClickHandle(sender)
    TFDirector:send(c2s.DINING_REQUEST, {})
    sender:setGrayEnabled(true)
    sender:setTouchEnabled(false)
    local self = sender.logic
    if self.effect then
        self.effect:removeFromParent()
        self.effect = nil
    end

    self:stopPigEffect()
end

return EatPigLayer
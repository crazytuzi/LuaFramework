require("app.cfg.activity_drink_info")

local EffectNode = require "app.common.effects.EffectNode"
local ActivityPageWine = class("ActivityPageWine", UFCCSNormalLayer )

function ActivityPageWine.create(...)
    return ActivityPageWine.new("ui_layout/activity_ActivityWine.json")
end


function ActivityPageWine:onLayerEnter()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_DATA_WINE_UPDATED, self._onWineUpdated, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_FINISH_WINE, self._onWineFinish, self) 

  
    -- self._timer = GlobalFunc.addTimer(1, function() 
        
    --     self:_updateButtion()
    -- end)

end


function ActivityPageWine:onLayerExit()
   uf_eventManager:removeListenerWithTarget(self)
   -- if self._timer then
   --     GlobalFunc.removeTimer(self._timer )
   --     self._timer =nil

   -- end
end


function ActivityPageWine:ctor(...)
    self.super.ctor(self, ...)

    local record1 = activity_drink_info.get(1)
    local record2 = activity_drink_info.get(2)
  
    self:getLabelByName("Label_time1"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_time2"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_reward_desc"):createStroke(Colors.strokeBrown,1)

    self:getLabelByName("Label_time1"):setText(record1.desc)
    self:getLabelByName( "Label_time2"):setText(record2.desc)
    self:getLabelByName( "Label_reward_desc"):setText(G_lang:get("LANG_ACTIVITY_WINE_REWARD_DESC"))



    self:registerBtnClickEvent("Button_wine",function()
        if G_Me.activityData.wine:isActivate() then
            self:_startDrink()
        end

    end)

    -- if IS_HEXIE_VERSION then       
    --     local bgImg = self:getImageViewByName("Image_20")
    --     if bgImg then 
    --         bgImg:loadTexture("ui/activity/qingmeizhujiu_mm_hexie.png")
    --     end
    -- end
    local bgImage = self:getImageViewByName("Image_1")
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        --添加特效
        self._bgEffect01 = EffectNode.new("effect_tqt", function(event, frameIndex)
                    end)  
        self._bgEffect01:setPosition(ccp(0,0))
        bgImage:addNode(self._bgEffect01)
        self._bgEffect01:play()
    end

    -- local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
    -- EffectSingleMoving.run(self:getImageViewByName("Image_caicai"), "smoving_idle", nil, {})

    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    if appstoreVersion or IS_HEXIE_VERSION then    
        local panel = self:getPanelByName("Panel_caiwenji")
        if panel then 
            local bgImg = ImageView:create()
            bgImg:loadTexture("ui/arena/xiaozhushou_hexie.png")
            panel:addChild(bgImg) 
            local panelSize = panel:getSize()
            bgImg:setPositionXY(panelSize.width/2, panelSize.height/2)
        end  
    else
        self._caiwenjiEffect = EffectNode.new("effect_caiwenji", function(event, frameIndex)
                end) 
        self._caiwenjiEffect:play()
        self._caiwenjiEffect:setPosition(ccp(0,0))
        -- self:getPanelByName("Panel_caiwenji"):addNode(self._caiwenjiEffect) 
        bgImage:addNode(self._caiwenjiEffect) 
    end

end

function ActivityPageWine:adapterLayer()
    
end

function ActivityPageWine:_addDeskEffect()
    if self._bgEffect02 == nil then
        local deskImage = self:getImageViewByName("Image_zhuozi")
        self._bgEffect02 = EffectNode.new("effect_wine", function(event, frameIndex)
                    end)  
        self._bgEffect02:setPosition(ccp(0,0))
        deskImage:addNode(self._bgEffect02)
        self._bgEffect02:play()
    end
end

function ActivityPageWine:_removeDeskEffect()
    if self._bgEffect02 ~= nil then
        self._bgEffect02:removeFromParentAndCleanup(true)
        self._bgEffect02 = nil
    end
end

function ActivityPageWine:_onWineFinish(data)   
    self:updatePage()

    if rawget(data, "gold") and data.gold > 0 then
        local node = require("app.scenes.activity.ActivityWineGold").create()
        node:setGold(data.gold)

        uf_sceneManager:getCurScene():addChild(node)    
    else
        G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_WINE_OK"), {    movingStyle = "moving_texttip4_slow"})
    end

end


function ActivityPageWine:_onWineUpdated(data)   
    self:updatePage()



end

function ActivityPageWine:_updateButtion()   


    -- if self._activated == nil or self._activated ~= G_Me.activityData.wine:isActivate() then
    --      if G_Me.activityData.wine:isActivate() then
    --         self:getButtonByName("Button_wine"):loadTextureNormal("btn-middle-red.png", UI_TEX_TYPE_PLIST)
    --     else
    --         self:getButtonByName("Button_wine"):loadTextureNormal("btn-middle-unable.png", UI_TEX_TYPE_PLIST)
    --     end

    --     self._activated =  G_Me.activityData.wine:isActivate() 
    -- end


     if G_Me.activityData.wine:isActivate() then
        self:getButtonByName("Button_wine"):setVisible(true)
        -- self:getButtonByName("Button_wine"):loadTextureNormal("btn-middle-red.png", UI_TEX_TYPE_PLIST)
    else
        self:getButtonByName("Button_wine"):setVisible(false)

        -- self:getButtonByName("Button_wine"):loadTextureNormal("btn-middle-unable.png", UI_TEX_TYPE_PLIST)
    end
end



function ActivityPageWine:_startDrink()   
    G_HandlersManager.activityHandler:sendDrink()   
end

function ActivityPageWine:showPage()   
    --进界面的时候强刷一次数据
    G_HandlersManager.activityHandler:sendLiquorInfo()
end


function ActivityPageWine:updatePage()
    local state = G_Me.activityData.wine.state


    if state == 2 or state ==3 then
        self:getLabelByName("Label_time1"):setColor(Colors.darkColors.TIPS_01)
        self:getLabelByName("Label_time2"):setColor(Colors.darkColors.DESCRIPTION)
    elseif state == 5 or state == 6 then
        self:getLabelByName("Label_time1"):setColor(Colors.darkColors.DESCRIPTION)
        self:getLabelByName("Label_time2"):setColor(Colors.darkColors.TIPS_01)
    else
        self:getLabelByName("Label_time1"):setColor(Colors.darkColors.DESCRIPTION)
        self:getLabelByName("Label_time2"):setColor(Colors.darkColors.DESCRIPTION)
    end
    local record1 = activity_drink_info.get(1)
    local record2 = activity_drink_info.get(2)

    self:getLabelByName("Label_time1"):setText(record1.desc, true)
    self:getLabelByName( "Label_time2"):setText(record2.desc, true )

    if state >0 and state <=7 then
        self:getLabelByName("Label_desc"):setText(G_lang:get("LANG_ACTIVITY_WINE_" .. state))
    end

    --添加桌子特效
    if G_Me.activityData.wine:isActivate() then
        self:_addDeskEffect()
    else
        self:_removeDeskEffect()
    end
    
    self:_updateButtion()

end


return ActivityPageWine

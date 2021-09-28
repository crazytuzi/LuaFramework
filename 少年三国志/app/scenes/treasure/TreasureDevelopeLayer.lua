local funLevelConst = require("app.const.FunctionLevelConst")
local TreasureDevelopeLayer = class("TreasureDevelopeLayer",UFCCSNormalLayer)
local BagConst = require("app.const.BagConst")
local EffectNode = require("app.common.effects.EffectNode")
local EquipmentConst = require("app.const.EquipmentConst")

function TreasureDevelopeLayer.create(...)
    return require("app.scenes.treasure.TreasureDevelopeLayer").new("ui_layout/treasure_TreasureDevelopeLayer.json", ...)
end

function TreasureDevelopeLayer:ctor(...)
    self._defaultDevelpeType = "CheckBox_strength"
    self._equipment = nil
    self._treasureStrength = nil
    self._treasureRefine = nil
    self._treasureForge = nil
    self.super.ctor(self, ...)
    self._tabs = require("app.common.tools.Tabs").new(2, self,self._checkedCallBack, self._uncheckedCallBack) 
    self._bg = self:getImageViewByName("ImageView_bg_0")
    self._di = self:getImageViewByName("Image_di")

    self:registerBtnClickEvent("Button_return", function()
        self:onBackKeyEvent()
    end)
end

function TreasureDevelopeLayer:onBackKeyEvent(...)
    if CCDirector:sharedDirector():getSceneCount() > 1 then 
                uf_sceneManager:popScene()
    else
        uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureMainScene").new())
    end

    return true
end

function TreasureDevelopeLayer:setEquipment(equipment, developeType)
    self._equipment = equipment
    
    if developeType ~= nil then
        if developeType == EquipmentConst.RefineMode then
            self._defaultDevelpeType = "CheckBox_refine"
        elseif developeType == EquipmentConst.ForgeMode then
            self._defaultDevelpeType = "CheckBox_Forge"
        end
    end

    -- 如果到了可预览铸造的等级，显示铸造页签
    local canPreviewForge = G_moduleUnlock:canPreviewModule(funLevelConst.TREASURE_FORGE)
    self:showWidgetByName("CheckBox_Forge", canPreviewForge)

    -- 经验宝物和非橙色宝物不可铸造，页签置灰
    if canPreviewForge then
        local treasureInfo = self._equipment:getInfo()
        local canForge = treasureInfo.type ~= 3 and treasureInfo.quality == BagConst.QUALITY_TYPE.ORANGE
        local isUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_FORGE)
        self:getWidgetByName("CheckBox_Forge"):setTouchEnabled(isUnlock and canForge)
    end
end

function TreasureDevelopeLayer:_initTabs()
    self:_updateCheckBtns()
    self._tabs:add("CheckBox_strength", "", "Label_strength") --delay load
    self._tabs:add("CheckBox_refine", "", "Label_refine")  -- delay load
    self._tabs:add("CheckBox_Forge", "", "Label_Forge")
    self._tabs:checked(self._defaultDevelpeType)
end


function TreasureDevelopeLayer:_checkedCallBack(btnName)
    if btnName == "CheckBox_strength" then
        self:_resetStrengthView()
    elseif btnName == "CheckBox_refine" then
        self:_resetRefineView()
    elseif btnName == "CheckBox_Forge" then
        self:_resetForgeView()
    end
end

function TreasureDevelopeLayer:_uncheckedCallBack(btnName)
    if btnName == "CheckBox_strength" then
        if  self._treasureStrength ~= nil  then
           self._treasureStrength:onUncheck()
        end
        
    elseif btnName == "CheckBox_refine" then
        if  self._treasureRefine ~= nil then
           self._treasureRefine:onUncheck()
        end

    elseif btnName == "CheckBox_Forge" then
        if self._treasureForge ~= nil then
            self._treasureForge:onUncheck()
        end
    end
end



--当玩家点击了强化tab时
function TreasureDevelopeLayer:_resetStrengthView()

    self._bg:loadTexture("ui/background/bg_yangcheng.png")
    self._di:setVisible(false)
    if self._huoyan1 ~= nil then 
        self._huoyan1:setVisible(false)
    end
    if self._huoyan2 ~= nil then 
        self._huoyan2:setVisible(false)
    end
    if self._huoyan3 ~= nil then 
        self._huoyan3:setVisible(false)
    end
    if self._treasureStrength == nil then
        self._treasureStrength = require("app.scenes.treasure.develope.TreasureStrengthLayer").create()
        self:getPanelByName("Panel_content"):addNode(self._treasureStrength)
        self._tabs:updateTab("CheckBox_strength", self._treasureStrength)
        local size = self:getPanelByName("Panel_content"):getContentSize()
        self._treasureStrength:adapterWithSize(CCSizeMake(size.width, size.height))
    end
    self._treasureStrength:setEquipment(self._equipment)

    self:getImageViewByName("Image_luzi1"):setVisible(false)
    self:getImageViewByName("Image_luzi2"):setVisible(false)
    if self._luziup then 
        self._luziup:stop()
        self._luziup:removeFromParentAndCleanup(true)
        self._luziup = nil    
    end
    if self._luzidown then 
        self._luzidown:stop()
        self._luzidown:removeFromParentAndCleanup(true)
        self._luzidown = nil    
    end
    
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        if not self._strEffect then
            self._strEffect  = EffectNode.new("effect_jinjiechangjing")
            self._strEffect:play()

            if self._bg then 
                self._bg:addNode(self._strEffect)
            end
        end
    end

    G_flyAttribute._clearFlyAttributes()
    if self._treasureStrength then
        self._treasureStrength:updateView()
    end

end



--当玩家点击了精炼tab时
function TreasureDevelopeLayer:_resetRefineView()
    self._bg:loadTexture("ui/background/zhuangbeifenjie_bg1.png")
    self._di:setVisible(true)
    if self._huoyan1 ~= nil then 
        self._huoyan1:setVisible(true)
    end
    if self._huoyan2 ~= nil then 
        self._huoyan2:setVisible(true)
    end
    if self._huoyan3 ~= nil then 
        self._huoyan3:setVisible(true)
    end
    if self._treasureRefine == nil then
        self._treasureRefine = require("app.scenes.treasure.develope.TreasureRefineLayer").create()
        self:getPanelByName("Panel_content"):addNode(self._treasureRefine)
        self._tabs:updateTab("CheckBox_refine",  self._treasureRefine)

        local size = self:getPanelByName("Panel_content"):getContentSize()
        self._treasureRefine:adapterWithSize(CCSizeMake(size.width, size.height))
    end
    self._treasureRefine:setEquipment(self._equipment)
    

    local luzi = self:getImageViewByName("Image_luzi1")
    luzi:setVisible(false)
    self:getImageViewByName("Image_luzi2"):setVisible(false)

    if self._luziup == nil then 
        self._luziup = EffectNode.new("effect_luzi_up", 
            function(event, frameIndex)

            end
        )
        self._luziup:setPosition(ccp(0,-10))
        self:getPanelByName("Panel_effect_up"):addNode(self._luziup)
        self._luziup:play()
    end

    if self._luzidown == nil then 
        self._luzidown = EffectNode.new("effect_luzi_down", 
            function(event, frameIndex)

            end
        )
        self._luzidown:setPosition(ccp(0,-10))
        self:getPanelByName("Panel_effect_down"):addNode(self._luzidown)
        self._luzidown:play()
    end

    if self._strEffect then 
        self._strEffect:stop()
        self._strEffect:removeFromParentAndCleanup(true)
        self._strEffect = nil    
    end

    G_flyAttribute._clearFlyAttributes()
    if self._treasureRefine then 
        self._treasureRefine:updateView()
    end
    if self._treasureStrength then 
        self._treasureStrength:_dataClear()
    end
    
end

function TreasureDevelopeLayer:_resetForgeView()
    self._bg:loadTexture("ui/background/bg_yangcheng.png")
    self._di:setVisible(false)
    if self._huoyan1 ~= nil then 
        self._huoyan1:setVisible(false)
    end
    if self._huoyan2 ~= nil then 
        self._huoyan2:setVisible(false)
    end
    if self._huoyan3 ~= nil then 
        self._huoyan3:setVisible(false)
    end

    if self._treasureForge == nil then
        self._treasureForge = require("app.scenes.treasure.develope.TreasureForgeLayer").create(self)
        self:getPanelByName("Panel_content"):addNode(self._treasureForge)
        self._tabs:updateTab("CheckBox_Forge", self._treasureForge)
        local size = self:getPanelByName("Panel_content"):getContentSize()
        self._treasureForge:adapterWithSize(CCSizeMake(size.width, size.height))
    end

    -- 这放到外面来，以防在强化或精炼后，铸造界面不刷新属性
    self._treasureForge:setCurTreasure(self._equipment)

    self:getImageViewByName("Image_luzi1"):setVisible(false)
    self:getImageViewByName("Image_luzi2"):setVisible(false)
    if self._luziup then 
        self._luziup:stop()
        self._luziup:removeFromParentAndCleanup(true)
        self._luziup = nil    
    end
    if self._luzidown then 
        self._luzidown:stop()
        self._luzidown:removeFromParentAndCleanup(true)
        self._luzidown = nil    
    end

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        if not self._strEffect then
            self._strEffect  = EffectNode.new("effect_jinjiechangjing")
            self._strEffect:play()

            if self._bg then 
                self._bg:addNode(self._strEffect)
            end
        end
    end

    G_flyAttribute._clearFlyAttributes()
    if self._treasureStrength then 
        self._treasureStrength:_dataClear()
    end
end

function TreasureDevelopeLayer:adapterLayer()
    self:adapterWidgetHeight("Panel_content", "Panel_checkbox", "", 0, 0)

    self:_initTabs()
    self:_updateCheckBtns()
end

function TreasureDevelopeLayer:_updateCheckBtns()
    local StrUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_STRENGTH)
    local RefUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_TRAINING)

    self:getWidgetByName("CheckBox_strength"):setTouchEnabled(StrUnlock)
    self:getWidgetByName("CheckBox_refine"):setTouchEnabled(RefUnlock)

    -- self:enableWidgetByName("CheckBox_strength", StrUnlock)
    -- if not StrUnlock then
    --     self:getLabelByName("Label_strength"):setColor(Colors.TAB_GRAY)
    --     self:getLabelByName("Label_strength_0"):setColor(Colors.TAB_GRAY)
    -- end
    -- self:enableWidgetByName("CheckBox_refine", RefUnlock)
    -- if not RefUnlock then
    --     self:getLabelByName("Label_refine"):setColor(Colors.TAB_GRAY)
    --     self:getLabelByName("Label_refine_0"):setColor(Colors.TAB_GRAY)
    -- end
end

function TreasureDevelopeLayer:onLayerEnter()
    --代码添加宝物精炼红点
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._onBagDataChange, self)
    local refineTip = ImageView:create()
    refineTip:loadTexture("tips_numb.png",UI_TEX_TYPE_PLIST)
    refineTip:setName("Image_refine_tips")
    refineTip:setPositionXY(126,16)
    self:getWidgetByName("CheckBox_refine"):addChild(refineTip)
    self:showWidgetByName("Image_refine_tips",G_Me.bagData:checkTreasureRefine(self._equipment.id))
end

--包裹发送变化
function TreasureDevelopeLayer:_onBagDataChange()
    self:showWidgetByName("Image_refine_tips",G_Me.bagData:checkTreasureRefine(self._equipment.id))
end

function TreasureDevelopeLayer:onLayerLoad( )
    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
        if self._huoyan1 == nil then 
            self._huoyan1 = EffectNode.new("effect_zbyc", 
                function(event, frameIndex)

                end
            )
            self:getImageViewByName("ImageView_bg_0"):addNode(self._huoyan1)
            self._huoyan1:play()
        end
        if self._huoyan2 == nil then 
            self._huoyan2 = EffectNode.new("effect_fire", 
                function(event, frameIndex)

                end
            )
            self._huoyan2:setPosition(ccp(-196,220))
            self:getImageViewByName("ImageView_bg_0"):addNode(self._huoyan2)
            self._huoyan2:play()
        end
        if self._huoyan3 == nil then 
            self._huoyan3 = EffectNode.new("effect_fire", 
                function(event, frameIndex)

                end
            )
            self._huoyan3:setPosition(ccp(172,205))
            self:getImageViewByName("ImageView_bg_0"):addNode(self._huoyan3)
            self._huoyan3:play()
        end
    end
end

function TreasureDevelopeLayer:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)

    if self._huoyan1 ~= nil then 
        self._huoyan1:stop()
        self._huoyan1:removeFromParentAndCleanup(true)
        self._huoyan1 = nil
    end
    if self._huoyan2 ~= nil then 
        self._huoyan2:stop()
        self._huoyan2:removeFromParentAndCleanup(true)
        self._huoyan2 = nil
    end
    if self._huoyan3 ~= nil then 
        self._huoyan3:stop()
        self._huoyan3:removeFromParentAndCleanup(true)
        self._huoyan3 = nil
    end
    G_flyAttribute._clearFlyAttributes()
    self.super:onLayerUnload()
end



return TreasureDevelopeLayer

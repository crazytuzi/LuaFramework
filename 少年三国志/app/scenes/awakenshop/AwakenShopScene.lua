-- AwakenShopScene

local AwakenShopScene = class("AwakenShopScene", UFCCSBaseScene)
local FunctionLevelConst = require "app.const.FunctionLevelConst"

function AwakenShopScene:ctor(_, _, _, _, scenePack)
    
    AwakenShopScene.super.ctor(self)
    
    local layer = require("app.scenes.awakenshop.AwakenShopLayer").create()
    self:addUILayerComponent("AwakenShopLayer", layer, true)
    
    local roleInfo = G_commonLayerModel:getShopRoleInfoLayer()
    self:addUILayerComponent("RoleInfoUI", roleInfo, true)
    
    local speedBar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", speedBar, true)
    
    -- 扣除roleInfo和speedBar的位置
    self:adapterLayerHeight(layer, roleInfo, speedBar, -10, -20)
    -- 调整Panel_content至屏幕中央
    layer:adapterWidgetHeight("Panel_content", "Panel_117", "Panel_261", 0, 0)
    
    -- 获取将魂按钮
    layer:registerBtnClickEvent("Button_get_essence", function()
        uf_sceneManager:popToRootAndReplaceScene(require("app.scenes.bag.BagScene").new(2, GlobalFunc.sceneToPack("app.scenes.awakenshop.AwakenShopScene", {})))
    end)
    
    -- 返回按钮
    layer:registerBtnClickEvent("Button_back", function()
        uf_sceneManager:replaceScene(scenePack and G_GlobalFunc.packToScene(scenePack) or require("app.scenes.mainscene.MainScene").new())
    end)


    -- 等级差5级的时候就可以看到了  
    if G_Me.userData.level - G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.AWAKEN_MARK) >= -5 then 
        layer:getButtonByName("Button_yixuandaojuIcon"):setVisible(true)
        layer:registerBtnClickEvent("Button_yixuandaojuIcon", function()
            if G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.AWAKEN_MARK) == true then
                local selectedLayer = require("app.scenes.awakenshop.AwakenSelectedLayer").create()
                uf_notifyLayer:getModelNode():addChild(selectedLayer)  
            end 
        end)
    else 
        layer:getButtonByName("Button_yixuandaojuIcon"):setVisible(false)
    end 
    
end

return AwakenShopScene

-- SecretShopScene

local SecretShopScene = class("SecretShopScene", UFCCSBaseScene)

function SecretShopScene:ctor(_, _, _, _, scenePack)
    
    SecretShopScene.super.ctor(self)
    
    local layer = require("app.scenes.secretshop.SecretShopLayer").create()
    self:addUILayerComponent("SecretShopLayer", layer, true)
    
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
        uf_sceneManager:replaceScene(require("app.scenes.recycle.RecycleScene").new(nil, nil, nil, nil, 
            GlobalFunc.sceneToPack("app.scenes.secretshop.SecretShopScene")))
    end)
    
    -- 返回按钮
    layer:registerBtnClickEvent("Button_back", function()
        uf_sceneManager:replaceScene(scenePack and G_GlobalFunc.packToScene(scenePack) or require("app.scenes.mainscene.MainScene").new())
    end)
    
end

return SecretShopScene
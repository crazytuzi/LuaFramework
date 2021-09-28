-- PetShopScene

local PetShopScene = class("PetShopScene", UFCCSBaseScene)

function PetShopScene:ctor(_, _, _, _, scenePack)
    
    PetShopScene.super.ctor(self)
    
    local layer = require("app.scenes.pet.shop.PetShopLayer").create()
    self:addUILayerComponent("PetShopLayer", layer, true)
    
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
        uf_sceneManager:replaceScene(require("app.scenes.crusade.CrusadeScene").new(nil, nil, nil, nil, 
            GlobalFunc.sceneToPack("app.scenes.pet.shop.PetShopScene")))
    end)
    
    -- 返回按钮
    layer:registerBtnClickEvent("Button_back", function()
        uf_sceneManager:replaceScene(scenePack and G_GlobalFunc.packToScene(scenePack) or require("app.scenes.mainscene.MainScene").new())
    end)
    
end

return PetShopScene
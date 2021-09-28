local ShopScene = class("ShopScene",UFCCSBaseScene)
local ShopLayer = require("app.scenes.shop.ShopLayer")
function ShopScene:ctor(...)
    __LogTag(TAG,"ShopScene:ctor")
    self._shopVipId = 0
    self.super.ctor(self, ...)
end

function ShopScene:onSceneLoad( json, func, vipId )
    __LogTag("__------------------vipId = %s",vipId)
    self._shopVipId = vipId or 0
end

function ShopScene:onSceneUnload()
    uf_eventManager:removeListenerWithTarget(self)
end

function ShopScene:onSceneEnter(json, func, vipId )
    self._shopLayer = ShopLayer.create()
    self:addUILayerComponent("ShopLayer", self._shopLayer,true)

     --顶部
    self._shopTopbar = G_commonLayerModel:getShopRoleInfoLayer()
    self:addUILayerComponent("ShopTopbar",self._shopTopbar,true)
    
    self._speedbar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", self._speedbar,true)
    -- self._speedbar:setSelectBtn("Button_Shop")
    
    self:adapterLayerHeight(self._shopLayer,self._shopTopbar,self._speedbar,0,0)
    self._shopLayer:adapterLayer()
    --[[
        因为包裹物道具时，跳转shop，传入id为负数
    ]]
    if self._shopVipId ~= nil and type(self._shopVipId) == "number" and self._shopVipId ~= 0 then 
        if self._shopLayer then 
            self._shopLayer:startWithShopVipId(self._shopVipId)
        end
        self._shopVipId = 0
    elseif self._shopVipId ~= nil and type(self._shopVipId) == "string" then
        if self._shopVipId == ShopLayer.ITEM_CHECKED then
            self._shopLayer:setChecked(ShopLayer.ITEM_CHECKED)
        elseif self._shopVipId == ShopLayer.RECHARGE_SHOW then
            require("app.scenes.shop.recharge.RechargeLayer").show()
        end
    end
end

function ShopScene:onSceneExit()
    self:removeComponent(SCENE_COMPONENT_GUI, "ShopTopbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return ShopScene

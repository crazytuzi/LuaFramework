
local MailScene = class("MailScene", UFCCSBaseScene)


function MailScene:ctor(checkType,...)
    self._checkType = checkType
    self.super.ctor(self,...)

end


function MailScene:onSceneLoad( ... )

    --列表页面
    self._mailListLayer = require("app.scenes.mail.MailListLayer").create(self._checkType)
    self:addUILayerComponent("MailListLayer", self._mailListLayer, true)

end



function MailScene:onSceneEnter( )
    --self:adapterLayerHeight(self._mailListLayer, nil, self._speedbar, 0, -20)
    ---底部菜单
    self._speedbar = G_commonLayerModel:getSpeedbarLayer()
    self._roleInfo = G_commonLayerModel:getShopRoleInfoLayer()
    
    self:addUILayerComponent("RoleInfoUI",self._roleInfo,true)
    self:addUILayerComponent("SpeedBar", self._speedbar, true)
    
    self:adapterLayerHeight(self._mailListLayer,self._roleInfo,self._speedbar,-2,-50)
    self._mailListLayer:adapterLayer()
end

return MailScene

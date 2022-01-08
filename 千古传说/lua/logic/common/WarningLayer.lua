--[[
******操作确定层*******

    -- by king
    -- 2015/8/25
]]

local WarningLayer = class("WarningLayer", BaseLayer)

-- --CREATE_SCENE_FUN(WarningLayer)
CREATE_PANEL_FUN(WarningLayer)

function WarningLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.common.mistatetips")
end



function WarningLayer:initUI(ui)
  self.super.initUI(self,ui)

  self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')

end

function WarningLayer:removeUI()
  self.super.removeUI(self)
end


function WarningLayer.onOkClickHandle(sender)
  AlertManager:clearAllCache()
  CommonManager:closeConnection()
  -- MainPlayer:restart()
  -- AlertManager:changeSceneForce(SceneType.LOGIN)

  -- modify by king 20151106 游戏出错重启引擎
  restartLuaEngine("CompleteUpdate")
end


function WarningLayer:registerEvents()
    self.super.registerEvents(self)

    self.btn_ok.logic = self;
    self.btn_ok:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onOkClickHandle),1)
end


return WarningLayer

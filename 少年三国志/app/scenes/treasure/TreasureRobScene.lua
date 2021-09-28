

local TreasureRobScene = class("TreasureRobScene",UFCCSBaseScene)

function TreasureRobScene:ctor(...)
    self._isEnter = false
    self._fragmentId = nil
    self.super.ctor(self, ...)
end

--[[
    fragmentId 
    listData 未空则重新获取
]]
function TreasureRobScene:onSceneLoad(fragmentId,listData,...)
    self._fragmentId = fragmentId
    if not fragmentId then
        return nil
    end

    if self._mainBody == nil then
        self._mainBody = require("app.scenes.treasure.TreasureRobLayer").create(fragmentId,listData)
        self:addUILayerComponent("TreasureRobLayer", self._mainBody, true)
    end
end

function TreasureRobScene:onSceneEnter(...)
    if not self._fragmentId then
        uf_funcCallHelper:callNextFrame(function()
                uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureComposeScene").new())
            end, nil)
        return
    end

    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.PVP)
    self._roleInfo  = G_commonLayerModel:getTreasureRobRoleInfoLayer()
    self:addUILayerComponent("roleInfo", self._roleInfo,true)

    self._speedbar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", self._speedbar,true)
    if not self._isEnter then
        self:adapterLayerHeight(self._mainBody, self._roleInfo, self._speedbar, 10, -30)
        self._mainBody:adapterLayer()
    end 
    self._isEnter = true
end

--移除通用模块
function TreasureRobScene:onSceneExit( ... )
    if self._roleInfo then
        self:removeComponent(SCENE_COMPONENT_GUI, "roleInfo")
    end

    if self._speedbar then
        self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
    end
end

return TreasureRobScene









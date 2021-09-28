local TreasureDevelopeScene = class("TreasureDevelopeScene",UFCCSBaseScene)
local EquipmentConst = require("app.const.EquipmentConst")

function TreasureDevelopeScene:ctor(equipment, developeType)
    self.super.ctor(self)
    self._equipment = equipment
    self._developeType = developeType
end



function TreasureDevelopeScene.show(equipment, mode)

    if mode == EquipmentConst.RefineMode then
        -- 如果强化已经到达上限, 提示一下吧
        local funLevelConst = require("app.const.FunctionLevelConst")
        if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.TREASURE_TRAINING) then
            local level = equipment.refining_level
            local maxLevel = equipment:getMaxRefineLevel()
            if equipment:getInfo().type == 3 then
                G_MovingTip:showMovingTip(G_lang:get("LANG_EXP_CANNOT_REFINE"))
                return false
            end 
            if level >= maxLevel then
                G_MovingTip:showMovingTip(G_lang:get("LANG_REFINE_LEVEL_LIMIT"))
                return false
            end
        else
            return false
        end

    elseif mode == EquipmentConst.StrengthMode then
        --是否已经到达上限
        local funLevelConst = require("app.const.FunctionLevelConst")
        if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.TREASURE_STRENGTH) then
            local level = equipment.level
            local maxLevel = equipment:getMaxStrengthLevel()
            if equipment:getInfo().type == 3 then
                G_MovingTip:showMovingTip(G_lang:get("LANG_EXP_CANNOT_STRENGTH"))
                return false
            end 
            if level >= maxLevel then
                G_MovingTip:showMovingTip(G_lang:get("LANG_STRENGTH_LEVEL_LIMIT"))
                return false
            end
        else
            return false
        end
    end
    uf_sceneManager:pushScene(require("app.scenes.treasure.TreasureDevelopeScene").new( equipment, mode))
    return true
end

function TreasureDevelopeScene:onSceneLoad(equipment, developeType )
    self._style = developeType or 0
    self._equipment = equipment
end


function TreasureDevelopeScene:onSceneEnter()
    self._developeLayer = require("app.scenes.treasure.TreasureDevelopeLayer").create() 
    self._developeLayer:setEquipment(self._equipment, self._developeType)

    self:addUILayerComponent("DevelopeLayer", self._developeLayer, true)
    
 

    --顶部信息栏
 	self._topbar = G_commonLayerModel:getStrengthenRoleInfoLayer() 
 	self:addUILayerComponent("Topbar",self._topbar,true)


    --底部按钮栏    
    self._speedbar = G_commonLayerModel:getSpeedbarLayer()
    self:addUILayerComponent("SpeedBar", self._speedbar,true)
    

    --UI适配
    self:adapterLayerHeight(self._topbar,self._notice,nil,0,0)
    self:adapterLayerHeight(self._developeLayer,self._topbar,self._speedbar,-9,-9)
    self._developeLayer:adapterLayer()

    if self._style > 0 then
        self.show(self._equipment,self._style)
    end

end

--移除通用模块
function TreasureDevelopeScene:onSceneExit( ... )
    self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

function TreasureDevelopeScene:setEquipment(equipment)
    if equipment then
        self._equipment = equipment

        if self._developeLayer then
            self._developeLayer:setEquipment(self._equipment, self._developeType)
        end
    end
end

return TreasureDevelopeScene





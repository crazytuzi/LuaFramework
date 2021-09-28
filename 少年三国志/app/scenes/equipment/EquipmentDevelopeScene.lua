local EquipmentDevelopeScene = class("EquipmentDevelopeScene",UFCCSBaseScene)
local EquipmentConst = require("app.const.EquipmentConst")
function EquipmentDevelopeScene:ctor(equipment, developeType)    
    self._equipment = equipment
    self._developeType = developeType
    self.super.ctor(self,equipment, developeType)
end



function EquipmentDevelopeScene.show(equipment, mode)

    if not equipment:isEquipment() then
         G_MovingTip:showMovingTip("还没做宝物的这个界面哪")   
        return false
    else
        -- 如果强化已经到达上限, 提示一下吧
        if mode == EquipmentConst.RefineMode then

                local funLevelConst = require("app.const.FunctionLevelConst")
                if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.EQUIP_TRAINING) then

                    local level = equipment.refining_level
                    local maxLevel = equipment:getMaxRefineLevel()
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
                if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.EQUIP_STRENGTH) then
                    local level = equipment.level
                    local maxLevel = equipment:getMaxStrengthLevel()
                    if level >= maxLevel then
                        G_MovingTip:showMovingTip(G_lang:get("LANG_STRENGTH_LEVEL_LIMIT"))
                        return false
                    end
                else
                    return false
                end
        elseif mode == EquipmentConst.StarMode then
            
                -- 装备升星
                local funLevelConst = require("app.const.FunctionLevelConst")
                local star_level = equipment.star or 0
                local maxStarLevel = equipment:getMaxStarLevel()
                local equipmentInfo = equipment:getInfo()

                if equipmentInfo.potentiality < EquipmentConst.Star_Potentiality_Min_Value then

                    G_MovingTip:showMovingTip(G_lang:get("LANG_EQUIPMENT_STAR_CAN_NOT_DO_DESC"))
                    return false

                elseif G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.EQUIP_STAR) then

                    if star_level >= maxStarLevel then

                        G_MovingTip:showMovingTip(G_lang:get("LANG_EQUIPMENT_STAR_LEVEL_LIMIT"))
                        return false
                    end

                else

                    return false
                end

        end

    end

    uf_sceneManager:pushScene(require("app.scenes.equipment.EquipmentDevelopeScene").new( equipment, mode))
    return true
end

function EquipmentDevelopeScene:onSceneLoad( equip, style, ... )
    self._equipment = equip

    self._developeLayer = require("app.scenes.equipment.EquipmentDevelopeLayer").create() 

    self._developeLayer:setEquipment(self._equipment, self._developeType)

    self:addUILayerComponent("DevelopeLayer", self._developeLayer, true)
end


function EquipmentDevelopeScene:onSceneEnter()

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

    -- if self._style > 0 then
    --     self.show(self._equipment,self._style)
    -- end

end

--移除通用模块
function EquipmentDevelopeScene:onSceneExit( ... )
    self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return EquipmentDevelopeScene





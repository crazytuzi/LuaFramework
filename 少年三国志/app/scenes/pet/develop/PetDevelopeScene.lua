local PetDevelopeScene = class("PetDevelopeScene",UFCCSBaseScene)

function PetDevelopeScene:ctor(pet, developeType)    
    self.super.ctor(self)
    self._pet = pet
    self._developeType = developeType
end



function PetDevelopeScene.show(pet, developeType)

    -- -- 如果强化已经到达上限, 提示一下吧
    -- if mode == EquipmentConst.RefineMode then

    --         local funLevelConst = require("app.const.FunctionLevelConst")
    --         if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.EQUIP_TRAINING) then

    --             local level = equipment.refining_level
    --             local maxLevel = equipment:getMaxRefineLevel()
    --             if level >= maxLevel then
    --                 G_MovingTip:showMovingTip(G_lang:get("LANG_REFINE_LEVEL_LIMIT"))
    --                 return false
    --             end
    --         else
    --             return false
    --         end

    -- elseif mode == EquipmentConst.StrengthMode then
    --     --是否已经到达上限
    --         local funLevelConst = require("app.const.FunctionLevelConst")
    --         if G_moduleUnlock:checkModuleUnlockStatus(funLevelConst.EQUIP_STRENGTH) then
    --             local level = equipment.level
    --             local maxLevel = equipment:getMaxStrengthLevel()
    --             if level >= maxLevel then
    --                 G_MovingTip:showMovingTip(G_lang:get("LANG_STRENGTH_LEVEL_LIMIT"))
    --                 return false
    --             end
    --         else
    --             return false
    --         end
    -- end

    uf_sceneManager:pushScene(require("app.scenes.pet.develop.PetDevelopeScene").new( pet, developeType))
    return true
end

function PetDevelopeScene:onSceneLoad( pet, style, ... )
    self._pet = pet
    self._style = style or 0
end


function PetDevelopeScene:onSceneEnter()

    self._developeLayer = require("app.scenes.pet.develop.PetDevelopeLayer").create() 
    
    self._developeLayer:setPet(self._pet, self._developeType)

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
    -- self._developeLayer:adapterLayer()

end

--移除通用模块
function PetDevelopeScene:onSceneExit( ... )
    self:removeComponent(SCENE_COMPONENT_GUI, "Topbar")
    self:removeComponent(SCENE_COMPONENT_GUI, "SpeedBar")
end

return PetDevelopeScene





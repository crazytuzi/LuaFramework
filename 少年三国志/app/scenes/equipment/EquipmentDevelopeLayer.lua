


local EquipmentDevelopeLayer = class("EquipmentDevelopeLayer",UFCCSNormalLayer)
local BagConst = require("app.const.BagConst")
local EffectNode = require "app.common.effects.EffectNode"
local funLevelConst = require("app.const.FunctionLevelConst")
local EquipmentConst = require("app.const.EquipmentConst")

require("app.cfg.team_target_info")
require("app.cfg.equipment_skill_info")

function EquipmentDevelopeLayer.create(...)
    return require("app.scenes.equipment.EquipmentDevelopeLayer").new("ui_layout/equipment_EquipmentDevelopeLayer.json", equipment, ...)
end

function EquipmentDevelopeLayer:ctor(json, ...)
    self._equipStrengthTargetId = 0
    self._equipJinglianTargetId = 0
    self._wearPosId = 0

    -- print("EquipmentDevelopeLayer ctor")
    self._views = {}
    self._defaultDevelpeType = "CheckBox_strength"
    self._equipment = nil
    self._equipmentStrength = require("app.scenes.equipment.develope.EquipmentStrength").new(self)
    self._equipmentRefine = require("app.scenes.equipment.develope.EquipmentRefine").new(self)
    self._equipmentStar = require("app.scenes.equipment.develope.EquipmentStar").new(self)
    self.super.ctor(self, json, ...)
    self._tabs = require("app.common.tools.Tabs").new(2, self,self._checkedCallBack, self._uncheckedCallBack) 

    self._showAttrButton = self:getButtonByName("Button_showAttr")
    self._showAttrButton:setVisible(false)
end

--设置这个养成界面的装备(mergeEquipment)
function EquipmentDevelopeLayer:setEquipment(equipment, developeType)

    self._equipment = equipment
    
    if developeType ~= nil then
        
        if developeType == EquipmentConst.RefineMode then

            self._defaultDevelpeType  = "CheckBox_refine"
        elseif developeType == EquipmentConst.StarMode then
            -- 装备升星
            self._defaultDevelpeType = "CheckBox_star"
        end
    end

    if equipment then 
        local inLiueupId = equipment:getWearingKnightId()
        if inLiueupId > 0 then 
            local teamId, posId = G_Me.formationData:getKnightPosInTeam(inLiueupId)
            if teamId == 1 and posId > 0 then 
                self._wearPosId = posId
                self._equipStrengthTargetId = G_Me.formationData:getKnightEquipTarget(true, posId)
                self._equipJinglianTargetId = G_Me.formationData:getKnightEquipTarget(false, posId)

                __Log("self._equipStrengthTargetId:%d, self._equipJinglianTargetId:%d", 
                    self._equipStrengthTargetId, self._equipJinglianTargetId)
            end
        end
    end
end

function EquipmentDevelopeLayer:onEquipStrength( ... )
    if self._wearPosId < 1 then 
        return 
    end

    local equipStrengthTarget, targetLevel = G_Me.formationData:getKnightEquipTarget(true, self._wearPosId)
    if equipStrengthTarget <= self._equipStrengthTargetId then 
        return 
    end

    self._equipStrengthTargetId = equipStrengthTarget
    local desc = G_lang:get("LANG_KNIGHT_TARGET_ATTRI_CHANGE_TIP", {targetName = G_lang:get("LANG_KNIGHT_EQUIP_STRENGTH_TARGET_NAME"), targeLevel = equipStrengthTarget})
    G_flyAttribute.doAddRichtext(desc, 40, nil, nil, nil)

    local targetRecord = team_target_info.get(1, targetLevel)
    if targetRecord then 
        if targetRecord.att_type_1 > 0 then
            local curTargetDesc = G_lang.getGrowthTypeName(
                targetRecord.att_type_1).."+"..G_lang.getGrowthValue(
                targetRecord.att_type_1, targetRecord.att_value_1)
            G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen, nil, nil, nil, 40)
        end
        if targetRecord.att_type_2 > 0 then
            local curTargetDesc = G_lang.getGrowthTypeName(
                targetRecord.att_type_2).."+"..G_lang.getGrowthValue(
                targetRecord.att_type_2, targetRecord.att_value_2)
            G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen, nil, nil, nil, 40)
        end
        if targetRecord.att_type_3 > 0 then
            local curTargetDesc = G_lang.getGrowthTypeName(
                targetRecord.att_type_3).."+"..G_lang.getGrowthValue(
                targetRecord.att_type_3, targetRecord.att_value_3)
            G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen, nil, nil, nil, 40)
        end
    end
end

-- 红装神兵技能达到之后的文字特效
function EquipmentDevelopeLayer:_redEquipmentSkill()
    local baseInfo = self._equipment:getInfo()
    for i=1, 10 do
        local equipmentSkillId = baseInfo["equipment_skill_"..i]
        if equipmentSkillId and equipmentSkillId ~= 0 then
            local equipmentSkillInfo = equipment_skill_info.get(equipmentSkillId)
            if self._equipment.refining_level == equipmentSkillInfo.open_value then
                -- 满足要求 神兵技能XXXX激活
                local desc = G_lang:get("LANG_KNIGHT_TARGET_ATTRI_CHANGE_TIP_EQUIPMENT", {targetName = equipmentSkillInfo.name})
                G_flyAttribute.doAddRichtext(desc, 40, nil, nil, self._showAttrButton)
                local curTargetDesc = G_lang.getGrowthTypeName(
                    equipmentSkillInfo.attribute_type).."+"..G_lang.getGrowthValue(
                    equipmentSkillInfo.attribute_type, equipmentSkillInfo.attribute_value)
                if equipmentSkillInfo.attribute_type == 0 then 
                    -- 属性没有固定增加值  显示描述
                    local tempDesc = GlobalFunc.autoNewLine(string.split(equipmentSkillInfo.directions,"（")[1],10,1)
                    for i = 1,#tempDesc do 
                        G_flyAttribute.addNormalText( tempDesc[i] , Colors.titleGreen, self._showAttrButton, nil, nil, 40)
                    end
                else 
                    G_flyAttribute.addNormalText( curTargetDesc , Colors.titleGreen, self._showAttrButton, nil, nil, 40)
                end
                break 
            end
        end
    end
end

function EquipmentDevelopeLayer:onEquipJinglian( ... )
    self:_redEquipmentSkill()
    if self._wearPosId < 1 then 
        return 
    end

    local equipStrengthTarget, targetLevel = G_Me.formationData:getKnightEquipTarget(false, self._wearPosId)
    if equipStrengthTarget <= self._equipJinglianTargetId then 
        return 
    end

    self._equipJinglianTargetId = equipStrengthTarget
    local desc = G_lang:get("LANG_KNIGHT_TARGET_ATTRI_CHANGE_TIP", {targetName = G_lang:get("LANG_KNIGHT_EQUIP_JINGLIAN_TARGET_NAME"), targeLevel = equipStrengthTarget})
    G_flyAttribute.doAddRichtext(desc, 40, nil, nil, nil)

    local targetRecord = team_target_info.get(3, targetLevel)
    if targetRecord then 
        if targetRecord.att_type_1 > 0 then
            local curTargetDesc = G_lang.getGrowthTypeName(
                targetRecord.att_type_1).."+"..G_lang.getGrowthValue(
                targetRecord.att_type_1, targetRecord.att_value_1)
            G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen, nil, nil, nil, 40)
        end
        if targetRecord.att_type_2 > 0 then
            local curTargetDesc = G_lang.getGrowthTypeName(
                targetRecord.att_type_2).."+"..G_lang.getGrowthValue(
                targetRecord.att_type_2, targetRecord.att_value_2)
            G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen, nil, nil, nil, 40)
        end
        if targetRecord.att_type_3 > 0 then
            local curTargetDesc = G_lang.getGrowthTypeName(
                targetRecord.att_type_3).."+"..G_lang.getGrowthValue(
                targetRecord.att_type_3, targetRecord.att_value_3)
            G_flyAttribute.addNormalText(curTargetDesc, Colors.titleGreen, nil, nil, nil, 40)
        end
    end
end

function EquipmentDevelopeLayer:getEquipment()
    return self._equipment   
end

--播放特效的锚点容器
function EquipmentDevelopeLayer:getEffectNode()
   return self:getPanelByName("Panel_effect")
end

function EquipmentDevelopeLayer:_initTabs()
    self:_updateCheckBtns()
    self:_createTab("Panel_strengthEquipment","CheckBox_strength","Label_strength")
    self:_createTab("Panel_refineEquipment", "CheckBox_refine","Label_refine")
    self:_createTab("Panel_starEquipment", "CheckBox_star","Label_star")
    self._tabs:checked(self._defaultDevelpeType)

end


function EquipmentDevelopeLayer:_checkedCallBack(btnName)
    if btnName == "CheckBox_strength" then
        self:_resetStrengthView()
    elseif btnName == "CheckBox_refine" then
        self:_resetRefineView()
    elseif btnName == "CheckBox_star" then
        self:_resetStarView()
    end
   
end

function EquipmentDevelopeLayer:_uncheckedCallBack(btnName)
    if btnName == "CheckBox_strength" then
        self._equipmentStrength:onUncheck()
    elseif btnName == "CheckBox_refine" then
        
    end
end


function EquipmentDevelopeLayer:_createTab(panelName,btnName,labelName)

    self._views[btnName] = self:getPanelByName(panelName)
    self._tabs:add(btnName, self._views[btnName],labelName)
end


--当玩家点击了强化tab时
function EquipmentDevelopeLayer:_resetStrengthView()
    
    self:_updateCommonAttrs()

    self._equipmentStrength:updateView()
    self._showAttrButton:setVisible(false)
    self._equipmentStar:stopAllEffect()

    local tiezan = self:getImageViewByName("ImageView_tiezan")
    tiezan:setVisible(false)
    self:getImageViewByName("Image_luzi1"):setVisible(false)
    self:getImageViewByName("Image_luzi2"):setVisible(false)
    self:showWidgetByName("Panel_stars_equip",false)
    self:showWidgetByName("Button_help",false)
    -- effect_stone
    -- effect_fire
    if self._huoyandown == nil then 
        self._huoyandown = EffectNode.new("effect_firestone_down", 
            function(event, frameIndex)

            end
        )
        self._huoyandown:setScale(1.5)
        self._huoyandown:setPosition(ccp(-30,-70))
        self:getPanelByName("Panel_foreffect_down"):addNode(self._huoyandown)
        self._huoyandown:play()
    end
    if self._huoyanup == nil then 
        self._huoyanup = EffectNode.new("effect_firestone_up", 
            function(event, frameIndex)

            end
        )
        self._huoyanup:setPosition(ccp(0,50))
        self:getPanelByName("Panel_foreffect"):addNode(self._huoyanup)
        self._huoyanup:play()
    end

    
    if self._luziup then 
        self._luziup:stop()
        self._luziup:removeFromParentAndCleanup(true)
        self._luziup = nil    
    end

    if self._luzidown then 
        self._luzidown:stop()
        self._luzidown:removeFromParentAndCleanup(true)
        self._luzidown = nil    
    end
    
    self:_treasureMove("ImageView_pic",false)
    -- G_flyAttribute._clearFlyAttributes()
end



--当玩家点击了精炼tab时
function EquipmentDevelopeLayer:_resetRefineView()
    self:_updateCommonAttrs()

    self._equipmentRefine:updateView()
    self._equipmentRefine:setTouchable(true)
    self._showAttrButton:setVisible(#self._equipment:getSkillTxt() > 0)
    self._equipmentStar:stopAllEffect()

    self:getImageViewByName("ImageView_tiezan"):setVisible(false)
    self:showWidgetByName("Panel_stars_equip",false)
    self:showWidgetByName("Button_help",false)

    local luzi = self:getImageViewByName("Image_luzi1")
    luzi:setVisible(false)
    self:getImageViewByName("Image_luzi2"):setVisible(false)

    if self._luziup == nil then 
        self._luziup = EffectNode.new("effect_luzi_up", 
            function(event, frameIndex)

            end
        )
        self._luziup:setPosition(ccp(50,50))
        self:getPanelByName("Panel_foreffect"):addNode(self._luziup)
        self._luziup:play()
    end

    if self._luzidown == nil then 
        self._luzidown = EffectNode.new("effect_luzi_down", 
            function(event, frameIndex)

            end
        )
        self._luzidown:setPosition(ccp(50,50))
        self:getPanelByName("Panel_foreffect_down"):addNode(self._luzidown)
        self._luzidown:play()
    end

    if self._huoyanup then 
        self._huoyanup:stop()
        self._huoyanup:removeFromParentAndCleanup(true)
        self._huoyanup = nil    
    end

    if self._huoyandown then 
        self._huoyandown:stop()
        self._huoyandown:removeFromParentAndCleanup(true)
        self._huoyandown = nil    
    end
    
    self:_treasureMove("ImageView_pic",true)
    -- G_flyAttribute._clearFlyAttributes()
end

--当玩家点击了升星tab时
function EquipmentDevelopeLayer:_resetStarView()
    self:_updateCommonAttrs()

    self._equipmentStar:updateView()
    self._equipmentStar:setTouchable(true)
    self._showAttrButton:setVisible(false)
    self._equipmentStar:stopAllEffect()

    self:getImageViewByName("ImageView_tiezan"):setVisible(false)
    self:showWidgetByName("Panel_stars_equip",true)
    self:showWidgetByName("Button_help",true)

    local luzi = self:getImageViewByName("Image_luzi1")
    luzi:setVisible(false)
    self:getImageViewByName("Image_luzi2"):setVisible(false)

    if self._luziup == nil then 
        self._luziup = EffectNode.new("effect_luzi_up", 
            function(event, frameIndex)

            end
        )
        self._luziup:setPosition(ccp(50,50))
        self:getPanelByName("Panel_foreffect"):addNode(self._luziup)
        self._luziup:play()
    end

    if self._luzidown == nil then 
        self._luzidown = EffectNode.new("effect_luzi_down", 
            function(event, frameIndex)

            end
        )
        self._luzidown:setPosition(ccp(50,50))
        self:getPanelByName("Panel_foreffect_down"):addNode(self._luzidown)
        self._luzidown:play()
    end

    if self._huoyanup then 
        self._huoyanup:stop()
        self._huoyanup:removeFromParentAndCleanup(true)
        self._huoyanup = nil    
    end

    if self._huoyandown then 
        self._huoyandown:stop()
        self._huoyandown:removeFromParentAndCleanup(true)
        self._huoyandown = nil    
    end
    
    self:_treasureMove("ImageView_pic",true)
end

-- 更新通用的属性, 名字啊, star啥的
function EquipmentDevelopeLayer:_updateCommonAttrs()
    local info = self._equipment:getInfo()
    --名字
    self:getLabelByName("Label_equipmentName"):setColor(Colors.getColor(info.quality))
    self:getLabelByName("Label_equipmentName"):setText(info.name)
    self:getLabelByName("Label_equipmentName"):createStroke(Colors.strokeBrown,2)

    --大图
    self:getImageViewByName("ImageView_pic"):loadTexture(self._equipment:getPic())
    
end

function EquipmentDevelopeLayer:adapterLayer()

    self:adapterWidgetHeight("Panel_content", "Panel_checkbox", "", 0, 0)
    -- self:adapterWidgetHeight("ImageView_bg","Panel_checkbox","",0,0)

    self:_initTabs()
    self:_updateCheckBtns()
end

function EquipmentDevelopeLayer:_updateCheckBtns()

    local StrUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.EQUIP_STRENGTH)
    local RefUnlock = G_moduleUnlock:isModuleUnlock(funLevelConst.EQUIP_TRAINING)

    -- self:enableWidgetByName("CheckBox_strength", StrUnlock)
    -- if not StrUnlock then
    --     self:getLabelByName("Label_strength"):setColor(Colors.TAB_GRAY)
    --     self:getLabelByName("Label_strength_0"):setColor(Colors.TAB_GRAY)
    -- end
    -- self:enableWidgetByName("CheckBox_refine", RefUnlock)
    -- if not RefUnlock then
    --     self:getLabelByName("Label_refine"):setColor(Colors.TAB_GRAY)
    --     self:getLabelByName("Label_refine_0"):setColor(Colors.TAB_GRAY)
    -- end


    local equipment = self._equipment
    local info = equipment:getInfo()
    local star_level = equipment.star or 0
    local maxStarLevel = equipment:getMaxStarLevel()
    local refineLevel = equipment.refining_level
    local refineMaxLevel = equipment:getMaxRefineLevel()

    local canRefine = RefUnlock
    if refineLevel >= refineMaxLevel then
        canRefine = false
    end

    self:getWidgetByName("CheckBox_strength"):setTouchEnabled(StrUnlock)


    self:getWidgetByName("CheckBox_refine"):setTouchEnabled(canRefine)


    

    local canStar = true
    if info.potentiality < EquipmentConst.Star_Potentiality_Min_Value then
        canStar = false
    elseif not G_moduleUnlock:isModuleUnlock(funLevelConst.EQUIP_STAR) then
        canStar = false
    elseif star_level >= maxStarLevel then
        canStar = false
    end
    self:getWidgetByName("CheckBox_star"):setTouchEnabled(canStar)

end

function EquipmentDevelopeLayer:onLayerLoad( )

    --返回按钮事件
    self:registerBtnClickEvent("Button_return", function()
        -- uf_sceneManager:popScene()
        if CCDirector:sharedDirector():getSceneCount() > 1 then 
                    uf_sceneManager:popScene()
        else
            uf_sceneManager:replaceScene(require("app.scenes.equipment.EquipmentMainScene").new())
        end
    end)

    self:registerWidgetClickEvent("ImageView_pic", function()
        -- uf_sceneManager:popScene()
        if CCDirector:sharedDirector():getSceneCount() > 1 then 
                    uf_sceneManager:popScene()
        else
            uf_sceneManager:replaceScene(require("app.scenes.equipment.EquipmentMainScene").new())
        end
    end)

    --通用
    --self:getLabelByName("Label_equipmentName"):createStroke(Colors.strokeBrown,1)
    -- self:getLabelByName("Label_currentLevel"):createStroke(Colors.strokeBrown,1)
    -- self:getLabelByName("Label_nextLevel"):createStroke(Colors.strokeBrown,1)
    -- self:getLabelByName("Label_cost"):createStroke(Colors.strokeBrown,1)

    --强化装备
    self._equipmentStrength:onLayerLoad()

    --精炼装备
    self._equipmentRefine:onLayerLoad()

    -- 升星装备
    self._equipmentStar:onLayerLoad()

    if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
         if self._huoyan1 == nil then 
             self._huoyan1 = EffectNode.new("effect_zbyc", 
                 function(event, frameIndex)

                 end
             )
             self:getImageViewByName("ImageView_bg"):addNode(self._huoyan1)
             self._huoyan1:play()
         end

        if self._huoyan2 == nil then 
            self._huoyan2 = EffectNode.new("effect_fire", 
                function(event, frameIndex)

                end
            )
            self._huoyan2:setPosition(ccp(-196,220))
            self:getImageViewByName("ImageView_bg"):addNode(self._huoyan2)
            self._huoyan2:play()
        end
        if self._huoyan3 == nil then 
            self._huoyan3 = EffectNode.new("effect_fire", 
                function(event, frameIndex)

                end
            )
            self._huoyan3:setPosition(ccp(172,205))
            self:getImageViewByName("ImageView_bg"):addNode(self._huoyan3)
            self._huoyan3:play()
        end
    end
end

function EquipmentDevelopeLayer:onLayerUnload()

    uf_eventManager:removeListenerWithTarget(self)

    self._equipmentStrength:onLayerUnload()
    self._equipmentRefine:onLayerUnload()
    self._equipmentStar:onLayerUnload()

    G_flyAttribute._clearFlyAttributes()

    if self._huoyan1 ~= nil then 
        self._huoyan1:stop()
        self._huoyan1:removeFromParentAndCleanup(true)
        self._huoyan1 = nil
    end
    if self._huoyan2 ~= nil then 
        self._huoyan2:stop()
        self._huoyan2:removeFromParentAndCleanup(true)
        self._huoyan2 = nil
    end
    if self._huoyan3 ~= nil then 
        self._huoyan3:stop()
        self._huoyan3:removeFromParentAndCleanup(true)
        self._huoyan3 = nil
    end

    self.super:onLayerUnload()
end

local basePos = nil
function EquipmentDevelopeLayer:_treasureMove( imgName, blur )
  if not imgName then
    return 
  end
  local imgCtrl = self:getWidgetByName(imgName)
  if not imgCtrl then
    return 
  end
  if not basePos then
    basePos = ccp(imgCtrl:getPosition())
  end

  blur = blur or false

  local time = 1.0
  local offset = 10

  if blur then
    imgCtrl:setPosition(basePos)
    imgCtrl:stopAllActions()
    local anime1 = CCMoveBy:create(time,ccp(0,offset))
    local anime2 = CCMoveBy:create(time,ccp(0,-offset))
    local seqAction = CCSequence:createWithTwoActions(anime1, anime2)
    seqAction = CCRepeatForever:create(seqAction)
    imgCtrl:runAction(seqAction)
  else
    imgCtrl:setPosition(basePos)
    imgCtrl:stopAllActions()
  end
end

-- function EquipmentDevelopeLayer:onLayerExit( )
--     uf_eventManager:removeListenerWithTarget(self)
-- end

return EquipmentDevelopeLayer


local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local FunctionLevelConst = require("app.const.FunctionLevelConst")

local LoseGuide = class ("LoseGuide", function() return display.newNode() end)
local Colors = require("app.setting.Colors")
local BattleGuideFunction = require("app.scenes.common.fightend.BattleGuideFunction")

local KnightPic = require("app.scenes.common.KnightPic")
require("app.cfg.battle_guide_info")
function LoseGuide:ctor( endCallback)
    self._endCallback =  endCallback

    self:setNodeEventEnabled(true)

    self._layer =  UFCCSNormalLayer.new("ui_layout/fightend_FightEndLose.json")
    self._layer:setClickSwallow(true)
    local size = self._layer:getRootWidget():getContentSize()
    self._layer:setPosition(ccp(-size.width/2, -size.height/2 - 200))
    self:addChild(self._layer)

    self._layer:setCascadeOpacityEnabled(true)
    -- self._layer:setOpacity(0)


    self._layer:getLabelByName("Label_title"):createStroke(Colors.strokeBrown,1)

    self._layer:getLabelByName("Label_title"):setText(G_lang:get("LANG_FIGHTEND_LOSE_GUIDE"))



    self._guideInfo = self:_getBattleGuideInfo()

    local strengthKnightBtn = nil
    if self._guideInfo then
        for i=1,3 do
            if self._guideInfo["type_"..i] == BattleGuideFunction.WU_JIANG_SHENG_JI then
                strengthKnightBtn = "Button_0" .. i
            end

            self._layer:getButtonByName("Button_0" .. i):loadTextureNormal(G_Path.getBasicIconById(self._guideInfo["res_id_" .. i]))
            local path = string.format("%s.png",G_Path.getTextPath(self._guideInfo["txt_id_" .. i]))
            self._layer:getImageViewByName("Image_0" .. i):loadTexture(path)
        end
    end
    self._layer:registerBtnClickEvent("Button_01", function ( widget )
        if self._guideInfo then
            BattleGuideFunction.linkSceneByType((type(strengthKnightBtn) == "string" and strengthKnightBtn == "Button_01" and self:_hasUnStrenthHero() ) and 
                 BattleGuideFunction.WU_JIANG_SHENG_JI_ADVANCED or (self._guideInfo.type_1 or 1))
        end
    end)

    self._layer:registerBtnClickEvent("Button_02", function ( widget )
        if self._guideInfo then
            BattleGuideFunction.linkSceneByType((type(strengthKnightBtn) == "string" and strengthKnightBtn == "Button_02" and self:_hasUnStrenthHero() ) and
                BattleGuideFunction.WU_JIANG_SHENG_JI_ADVANCED or BattleGuideFunction.WU_JIANG_SHENG_JI)
        end
    end)

    self._layer:registerBtnClickEvent("Button_03", function ( widget )
       if self._guideInfo then
           BattleGuideFunction.linkSceneByType(self._guideInfo.type_3 or 1)
       end
    end)

    if G_GuideMgr and G_GuideMgr:isCurrentGuiding() then 
        self._layer:showWidgetByName("Label_title", false)
        self._layer:showWidgetByName("Button_equipment", false)
        self._layer:showWidgetByName("Button_knight", false)
        self._layer:showWidgetByName("Button_shop", false)
    end
    

    if self:_hasUnStrenthHero() and strengthKnightBtn then
        self:_showFingerAtWidget(self._layer:getWidgetByName(strengthKnightBtn))
    end
end

function LoseGuide:_hasUnStrenthHero()
    local mainTeamHeroCount = G_Me.formationData:getFormationHeroCount(1)
    for index = 1, mainTeamHeroCount do 
        local knightId, baseId = G_Me.formationData:getTeamKnightIdAndBaseIdByIndex(1, index)
        local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId or 0)
        if knightInfo and knightInfo["level"] == 1 then 
            return true
        end
    end

    return false
end

function LoseGuide:_showFingerAtWidget( widget )
    if not widget then 
        return 
    end

    local EffectNode = require "app.common.effects.EffectNode"
    self._fingerEffect = EffectNode.new("effect_finger") 
    widget:addNode(self._fingerEffect)
    self._fingerEffect:setVisible(true)
    self._fingerEffect:play()
end

function LoseGuide:_getBattleGuideInfo()
    local len = battle_guide_info.getLength()
    local level = G_Me.userData.level
    for i=1,len do
        local item = battle_guide_info.indexOf(i)
        if item then
            if i == len then
                --最后一条无视level_max
                if level >= item.level_min then
                    return item
                end
            else
                if level >= item.level_min and level <= item.level_max then
                    return item
                end
            end
        end
    end
    return nil
end

function LoseGuide:play(   )
    -- transition.fadeTo(self._layer, {time=0.3, opacity=255})

    if self._endCallback ~= nil then
        self._endCallback()
    end


end


function LoseGuide:onExit()
    self:setNodeEventEnabled(false)

    
end




return LoseGuide
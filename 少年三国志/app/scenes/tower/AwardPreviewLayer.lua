
require("app.cfg.tower_info")

local AwardPreviewLayer = class("AwardPreviewLayer",UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function AwardPreviewLayer:ctor(...)
    self.super.ctor(self, ...)
    self:showAtCenter(true)
    self:registerTouchEvent(false, true, 0)
    -- self:registerBtnClickEvent("Button_Close1", function()
    --     self:close()
    -- end)
    -- self:registerBtnClickEvent("Button_Close2", function()
    --     self:close()
    -- end)
    self:showAtCenter(true)
end

function AwardPreviewLayer:onLayerEnter( )
    self:closeAtReturn(true)
end

function AwardPreviewLayer:initWithFloor(floor)
    local ri =  tower_info.get(floor)
    if not ri then
        return
    end
    -- GlobalFunc.numberToChinese
    self:getLabelByName("LabelBMFont_Floor"):setText(G_lang:get("LANG_TOWER_CENGSHU",{floor=floor}))
    self:getLabelByName("LabelBMFont_Floor"):createStroke(Colors.strokeBrown, 1)
    -- local fadeInAction = CCFadeIn:create(1)
    -- local fadeOutAction = CCFadeOut:create(1)
    -- local seqAction = CCSequence:createWithTwoActions(fadeInAction, fadeOutAction)
    -- seqAction = CCRepeatForever:create(seqAction)
    -- self:getImageViewByName("Image_kongbai"):runAction(seqAction)
    self:setClickClose(true)
    EffectSingleMoving.run(self:getImageViewByName("Image_kongbai"), "smoving_wait", nil , {position = true} )
    
    if math.floor(floor%5)==0 then
        self._panelAward = self:getPanelByName("Panel_AwardContainer")
        local p = require("app.scenes.tower.AwardLayer").new("ui_layout/tower_AwardPreview.json")
        p:initWithFloor(floor)
        p:setPosition(ccp(0,0))
        self._panelAward:addNode(p)
    else
        -- self:getLabelByName("Label_Prize"):setText(G_lang:get("LANG_TOWER_AWARD1",{money=ri.coins} ))
        -- self:getLabelByName("Label_Prize2"):setText(G_lang:get("LANG_TOWER_AWARD2",{score=ri.tower_score}))
        -- self:getLabelByName("Label_Prize"):createStroke(Colors.strokeBrown, 1)
        -- self:getLabelByName("Label_Prize2"):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_Prize"):setText(G_lang:get("LANG_TOWER_MONEY"))
        self:getLabelByName("Label_Prize2"):setText(G_lang:get("LANG_TOWER_ZHANGONG"))
        -- self:getLabelByName("Label_Prize"):createStroke(Colors.strokeBrown, 1)
        -- self:getLabelByName("Label_Prize2"):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_2566"):setText(G_lang:get("LANG_TOWER_JIANGLI"))
        self:getLabelByName("Label_2566"):createStroke(Colors.strokeBrown, 1)
        -- self:getLabelByName("Label_any"):setText(G_lang:get("LANG_TOWER_ANYKEY"))
        self:getLabelByName("Label_prizeValue1"):setText(ri.coins)
        self:getLabelByName("Label_prizeValue2"):setText(ri.tower_score)
        -- self:getLabelByName("Label_prizeValue1"):createStroke(Colors.strokeBrown, 1)
        -- self:getLabelByName("Label_prizeValue2"):createStroke(Colors.strokeBrown, 1)
    end
end

-- function AwardPreviewLayer:onTouchEnd( xpos, ypos )
--     self:close()
-- end

return AwardPreviewLayer


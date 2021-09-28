
local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"


local ExDungeonLayer = class ("ExDungeonLayer", function() return display.newNode() end)
local Colors = require("app.setting.Colors")
local BattleGuideFunction = require("app.scenes.common.fightend.BattleGuideFunction")

local KnightPic = require("app.scenes.common.KnightPic")
require("app.cfg.battle_guide_info")
function ExDungeonLayer:ctor(tData, endCallback)
    self._tData = tData
    self._endCallback =  endCallback

    self:setNodeEventEnabled(true)

    self._layer =  UFCCSNormalLayer.new("ui_layout/fightend_FightEndExDungeon.json")
    self._layer:setClickSwallow(true)
    local size = self._layer:getRootWidget():getContentSize()
    self._layer:setPosition(ccp(0, -size.height/2 - 38))
    self:addChild(self._layer)

    self._layer:setCascadeOpacityEnabled(true)

    -- 经验
    if self._tData._nExp ~= 0 then
        self._layer:showWidgetByName("Panel_ExpShow", true)
        G_GlobalFunc.updateLabel(self._layer, "Label_Exp", {stroke=Colors.strokeBrown})
        G_GlobalFunc.updateLabel(self._layer, "Label_Exp_Value", {stroke=Colors.strokeBrown, text=self._tData._nExp})
        G_GlobalFunc.updateLabel(self._layer, "Label_Exp_Value_Add", {stroke=Colors.strokeBrown, text=self._tData._szExpAdd})
    else
        self._layer:showWidgetByName("Panel_ExpShow", false)
    end

    if self._tData._szDesc then
        local label = self._layer:getLabelByName("Label_desc")
        if label then
            label:setText(self._tData._szDesc)
            label:createStroke(Colors.strokeBrown, 1)
        end
    end

    if table.nums(self._tData._tAwards) == 0 then
        self._layer:showWidgetByName("Image_Title2_Bg", false)
        for i=1, 3 do
            self._layer:showWidgetByName("Image_AwardBg"..i, false)
        end
    else
        for i=1, 3 do
            local imgBg = self._layer:getImageViewByName("Image_AwardBg"..i)
            local award = self._tData._tAwards[i]
            if award then
                local tGoods = G_Goods.convert(award.type, award.value, award.size)
                if tGoods then
                    self:_initGoods(i, tGoods)
                else
                    imgBg:setVisible(false)
                end
            else
                imgBg:setVisible(false)
            end
        end
    end

    self._layer:showWidgetByName("Panel_StarChanged", self._tData._bStarChanged)
    self._layer:showWidgetByName("Panel_StarNotChanged", not self._tData._bStarChanged)
    local labelTips = self._layer:getLabelByName("Label_Strive_Tips")
    if labelTips then
        labelTips:createStroke(Colors.strokeBrown, 1)
    end
end

function ExDungeonLayer:_initGoods(nIndex, tGoods)
    local imgIcon = self._layer:getImageViewByName("Image_Icon"..nIndex)
    if imgIcon then
        imgIcon:loadTexture(tGoods.icon, UI_TEX_TYPE_LOCAL)
    end    
    local imgQualityFrame = self._layer:getImageViewByName("Image_QualityFrame"..nIndex)
    if imgQualityFrame then
        imgQualityFrame:loadTexture(G_Path.getEquipColorImage(tGoods.quality), UI_TEX_TYPE_PLIST)
    end
    local imgColorBg = self._layer:getImageViewByName("Image_ColorBg"..nIndex)
    if imgColorBg then
        imgColorBg:loadTexture(G_Path.getEquipIconBack(tGoods.quality), UI_TEX_TYPE_PLIST)
    end
    local labelNum = self._layer:getLabelByName("Label_Num"..nIndex)
    if labelNum then
        labelNum:setText("x"..G_GlobalFunc.ConvertNumToCharacter2(tGoods.size))
        labelNum:createStroke(Colors.strokeBrown, 1)
    end
end

function ExDungeonLayer:play(   )
    -- if self._endCallback ~= nil then
    --     self._endCallback()
    -- end

    -- if table.nums(self._tData._tAwards) > 0 then
    --     self._layer:showWidgetByName("Image_Title1_Bg", true)
    --     self._layer:showWidgetByName("Label_desc", true)
    --     self._layer:showWidgetByName("Image_Title2_Bg", false)
    --     self._layer:showWidgetByName("Panel_Awards", false)

    --     local actDelay = CCDelayTime:create(0.5)
    --     local actCallback = CCCallFunc:create(function()
    --         self._layer:showWidgetByName("Image_Title2_Bg", true)
    --         self._layer:showWidgetByName("Panel_Awards", true)
    --         if self._endCallback ~= nil then
    --             self._endCallback()
    --         end
    --     end)
    --     self._layer:runAction(CCSequence:createWithTwoActions(actDelay, actCallback))
    -- end

    local nCurPosX = self._layer:getPositionX()
    local nCurPosY = self._layer:getPositionY()
    local nOffsetY = 90
    self._layer:setPositionY(nCurPosY - nOffsetY)
    local actMoveTo = CCMoveTo:create(0.1, ccp(nCurPosX, nCurPosY))
    local actCallback = CCCallFunc:create(function()
        if self._endCallback ~= nil then
            self._endCallback()
        end
    end)
    self._layer:runAction(CCSequence:createWithTwoActions(actMoveTo, actCallback))
end


function ExDungeonLayer:onExit()
    self:setNodeEventEnabled(false)
end




return ExDungeonLayer
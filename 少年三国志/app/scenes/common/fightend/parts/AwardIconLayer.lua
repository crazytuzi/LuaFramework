
local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"


local AwardIconLayer = class ("AwardIconLayer", function() return display.newNode() end)
local Colors = require("app.setting.Colors")
local BattleGuideFunction = require("app.scenes.common.fightend.BattleGuideFunction")

local KnightPic = require("app.scenes.common.KnightPic")
require("app.cfg.battle_guide_info")
function AwardIconLayer:ctor(tData, endCallback)
    self._tData = tData
    self._endCallback =  endCallback

    self:setNodeEventEnabled(true)

    self._layer =  UFCCSNormalLayer.new("ui_layout/fightend_FightEndAwardIcon.json")
    self._layer:setClickSwallow(true)
    local size = self._layer:getRootWidget():getContentSize()
    self._layer:setPosition(ccp(0, -size.height/2 - 38))
    self:addChild(self._layer)

    self._layer:setCascadeOpacityEnabled(true)

    if rawget(self._tData.tAward, "type") then
        self._layer:showWidgetByName("Panel_HasAward", true)
        self._layer:showWidgetByName("Panel_HasNoAward", false)

        local tAward = self._tData.tAward
        local tGoods = G_Goods.convert(tAward.type, tAward.value, tAward.size)
        assert(tGoods)

        local labelTmpl = self._layer:getLabelByName("Label_desc")
        local tRichText = G_GlobalFunc.createRichTextSingleRow(labelTmpl)
        local szContent = G_lang:get("LANG_HERO_SOUL_GONGXI_GET", {namecolor = Colors.qualityDecColors[tGoods.quality], name=tGoods.name or ""})
        tRichText:clearRichElement()
        tRichText:appendContent(szContent, ccc3(255, 255, 255))
        tRichText:reloadData()

        self:_initGoods(1, tGoods)
    else
        self._layer:showWidgetByName("Panel_HasAward", false)
        self._layer:showWidgetByName("Panel_HasNoAward", true)
    end
end

function AwardIconLayer:_initGoods(nIndex, tGoods)
    local imgIcon = self._layer:getImageViewByName("Image_Icon"..nIndex)
    if imgIcon then
        imgIcon:loadTexture(tGoods.icon, UI_TEX_TYPE_LOCAL)
    end    
    local imgQualityFrame = self._layer:getImageViewByName("Image_QualityFrame"..nIndex)
    if imgQualityFrame then
        imgQualityFrame:loadTexture(G_Path.getEquipColorImage(tGoods.quality, tGoods.type))
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

function AwardIconLayer:play(   )
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


function AwardIconLayer:onExit()
    self:setNodeEventEnabled(false)
end




return AwardIconLayer
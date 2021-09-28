
local LegionTechUpdateLayer = class("LegionTechUpdateLayer", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
local LegionConst = require("app.const.LegionConst")
require("app.cfg.corps_technology_info")

function LegionTechUpdateLayer:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self:setClickClose(true)

    self._icon = self:getImageViewByName("Image_icon")
    self._pinji = self:getImageViewByName("Image_pinji")
    self._titleImg = self:getImageViewByName("Image_title")
    self._nameLabel = self:getLabelByName("Label_name")
    self._nameLabel:createStroke(Colors.strokeBrown, 1)
    self._levelLabel = self:getLabelByName("Label_level")
    self._levelLabel:createStroke(Colors.strokeBrown, 1)
    self._levelValueLabel = self:getLabelByName("Label_levelValue")
    self._levelValueLabel:createStroke(Colors.strokeBrown, 1)
    self._curLabel = self:getLabelByName("Label_curValue")
    self._nextLabel = self:getLabelByName("Label_nextValue")
    self._needLabel = self:getLabelByName("Label_needLevel")
    self._needLevelLabel = self:getLabelByName("Label_needLevelValue")
    self._costLabel = self:getLabelByName("Label_cost")
    self._costValueLabel = self:getLabelByName("Label_costValue")
    self._learnImg = self:getImageViewByName("Image_tech")
    self._descLabel = self:getLabelByName("Label_desc")
end

function LegionTechUpdateLayer.create(id,_type,...)
    local layer = LegionTechUpdateLayer.new("ui_layout/legion_TechUpdateLayer.json",require("app.setting.Colors").modelColor,...) 
    layer:updateView(id,_type)
    return layer
end

function LegionTechUpdateLayer:_onRefresh(  )
    self:updateView(self._id,self._type)
end

function LegionTechUpdateLayer:updateView( id,_type )
    self._id = id 
    self._type = _type

    local learnLevel = G_Me.legionData:getTechLearnLevel(id)
    local developLevel = G_Me.legionData:getTechDevelopLevel(id)
    local level = {learnLevel,developLevel}
    local info = corps_technology_info.get(id,level[_type])
    local nextInfo = corps_technology_info.get(id,level[_type]+1)

    local baseInfo = info and info or nextInfo
    local gray1 = _type == LegionConst.LearnType.LEARN and developLevel == 0 
    local gray2 = _type == LegionConst.LearnType.DEVELOP and corps_technology_info.get(id,1).require_corpslevel > G_Me.legionData:getCorpDetail().level
    local gray = gray1 or gray2
    self._icon:loadTexture(G_Path.getLegionTechIcon(baseInfo.icon))
    self._icon:showAsGray(gray)
    self._pinji:loadTexture(G_Path.getEquipColorImage(baseInfo.quality))
    self._pinji:showAsGray(gray)
    self._nameLabel:setText(baseInfo.name)
    local levelTxt = _type == LegionConst.LearnType.LEARN and learnLevel.."/"..developLevel or levelTxt or G_lang:get("LANG_LEGION_TECH_DENGJI",{level=level[_type]})
    levelTxt = level[_type] > 0 and levelTxt or G_lang:get("LANG_LEGION_TECH_HAS_CLOSED".._type)
    self._levelValueLabel:setText(levelTxt)    
    self._levelValueLabel:setColor(level[_type] > 0 and Colors.darkColors.DESCRIPTION or Colors.darkColors.TIPS_01)
    self._levelLabel:setText(G_lang:get("LANG_LEGION_TECH_LEVEL_DESC".._type))
    self._curLabel:setText(G_Me.legionData:getTechTxt(id,level[_type],_type))
    self._nextLabel:setText(G_Me.legionData:getTechTxt(id,level[_type]+1,_type))
    local learnCost = corps_technology_info.get(id,learnLevel+1) and corps_technology_info.get(id,learnLevel+1).learn_cost_size or 0
    local developCost = corps_technology_info.get(id,developLevel+1) and corps_technology_info.get(id,developLevel+1).corpsexp_cost or 0
    local cost = _type == LegionConst.LearnType.LEARN and learnCost or developCost
    local costTxt = G_lang:get("LANG_LEGION_TECH_EXP".._type,{exp=cost})
    self._costValueLabel:setText(costTxt)
    local enough = (_type == LegionConst.LearnType.LEARN and (G_Me.userData.corp_point >= cost)) or (_type == LegionConst.LearnType.DEVELOP and (G_Me.legionData:getCorpDetail().exp >= cost))
    -- local costColor = enough and Colors.lightColors.DESCRIPTION or Colors.lightColors.TIPS_01
    -- self._costValueLabel:setColor(costColor)
    local needLevel = corps_technology_info.get(id,developLevel+1) and corps_technology_info.get(id,developLevel+1).require_corpslevel or 0
    self._needLevelLabel:setText(needLevel)
    self._needLabel:setVisible(_type == LegionConst.LearnType.DEVELOP)
    self._needLevelLabel:setVisible(_type == LegionConst.LearnType.DEVELOP)
    -- local needColor = G_Me.legionData:getCorpDetail().level >= needLevel and Colors.lightColors.DESCRIPTION or Colors.lightColors.TIPS_01
    -- self._needLevelLabel:setColor(needColor)
    self._descLabel:setText(baseInfo.description)
end

function LegionTechUpdateLayer:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CORP_TECH_BROADCAST, self._onRefresh, self)

    EffectSingleMoving.run(self:getImageViewByName("Image_click"), "smoving_wait", nil , {position = true} )
end

return LegionTechUpdateLayer
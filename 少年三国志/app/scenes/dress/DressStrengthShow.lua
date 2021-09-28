
local DressStrengthShow = class("DressStrengthShow", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
require("app.cfg.dress_info")

function DressStrengthShow:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self:setClickClose(true)
    self._id = 1
end

function DressStrengthShow.create(dress,...)
    local layer = DressStrengthShow.new("ui_layout/dress_StrengthShow.json",require("app.setting.Colors").modelColor,...) 
    layer:setDress(dress)
    return layer
end

function DressStrengthShow:setDress(dress)
    self._dress = dress
end

function DressStrengthShow:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")
    EffectSingleMoving.run(self:getImageViewByName("Image_jixu"), "smoving_wait", nil , {position = true} )
    self:updateView()

    -- 当前强化等级说明
    -- self:getLabelByName("Label_Curr_Level_Tag"):createStroke(Colors.strokeBrown, 1)
    self._currLevelLabel = self:getLabelByName("Label_Curr_Level")
    -- self._currLevelLabel:createStroke(Colors.strokeBrown, 1)
    self._currLevelLabel:setText(self._dress.level .. " " .. G_lang:get("LANG_FIGHTEND_GONGXI_AFTER"))
end

function DressStrengthShow:updateView()
    local info = dress_info.get(self._dress.base_id)
    for i = 1 , 6 do
        local label = self:getLabelByName("Label_txt"..i)
        local skillId = info["passive_skill_"..i]
        if skillId > 0 then
            local skillInfo = passive_skill_info.get(skillId)
            local str = "["..skillInfo.name.."]  "..skillInfo.directions
            label:setText(str)
            label:setColor(self._dress.level >= info["strength_level_"..i] and Colors.activeSkill or Colors.inActiveSkill)
        end
    end
end

return DressStrengthShow


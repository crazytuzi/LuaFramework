
local SpecialActivityAllAward = class("SpecialActivityAllAward", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function SpecialActivityAllAward:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self:setClickClose(true)

    local label = self:getLabelByName("Label_info")
    label:setVisible(false)
    local size = label:getSize()
    local clr = label:getColor()
    self._labelClr = ccc3(clr.r, clr.g, clr.b)
    self._richText = CCSRichText:create(size.width+60, size.height+25)
    self._richText:setFontName(label:getFontName())
    self._richText:setFontSize(label:getFontSize())
    local x, y = label:getPosition()
    self._richText:setPosition(ccp(x+20, y))
    self._richText:setShowTextFromTop(true)
    local parent = label:getParent()
    if parent then
        parent:addChild(self._richText, 5)
    end
end

function SpecialActivityAllAward.create(...)
    local layer = SpecialActivityAllAward.new("ui_layout/specialActivity_AllAward.json",require("app.setting.Colors").modelColor,...) 
    return layer
end


function SpecialActivityAllAward:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")
    EffectSingleMoving.run(self:getImageViewByName("Image_close"), "smoving_wait", nil , {position = true} )

    -- self:getLabelByName("Label_time"):setText(G_lang:get("LANG_SPECIAL_ACTIVITY_ENDTIME"))
    self:getLabelByName("Label_time"):setText(G_Me.specialActivityData:getTotalEndTime())
    -- self:getLabelByName("Label_info"):setText(G_lang:get("LANG_SPECIAL_ACTIVITY_ALLAWARD_TXT"))
    self._richText:clearRichElement()
    self._richText:appendContent(G_lang:get("LANG_SPECIAL_ACTIVITY_ALLAWARD_TXT"), self._labelClr)
    self._richText:reloadData()
end


return SpecialActivityAllAward


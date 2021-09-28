
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")

local RebelBossBattleBuffLayer = class("RebelBossBattleBuffLayer", UFCCSNormalLayer)

function RebelBossBattleBuffLayer.create(...)
	return RebelBossBattleBuffLayer.new("ui_layout/moshen_RebelBossBattleBuffLayer.json", nil, ...)
end

function RebelBossBattleBuffLayer:ctor(json, param, ...)
	self.super.ctor(self, json, param, ...)
	self:_initWidgets()
end

function RebelBossBattleBuffLayer:_initWidgets()
    self:updateDamage(0)
end

function RebelBossBattleBuffLayer:updateDamage(damage)
    if type(damage) ~= "number" or damage < 0 then
        return
    end
    CommonFunc._updateLabel(self, "Label_buffdes1", {text=G_lang:get("LANG_REBEL_BOSS_HARM_BUFF")})
    CommonFunc._updateLabel(self, "Label_buffdes2", {text=G_lang:get("LANG_REBEL_BOSS_HONOR_BUFF")})

    CommonFunc._updateLabel(self, "Label_HarmValue", {text=G_GlobalFunc.ConvertNumToCharacter(damage), stroke=Colors.strokeBrown})
    CommonFunc._updateLabel(self, "Label_HonorValue", {text=math.floor(damage / 10000), stroke=Colors.strokeBrown})

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_buffdes1'),
        self:getLabelByName('Label_HarmValue'),
    }, "L")
    self:getLabelByName('Label_buffdes1'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_HarmValue'):setPositionXY(alignFunc(2))   

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_buffdes2'),
        self:getLabelByName('Label_HonorValue'),
    }, "L")
    self:getLabelByName('Label_buffdes2'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_HonorValue'):setPositionXY(alignFunc(2))   
end


return RebelBossBattleBuffLayer

local RichItemLayer = class("RichItemLayer", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
require("app.cfg.richman_info")

function RichItemLayer:ctor(json,color,index,...)
    self.super.ctor(self,json,color,...)
    self._index = index
    self:showAtCenter(true)
    self:setClickClose(true)
end

function RichItemLayer.create(index,...)
    local layer = RichItemLayer.new("ui_layout/dafuweng_ItemCell.json",require("app.setting.Colors").modelColor,index,...) 
    return layer
end

function RichItemLayer:updateView()
    local info = richman_info.get(self._index)
    local titleImg = self:getImageViewByName("Image_title") 
    local itemImg = self:getImageViewByName("Image_item") 
    local label = self:getLabelByName("Label_txt") 
    label:setText(self:getInfo(info))
    titleImg:loadTexture(self:getImg(info))
    itemImg:loadTexture(info.icon)
end

function RichItemLayer:getImg(info )
    if info.square_type == 1 then
        return "ui/text/txt-title/yinliangge.png"
    elseif info.square_type == 2 then
        return "ui/text/txt-title/daojuge.png"
    elseif info.square_type == 3 then
        return "ui/text/txt-title/shijiange.png"
    elseif info.square_type == 4 then
        return "ui/text/txt-title/shangdiange.png"
    elseif info.square_type == 5 then
        return "ui/text/txt-title/yidongge.png"
    else
        return nil
    end
end

function RichItemLayer:getInfo(info )
    if info.square_type == 1 then
        return G_lang:getByString(info.info,{num1=G_GlobalFunc.ConvertNumToCharacter3(info.min_size),
            num2=G_GlobalFunc.ConvertNumToCharacter2(info.max_size)})
    elseif info.square_type == 2 then
        local g = G_Goods.convert(info.type,info.value)
        return G_lang:getByString(info.info,{name=g.name,num1=G_GlobalFunc.ConvertNumToCharacter3(info.min_size),
            num2=G_GlobalFunc.ConvertNumToCharacter2(info.max_size)})
    elseif info.square_type == 3 then
        return info.info
    else
        return info.info
    end
end

function RichItemLayer:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")
    EffectSingleMoving.run(self:getImageViewByName("Image_jixu"), "smoving_wait", nil , {position = true} )

    self:updateView()
end

function RichItemLayer:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

return RichItemLayer



local DressRebirthShow = class("DressRebirthShow", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
require("app.cfg.dress_info")

function DressRebirthShow:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    -- self:setClickClose(true)
    self._nameLabel = self:getLabelByName("Label_name")
    self._label1 = self:getLabelByName("Label_txt1")
    self._label2 = self:getLabelByName("Label_txt2")
    self._costLabel = self:getLabelByName("Label_cost")
    self._costNumLabel = self:getLabelByName("Label_costNum")
    self._nameLabel:createStroke(Colors.strokeBrown, 1)
    self._label1:createStroke(Colors.strokeBrown, 1)
    self._label2:createStroke(Colors.strokeBrown, 1)
    self._costLabel:createStroke(Colors.strokeBrown, 1)
    self._costNumLabel:createStroke(Colors.strokeBrown, 1)
    self._awardPanel = self:getPanelByName("Panel_award")

    self._goldCost = 200
    self._costNumLabel:setText(self._goldCost )

    self:registerBtnClickEvent("Button_ok", function()
        G_HandlersManager.dressHandler:sendRecycleDress(self._dress.id,0)
        self:close()
    end)
    self:registerBtnClickEvent("Button_cancel", function()
        self:close()
    end)
end

function DressRebirthShow.create(dress,data,...)
    local layer = DressRebirthShow.new("ui_layout/dress_RebirthShow.json",require("app.setting.Colors").modelColor,...) 
    layer:setData(dress,data)
    return layer
end

function DressRebirthShow:setData(dress,data)
    self._data = data
    self._dress = dress
    self:updateView()
end

function DressRebirthShow:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")
    self:updateView()
end

function DressRebirthShow:updateView()
    dump(self._data)
    local info = G_Me.dressData:getDressInfo(self._dress.base_id) 
    self._nameLabel:setText(info.name)
    self._nameLabel:setColor(Colors.qualityColors[info.quality])

    GlobalFunc.createIconInPanel({panel=self._awardPanel,award=self._data,click=true,name=true,offset=10,left=true,numType=4})
end


function DressRebirthShow:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

return DressRebirthShow


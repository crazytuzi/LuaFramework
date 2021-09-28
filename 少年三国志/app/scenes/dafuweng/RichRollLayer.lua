
local RichRollLayer = class("RichRollLayer", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function RichRollLayer:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)

    self:registerBtnClickEvent("Button_touzi1", function()
        self:click(1)
    end)
    self:registerBtnClickEvent("Button_touzi2", function()
        self:click(2)
    end)
    self:registerBtnClickEvent("Button_touzi3", function()
        self:click(3)
    end)
    self:registerBtnClickEvent("Button_touzi4", function()
        self:click(4)
    end)
    self:registerBtnClickEvent("Button_touzi5", function()
        self:click(5)
    end)
    self:registerBtnClickEvent("Button_touzi6", function()
        self:click(6)
    end)
    self:registerBtnClickEvent("Button_close", function()
        self:animationToClose()
    end)
end

function RichRollLayer:click(index)
    self:checkShop(function ( )
        if G_Me.richData:getState() == 3 then
            G_MovingTip:showMovingTip(G_lang:get("LANG_FU_TIMEOUT"))
            self:animationToClose()
            return
        end
        G_HandlersManager.richHandler:sendRichMove(index,1)
        if self._callBack then
            self._callBack()
        end
        self:animationToClose()
    end)
end

function RichRollLayer.create(...)
    local layer = RichRollLayer.new("ui_layout/dafuweng_ChooseTouzi.json",require("app.setting.Colors").modelColor,...) 
    return layer
end

function RichRollLayer:setCallBack(callBack)
    self._callBack = callBack
end

function RichRollLayer:updateView()
    local label = self:getLabelByName("Label_desc") 
    label:setText(G_lang:get("LANG_FU_CLICK"))
    local label2 = self:getLabelByName("Label_left") 
    label2:setText(G_lang:get("LANG_FU_TOUZILEFT",{num=G_Me.richData:getCurTouziNum()}))
end

function RichRollLayer:onLayerEnter()
    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")

    self:updateView()
end

function RichRollLayer:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

function RichRollLayer:checkShop(callBack)
    if G_Me.richData:hasShopLeft() then
        local str = G_lang:get("LANG_FU_SHOPCHECK")
        MessageBoxEx.showYesNoMessage(nil,str,false,function()
            if callBack then
                callBack()
            end
        end,nil,nil,MessageBoxEx.OKNOButton.OKNOBtn_Richman)
    else
        if callBack then
            callBack()
        end
    end
end

return RichRollLayer


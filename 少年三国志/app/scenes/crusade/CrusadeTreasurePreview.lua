
require("app.cfg.drop_info")
require("app.cfg.battlefield_info")


local CrusadeTreasurePreview = class("CrusadeTreasurePreview", UFCCSModelLayer)
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function CrusadeTreasurePreview:ctor(...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self:setClickClose(true)

    self._gateNumLabel = self:getLabelByName("Label_gate")
    self._paidTimesLabel = self:getLabelByName("Label_paidTimes")
    self._freeTimesLabel = self:getLabelByName("Label_freeTimes")
    self._passGateCondLabel = self:getLabelByName("Label_passGateCond")
    self._paidCostLabel = self:getLabelByName("Label_paidCost")

    self._costInfoPanel = self:getPanelByName("Panel_costInfo")
    self._costInfoPanel:setVisible(false)

    self._openButton = self:getButtonByName("Button_open")
    self._openButton:setVisible(false)

    self._gateNumLabel:createStroke(Colors.strokeBrown, 2)
    self._paidCostLabel:createStroke(Colors.strokeBrown, 2)

    self:showTextWithLabel("Label_getGoods", G_lang:get("LANG_CRUSADE_TREASURE_GET_GOODS"))
    self:showTextWithLabel("Label_gate", "")

    self._passGateCondLabel:setText("")
    self._freeTimesLabel:setText("")
  
    self._scrollView = self:getScrollViewByName("ScrollView_itemList")


    self:registerBtnClickEvent("Button_open", function()

        local t = G_Me.crusadeData:getOpenTreasureCost()
        if G_Me.userData.gold < t then
          -- G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_GOLD_NOT_ENOUGH"))
          require("app.scenes.shop.GoldNotEnoughDialog").show()
          return 
        end

        if G_Me.crusadeData:canOpenTreasure() then
            self._openButton:setEnabled(false)
            G_HandlersManager.crusadeHandler:sendGetAward()
        end

    end)
end

function CrusadeTreasurePreview.create(...)
    local layer = CrusadeTreasurePreview.new("ui_layout/crusade_TreasurePreview.json",require("app.setting.Colors").modelColor,...) 
    return layer
end

function CrusadeTreasurePreview:onLayerEnter()

    self:closeAtReturn(true)
    EffectSingleMoving.run(self, "smoving_bounce")

    EffectSingleMoving.run(self:getImageViewByName("Image_close"), "smoving_wait", nil , {position = true} )

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_UPDATE_AWARD_INFO, self._updateTreasureView, self)

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CRUSADE_GET_AWARD, self._onOpenTreasure, self)

    --避免每次都请求
    if G_Me.crusadeData:getDropId() <= 1 then
        G_HandlersManager.crusadeHandler:sendGetAwardInfo()
    else
        self:_updateTreasureView()
    end

end

function CrusadeTreasurePreview:_updateTreasureView(data)
    
    --最后一次开启宝藏后 服务器返回cur_dropId = 0 这时界面还是显示上次的预览
    if G_Me.crusadeData:getDropId() ~= 0 then
        self._scrollView:removeAllChildren()
    end

    self._passGateCondLabel:setText("")
    self._freeTimesLabel:setText("")

    local innerContainer = self._scrollView:getInnerContainer()
    local size = innerContainer:getContentSize()

    local _dropInfo = drop_info.get(G_Me.crusadeData:getDropId())

    --print("---------------------- _updateTreasureView dropid="..G_Me.crusadeData:getDropId())
    --dump(_dropInfo)

    if _dropInfo ~= nil then

        local _list = {}

        local insertFunc = function (list, dropInfo, k, _quality)
            local numSize = dropInfo["max_num_" .. k]
            if dropInfo["min_num_" .. k] ~= dropInfo["max_num_" .. k] then
                numSize = "("..dropInfo["min_num_" .. k].."~"..dropInfo["max_num_" .. k]..")"
            end
            table.insert(list, {type = dropInfo["type_" .. k],value = dropInfo["value_" .. k],
            size = numSize, forceSize=true, maxSize = dropInfo["max_num_" .. k],
            quality = _quality
            })

        end


        for i=1,5 do

            local _type = _dropInfo["type_" .. i]
            local _value = _dropInfo["value_" .. i]

            --需嵌套读取drop表 FIXME
            if  _type == 9 then
               local _inner_dropInfo = drop_info.get(_value)

               for j=1,5 do

                    local _inner_type = _inner_dropInfo["type_" .. j]
                    local _inner_value = _inner_dropInfo["value_" .. j]
                    local _inner_g = G_Goods.convert(_inner_type, _inner_value)
                    --只显示品质大于3的
                    if _inner_g and _inner_g.quality >= 4 then
                        insertFunc(_list, _inner_dropInfo, j, _inner_g.quality)
                    end
                end
            else
                local _g = G_Goods.convert(_type, _value)
                --只显示品质大于3的
                if _g and _g.quality >= 4 then
                    insertFunc(_list, _dropInfo, i, _g.quality)
                end
            end
        end

        local sortFunc = function ( a, b )

            if a.quality ~= b.quality then
                return a.quality > b.quality
            else
                return a.maxSize > b.maxSize
            end
        end


        table.sort(_list, sortFunc)

        local width = 3*(#_list+1)+100*(#_list)
        self._scrollView:setInnerContainerSize(CCSizeMake(width,size.height))
        GlobalFunc.createIconInPanel2({panel=innerContainer,award=_list,click=true,left=true,offset=2})
    end
    
    self._scrollView:jumpToPercentHorizontal(0)

    self._costInfoPanel:setVisible(G_Me.crusadeData:canOpenTreasure() and G_Me.crusadeData:getOpenTreasureCost() > 0)

    self._openButton:setVisible(G_Me.crusadeData:canOpenTreasure())
    self._openButton:setEnabled(true)

    if not G_Me.crusadeData:hasPassStage() then
        self._passGateCondLabel:setText(G_lang:get("LANG_CRUSADE_TREASURE_PASS_COND"))
    elseif not G_Me.crusadeData:canOpenTreasure() then
        self._passGateCondLabel:setText(G_lang:get("LANG_CRUSADE_TREASURE_NO_TIMES"))   
    end

    if G_Me.crusadeData:canOpenTreasureFree()  then
        self._freeTimesLabel:setText(G_lang:get("LANG_CRUSADE_TREASURE_FREE_OPEN"))
    end

    --self._gateNumLabel:setText(G_lang:get("LANG_CRUSADE_GATE_NUM",{num=GlobalFunc.numberToChinese(G_Me.crusadeData:getCurStage())}))
    
    local battlefield = battlefield_info.get(G_Me.crusadeData:getCurStage())
    if battlefield then
        self._gateNumLabel:setText(battlefield.award_name)
    end
    self._paidTimesLabel:setText(G_lang:get("LANG_CRUSADE_TREASURE_PAID_TIMES",{num=G_Me.crusadeData:getLeftOpenTreasureTimes()}))
    
    local cost = G_Me.crusadeData:getOpenTreasureCost()
    self._paidCostLabel:setText(tostring(cost))
    if cost > G_Me.userData.gold then
        self._paidCostLabel:setColor(Colors.darkColors.TIPS_01)
    else
        self._paidCostLabel:setColor(Colors.darkColors.TITLE_01)
    end


end

function CrusadeTreasurePreview:_onOpenTreasure(data)
    if not data or type(data) ~= "table" then
        return
    end

    if rawget(data,"awards") and type(data.awards) then
        local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.awards, function ( ... )
            end)
        uf_sceneManager:getCurScene():addChild(_layer)

    end

end


function CrusadeTreasurePreview:onLayerExit( ... )
    uf_eventManager:removeListenerWithTarget(self)
end

return CrusadeTreasurePreview


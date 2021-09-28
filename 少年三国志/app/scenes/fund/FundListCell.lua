local FundListCell = class("FundListCell",function()
    return CCSItemCellBase:create("ui_layout/fund_fundCell.json")
end)

require("app.cfg.fund_coin_info")
require("app.cfg.fund_number_info")
local Goods = require("app.setting.Goods")

function FundListCell:ctor()
    self._type = 1
    self._getButton = self:getButtonByName("Button_get")
    self._getButtonImg = self:getImageViewByName("Image_8")
    self._gotStat = self:getImageViewByName("Image_get")
    self._gotStat:setVisible(false)

    self._title = self:getLabelByName("Label_title")
    self._des1 = self:getLabelByName("Label_des1")
    self._des2 = self:getLabelByName("Label_des2")
    self._des3 = self:getLabelByName("Label_des3")
    self._title:createStroke(Colors.strokeBrown, 1)
    -- self._des1:createStroke(Colors.strokeBrown, 1)
    -- self._des2:createStroke(Colors.strokeBrown, 1)
    -- self._des3:createStroke(Colors.strokeBrown, 1)

    local EffectNode = require "app.common.effects.EffectNode"
    self.node = EffectNode.new("effect_around2")     
    self.node:setScale(1.4) 
    self._getButton:addNode(self.node)
    self.node:setVisible(false)

    self:registerBtnClickEvent("Button_border", function ( widget )
        if self._info ~= nil and self._type == 2 then
            require("app.scenes.common.dropinfo.DropInfo").show(self._info.type,self._info.value) 
        end
    end)    
    self:registerBtnClickEvent("Button_get", function ( widget )
        if self._func then
            self._func(self._data.id)
        end
        if self._type == 1 then
            G_HandlersManager.fundHandler:sendGetFundAward(self._data.id)
        else
            G_HandlersManager.fundHandler:sendGetFundWeal(self._data.id)
        end
    end)   
    -- self:registerCellClickEvent(function ( cell, index )
    --     if self._type == 1 then
    --         G_HandlersManager.dailytaskHandler:sendFinishDailyMission(self._data.id)
    --     else

    --     end
    -- end) 
end

function FundListCell:updateData(data,type,func)

    self._data = data
    self._type = type
    self._func = func

    if self._type == 1 then
        self:_init1()
    else
        self:_init2()
    end
    
end

function FundListCell:_init1()
    
    self._info = fund_coin_info.get(self._data.id)
    self._title:setText(G_lang:get("LANG_FUND_YUANBAO",{num=self._info.coin_number})) 
    self._des1:setText(G_lang:get("LANG_FUND_LEVEL1"))
    self._des3:setText(G_lang:get("LANG_FUND_LEVEL3"))
    self._des2:setText(G_lang:get("LANG_FUND_LEVEL2",{level = self._info.level}))

    self:_refreshPos()

    local g = Goods.convert(2, 0)
    self:getImageViewByName("Image_icon"):loadTexture(g.icon)
    self:getButtonByName("Button_border"):loadTextureNormal(G_Path.getEquipColorImage(g.quality,g.type))
    self:getButtonByName("Button_border"):loadTexturePressed(G_Path.getEquipColorImage(g.quality,g.type))

    self:_initButton()
end

function FundListCell:_init2()
    
    self._info = fund_number_info.get(self._data.id)
    self._title:setText(self._info.name) 
    self._des1:setText(G_lang:get("LANG_FUND_BUY1"))
    self._des3:setText(G_lang:get("LANG_FUND_BUY3"))
    self._des2:setText(G_lang:get("LANG_FUND_BUY2",{num=self._info.buy_number}))

    self:_refreshPos()

    local g = Goods.convert(self._info.type, self._info.value)
    self:getImageViewByName("Image_icon"):loadTexture(g.icon)
    self:getButtonByName("Button_border"):loadTextureNormal(G_Path.getEquipColorImage(g.quality,g.type))
    self:getButtonByName("Button_border"):loadTexturePressed(G_Path.getEquipColorImage(g.quality,g.type))

    self:_initButton()
end

function FundListCell:_refreshPos()
    local pos1 = ccp(self._des1:getPosition())
    local width1 = self._des1:getContentSize().width
    self._des2:setPosition(ccp(pos1.x+width1+5,pos1.y))
    local pos2 = ccp(self._des2:getPosition())
    local width2 = self._des2:getContentSize().width
    self._des3:setPosition(ccp(pos2.x+width2+5,pos2.y))
end

function FundListCell:_initButton()
    
    if self._data.status == 1 then
        self._getButton:setVisible(true)
        self._getButton:setTouchEnabled(true)
        self._getButtonImg:showAsGray(false)
        self._gotStat:setVisible(false)
    elseif self._data.status == 2 then
        self._getButton:setVisible(true)
        self._getButton:setTouchEnabled(false)
        self._getButtonImg:showAsGray(true)
        self._gotStat:setVisible(false)
    else
        self._getButton:setVisible(false)
        self._gotStat:setVisible(true)
    end

end

function FundListCell:onLayerUnload()
    
    uf_eventManager:removeListenerWithTarget(self)

end

return FundListCell

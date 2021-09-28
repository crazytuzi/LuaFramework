local ShopDropKnightBaseLayer = require("app.scenes.shop.ShopDropKnightBaseLayer")
local BagConst = require("app.const.BagConst")


local ShopDropGodlyKnight20Layer = class("ShopDropGodlyKnight20Layer",function()
    return ShopDropKnightBaseLayer:create()
end)

function ShopDropGodlyKnight20Layer:ctor()
    self.super.ctor(self)
    self:_setWidgets()
    self:_setActivityWidgets()
    self:_initBtnClickEvent()
    self:removeOneButtonToCenter()

    
    self:getLabelByName("Label_curPrice01"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_curPrice02"):createStroke(Colors.strokeBrown,1)
end


function ShopDropGodlyKnight20Layer:removeOneButtonToCenter(isZhanJiang)
    local oneButton = self:getButtonByName("Button_moretime")
    local oneButtonY = oneButton:getPositionY()
    --移到中间
    local centerX = oneButton:getParent():getContentSize().width/2
    oneButton:setPosition(ccp(centerX,oneButtonY))
    self:showWidgetByName("Button_onetime",false)
    self:showWidgetByName("Panel_onetime",false)
    self:showWidgetByName("Panel_moretime",true)
    local panel = self:getWidgetByName("Panel_moretime")
    local size = panel:getContentSize()
    panel:setPosition(ccp(centerX-size.width/2,panel:getPositionY()))

end


function ShopDropGodlyKnight20Layer:_setWidgets()
    --设置背景图
    self.ImgNowMoneyTag:loadTexture(G_Path.getPriceTypeIcon(2),UI_TEX_TYPE_PLIST)
    self.ImgShuaXinToken:loadTexture("icon_shengjiangling.png",UI_TEX_TYPE_PLIST)

    --可招募
    self:showWidgetByName("Panel_kezhaomu_jipin",true)
    self:showWidgetByName("Panel_kezhaomu_liangpin",false)
    --标题
    self.titleImage:loadTexture("ui/text/txt-title/shenjiangzhaomu.png",UI_TEX_TYPE_LOCAL)

    --神将令的文字
    self.tokenTagLabel:setText(G_lang:get("LANG_SHEN_JIANG_LING"))
    self:showWidgetByName("Panel_must_shenjiang",false)
    self:showWidgetByName("Panel_must",false)
    self:showWidgetByName("Panel_20must",true)
    self:setAutoScrollView(2)

    local tokenCount = G_Me.bagData:getGodlyKnightTokenCount()
    if tokenCount >= 20 then
        self.ImgMoreTimeTag:loadTexture("icon_shengjiangling.png",UI_TEX_TYPE_PLIST)
        self.LabelMoreTimeMoney:setText("x 20")
    else
        local isDiscount,discount = G_Me.activityData.custom:isGodlyDropDiscount()
        self:showWidgetByName("Label_curPrice02",isDiscount)
        if isDiscount then
            self:getLabelByName("Label_curPrice02"):setText(BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_20_TIME)
            self.LabelMoreTimeMoney:setText(BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_20_TIME * discount / 1000)
        else

            self.ImgMoreTimeTag:loadTexture("icon_mini_yuanbao.png",UI_TEX_TYPE_PLIST)
            self.LabelMoreTimeMoney:setText("4800")
        end
    end
    self:getImageViewByName("ImageView_3885"):loadTexture(G_Path.getBigBtnTxt("zhaoershici.png"))
end


--经常需要刷新的widgets

function ShopDropGodlyKnight20Layer:_setActivityWidgets()
    --当前gold
    self.LabelNowMoney:setText(G_GlobalFunc.ConvertNumToCharacter(G_Me.userData.gold))
    --当前刷新令
    local tokenCount = G_Me.bagData:getGodlyKnightTokenCount()
    self.LabelShuaxinToken:setText(tokenCount)

end


function ShopDropGodlyKnight20Layer:_initBtnClickEvent()
    self._moreTimeFunc = function()
        if self:checkBagMoreTime(24)== true then
            return
        end
        local tokenCount = G_Me.bagData:getGodlyKnightTokenCount()
        if tokenCount >=20 then
            G_HandlersManager.shopHandler:sendDropGodlyKnight20(BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.TOKEN)
        else
            local isDiscount,discount = G_Me.activityData.custom:isGodlyDropDiscount()
            local price = BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_20_TIME
            if isDiscount then
                price = math.ceil(price * discount / 1000)
            end
            if G_Me.userData.gold < price then
                require("app.scenes.shop.GoldNotEnoughDialog").show()
                return
            end
            G_HandlersManager.shopHandler:sendDropGodlyKnight20(BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.MONEY)
        end
        -- self:close()
        self:animationToClose()
    end
end




return ShopDropGodlyKnight20Layer


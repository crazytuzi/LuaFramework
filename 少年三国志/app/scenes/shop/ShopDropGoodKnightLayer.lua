local ShopDropKnightBaseLayer = require("app.scenes.shop.ShopDropKnightBaseLayer")
local BagConst = require("app.const.BagConst")
local ShopDropGoodKnightLayer = class("ShopDropGoodKnightLayer",function()
    return ShopDropKnightBaseLayer:create()
end)

function ShopDropGoodKnightLayer:ctor()
    --表示是否免费
    self.super.ctor(self)
    self:_setWidgets()
    self:_setActivityWidgets()
    self:_initBtnClickEvent()
    --免费则移动到中间
    local tokenCount = G_Me.bagData:getGoodKnightTokenCount()

    local leftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.lp_free_time)
    self._isFree = leftTime < 0 and G_Me.shopData.dropKnightInfo.lp_free_count < 3

    if self._isFree or (tokenCount>0 and tokenCount<10) then
        self:removeOneButtonToCenter(true)
    end
end

--不变的widgets
function ShopDropGoodKnightLayer:_setWidgets()
    self.ImgNowMoneyTag:loadTexture(G_Path.getPriceTypeIcon(1),UI_TEX_TYPE_PLIST)
    self.ImgShuaXinToken:loadTexture("icon_liangjiangling.png",UI_TEX_TYPE_PLIST)

    --标题  再招8次后，必出五星神将
    self:showWidgetByName("Panel_must_shenjiang",false)
    -- Panel_bottom网上移一点
    local bottomPanel = self:getPanelByName("Panel_bottom")
    bottomPanel:setPosition(ccp(bottomPanel:getPositionX(),bottomPanel:getPositionY()+20))

    --不显示银两了
    self:showWidgetByName("ImageView_currentmoney",false)
    --可招募
    self:showWidgetByName("Panel_kezhaomu_jipin",false)
    self:showWidgetByName("Panel_kezhaomu_liangpin",true)

    --超值标签
    self:showWidgetByName("ImageView_chaozhiTag",false)
    --标题
    self.titleImage:loadTexture("ui/text/txt-title/zhanjiangzhaomu.png",UI_TEX_TYPE_LOCAL)

    for i=1,knight_pack_info.getLength() do
        local v = knight_pack_info.indexOf(i)
        if v.knight_show == 1 then
            self.knightList = v
        end
    end
    --神将令的文字
    self.tokenTagLabel:setText(G_lang:get("LANG_ZHAN_JIANG_LING"))

    self:setAutoScrollView(1)
end

--经常需要刷新的widgets

function ShopDropGoodKnightLayer:_setActivityWidgets()
    --当前银两
    self.LabelNowMoney:setText(G_GlobalFunc.ConvertNumToCharacter(G_Me.userData.money))
    --当前刷新令
    local tokenCount = G_Me.bagData:getGoodKnightTokenCount()
    __LogTag(TAG,"tokenCount = %s",tokenCount)
    self.LabelShuaxinToken:setText(tokenCount)
    --使用刷新令
    self.ImgOneTimeTag:loadTexture("icon_liangjiangling.png",UI_TEX_TYPE_PLIST)
    self.ImgMoreTimeTag:loadTexture("icon_liangjiangling.png",UI_TEX_TYPE_PLIST)
    self.LabelOneTimeMoney:setText("x 1")
    if tokenCount == 0 then
        self.LabelOneTimeMoney:setColor(Colors.darkColors.TIPS_01)
    end
    self.LabelMoreTimeMoney:setText("x 10")
    if tokenCount < 10 then
        self.LabelMoreTimeMoney:setColor(Colors.darkColors.TIPS_01)
    end
    self.ButtonMoreTime:setTouchEnabled(tokenCount>=10)
end

function ShopDropGoodKnightLayer:_initBtnClickEvent()
    self._oneTimeFunc = function()
        require("app.scenes.shop.ShopTools").sendGoodKnightDrop()
        -- self:close()
        self:animationToClose()
    end
    self._moreTimeFunc = function()
        --免费次数是不能点击，所以不需判断
        if self:checkBagMoreTime(12)== true then
            return
        end
        
        local tokenCount = G_Me.bagData:getGoodKnightTokenCount()
        if tokenCount >=10 then
            G_HandlersManager.shopHandler:sendDropGoodKnightTen(BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.TOKEN)
        end
        -- self:close()
        self:animationToClose()
    end
end
return ShopDropGoodKnightLayer


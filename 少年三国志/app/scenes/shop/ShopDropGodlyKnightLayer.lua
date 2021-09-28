local ShopDropKnightBaseLayer = require("app.scenes.shop.ShopDropKnightBaseLayer")
local BagConst = require("app.const.BagConst")


local ShopDropGodlyKnightLayer = class("ShopDropGodlyKnightLayer",function()
    return ShopDropKnightBaseLayer:create()
end)

function ShopDropGodlyKnightLayer:ctor()
    self.super.ctor(self)
    self:_setWidgets()
    self:_setActivityWidgets()
    self:_initBtnClickEvent()
    local leftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.jp_free_time)
    self._isFree = leftTime < 0

    --免费或者则移动到中间
    local tokenCount = G_Me.bagData:getGodlyKnightTokenCount()
    if self._isFree or (tokenCount>0 and tokenCount < 10) then
        self:removeOneButtonToCenter()
    end

    
    self:getLabelByName("Label_curPrice01"):createStroke(Colors.strokeBrown,1)
    self:getLabelByName("Label_curPrice02"):createStroke(Colors.strokeBrown,1)
end

function ShopDropGodlyKnightLayer:_setWidgets()
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

    --标题  再招8次后，必出五星神将

    --[[
        times == 0 新手引导
        times == 1 首刷
        --从0开始算
    ]]
    local times,isCheng = G_Me.shopData:getDropGodlyKnightLeftTime()

    if times == 1 then
        self:showWidgetByName("Panel_must_shenjiang",false)
        self:showWidgetByName("Panel_must",true)
        if isCheng == true then
            self:getLabelByName("Label_must_shenjiang_0"):setText(G_lang:get("LANG_DROP_KNIGHT_CHENG_SE_WU_JIANG"))
            self:getLabelByName("Label_must_shenjiang_0"):setColor(Colors.qualityColors[5])
        else
            self:getLabelByName("Label_must_shenjiang_0"):setText(G_lang:get("LANG_DROP_KNIGHT_ZI_JIANG_YI_SHANG"))
            self:getLabelByName("Label_must_shenjiang_0"):setColor(Colors.qualityColors[4])
        end
    else
        self:showWidgetByName("Panel_must_shenjiang",true)
        self:showWidgetByName("Panel_must",false)
        self.LabelTitleNote:setText(times)
        if isCheng == true then
            self:getLabelByName("Label_6"):setText(G_lang:get("LANG_DROP_KNIGHT_CHENG_SE_WU_JIANG"))
            self:getLabelByName("Label_6"):setColor(Colors.qualityColors[5])
        else
            self:getLabelByName("Label_6"):setColor(Colors.qualityColors[4])
            self:getLabelByName("Label_6"):setText(G_lang:get("LANG_DROP_KNIGHT_ZI_JIANG_YI_SHANG"))
        end
    end
    local knightIdList={}
    
    self:setAutoScrollView(2)
end


--经常需要刷新的widgets

function ShopDropGodlyKnightLayer:_setActivityWidgets()
    --当前gold
    self.LabelNowMoney:setText(G_GlobalFunc.ConvertNumToCharacter(G_Me.userData.gold))
    --当前刷新令
    local tokenCount = G_Me.bagData:getGodlyKnightTokenCount()
    self.LabelShuaxinToken:setText(tokenCount)
    --当前刷新令数量
    if tokenCount == 0 then
        -- self.ImgNowMoneyTag:loadTexture(G_Path.getPriceTypeIcon(2),UI_TEX_TYPE_PLIST)
        self.ImgOneTimeTag:loadTexture(G_Path.getPriceTypeIcon(2),UI_TEX_TYPE_PLIST)
        self.ImgMoreTimeTag:loadTexture(G_Path.getPriceTypeIcon(2),UI_TEX_TYPE_PLIST)
        --一次消耗黄金
        self.LabelOneTimeMoney:setText(BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_PER_TIME)
        --多次的时候
        self.LabelMoreTimeMoney:setText(BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_TEN_TIME)

        local isDiscount,discount = G_Me.activityData.custom:isGodlyDropDiscount()
        --是否有活动
        if isDiscount then
            local newPrice = math.ceil(BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_PER_TIME * discount / 1000)
            
            self.LabelOneTimeMoney:setText(newPrice)

            if G_Me.userData.gold < newPrice then
                self.LabelOneTimeMoney:setColor(Colors.darkColors.TIPS_01)
            end

            self:getLabelByName("Label_curPrice01"):setText(BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_PER_TIME)

            local newPrice02 = math.ceil(BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_TEN_TIME * discount / 1000)

            self:showWidgetByName("Label_curPrice01",true)
            self:showWidgetByName("Label_curPrice02",true)
            self:getLabelByName("Label_curPrice02"):setText(BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_TEN_TIME)

            self.LabelMoreTimeMoney:setText(newPrice02)
        else
            self:showWidgetByName("Label_curPrice01",false)
            self:showWidgetByName("Label_curPrice02",false)
        end
        
        local price = BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_TEN_TIME
        if isDiscount then
            price = math.ceil(price * discount / 1000)
        end 
        if G_Me.userData.gold < price then
            self.LabelMoreTimeMoney:setColor(Colors.darkColors.TIPS_01)
        end
        
    else
        --使用刷新令
        self.ImgOneTimeTag:loadTexture("icon_shengjiangling.png",UI_TEX_TYPE_PLIST)
        self.ImgMoreTimeTag:loadTexture("icon_shengjiangling.png",UI_TEX_TYPE_PLIST)
        self.LabelOneTimeMoney:setText("x 1")
        self.LabelMoreTimeMoney:setText("x 10")
        if tokenCount < 10 then
            self.ButtonMoreTime:setTouchEnabled(false)
        end
    end

end


function ShopDropGodlyKnightLayer:_initBtnClickEvent()
    self._oneTimeFunc = function()
        require("app.scenes.shop.ShopTools").sendGodlyKnightDrop()
        -- self:close()
        self:animationToClose()
    end
    self._moreTimeFunc = function()
        if self:checkBagMoreTime(12)== true then
            return
        end
        
        local tokenCount = G_Me.bagData:getGodlyKnightTokenCount()
        if tokenCount >=10 then
            G_HandlersManager.shopHandler:sendDropGodlyKnightTen(BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.TOKEN)
        else
            local isDiscount,discount = G_Me.activityData.custom:isGodlyDropDiscount()
            local price = BagConst.DROP_KNIGHT_GOLD_CONSUMPTION_TEN_TIME
            if isDiscount then
                price = math.ceil(price * discount / 1000)
            end
            if G_Me.userData.gold < price then
                require("app.scenes.shop.GoldNotEnoughDialog").show()
                return
            end
            G_HandlersManager.shopHandler:sendDropGodlyKnightTen(BagConst.DROP_KNIGHT_CONSUMPTION_TYPE.MONEY)
        end
        -- self:close()
        self:animationToClose()
    end
end




return ShopDropGodlyKnightLayer


-- HeroSoulShopLayer


local function _convertUnit(num)
    if num >= 1000000 and num < 100000000 then
        return math.floor(num / 10000)..G_lang:get("LANG_WAN")
    elseif num >= 100000000 then
        return math.floor(num / 100000000)..G_lang:get("LANG_YI")
    else
        return num
    end
end

require("app.const.ShopType")
require("app.cfg.ksoul_shop_info")

local BagConst = require("app.const.BagConst")

local HeroSoulShopLayer = class("HeroSoulShopLayer", UFCCSNormalLayer)

local MAX_FREE_COUNT = 10

function HeroSoulShopLayer.create(scenePack, ...)
    return HeroSoulShopLayer.new("ui_layout/herosoul_ShopLayer.json", nil, scenePack, ...)
end

function HeroSoulShopLayer:ctor(json, param, scenePack, ...)
    self._scenePack = scenePack

    self._nFreeCount = 0
    self._nPreHeroSoulPoint = G_Me.userData.hero_soul_point

    -- 商品id列表
    self._tIdList = {}
    -- 是否购买的标志, 1表示已购买  0表示未购买
    self._tBugFlagList = {}

    -- 标记进入过商店
    G_Me.heroSoulData:setClickedShop()

    self.super.ctor(self, json, param, ...)

    -- 显示时间的label
    self._labelTime = self:getLabelByName("Label_LeftTime")
    self._labelTimeValue = self:getLabelByName("Label_LeftTime_Value")
    self._labelTime:createStroke(Colors.strokeBrown, 1)
    self._labelTimeValue:createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_desc"):createStroke(Colors.strokeBrown, 1)
end

function HeroSoulShopLayer:onLayerLoad()
    self:_initWidgets()
end

function HeroSoulShopLayer:onLayerEnter()
    self:registerKeypadEvent(true)
    
    -- 关闭主界面上神秘商店的提示
    G_Me.shopData:setShohwSecretShop()
    
    -- 刷新基础信息
    self:updateView()
    
    -- 刷新神魂
    self:updateHeroSoulPoint()
    
    -- 刷新令
    self:updateRefreshCount()
    
    -- 倒计时
    self:updateCountdown(0)
    
    -- 数据没来之前先隐藏item
    self:showWidgetByName("Panel_content", false)
    
    -- 请求商店数据，先不考虑缓存的问题
    G_HandlersManager.heroSoulHandler:sendKsoulShopInfo()
    
    self:_registerEvents()

    self:_showDiscountDesc()
end

function HeroSoulShopLayer:_addTimer()
    -- 开启定时器, 到了刷新的时间戳，发送协议
    self:showLeftTime()
    if not self._tTimer then
        self._tTimer = GlobalFunc.addTimer(1, function(dt)
            self:showLeftTime()
        end)
    end
end

function HeroSoulShopLayer:showLeftTime()
    local nNextTimestamp = G_Me.heroSoulData:getNextTimestamp()
    if nNextTimestamp == 0 then
        return
    end

    local nLeftSeconds = G_ServerTime:getLeftSeconds(nNextTimestamp)
    if nLeftSeconds <= 0 then
        G_HandlersManager.heroSoulHandler:sendKsoulShopInfo()
        self:_removeTimer()
    else
        -- 更新剩余时间显示    
        self._labelTimeValue:setText(G_ServerTime:getLeftSecondsString(nNextTimestamp))

        local alignFunc = G_GlobalFunc.autoAlign(ccp(0, 0), {
            self._labelTime,
            self._labelTimeValue,
        }, "C")
        self._labelTime:setPositionXY(alignFunc(1))
        self._labelTimeValue:setPositionXY(alignFunc(2)) 
    end
end

function HeroSoulShopLayer:_removeTimer()
    if self._tTimer then
        G_GlobalFunc.removeTimer(self._tTimer)
        self._tTimer = nil
    end
end

function HeroSoulShopLayer:onLayerExit()
    G_flyAttribute._clearFlyAttributes()
    self:_removeTimer()
end

function HeroSoulShopLayer:updateView()

    -- "刷新倒计时"
    G_GlobalFunc.updateLabel(self, "Label_countdown_desc", {text=G_lang:get("LANG_SECRET_SHOP_NEXT_REFRESH"), stroke=Colors.strokeBlack})

    
end

function HeroSoulShopLayer:updateCountdown(countdown)

    local minu = countdown%3600;
    local str = string.format("(%02d:%02d:%02d)", math.floor(countdown/3600), math.floor(minu/60), math.floor(minu%60))
    
    -- 刷新时间
end

function HeroSoulShopLayer:updateItems(message)
    self._tIdList = clone(message.id)
    self._tBugFlagList = clone(message.num)

    -- 更新每一项的数据
    for i=1, #message.id do
        self:updateSingleItem(i)
    end
end

function HeroSoulShopLayer:updateSingleItem(nIndex)
    local marketId = self._tIdList[nIndex]

    -- 获取商品数据 ksoul_shop_info
    local mi = ksoul_shop_info.get(marketId)
    assert(mi, "Could not find the market item with id: "..marketId)

    local goods = G_Goods.convert(mi.item_type, mi.item_id, mi.item_num)

    -- 商品名称
    G_GlobalFunc.updateLabel(self, "Label_item_name"..nIndex, {text=goods.name, stroke=Colors.strokeBrown, color=Colors.qualityColors[goods.quality]})

    -- 数量
    G_GlobalFunc.updateLabel(self, "Label_item_amount"..nIndex, {text="x"..mi.item_num, stroke=Colors.strokeBrown, color=Colors.darkColors.DESCRIPTION})

    -- 商品价格类型
    local money = nil

    if mi.price_type == BagConst.PRICE_TYPE.GOLD then
        money = G_Me.userData.gold
        G_GlobalFunc.updateImageView(self, "ImageView_price_type"..nIndex, {texture="icon_mini_yuanbao.png", texType=UI_TEX_TYPE_PLIST})
    elseif mi.price_type == BagConst.PRICE_TYPE.HERO_SOUL_POINT then
        money = G_Me.userData.hero_soul_point
        G_GlobalFunc.updateImageView(self, "ImageView_price_type"..nIndex, {texture="icon_mini_lingyu.png", texType=UI_TEX_TYPE_PLIST})
    end

    
    -- 商品icon
    G_GlobalFunc.updateImageView(self, "ImageView_head"..nIndex, {texture=goods.icon, texType=UI_TEX_TYPE_LOCAL})

    -- 头像现在需要响应事件用来显示详情
    self:getImageViewByName("ImageView_head"..nIndex):setTouchEnabled(true)

    self:registerWidgetClickEvent("ImageView_head"..nIndex, function()
        require("app.scenes.common.dropinfo.DropInfo").show(mi.item_type, mi.item_id)
        -- if mi.type ~= G_Goods.TYPE_HERO_SOUL then
        --     require("app.scenes.common.dropinfo.DropInfo").show(mi.item_type, mi.item_id)
        -- else
        --     G_GlobalFunc.showBaseInfo(mi.item_type, mi.item_id)
        -- end
    end)
    
    -- 背景
    G_GlobalFunc.updateImageView(self, "ImageView_bg"..nIndex, {texture=G_Path.getEquipIconBack(goods.quality), texType=UI_TEX_TYPE_PLIST})
    
    -- 商品品质框
    local imgFrame = self:getImageViewByName("ImageView_headframe"..nIndex)
    if imgFrame then
        imgFrame:loadTexture(G_Path.getEquipColorImage(goods.quality,goods.type))
    end


    -- 优惠
    local isDiscount,discount = G_Me.activityData.custom:isHeroSoulShopDiscount()

    local newPrice = mi.price
    if isDiscount then   --有折扣
        newPrice = math.ceil(newPrice * discount / 1000)
    end

    -- 价格
    G_GlobalFunc.updateLabel(self, "Label_price"..nIndex, {text=newPrice, color=money >= newPrice and Colors.lightColors.DESCRIPTION or Colors.lightColors.TIPS_01})

    -- 按钮状态
    G_GlobalFunc.updateImageView(self, "ImageView_buy"..nIndex, {visible=self._tBugFlagList[nIndex] == 0})
    G_GlobalFunc.updateImageView(self, "ImageView_got"..nIndex, {visible=self._tBugFlagList[nIndex] ~= 0})
    self:getButtonByName("Button_buy"..nIndex):setTouchEnabled(self._tBugFlagList[nIndex] == 0)
    self:getButtonByName("Button_buy"..nIndex):setEnabled(self._tBugFlagList[nIndex] == 0)

    -- 推荐、已上阵、折扣先不要
    self:showWidgetByName("Image_discount"..nIndex, false)
    self:showWidgetByName("Image_inbattle"..nIndex, false)

    -- 该将灵是否需要
    self:_setMarkImg(nIndex, goods, isDiscount)
end


function HeroSoulShopLayer:_updatePriceColor(nIndex)
    local marketId = self._tIdList[nIndex]

    -- 获取商品数据 ksoul_shop_info
    local mi = ksoul_shop_info.get(marketId)
    assert(mi, "Could not find the market item with id: "..marketId)

    local goods = G_Goods.convert(mi.item_type, mi.item_id, mi.item_num)

    -- 商品价格类型
    local money = nil
    if mi.price_type == BagConst.PRICE_TYPE.GOLD then
        money = G_Me.userData.gold
    elseif mi.price_type == BagConst.PRICE_TYPE.HERO_SOUL_POINT then
        money = G_Me.userData.hero_soul_point
    end

    -- 优惠
    local isDiscount,discount = G_Me.activityData.custom:isHeroSoulShopDiscount()

    local newPrice = mi.price
    if isDiscount then
        newPrice = math.ceil(newPrice * discount / 1000)
    end
    -- 价格
    G_GlobalFunc.updateLabel(self, "Label_price"..nIndex, {text=newPrice, color=money >= newPrice and Colors.lightColors.DESCRIPTION or Colors.lightColors.TIPS_01})

    self:_setMarkImg(nIndex, goods, isDiscount)
end

function HeroSoulShopLayer:_setMarkImg(nIndex, goods, isDiscount)
    if goods.type == G_Goods.TYPE_HERO_SOUL then
        if G_Me.heroSoulData:isSoulNeeded(goods.value) then
            self:showWidgetByName("ImageView_suggestion"..nIndex, true)
            if G_Me.heroSoulData:isSoulBadlyNeeded(goods.value) then
                G_GlobalFunc.updateImageView(self, "ImageView_suggestion"..nIndex, {texture="ui/text/txt/jixu.png", texType=UI_TEX_TYPE_LOCAL})
            else
                G_GlobalFunc.updateImageView(self, "ImageView_suggestion"..nIndex, {texture="ui/text/txt/jzcb_xuyao.png", texType=UI_TEX_TYPE_LOCAL})
            end
        else
            if isDiscount then
                G_GlobalFunc.updateImageView(self, "ImageView_suggestion"..nIndex, {texture="ui/text/txt/sc_youhui.png", texType=UI_TEX_TYPE_LOCAL})
                self:showWidgetByName("ImageView_suggestion"..nIndex, false)
            else
                self:showWidgetByName("ImageView_suggestion"..nIndex, false)
            end
        end
    else
        if isDiscount then
            G_GlobalFunc.updateImageView(self, "ImageView_suggestion"..nIndex, {texture="ui/text/txt/sc_youhui.png", texType=UI_TEX_TYPE_LOCAL})
            self:showWidgetByName("ImageView_suggestion"..nIndex, false)
        else
            self:showWidgetByName("ImageView_suggestion"..nIndex, false)
        end
    end
end

function HeroSoulShopLayer:playItemAnimation()
    -- 入场动画
    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_item1"), 
                self:getWidgetByName("Panel_item3"), 
                self:getWidgetByName("Panel_item5")}, true, 0.2, 5, 50)

    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_item2"), 
                self:getWidgetByName("Panel_item4"), 
                self:getWidgetByName("Panel_item6")}, false, 0.2, 5, 50)
end

function HeroSoulShopLayer:updateHeroSoulPoint()
    -- 灵玉
    G_GlobalFunc.updateLabel(self, "Label_Point", {text=G_lang:get("LANG_HERO_SOUL_SHOP_POINT"), stroke=Colors.strokeBrown})
    
    -- 刷新灵玉数量
    if self._nPreHeroSoulPoint == G_Me.userData.hero_soul_point then
        G_GlobalFunc.updateLabel(self, "Label_Point_Num", {text=_convertUnit(G_Me.userData.hero_soul_point), stroke=Colors.strokeBrown})
    else
        self._nPreHeroSoulPoint = G_Me.userData.hero_soul_point
        local label = self:getLabelByName("Label_Point_Num")
        label:stopAllActions()
        label:setScale(1)
        local actSacleTo1 = CCScaleTo:create(0.25, 2)
        local actSacleTo2 = CCScaleTo:create(0.15, 1)
        local actCallback = CCCallFunc:create(function()
            G_GlobalFunc.updateLabel(self, "Label_Point_Num", {text=_convertUnit(G_Me.userData.hero_soul_point)})
        end)
        local arr = CCArray:create()
        arr:addObject(actSacleTo1)
        arr:addObject(actSacleTo2)
        arr:addObject(actCallback)
        local actSeq = CCSequence:create(arr)
        label:runAction(actSeq)
    end
    
end

function HeroSoulShopLayer:updateRefreshCount()
    -- 没有价格一说了，但是不想删除代码，万一加回来呢，万恶的策划
    if true then
        return
    end

    -- 总共刷新次数 - 已刷新次数
    local nPrice = G_GlobalFunc.getPrice(36, G_Me.heroSoulData:getShopRefreshCount() + 1)

    -- 刷新价格
    G_GlobalFunc.updateLabel(self, "Label_Gold", {text=nPrice, stroke=Colors.strokeBrown})

    local alignFunc = G_GlobalFunc.autoAlign(ccp(0, 0), {
        self:getImageViewByName('Image_Gold'),
        self:getLabelByName('Label_Gold'),
    }, "C")
    self:getImageViewByName('Image_Gold'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_Gold'):setPositionXY(alignFunc(2)) 
end

function HeroSoulShopLayer:_initWidgets()
    -- 返回按钮
    self:registerBtnClickEvent("Button_back", function()
        self:_onClickReturn()
    end)

    -- 刷新按钮
    self:registerBtnClickEvent("Button_Refresh", function()
        -- 刷新要花的元宝
        local nPrice = G_GlobalFunc.getPrice(36, G_Me.heroSoulData:getShopRefreshCount() + 1)
        if G_Me.userData.gold >= nPrice then
            -- 发协议刷新
            G_HandlersManager.heroSoulHandler:sendKsoulShopRefresh()
        else
            require("app.scenes.shop.GoldNotEnoughDialog").show()
        end
    end)

    -- 获取灵玉按钮
    self:registerBtnClickEvent("Button_get_essence", function()
        local pack = G_GlobalFunc.sceneToPack("app.scenes.herosoul.HeroSoulShopScene", {self._scenePack})
        local tScene = require("app.scenes.herosoul.HeroSoulScene").new(nil, nil, pack, require("app.const.HeroSoulConst").BAG)
        uf_sceneManager:replaceScene(tScene)
    end)

    self:_registerBuyButtonEvents()
end

function HeroSoulShopLayer:onBackKeyEvent()
    self:_onClickReturn()
    return true
end

function HeroSoulShopLayer:_onClickReturn()
    uf_sceneManager:replaceScene(self._scenePack and G_GlobalFunc.packToScene(self._scenePack) or require("app.scenes.mainscene.MainScene").new())
end

function HeroSoulShopLayer:_registerBuyButtonEvents()
    -- 购买按钮
    for i=1, 6 do
        self:registerBtnClickEvent("Button_buy"..i, function()
            local marketId = self._tIdList[i]
            local mi = ksoul_shop_info.get(marketId)

            local goods = G_Goods.convert(mi.item_type, mi.item_id, mi.item_num)

            local money = nil
            if mi.price_type == BagConst.PRICE_TYPE.GOLD then
                money = G_Me.userData.gold
            elseif mi.price_type == BagConst.PRICE_TYPE.HERO_SOUL_POINT then
                money = G_Me.userData.hero_soul_point
            end

            local newPrice = mi.price
            local isDiscount,discount = G_Me.activityData.custom:isHeroSoulShopDiscount()
            if isDiscount then   --有折扣
                newPrice = math.ceil(newPrice * discount / 1000)
            end

            -- 价格不足以购买则返回
            if money < newPrice then
                if mi.price_type == BagConst.PRICE_TYPE.HERO_SOUL_POINT then
                    require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_HERO_SOUL_POINT, 0,
                    GlobalFunc.sceneToPack("app.scenes.herosoul.HeroSoulShopScene", {self._scenePack}) )
                elseif mi.price_type == BagConst.PRICE_TYPE.GOLD then
                    require("app.scenes.shop.GoldNotEnoughDialog").show()
                else
                    assert(false, "Unknown price type: "..mi.price_type)
                end
                return
            end

            -- 用元宝购买要提示
            if mi.price_type == BagConst.PRICE_TYPE.GOLD then
                -- 元宝购买提示
                self:getButtonByName("Button_buy" .. i):setEnabled(false)
                local layer = require("app.scenes.common.CommonGoldConfirmLayer").create(goods, newPrice, function(_layer)
                    _layer:animationToClose()
                    -- 发送购买按钮
                    G_HandlersManager.heroSoulHandler:sendKsoulShopBuy(self._tIdList[i])
                    -- 关闭按钮避免连续点击出错
                    self:getButtonByName("Button_buy"..i):setEnabled(false)
                
                end, function()
                    -- cancel回调 
                    self:getButtonByName("Button_buy" .. i):setEnabled(true)
                end)
                uf_sceneManager:getCurScene():addChild(layer)
            else
                -- 发送购买按钮
                G_HandlersManager.heroSoulHandler:sendKsoulShopBuy(self._tIdList[i])
                -- 关闭按钮避免连续点击出错
                self:getButtonByName("Button_buy"..i):setEnabled(false)
            end
        end)
    end
end

function HeroSoulShopLayer:_onRefreshSucc(message)
    G_MovingTip:showMovingTip(G_lang:get("LANG_SECRET_SHOP_REFRESH_SUCCESS"))
end

function HeroSoulShopLayer:_registerEvents()
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_GET_SHOP_INFO_SUCC, self._onGetShopInfoSucc, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_REFRESH_SUCC, self._onRefreshSucc, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_HERO_SOUL_BUY_SUCC, self._onBuySucc, self)
end

function HeroSoulShopLayer:_onBuySucc(data)
    if data.ret == NetMsg_ERROR.RET_OK then
        self._tBugFlagList[data.index] = 1

        local mi = ksoul_shop_info.get(data.id)
        assert(mi)

        local goods = G_Goods.convert(mi.item_type, mi.item_id)
        G_flyAttribute.addNormalText(G_lang:get("LANG_SECRET_SHOP_BUY_SUCCESS_DESC1"), Colors.getColor(5))
        G_flyAttribute.doAddRichtext(G_lang:get("LANG_SECRET_SHOP_BUY_SUCCESS_DESC2", {color=Colors.getRichTextValue(Colors.getColor(goods.quality)), name=goods.name}))
        G_flyAttribute.play()

        -- 开启按钮响应
        self:getButtonByName("Button_buy"..data.index):setTouchEnabled(false) 
        
        -- 更新神魂
        self:updateHeroSoulPoint()
        
        -- 更新单个商品
        self:updateSingleItem(data.index)
        -- 更新其它商品的价格，特别是颜色
        for i=1, 6 do
            self:_updatePriceColor(i)
        end
    else
        MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"), G_NetMsgError.getMsg(data.ret).msg)
    end
end

-- 这里是真正的刷新商品的地方
function HeroSoulShopLayer:_onGetShopInfoSucc(message)
    -- 更新商店项
    -- 先播放动画
    self:playItemAnimation()
    -- 然后显示item
    self:showWidgetByName("Panel_content", true)
    
    self:updateItems(message)

    self:updateRefreshCount()

    self:updateHeroSoulPoint()

    self:_addTimer()
end

-- 折扣的文字提示，如果有折扣的话
function HeroSoulShopLayer:_showDiscountDesc()
    local isDiscount,discount = G_Me.activityData.custom:isHeroSoulShopDiscount()
    if isDiscount then
        if not self._tRTDiscount then
            self._tRTDiscount = G_GlobalFunc.createRichTextSingleRow(self:getLabelByName("Label_DiscountDesc"))
        end

        local nDiscount = 0
        if discount % 100 == 0 then
            nDiscount = string.format("%d", discount/100)
        else
            nDiscount = string.format("%.1f", discount/100)
        end

        local szContent = G_lang:get("LANG_HERO_SOUL_DISCOUNT_DESC", {num=nDiscount})
        self._tRTDiscount:clearRichElement()
        self._tRTDiscount:appendContent(szContent, ccc3(255, 255, 255))
        self._tRTDiscount:reloadData()

        local panelTextDesc = self:getPanelByName("Panel_TextDesc")
        if panelTextDesc then
            panelTextDesc:setPositionY(panelTextDesc:getPositionY() - 20)
        end
    else
        if self._tRTDiscount then
            self._tRTDiscount:removeFromeParentAndCleanup(true)
            self._tRTDiscount = nil
        end
    end
end

return HeroSoulShopLayer

-- SecretShopLayer

local function _updateLabel(target, name, params)
    
    local label = target:getLabelByName(name)
    assert(label, "Could not find the label with name: "..name)
    
    if params.stroke ~= nil then
        label:createStroke(params.stroke, 1)
    end
    
    if params.color ~= nil then
        label:setColor(params.color)
    end
    
    if params.text ~= nil then
        label:setText(params.text)
    end
    
    if params.visible ~= nil then
        label:setVisible(params.visible)
    end
end

local function _updateImageView(target, name, params)
    
    local img = target:getImageViewByName(name)
    assert(img, "Could not find the img with name: "..name)
    
    if params.texture ~= nil then
        img:loadTexture(params.texture, params.texType or UI_TEX_TYPE_LOCAL)
    end
    
    if params.visible ~= nil then
        img:setVisible(params.visible)
    end
end

local ALIGN_CENTER = "align_center"
local ALIGN_LEFT = "align_left"
local ALIGN_RIGHT = "align_right"

-- @basePosition 这里指的是基准点的位置，因为现在只支持居中对齐，所以basePosition指的是中心点的位置
-- @items 需要对齐的子项，是个table
-- @align 对齐方式

local function _autoAlign(basePosition, items, align)
    
    -- 先统计总共的宽度，因为这里居中对齐不需要考虑高度
    local totalWidth = 0
    for i=1, #items do
        totalWidth = totalWidth + items[i]:getContentSize().width
    end
    
    local function _convertToNodePosition(position, item)

        -- print("position.x: "..position.x.." position.y: "..position.y)

        -- 默认是以ccp(0, 0.5)为标准
        local anchorPoint = item:getAnchorPoint()
        return ccp(position.x + anchorPoint.x * item:getContentSize().width, position.y + (anchorPoint.y - 0.5) * item:getContentSize().height)

    end
    
    if align == ALIGN_CENTER then

        -- 然后返回一个函数，用来获取每一项节点的位置（通过index）
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x - totalWidth/2 + _width, 0), items[index])

        end
        
    elseif align == ALIGN_LEFT then
        
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x + _width, 0), items[index])

        end
        
    elseif align == ALIGN_RIGHT then
        
        return function(index)

            assert(index > 0 and index <= #items, "Invalid index: "..index)

            -- 统计下目前为止左边项所占据的宽度
            local _width = 0
            for i=1, index-1 do
                _width = _width + items[i]:getContentSize().width
            end

            -- print("basePosition.x: "..basePosition.x.." basePosition.y: "..basePosition.y)
            -- print("totalWidth: "..totalWidth)
            -- print("_width: ".._width)

            return _convertToNodePosition(ccp(basePosition.x - totalWidth + _width, 0), items[index])

        end

    else
        
        assert(false, "Now we don't support other align type :"..align)
        
    end

end

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
require("app.cfg.market_info")

local BagConst = require("app.const.BagConst")

local SecretShopLayer = class("SecretShopLayer", UFCCSNormalLayer)

local MAX_FREE_COUNT = 10

function SecretShopLayer.create()
    return SecretShopLayer.new("ui_layout/secretshop_Main.json")
end

function SecretShopLayer:ctor(json, param, ...)
    self.super.ctor(self, json, param, ...)

    self._nFreeCount = 0
    self._nPreEssenceCount = G_Me.userData.essence
end

function SecretShopLayer:onLayerEnter()
    
    -- 关闭主界面上神秘商店的提示
    G_Me.shopData:setShohwSecretShop()
    
    -- 刷新基础信息
    self:updateView()
    
    -- 刷新神魂
    self:updateEssence()
    
    -- 刷新令
    self:updateRefreshCount(G_Me.vipData:getData(12).value)
    
    -- 倒计时
    self:updateCountdown(0)
    _updateLabel(self, "Label_free_refresh_countdown", {text=""})
    
    -- 数据没来之前先隐藏item
    self:showWidgetByName("Panel_content", false)
    
    -- 请求商店数据，先不考虑缓存的问题
    G_HandlersManager.shopHandler:sendShopInfo(SHOP_TYPE_SECRET_SHOP)
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_INFO, function(_, message)
        
        -- 更新商店项
        -- 先播放动画
        self:playItemAnimation()
        -- 然后显示item
        self:showWidgetByName("Panel_content", true)
        
        self:updateItems(message)
        
    end, self)
    
    -- 请求刷新次数
    G_HandlersManager.secretShopHandler:sendLeftNumberReq()
    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SECRETSHOP_REFRESH_NUMBER, function(_, message)
        
        self:updateRefreshCount(message.refresh_count, message.free_refresh_count)
        
    end, self)
        
    -- 当前时间，取自服务器
    local curTimeStamp = G_ServerTime:getTime()
    --local curHour = G_ServerTime:getDateObject(curTimeStamp)
    --local curHour = os.date("%H", curTimeStamp)
    
    -- 那么距离下一次刷新的时间还有
    --local curTime = os.date("*t", curTimeStamp)
    local curTime = G_ServerTime:getDateObject(curTimeStamp)
    local nextTimeStamp = os.time({year=curTime.year, month=curTime.month, day=curTime.day, hour=curTime.hour + (curTime.hour % 2 == 0 and 2 or 1), min=0, sec=0})
    local nHour, _, _ = G_ServerTime:getCurrentHHMMSS(nextTimeStamp)
    nHour = (nHour ~= 0) and nHour or 24 
    _updateLabel(self, "Label_countdown", {text=G_lang:get("LANG_SECRET_SHOP_NEXT_REFRESH_TIME", {num=nHour}), stroke=Colors.strokeBlack})

    local alignFunc = _autoAlign(ccp(0, 0), {
        self:getLabelByName('Label_countdown_desc'),
        self:getLabelByName('Label_countdown'),
    }, ALIGN_LEFT)
    self:getLabelByName('Label_countdown_desc'):setPosition(alignFunc(1))
    self:getLabelByName('Label_countdown'):setPosition(alignFunc(2))

    local countdown = nextTimeStamp - curTimeStamp

    -- 开启定时器，每隔一秒钟刷新一次倒计时，隔2小时刷新一次数据
    self._schedule = GlobalFunc.addTimer(1, function(dt)
        
        countdown = math.max(0, countdown - math.floor(dt))

        self:updateCountdown(countdown)
        
        if countdown == 0 then

            countdown = 2*3600

            -- 获取现在的时间戳
            local curTimeStamp = G_ServerTime:getTime()
            local curTime = G_ServerTime:getDateObject(curTimeStamp)
            local nextTimeStamp = os.time({year=curTime.year, month=curTime.month, day=curTime.day, hour=curTime.hour + (curTime.hour % 2 == 0 and 2 or 1), min=0, sec=0})
            local nHour, _, _ = G_ServerTime:getCurrentHHMMSS(nextTimeStamp)
            nHour = (nHour ~= 0) and nHour or 24 
            _updateLabel(self, "Label_countdown", {text=G_lang:get("LANG_SECRET_SHOP_NEXT_REFRESH_TIME", {num=nHour}), stroke=Colors.strokeBlack})

            
            -- 自动刷新数据
        --    G_HandlersManager.shopHandler:sendShopInfo(SHOP_TYPE_SECRET_SHOP)
            -- 请求刷新次数
            G_HandlersManager.secretShopHandler:sendLeftNumberReq()

            --[[
            -- 简单的粒子效果
            local emitter = CCParticleFlower:create()
            self:addChild(emitter)

            local countDown = self:getLabelByName("Label_countdown")
            local position = emitter:getParent():convertToNodeSpace(countDown:convertToWorldSpace(ccp(-countDown:getSize().width/2, 0)))

            emitter:setPosition(position)
            emitter:setTexture(CCTextureCache:sharedTextureCache():addImage("particles/stars.png"))

            local array = CCArray:create()
            array:addObject(CCMoveBy:create(0.7, ccp(countDown:getSize().width, 0)))
            array:addObject(CCDelayTime:create(5))
            array:addObject(CCRemoveSelf:create())

            emitter:runAction(CCSequence:create(array))
            emitter:setDuration(0.7)
            ]]
        end

    end)
    
end

function SecretShopLayer:onLayerExit()
    
    uf_eventManager:removeListenerWithTarget(self)
    
    if self._schedule then
        GlobalFunc.removeTimer(self._schedule)
    end
    
end

function SecretShopLayer:updateView()

    -- "刷新倒计时"
    _updateLabel(self, "Label_countdown_desc", {text=G_lang:get("LANG_SECRET_SHOP_NEXT_REFRESH"), stroke=Colors.strokeBlack})
    
    -- 使用刷新令或20元宝可以立即刷新商店
    _updateLabel(self, "Label_desc", {text=G_lang:get("LANG_SECRET_SHOP_DESC")})
    
end

function SecretShopLayer:updateCountdown(countdown)

    local minu = countdown%3600;
    local str = string.format("(%02d:%02d:%02d)", math.floor(countdown/3600), math.floor(minu/60), math.floor(minu%60))
    
    -- 刷新时间
    if self._nFreeCount < MAX_FREE_COUNT then
        _updateLabel(self, "Label_free_refresh_countdown", {text=str, stroke=Colors.strokeBlack, color=Colors.darkColors.TIPS_02})
    else
        _updateLabel(self, "Label_free_refresh_countdown", {text=G_lang:get("LANG_RES_FULL_TIP"), color=Colors.darkColors.ATTRIBUTE})
    end
end

function SecretShopLayer:updateItems(message)
    
    -- 更新每一项的数据
    for i=1, #message.id do
        
        local marketId = message.id[i]
        
        -- 获取商品数据
        local mi = market_info.get(marketId)
        assert(mi, "Could not find the market item with id: "..marketId)

        local goods = G_Goods.convert(mi.item_type, mi.item_id, mi.item_num)

        -- 商品名称
        _updateLabel(self, "Label_item_name"..i, {text=goods.name, stroke=Colors.strokeBrown, color=Colors.qualityColors[goods.quality]})

        -- 数量
        _updateLabel(self, "Label_item_amount"..i, {text="x"..mi.item_num, stroke=Colors.strokeBrown, color=Colors.darkColors.DESCRIPTION})

        -- 商品价格类型
        local money = nil

        if mi.price_type == BagConst.PRICE_TYPE.GOLD then
            money = G_Me.userData.gold
            _updateImageView(self, "ImageView_price_type"..i, {texture="icon_mini_yuanbao.png", texType=UI_TEX_TYPE_PLIST})
        elseif mi.price_type == BagConst.PRICE_TYPE.ESSENCE then
            money = G_Me.userData.essence
            _updateImageView(self, "ImageView_price_type"..i, {texture="icon_mini_hunyu.png", texType=UI_TEX_TYPE_PLIST})
        end
        --assert(money, "mi.price_type: "..mi.price_type)
        
        -- 商品icon
        _updateImageView(self, "ImageView_head"..i, {texture=goods.icon, texType=UI_TEX_TYPE_LOCAL})

        -- 头像现在需要响应事件用来显示详情
        self:getImageViewByName("ImageView_head"..i):setTouchEnabled(true)

        self:registerWidgetClickEvent("ImageView_head"..i, function()
            require("app.scenes.common.dropinfo.DropInfo").show(mi.item_type, mi.item_id)
        end)
        
        -- 背景
        _updateImageView(self, "ImageView_bg"..i, {texture=G_Path.getEquipIconBack(goods.quality), texType=UI_TEX_TYPE_PLIST})
        
        -- 商品品质框
        _updateImageView(self, "ImageView_headframe"..i, {texture=G_Path.getEquipColorImage(goods.quality,goods.type), texType=UI_TEX_TYPE_PLIST})
        
        -- 优惠
        local isDiscount,discount = G_Me.activityData.custom:isSecretDiscount()
        
        -- 推荐，优惠和推荐同时只显示一个，优先显示优惠
        self:getImageViewByName("ImageView_suggestion"..i):setVisible(mi.recommend == 1)

        -- 已上阵
        local knightId
        if mi.item_type == G_Goods.TYPE_KNIGHT then
            knightId = mi.item_id
        elseif mi.item_type == G_Goods.TYPE_FRAGMENT then
            local fi = fragment_info.get(mi.item_id)
            if fi then
                knightId = fi.fragment_value
            end
        end
        local isInTeam = false
        if knightId then
            local ki = knight_info.get(knightId)
            if ki and G_Me.formationData:getKnightTeamIdByFragment(ki.advance_code) == 1 then
                isInTeam = true
            end
        end
        if isInTeam then
            self:showWidgetByName("Image_inbattle"..i, true)
            self:showWidgetByName("ImageView_suggestion"..i, false)
        else
            self:showWidgetByName("Image_inbattle"..i, false)
        end

        local newPrice = mi.price
        if isDiscount then   --有折扣
            newPrice = math.ceil(newPrice * discount / 1000)
            self:showWidgetByName("Image_discount"..i,true)
            self:showWidgetByName("Image_inbattle"..i, false)
            self:showWidgetByName("ImageView_suggestion"..i, false)
        else   --无折扣
            self:showWidgetByName("Image_discount"..i,false)
        end

        -- 价格
        _updateLabel(self, "Label_price"..i, {text=newPrice, color=money >= newPrice and Colors.lightColors.DESCRIPTION or Colors.lightColors.TIPS_01})

        -- 按钮状态
        _updateImageView(self, "ImageView_buy"..i, {visible=message.num[i] == 0})
        _updateImageView(self, "ImageView_got"..i, {visible=message.num[i] ~= 0})
        self:getButtonByName("Button_buy"..i):setTouchEnabled(message.num[i] == 0)

        -- 购买事件回调
        self:registerBtnClickEvent("Button_buy"..i, function()

            local CheckFunc = require "app.scenes.common.CheckFunc"
            local result, errorMsg = CheckFunc.checkBagFullByType(mi.item_type)

            if result then
                --弹出回收弹窗,不需要弹文字提示了
                --G_MovingTip:showMovingTip(errorMsg)
                return
            end
            
            -- 价格不足以购买则返回
            if money < newPrice then
    --            MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"), G_NetMsgError.getMsg(mi.price_type == BagConst.PRICE_TYPE.GOLD and NetMsg_ERROR.RET_NOT_ENOUGH_GOLD or NetMsg_ERROR.RET_NOT_ENOUGH_ESSENCE))
                if mi.price_type == BagConst.PRICE_TYPE.ESSENCE then
                    --G_MovingTip:showMovingTip(G_lang:get("LANG_SECRET_SHOP_NOT_ENOUGH_ESSENCE"))
                    require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_WUHUN, 0,
                    GlobalFunc.sceneToPack("app.scenes.secretshop.SecretShopScene") )
                elseif mi.price_type == BagConst.PRICE_TYPE.GOLD then
    --                G_MovingTip:showMovingTip(G_lang:get("LANG_SECRET_SHOP_NOT_ENOUGH_MONEY"))
                    require("app.scenes.shop.GoldNotEnoughDialog").show()
                else
                    assert(false, "Unknown price type: "..mi.price_type)
                end
                return
            end
            
            local function _onBuyResultEvent(_, data)

                if data.ret == NetMsg_ERROR.RET_OK then
                    
                    local goods = G_Goods.convert(mi.item_type, mi.item_id)
                    G_flyAttribute.addNormalText(G_lang:get("LANG_SECRET_SHOP_BUY_SUCCESS_DESC1"), Colors.getColor(5))
                    G_flyAttribute.doAddRichtext(G_lang:get("LANG_SECRET_SHOP_BUY_SUCCESS_DESC2", {color=Colors.getRichTextValue(Colors.getColor(goods.quality)), name=goods.name}))
                    G_flyAttribute.play()

                    -- 开启按钮响应
                    self:getButtonByName("Button_buy"..data.index):setEnabled(true)
                    self:getButtonByName("Button_buy"..data.index):setTouchEnabled(false)
                    
                    message.num[data.index] = 1
                    
                    -- 更新神魂
                    self:updateEssence()
                    
                    self:updateItems(message)
                    
                else
                    MessageBoxEx.showOkMessage(G_lang:get("LANG_TIPS"), G_NetMsgError.getMsg(data.ret).msg)
                end
                
                uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT)
                
            end
            
            -- 用元宝购买要提示
            if mi.price_type == BagConst.PRICE_TYPE.GOLD then

                -- 元宝购买提示
                self:getButtonByName("Button_buy" .. i):setEnabled(false)
                local layer = require("app.scenes.common.CommonGoldConfirmLayer").create(goods, newPrice, function(_layer)
                    
                    _layer:animationToClose()
                    -- 发送购买按钮
                    G_HandlersManager.shopHandler:sendBuyItem(SHOP_TYPE_SECRET_SHOP, message.id[i], 1, i)
                    -- 关闭按钮避免连续点击出错
                    self:getButtonByName("Button_buy"..i):setEnabled(false)
                    
                    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, _onBuyResultEvent, self)
                end, function()
                    -- cancel回调 
                    self:getButtonByName("Button_buy" .. i):setEnabled(true)
                end)
                
                uf_sceneManager:getCurScene():addChild(layer)
                
            else
                -- 发送购买按钮
                G_HandlersManager.shopHandler:sendBuyItem(SHOP_TYPE_SECRET_SHOP, message.id[i], 1, i)

                -- 关闭按钮避免连续点击出错
                self:getButtonByName("Button_buy"..i):setEnabled(false)
                
                uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, _onBuyResultEvent, self)
                
            end
            
        end)
    end
    
end

function SecretShopLayer:playItemAnimation()
    
    -- 入场动画
    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_item1"), 
                self:getWidgetByName("Panel_item3"), 
                self:getWidgetByName("Panel_item5")}, true, 0.2, 5, 50)

    GlobalFunc.flyIntoScreenLR({self:getWidgetByName("Panel_item2"), 
                self:getWidgetByName("Panel_item4"), 
                self:getWidgetByName("Panel_item6")}, false, 0.2, 5, 50)
    
end

function SecretShopLayer:updateEssence()
    
    -- 将魂
    _updateLabel(self, "Label_essence", {text=G_lang:get("LANG_SECRET_SHOP_ESSENCE"), stroke=Colors.strokeBrown})
    
    -- 刷新将魂数量
    if self._nPreEssenceCount == G_Me.userData.essence then
        _updateLabel(self, "Label_essence_num", {text=_convertUnit(G_Me.userData.essence), stroke=Colors.strokeBrown})
    else
        self._nPreEssenceCount = G_Me.userData.essence
        local label = self:getLabelByName("Label_essence_num")
        label:stopAllActions()
        label:setScale(1)
        local actSacleTo1 = CCScaleTo:create(0.25, 2)
        local actSacleTo2 = CCScaleTo:create(0.15, 1)
        local actCallback = CCCallFunc:create(function()
            _updateLabel(self, "Label_essence_num", {text=_convertUnit(G_Me.userData.essence)})
        end)
        local arr = CCArray:create()
        arr:addObject(actSacleTo1)
        arr:addObject(actSacleTo2)
        arr:addObject(actCallback)
        local actSeq = CCSequence:create(arr)
        label:runAction(actSeq)
    end
    
end

function SecretShopLayer:updateRefreshCount(count, nFreeCount)
    nFreeCount = nFreeCount or 0

    local nPreFreeCount = self._nFreeCount
    self._nFreeCount = nFreeCount

    G_Me.shopData:setSecretShopPreFreeCount(nFreeCount)

--    __Log("-- count = %d, nFreeCount = %d", count, nFreeCount);

    -- 总共刷新次数 - 已刷新次数
    local totalCount = G_Me.vipData:getData(12).value
    local refreshCount = totalCount - count
    assert(refreshCount >= 0, "The refreshCount could not be negative with totalCount: "..totalCount.." and refresh count: "..count)
    
    -- 今日可刷新次数
    _updateLabel(self, "Label_yuanbao_refresh", {text=G_lang:get("LANG_SECRET_YUAUNBAO_REFRESH")})
      
    -- 刷新次数
    _updateLabel(self, "Label_yuanbao_refresh_num", {text=refreshCount})
    _updateLabel(self, "Label_desc_left_time", {text=G_lang:get("LANG_SECRET_SHOP_LEFT_REFRESH_COUNT", {num=refreshCount})})


    -- 动态效果
    if nPreFreeCount ~= self._nFreeCount then
        local label = self:getLabelByName("Label_free_refresh_num")
        if label then
            label:stopActionByTag(100)
            label:setScale(1)

            local array = CCArray:create()
            array:addObject(CCScaleBy:create(0.2, 2))
            array:addObject(CCDelayTime:create(0.1))
            array:addObject(CCScaleBy:create(0.2, 0.5))

            local action = CCSequence:create(array)
            action:setTag(100)
            label:runAction(action)
        end
    end

    -- 判断当前有没有免费刷新次数
    _updateLabel(self, "Label_free_refresh", {text=G_lang:get("LANG_SECRET_SHOP_FREE_REFRESH")})
    _updateLabel(self, "Label_free_refresh_num", {text=nFreeCount .."/"..MAX_FREE_COUNT})

    local alignFunc = _autoAlign(ccp(0, 0), {
        self:getLabelByName('Label_free_refresh'),
        self:getLabelByName('Label_free_refresh_num'),
    }, ALIGN_LEFT)
    
    self:getLabelByName('Label_free_refresh'):setPosition(alignFunc(1))
    self:getLabelByName('Label_free_refresh_num'):setPosition(alignFunc(2))
    
    -- 当前刷新令
    _updateLabel(self, "Label_cur_refresh", {text=G_lang:get("LANG_SECRET_SHOP_CUR_REFRESH")})
    
    -- 刷新令数量
    local itemInfo = G_Me.bagData.propList:getItemByKey(BagConst.ITEM_TYPE.SECRET_SHOP_REFRESH_TOKEN)
    _updateLabel(self, "Label_cur_refresh_num", {text=itemInfo and itemInfo.num or 0})
    
    -- 这里重新排列一下位置
    local alignFunc = _autoAlign(ccp(0, 0), {
        self:getLabelByName('Label_cur_refresh'),
        self:getLabelByName('Label_cur_refresh_num'),
    }, ALIGN_CENTER)
    
    self:getLabelByName('Label_cur_refresh'):setPosition(alignFunc(1))
    self:getLabelByName('Label_cur_refresh_num'):setPosition(alignFunc(2))
    
    local alignFunc = _autoAlign(ccp(0, 0), {
        self:getLabelByName("Label_yuanbao_refresh"),
        self:getLabelByName("Label_yuanbao_refresh_num")
    }, ALIGN_LEFT)
    
    self:getLabelByName("Label_yuanbao_refresh"):setPosition(alignFunc(1))
    self:getLabelByName("Label_yuanbao_refresh_num"):setPosition(alignFunc(2))
    
    -- 刷新按钮
    self:registerBtnClickEvent("Button_Refresh", function()
        -- 先使用免费次数, 免费次数刷新不记入刷新总次数
        if nFreeCount > 0 then
            G_HandlersManager.secretShopHandler:sendRefreshReq(0)
        else
            -- 刷新次数不够
            if refreshCount <= 0 then
    --            G_MovingTip:showMovingTip(G_lang:get("LANG_SECRET_SHOP_VIP_REFRESH_NOT_ENOUGH"))
                G_GlobalFunc.showVipNeedDialog(require("app.const.VipConst").SECRETSHOP)
                return
            end
            
            -- 获取刷新令
            local itemInfo = G_Me.bagData.propList:getItemByKey(BagConst.ITEM_TYPE.SECRET_SHOP_REFRESH_TOKEN)
            
            if itemInfo and itemInfo.num > 0 then 
                G_HandlersManager.secretShopHandler:sendRefreshReq(0)
            elseif (not IS_HEXIE_VERSION) and G_Me.userData.essence >= 20 then
                G_HandlersManager.secretShopHandler:sendRefreshReq(1)
            else
                -- if IS_HEXIE_VERSION then
                --     G_MovingTip:showMovingTip(G_lang:get("LANG_SECRET_SHOP_NOT_ENOUTH_LINGPAI"))
                -- else
                --     require("app.scenes.shop.GoldNotEnoughDialog").show()
                -- end
                require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_WUHUN, 0,
                GlobalFunc.sceneToPack("app.scenes.secretshop.SecretShopScene") )
            end
        end

        -- 接收刷新消息
        uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SECRETSHOP_REFRESH_INFO, function(_, message)

            G_MovingTip:showMovingTip(G_lang:get("LANG_SECRET_SHOP_REFRESH_SUCCESS"))

            local _message = clone(message)
            -- 这里缺失了num，自己模拟一下
            _message.num = rawget(_message, "num") or {0, 0, 0, 0, 0, 0}

            -- 更新商店项
            -- 先播放动画
            self:playItemAnimation()
            self:updateItems(_message)

            -- 更新刷新次数
            self:updateRefreshCount(_message.refresh_count, _message.free_refresh_count)
            
            uf_eventManager:removeListenerWithEvent(self, G_EVENTMSGID.EVENT_SECRETSHOP_REFRESH_INFO)

            self:updateEssence()
        
        end, self)
        
    end)
    
end

return SecretShopLayer

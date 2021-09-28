
local ShopLayer = class("ShopLayer",UFCCSNormalLayer)
local ShopPropItem = require("app.scenes.shop.ShopPropItem")
local CheckFunc = require("app.scenes.common.CheckFunc")
local FunctionLevelConst = require("app.const.FunctionLevelConst")
require("app.cfg.shop_score_info")
require("app.const.ShopType")
local BagConst = require("app.const.BagConst")

--设置选中道具
ShopLayer.ITEM_CHECKED = "CheckBox_prop"
--设置选中礼包
ShopLayer.GIFT_CHECKED = "CheckBox_giftbag"
--显示充值
ShopLayer.RECHARGE_SHOW = "show_recharge"

function ShopLayer.create()
    return ShopLayer.new("ui_layout/shop_ShopLayer.json")
end


function ShopLayer:ctor(...)
    self.super.ctor(self, ...)
    
    if IS_HEXIE_VERSION then 
        self:showWidgetByName("CheckBox_pub", false)
        self:showWidgetByName("Button_recharge", false)
        
        self:callAfterFrameCount(1, function ( ... )
            local widget = self:getWidgetByName("CheckBox_prop")
            if widget then 
                local size = widget:getSize()
                local posx, posy = widget:getPosition()
                widget:setPosition(ccp(posx - size.width, posy))
            end

            widget = self:getWidgetByName("CheckBox_giftbag")
            if widget then 
                local size = widget:getSize()
                local posx, posy = widget:getPosition()
                widget:setPosition(ccp(posx - size.width, posy))
            end
        end)  
    end

    self._checkedName = nil
end

function ShopLayer:_sortTable()
    local sortFunc = function(a,b) 
        local itemA = self._itemList[a]
        local itemB = self._itemList[b]

        local isXianshiA,isSellEnabledA = G_Me.shopData:checkItemXianShiEnabled(itemA)
        local isXianshiB,isSellEnabledB = G_Me.shopData:checkItemXianShiEnabled(itemB)
        local xA = isXianshiA and 1 or 0
        local xB = isXianshiB and 1 or 0
        if xA ~= xB then
            return xA > xB
        end

        local isDiscountA,_ = G_Me.activityData.custom:isItemDiscountById(itemA.id) 
        local isDiscountB,_ = G_Me.activityData.custom:isItemDiscountById(itemB.id) 
        local isActiveA = isDiscountA and 1 or 0
        local isActiveB = isDiscountB and 1 or 0
        if isActiveB ~= isActiveA then
            return isActiveA > isActiveB
        end
        return itemA.arrange < itemB.arrange
    end
    table.sort( self._itemIndex,sortFunc)

    sortFunc = function(a,b) 
            local itemA = self._giftBagList[a]
            local itemB = self._giftBagList[b]
            return itemA.arrange < itemB.arrange
        end
    table.sort( self._giftBagIndex,sortFunc)
end

function ShopLayer:_initListData( ... )
    --商品列表
    self._itemList = {} -- 兑换商品列表
    self._itemIndex = {} --保存索引
    
    self._giftBagList = {} --礼包列表
    self._giftBagIndex = {} --礼包列表
    local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    for i=1, shop_score_info.getLength() do
        local v = shop_score_info.indexOf(i)
        if appstoreVersion and (v.id == 24 or v.id == 25) then
            --越狱封测服的道具
        else
            if v.shop == SCORE_TYPE.VIP then
                if v.tab == 1 then
                    -- 判断出售时间
                    local isXianshi,isSellEnabled = G_Me.shopData:checkItemXianShiEnabled(v)
                    if (isXianshi and isSellEnabled) or (not isXianshi) then
                        if v.show_ban_type == 3 then
                            --vip 等级限制
                            if G_Me.userData.vip >= v.show_ban_value then
                               self._itemList[v.id] = v
                                self._itemIndex[#self._itemIndex+1] = v.id
                            end
                        elseif v.show_ban_type == 2 then
                            --等级限制
                            if G_Me.userData.level >= v.show_ban_value then
                                self._itemList[v.id] = v
                                self._itemIndex[#self._itemIndex+1] = v.id
                            end
                        else
                            self._itemList[v.id] = v
                            self._itemIndex[#self._itemIndex+1] = v.id
                        end
                    end    
                elseif v.tab == 2 then
                    local purchaseEnabled= G_Me.shopData:checkGiftItemPurchaseEnabled(v)
                    if purchaseEnabled == true then
                        if v.show_ban_type == 3 then
                            if G_Me.userData.vip >= v.show_ban_value then
                                self._giftBagList[v.id] = v
                                self._giftBagIndex[#self._giftBagIndex+1] = v.id
                            end
                        elseif v.show_ban_type == 2 then
                            --等级限制
                            if G_Me.userData.level >= v.show_ban_value then
                                self._giftBagList[v.id] = v
                                self._giftBagIndex[#self._giftBagIndex+1] = v.id
                            end
                        else
                            self._giftBagList[v.id] = v
                            self._giftBagIndex[#self._giftBagIndex+1] = v.id
                        end 
                    end
                end
            end
        end
        
    end
    self:_sortTable()
end

function ShopLayer:onLayerEnter(...)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_ITEM_BUY_RESULT, self._getBuyResult, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_KNIGHT_INFO, self._getShopDropKnightInfo, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_INFO, self._getShopInfo, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECHARGE_SUCCESS, self._getRechargeResult, self) 

    --良品抽卡结果，需要刷新一些控件
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_GOOD_KNIGHT, self._getShopDropKnightInfo, self) 
    --极品抽卡结果，需要刷新一些控件
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_GODLY_KNIGHT, self._getShopDropKnightInfo, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_SHOP_DROP_GODLY_KNIGHT_20, self._getShopDropKnightInfo, self)
    -- 限时抽将，隔天了，会有免费次数
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_THEME_DROP_UPDATE_SHOP_TIPS, self._getShopDropKnightInfo, self)
    
    if not G_Me.shopData:checkEnterScoreShop() then
        G_HandlersManager.shopHandler:sendShopInfo(SHOP_TYPE_SCORE)
    else
        self:_initListData()
        self:showWidgetByName("Image_vipTips",CheckFunc.checkVipGiftbagEnabled())

    end
    
    if not G_Me.shopData:checkDropInfo() then

    else
        self:_getShopDropKnightInfo()
    end

end

function ShopLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
end

function ShopLayer:adapterLayer()
    self:adapterWidgetHeight("Panel_alllistview","Panel_topbar","",0,-54)
    self:_init()
    self:_initTextStroke()
end

function ShopLayer:startWithShopVipId( vipId )
    if not vipId then 
        return 
    end
    --判断是否是礼包
    local item = shop_score_info.get(vipId)
    --因为礼包有可能购买过,而不显示
    if item ~= nil and item.tab == 2 then
        self:setCheckStatus(1, "CheckBox_giftbag")
        self:__prepareDataForGuide__(vipId)
    elseif self._itemList ~= nil and self._itemList[vipId] ~= nil then
        self:setCheckStatus(1, "CheckBox_prop")
        self:__prepareDataForGuide__(vipId)
    end
    
end

function ShopLayer:setChecked(name)
    if name == ShopLayer.ITEM_CHECKED then
        self:setCheckStatus(1,ShopLayer.ITEM_CHECKED)
    elseif name == ShopLayer.GIFT_CHECKED then
        self:setCheckStatus(1,ShopLayer.GIFT_CHECKED)
    end
end


function ShopLayer:_init()
    self:addCheckBoxGroupItem(1, "CheckBox_pub")
    self:addCheckBoxGroupItem(1, "CheckBox_prop")
    self:addCheckBoxGroupItem(1, "CheckBox_giftbag")

    self:addCheckNodeWithStatus("CheckBox_pub", "Label_pub_check", true)
    self:addCheckNodeWithStatus("CheckBox_pub", "Label_pub_uncheck", false)

    self:addCheckNodeWithStatus("CheckBox_prop", "Label_shop_check", true)
    self:addCheckNodeWithStatus("CheckBox_prop", "Label_shop_uncheck", false)

    self:addCheckNodeWithStatus("CheckBox_giftbag", "Label_gift_check", true)
    self:addCheckNodeWithStatus("CheckBox_giftbag", "Label_gift_uncheck", false)

    
    self:registerCheckBoxGroupEvent(function(groupId, oldName, newName, widget )
        if groupId == 1 then
            self._checkedName = newName
            if newName == "CheckBox_pub" then   --卡牌
                self:_setPubView()
            elseif newName == "CheckBox_prop" then  -- 装备
                self:_setPropListView()
            elseif newName == "CheckBox_giftbag" then -- 道具
                self:_setGiftBagListView()
            end
        end
    end)

    self:setCheckStatus(1, IS_HEXIE_VERSION and "CheckBox_prop" or "CheckBox_pub")

    self:registerBtnClickEvent("Button_recharge", function ( widget )
        --这段文字不需要加到lang里
        -- G_MovingTip:showMovingTip("充值功能暂未开放")
        require("app.scenes.shop.recharge.RechargeLayer").show()
        -- uf_sceneManager:getCurScene():addChild(layer)   
        -- G_GlobalFunc.showPurchasePowerDialog(1)   
    end)
end

--设置描边
function ShopLayer:_initTextStroke()
    self:getLabelByName("Label_shop_check"):createStroke(Colors.strokeBrown,2)
    self:getLabelByName("Label_pub_check"):createStroke(Colors.strokeBrown,2)
    self:getLabelByName("Label_gift_check"):createStroke(Colors.strokeBrown,2)
end



function ShopLayer:__prepareDataForGuide__(_itemId)
    if not self._propListView then 
        return false
    end
    local item = shop_score_info.get(_itemId)
    if item == nil then
        __Log("invalid itemId:%d", _itemId)
        self._propListView:reloadWithLength(#self._itemIndex,self._propListView:getShowStart())
        return
    end
    __Log("__prepareDataForGuide__:itemId:%d", _itemId)
    local index = 0
    for i,v in ipairs(self._itemIndex) do
        if _itemId == v then
            index = i
        end
    end
    __Log("index=%d", index)
    if index <= 0 then 
        --dump(self._itemIndex)
        return false
    end

    self._propListView:scrollToTopLeftCellIndex(index-1,0,-1,function() end)
    return true
end

function ShopLayer:__prepareDataForAcquireGuide__( funId, itemId )
    if not self._propListView then 
        return nil
    end

__Log("__prepareDataForAcquireGuide__: funid:%d, itemId:%d", funId, itemId)
    local index = 0
    for i,v in ipairs(self._itemIndex) do
        if itemId == v then
            index = i
        end
    end
    __Log("index = %d", index)
    if index <= 0 then 
        --dump(self._itemIndex)
        return nil
    end

    local item = self._propListView:getCellByIndex(index - 1)
    if not item then 
        __Log("item is nil")
        return nil
    end

    return item:getScreenRectWithWidget("Button_buy")
end


function ShopLayer:_setPropListView()
    if self._propListView == nil and self._itemIndex ~= nil and #self._itemIndex ~= 0 then
        local propPanel = self:getPanelByName("Panel_proplistview")
        self._propListView = CCSListViewEx:createWithPanel(propPanel,LISTVIEW_DIR_VERTICAL)
        --道具
        self._propListView:setCreateCellHandler(function(list,index)
            local item = ShopPropItem.new()        
            return item
        end)
        
        self._propListView:setUpdateCellHandler(function(list,index,cell)
            local item = self._itemList[self._itemIndex[index+1]]
            cell:updateCell(item)
            --发送购买协议
            cell:setBuyButtonEvent(function() 
                if not item then
                    return
                end
                if G_Me.shopData:checkScoreMaxPurchaseNumber(item.id) == true then
                    G_MovingTip:showMovingTip(G_lang:get("LANG_PURCHASE_REACHED_MAXINUM"))
                    return
                end
                
                --判断是否限时过期
                local isXianshi,isSellEnabled = G_Me.shopData:checkItemXianShiEnabled(item)
                if isXianshi and (not isSellEnabled) then
                    G_MovingTip:showMovingTip(G_lang:get("LANG_ITEM_XIAN_SHI_TIME_OUT"))
                    return
                end

                --再判断购买金额
                if item.price_type == 1 and G_Me.userData.money < self:_getPrice(item) then
                    G_MovingTip:showMovingTip(G_lang:get("LANG_XILIAN_MONEY_BUZU"))
                    return
                elseif item.price_type == 2 and G_Me.userData.gold < self:_getPrice(item) then
                    require("app.scenes.shop.GoldNotEnoughDialog").show()
                    return
                end
                
                local layer = require("app.scenes.common.PurchaseScoreDialog").create(item.id)
                uf_sceneManager:getCurScene():addChild(layer)
            end)
            cell:setCheckItemInfoButtonEvent(function()  
                local item = self._itemList[self._itemIndex[index+1]]
                require("app.scenes.common.dropinfo.DropInfo").show(item.type,item.value) 
            end)
        end)
        self._propListView:setSpaceBorder(0,40)
        self._propListView:reloadWithLength(#self._itemIndex,self._propListView:getShowStart(),0.2)
    end 
    self:showWidgetByName("Panel_publistview",false)
    self:showWidgetByName("Panel_proplistview",true)
    self:showWidgetByName("Panel_baglistview",false)
    self:showWidgetByName("Panel_Top_VIP_Notice", false)
    self:registerListViewEvent("Panel_proplistview", function ( ... )
        -- this function is used for new user guide, you shouldn't care it
    end)
end

--获取价格
function ShopLayer:_getPrice(item)
    local price = G_Me.shopData:getPrice(item)
    --判断是否有活动
    local isDiscount,discount = G_Me.activityData.custom:isItemDiscountById(item.id)
    return isDiscount and math.ceil(discount * price / 1000) or price
end


function ShopLayer:_setGiftBagListView()
    if self._giftBagListView == nil and self._giftBagIndex ~= nil and #self._giftBagIndex ~= 0 then
        local giftBagPanel = self:getPanelByName("Panel_baglistview")
        self._giftBagListView = CCSListViewEx:createWithPanel(giftBagPanel,LISTVIEW_DIR_VERTICAL)
        local GiftBagItem = require("app.scenes.shop.ShopGiftbagItem")
        self._giftBagListView:setCreateCellHandler(function(list,index)
            local item = GiftBagItem.new()        
            return item
        end)
        
        self._giftBagListView:setUpdateCellHandler(function(list,index,cell)
            local item = self._giftBagList[self._giftBagIndex[index+1]]
            cell:updateCell(item)
            --发送购买协议
            cell:setBuyButtonEvent(function() 
                if not item then
                    return
                end
                --先判断vip
                local vip = -1
                repeat 
                    vip = vip+1
                    key =string.format("vip%s_num",vip)
                until item[key] ~= nil and item[key] >0
                vip = vip>=0 and vip or 0
                if vip > G_Me.userData.vip then
                    G_MovingTip:showMovingTip(G_lang:get("LANG_VIP_LEVEL_SMALL"))
                    return
                end

                --判断购买金额
                if item.price_type == 1 and G_Me.userData.money < self:_getPrice(item) then
                    G_MovingTip:showMovingTip(G_lang:get("LANG_XILIAN_MONEY_BUZU"))
                    return
                elseif item.price_type == 2 and G_Me.userData.gold < self:_getPrice(item) then
                    require("app.scenes.shop.GoldNotEnoughDialog").show()
                    return
                end
                
                local layer = require("app.scenes.common.PurchaseScoreDialog").create(item.id)
                uf_sceneManager:getCurScene():addChild(layer)
            end)
            cell:setCheckItemInfoFunc(function()  
                require("app.cfg.item_info")
                local _item = item_info.get(item.value)
                local layer = require("app.scenes.shop.ShopGiftReviewDialog").create(_item)
                uf_sceneManager:getCurScene():addChild(layer)
            end)
        end)
        self._giftBagListView:setSpaceBorder(0,40)
        self._giftBagListView:reloadWithLength(#self._giftBagIndex,self._giftBagListView:getShowStart(),0.2)
    elseif #self._giftBagIndex == 0 and not self:getWidgetByName("Panel_Top_VIP_Notice"):isVisible() then
        -- 达到VIP最高等级，显示提示
        self:showWidgetByName("Panel_Top_VIP_Notice", true)
        self:getLabelByName("Label_Top_VIP_1"):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_Top_VIP_2"):createStroke(Colors.strokeBrown, 1)
        self:getLabelByName("Label_Top_VIP_3"):createStroke(Colors.strokeBrown, 1)
    end
    
    self:showWidgetByName("Panel_publistview",false)
    self:showWidgetByName("Panel_proplistview",false)
    self:showWidgetByName("Panel_baglistview",true)
end

function ShopLayer:_setPubView()
    self:showWidgetByName("Panel_publistview",true)
    self:showWidgetByName("Panel_proplistview",false)
    self:showWidgetByName("Panel_baglistview",false)
    self:showWidgetByName("Panel_Top_VIP_Notice", false)
    if self._dropLayer == nil then
        self._dropLayer = require("app.scenes.shop.ShopDropMainLayer").create()
        self:getPanelByName("Panel_publistview"):addNode(self._dropLayer)
        local size = self:getPanelByName("Panel_publistview"):getContentSize()
        self._dropLayer:adapterWithSize(CCSizeMake(size.width, size.height))
    end
end

function ShopLayer:onLayerUnload()
end

--购买结果处理
function ShopLayer:_getBuyResult(data)
    self:showWidgetByName("Image_vipTips",CheckFunc.checkVipGiftbagEnabled())
    if data.ret == 1 then 
        --背包数量需要处理
        G_MovingTip:showMovingTip(G_lang:get("LANG_BUY_SUCCESS"))
        --购买后，单个刷新,不用所有的ListView刷新
        if self._propListView ~= nil and self._checkedName == "CheckBox_prop" then
            self:_initListData()
            self._propListView:refreshAllCell()
        elseif self._giftBagListView ~= nil and self._checkedName == "CheckBox_giftbag" then
            -- self._giftBagListView:reloadWithLength(#self._giftBagIndex,self._giftBagListView:getShowStart())
            self._giftBagListView:refreshAllCell()
        end
    end
end

--在次数判断是否显示checkbox上的抽卡红点
function ShopLayer:_getShopDropKnightInfo()
    if not self or not self.showWidgetByName then
        return
    end
    --极品
    local JPLeftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.jp_free_time)
    local JPTokenCount = G_Me.bagData:getGodlyKnightTokenCount()
    local LPTokenCount = G_Me.bagData:getGoodKnightTokenCount()
    local LPLeftTime = G_ServerTime:getLeftSeconds(G_Me.shopData.dropKnightInfo.lp_free_time)
    local themeDropTips = G_moduleUnlock:isModuleUnlock(FunctionLevelConst.THEME_DROP) and (G_Me.themeDropData:hasFreeTimes() or G_Me.themeDropData:couldExtractKnight())
    self:showWidgetByName("Image_dropTips",(LPLeftTime<=0 and G_Me.shopData.dropKnightInfo.lp_free_count < 3) or JPLeftTime<=0 or LPTokenCount > 0 or JPTokenCount > 0 or themeDropTips)
    -- self:showWidgetByName("Image_dropTips",true)
end

function ShopLayer:_getRechargeResult()
    self:showWidgetByName("Image_vipTips",CheckFunc.checkVipGiftbagEnabled())
end


function  ShopLayer:_getShopInfo(data)
    -- if self._giftBagListView ~= nil then
    --     self._giftBagListView:refreshAllCell()
    -- end

    -- if self._propListView ~= nil then
    --     self._propListView:refreshAllCell()
    -- end
    self:showWidgetByName("Image_vipTips",CheckFunc.checkVipGiftbagEnabled())
    self:_initListData()
    __LogTag("wkj","---- self._checkedName = %s",self._checkedName)
    if self._checkedName == "CheckBox_pub" then   --卡牌
        self:_setPubView()
    elseif self._checkedName == "CheckBox_prop" then  -- 装备
        self:_setPropListView()
    elseif self._checkedName == "CheckBox_giftbag" then -- 道具
        self:_setGiftBagListView()
    end
end

--包裹消息变化,重新刷新红点
function ShopLayer:_bagDataChange()
    __Log("包裹发生变化")
    self:_getShopDropKnightInfo()
end


return ShopLayer

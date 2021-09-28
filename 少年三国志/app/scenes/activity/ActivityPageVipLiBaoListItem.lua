local ActivityPageVipLiBaoListItem = class("ActivityPageVipLiBaoListItem",function()
    return CCSItemCellBase:create("ui_layout/activity_ActivityVipLiBaoListItem.json")
end)

require("app.cfg.vip_weekshop_info")

function ActivityPageVipLiBaoListItem:ctor()
    self._titleLabel = self:getLabelByName("Label_title")
    self._getButton = self:getButtonByName("Button_get")
    self._gotImg = self:getImageViewByName("Image_got")
    self._scrollView = self:getScrollViewByName("ScrollView_list")
    self._moneyLabel = self:getLabelByName("Label_money")
    self._moneyImg = self:getImageViewByName("Image_money")
    self._timesLabel = self:getLabelByName("Label_times")
    self._discountImg = self:getImageViewByName("Image_discount")
    self._titleLabel:createStroke(Colors.strokeBrown, 1)
    self._moneyLabel:createStroke(Colors.strokeBrown, 1)
    self._gotImg:setVisible(false)
    self._cost = 0
    self._index = 1

    self:registerBtnClickEvent("Button_get", function()
        self:goBuy()
    end)
end

function ActivityPageVipLiBaoListItem:goBuy()
    if G_Me.userData.gold >= self._cost then
        local str = G_lang:get("LANG_ACTIVITY_VIPDAILY_BUY_TIPS",{money=self._cost})
        MessageBoxEx.showYesNoMessage(nil,str,false,function()
            G_HandlersManager.activityHandler:sendVipWeekShopBuy(self._info.id*10+1)
        end,nil,nil,MessageBoxEx.OKNOButton.OKNOBtn_Default)
        -- G_HandlersManager.activityHandler:sendVipWeekShopBuy(self._info.id*10+1)
    else
        require("app.scenes.shop.GoldNotEnoughDialog").show()
    end
end

function ActivityPageVipLiBaoListItem:updateData(info)
    self._info = info
    if info == nil then
        return
    end
    self._titleLabel:setText(info["bag_1_name"]) 
    if vip_weekshop_info.hasKey("bag_1_item_1_type") and info["bag_1_item_1_type"] > 0 then
        local count = G_Me.activityData.vipDiscount:getShopCount(info.id*10+1)
        local leftCount = info.bag_1_cost_time - count
        local state = leftCount > 0
        self._getButton:setVisible(state)
        self._gotImg:setVisible(not state)
        self._moneyImg:setVisible(state)
        self._moneyLabel:setVisible(state)
        self._timesLabel:setVisible(state)
        self:updateList(info)
        local g = G_Goods.convert(info["bag_1_cost_type"],0)
        self._moneyImg:loadTexture(g.icon_mini,g.texture_type)
        self._cost = info["bag_1_cost_value"]
        self._moneyLabel:setText(self._cost)
        self._timesLabel:setText(G_lang:get("LANG_SPECIAL_ACTIVITY_BUYTIMES",{times=leftCount}))
    end
end

function ActivityPageVipLiBaoListItem:updateList(info)
    self._scrollView:removeAllChildren();
    local innerContainer = self._scrollView:getInnerContainer()
    local size = innerContainer:getContentSize()
    local award = {}
    for i = 1 , 4 do 
        if info["bag_1_item_"..i.."_type"] > 0 then
            table.insert(award,#award+1,{type=info["bag_1_item_"..i.."_type"],value=info["bag_1_item_"..i.."_value"],size=info["bag_1_item_"..i.."_size"]})
        end
    end
    local width = 5*(#award+1)+100*(#award)
    self._scrollView:setInnerContainerSize(CCSizeMake(width,size.height))
    GlobalFunc.createIconInPanel({panel=innerContainer,award=award,click=true,left=true,offset=5, numType = 3})

    if info.discount > 0 then
        self._discountImg:setVisible(true)
        self._discountImg:loadTexture(G_Path.getDiscountImage(info.discount))
    else
        self._discountImg:setVisible(false)
    end
end

return ActivityPageVipLiBaoListItem

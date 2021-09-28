local ActivityPageVipDiscountListItem = class("ActivityPageVipDiscountListItem",function()
    return CCSItemCellBase:create("ui_layout/activity_ActivityVipDiscountListItem.json")
end)

require("app.cfg.vip_daily_boon")

function ActivityPageVipDiscountListItem:ctor()
    -- self._descLabel = self:getLabelByName("Label_desc")
    self._titleLabel = self:getLabelByName("Label_title")
    self._titleLabel2 = self:getLabelByName("Label_title2")
    self._getButton = self:getButtonByName("Button_get")
    self._rechargeButton = self:getButtonByName("Button_recharge")
    self._gotImg = self:getImageViewByName("Image_got")
    self._scrollView = self:getScrollViewByName("ScrollView_list")
    self._titleLabel:createStroke(Colors.strokeBrown, 1)
    self._gotImg:setVisible(false)

    self:registerBtnClickEvent("Button_get", function()
        G_HandlersManager.activityHandler:sendBuyVipDaily()
    end)
    self:registerBtnClickEvent("Button_recharge", function()
        require("app.scenes.shop.recharge.RechargeLayer").show()  
    end)
end

function ActivityPageVipDiscountListItem:updateData(index,data)
    self._info = data
    if data == nil then
        return
    end
    self._titleLabel:setText(G_lang:get("LANG_ACTIVITY_VIPDAILY_TITLE",{level=data.vip_level})) 
    if index == 1 then
        self._titleLabel2:setVisible(false)
        self._rechargeButton:setVisible(false)
        if G_Me.activityData.vipDiscount.curLevel==-1 then
            self._getButton:setVisible(false)
            self._gotImg:setVisible(true)
        else
            self._getButton:setVisible(true)
            self._gotImg:setVisible(false)
        end
    else
        self._titleLabel2:setVisible(true)
        self._titleLabel2:setText(G_lang:get("LANG_ACTIVITY_VIPDAILY_TITLE_BUY",{money=G_Me.vipData:getNextExp()}))
        self._getButton:setVisible(false)
        self._rechargeButton:setVisible(true)
        self._gotImg:setVisible(false)
    end
    self:updateList()
end

function ActivityPageVipDiscountListItem:updateList()
    self._scrollView:removeAllChildren();
    local innerContainer = self._scrollView:getInnerContainer()
    local size = innerContainer:getContentSize()
    local award = {}
    for i = 1 , 5 do 
        if self._info["item_"..i.."_type"] > 0 then
            table.insert(award,#award+1,{type=self._info["item_"..i.."_type"],value=self._info["item_"..i.."_value"],size=self._info["item_"..i.."_size"]})
        end
    end
    local width = 5*(#award+1)+100*(#award)
    self._scrollView:setInnerContainerSize(CCSizeMake(width,size.height))
    GlobalFunc.createIconInPanel({panel=innerContainer,award=award,click=true,left=true,offset=5, numType = 3})
end

return ActivityPageVipDiscountListItem

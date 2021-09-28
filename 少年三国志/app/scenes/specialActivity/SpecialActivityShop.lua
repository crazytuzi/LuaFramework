local SpecialActivityShop = class("SpecialActivityShop",UFCCSModelLayer)
require("app.cfg.special_holiday_info")

function SpecialActivityShop.create(...)
    local layer = SpecialActivityShop.new("ui_layout/specialActivity_Shop.json",Colors.modelColor,...)
    return layer
end

function SpecialActivityShop:ctor(json,color,...)
    self._listView = nil
    self.super.ctor(self,json,color,...)
    self:showAtCenter(true)

    self:getLabelByName("Label_timeTitle"):createStroke(Colors.strokeBrown, 1)
    local note = self:getLabelByName("Label_time")
    note:createStroke(Colors.strokeBrown, 1)
    -- note:setText(G_lang:get("LANG_SPECIAL_ACTIVITY_ENDTIME"))
    note:setText(G_Me.specialActivityData:getTotalEndTime())

    self:registerBtnClickEvent("Button_close", function()
        self:onBackKeyEvent()
    end)
    self:registerBtnClickEvent("Button_close02", function()
        self:onBackKeyEvent()
    end)
end

function SpecialActivityShop:onBackKeyEvent()
    self:animationToClose()
    return true
end

function SpecialActivityShop:onLayerEnter()
    -- self:closeAtReturn(true)
    self:registerKeypadEvent(true)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_BUY_SPECILA_HOLIDAY_SALE, self._onBuyRsp, self)

    require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_bg"), "smoving_bounce")
    self:_initListView()
    self:updateCount()
end

function SpecialActivityShop:updateCountLabel(titleLabel,countLabel,id )
    if id > 0 then
        local name = G_Goods.convert(3,id).name
        titleLabel:setText(G_lang:get("LANG_SPECIAL_ACTIVITY_COUNT",{name=name}))
        countLabel:setText(G_Me.bagData:getPropCount(id))
        local posx,posy = titleLabel:getPosition()
        local width = titleLabel:getContentSize().width
        countLabel:setPositionXY(posx+width-10,posy)

        titleLabel:setVisible(true)
        countLabel:setVisible(true)
    else
        titleLabel:setVisible(false)
        countLabel:setVisible(false)
    end
end

function SpecialActivityShop:updateCount( )
    local id1,id2 = G_Me.specialActivityData:getMoneyId()
    self:updateCountLabel(self:getLabelByName("Label_countTitle1"),self:getLabelByName("Label_count1"),id1)
    self:updateCountLabel(self:getLabelByName("Label_countTitle2"),self:getLabelByName("Label_count2"),id2)
end

function SpecialActivityShop:_initListView()
    if self._listView == nil then
        local panel = self:getPanelByName("Panel_awardList")
        self._listView = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
        self._listView:setCreateCellHandler(function ()
            return require("app.scenes.specialActivity.SpecialActivityShopCell").new()
        end)
        self._listView:setUpdateCellHandler(function ( list, index, cell)
            if index < #self:getData() then
                cell:updateView(self:getData()[index+1])
            end
        end)
        self._listView:initChildWithDataLength(#self:getData())
    end
end

function SpecialActivityShop:getData()
    local data = G_Me.specialActivityData:getShopData()
    table.sort(data,function ( a,b )
        local arrangeA = G_Me.specialActivityData:getSaleArrange(a.id)
        local arrangeB = G_Me.specialActivityData:getSaleArrange(b.id)
        return arrangeA < arrangeB
    end)
    return data
end

function SpecialActivityShop:_onBuyRsp(data)
    if data.ret == NetMsg_ERROR.RET_OK then
        self._listView:refreshAllCell()
        self:updateCount()
    end
end

function SpecialActivityShop:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
end

return SpecialActivityShop


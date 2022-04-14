

BuyMarketPanel = BuyMarketPanel or class("BuyMarketPanel", BaseItem)
local BuyMarketPanel = BuyMarketPanel

function BuyMarketPanel:ctor(parent_node, layer)
    self.abName = "market";
    self.assetName = "BuyMarketPanel"
    self.layer = "UI"

    self.parentPanel = parent_node;
    self.model = MarketModel:GetInstance()
    self.schedules = {};


    self.Events = {} --事件
    self.leftItems = {}  --左侧按钮缓存
    self.rightItems = {}  --右侧小类缓存
    self.goodsItems = {} --商品信息的缓存
    self.dropItems = {}

    self.panelIndex = nil -- 大类的索引
    self.panelType = 0  -- 显示类型，1大类界面  2小类界面
    self.model.isOpenMarket = true

   -- self.isUnitSort = false   --是否单价排序
    --self.isAllSort = false   --是否总价排序
    self.unitSortType = true   -- false 从大到小  true 从小到大
    self.allSortType = true

    self.curOrder = 0 --当前阶数
    self.curStar = 0 -- 当前星数
    self.role = RoleInfoModel:GetInstance():GetMainRoleData()
    BuyMarketPanel.super.Load(self);

end

function BuyMarketPanel:dctor()
    GlobalEvent:RemoveTabListener(self.Events)
    if self.money_event_id then
        self.role:RemoveListener(self.money_event_id)
        self.money_event_id = nil
    end
    self.model.isOpenMarket = false
    for i, v in pairs(self.leftItems) do
        v:destroy()
        v = nil
    end
    for i, v in pairs(self.rightItems) do
        v:destroy()
        v = nil
    end
    for i, v in pairs(self.goodsItems) do
        v:destroy()
        v = nil
    end
    self.goodsItems = nil
    self.leftItems = nil
    self.rightItems = nil
    self.cacheItems = nil
    --if self.buyPanel ~= nil then
    --    self.buyPanel = nil
    --    self.buyPanel:destroy()
    --end
end


function BuyMarketPanel:Open(data)
    self.data = data;
    WindowPanel.Open(self)
end

function BuyMarketPanel:LoadCallBack()
    self.nodes = 
    {
        "itemScrollView/Viewport/itemContent",
        "SmallTypePanel/GoodsScrollView/Viewport/GoodsContent",
        "BuyMarketLeftItem",
        "SearchBtn",
        "SearchIpt",
        "BigTypePanel",
        "SmallTypePanel",
        "noSearchPanel",
        "Tips",
        "tipsParent",
        "Times",
        "BigTypePanel/RightItemsScrollView/Viewport/RightItemsContent",
        "BuyMarketRightItem",
        "BuyMarketBuyPanel",
        "SmallTypePanel/Text/level",
        "SmallTypePanel/Text/unitPrice",
        "SmallTypePanel/Text/unitPrice/unitImg",
        "SmallTypePanel/Text/allPrice",
        "SmallTypePanel/Text/allPrice/allImg",
        "SmallTypePanel/JieDropdown",
        "SmallTypePanel/XingDropdown",
        "BuyMarketBuyTowPanel",
        "SmallTypePanel/noItem",
        "moneyParent/priceIcon","moneyParent/priceText",

    }
    self:GetChildren(self.nodes)
    self.priceIcon = GetImage(self.priceIcon)
    self.priceText = GetText(self.priceText)

    SetLocalPosition(self.transform, 0, 0, 0)
    self:InitUI()
    self:AddEvent()
end


function BuyMarketPanel:AddEvent()
    local Search_call_back = function(target, x, y)

        self:SearchItems(self.SearchIptText.text)
    end

    AddClickEvent(self.SearchBtn.gameObject, Search_call_back);


    local call_back = function(target, x, y)

        self.unitSortType = not self.unitSortType
        if self.unitSortType then
            self.model:SortUPrice(1,self.cacheItems)
            SetLocalRotation(self.unitImg.transform,0,0,0)
        else
            self.model:SortUPrice(2,self.cacheItems)
            SetLocalRotation(self.unitImg.transform,180,0,0)
        end
        self:UpdateSellItemData(self.cacheItems)
        
    end
    AddClickEvent(self.unitPrice.gameObject,call_back)

    local call_back = function(target, x, y)
        self.allSortType = not self.allSortType
        if self.allSortType then
            self.model:SortUPrice(1,self.cacheItems)
            SetLocalRotation(self.allImg.transform,0,0,0)
        else
            self.model:SortUPrice(2,self.cacheItems)
            SetLocalRotation(self.allImg.transform,180,0,0)
        end
        self:UpdateSellItemData(self.cacheItems)
    end
    AddClickEvent(self.allPrice.gameObject,call_back)

    AddValueChange(self.JieDropdown.gameObject, handler(self, self.HandleJieChange));
    AddValueChange(self.XingDropdown.gameObject, handler(self, self.HandleXingChange));

    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketLeftItemClick, handler(self, self.BuyMarketLeftItemClick))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketRightItemClick, handler(self, self.BuyMarketRightItemClick))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateBigTypeData, handler(self, self.UpdateBigType))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateSellItemData, handler(self, self.UpdateSellItemData)) --商品列表
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateSearchItemData, handler(self, self.UpdateSearchItem)) --搜索列表
   -- self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateGoodData, handler(self, self.UpdateGood)) --物品详情
   -- self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateTwoGoodData, handler(self, self.UpdateTwoGood)) --物品详情
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketBuyItemData, handler(self, self.BuyItemData))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketReturnTimes, handler(self, self.UpdateTimes))

    local function call_back()
        self:SetValue()
    end
    self.money_event_id = self.role:BindData(Constant.GoldType.GreenGold, call_back)
end



function BuyMarketPanel:InitUI()
    -- body
    self.Tips = GetText(self.Tips)
    self.Times = GetText(self.Times)
    self.SearchBtn = GetButton(self.SearchBtn)
    self.JieDropdown = GetDropDown(self.JieDropdown)
    self.XingDropdown = GetDropDown(self.XingDropdown)
    self.SearchIptText = self.SearchIpt:GetComponent('InputField')   --输入框的文本
    self.level = GetText(self.level)
    self:InitLeftItem()
    self.Tips.text = "Trade reset at 05:00 daily. Tips: Market consumption is not calculated in spend events and VIP EXP"

    local iconName = Config.db_item[enum.ITEM.ITEM_GREEN_DRILL].icon
    GoodIconUtil:CreateIcon(self, self.priceIcon, iconName, true)
    self:SetValue()
end

function BuyMarketPanel:SetValue()
    local money = RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.GreenGold) or 0
    local color = "eb0000"
    if money > 0 then
        color = "3ab60e"
    end
    self.priceText.text = string.format("<color=#%s>%s</color>",color,money)
end

function BuyMarketPanel:InitDropdown()

    self.JieDropdown.options:Clear();
    self.XingDropdown.options:Clear();

    local xod = UnityEngine.UI.Dropdown.OptionData();
    xod.text = "All stars";
    self.XingDropdown.options:Add(xod);

    local xod = UnityEngine.UI.Dropdown.OptionData();
    xod.text = "1-star";
    self.XingDropdown.options:Add(xod);

    local xod = UnityEngine.UI.Dropdown.OptionData();
    xod.text = "2-star";
    self.XingDropdown.options:Add(xod);
    local xod = UnityEngine.UI.Dropdown.OptionData();
    xod.text = "3-star";
    self.XingDropdown.options:Add(xod);
    local xod = UnityEngine.UI.Dropdown.OptionData();
    xod.text = "4-star";
    self.XingDropdown.options:Add(xod);
    local xod = UnityEngine.UI.Dropdown.OptionData();
    xod.text = "5-star";
    self.XingDropdown.options:Add(xod);

  --  self.JieDropdown.captionText.text = "阶数筛选"
    local od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "All tiers";
    self.JieDropdown.options:Add(od);
    if not self.model:CheckIsEquip(self.panelIndex)  then
        if self.model:CheckIsShowOrder(self.panelIndex) == 1 then
            local od = UnityEngine.UI.Dropdown.OptionData();
            od.text = "but combining?Revelry Pets";
            self.JieDropdown.options:Add(od);
        end
    end
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "Tier 1";
    self.JieDropdown.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "T2";
    self.JieDropdown.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "T3";
    self.JieDropdown.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "T4";
    self.JieDropdown.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "T5";
    self.JieDropdown.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "T6";
    self.JieDropdown.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "T7";
    self.JieDropdown.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "T8";
    self.JieDropdown.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "T9";
    self.JieDropdown.options:Add(od);
    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = "T10";
    self.JieDropdown.options:Add(od);




end

function BuyMarketPanel:HandleJieChange(go,value)
    self.curOrder = value
    self:UpdateDropEquips(self.curOrder,self.curStar)
    --if self.model:CheckIsEquip(self.panelIndex) then
    --    self:UpdateDropEquips(self.curOrder,self.curStar)
    --else
    --    self:UpdateDropItems(self.curOrder)
    --end
end

function BuyMarketPanel:HandleXingChange(go,value)
    self.curStar = value
    self:UpdateDropEquips(self.curOrder,self.curStar)
end

function BuyMarketPanel:UpdateDropEquips(order,star)
   -- print2(order,star)
    self.dropItems = {}
    local cfg = nil
    cfg = Config.db_equip
    for i, v in pairs(self.model.SellItems) do
        local id = v.id
        local itemCfg = cfg[id]
        if Config.db_item[id].stype == enum.ITEM_STYPE.ITEM_STYPE_PET then
            local  showOrder = order - 1
            if showOrder >= 0 then
                local petCfg = Config.db_pet[id]
                if showOrder == petCfg.order_show then
                    table.insert(self.dropItems,v)
                end
            else
                table.insert(self.dropItems,v)
            end
        else
            if order ~= 0 and star ~= 0 then
                if  order == itemCfg.order and star == itemCfg.star then
                    table.insert(self.dropItems,v)
                end
            else
                if order == 0 and star == 0 then
                    table.insert(self.dropItems,v)
                else
                    if order == 0 then
                        if star == itemCfg.star  then
                            table.insert(self.dropItems,v)
                        end
                    end
                    if star == 0 then
                        if order == itemCfg.order  then
                            table.insert(self.dropItems,v)
                        end
                    end
                end

            end
        end
        

    end
    self:UpdateSellItemData(self.dropItems)
end
--function BuyMarketPanel:UpdateDropItems(order)
--    self.dropItems = {}
--    local cfg = Config.db_item
--    for i, v in pairs(self.model.SellItems) do
--        local id = v.id
--        local itemCfg = cfg[id]
--        if order ~= 0 then
--            if order ==itemCfg.level then
--                table.insert(self.dropItems,v)
--            end
--        else
--            table.insert(self.dropItems,v)
--        end
--    end
--    self:UpdateSellItemData(self.dropItems)
--end



--加载左侧按钮
function BuyMarketPanel:InitLeftItem()
    local cfg = self.model:GetBuyMarketRightItem()
    for i = 1, #cfg do
        self.leftItems[cfg[i].type] = BuyMarketLeftItem(self.BuyMarketLeftItem.gameObject,self.itemContent,"UI")
        self.leftItems[cfg[i].type]:SetData(cfg[i],index)
    end
    self:BuyMarketLeftItemClick(cfg[1])
end

------搜索
function BuyMarketPanel:SearchItems(text)
    local ShowItemsId = {}   --搜索需要展示的物品
    if  text ~= "" then
        local items = Config.db_market_item
        for i, v in pairs(items) do
            local id = tonumber(v.item_id)
            local itemName = ""
            if Config.db_item[id] ~= nil then
                itemName = Config.db_item[id].name
            else
                print2("检查配表ID——"..tostring(id))
            end
            --if string.match(itemName,text) ~= nil then
            --    table.insert(ShowItemsId,id)
            --end
            if itemName == text then
                table.insert(ShowItemsId,id)
            end
        end
        MarketController:GetInstance():RequeseSearchInfo(ShowItemsId)
    else
        Notify.ShowText("Please enter the content you want to search for")
    end
end
--点击左侧按钮的回调
function BuyMarketPanel:BuyMarketLeftItemClick(item)
    if item.type == self.panelIndex and  self.panelType == 1 then
        return
    end
    self.panelIndex = item.type
    local tab = {}
    tab = self.model:GetBuyMarketRightItemByID(item.type)
    self.rightItems = self.rightItems or {}

    for i = 1, #tab do
        local buyItem =  self.rightItems[i]
        if  not buyItem then
            buyItem = BuyMarketRightItem(self.BuyMarketRightItem.gameObject,self.RightItemsContent,"UI")

            self.rightItems[i] = buyItem
        else
            buyItem:SetVisible(true)
        end
        buyItem:SetData(tab[i])
    end
    for i = #tab + 1,#self.rightItems do
        local buyItem = self.rightItems[i]
        buyItem:SetVisible(false)
    end
    MarketController:GetInstance():RequeseBigTypeInfo(self.panelIndex)
    self:SetBtnState(self.panelIndex)
    if self.panelType ~= 1 then
        self.panelType = 1
        self:SetShow(self.panelType)
    end

end
--设置左侧按钮状态
function BuyMarketPanel:SetBtnState(index)
    for i, v in pairs(self.leftItems) do
        if index == i then
            v:Select(true)
        else
            v:Select(false)
        end
    end
end
--右侧小类的回调
function BuyMarketPanel:BuyMarketRightItemClick(data)
    self.stype = data.stype
    MarketController:GetInstance():RequeseSellListInfo(data.type,data.stype)
end

function BuyMarketPanel:SetShow(panelType)
    if panelType == 2 then --小类
        SetVisible(self.BigTypePanel,false)
        SetVisible(self.SmallTypePanel,true)
        SetVisible(self.noSearchPanel,false)
        if self.model:CheckIsEquip(self.panelIndex) then
            self.level.text = "Quality"
            SetVisible(self.XingDropdown,true)
            SetVisible(self.JieDropdown,true)
        else
            local show = self.model:CheckIsShowOrder(self.panelIndex)
            if show == 1 then
                self.level.text = "Quality"
                SetVisible(self.XingDropdown,false)
                SetVisible(self.JieDropdown,true)
            else
                self.level.text = "Level"
                SetVisible(self.XingDropdown,false)
                SetVisible(self.JieDropdown,false)
            end
        end
        self:InitDropdown()
    elseif panelType == 1 then  --大类
        SetVisible(self.BigTypePanel,true)
        SetVisible(self.SmallTypePanel,false)
        SetVisible(self.noSearchPanel,false)
        self.unitSortType = true
        SetLocalRotation(self.unitImg.transform,0,0,0)
        self.allSortType = true
        SetLocalRotation(self.allImg.transform,0,0,0)
    else ---没有搜索到
        SetVisible(self.noSearchPanel,true)
        SetVisible(self.BigTypePanel,false)
        SetVisible(self.SmallTypePanel,false)
        self.unitSortType = true
        SetLocalRotation(self.unitImg.transform,0,0,0)
        self.allSortType = true
        SetLocalRotation(self.allImg.transform,0,0,0)
    end
end


-----------------服务器消息
function BuyMarketPanel:UpdateBigType(data)
   -- print2(self.model:GetVipBuyTimes())
    for i, v in pairs(self.rightItems) do
        if v.data.stype == 0 then --全部
          local nums =   self.model:GetAllNums(data.stat)
            v:SetNum(nums)
        else
            if data.stat[v.stype] == 0 or data.stat[v.stype] == nil then
                v:SetNum(0);
            else
                v:SetNum(data.stat[v.stype])
            end
        end

    end
    local curTimes = self.model:GetVipBuyTimes() - data.times
	if curTimes < 0  then
		curTimes = 0
	end
    local color = "'"
    if curTimes <= 5 then
         color = "e63232"
    else
        color = "00B023"
    end
    self.Times.text =string.format("Trade attempts left：<color=#%s>%s</color>",color,curTimes)
end

function BuyMarketPanel:UpdateSellItemData(data,isSearch)
    local tab = data
    self.cacheItems = data
    self.goodsItems = self.goodsItems or {}
    if table.nums(tab) <= 0 then
        SetVisible(self.noItem,true)
    else
        SetVisible(self.noItem,false)
    end
    for i = 1, #tab do
        local buyItem =  self.goodsItems[i]
        if  not buyItem then
            buyItem = BuyMarketGoodsItem(self.GoodsContent,"UI")
            self.goodsItems[i] = buyItem
        else
            buyItem:SetVisible(true)
        end
        buyItem:SetData(tab[i],self.panelIndex,isSearch)
    end
    for i = #tab + 1,#self.goodsItems do
        local buyItem = self.goodsItems[i]
        buyItem:SetVisible(false)
    end
    self.panelType = 2
    self:SetShow(self.panelType)

end
--更新搜索列表
function BuyMarketPanel:UpdateSearchItem(data)

    if data.items == nil or data.items == {} or #data.items <= 0 then
        if self.panelType ~= 3 then
            self.panelType = 3
            self:SetShow(self.panelType)
        end
    else
        dump(data.items)
        self:UpdateSellItemData(data.items,true)
        if self.panelType ~= 2 then
            self.panelType = 2
            self:SetShow(self.panelType)
        end
    end
end
--物品详情
function BuyMarketPanel:UpdateGood(data)
    self.buyPanel = BuyMarketBuyPanel(self.BuyMarketBuyPanel.gameObject,self.tipsParent.transform,"UI")
    self.buyPanel:UpdateInfo(data.item)
    self.buyPanel:SetItemData(data.item,1,false)
end
--非装备
function BuyMarketPanel:UpdateTwoGood(data)
    self.buyPanel = BuyMarketBuyTowPanel(self.BuyMarketBuyTowPanel.gameObject,self.tipsParent.transform,"UI")
    self.buyPanel:UpdateInfo(data.item)
    self.buyPanel:SetItemData(data.item,1,false)
end
--购买
function BuyMarketPanel:BuyItemData(data)

    MarketController:GetInstance():RequeseSellListInfo(self.panelIndex,self.stype)
    --self.buyPanel:destroy()
    --if data.type == 1 then  --市场交易
    --    for i, v in ipairs(self.goodsItems) do
    --        if v.uid == data.uid then
    --            print2(v.type)
    --            v:SetVisible(false)
    --        end
    --    end
    --    self.buyPanel:destroy()
    --end
end
function BuyMarketPanel:UpdateTimes(data)
    local curTimes = self.model:GetVipBuyTimes() - data.times
    local color = "'"
    if curTimes <= 5 then
        color = "e63232"
    else
        color = "00B023"
    end
    self.Times.text =string.format("Trade attempts left：<color=#%s>%s</color>",color,curTimes)
end




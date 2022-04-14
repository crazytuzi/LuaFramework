UpShelfMaketPanel = UpShelfMaketPanel or class("UpShelfMaketPanel", BaseItem)
local UpShelfMaketPanel = UpShelfMaketPanel

function UpShelfMaketPanel:ctor(parent_node, layer)
    self.abName = "market";
    self.assetName = "UpShelfMaketPanel"
    self.layer = "UI"

    self.parentPanel = parent_node;
    self.model = MarketModel:GetInstance()
    self.schedules = {};

    self.openMoreBtn = false;
    self.pageType = -1  --分页
    self.Events = {} --事件
    self.btnList = {}
    self.moreBtnList = {}
    self.itemList = {}
    self.upItemList = {} --已经上架物品





    self.model.isOpenUpShelfMarket = true
    UpShelfMaketPanel.super.Load(self);
end

function UpShelfMaketPanel:dctor()
    GlobalEvent:RemoveTabListener(self.Events)
    self.model.isOpenUpShelfMarket = false
    if self.PageScrollView ~= nil then
        self.PageScrollView:OnDestroy()
        self.PageScrollView = nil
    end
    for i, v in pairs(self.itemList) do
        v:destroy()
        v = nil
    end
    self.itemList = {}
    for i, v in pairs(self.btnList) do
        v:destroy()
        v = nil
    end
    for i, v in pairs(self.moreBtnList) do
        v:destroy()
        v = nil
    end
    self.moreBtnList = {}
    for i, v in pairs(self.upItemList) do
        v:destroy()
        v = nil
    end
    self.upItemList = {}
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end


function UpShelfMaketPanel:Open(data)
    self.data = data;
    WindowPanel.Open(self)
end

function UpShelfMaketPanel:LoadCallBack()
    self.nodes =
    {
        "itemScrollView/Viewport/itemContent",
        "Btns/UpshelfTopBtnItem",
        "Btns",
        "itemScrollView",
        "Title/ItemNumsText",
        "NoUpShelf",
        "moreBtn",
        "moreBtn/moreBtnText",
        "moreBtn/moreBtnSelect",
        "moreBtn/morebtnpanel",
        "moreBtn/morebtnpanel/bg",
        "moreBtn/morebtnpanel/moreParent",
        "UpShelfLeftItem",
        "leftItemScrollView/Viewport/leftItemContent",
        "BuyMarketBuyPanel",
        "BuyMarketBuyTowPanel",
        "tipsTrans",
        "itemScrollView/Viewport"



    }
    self:GetChildren(self.nodes)
    SetLocalPosition(self.transform, 0, 0, 0)
    self.ItemNumsText = GetText(self.ItemNumsText)
    self.moreBtn = GetButton(self.moreBtn)
    self.moreBtnText = GetText(self.moreBtnText)
    self.moreBtnBg = GetImage(self.bg)
    self:SetMask()
    self:InitUI()
    self:AddEvent()

end

function UpShelfMaketPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function UpShelfMaketPanel:InitUI()
    self:InitPageItem()
    self:UpShelfMarketPageBtnClick(1)
    MarketController:GetInstance():RequeseSalingInfo()
end
function UpShelfMaketPanel:AddEvent()

    local morebtn_call_Back = function(target, x, y)
        self.openMoreBtn = not self.openMoreBtn
        SetVisible(self.morebtnpanel,self.openMoreBtn)
    end

    AddClickEvent(self.moreBtn.gameObject,morebtn_call_Back)

    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketUpBtn, handler(self, self.UpShelfMarketUpBtnClick))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketPageBtn, handler(self, self.UpShelfMarketPageBtnClick))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketPageMoreBtn, handler(self, self.UpShelfMarketPageMoreBtnClick))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketSalingInfo, handler(self, self.UpShelfMarketSalingInfo))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketSaleInfo, handler(self, self.UpShelfMarketSaleInfo))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketRemove, handler(self, self.UpShelfMarketRemove))
    self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.UpShelfMarketAlter, handler(self, self.UpShelfMarketAlter))
   -- self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateGoodData, handler(self, self.UpdateGood))
    --self.Events[#self.Events + 1] = GlobalEvent:AddListener(MarketEvent.BuyMarketUpdateTwoGoodData, handler(self, self.UpdateTwoGood))
end

function UpShelfMaketPanel:InitPageItem()
    local types = Config.db_market_sell
    for i = 1, #types do
        if i > 4 then
            break
        end
        self.btnList[types[i].type] = UpshelfTopBtnItem(self.UpshelfTopBtnItem.gameObject,self.Btns,"UI")
        self.btnList[types[i].type]:SetData(types[i],false)
    end
    for i = 5, #types do
        self.btnList[types[i].type] = UpshelfTopBtnItem(self.UpshelfTopBtnItem.gameObject,self.moreParent,"UI")
        self.btnList[types[i].type]:SetData(types[i],true)
    end

end



function UpShelfMaketPanel:CreateItems(cellCount)
    local param = {}
    local cellSize = {width = 78,height = 78}
    param["scrollViewTra"] = self.itemScrollView
    param["cellParent"] = self.itemContent
    param["cellSize"] = cellSize
    param["cellClass"] = UpshelfMarketSettor
    param["begPos"] = Vector2(0,0)
    param["spanX"] = 5
    param["spanY"] = 10
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] = BagModel.GetInstance().bagOpenCells
    self.PageScrollView = ScrollViewUtil.CreateItems(param)


end


function UpShelfMaketPanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function UpShelfMaketPanel:UpdateCellCB(itemCLS)
    local bagItems,bagId = self.model:GetCanUpShelfItemInBag(self.pageType)
    if bagItems ~=nil then
        local itemBase = bagItems[itemCLS.__item_index]
        if itemBase ~= nil and itemBase ~= 0 then
            local configItem = Config.db_item[itemBase.id]
            if configItem ~= nil then --配置表存该物品
                local param = {}
                --type,uid,id,num,bag,bind,outTime
                param["type"] = configItem.type
                param["uid"] = itemBase.uid
                param["id"] = configItem.id
                param["num"] = itemBase.num
                param["bag"] = bagId
                param["bind"] = itemBase.bind
                param["sex"] = itemBase.gender
                param["outTime"] = itemBase.etime
                param["itemSize"] = {x=80, y=80}
                param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
                param["model"] = self.model
                param["model"] = self.model
                param["itemIndex"] = itemCLS.__item_index
                param["stencil_id"] = self.StencilId
                itemCLS:DeleteItem()
                itemCLS:UpdateItem(param)
            end
        else
            --Chkprint('--chk BagShowPanel.lua,line 125-- data=',data)
            local param = {}
            param["bag"] = bagId
            param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
            param["model"] = self.model
            itemCLS:InitItem(param)
        end
    else
        local param = {}
        param["bag"] = bagId
        param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
        param["model"] = self.model
        itemCLS:InitItem(param)
    end

    --itemCLS:SetCellIsLock(BagModel.UpShelfBag)
end

function UpShelfMaketPanel:GetItemDataByIndex(index)
    return BagModel.Instance:GetItemDataByIndex(index)
end

---上架
function UpShelfMaketPanel:UpShelfMarketUpBtnClick( index)
        --1上架 2修改
   -- if index == 1 then  --上架
        GlobalEvent:Brocast(MarketEvent.OpenUpShelfTowPanel,index)
   -- end
end

---更多分页里的按钮
function UpShelfMaketPanel:UpShelfMarketPageMoreBtnClick(data)
    if data.type == self.pageType then
        return
    end
    self.pageType = data.type
    self.openMoreBtn = false
    SetVisible(self.morebtnpanel,false)
    SetVisible(self.moreBtnSelect,true)
    self.moreBtnText.text = data.name
   -- local count = #self.model:GetCanUpShelfItemInBag(self.pageType)
    if self.PageScrollView ~= nil then
        self.PageScrollView:OnDestroy()
        self.PageScrollView = nil
    end
    self:CreateItems()
    self:SetBtnState(data.type)

end

--点击分页按钮
function UpShelfMaketPanel:UpShelfMarketPageBtnClick(pageType)

    if pageType == self.pageType then
        return
    end
    if self.moreBtnText.text ~= "More" then
        self.moreBtnText.text = "More"
    end
    self.pageType = pageType
    SetVisible(self.moreBtnSelect,false)
    self.openMoreBtn = false
    SetVisible(self.morebtnpanel,false)

  --  local count = #self.model:GetCanUpShelfItemInBag(self.pageType)
    if self.PageScrollView ~= nil then
        self.PageScrollView:OnDestroy()
        self.PageScrollView = nil
    end

    self:CreateItems()
    self:SetBtnState(pageType)
end



function UpShelfMaketPanel:SetBtnState(pageType)
    for i, v in pairs(self.btnList) do
        if i == pageType then
            v:Select(true)
        else
            v:Select(false)

        end
    end

end

---服务器
function  UpShelfMaketPanel:UpShelfMarketSalingInfo(items)
    self.ItemNumsText.text = string.format("Items on sale  <color=#7B3E28>%s/%s</color>",#items,self.model:GetVipTimes())
    if items == nil or items == {} or #items == 0 then       --无上架物品
        SetVisible(self.NoUpShelf,true)
        for i = 1,#self.upItemList do
            local buyItem = self.upItemList[i]
            buyItem:SetVisible(false)
        end
    else
        SetVisible(self.NoUpShelf,false)
        local tab = items
        --tab = self.model:GetBuyMarketRightItemByID(item.type)
        self.upItemList = self.upItemList or {}
        for i = 1, #tab do
            local buyItem =  self.upItemList[i]
            if  not buyItem then
                buyItem = UpShelfLeftItem(self.UpShelfLeftItem.gameObject,self.leftItemContent,"UI")

                self.upItemList[i] = buyItem
            else
                buyItem:SetVisible(true)
            end
            buyItem:SetData(tab[i])
        end
        for i = #tab + 1,#self.upItemList do
            local buyItem = self.upItemList[i]
            buyItem:SetVisible(false)
        end
    end
end
--上架成功
function UpShelfMaketPanel:UpShelfMarketSaleInfo(data)
    table.insert(self.model.saleList,data.item)
   -- local count = #self.model:GetCanUpShelfItemInBag(self.pageType)
    --if self.PageScrollView ~= nil then
    --    self.PageScrollView:OnDestroy()
    --    self.PageScrollView = nil
    --end

   -- self:CreateItems(count)
   self:UpShelfMarketSalingInfo(self.model.saleList)
end
--修改成功
function UpShelfMaketPanel:UpShelfMarketAlter(data)
  --  self.buyPanel:destroy()
    for i, v in pairs(self.model.saleList) do
        if v.uid == data.uid then
            v.price = data.price
        end
    end
    self:UpShelfMarketSalingInfo(self.model.saleList)
end

function UpShelfMaketPanel:UpdateGood(data)
   -- self.buyPanel = BuyMarketBuyPanel(self.BuyMarketBuyPanel.gameObject,self.transform,"UI")

    --SetPutDownSellCB
    --local operate_param = {}
    --local function call_back()
    --    local item = MarketModel:GetInstance().selectGoodItem
    --    local type = 1
    --    local uid = item.uid
    --    MarketController:GetInstance():RequeseRemove(type,uid)
    --end
    --GoodsTipController.Instance:SetPutDownSellCB(operate_param,call_back,{data.item}) --下架
    --
    --local function call_back(item)
    --    self.model.selectItem = item[1]
    --    GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn,2)
    --end
    --GoodsTipController.Instance:SetChangePriceSellCB(operate_param,call_back,{data.item})
    --
    --local param = {}
    --param["item_id"] = data.item.id
    --param["p_item"] = data.item
    --param["model"] = self.model
    --param["operate_param"] = operate_param
    --param["mType"] = 1
    --param["isUp"] = true
    --self.buyPanel = BuyMarketBuyPanel(self.transform)
    --self.buyPanel:ShowTip(param)
    --self.buyPanel:UpdateInfo(data.item)
   -- self.buyPanel:SetItemData(data.item,1,true)
end

function UpShelfMaketPanel:UpdateTwoGood(data)
    self.buyPanel = BuyMarketBuyTowPanel(self.BuyMarketBuyTowPanel.gameObject,self.tipsTrans.transform,"UI")
    self.buyPanel:UpdateInfo(data.item)
    self.buyPanel:SetItemData(data.item,1,true)
end

function UpShelfMaketPanel:UpShelfMarketRemove(data)
    if self.PageScrollView ~= nil then
        self.PageScrollView:OnDestroy()
        self.PageScrollView = nil
    end
    --local count = #self.model:GetCanUpShelfItemInBag(self.pageType)
    self:CreateItems()
   -- self.buyPanel:destroy()
   -- local items = BagModel.GetInstance().bagItems
    for i, v in pairs(self.model.saleList) do
        if v.uid == data.uid then
            table.remove(self.model.saleList,i)
        end
    end
    self:UpShelfMarketSalingInfo(self.model.saleList)
end


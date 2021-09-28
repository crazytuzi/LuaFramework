require "Core.Module.Common.Panel"
require "Core.Module.TShop.View.ShopProItem"
require "Core.Module.TShop.View.ShopRightPanelCtr"

TShopPanel = class("TShopPanel", Panel);
function TShopPanel:New()
    self = { };
    setmetatable(self, { __index = TShopPanel });
    return self
end

function TShopPanel:IsPopup()
    return false
end

function TShopPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function TShopPanel:_InitReference()
    self._txttitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txttitle");


    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self._ScrollView = UIUtil.GetChildByName(self._trsContent, "Transform", "ScrollView");
    self._pag_phalanx = UIUtil.GetChildByName(self._ScrollView, "LuaAsynPhalanx", "bag_phalanx");
    self._scrollViewLogic = UIUtil.GetComponent(self._ScrollView, "UIScrollView");

    self._rightPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "rightPanel");

    self._shopRightPanelCtr = ShopRightPanelCtr:New();
    self._shopRightPanelCtr:Init(self._rightPanel);

    self._pages = UIUtil.GetChildByName(self._trsContent, "Transform", "pages");

    self._pageIcons = { };

    for i = 1, 10 do
        self._pageIcons[i] = UIUtil.GetChildByName(self._pages, "UISprite", "pageSelect" .. i);
        self._pageIcons[i].gameObject:SetActive(false);
    end



    -------------------------------------------------------------------------------------------------
    self._centerOnChild = UIUtil.GetChildByName(self._ScrollView, "UICenterOnChild", "bag_phalanx")
    self._delegate = function(go) self:_OnCenterCallBack(go) end
    self._centerOnChild.onCenter = self._delegate

    -----------------------------------------------------------------------------------

    self.pag_phalanx = Phalanx:New();
    self.pag_phalanx:Init(self._pag_phalanx, ShopProItem)

    self:InitData();


    MessageManager.AddListener(ShopDataManager, ShopDataManager.MESSAGE_HAS_BUY_PRODUCTS_CHANGE, TShopPanel.ProductsChange, self);
    MessageManager.AddListener(PVPManager, PVPManager.SELFPVPRANKCHANGE, TShopPanel.MdataChange, self);

   -- MessageManager.AddListener(TrumpManager, TrumpManager.TRUMPCOINCHANGE, TShopPanel.MdataChange, self);
    MessageManager.AddListener(GuildDataManager, GuildDataManager.MESSAGE_DKPCHANGE, TShopPanel.MdataChange, self);
    MessageManager.AddListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, TShopPanel.MdataChange, self);
end

function TShopPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function TShopPanel:InitData()


    self._productPanels = { };
    self._productPanels_index = 1;
    --[[
    local data = {
        { name = "page1", page_id = "1" },
        { name = "page2", page_id = "2" },
        { name = "page3", page_id = "3" },
        { name = "page4", page_id = "4" },
        { name = "page5", page_id = "5" },
        { name = "page6", page_id = "6" },
        { name = "page7", page_id = "7" },
        { name = "page8", page_id = "8" },
        { name = "page9", page_id = "9" },
        { name = "page10", page_id = "10" }
    }


    self.pag_phalanx:Build(1, 10, data);
    ]]
    self.currPage_id = "-1";
end

function TShopPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(TShopNotes.CLOSE_TSHOP)
end


function TShopPanel:_OnCenterCallBack(go)
    if (go) then
        if (self._currentGo == go) then
            return
        end
        self._currentGo = go

        local index = self.pag_phalanx:GetItemIndex(go)

        self.currPage_id = index - 1;
        self:ShowPageIcon(self.currPage_id);

    end
end



function TShopPanel:ShowPageIcon(pid)

    local index = pid + 1;
    for i = 1, 10 do
        if index == i then
            self._pageIcons[i].spriteName = "circle2";
            self._pageIcons[i]:MakePixelPerfect();
        else
            self._pageIcons[i].spriteName = "circle1";
            self._pageIcons[i]:MakePixelPerfect();
        end
    end
end


function TShopPanel:SetType(type)

    TShopPanel.curr_type = type;
    TShopProxy.TryGetShopData(type);

    self.needSetDefSelect = true;

end

function TShopPanel:SetData(data)
    self._selectID = data.id;
    if (data.type) then
        self:SetType(data.type);
    end
end

function TShopPanel:MdataChange()


    self:UpProductInfo();
    self._shopRightPanelCtr:MoneyChange();

end

function TShopPanel:ProductsChange()

    self:UpProductInfo();
    FixedUpdateBeat:Add(self.UpTime, self);

    if (self._selectID) then
        local pages = self.pag_phalanx:GetItems();
        for i, v in pairs(pages) do
            local logic = v.itemLogic;
            if (logic:SetSelectById(self._selectID)) then
               
                if i == 1 then
                 self._scrollViewLogic:SetDragAmount(0, 0, false);
                elseif i == 2 then
                 self._scrollViewLogic:SetDragAmount(1, 0, false);
                end 
               
                self.currPage_id = i - 1;
                self:ShowPageIcon(self.currPage_id);
            end
        end
    else
        if self.needSetDefSelect then
            self.pag_phalanx._items[1].itemLogic:SetDefSelect();
            self.needSetDefSelect = false;
        end
    end
    -- 更新  ShopRightPanelCtr
    self._shopRightPanelCtr:UpProductSelect()
end

function TShopPanel:UpTime()

    self._trsContent.gameObject:SetActive(false);
    self._trsContent.gameObject:SetActive(true);
    FixedUpdateBeat:Remove(self.UpTime, self)
end

-- 更新数据
function TShopPanel:UpProductInfo()

    local arr = ShopDataManager.GetProductsForTShop(TShopPanel.curr_type);
    local len = table.getn(arr);

    -- len = 2;

    local leftPx =(len - 1) * 30 *(-0.5);


    --[[
    local item = self.pag_phalanx._items;
    local num = table.getn(item);
    for i = 1, num do

        local tg = item[i].itemLogic;

        if i <= len then
            tg:SetProductData(arr[i]);
            self._pageIcons[i].gameObject:SetActive(true);
            self._pageIcons[i].transform.localPosition = Vector3.New(leftPx, 0, 0);
            leftPx = leftPx + 30;

        else
            tg:SetProductData(nil);
            self._pageIcons[i].gameObject:SetActive(false);
        end

    end
    ]]

    for i = 1, len do
        self._pageIcons[i].gameObject:SetActive(true);
        Util.SetLocalPos(self._pageIcons[i].transform, leftPx, 0, 0)
        --        self._pageIcons[i].transform.localPosition = Vector3.New(leftPx, 0, 0);
        leftPx = leftPx + 30;
    end

    self.pag_num = len;
    self.pag_phalanx:Build(1, len, arr);

end


function TShopPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function TShopPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;

    MessageManager.RemoveListener(ShopDataManager, ShopDataManager.MESSAGE_HAS_BUY_PRODUCTS_CHANGE, TShopPanel.ProductsChange);
    MessageManager.RemoveListener(PVPManager, PVPManager.SELFPVPRANKCHANGE, TShopPanel.MdataChange);

   -- MessageManager.RemoveListener(TrumpManager, TrumpManager.TRUMPCOINCHANGE, TShopPanel.MdataChange);
    MessageManager.RemoveListener(GuildDataManager, GuildDataManager.MESSAGE_DKPCHANGE, TShopPanel.MdataChange);
    MessageManager.RemoveListener(MoneyDataManager, MoneyDataManager.EVENT_MONEY_CHANGE, TShopPanel.MdataChange);

    self._delegate = nil;
    if self._centerOnChild and self._centerOnChild.onCenter then
        self._centerOnChild.onCenter:Destroy();
    end
end

function TShopPanel:_DisposeReference()
    self._btn_close = nil;

    self._shopRightPanelCtr:Dispose();
    self.pag_phalanx:Dispose();
    self.pag_phalanx = nil;


    self._txttitle = nil;


    self._btn_close = nil;

    self._ScrollView = nil;
    self._pag_phalanx = nil;
    self._scrollViewLogic = nil

    self._rightPanel = nil;

    self._shopRightPanelCtr = nil;

    self._pages = nil;


    for i = 1, 10 do
        self._pageIcons[i] = nil;
    end

    -------------------------------------------------------------------------------------------------
    self._centerOnChild = nil;
    self._delegate = nil;

end

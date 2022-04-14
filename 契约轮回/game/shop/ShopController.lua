--
-- @Author: lwj
-- @Date:  2018-11-12 16:42:46
--

require("game.shop.RequireShop")
ShopController = ShopController or class("ShopController", BaseController)
local ShopController = ShopController

function ShopController:ctor()
    ShopController.Instance = self
    self.model = ShopModel:GetInstance()
    self.addFlashIcon = false
    self:AddEvents()
    self:RegisterAllProtocal()
end

function ShopController:dctor()
end

function ShopController:GetInstance()
    if not ShopController.Instance then
        ShopController.new()
    end
    return ShopController.Instance
end

function ShopController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1125_mall_pb"
    self:RegisterProtocal(proto.MALL_GETLIMIT, self.HandleLimitItemList)
    self:RegisterProtocal(proto.MALL_BUY, self.HandleBuyGoods)
    self:RegisterProtocal(proto.MALL_BOUGHT, self.HandleSlotGoods)
    self:RegisterProtocal(proto.MALL_VALIDATE, self.HandleValidate)

    --活动商品
    self:RegisterProtocal(proto.MALL_ACT_ITEMS, self.HandleActItems)
    -- 打包带走
    self:RegisterProtocal(proto.MALL_BUY_PACK, self.HandlePackMallInfo)
end

function ShopController:AddEvents()
    GlobalEvent:AddListener(ShopEvent.OpenShopPanel, handler(self, self.HandleOpenShopPanel))
    GlobalEvent:AddListener(ShopEvent.BuyShopGoods, handler(self, self.RequestBuyGoods))
    GlobalEvent:AddListener(ShopEvent.GetShopItemList, handler(self, self.RequestSlotGoods))
    GlobalEvent:AddListener(ShopEvent.OpenBuyFairyPanel, handler(self, self.OpenBuyFairyPanel))

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(FairyTiyanPanel):Open()
    end
    GlobalEvent:AddListener(ShopEvent.OpenFairyTiyanPanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(BeastActivityPanel):Open()
    end
    GlobalEvent:AddListener(ShopEvent.OpenBeastActivityPanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(GundamLimitBuyPanel):Open()
    end
    GlobalEvent:AddListener(ShopEvent.OpenGundamLimitBuyPanel, call_back)


    local function call_back()
        lua_panelMgr:GetPanelOrCreate(PetEquipBuyPanel):Open()
    end
    GlobalEvent:AddListener(ShopEvent.OpenPetBuyPanel, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MagicBuyPanel):Open()
    end
    GlobalEvent:AddListener(ShopEvent.OpenMagicBuyPanel, call_back)

    --打开图腾限购界面
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(TotemBuyPanel):Open()
    end
    GlobalEvent:AddListener(ShopEvent.OpenTotemBuyPanel, call_back)

    local function call_back()
        self:RequestLimitItemList()
    end
    RoleInfoModel:GetInstance():GetMainRoleData():BindData("level", call_back)
    GlobalEvent:AddListener(EventName.CrossDayAfter, call_back)

    local function call_back()
        if OpenTipModel.GetInstance():IsOpenSystem(1420, 1) then
            local beast_list = self.model:GetBeastList()
            local flag = true
            if table.isempty(beast_list) then
                flag = false
            else
                local end_time = beast_list[1].end_time
                if end_time <= os.time() then
                    flag = false
                end
            end
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "beast_limit", flag)
        end

        if OpenTipModel.GetInstance():IsOpenSystem(1420, 3) then
            local beast_list = self.model:GetPetEquipList()
            local flag = true
            if table.isempty(beast_list) then
                flag = false
            else
                local end_time = beast_list[1].end_time
                if end_time <= os.time() then
                    flag = false
                end
            end
            GlobalEvent:Brocast(MainEvent.ChangeRightIcon, "pet_limit", flag)
        end

    end
    GlobalEvent:AddListener(ShopEvent.UpdateFlashSale, call_back)

    -- 打包带走
    local function call_back()
        local id = OperateModel:GetInstance():GetPackMallID()
        if id then
            self.model.packmallId = id
            lua_panelMgr:GetPanelOrCreate(PackMallPanel):Open()
        else
            logError("未开启 打包带走 活动")
        end
    end
    GlobalEvent:AddListener(ShopEvent.OpenPackMallActivityPanel, call_back)

end

function ShopController:OpenBuyFairyPanel(uid, item_id)
    lua_panelMgr:GetPanelOrCreate(BuyFairyPanel):Open(uid, item_id)
end

function ShopController:HandleOpenShopPanel(id, sub_id, label_id, top_toggle_id, shop_id)
    self:RequestLimitItemList()
    lua_panelMgr:GetPanelOrCreate(ShopPanel):Open(id, sub_id, label_id, top_toggle_id, shop_id)
end

-- overwrite
function ShopController:GameStart()
    local function step()
        self:RequestLimitItemList()
        self:RequestSlotGoods()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Super)
end

--请求限时抢购商品列表
function ShopController:RequestLimitItemList()
    self:WriteMsg(proto.MALL_GETLIMIT)
end

function ShopController:HandleLimitItemList()
    local list = {}
    local data = self:ReadMsg("m_mall_getlimit_toc")
    --dump(data, "<color=#6ce19b>HandleLimitItemList   HandleLimitItemList  HandleLimitItemList  HandleLimitItemList</color>")
    if table.nums(data.limit_items) < 1 then
        self.model:SetFlashSaleList(list)
    else
        self.model:SetFlashSaleList(data.limit_items)
    end
    GlobalEvent:Brocast(ShopEvent.UpdateFlashSale)
    local time = self.model:GetFlashLongestLimit()
    if time then
        GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "shop", true, handler(self, self.OpenShop), nil, time - os.time(), nil)
    else
        GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "shop", false, handler(self, self.OpenShop), nil, os.time(), nil)
    end
end

--续期
function ShopController:RequestValidate(goodsId, uid)
    local pb = self:GetPbObject("m_mall_validate_tos")
    pb.id = tonumber(goodsId)
    pb.uid = tonumber(uid)
    self:WriteMsg(proto.MALL_VALIDATE, pb)
end

function ShopController:HandleValidate()
    Notify.ShowText("Renewal successful")
    BagController.Instance:RequestBagInfo(BagModel.bagId)
end

--购买商品
function ShopController:RequestBuyGoods(goodsId, num)
    local pb = self:GetPbObject("m_mall_buy_tos")
    pb.id = tonumber(goodsId)
    pb.num = tonumber(num)
    self:WriteMsg(proto.MALL_BUY, pb)
end

function ShopController:HandleBuyGoods()
    local data = self:ReadMsg("m_mall_buy_toc")
    local id = tonumber(data.id)
    local tips = "Purchased!"
    Notify.ShowText(tips)
    if id >= 1000 and id < 1100 then
        BrocastModelEvent(CardEvent.CARD_EXCHANGE);
    end
    GlobalEvent:Brocast(ShopEvent.SuccessToBuyGoodsInShop, id)
end

--请求商品已购买数量
function ShopController:RequestSlotGoods()
    self:WriteMsg(proto.MALL_BOUGHT)
end

function ShopController:HandleSlotGoods()
    local data = self:ReadMsg("m_mall_bought_toc")
    --dump(data, "<color=#6ce19b>Handle_Shop_Slot_Goods   Handle_Shop_Slot_Goods  Handle_Shop_Slot_Goods  Handle_Shop_Slot_Goods</color>")
    if not self.model.isRecivingSingle then
        self.model:SetGoodsBoughtList(data.bought_items)
        GlobalEvent:Brocast(ShopEvent.HandelShopBoughtList)
    else
        self.model.isRecivingSingle = false
        self.model.goodsSingelBought = data.bought_items
        GlobalEvent:Brocast(ShopEvent.HandleSingleBought)
    end
end

function ShopController:OpenShop()
    lua_panelMgr:GetPanelOrCreate(ShopPanel):Open()
end

function ShopController:RequestActItems(actID)
    local pb = self:GetPbObject("m_mall_act_items_tos")
    pb.act_id = tonumber(actID)
    self:WriteMsg(proto.MALL_ACT_ITEMS, pb)
end

function ShopController:HandleActItems()
    local data = self:ReadMsg("m_mall_act_items_toc")
    GlobalEvent:Brocast(ShopEvent.HandleActItems, data)
    --  m_mall_act_items_toc
end

-- 打包带走
function ShopController:HandleBuyInfo(id)
    local pb = self:GetPbObject("m_mall_buy_pack_tos")
    pb.act_id = tonumber(id)
    self:WriteMsg(proto.MALL_BUY_PACK, pb)
end

function ShopController:HandlePackMallInfo()
    local data = self:ReadMsg("m_mall_buy_pack_toc")
    local tips = "Purchased!"
    Notify.ShowText(tips)
end
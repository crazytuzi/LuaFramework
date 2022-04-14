

require("game.market.RequireMarket")
MarketController = MarketController or class("MarketController", BaseController)
local MarketController = MarketController

function MarketController:ctor()
    MarketController.Instance = self
    self.model = MarketModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function MarketController:dctor()
end

function MarketController:GetInstance()
    if not MarketController.Instance then
        MarketController.new()
    end
    return MarketController.Instance
end

function MarketController:GameStart()
    local function step()
        self:RequeseDealingInfo()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Ordinary)
end



function MarketController:RegisterAllProtocal()
    self.pb_module_name = "pb_1113_market_pb"
    ---市场
    self:RegisterProtocal(proto.MARKET_STAT, self.HandleBigTypeInfo);
    self:RegisterProtocal(proto.MARKET_LIST, self.HandleSellListInfo);
    self:RegisterProtocal(proto.MARKET_SEARCH, self.HandleSearchInfo);
    self:RegisterProtocal(proto.MARKET_DETAIL, self.HandleGoodInfo);
    self:RegisterProtocal(proto.MARKET_BUY, self.HandleBuyItem);

    ------上架
    self:RegisterProtocal(proto.MARKET_SALING, self.HandleSalingInfo);  --已上架商品
    self:RegisterProtocal(proto.MARKET_SALE, self.HandleSaleInfo);
    self:RegisterProtocal(proto.MARKET_REMOVE, self.HandleRemove); -- 下架
    self:RegisterProtocal(proto.MARKET_ALTER, self.HandleAlter); -- 修改
    self:RegisterProtocal(proto.MARKET_DEAL, self.HandleDeal); --指定交易


    --交易记录
    self:RegisterProtocal(proto.MARKET_LOG, self.HandleLogInfo);

    --指定交易
    self:RegisterProtocal(proto.MARKET_DEALING, self.HandleDealingInfo);
    self:RegisterProtocal(proto.MARKET_REFUSE, self.HandleRefuse);

    self:RegisterProtocal(proto.MARKET_DEALTIMES, self.HandleDealTimes);


end

function MarketController:AddEvents()
	GlobalEvent:AddListener(MarketEvent.OpenMarketPanel, handler(self, self.HandleOpenMarketPanel))

    local function call_back(data)
        lua_panelMgr:GetPanelOrCreate(UpShelfTowPanel):Open(data)
    end
    GlobalEvent:AddListener(MarketEvent.OpenUpShelfTowPanel, call_back)

    local function call_back(data,isBag)
        if isBag then
            lua_panelMgr:GetPanelOrCreate(UpShelfTowPanel):Open(data)
        end
    end
    GlobalEvent:AddListener(MarketEvent.UpShelfMarketUpBtn, call_back)
end

function MarketController:HandleOpenMarketPanel()
	lua_panelMgr:GetPanelOrCreate(MarketPanel):Open()
end
--------------------------市场
--请求左侧大类的信息
function MarketController:RequeseBigTypeInfo(typeID)
    local pb = self:GetPbObject("m_market_stat_tos")
    pb.type = tonumber(typeID)
    self:WriteMsg(proto.MARKET_STAT,pb)
end

--返回左侧大类的信息
--map<int32, int32> stat = 2; // key=子类, val=数量
function MarketController:HandleBigTypeInfo()
    local data = self:ReadMsg("m_market_stat_toc")
    local items = data.stat
    GlobalEvent:Brocast(MarketEvent.BuyMarketUpdateBigTypeData,data)

end

--请求商品列表
--type 类型
--stype 子类型
-- sort 排序方式
function MarketController:RequeseSellListInfo(type,stype)
    local pb = self:GetPbObject("m_market_list_tos")
    pb.type = tonumber(type)
    pb.stype = tonumber(stype)
   -- pb.sort = tonumber(sort)
    self:WriteMsg(proto.MARKET_LIST,pb)
end

--返回商品列表
function MarketController:HandleSellListInfo()
    local data = self:ReadMsg("m_market_list_toc")
   -- self.model.sellItem = data.items   --商品列表
    self.model.SellItems = data.items
    GlobalEvent:Brocast(MarketEvent.BuyMarketUpdateSellItemData,data.items)
end


--请求物品详情
function MarketController:RequeseGoodInfo(uid)
    local pb = self:GetPbObject("m_market_detail_tos")
    pb.uid = uid
    self:WriteMsg(proto.MARKET_DETAIL,pb)
end
---返回物品详细信息
function MarketController:HandleGoodInfo()
    local data = self:ReadMsg("m_market_detail_toc")
    local itemId = data.item.id
    --print2(itemId)
    local itemCfg = Config.db_item[itemId]
    if self.model.isOpenUpShelfMarketTwo then
       -- print2("二级界面")
        GlobalEvent:Brocast(MarketEvent.ReturnPitem,data)
        return
    end
    --print2(itemCfg.type.."物品类型")
    if itemCfg.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
        GlobalEvent:Brocast(MarketEvent.BuyMarketUpdateGoodData,data)   -- 装备类型
    elseif itemCfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
        GlobalEvent:Brocast(MarketEvent.BuyMarketUpdateThreeGoodData,data)  --宠物装备类型
    else
        GlobalEvent:Brocast(MarketEvent.BuyMarketUpdateTwoGoodData,data) --非装备类型
    end

end




--请求搜索
function MarketController:RequeseSearchInfo(ids)
    local pb = self:GetPbObject("m_market_search_tos")
    for k,v in pairs(ids) do
        pb.item_ids:append(v)
    end
   -- pb.item_ids = ids
    self:WriteMsg(proto.MARKET_SEARCH,pb)
end


--返回搜索
function MarketController:HandleSearchInfo()
    local data = self:ReadMsg("m_market_search_toc")
    self.model.SellItems = data.items
    GlobalEvent:Brocast(MarketEvent.BuyMarketUpdateSearchItemData,data)
end


--请求购买
function MarketController:RequeseBuyItem(type,uid,num,price)
    if RoleInfoModel:GetInstance():CheckGold(price * num,Constant.GoldType.GreenGold) then
        local pb = self:GetPbObject("m_market_buy_tos")
        pb.type = tonumber(type)
        pb.uid = uid
        pb.num = tonumber(num)
        pb.price = tonumber(price)
        self:WriteMsg(proto.MARKET_BUY,pb)
    end

end



--返回购买
function MarketController:HandleBuyItem()
    Notify.ShowText("Purchased")
    local data = self:ReadMsg("m_market_buy_toc")
    if data.type == 1 then
        GlobalEvent:Brocast(MarketEvent.BuyMarketBuyItemData,data)
    else
        self.model:DeathAppointBuyInfo(data.uid)
        self.model:CheckRedPoint()
        GlobalEvent:Brocast(MarketEvent.MarketDesignatedBuy,data)
    end
end


----------------------------------end



-----------------------上架

--请求上架物品列表
function MarketController:RequeseSalingInfo()
    local pb = self:GetPbObject("m_market_saling_tos")
    self:WriteMsg(proto.MARKET_SALING,pb)
end



---已上架商品返回
function MarketController:HandleSalingInfo()
    local data = self:ReadMsg("m_market_saling_toc")
    self.model.saleList = data.items
    GlobalEvent:Brocast(MarketEvent.UpShelfMarketSalingInfo,data.items)
end



--上架请求
function MarketController:RequeseSaleInfo(uid,num,price)
    local pb = self:GetPbObject("m_market_sale_tos")
    pb.uid = uid
    pb.num = tonumber(num)
    pb.price = tonumber(price)
    self:WriteMsg(proto.MARKET_SALE,pb)
end

function MarketController:HandleSaleInfo()
    Notify.ShowText("Added to shelf")
    local data = self:ReadMsg("m_market_sale_toc")
    GlobalEvent:Brocast(MarketEvent.UpShelfMarketSaleInfo,data)
end

--下架请求
function MarketController:RequeseRemove(type,uid)
    local pb = self:GetPbObject("m_market_remove_tos")
    pb.type = tonumber(type)
    pb.uid = uid
    self:WriteMsg(proto.MARKET_REMOVE,pb)
end

--下架返回
function MarketController:HandleRemove()
    Notify.ShowText("Removed from shelf")
    local data = self:ReadMsg("m_market_remove_toc")
    GlobalEvent:Brocast(MarketEvent.UpShelfMarketRemove,data)
end


--请求修改
function MarketController:RequeseAlter(uid,price)
    local pb = self:GetPbObject("m_market_alter_tos")
    pb.uid = uid
    pb.price = tonumber(price)
    self:WriteMsg(proto.MARKET_ALTER,pb)
end


--修改返回
function MarketController:HandleAlter()
    Notify.ShowText("Edited")
    local data = self:ReadMsg("m_market_alter_toc")
    GlobalEvent:Brocast(MarketEvent.UpShelfMarketAlter,data)
end





------------------------end


--------------------指定交易

function MarketController:RequeseDealingInfo()
    local pb = self:GetPbObject("m_market_dealing_tos")

    self:WriteMsg(proto.MARKET_DEALING,pb)
end



function MarketController:HandleDealingInfo()
    local data = self:ReadMsg("m_market_dealing_toc")
    self.model.leftDealInfos = data.from_me
    self.model.rightDealInfos = data.to_me
    self.model:CheckRedPoint()
    GlobalEvent:Brocast(MarketEvent.MarketDesignatedDealing,data)
end

function MarketController:RequeseRefuse(uid)
    local pb = self:GetPbObject("m_market_refuse_tos")
    pb.uid = uid
    self:WriteMsg(proto.MARKET_REFUSE,pb)
end



function MarketController:HandleRefuse()
    local data = self:ReadMsg("m_market_refuse_toc")
    self.model:DeathAppointBuyInfo(data.uid)
    GlobalEvent:Brocast(MarketEvent.MarketDesignatedRefuse,data)
end
--请求指定交易上架
function MarketController:RequeseDeal(to_role,item_uid,item_num,price)
    local pb = self:GetPbObject("m_market_deal_tos")
    pb.to_role = tostring(to_role)
    pb.item_uid = tonumber(item_uid)
    pb.item_num = tonumber(item_num)
    pb.price = tonumber(price)
    self:WriteMsg(proto.MARKET_DEAL,pb)
end

--返回指定交易
function MarketController:HandleDeal()
    --Notify.ShowText("指定交易上架成功")
    local data = self:ReadMsg("m_market_deal_toc")
    if data.deal.from_id ~= RoleInfoModel:GetInstance():GetMainRoleId() then
        self.model:AddAppointBuyInfo(data.deal)
        self.model:CheckRedPoint()
    end
    GlobalEvent:Brocast(MarketEvent.UpShelfMarketDeal,data)
end

-------------------end





--------------------------交易记录

function MarketController:RequeseLogInfo()
    local pb = self:GetPbObject("m_market_log_tos")
    self:WriteMsg(proto.MARKET_LOG,pb)
end


function MarketController:HandleLogInfo()
    local data = self:ReadMsg("m_market_log_toc")
    GlobalEvent:Brocast(MarketEvent.MarketRecordUpdateRecord,data)
end

--------------------------end


---次数返回
function MarketController:HandleDealTimes()
    local data = self:ReadMsg("m_market_dealtimes_toc")
    GlobalEvent:Brocast(MarketEvent.BuyMarketReturnTimes,data)
end

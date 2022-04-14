UpshelfMarketSettor = UpshelfMarketSettor or class("UpshelfMarketSettor", BaseBagIconSettor)
local UpshelfMarketSettor = UpshelfMarketSettor

function UpshelfMarketSettor:ctor(parent_node, layer)
    self.abName = "system"
    self.assetName = "BagItem"
    self.layer = layer


    UpshelfMarketSettor.super.Load(self)
end

function UpshelfMarketSettor:AddEvent()
    UpshelfMarketSettor.super.AddEvent(self)
    AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end
--处理装备(物品)详细信息,要重载
--第1个参数 请求物品的返回的p_item (必传)
--第2个参数 对请求的物品的操作参数 (看着办)
--第3个参数 身上穿的,装备的        (看着办)
function UpshelfMarketSettor:DealGoodsDetailInfo(...)
    if not self.gameObject.activeInHierarchy then
        return
    end
    local param = { ... }
    local item = param[1]

    if item.uid ~= self.uid then
        return
    end

    local operate_param = {}
    if item.bag == BagModel.bagId then   --是背包中的物品
        GoodsTipController.Instance:SetPutOnSellCB(operate_param,
                handler(self,self.UpShelf),{item})
        UpshelfMarketSettor.super.DealGoodsDetailInfo(self,item,operate_param,nil,true)
    elseif item.bag == BagModel.Pet then
        local pos = self.transform.position
        local view = PetShowTipView()
        view:SetData(item,PetModel.TipType.PetMarket,pos,handler(self,self.UpShelf),{item})

    end
end

function UpshelfMarketSettor:UpShelf(item)
    --print2("-------1-1-----------")
    GlobalEvent:Brocast(MarketEvent.UpShelfMarketUpBtn, 1)
    MarketModel.GetInstance().selectItem = item[1]
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end
--function UpshelfMarketSettor:ClickEvent()
--
--end
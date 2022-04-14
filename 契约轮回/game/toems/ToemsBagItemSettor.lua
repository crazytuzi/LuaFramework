---
--- Created by  Administrator
--- DateTime: 2020/7/27 18:51
---
ToemsBagItemSettor = ToemsBagItemSettor or class("ToemsBagItemSettor", BaseBagIconSettor)
local this = ToemsBagItemSettor

function ToemsBagItemSettor:ctor(parent_node,layer)
    self.abName = "system"
    self.assetName = "BagItem"
    self.layer = layer

    self.model = ToemsModel:GetInstance()
    ToemsBagItemSettor.super.Load(self)
end

function ToemsBagItemSettor:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function ToemsBagItemSettor:AddEvent()
    ToemsBagItemSettor.super.AddEvent(self)


    AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end

--处理装备(物品)详细信息,要重载
--第1个参数 请求物品的返回的p_item (必传)
--第2个参数 对请求的物品的操作参数 (看着办)
--第3个参数 身上穿的,装备的        (看着办)
function ToemsBagItemSettor:DealGoodsDetailInfo(...)
    if self.gameObject and tostring(self.gameObject) ~= "null" and not self.gameObject.activeInHierarchy then
        return
    end

    local param = { ... }
    local item = param[1]

    if item.uid ~= self.uid then
        return
    end

    local operate_param = {}
    if item.bag == BagModel.toems then   --是背包中的物品
        local param = {}
        local operate_param = {}
        GoodsTipController.Instance:SetPutOnCB(operate_param, handler(self, self.PutOnEquip), { item })
        local cfg = Config.db_item[item.id]
        if cfg then
            local compose = cfg.compose
            if not table.isempty(String2Table(compose)) then
                GoodsTipController.Instance:SetComposeCB(operate_param, handler(self, self.ComposeEquip), { item, String2Table(compose)})
            end
        end
        -- GoodsTipController.Instance:SetComposeCB(operate_param, handler(self, self.ComposeEquip), { item })
        GoodsTipController.Instance:SetSellCB(operate_param, handler(self, self.SellEquip), { item })
        ToemsBagItemSettor.super.DealGoodsDetailInfo(self,item,operate_param)
    end
end

function ToemsBagItemSettor:PutOnEquip(param)
    if not self.model then
        return;
    end
    local str = self.model:CheckCanEquip(param[1].uid);
    if str then
        Notify.ShowText(str);
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
        return;
    end
    ToemsController:GetInstance():RequesEquipLoadInfo(self.model.currentBeastEquip, param[1].uid)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end
function ToemsBagItemSettor:ComposeEquip(prarm,tab)
    --OpenLink(170, 1, 1, true)
    local opLv = Config.db_equip_combine_sec_type[108].open_level
    if RoleInfoModel:GetInstance():GetMainRoleLevel() >= opLv then
        OpenLink(unpack(prarm[2]))
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    else
        Notify.ShowText(opLv.."Unlocks at Lv.X")
    end


end

function ToemsBagItemSettor:SellEquip(_param)
    local itemConfig = Config.db_item[_param[1].id];
    local param = {}
    local kv = { key = _param[1].uid, value = 1 };
    table.insert(param, kv);
    local fun = function()
        GoodsController.Instance:RequestSellItems(param);
    end
    if itemConfig.color >= enum.COLOR.COLOR_RED then
        Dialog.ShowTwo("Notice", "You will sell a precious totem gear, confirm the sale?", "Yes", fun, nil, "Cancle");
    else
        GoodsController.Instance:RequestSellItems(param);
    end

    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end
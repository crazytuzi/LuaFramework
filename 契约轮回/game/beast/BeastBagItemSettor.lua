--
-- @Author: chk
-- @Date:   2019-02-25 21:45:18
--
BeastBagItemSettor = BeastBagItemSettor or class("BeastBagItemSettor",BaseBagIconSettor)
local this = BeastBagItemSettor

function BeastBagItemSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "BagItem"
	self.layer = layer

	self.model = BeastModel:GetInstance()
	BeastBagItemSettor.super.Load(self)
end

function BeastBagItemSettor:AddEvent()
    BeastBagItemSettor.super.AddEvent(self)


    AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end

--处理装备(物品)详细信息,要重载
--第1个参数 请求物品的返回的p_item (必传)
--第2个参数 对请求的物品的操作参数 (看着办)
--第3个参数 身上穿的,装备的        (看着办)
function BeastBagItemSettor:DealGoodsDetailInfo(...)
    if self.gameObject and tostring(self.gameObject) ~= "null" and not self.gameObject.activeInHierarchy then
        return
    end

    local param = { ... }
    local item = param[1]

    if item.uid ~= self.uid then
        return
    end

    local operate_param = {}
    if item.bag == BagModel.beast then   --是背包中的物品
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
        BeastBagItemSettor.super.DealGoodsDetailInfo(self,item,operate_param)
    end
end

function BeastBagItemSettor:PutOnEquip(param)
    if not self.model then
        return;
    end
    local str = self.model:CheckCanEquip(param[1].uid);
    if str then
        Notify.ShowText(str);
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
        return;
    end
    BeastCtrl:GetInstance():RequestEquipLoad(self.model.currentBeastEquip, param[1].uid)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end
function BeastBagItemSettor:ComposeEquip(prarm,tab)
    --OpenLink(170, 1, 1, true)
    local opLv = Config.db_equip_combine_sec_type[106].open_level
    if RoleInfoModel:GetInstance():GetMainRoleLevel() >= opLv then
        OpenLink(unpack(prarm[2]))
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    else
        Notify.ShowText(opLv.."Unlocks at Lv.X")
    end


end

function BeastBagItemSettor:SellEquip(_param)
    local itemConfig = Config.db_item[_param[1].id];
    local param = {}
    local kv = { key = _param[1].uid, value = 1 };
    table.insert(param, kv);
    local fun = function()
        GoodsController.Instance:RequestSellItems(param);
    end
    if itemConfig.color >= enum.COLOR.COLOR_RED then
        Dialog.ShowTwo("Tip", "You are going to sell a rare beast gear, sale?", "Confirm", fun, nil, "Cancel");
    else
        GoodsController.Instance:RequestSellItems(param);
    end

    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
end
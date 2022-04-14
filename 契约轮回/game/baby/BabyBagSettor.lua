---
--- Created by  Administrator
--- DateTime: 2019/11/12 11:03
---
BabyBagSettor = BabyBagSettor or class("BabyBagSettor", BaseBagIconSettor)
local this = BabyBagSettor

function BabyBagSettor:ctor(parent_node, layer)
    self.abName = "system"
    self.assetName = "BagItem"
    self.layer = layer

    BabyBagSettor.super.Load(self)
end




function BabyBagSettor:AddEvent()
    BabyBagSettor.super.AddEvent(self)
    AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end

--处理装备(物品)详细信息,要重载
--第1个参数 请求物品的返回的p_item (必传)
--第2个参数 对请求的物品的操作参数 (看着办)
--第3个参数 身上穿的,装备的        (看着办)
function BabyBagSettor:DealGoodsDetailInfo(...)
    if not self.gameObject.activeInHierarchy then
        return
    end
    local param = { ... }
    local item = param[1]

    if item.uid ~= self.uid then
        return
    end

    local operate_param = {}
    if item.bag == BagModel.baby then   --是背包中的物品
        local id = item.id
        local itemCfg = Config.db_baby_equip[id]
        local slot = itemCfg.slot
        if BabyModel:GetInstance():GetPutOnBySlot(slot) then
            GoodsTipController.Instance:SetDeplaceCB(operate_param,
                    handler(self,self.PutOn),{item})
        else
            GoodsTipController.Instance:SetPutOnCB(operate_param,
                    handler(self,self.PutOn),{item})
        end

        GoodsTipController.Instance:SetDecomposeCB(operate_param,
                handler(self,self.Decompose),{item})
        BabyBagSettor.super.DealGoodsDetailInfo(self,item,operate_param,nil)
    end
end

function BabyBagSettor:PutOn(param)
    if param then
        BabyController:GetInstance():RequstBabyEquipPutOn(param[1].uid)
    end
end

function BabyBagSettor:Decompose(param)
    if param then
        local str = ""
        local cfg = Config.db_baby_equip[param[1].id]
        local itemCfg = Config.db_item[param[1].id]
        local tab = String2Table(cfg.gain)
        local money = tab[1][1]
        local num = tab[1][2]
              --  <color=#%s>%s</color>", ColorUtil.GetColor(curCfg.color)
        str = string.format("Sure to dismantle<color=#%s>%s</color>，Can get:<color=#3ab60e>%sx%s</color>",ColorUtil.GetColor(itemCfg.color),itemCfg.name,enumName.ITEM[money],num)
        local function call_back()
            BabyController:GetInstance():RequstBabyEquipDecompose({param[1].uid})
        end
        Dialog.ShowTwo("Tip", str, "Confirm", call_back, nil, "Cancel", nil, nil)
    end
end

function BabyBagSettor:SelectItem(bagId, select)
    if BabyModel:GetInstance().isOpenDecompose then
        return
    end
    BabyBagSettor.super.SelectItem(self,bagId,select)
end
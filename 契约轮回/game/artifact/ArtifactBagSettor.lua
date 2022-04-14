---
--- Created by  Administrator
--- DateTime: 2020/6/24 9:46
---
ArtifactBagSettor = ArtifactBagSettor or class("ArtifactBagSettor", BaseBagIconSettor)
local this = ArtifactBagSettor

function ArtifactBagSettor:ctor(parent_node, parent_panel)
    self.abName = "system"
    self.assetName = "BagItem"

    ArtifactBagSettor.super.Load(self)
end

function ArtifactBagSettor:AddEvent()
    ArtifactBagSettor.super.AddEvent(self)
    AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end


function ArtifactBagSettor:DealGoodsDetailInfo(...)
    if not self.gameObject.activeInHierarchy then
        return
    end
    local param = { ... }
    local item = param[1]

    if item.uid ~= self.uid then
        return
    end

    local operate_param = {}
    if item.bag == BagModel.artifact then   --是背包中的物品
        local id = item.id
        local itemCfg = Config.db_item[id]
        
        local equipCfg = Config.db_equip[id]
        local slot = 0
        if equipCfg then
             slot = equipCfg.slot
            if itemCfg.stype == ArtifactModel:GetInstance().curArtId then
                if    ArtifactModel:GetInstance():GetEquipInfo(ArtifactModel:GetInstance().curArtId,slot) then
                    GoodsTipController.Instance:SetDeplaceCB(operate_param,
                            handler(self,self.PutOn),{item,slot})
                else
                    GoodsTipController.Instance:SetPutOnCB(operate_param,
                            handler(self,self.PutOn),{item,slot})
                end
            end
        end

        --if GodModel:GetInstance():GetPutOnBySlot(slot) then
        --    GoodsTipController.Instance:SetDeplaceCB(operate_param,
        --            handler(self,self.PutOn),{item,slot})
        --else
        --    GoodsTipController.Instance:SetPutOnCB(operate_param,
        --            handler(self,self.PutOn),{item,slot})
        --end

    end
    GodBagSettor.super.DealGoodsDetailInfo(self,item,operate_param,nil)
end

function ArtifactBagSettor:PutOn(param)
    if param then
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
        self.model.curPItem = param[1]
        ArtifactController:GetInstance():RequstArtifactPutOnInfo(ArtifactModel:GetInstance().curArtId,param[1].uid)
    end
end

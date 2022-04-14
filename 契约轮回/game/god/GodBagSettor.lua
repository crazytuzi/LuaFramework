---
--- Created by  Administrator
--- DateTime: 2019/11/29 11:33
---
GodBagSettor = GodBagSettor or class("GodBagSettor", BaseBagIconSettor)
local this = GodBagSettor

function GodBagSettor:ctor(parent_node, parent_panel)
    self.abName = "system"
    self.assetName = "BagItem"
    self.layer = layer

    GodBagSettor.super.Load(self)
end



function GodBagSettor:AddEvent()
    GodBagSettor.super.AddEvent(self)
    AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end


function GodBagSettor:DealGoodsDetailInfo(...)
    if not self.gameObject.activeInHierarchy then
        return
    end
    local param = { ... }
    local item = param[1]

    if item.uid ~= self.uid then
        return
    end

    local operate_param = {}
    if item.bag == BagModel.God then   --是背包中的物品
        local id = item.id
        local itemCfg = Config.db_god_equip[id]
        local slot = itemCfg.slot
        if GodModel:GetInstance():GetPutOnBySlot(slot) then
            GoodsTipController.Instance:SetDeplaceCB(operate_param,
                    handler(self,self.PutOn),{item,slot})
        else
            GoodsTipController.Instance:SetPutOnCB(operate_param,
                    handler(self,self.PutOn),{item,slot})
        end

        local itemCfg = Config.db_item[item.id]
        if itemCfg then
            local compose = itemCfg.compose
            if not table.isempty(String2Table(compose)) then
                GoodsTipController.Instance:SetComposeCB(operate_param, handler(self, self.ComposeEquip), { item, String2Table(compose)})
            end
        end

        GoodsTipController.Instance:SetDecomposeCB(operate_param,
                handler(self,self.Decompose),{item})
        GodBagSettor.super.DealGoodsDetailInfo(self,item,operate_param,nil)
    end
end

function GodBagSettor:ComposeEquip(prarm)
    local opLv = Config.db_equip_combine_sec_type[301].open_level
    if RoleInfoModel:GetInstance():GetMainRoleLevel() >= opLv then
        OpenLink(unpack(prarm[2]))
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    else
        Notify.ShowText(opLv.."Unlocks at Lv.X")
    end
end


function GodBagSettor:PutOn(param)
    if param then
        if self.model:GetSlotLock(param[2]) then --锁了
            local cfg = Config.db_god_equip_open[param[2]]
            if  cfg then
                local tab = String2Table(cfg.open)
                local str = ""
                local type = tab[1]
                if type == "own" then
                    local color = enumName.COLOR[tab[2]]
                    str = string.format("After having at least <color=#3ab60e>%s%s avatars,</color> you can unlock this slot.\nunlock now?",tab[3],color)
                elseif type == "dunge" then
                    str = string.format("Clear <color=#3ab60e>Path of Avatars %s wave.</color> You can unlock this slot.\nunlock now?",tab[2])
                end
                local function ok_func()
                    OpenLink(150,1,1,6)
                end
                Dialog.ShowTwo("Tip",str,"Go",ok_func)
            end
            return
        end
        GodController:GetInstance():RequstGodEquipPutOnInfo(param[1].uid)
    end
end

function GodBagSettor:Decompose(param)
    if param then
        local str = ""
        local cfg = Config.db_god_equip[param[1].id]
        local itemCfg = Config.db_item[param[1].id]
        local tab = String2Table(cfg.gain)
        local money = tab[1][1]
        local num = tab[1][2]
        --  <color=#%s>%s</color>", ColorUtil.GetColor(curCfg.color)
        str = string.format("Sure to dismantle<color=#%s>%s</color>，Can get:<color=#3ab60e>%sx%s</color>",ColorUtil.GetColor(itemCfg.color),itemCfg.name,enumName.ITEM[money],num)
        local function call_back()
            GodController:GetInstance():RequstGodEquipDecomposeInfo({param[1].uid})
        end
        Dialog.ShowTwo("Tip", str, "Confirm", call_back, nil, "Cancel", nil, nil)
    end
end

function GodBagSettor:SelectItem(bagId, select)
    if GodModel:GetInstance().isOpenDecompose then
        return
    end
    GodBagSettor.super.SelectItem(self,bagId,select)
end
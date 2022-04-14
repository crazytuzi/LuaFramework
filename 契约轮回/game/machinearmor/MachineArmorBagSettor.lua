---
--- Created by  Administrator
--- DateTime: 2019/12/24 19:58
---
MachineArmorBagSettor = MachineArmorBagSettor or class("MachineArmorBagSettor", BaseBagIconSettor)
local this = MachineArmorBagSettor

function MachineArmorBagSettor:ctor(parent_node, parent_panel)

    self.abName = "system"
    self.assetName = "BagItem"
    self.layer = layer

    MachineArmorBagSettor.super.Load(self)
end


function MachineArmorBagSettor:AddEvent()
    MachineArmorBagSettor.super.AddEvent(self)
    AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end

function MachineArmorBagSettor:DealGoodsDetailInfo(...)
    if not self.gameObject.activeInHierarchy then
        return
    end
    local param = { ... }
    local item = param[1]

    if item.uid ~= self.uid then
        return
    end

    local operate_param = {}
    if item.bag == BagModel.mecha then   --是背包中的物品
        local id = item.id
        local itemCfg = Config.db_mecha_equip[id]
        local slot = itemCfg.slot
        if MachineArmorModel:GetInstance():GetPutOnBySlot(MachineArmorModel.GetInstance().curMecha,slot) then
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
        --
        --
        GoodsTipController.Instance:SetDecomposeCB(operate_param,
                handler(self,self.Decompose),{item})
        MachineArmorBagSettor.super.DealGoodsDetailInfo(self,item,operate_param,nil)
    end
end



function MachineArmorBagSettor:PutOn(param)
    if param then
        local mechaId = MachineArmorModel.GetInstance().curMecha
       local isOwner,ownerId =  MachineArmorModel.GetInstance():isOwnerEquip(param[1].id)
        if isOwner then
            if ownerId ~= mechaId then
                Notify.ShowText("This equipment is exclusive for another mecha")
                return
            end
        end


      --  MachineArmorController:GetInstance():RequstEquipPutOnInfo(MachineArmorModel.GetInstance().curMecha,param[1].uid)
        if MachineArmorModel.GetInstance():isSlotLock(mechaId,param[2]) then --锁了
            local cfg = Config.db_mecha_equip_open[mechaId.."@"..param[2]]
            if  cfg then
                local tab = String2Table(cfg.open)
                local str = ""
                local type = tab[1]
                if type == "star" then
                    --local color = enumName.COLOR[tab[2]]
                    local star = tab[2]
                    local showCfg = Config.db_mecha_star[mechaId.."@"..star]
                    str = string.format("Unlock at Mecha T%sS%s",showCfg.star_client,showCfg.plot_client)
                end
                local function ok_func()
                   -- OpenLink(150,1,1,6)
                end
                Dialog.ShowTwo("Tip",str,"Confirm",ok_func)
            end
            return
        end
        MachineArmorController:GetInstance():RequstEquipPutOnInfo(mechaId,param[1].uid)
    end
end

function MachineArmorBagSettor:Decompose(param)
    if param then
        local str = ""
        local cfg = Config.db_mecha_equip[param[1].id]
        local itemCfg = Config.db_item[param[1].id]
        local tab = String2Table(cfg.gain)
        local money = tab[1][1]
        local num = tab[1][2]
        --  <color=#%s>%s</color>", ColorUtil.GetColor(curCfg.color)
        str = string.format("Sure to dismantle<color=#%s>%s</color>，Can get:<color=#3ab60e>%sx%s</color>",ColorUtil.GetColor(itemCfg.color),itemCfg.name,enumName.ITEM[money],num)
        local function call_back()
            MachineArmorController:GetInstance():RequstEquipDecomposeInfo({param[1].uid})
        end
        Dialog.ShowTwo("Tip", str, "Confirm", call_back, nil, "Cancel", nil, nil)
    end
end

function MachineArmorBagSettor:SelectItem(bagId, select)
    if MachineArmorModel:GetInstance().isOpenDecompose then
        return
    end
    MachineArmorBagSettor.super.SelectItem(self,bagId,select)
end

function MachineArmorBagSettor:ComposeEquip(prarm)
    local opLv = Config.db_equip_combine_sec_type[302].open_level
    if RoleInfoModel:GetInstance():GetMainRoleLevel() >= opLv then
        OpenLink(unpack(prarm[2]))
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    else
        Notify.ShowText(opLv.."Unlocks at Lv.X")
    end
end

--function MachineArmorBagSettor:AddItem(bagId, index)
--    if self.bag == bagId and self.__item_index == index and self.get_item_cb ~= nil then
--        local param = {}
--        local itemBase = self.get_item_cb(index)
--        if itemBase ~= nil then
--            local itemConfig = Config.db_item[itemBase.id]
--            param["itemIndex"] = index
--            param["type"] = itemConfig.type
--            param["uid"] = itemBase.uid
--            param["id"] = itemConfig.id
--            param["num"] = itemBase.num
--            param["bag"] = self.bag
--            param["bind"] = itemBase.bind
--            param["itemSize"] = {x=78, y=78}
--            param["outTime"] = itemBase.etime
--            param["multy_select"] = self.is_multy_selet
--            param["get_item_select_cb"] = self.get_item_select_cb
--            param["get_item_cb"] = self.get_item_cb
--            param["model"] = self.model
--            param["selectItemCB"] = self.selectItemCB
--            param["click_call_back"] = self.click_call_back
--            param["quick_double_click_call_back"] = self.quick_double_click_call_back
--            param["stencil_id"] = self.stencil_id
--        end
--        self:UpdateItem(param)
--    end
--end
---
--- Created by  Administrator
--- DateTime: 2019/12/25 16:52
---
MachineArmorEquipSettor = MachineArmorEquipSettor or class("MachineArmorEquipSettor", BaseBagGoodsSettor)
local this = MachineArmorEquipSettor

--MachineArmorEquipSettor.__cache_count=50
function MachineArmorEquipSettor:ctor(parent_node, layer)

    self.abName = "system"
    self.assetName = "EquipItem"
    self.layer = layer
    self.stepLbl = nil
    MachineArmorEquipSettor.super.Load(self)
end



function MachineArmorEquipSettor:LoadCallBack()
    self.nodes = {
        "upPowerTip",
        "downPowerTip",
        "notCantPutPutOn",
        "stepTxt",
    }

    self:GetChildren(self.nodes)
    -- self.stepLbl = self.stepTxt:GetComponent('Text')
    MachineArmorEquipSettor.super.LoadCallBack(self)
end


function MachineArmorEquipSettor:UpdateInfo(param)
    MachineArmorEquipSettor.super.UpdateInfo(self, param)

    if self.is_loaded then
        SetVisible(self.stepTxt,false)
        SetVisible(self.starContain,false)
        self:UpdateFightPowerTip()
        --self:UpdateFightEff()
    end
end

function MachineArmorEquipSettor:UpdateFightPowerTip()
    local slot = self.cfg.slot
    local curID = MachineArmorModel:GetInstance().curMecha
    local equip = MachineArmorModel:GetInstance():GetPutOnBySlot(curID,slot)
    --MachineArmorModel:GetInstance():isOwnerEquip()
    local ownerID = self.cfg.mecha_id
    if ownerID == 0 then --不是专属
        if MachineArmorModel:GetInstance():isSlotLock(curID,slot) then
            SetVisible(self.notCantPutPutOn,true)
        else
            SetVisible(self.notCantPutPutOn,false)
            if not equip then
                SetVisible(self.upPowerTip, true)
                SetVisible(self.downPowerTip, false)
            else
                local equipID = equip.id
                local cfg = Config.db_item[equipID]
                local curCfg = Config.db_item[self.id]
                SetVisible(self.upPowerTip, curCfg.color > cfg.color)
                SetVisible(self.downPowerTip, curCfg.color < cfg.color)
            end
        end
    else --是专属
        if ownerID == curID then
            if MachineArmorModel:GetInstance():isSlotLock(curID,slot) then
                SetVisible(self.notCantPutPutOn,true)
            else
                SetVisible(self.notCantPutPutOn,false)
                if not equip then
                    SetVisible(self.upPowerTip, true)
                    SetVisible(self.downPowerTip, false)
                else
                    local equipID = equip.id
                    local cfg = Config.db_item[equipID]
                    local curCfg = Config.db_item[self.id]
                    SetVisible(self.upPowerTip, curCfg.color > cfg.color)
                    SetVisible(self.downPowerTip, curCfg.color < cfg.color)
                end
            end
        else
            SetVisible(self.notCantPutPutOn,true)
        end
    end



end
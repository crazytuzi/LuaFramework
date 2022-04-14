---
--- Created by  Administrator
--- DateTime: 2019/11/29 11:42
---
GodEquipSettor = GodEquipSettor or class("GodEquipSettor", BaseBagGoodsSettor)
local this = GodEquipSettor

GodEquipSettor.__cache_count=50
function GodEquipSettor:ctor(parent_node, layer)

    self.abName = "system"
    self.assetName = "EquipItem"
    self.layer = layer
    self.stepLbl = nil
    GodEquipSettor.super.Load(self)
end


function GodEquipSettor:LoadCallBack()
    self.nodes = {
        "upPowerTip",
        "downPowerTip",
        "notCantPutPutOn",
        "stepTxt",
    }

    self:GetChildren(self.nodes)
    -- self.stepLbl = self.stepTxt:GetComponent('Text')
    GodEquipSettor.super.LoadCallBack(self)
end

function GodEquipSettor:UpdateInfo(param)
    GodEquipSettor.super.UpdateInfo(self, param)

    if self.is_loaded then
        SetVisible(self.stepTxt,false)
        SetVisible(self.starContain,false)
        self:UpdateFightPowerTip()
        --self:UpdateFightEff()
    end
end

function GodEquipSettor:UpdateFightPowerTip()
    --logError(self.id,self.uid,self.cfg)
    local slot = self.cfg.slot
    local equip = GodModel:GetInstance():GetPutOnBySlot(slot)
    if self.model:GetSlotLock(slot) then
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

end
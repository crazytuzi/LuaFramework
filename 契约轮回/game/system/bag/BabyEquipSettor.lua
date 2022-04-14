---
--- Created by  Administrator
--- DateTime: 2019/11/14 19:12
---
BabyEquipSettor = BabyEquipSettor or class("BabyEquipSettor", BaseBagGoodsSettor)
local this = BabyEquipSettor

BabyEquipSettor.__cache_count = 50
function BabyEquipSettor:ctor(parent_node, layer)

    self.abName = "system"
    self.assetName = "EquipItem"
    self.layer = layer
    self.stepLbl = nil
    BabyEquipSettor.super.Load(self)
end


function BabyEquipSettor:LoadCallBack()
    self.nodes = {
        "upPowerTip",
        "downPowerTip",
        "notCantPutPutOn",
        "stepTxt",
    }

    self:GetChildren(self.nodes)
   -- self.stepLbl = self.stepTxt:GetComponent('Text')
    BabyEquipSettor.super.LoadCallBack(self)
end

function BabyEquipSettor:UpdateInfo(param)
    BabyEquipSettor.super.UpdateInfo(self, param)

    if self.is_loaded then
        SetVisible(self.stepTxt,false)
        SetVisible(self.starContain,false)
        self:UpdateFightPowerTip()
        --self:UpdateFightEff()
    end
end

function BabyEquipSettor:UpdateFightPowerTip()
    --logError(self.id,self.uid,self.cfg)
    local slot = self.cfg.slot
    local equip = BabyModel:GetInstance():GetPutOnBySlot(slot)
    if not equip then
        SetVisible(self.upPowerTip, true)
        SetVisible(self.downPowerTip, false)
    else
        local equipID = equip.id
        local cfg = Config.db_item[equipID]
        local curCfg = Config.db_item[self.id]
        SetVisible(self.upPowerTip, curCfg.color > cfg.color)
        SetVisible(self.downPowerTip, curCfg.color < cfg.color)
        --if curCfg.color > cfg.color then
        --    if not self.score_effect then
        --        self.score_effect = UIEffect(self.icon, 20429)
        --        self.score_effect:SetConfig({ useStencil = true, stencilId = self.stencil_id, stencilType = 3 })
        --    end
        --else
        --    if self.score_effect then
        --        self.score_effect:destroy()
        --        self.score_effect = nil
        --    end
        --end
    end
end
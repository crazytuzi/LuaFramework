---
--- Created by  Administrator
--- DateTime: 2020/6/29 19:55
---
ArtifactEquipSettor = ArtifactEquipSettor or class("ArtifactEquipSettor", BaseBagGoodsSettor)
local this = ArtifactEquipSettor

function ArtifactEquipSettor:ctor(parent_node, layer)
    self.abName = "system"
    self.assetName = "EquipItem"
    self.layer = layer
    self.stepLbl = nil
    ArtifactEquipSettor.super.Load(self)
end

function ArtifactEquipSettor:LoadCallBack()
    -- self.stepLbl = self.stepTxt:GetComponent('Text')

    self.nodes = {
        "upPowerTip",
        "downPowerTip",
        "notCantPutPutOn",
        "stepTxt",
    }

    self:GetChildren(self.nodes)
    self.stepLbl = self.stepTxt:GetComponent('Text')

    ArtifactEquipSettor.super.LoadCallBack(self)

end

function ArtifactEquipSettor:UpdateInfo(param)
    ArtifactEquipSettor.super.UpdateInfo(self, param)
  --  logError(self.cfg.order)
    if self.is_loaded then
        self:UpdateStep(param);
        self:UpdateFightPowerTip()
        --self:UpdateFightEff()
    end
end

function ArtifactEquipSettor:UpdateStep()
    self.stepLbl.text = self.cfg.order.."Tier"
end

function ArtifactEquipSettor:UpdateFightPowerTip()
    local slot = self.cfg.slot
    local id =  ArtifactModel:GetInstance().curArtId
    local info = ArtifactModel:GetInstance():GetEquipInfo(id,slot)
    local item = ArtifactModel:GetInstance():GetEquipByUid(self.uid)
    local itemCfg = Config.db_item[self.cfg.id]
    if itemCfg.stype ~= ArtifactModel:GetInstance().curArtId then
        SetVisible(self.notCantPutPutOn,true)
        SetVisible(self.upPowerTip, false)
        SetVisible(self.downPowerTip, false)
    else
        SetVisible(self.notCantPutPutOn,false)
        if not info then
            SetVisible(self.upPowerTip, true)
            SetVisible(self.downPowerTip, false)
        else
            if item ~= nil then
                if item.score > info.score  then
                    SetVisible(self.upPowerTip, true)
                    SetVisible(self.downPowerTip, false)
                elseif item.score < info.score then
                    SetVisible(self.upPowerTip, false)
                    SetVisible(self.downPowerTip, true)
                else
                    SetVisible(self.upPowerTip, false)
                    SetVisible(self.downPowerTip, false)
                end
            end

        end
    end
    --logError(Table2String(info))
    --logError(Table2String(item))

end

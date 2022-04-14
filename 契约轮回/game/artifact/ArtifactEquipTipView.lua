---
--- Created by  Administrator
--- DateTime: 2020/6/30 11:56
---
ArtifactEquipTipView = ArtifactEquipTipView or class("ArtifactEquipTipView", EquipTipView)
local this = ArtifactEquipTipView

function ArtifactEquipTipView:ctor(parent_node, parent_panel)
    self.abName = "system"
    self.assetName = "EquipDetailView"
    self.layer = "UI"

    BaseGoodsTip.Load(self)
end

function ArtifactEquipTipView:BeforeLoad()
   -- EquipTipView.super.Load(self)
end


function ArtifactEquipTipView:InitData()
    ArtifactEquipTipView.super.InitData(self)

    --self.maxScrollViewHeight = 371
    self.minScrollViewHeight = 160
    --self.maxViewHeight = 555
    self.addValueTemp = 180
end

function ArtifactEquipTipView:ShowTip(param)
    self.is_compare = param["is_compare"]
    ArtifactEquipTipView.super.ShowTip(self, param)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    self:AddEvent()
    self:AddClickCloseBtn()
    self:SetViewPosition()
    SetVisible(self.mask.gameObject, true)

end


function ArtifactEquipTipView:AddEvent()
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.CloseTipView, handler(self, self.CloseTipView))
end

function ArtifactEquipTipView:CompareEquipScore()
    local equipCfg = Config.db_equip[self.goods_item.id]
    local id =  ArtifactModel:GetInstance().curArtId
    if self.is_compare then
        local putOnEquip =  ArtifactModel:GetInstance():GetEquipInfo(id,equipCfg.slot)
        if putOnEquip ~= nil and putOnEquip.uid ~= self.goods_item.uid then
            local w = self.scoreValueTxt.preferredWidth
            local difScore = self.goods_item.score - putOnEquip.score
            if difScore > 0 then
                --self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
                --        ColorUtil.GetColor(ColorUtil.ColorType.Green), self.goods_item.score)
                self.scoreValueTxt.text = self.goods_item.score
                self:ShowScoreUpArrow(true)
            elseif difScore < 0 then
                --self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
                --        ColorUtil.GetColor(ColorUtil.ColorType.Red), self.goods_item.score)
                self.scoreValueTxt.text = self.goods_item.score
                self:ShowScoreUpArrow(false)
            else
                self.scoreValueTxt.text = self.goods_item.score
                self:ShowScoreUpArrow(false, false)
            end
        else
            self.scoreValueTxt.text = self.goods_item.score
            self:ShowScoreUpArrow(false, false)
        end
    else
        local putOnEquip =  ArtifactModel:GetInstance():GetEquipInfo(id,equipCfg.slot)
        if putOnEquip ~= nil and putOnEquip.uid == self.goods_item.uid then
            self.scoreValueTxt.text = self.goods_item.score
            self:ShowScoreUpArrow(false, false)
        else
            --self.scoreValueTxt.text = string.format("<color=#%s>%s</color>",
            --        ColorUtil.GetColor(ColorUtil.ColorType.Green), self.goods_item.score)
            self.scoreValueTxt.text = self.goods_item.score
            self:ShowScoreUpArrow(true , false)
        end

    end
end
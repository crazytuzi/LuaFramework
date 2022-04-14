---
--- Created by  R2D2
--- DateTime: 2019/4/8 11:17
---
require("game.pet.BaseInfo.PetBaseValueView")
require("game.pet.BaseInfo.PetBaseAttributeView")
require("game.pet.BaseInfo.PetBaseInbornAttributeView")

PetBaseInfoPanel = PetBaseInfoPanel or class("PetBaseInfoPanel", BaseItem)
local this = PetBaseInfoPanel

function PetBaseInfoPanel:ctor(parent_node, parent_panel)
    self.abName = "pet"
    self.assetName = "PetBaseInfoPanel"
    self.layer = "UI"

    self.model = PetModel:GetInstance()

    self.events = {}
    self.modelEvents = {}

    self.baseValueView = self.baseValueView or PetBaseValueView()
    self.baseAttributeView = self.baseAttributeView or PetBaseAttributeView()
    self.inbornAttributeView = self.inbornAttributeView or PetBaseInbornAttributeView()

    PetBaseInfoPanel.super.Load(self)
end

function PetBaseInfoPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.modelEvents)

    if (self.baseValueView) then
        self.baseValueView:destroy()
        self.baseValueView = nil
    end

    if (self.baseAttributeView) then
        self.baseAttributeView:destroy()
        self.baseAttributeView = nil
    end

    if (self.inbornAttributeView) then
        self.inbornAttributeView:destroy()
        self.inbornAttributeView = nil
    end
end

function PetBaseInfoPanel:LoadCallBack()
    self.nodes = {
        "ShowDetail",
        "Grade", "Score", "Damage",

        "BaseAttr/BTitle1", "BaseAttr/BTitle2", "BaseAttr/BTitle3", "BaseAttr/BTitle4", "BaseAttr/BTitle5", "BaseAttr/BTitle6",
        "BaseAttr/Slider1", "BaseAttr/Slider2", "BaseAttr/Slider3", "BaseAttr/Slider4", "BaseAttr/Slider5", "BaseAttr/Slider6",
        "BaseAttr/Slider1/ForeGround1", "BaseAttr/Slider2/ForeGround2", "BaseAttr/Slider3/ForeGround3",
        "BaseAttr/Slider4/ForeGround4", "BaseAttr/Slider5/ForeGround5", "BaseAttr/Slider6/ForeGround6",
        "BaseAttr/Value1", "BaseAttr/Value2", "BaseAttr/Value3", "BaseAttr/Value4", "BaseAttr/Value5", "BaseAttr/Value6",
        "Power/PowerValue",
        "InbornAttr/ItemParent", "InbornAttr/InbornTip", "InbornAttr/ItemParent/ItemPrefab",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    if (self.petData) then
        self:RefreshView()
    end
end

function PetBaseInfoPanel:InitUI()
    self.PowerValue = GetText(self.PowerValue)
    self.baseValueView:InitUI(self.Grade, self.Score, self.Damage)
    SetVisible(self.Grade, false)

    self.baseAttributeView:AddItem(self.BTitle1, self.Slider1, self.ForeGround1, self.Value1)
    self.baseAttributeView:AddItem(self.BTitle2, self.Slider2, self.ForeGround2, self.Value2)
    self.baseAttributeView:AddItem(self.BTitle3, self.Slider3, self.ForeGround3, self.Value3)
    self.baseAttributeView:AddItem(self.BTitle4, self.Slider4, self.ForeGround4, self.Value4)
    self.baseAttributeView:AddItem(self.BTitle5, self.Slider5, self.ForeGround5, self.Value5)
    self.baseAttributeView:AddItem(self.BTitle6, self.Slider6, self.ForeGround6, self.Value6)

    self.inbornAttributeView:InitUI(self.ItemPrefab, self.ItemParent, self.InbornTip)
end

function PetBaseInfoPanel:AddEvent()
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_SelectPetEvent, handler(self, self.OnSelectPet))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(PetEvent.Pet_Model_ChangeBattlePetEvent, handler(self, self.OnChangeBattlePet))

    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.GoodsDetail, handler(self, self.OnGetItemDetail))
    AddClickEvent(self.ShowDetail.gameObject, handler(self, self.OnShowDetail))
end

function PetBaseInfoPanel:OnShowDetail()
    local view = PetAttributeDetailTip()
    view:SetData(self.petData)
end

function PetBaseInfoPanel:SetData(petData)
    self.petData = petData

    if (self.is_loaded) then
        self:RefreshView()
    end
end

function PetBaseInfoPanel:OnSelectPet(petData)
    self.petData = petData
    self:RefreshView()
end

function PetBaseInfoPanel:OnChangeBattlePet(petData)
    if (self.petData.Config.order == petData.Config.order and self.gameObject.activeSelf) then
        self.petData = petData
        self:RefreshView()
    end
end

function PetBaseInfoPanel:OnGetItemDetail(pItem)
    if(self.petData == nil) then
        return
    end

    if ( not self.petData.IsActive) and self.petData.HasInBag and pItem.uid == self.petData.BagPet.uid then
        self:RefreshView()
    end
end

function PetBaseInfoPanel:RefreshView()
    SetVisible(self.ShowDetail, self.petData.IsActive)
    if self.petData.IsActive then
        self.PowerValue.text = self.petData.Data.pet.power
    else
        self.PowerValue.text = "wwwwwww"
    end
    self.baseValueView:RefreshView(self.petData)
    self.baseAttributeView:RefreshView(self.petData)
    self.inbornAttributeView:RefreshView(self.petData)

end
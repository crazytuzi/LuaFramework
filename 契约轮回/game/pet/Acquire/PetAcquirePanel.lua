---
--- Created by R2D2.
--- DateTime: 2019/4/19 20:25
---

PetAcquirePanel = PetAcquirePanel or class("PetAcquirePanel", BasePanel)
local PetAcquirePanel = PetAcquirePanel

function PetAcquirePanel:ctor()
    self.abName = "pet"
    self.imageAb = "pet_image"
    self.assetName = "PetAcquirePanel"
    --self.layer = "UI"
    self.layer = "Top"
    self.use_background = false
    self.show_sidebar = false
    self.touch_close = false
    self.model = PetModel:GetInstance()

    self.events = {}
    PetAcquirePanel.super.Open(self)
end

function PetAcquirePanel:dctor()

    self:StopAction()
    self:ClearAutoClose()

    if self.PetModle then
        self.PetModle:destroy()
        self.PetModle = nil
    end

    if self.baseInfoPanel then
        self.baseInfoPanel:destroy()
        self.baseInfoPanel = nil
    end

    if self.effect then
        self.effect:destroy()
    end

    GlobalEvent:RemoveTabListener(self.events)
    self.events = {}

    if(self.epImageList) then
        for _, value in pairs(self.epImageList) do
            value = nil
        end

        self.epImageList = nil
    end    
end

function PetAcquirePanel:LoadCallBack()
    self.nodes = { "FullBg", "EffectParent", "Content", "Content/Block", "Content/Pet/QualityName", "Content/Pet/NameText", "Content/Pet/NoEvolution",
                   "Content/Pet/Model", "Content/Pet/EP1", "Content/Pet/EP2", "Content/Pet/EP3", "Content/Pet/EP4", "Content/SubPanel", "Content/CloseCountDown",
    }
    self:GetChildren(self.nodes)

    self.layerIndex = LuaPanelManager:GetInstance():GetPanelInLayerIndex(self.layer, self)
    --local orderIndex = LayerManager:GetInstance():GetLayerOrderByName(self.layer)
    --self:SetOrderIndex(orderIndex + 10)

    local _, orderIndex = GetParentOrderIndex(self.gameObject)
    UIDepth.SetOrderIndex(self.Content.gameObject, true, orderIndex + 4)

    self:LoadEffect()
    self:LoadBaseInfoPanel()
    self:InitUI()
    self:AddEvent()

    if (self.CurrPetData) then
        self:RefreshView()
    end
end

function PetAcquirePanel:InitUI()

    self.img_bg_component = GetImage(self.FullBg)
    self.nameText = GetText(self.NameText)
    self.qualityNameImage = GetImage(self.QualityName)
    self.noEvolutionImg = GetImage(self.NoEvolution)
    self.countDownText = GetText(self.CloseCountDown)

    self.epImageList = {}
    table.insert(self.epImageList, GetImage(self.EP1))
    table.insert(self.epImageList, GetImage(self.EP2))
    table.insert(self.epImageList, GetImage(self.EP3))
    table.insert(self.epImageList, GetImage(self.EP4))

    self.subPanelX = self.SubPanel.anchoredPosition.x
    self.subPanelY = self.SubPanel.anchoredPosition.y
    self.subPanelX2 = ScreenWidth * 0.5 + 210

    lua_resMgr:SetImageTexture(self, self.img_bg_component, "iconasset/icon_big_bg_pet_bg", "pet_bg", true)
    SetSizeDelta(self.FullBg, ScreenWidth, ScreenHeight)
    --self:SetBackgroundImage("iconasset/icon_big_bg_pet_bg", "pet_bg")
    SetAnchoredPosition(self.SubPanel, self.subPanelX2, self.subPanelY)
end

function PetAcquirePanel:AddEvent()
    --self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.GoodsDetail, handler(self, self.OnGetItemDetail))

    local function call_back()
        if (self.touch_close) then
            self:Close()
        end
    end
    AddClickEvent(self.Block.gameObject, call_back)
end

--[[function PetAcquirePanel:OnGetItemDetail(itemData)
    if (itemData.bag == self.CurrPetData.Data.bag and itemData.uid == self.CurrPetData.Data.uid) then

        local config = Config.db_pet[itemData.id]
        local data = { ["Data"] = itemData, ["Config"] = config,
                       ["IsActive"] = true }

        self.baseInfoPanel:SetData(data)
    end
end--]]

function PetAcquirePanel:SetData(data)
    self.CurrPetData = data
    if (self.is_loaded) then
        self:RefreshView()
    end
end

function PetAcquirePanel:RefreshView()

    if self.CurrPetData.Config.type == 2 then
        self.nameText.text = string.format("%s\n\n%s", ConfigLanguage.Pet.ActivityType, self.CurrPetData.Config.name)
    else
        self.nameText.text = string.format("T%s\n\n%s", ChineseNumber(self.CurrPetData.Config.order_show), self.CurrPetData.Config.name)
    end

    lua_resMgr:SetImageTexture(self, self.qualityNameImage, self.imageAb, "Q_Name_" .. self.CurrPetData.Config.quality, true)

    self:SetEvolutionPoint(self.CurrPetData.Config.evolution, self.CurrPetData.Data.extra)

    if (self.PetModle) then
        self.PetModle:ReLoadPet(self.CurrPetData.Config.model)
    else
        self.PetModle = UIPetCamera(self.Model, nil, self.CurrPetData.Config.model, 1, false, self.layerIndex)
    end
    ---修正位置
    local located = String2Table(self.CurrPetData.Config.located)
    local config = {}
    config.offset = { x = located[1] or 0, y = located[2] or 0, z = located[3] or 0 }
    self.PetModle:SetConfig(config)

    --PetController:GetInstance():RequestItemInfo(self.CurrPetData.Data.bag, self.CurrPetData.Data.uid)

    SetAnchoredPosition(self.SubPanel, self.subPanelX2, self.subPanelY)
    self.schedule = GlobalSchedule.StartFunOnce(handler(self, self.ShowPanelAction), 1)
    self:StartAutoClose(5)
end

function PetAcquirePanel:ShowPanelAction()
    self.touch_close = true
    self.panelAction = cc.MoveTo(0.5, self.subPanelX, self.subPanelY)
    cc.ActionManager:GetInstance():addAction(self.panelAction, self.SubPanel)
end

function PetAcquirePanel:StopAction()
    if self.panelAction then
        cc.ActionManager:GetInstance():removeAction(self.panelAction)
        self.panelAction = nil
    end
end

function PetAcquirePanel:SetEvolutionPoint(count, point)
    for i, v in ipairs(self.epImageList) do
        if (i <= point) then
            v.enabled = true
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint");
        elseif (i <= count) then
            v.enabled = true
            lua_resMgr:SetImageTexture(self, v, self.imageAb, "EvolutionPoint_Gray");
        else
            v.enabled = false
        end
    end

    self.noEvolutionImg.enabled = count <= 0
end

function PetAcquirePanel:LoadEffect()
    if (not self.effect) then
        self.effect = UIEffect(self.EffectParent, 10101, false, self.layer)
        self.effect:SetConfig({ is_loop = true })
    else
        self.effect:SetLoop(true)
        SetVisible(self.effect, true)
    end
end

function PetAcquirePanel:LoadBaseInfoPanel()
    self.baseInfoPanel = PetBaseInfoPanel(self.SubPanel)
    self.baseInfoPanel:SetData(self.CurrPetData)
end

function PetAcquirePanel:StartAutoClose(closetime)
    closetime = closetime or 10;
    self.countDownText.text = tostring(closetime) .. ConfigLanguage.Pet.CountDownClose;

    local function call_back(data)
        closetime = closetime - 1;

        if closetime >= 0 then
            self.countDownText.text = tostring(closetime) .. ConfigLanguage.Pet.CountDownClose;
        end

        if closetime <= 0 then
            self:Close()
            self:ClearAutoClose()
        end
    end

    self.autoSchedule = GlobalSchedule:Start(call_back, 1, -1);
end

function PetAcquirePanel:ClearAutoClose()
    if self.autoSchedule then
        GlobalSchedule.StopFun(self.autoSchedule);
        self.autoSchedule = nil
    end
end
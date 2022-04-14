---
--- Created by R2D2.
--- DateTime: 2019/1/9 19:17
---
WelfareSignPanel = WelfareSignPanel or class("WelfareSignPanel", BaseItem)
local this = WelfareSignPanel

function WelfareSignPanel:ctor(parent_node, parent_panel)
    self.abName = "welfare"
    self.assetName = "WelfareSignPanel"
    self.layer = "UI"

    self.parentPanel = parent_panel
    self.model = WelfareModel.GetInstance()
    self.events = {}

    self.ScrollViewParam = ScrollViewParam or {}
    self.ScrollViewParam["cellW"] = 84
    self.ScrollViewParam["cellH"] = 106
    self.ScrollViewParam["spacX"] = 5
    self.ScrollViewParam["spacY"] = 6
    self.ScrollViewParam["startX"] = 0
    self.ScrollViewParam["startY"] = 0

    WelfareSignPanel.super.Load(self)
end

function WelfareSignPanel:dctor()

    self.model = nil

    if self.UIModel then
        self.UIModel:destroy()
        self.UIModel = nil
    end

    if self.effect then
        self.effect:destroy()
        self.effect = nil
    end

    GlobalEvent:RemoveTabListener(self.events)

    for _, v in pairs(self.itemList) do
        v:destroy()
    end
    self.itemList = {}
end

--function WelfareSignPanel:OnEnable()
--    WelfareController:GetInstance():RequestSignInfo()
--end

function WelfareSignPanel:LoadCallBack()
    self.nodes = { "MonthAward/TitleText", "MonthAward/NameText", "ModelParent", "EffectParent",
                   "Table/ScrollView", "Table/ScrollView/Viewport", "Table/ScrollView/Viewport/Content",
                   "Table/CellPrefab", "RemainTimes", "HelpBtn",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function WelfareSignPanel:InitUI()

    --self.viewPortImage = GetImage(self.Viewport)
    --self.viewPortImage.material = ShaderManager.GetInstance():GetScrollRectMaskMaterial()

    self.monthTitleText = GetText(self.TitleText)
    self.monthNameText = GetText(self.NameText)

    self.remainTimesText = GetText(self.RemainTimes)
    self.contentRect = self.Content:GetComponent("RectTransform")
    self.remainTimesText.text = self.model:GetRemainTimes()

    self.itemList = {}

    self:RefreshMonthAward()
    self:LoadEffect()

    --local today = TimeManager.Instance:GetTimeDate(TimeManager.Instance:GetServerTime())
    local rewardTab = self.model:GetSignRewardList()
    if not rewardTab then
        return
    end

    local fullW = self.ScrollView:GetComponent("RectTransform").sizeDelta.x
    local cols = math.floor(fullW / self.ScrollViewParam.cellW)
    local rows = math.ceil(#rewardTab / cols)
    local fullH = self.ScrollViewParam.startY + self.ScrollViewParam.cellH * rows + (rows - 1) * self.ScrollViewParam.spacY
    self.contentRect.sizeDelta = Vector2(self.contentRect.sizeDelta.x, fullH)

    local baseX = (-fullW + self.ScrollViewParam.cellW) / 2 + self.ScrollViewParam.startX
    local baseY = (fullH - self.ScrollViewParam.cellH) / 2 - self.ScrollViewParam.startY

    self:CreateItems(rewardTab, cols, baseX, baseY)
    self.CellPrefab.gameObject:SetActive(false)
end

function WelfareSignPanel:AddEvent()

    local helpTip = function(target, x, y)
        ShowHelpTip(HelpConfig.Welfare.Sign);
    end
    AddClickEvent(self.HelpBtn.gameObject, helpTip)

    local function signed_CallBack(isSupplement)
        if isSupplement then
            Notify.ShowText("Sign-in successful")
        else
            Notify.ShowText("Sign-in table filled")
        end
        self:RefreshView()
    end
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_SignedEvent, signed_CallBack);

    local function signData_CallBack()
        self:RefreshView()
    end
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_SignDataEvent, signData_CallBack);
end

function WelfareSignPanel:LoadEffect()
    if not self.effect then
        self.effect = UIEffect(self.EffectParent, 10311, false)
        local cfg = { scale = 1.25 }
        self.effect:SetConfig(cfg)
    end
end

function WelfareSignPanel:CreateItems(rewardTab, cols, baseX, baseY)

    for i = 1, #rewardTab, 1 do
        local c = i % cols
        c = (c == 0) and cols or c
        local r = math.ceil(i / cols)

        local tempItem = WelfareSignItemView(newObject(self.CellPrefab), rewardTab[i])
        tempItem.transform:SetParent(self.Content.transform)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        tempItem.transform.anchoredPosition3D = Vector3(baseX + (c - 1) * (self.ScrollViewParam.cellW + self.ScrollViewParam.spacX),
                baseY - (r - 1) * (self.ScrollViewParam.cellH + self.ScrollViewParam.spacY), 0)

        self.itemList[i] = tempItem
    end
end

function WelfareSignPanel:RefreshMonthAward()
    local cfg = self.model:GetSignRewardConfig()
    if (cfg) then
        self.monthTitleText.text = cfg.line_one
        self.monthNameText.text = cfg.line_two

        if (self.UIModel) then
            self.UIModel:ReLoad(cfg.model)
        else
            self.UIModel = UIModelCommonCamera(self.ModelParent, nil, cfg.model, nil, false)
            if cfg.model == "model_fabao_10001" then
                SetLocalPositionXY(self.ModelParent.transform, -230, 197)
                SetLocalScale(self.ModelParent.transform, 1.2, 1.2, 1.2)
            else
                SetLocalPositionXY(self.ModelParent.transform, -230, 230)
                SetLocalScale(self.ModelParent.transform, 1, 1, 1)
            end
            local _, order = GetParentOrderIndex(self.transform)
            self.UIModel:SetOrderIndex(order+2)
        end
    end
end

function WelfareSignPanel:RefreshView()
    self.remainTimesText.text = self.model:GetRemainTimes()

    for _, v in pairs(self.itemList) do
        v:RefreshState()
    end
end
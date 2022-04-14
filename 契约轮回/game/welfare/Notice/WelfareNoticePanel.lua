---
--- Created by  R2D2
--- DateTime: 2019/1/16 14:31
---
WelfareNoticePanel = WelfareNoticePanel or class("WelfareNoticePanel", BaseItem)
local this = WelfareNoticePanel

function WelfareNoticePanel:ctor(parent_node, parent_panel)
    self.abName = "welfare"
    self.assetName = "WelfareNoticePanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.isUiInit = false

    self.model = WelfareModel.GetInstance():GetNoticeModel()
    self.events = {}

    WelfareNoticePanel.super.Load(self)
end

function WelfareNoticePanel:dctor()
    self:StopSchedule()
    self.model = nil
    GlobalEvent:RemoveTabListener(self.events)
    if self.goodItem then
        self.goodItem:destroy()
    end
    self.goodItem = nil
end

function WelfareNoticePanel:OnEnable()
    if self.isUiInit then
        self:RefreshPanel()
        self:ShowCountDown()
    end
end

function WelfareNoticePanel:OnDisable()
    self:StopSchedule()
end

function WelfareNoticePanel:LoadCallBack()
    self.nodes = {
        "ItemParent", "Button", "Received", "CountDown", "ScrollView/Viewport/Content", "ScrollView/Viewport/Content/Text",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self:RefreshPanel()
    self:ShowCountDown()
end

function WelfareNoticePanel:InitUI()
    self.goodsParent = self.ItemParent
    self.contentRect = self.Content:GetComponent("RectTransform")
    self.receivedImage = GetImage(self.Received)
    self.contentText = GetText(self.Text)
    self.countDownText = GetText(self.CountDown)
    self.textRect = self.Text:GetComponent("RectTransform")

    self.isUiInit = true
end

function WelfareNoticePanel:AddEvent()
    local function OnGetButtonClick()
        if self.timer > 0 then
            Notify.ShowText("You can claim only after having read the notice~")
            return
        end
        WelfareController:GetInstance():RequestNoticeReward(self.data.id)
    end
    AddButtonEvent(self.Button.gameObject, OnGetButtonClick)

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_NoticeRewardEvent, handler(self, self.NoticeReward))
end

function WelfareNoticePanel:NoticeReward()
    Notify.ShowText("Claimed")
    self:RefreshPanel()
end

function WelfareNoticePanel:RefreshPanel()

    local tab = self.model:GetNoticeInfo()

    if tab then
        self.data = tab

        self:InitGoodItem(tab.reward)
        self.contentText.text = Config.db_welfare_notice_reward[tab.id].content
        self.textRect.sizeDelta = Vector2(self.textRect.sizeDelta.x, self.contentText.preferredHeight)
        self.contentRect.sizeDelta = Vector2(self.contentRect.sizeDelta.x, self.contentText.preferredHeight)
        SetGameObjectActive(self.goodsParent.gameObject, true)

        if tab.isReceived then
            self.receivedImage.enabled = true
            SetGameObjectActive(self.Button, false)
        else
            self.receivedImage.enabled = false
            SetGameObjectActive(self.Button, true)
        end
    else
        self.contentText.text = "No notice yet"
        self.receivedImage.enabled = false
        SetGameObjectActive(self.goodsParent.gameObject, false)
        SetGameObjectActive(self.Button, false)
    end
end

function WelfareNoticePanel:InitGoodItem(goods)
    self.goodItems = {}

    for i = 1, #goods, 1 do
        local item = AwardItem(self.goodsParent)
        item:SetData(goods[i][1], goods[i][2])
        item:AddClickTips()
        SetLocalScale(item.transform, 1, 1, 1)
        SetLocalPosition(item.transform, (i - 1) * 80, 0, 0)
        table.insert(self.goodItems, item)
    end
end

function WelfareNoticePanel:ShowCountDown()
    self:StopSchedule()

    if self.data.isReceived then
        self.countDownText.text = ""
        return
    end

    self.timer = 5
    self.countDownText.text = "5"

    self.schedule = GlobalSchedule.StartFun(handler(self, self.StartCountDown), 1, -1)
end

function WelfareNoticePanel:StopSchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
end

function WelfareNoticePanel:StartCountDown()

    self.timer = self.timer - 1

    if self.timer > 0 then
        self.countDownText.text = self.timer
    else
        self:StopSchedule()
        self.countDownText.text = ""
    end
end
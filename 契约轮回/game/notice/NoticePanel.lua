---
--- Created by R2D2.
--- DateTime: 2019/1/19 11:45
---
NoticePanel = NoticePanel or class("NoticePanel", WindowPanel)
local this = NoticePanel

function NoticePanel:ctor()
    self.abName = "notice"
    self.assetName = "NoticePanel"
    self.layer = "UI"

    self.panel_type = 3
    self.show_sidebar = false

    self.model = NoticeModel.GetInstance()
    self.events = {}
end

function NoticePanel:dctor()
    self.model = nil;
    GlobalEvent:RemoveTabListener(self.events);

    if self.toggleItems then
        for _, v in pairs(self.toggleItems) do
            v:destroy()
        end
        self.toggleItems = nil
    end
end

function NoticePanel:Open()
    WindowPanel.Open(self)
end

function NoticePanel:LoadCallBack()
    self:SetPanelSize(870, 530);
    self:SetTileTextImage("notice_image", "Notice_title")

    self.nodes = {
        "ToggleList",
        "ToggleList/TogglePrefab",
        "Title",
        "ScrollView/Viewport/Content",
        "ScrollView/Viewport/Content/Text",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()

    if(self.toggleItems and self.toggleItems[1]) then
        self.toggleItems[1]:SetItOn(true)
    end
end

function NoticePanel:InitUI()
    self.titleText = GetText(self.Title)
    self.contentText = GetText(self.Text)
    self.textRect = self.Text:GetComponent("RectTransform")
    self.contentRect = self.Content:GetComponent("RectTransform")
    self.toggleGroup = GetToggleGroup(self.ToggleList)

    self.toggleItems = {}
    local tab = self.model.OnlineNotice
    --local tab = self.model.NoticeData   
    for i = 1, #tab, 1 do
        local tempTab = tab[i]
        local tempItem = NoticeToggleItemView(newObject(self.TogglePrefab), tempTab)
        tempItem:SetId(i)
        tempItem.gameObject.name = "Notice_Toggle" .. i
        tempItem.transform:SetParent(self.ToggleList)
        tempItem:SetTogGroup(self.toggleGroup)
        SetLocalScale(tempItem.transform, 1, 1, 1)
        SetLocalPosition(tempItem.transform, 0, (i - 1) * -56, 0)
        self.toggleItems[i] = tempItem
    end
    self.TogglePrefab.gameObject:SetActive(false)
end

function NoticePanel:AddEvent()
    local OnToggle = function(id)
        local tab = self.model.OnlineNotice[id] --Config.db_welfare_notice_reward[id]
        if tab then
            self.titleText.text = tab.title
            self.contentText.text = tab.content
            self.textRect.sizeDelta = Vector2(self.textRect.sizeDelta.x, self.contentText.preferredHeight)
            self.contentRect.sizeDelta = Vector2(self.contentRect.sizeDelta.x, self.contentText.preferredHeight)
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(NoticeEvent.Notice_ToggleEvent, OnToggle)
end
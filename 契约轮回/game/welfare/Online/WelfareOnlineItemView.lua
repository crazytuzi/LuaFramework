---
--- Created by R2D2.
--- DateTime: 2019/1/14 19:06
---
WelfareOnlineItemView = WelfareOnlineItemView or class("WelfareOnlineItemView", Node)
local this = WelfareOnlineItemView

function WelfareOnlineItemView:ctor(obj, data)
    self.transform = obj.transform
    self.data = data
    self.model = WelfareModel.GetInstance():GetOnlineModel()

    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self:InitUI()
    self:AddEvent()
    self:RefreshState()
end

function WelfareOnlineItemView:dctor()
    self:StopSchedule()

    if (self.redPoint) then
        self.redPoint:destroy()
        self.redPoint = nil
    end

    for _, v in pairs(self.goodItems) do
        v:destroy()
    end
    self.goodItems = {}
end

function WelfareOnlineItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "Button", "ItemParent", "DisableButton", "Received", "CountDown" }
    self:GetChildren(self.nodes)

    self.receivedImg = GetImage(self.Received)
    self.countDownText = GetText(self.CountDown)
    self.itemParent = self.ItemParent.transform
    self:InitGoodsItem()
end

function WelfareOnlineItemView:AddEvent()

    local function OnDisableButton()
        Notify.ShowText("You didn't stay online for required time")
    end
    AddButtonEvent(self.DisableButton.gameObject, OnDisableButton)

    local function OnGetButton()
        WelfareController:GetInstance():RequestOnlineReward(self.data.id)
    end
    AddButtonEvent(self.Button.gameObject, OnGetButton)
end

function WelfareOnlineItemView:InitGoodsItem()
    self.goodItems = {}
    local goods = self.data.reward

    for _, v in pairs(goods) do
        local item = AwardItem(self.itemParent)
        item:SetData(v[1], v[2])
        item:AddClickTips()
        table.insert(self.goodItems, item)

        local index = #self.goodItems - 1
        local col = index % 2
        local row = math.floor(index / 2)

        SetLocalScale(item.transform, 1, 1, 1)
        SetLocalPosition(item.transform, col * 80, row * -86, 0)
    end
end

function WelfareOnlineItemView:RefreshState()

    if self.data.isReceived then
        self:ReceivedStyle()
    else
        --local seconds = self.model:GetTotalSecond()
        local currTime = TimeManager.Instance:GetServerTime()
        --logError( string.format("Refresh State,ServerTime = %s, endTime = %s, Offset = %s",currTime , self.data.endTime ,  self.data.endTime - currTime ))
        --print("total seconds ===> " .. currTime - self.model.StartTime)
        if currTime >= self.data.endTime then
            self:ReachedStyle()
        else
            self:UnreachedStyle()
            self:ShowCountDown()
        end
    end
end

function WelfareOnlineItemView:ShowCountDown()
    --local timeTab = TimeManager:GetLastTimeData(TimeManager.Instance:GetServerTime(), self.data.endTime)
    --if timeTab then
    self:StopSchedule()
    self.schedule = GlobalSchedule.StartFun(handler(self, self.StartCountDown), 1, -1)
    self:StartCountDown();
    --end
end

function WelfareOnlineItemView:StartCountDown()

    local serverTime = TimeManager.Instance:GetServerTime()
    local timeTab = TimeManager:GetLastTimeData(serverTime, self.data.endTime)
    local minStr = ""
    local secStr = ""

    if timeTab then
        minStr = string.format("%02d", timeTab.min or 0)
        secStr = string.format("%02d", timeTab.sec or 0)
        self.countDownText.text = string.format("%s:%s", minStr, secStr)
    else
        self:StopSchedule()
        self:RefreshState()
    end
end

function WelfareOnlineItemView:StopSchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
end

function WelfareOnlineItemView:UnreachedStyle()
    self.receivedImg.enabled = false
    SetGameObjectActive(self.Button, false)
    SetGameObjectActive(self.DisableButton, true)
    self:SetRedPoint(false)
end

function WelfareOnlineItemView:ReachedStyle()
    self.countDownText.text = "Requirements met"
    self.receivedImg.enabled = false
    SetGameObjectActive(self.Button, true)
    SetGameObjectActive(self.DisableButton, false)
    self:SetRedPoint(true)

end

function WelfareOnlineItemView:ReceivedStyle()
    self.countDownText.text = ""
    self.receivedImg.enabled = true
    SetGameObjectActive(self.Button, false)
    SetGameObjectActive(self.DisableButton, false)
    self:SetRedPoint(false)

end

function WelfareOnlineItemView:SetRedPoint(isShow)
    if self.redPoint == nil then
        self.redPoint = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.redPoint:SetPosition(50, -100)
    end

    self.redPoint:SetRedDotParam(isShow)
end
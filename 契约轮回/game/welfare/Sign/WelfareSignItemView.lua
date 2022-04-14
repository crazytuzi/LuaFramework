---
--- Created by R2D2.
--- DateTime: 2019/1/9 20:12
---
WelfareSignItemView = WelfareSignItemView or class("WelfareSignItemView", Node)
local this = WelfareSignItemView

function WelfareSignItemView:ctor(obj, tab)

    self.transform = obj.transform
    self.data = tab

    self.gameObject = self.transform.gameObject;
    self.transform_find = self.transform.Find;

    self:InitUI();
    self:AddEvent();
end

function WelfareSignItemView:dctor()
    if self.goodItem then
        self.goodItem:destroy()
    end
    self.goodItem = nil
end

function WelfareSignItemView:InitUI()
    self.is_loaded = true
    self.nodes = { "Tip", "Mask", "ItemParent", "Signed", "Selector", "Clicker",
                   "VipTip", "VipTip/VipTipText", }

    self:GetChildren(self.nodes)

    self.tipText = GetText(self.Tip)
    self.signedImage = GetImage(self.Signed)
    self.maskImage = GetImage(self.Mask)
    self.selectorImage = GetImage(self.Selector)
    self.clickerImage = GetImage(self.Clicker)
    self.vipTipText = GetText(self.VipTipText)
    self.goodParent = self.ItemParent.transform

    self:InitGoodItem()
end

function WelfareSignItemView:AddEvent()

    local function OnClicker()
        local signInfo = WelfareModel.GetInstance().signInfo
        local count = WelfareModel.GetInstance():GetRemainTimes()

        if self.data.id ~= signInfo.signs + 1 then
            Notify.ShowText("You already signed in on that day")
            return
        end

        if (not signInfo.is_sign) then
            WelfareController:GetInstance():RequestSign()
        elseif count > 0 then

            local needActive = WelfareModel.GetInstance():GetSupplementActiveValue()
            local roleActive = WelfareModel.GetInstance().DailyValue

            if roleActive < needActive then
                Notify.ShowText(string.format("Daily activity reaches %s can recovery the check in.", needActive))
                return
            end
            WelfareController:GetInstance():RequestSign()
        end
    end
    AddButtonEvent(self.Clicker.gameObject, OnClicker)
end

function WelfareSignItemView:InitGoodItem()
    self.goodItem = {}
    local itemData = String2Table(self.data.reward)
    --local item = GoodsIconSettorTwo(self.ItemParent.transform)
    --local param = {}
    --param["item_id"] = itemData[1][1]
    --param["num"] = itemData[1][2]
    --param["can_click"] = true
    --item:SetIcon(param)

    local item = AwardItem(self.ItemParent.transform)
    item:SetData(itemData[1][1], itemData[1][2])
    item:AddClickTips()

    SetLocalScale(item.transform, 1, 1, 1)
    self.goodItem = item

    if self.data.vip <= 0 then
        SetVisible(self.VipTip.gameObject, false)
    else
        SetVisible(self.VipTip.gameObject, true)
        self.vipTipText.text = string.format("VIP%s Double", self.data.vip)
    end

    self:RefreshState()
end

function WelfareSignItemView:RefreshState()
    self:StopAction()
    local signInfo = WelfareModel:GetInstance().signInfo

    if self.data.id <= signInfo.signs then
        self:SetSignedStyle()
    else
        --if signInfo.max_days <=0 then
        if signInfo.signs >= signInfo.max_days then
            self:SetNormalStyle()
            return
        end
        local remainTimes = WelfareModel:GetInstance():GetRemainTimes()
        if signInfo.is_sign then
            if remainTimes > 0 then
                if self.data.id == signInfo.signs + 1 then
                    self:SetSupplementStyle()
                else
                    self:SetNormalStyle()
                end
            else
                self:SetNormalStyle()
            end
        else
            if self.data.id == signInfo.signs + 1 then
                self:SetSignableStyle()
            else
                self:SetNormalStyle()
            end
        end
    end
end

function WelfareSignItemView:StartAction()
    local action
    local action_time = 0.6
    action = cc.ScaleTo(action_time, 0.8)
    action = cc.Sequence(action, cc.ScaleTo(action_time, 1))

    if not action then
        return
    end
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.selectorImage.transform)
end

function WelfareSignItemView:StopAction()
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.selectorImage.transform)
end

function WelfareSignItemView:SetSignableStyle()
    self.tipText.text = "Available"
    self.signedImage.enabled = false
    self.maskImage.enabled = false
    self.selectorImage.enabled = true
    self.clickerImage.enabled = true
    self:StartAction()
end

function WelfareSignItemView:SetNormalStyle()
    self.tipText.text = string.format("Day %s", self.data.day)
    self.signedImage.enabled = false
    self.maskImage.enabled = false
    self.selectorImage.enabled = false
    self.clickerImage.enabled = false
end

function WelfareSignItemView:SetSignedStyle()
    self.tipText.text = "Signed in"
    self.signedImage.enabled = true
    self.maskImage.enabled = true
    self.selectorImage.enabled = false
    self.clickerImage.enabled = true
end

function WelfareSignItemView:SetSupplementStyle()
    self.tipText.text = "Tap to fill the table"
    self.signedImage.enabled = false
    self.maskImage.enabled = false
    self.selectorImage.enabled = true
    self.clickerImage.enabled = true
    self:StartAction()
end
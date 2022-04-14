---
--- Created by  Administrator
--- DateTime: 2020/4/16 16:56
---
RichManRoundItem = RichManRoundItem or class("RichManRoundItem", BaseCloneItem)
local this = RichManRoundItem

function RichManRoundItem:ctor(obj, parent_node, parent_panel)
    RichManRoundItem.super.Load(self)
    self.events = {}

end

function RichManRoundItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(   self.itemicon) do
        v:destroy()
    end
    self.itemicon ={}
    if self.lqRed then
        self.lqRed:destroy()
        self.lqRed = nil
    end
end

function RichManRoundItem:LoadCallBack()
    self.nodes = {
        "okBtn","round","iconParent","ylqImg","wdcImg",
    }
    self:GetChildren(self.nodes)
    self.round = GetText(self.round)
    self.btnImg = GetImage(self.okBtn)
    self:InitUI()
    self:AddEvent()
    if not self.lqRed then
        self.lqRed = RedDot(self.okBtn, nil, RedDot.RedDotType.Nor)
        self.lqRed:SetPosition(48, 19)
    end
    self.lqRed:SetRedDotParam(true)
end

function RichManRoundItem:InitUI()

end

function RichManRoundItem:AddEvent()

    local function call_back()
        if self.reward ~= 1 then
            Notify.ShowText("Requirement Not reached")
            return
        end

        RichManController:GetInstance():RequestRichManFitchInfo(self.data.round)
    end
    AddButtonEvent(self.okBtn.gameObject,call_back)
end

function RichManRoundItem:SetData(data)
    self.data = data
    self:CreateIcon()
    self.round.text = data.round
end

function RichManRoundItem:CreateIcon()
    local rewardTab = String2Table(self.data.reward)
    self.itemicon = self.itemicon or {}
    if rewardTab then
        for i = 1, #rewardTab do
            local itemId = rewardTab[i][1]
            local num = rewardTab[i][2]
            local bind = rewardTab[i][3] or 2
            local item =  self.itemicon[i]
            if not item then
                item = GoodsIconSettorTwo(self.iconParent)
                self.itemicon[i] = item
            end
            --if self.itemicon[i] == nil then
            --    self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
            --end
            local param = {}
            param["model"] = BagModel
            param["item_id"] = itemId
            param["num"] = num
            param["bind"] = bind
            param["can_click"] = true
            param["size"] = {x = 78,y = 78}
            self.itemicon[i]:SetIcon(param)
        end
    end
end
-- 1可领取  2未达成   3已领取
function RichManRoundItem:SetRewardInfo(type)
    self.reward = type
    if self.reward == 1 then
        ShaderManager.GetInstance():SetImageNormal(self.btnImg)
        SetVisible(self.okBtn,true)
        SetVisible(self.ylqImg,false)
        SetVisible(self.wdcImg,false)
    elseif self.reward == 2 then
        ShaderManager.GetInstance():SetImageGray(self.btnImg)
        SetVisible(self.okBtn,false)
        SetVisible(self.ylqImg,false)
        SetVisible(self.wdcImg,true)
    else
        SetVisible(self.okBtn,false)
        SetVisible(self.ylqImg,true)
        SetVisible(self.wdcImg,false)
    end
end
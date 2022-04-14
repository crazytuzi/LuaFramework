---
--- Created by  Administrator
--- DateTime: 2020/4/20 10:50
---
RichManRecharItem = RichManRecharItem or class("RichManRecharItem", BaseCloneItem)
local this = RichManRecharItem

function RichManRecharItem:ctor(obj, parent_node, parent_panel)
    RichManRecharItem.super.Load(self)
    self.events = {}
end

function RichManRecharItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.eft then
        self.eft:destroy()
    end
end

function RichManRecharItem:LoadCallBack()
    self.nodes = {
        "ykdes","domNum","domImg","num","ptdes","effParent","line",
    }
    self:GetChildren(self.nodes)
    self.num = GetText(self.num)
    self.domNum = GetText(self.domNum)
    self.domImg = GetImage(self.domImg)
    self:InitUI()
    self:AddEvent()
end

function RichManRecharItem:InitUI()
    local iconName = Config.db_item[enum.ITEM.ITEM_GOLD].icon
    GoodIconUtil:CreateIcon(self, self.domImg, iconName, true)
    --if not self.eft then
    --    self.eft = UIEffect(self.effParent, 45001, false, self.layer)
    --    self.eft:SetConfig({ is_loop = true })
    --    self.eft.is_hide_clean = false
    --    self.eft:SetOrderIndex(423)
    --end

end

function RichManRecharItem:AddEvent()

end

function RichManRecharItem:SetData(data,actId)
    self.data = data
    self.cfgData = OperateModel:GetInstance():GetRewardConfig(actId, self.data.id)
    self:SetState(data.state)
    local rewardTab = String2Table(self.cfgData.reward)
    local id = rewardTab[1][1]
    local touNum = rewardTab[1][2]
    local tab = String2Table(self.cfgData.task)
    local num = tab[2]
   -- self.domNum.text = num
    self.num.text = touNum
    SetVisible(self.ykdes,id == RichManModel:GetInstance().ykTouzi)
    SetVisible(self.ptdes,id == RichManModel:GetInstance().touzi)

    --06ECEE
    local color = "06ECEE"
    if self.data.count < num then
        color = "FF0000"
    end

    self.domNum.text = string.format("<color=#%s>%s/%s</color>", color, self.data.count, num)
end

function RichManRecharItem:SetState(state)
    if state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
        --未完成
        SetVisible(self.line,false)
    elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
        --已完成
        SetVisible(self.line,false)
    elseif state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        --已领取
        SetVisible(self.line,true)
    end
end
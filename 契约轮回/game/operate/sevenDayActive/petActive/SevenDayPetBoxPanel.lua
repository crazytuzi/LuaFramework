---
--- Created by  Administrator
--- DateTime: 2019/8/24 15:50
---
SevenDayPetBoxPanel = SevenDayPetBoxPanel or class("SevenDayPetBoxPanel", BaseItem)
local this = SevenDayPetBoxPanel

function SevenDayPetBoxPanel:ctor(parent_node, parent_panel,actID, assetName)
    self.abName = "sevenDayActive"
    self.assetName = assetName or "SevenDayPetBoxPanel"
    self.is_ill = assetName
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.rewardItems = {}
    self.itemicon = {}
    self.model = SevenDayActiveModel:GetInstance()
    self.actID = actID
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    SevenDayRushBuyPanel.super.Load(self)
end

function SevenDayPetBoxPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.parentPanel = nil
end

function SevenDayPetBoxPanel:LoadCallBack()
    self.nodes = {
        "iconParent","time","goBtn"
    }
    self:GetChildren(self.nodes)
    self.time = GetText(self.time)
    self:InitUI()
    self:AddEvent()
end

function SevenDayPetBoxPanel:InitUI()
    self:InitActTime()
    local rewardCfg = OperateModel:GetInstance():GetConfig(self.actID)
    if not rewardCfg then
        return
    end
    local rewardtab =  String2Table(rewardCfg.reward)
    for i = 1, #rewardtab do
        --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = rewardtab[i][1]
        param["num"] = rewardtab[i][2]
        param["bind"] = rewardtab[i][3]
        param["can_click"] = true
        param["size"] = {x = 78,y = 78}
        param["effect_type"] = 1
        param["color_effect"] = 5

        param["stencil_id"] = self.StencilId
        param["stencil_type"] = 3
        self.itemicon[i]:SetIcon(param)
    end
    -- dump(OperateModel:GetInstance():GetActInfo(self.actID))
   -- self:SetState()
end

function SevenDayPetBoxPanel:AddEvent()
    local function call_back()
        if self.is_ill then
            OpenLink(160,1,1,1)
        else
            OpenLink(160,1,3,1)
        end
    end
    AddClickEvent(self.goBtn.gameObject,call_back)
end

function SevenDayPetBoxPanel:InitActTime()
    local stime = self:GetActTime(self.openData.act_stime)
    local etime = self:GetActTime(self.openData.act_etime)
    local cfg =  OperateModel:GetInstance():GetConfig(self.actID)
    --self.des.text = "活动说明："..cfg.desc
    self.time.text = string.format("Event Time: %s-%s,\n%s",stime,etime,cfg.desc)
end

function SevenDayPetBoxPanel:GetActTime(time)
    local timeTab = TimeManager:GetTimeDate(time)
    local timestr = "";
    if timeTab.month then
        timestr = timestr .. string.format("%02d", timeTab.month) .. "M";
    end
    if timeTab.day then
        timestr = timestr .. string.format("%d", timeTab.day) .. "Sunday ";
    end
    if timeTab.hour then
        timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
    end
    if timeTab.min then
        timestr = timestr .. string.format("%02d", timeTab.min) .. "";
    end
    return timestr
end

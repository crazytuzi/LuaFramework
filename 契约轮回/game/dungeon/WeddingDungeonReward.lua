---
--- Created by  Administrator
--- DateTime: 2019/7/13 16:29
---
WeddingDungeonReward = WeddingDungeonReward or class("WeddingDungeonReward", BaseCloneItem)
local this = WeddingDungeonReward

function WeddingDungeonReward:ctor(obj, parent_node, parent_panel)
    WeddingDungeonReward.super.Load(self)
    self.events = {}
    self.model = MarryModel:GetInstance()
end

function WeddingDungeonReward:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function WeddingDungeonReward:LoadCallBack()
    self.nodes = {
        "rewardImg1","lqBtn1","lqBtn1/lqBtnText1"
    }
    self:GetChildren(self.nodes)
    self.lqBtnText1 = GetText(self.lqBtnText1)
    self.rewardImg1 = GetImage(self.rewardImg1)
    self.btnImg = GetImage(self.lqBtn1)
    self:InitUI()
    self:AddEvent()
    self.red = RedDot(self.lqBtn1, nil, RedDot.RedDotType.Nor)
    self.red:SetPosition(29, 8)

end

function WeddingDungeonReward:InitUI()

end

function WeddingDungeonReward:AddEvent()

    local function call_back()
        if self.state == 0 then
            Notify.ShowText("Rewards have been claimed")
            return
        elseif self.state == 1 then
            Notify.ShowText("Insufficient Popularity")
            return
        else
            MarryController:GetInstance():RequsetPartyFetch(self.data.lv)
        end
    end
    AddClickEvent(self.lqBtn1.gameObject,call_back)
    AddClickEvent(self.rewardImg1.gameObject,call_back)
end

function WeddingDungeonReward:SetData(data)
    self.data = data
    self:SetState()
    self:SetPos()
end

function WeddingDungeonReward:SetPos()
    local  max = self.model:GetHotLimit()
    local  lv = self.data.lv
    if self.data.lv == 520 then
        SetLocalPosition(self.transform,0,0,0)
    elseif self.data.lv == 1314 then
        SetLocalPosition(self.transform,90,0,0)
    else
        SetLocalPosition(self.transform,238,0,0)
    end
    --0  230
    --SetLocalPosition(self.transform,(lv/max)*230,0)
end

function WeddingDungeonReward:SetState()
    --ShaderManager.GetInstance():SetImageGray(self.rewardImg1)
    local isReward = self.model:IsHotReward(self.data.lv)
    if isReward then
        self.state = 0
        self.lqBtnText1.text = "Claimed"
        self.red:SetRedDotParam(false)
        lua_resMgr:SetImageTexture(self, self.rewardImg1, "dungeon_image", "dunge_marry_box", true, nil, false)
        ShaderManager.GetInstance():SetImageGray(self.btnImg)
    else
        if self.model.curHot <  self.data.lv then
            self.state = 1
            self.lqBtnText1.text = self.data.lv
            ShaderManager.GetInstance():SetImageGray(self.btnImg)
            self.red:SetRedDotParam(false)
        else
            self.state = 2
            self.lqBtnText1.text = "Claim"
            self.red:SetRedDotParam(true)
            ShaderManager.GetInstance():SetImageNormal(self.btnImg)
        end
    end

end
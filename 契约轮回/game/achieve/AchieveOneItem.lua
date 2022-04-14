---
--- Created by  Administrator
--- DateTime: 2019/4/2 17:37
---
AchieveOneItem = AchieveOneItem or class("AchieveOneItem", BaseCloneItem)
local this = AchieveOneItem

function AchieveOneItem:ctor(obj, parent_node, parent_panel)
    AchieveOneItem.super.Load(self)
    self.events = {}
    self.model = AchieveModel:GetInstance()
    self.itemicon = {}
end

function AchieveOneItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
    if self.rewardBtn_red then
        self.rewardBtn_red:destroy()
        self.rewardBtn_red = nil
    end
end

function AchieveOneItem:LoadCallBack()
    self.nodes = {
        "des","itemparent","name","isReceive","RecBtn","sign/achieveNum"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.des = GetText(self.des)
    self.achieveNum = GetText(self.achieveNum)
    self.isReceiveImg = GetImage(self.isReceive)
    self:InitUI()
    self:AddEvent()
    self.rewardBtn_red = RedDot(self.RecBtn, nil, RedDot.RedDotType.Nor)
    self.rewardBtn_red:SetPosition(50, 13)
end

function AchieveOneItem:InitUI()

end

function AchieveOneItem:AddEvent()
    function call_back()
        AchieveController:GetInstance():RequsestReward(self.data.id)
    end
    AddButtonEvent(self.RecBtn.gameObject,call_back)
end

function AchieveOneItem:SetData(data)
    self.data = data

    --print2(self.data.state)
    self:SetItemInfo()

end
function AchieveOneItem:SetItemInfo()
    local cfg = Config.db_achieve[self.data.id]
    self.name.text = cfg.title
    self.des.text = cfg.desc
    self.achieveNum.text = cfg.point
    self:SetIsReceive()
    local rewardTab = String2Table(cfg.reward)
    for i, v in pairs(self.itemicon) do
        v:destroy()
    end
    self.itemicon = {}
    for i = 1, #rewardTab do
        --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
        if self.itemicon[i] == nil then
            self.itemicon[i] = GoodsIconSettorTwo(self.itemparent)
        end
        local param = {}
        param["model"] = self.model
        param["item_id"] = rewardTab[i][1]
        param["num"] = rewardTab[i][2]
        param["can_click"] = true
        self.itemicon[i]:SetIcon(param)
    end

end
--设置领取状态
function AchieveOneItem:SetIsReceive()
    self.rewardBtn_red:SetRedDotParam(self.data.state == 1)
    if self.data.state == 3 then --已经领取
        SetVisible(self.RecBtn,false)
        SetVisible(self.isReceive,true)
        lua_resMgr:SetImageTexture(self,self.isReceiveImg, 'common_image', 'img_have_received_1',true)
       -- self.rewardBtn_red:SetRedDotParam(false)
    elseif self.data.state == 1 then --可领取
       -- SetVisible(self.RecBtn,false)
        SetVisible(self.RecBtn,true)
        SetVisible(self.isReceive,false)
     --   self.rewardBtn_red:SetRedDotParam(true)
    else --未达到
        SetVisible(self.RecBtn,false)
        SetVisible(self.isReceive,true)
        lua_resMgr:SetImageTexture(self,self.isReceiveImg, 'common_image', 'img_have_notReached',true)
        --self.rewardBtn_red:SetRedDotParam(false)
    end
end

--function AchieveOneItem:CreateIcon(id,num)
--    if self.itemicon == nil then
--        self.itemicon = GoodsIconSettorTwo(self.itemparent)
--    end
--    local param = {}
--    param["model"] = self.model
--    param["item_id"] = id
--    param["num"] = num
--    self.itemicon:SetIcon(param)
--end
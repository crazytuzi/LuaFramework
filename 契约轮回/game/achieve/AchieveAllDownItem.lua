---
--- Created by  Administrator
--- DateTime: 2019/4/2 17:53
---
AchieveAllDownItem = AchieveAllDownItem or class("AchieveAllDownItem", BaseCloneItem)
local this = AchieveAllDownItem

function AchieveAllDownItem:ctor(obj, parent_node, parent_panel)
    AchieveAllDownItem.super.Load(self)
    self.model = AchieveModel:GetInstance()
    self.events = {}
end

function AchieveAllDownItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.itemicon ~= nil then
        self.itemicon:destroy()
    end

    self.itemicon = nil
    if self.rewardBtn_red then
        self.rewardBtn_red:destroy()
        self.rewardBtn_red = nil
    end
end

function AchieveAllDownItem:LoadCallBack()
    self.nodes = {
        "recBtn","num","isReceive","name","des","iconParen",
    }
    self:GetChildren(self.nodes)
    self.num = GetText(self.num)
    self.name = GetText(self.name)
    self.des = GetText(self.des)
    self.isReceiveImg = GetImage(self.isReceive)
    self:InitUI()
    self:AddEvent()
    self.rewardBtn_red = RedDot(self.recBtn, nil, RedDot.RedDotType.Nor)
    self.rewardBtn_red:SetPosition(37, 14)
end

function AchieveAllDownItem:InitUI()

end

function AchieveAllDownItem:AddEvent()
    function call_back()
        AchieveController:GetInstance():RequsestReward(self.data.id)
    end
    AddButtonEvent(self.recBtn.gameObject,call_back)
end
function AchieveAllDownItem:SetData(data)
    self.data = data
    self:UpdateInfo()
end
function AchieveAllDownItem:UpdateInfo()
    local cfg = Config.db_achieve[self.data.id]
    if cfg then
        self.name.text = cfg.title
        self.des.text = cfg.desc
        local award = String2Table(cfg.reward)
        self:SetIsReceive()
        self:CreateIcon(award[1][1],award[1][2])
        self:SetPoint(cfg)
    end
end

function AchieveAllDownItem:CreateIcon(id,num)
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParen)
    end
    local param = {}
    param["model"] = self.model
    param["item_id"] = id
    param["num"] = num
    param["can_click"] = true
    self.itemicon:SetIcon(param)
end

function AchieveAllDownItem:SetIsReceive()
    self.rewardBtn_red:SetRedDotParam(self.data.state == 1)
    if self.data.state == 3 then --已经领取
        SetVisible(self.recBtn,false)
        SetVisible(self.isReceive,true)
        lua_resMgr:SetImageTexture(self,self.isReceiveImg, 'common_image', 'img_have_received_1',true)
    elseif self.data.state == 1 then --可领取
        -- SetVisible(self.RecBtn,false)
        SetVisible(self.recBtn,true)
        SetVisible(self.isReceive,false)
    else --未达到
        SetVisible(self.recBtn,false)
        SetVisible(self.isReceive,true)
        lua_resMgr:SetImageTexture(self,self.isReceiveImg, 'common_image', 'img_have_notReached',true)
    end
end

function AchieveAllDownItem:SetPoint(cfg)
    local tab = String2Table(cfg.target)
    local allPoint = tab[3]
    local curPoint = self.data.num
    if curPoint > allPoint then
        curPoint = allPoint
    end
   -- print2(curPoint,"curPoint")
    local color
    if curPoint < allPoint then
        color = "e63232"
    else
        color = "34B234"
    end

    self.num.text = string.format("<color=#%s>%s/%s</color>",color,curPoint,allPoint)
end
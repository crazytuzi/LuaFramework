---
--- Created by  Administrator
--- DateTime: 2019/11/22 17:02
---
CompeteDungelBuffItem = CompeteDungelBuffItem or class("CompeteDungelBuffItem", BaseCloneItem)
local this = CompeteDungelBuffItem

function CompeteDungelBuffItem:ctor(obj, parent_node, parent_panel)
    CompeteDungelBuffItem.super.Load(self)
    self.events = {}
end

function CompeteDungelBuffItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function CompeteDungelBuffItem:LoadCallBack()
    self.nodes = {
        "buyBtn","money","icon","moneyIcon","name",
    }
    self:GetChildren(self.nodes)
    self.money = GetText(self.money)
    self.icon = GetImage(self.icon)
    self.name = GetText(self.name)
    self.moneyIcon = GetImage(self.moneyIcon)
    self.buyBtnImg = GetImage(self.buyBtn)
    self:InitUI()
    self:AddEvent()
end

function CompeteDungelBuffItem:InitUI()

end

function CompeteDungelBuffItem:AddEvent()
    local function call_back()
        if self.isHave then
            Notify.ShowText("You already had the Buff")
            return
        end
        CompeteController:GetInstance():RequstCompeteBuffInfo(self.showId)
    end
    AddClickEvent(self.buyBtn.gameObject,call_back)
end

function CompeteDungelBuffItem:SetData(buffId,costId,costNum,showId)
    self.buffId = buffId
    self.costId = costId
    self.costNum = costNum
    self.showId = showId
    local iconName = Config.db_item[self.costId].icon
    GoodIconUtil:CreateIcon(self, self.moneyIcon, iconName, true)
    lua_resMgr:SetImageTexture(self, self.icon, "compete_image",self.buffId  , true, nil, false)
    self:UpdateInfo()
    self:SetBtnState()
end

function CompeteDungelBuffItem:UpdateInfo()
    local cfg = Config.db_buff[self.buffId]
    if not cfg then
        logError("没有BUFF id ："..self.buffId)
        return
    end
    self.money.text = self.costNum
    self.name.text = cfg.desc
end

function CompeteDungelBuffItem:SetBtnState()
    local role =  RoleInfoModel:GetInstance():GetMainRoleData()
    local buffs = role.buffs
    self.isHave = false
    for i, v in pairs(buffs) do
        if v.id == self.showId then
            self.isHave = true
        end
    end
    if  self.isHave  then --有BUFF
        ShaderManager:GetInstance():SetImageGray(self.buyBtnImg)
    else
        ShaderManager:GetInstance():SetImageNormal(self.buyBtnImg)
    end
end
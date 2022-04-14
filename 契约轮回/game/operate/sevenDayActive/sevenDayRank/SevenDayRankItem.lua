---
--- Created by  Administrator
--- DateTime: 2019/4/17 19:34
---
SevenDayRankItem = SevenDayRankItem or class("SevenDayRankItem", BaseCloneItem)
local this = SevenDayRankItem

function SevenDayRankItem:ctor(obj, parent_node, parent_panel)
    SevenDayRankItem.super.Load(self)
    self.events = {}
    self.model = SevenDayActiveModel:GetInstance()
end

function SevenDayRankItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function SevenDayRankItem:LoadCallBack()
    self.nodes = {
        "rankImg","name","power","rankTex","bg"
    }
    self:GetChildren(self.nodes)
    self.rankImg = GetImage(self.rankImg)
    self.name = GetText(self.name)
    self.rankTex = GetText(self.rankTex)
    self.power = GetText(self.power)
    self:InitUI()
    self:AddEvent()
end

function SevenDayRankItem:InitUI()

end

function SevenDayRankItem:AddEvent()
    local function call_back()
        if not self.data then
            return
        end
        local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.name)
        panel:Open(self.data.base)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end
function SevenDayRankItem:SetData(data,actID,type,index)
    dump(data)
    self.data = data
    self.actID = actID
    if type == 2 then
        self.rankId = actID
    else
        self.rankId = OperateModel:GetInstance():GetConfig(self.actID).rank
    end
    self.cfgData = RankModel:GetInstance():GetRankById(self.rankId)
    if data == nil then
        self.name.text = "Nobody made the list yet"
        self.rankTex.text =  index
        SetVisible(self.rankImg,false)
       -- SetVisible(self.power,false)
        local limen = self.cfgData.limen
        --E77E5B
        local des = ""
        if self.rankId == 110501 then --等級
            des = string.format("<color=#E77E5B>Requires LV.%s</color>",limen)
        elseif self.rankId == 110502 then --坐骑
            local cfg = self.model:GetMountNumByID(limen)
            des = string.format("<color=#E77E5B>Requires %sTier%sStar</color>",cfg.order,cfg.level)
        elseif self.rankId == 110503 then --副手
            local cfg = self.model:GetOffhandNumByID(limen)
            des = string.format("<color=#E77E5B>Requires %sTier%sStar</color>",cfg.order,cfg.level)
        elseif self.rankId == 110504 then --魂卡
            des = string.format("<color=#E77E5B>Require: %s CP</color>",GetShowNumber(limen))
        elseif self.rankId == 110505 then --充值
            des = string.format("<color=#E77E5B>Recharge required %s diamonds</color>",limen)
        elseif self.rankId == 110506 then --战力
            des = string.format("<color=#E77E5B>Require: %s CP</color>",GetShowNumber(limen))
        elseif self.rankId == 180505 then
            des = string.format("<color=#E77E5B>Need to consume %s diamonds</color>",GetShowNumber(limen))
        elseif self.rankId == 180506 then
            des = string.format("<color=#E77E5B>Recharge required %s diamonds</color>",GetShowNumber(limen))
        else
            des = string.format("<color=#E77E5B>Require %s CP</color>",GetShowNumber(limen))
        end
        self.power.text = des
        return
    end

     SetVisible(self.power,true)



   -- dump(self.data)
    self:UpdateInfo()
end

function SevenDayRankItem:UpdateInfo()
    local rank =  self.data.rank
    self.name.text = self.data.base.name
    self:SetPowerTex(self.data.sort)

    if rank <= 3 then
        SetVisible(self.rankTex,false)
        lua_resMgr:SetImageTexture(self,self.rankImg, 'sevenDayActive_image', 'sevenDayActive_ranksign'..rank,true)
    else
        self.rankTex.text = rank
        SetVisible(self.rankImg,false)
    end

end

function SevenDayRankItem:SetPowerTex(power)
    --print2(self.cfgData.event)
    --local str = ""
    --if true then
    --
    --end
    if  self.rankId == 110502 then  --坐骑
        local cfg = self.model:GetMountNumByID(power)
        self.power.text = string.format("T%sS%s",cfg.order,cfg.level)
    elseif  self.rankId == 110503 then --副手
        local cfg = self.model:GetOffhandNumByID(power)
        self.power.text = string.format("T%sS%s",cfg.order,cfg.level)
    else
        self.power.text = power
    end


end
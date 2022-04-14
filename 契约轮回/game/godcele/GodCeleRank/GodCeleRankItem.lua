---
--- Created by  Administrator
--- DateTime: 2019/4/17 19:34
---
GodCeleRankItem = GodCeleRankItem or class("GodCeleRankItem", BaseCloneItem)
local this = GodCeleRankItem

function GodCeleRankItem:ctor(obj, parent_node, parent_panel)
    GodCeleRankItem.super.Load(self)
    self.events = {}
    self.model = GodCelebrationModel:GetInstance()
end

function GodCeleRankItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function GodCeleRankItem:LoadCallBack()
    self.nodes = {
        "rankImg", "name", "power", "rankTex"
    }
    self:GetChildren(self.nodes)
    self.rankImg = GetImage(self.rankImg)
    self.name = GetText(self.name)
    self.rankTex = GetText(self.rankTex)
    self.power = GetText(self.power)
    self:InitUI()
    self:AddEvent()
end

function GodCeleRankItem:InitUI()

end

function GodCeleRankItem:AddEvent()

end
function GodCeleRankItem:SetData(data, actID, type, index)
    dump(data)
    if data == nil then
        self.name.text = "Nobody has made the list yet"
        self.rankTex.text = index
        SetVisible(self.rankImg, false)
        --SetVisible(self.power,false)
        local need_power = self.model.need_power
        self.power.text = string.format(ConfigLanguage.GodCele.EnoughPowerToTop, need_power)
        return
    end
    SetVisible(self.power, true)
    self.data = data
    self.actID = actID
    if type == 2 then
        self.rankId = actID
    else
        self.rankId = OperateModel:GetInstance():GetConfig(self.actID).rank
    end
    self.cfgData = RankModel:GetInstance():GetRankById(self.rankId)
    -- dump(self.data)
    self:UpdateInfo()
end

function GodCeleRankItem:UpdateInfo()
    local rank = self.data.rank
    self.name.text = self.data.base.name
    self:SetPowerTex(self.data.sort)

    if rank <= 3 then
        SetVisible(self.rankTex, false)
        lua_resMgr:SetImageTexture(self, self.rankImg, 'sevenDayActive_image', 'sevenDayActive_ranksign' .. rank, true)
    else
        self.rankTex.text = rank
        SetVisible(self.rankImg, false)
    end

end

function GodCeleRankItem:SetPowerTex(power)
    --print2(self.cfgData.event)
    --local str = ""
    --if true then
    --
    --end
    if self.rankId == 110502 then
        --坐骑
        local cfg = self.model:GetMountNumByID(power)
        self.power.text = string.format("T%sS%s", cfg.order, cfg.level)
    elseif self.rankId == 110503 then
        --副手
        local cfg = self.model:GetOffhandNumByID(power)
        self.power.text = string.format("T%sS%s", cfg.order, cfg.level)
    else
        self.power.text = power
    end


end
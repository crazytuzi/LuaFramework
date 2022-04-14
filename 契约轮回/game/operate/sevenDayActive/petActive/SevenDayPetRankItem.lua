---
--- Created by  Administrator
--- DateTime: 2019/8/23 11:35
---
SevenDayPetRankItem = SevenDayPetRankItem or class("SevenDayPetRankItem", BaseCloneItem)
local this = SevenDayPetRankItem

function SevenDayPetRankItem:ctor(obj, parent_node, parent_panel)
    SevenDayPetRankItem.super.Load(self)
    self.events = {}
end

function SevenDayPetRankItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function SevenDayPetRankItem:LoadCallBack()
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

function SevenDayPetRankItem:InitUI()

end

function SevenDayPetRankItem:AddEvent()
    local function call_back()
        if not self.data then
            return
        end
        local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.name)
        panel:Open(self.data.base)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function SevenDayPetRankItem:SetData(data,actID,type,index)
    self.data = data
    self.actID = actID
    if type == 2 then
        self.rankId = actID
    else
        self.rankId = OperateModel:GetInstance():GetConfig(self.actID).rank
    end
    self.cfgData = RankModel:GetInstance():GetRankById(self.rankId)
    if data == nil then
        self.name.text = "Nobody has made the list yet"
        self.rankTex.text =  index
        SetVisible(self.rankImg,false)
     --   SetVisible(self.power,false)

        local limen = self.cfgData.limen
        --E77E5B
        local des = ""
        if self.rankId == 130101 then --宠物
            des = string.format("<color=#E77E5B>Require: %s CP</color>",GetShowNumber(limen))
        end
        self.power.text = des
        return
    end
    SetVisible(self.power,true)


    -- dump(self.data)
    self:UpdateInfo()
end

function SevenDayPetRankItem:UpdateInfo()
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

function SevenDayPetRankItem:SetPowerTex(power)
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
---
--- Created by  Administrator
--- DateTime: 2019/4/19 16:42
---
GodCeleRankLastPanel = GodCeleRankLastPanel or class("GodCeleRankLastPanel", WindowPanel)
local this = GodCeleRankLastPanel

function GodCeleRankLastPanel:ctor(parent_node, parent_panel)
    self.abName = "sevenDayActive"
    self.assetName = "GodCeleRankLastPanel"
    self.layer = "UI"
    self.events = {}
    self.rankItems = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 3
    self.model = GodCelebrationModel:GetInstance()
end

function GodCeleRankLastPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    for _, item in pairs(self.rankItems) do
        item:destroy()
    end
    self.rankItems = {}
end

function GodCeleRankLastPanel:Open(rankID)
    self.rankID = rankID
    GodCeleRankLastPanel.super.Open(self)
end

function GodCeleRankLastPanel:LoadCallBack()
    self.nodes = {
        "myRank","myPower","time","SevenDayRankItem","rankScrollView/Viewport/rankContent","power"
    }
    self:GetChildren(self.nodes)
    self.myRank = GetText(self.myRank)
    self.myPower =GetText(self.myPower)
    self.power = GetText(self.power)
    self:SetPanelSize(390,465)
    self:SetTileTextImage("sevenDayActive_image", "sevenDayActive_titleImg2");
    self:InitUI()
    self:AddEvent()
    RankController:GetInstance():RequestRankListInfo(self.rankID,0)

end

function GodCeleRankLastPanel:InitUI()

end

function GodCeleRankLastPanel:AddEvent()
    self.events[#self.events+1] = GlobalEvent.AddEventListener(RankEvent.RankReturnList,handler(self,self.RankReturnList))
end

function GodCeleRankLastPanel:RankReturnList(data)
    local list = data.list
    self:SetMyInfo(data.mine)
    local rankCfg = RankModel:GetInstance():GetRankById(self.rankID)
    local size = rankCfg.size
    for i = 1, size do
        self.rankItems[i] = SevenDayRankItem(self.SevenDayRankItem.gameObject,self.rankContent,"UI")
        self.rankItems[i]:SetData(nil,self.rankID,2,i)
    end

    for i = 1, #list do
      --  self.rankItems[i] = SevenDayRankItem(self.SevenDayRankItem.gameObject,self.rankContent,"UI")
        self.rankItems[i]:SetData(list[i],self.rankID,2)
    end
end

function GodCeleRankLastPanel:SetMyInfo(mine)
    local rankStr = ""
    if mine.rank == 0 then   --没有排名
        rankStr = string.format("%s<color=#27C31F>%s</color>","Ranking:","Didn't make list")
    else
        rankStr = string.format("%s<color=#27C31F>%s</color>","Ranking:",mine.rank)
    end
    self.myRank.text = rankStr

    self.rankCfg =   RankModel:GetInstance():GetRankById(self.rankID)
    self.power.text = self.rankCfg.showdata
    --local des = self.model:GetRankTypeStr(self.rankCfg.event,self.rankCfg.id)
    --self.myPower.text = "我的："..des
    if self.rankID == 110502  then  --坐骑
        if mine.sort ~= 0 then
            local cfg = self.model:GetMountNumByID(mine.sort)
            self.myPower.text = string.format("My: T%sS%s",cfg.order,cfg.level)
        else
            self.myPower.text = string.format("My: T%sS%s",0,0)
        end

    elseif self.rankID == 110503 then
        if mine.sort ~= 0 then
            local cfg = self.model:GetOffhandNumByID(mine.sort)
            self.myPower.text = string.format("My: T%sS%s",cfg.order,cfg.level)
        else
            self.myPower.text = string.format("My: T%sS%s",0,0)
        end

    else
        self.myPower.text = "My:"..mine.sort
    end

end


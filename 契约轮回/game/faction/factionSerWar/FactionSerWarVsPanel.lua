---
--- Created by  Administrator
--- DateTime: 2020/5/15 16:07
---
FactionSerWarVsPanel = FactionSerWarVsPanel or class("FactionSerWarVsPanel", BaseItem)
local this = FactionSerWarVsPanel

function FactionSerWarVsPanel:ctor(parent_node, parent_panel)
    self.abName = "faction"
    self.assetName = "FactionSerWarVsPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.model = FactionSerWarModel.GetInstance()
    self.events = {}
    self.itemicon = {}
    self.round1Items = {}
    self.round2Items = {}
    FactionSerWarVsPanel.super.Load(self)
end

function FactionSerWarVsPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if not table.isempty(self.round1Items) then
        for i, v in pairs(self.round1Items) do
            v:destroy()
        end
        self.round1Items = {}
    end

    if not table.isempty(self.round2Items) then
        for i, v in pairs(self.round2Items) do
            v:destroy()
        end
        self.round2Items = {}
    end
end

function FactionSerWarVsPanel:LoadCallBack()
    self.nodes = {
        "rewardBtn","scoreText","guildRankText","rightObj/rightTime","leftObj/leftScrollView/Viewport/leftContent",
        "leftObj/leftTime", "FactionSerWarVsPanel","FactionSerWarVsItem","rightObj/rightScrollView/Viewport/rightContent",
        "leftObj/leftScrollView","leftObj/noLeft","rightObj/rightScrollView","rightObj/noRight",
    }
    self:GetChildren(self.nodes)
    self.scoreText = GetText(self.scoreText)
    self.guildRankText = GetText(self.guildRankText)

    self:InitUI()
    self:AddEvent()
    FactionSerWarController:GetInstance():RequstMatchInfo()
    FactionSerWarController:GetInstance():RequstGuildsInfo()
    FactionSerWarController:GetInstance():RequstRankInfo()
end

function FactionSerWarVsPanel:InitUI()

end

function FactionSerWarVsPanel:AddEvent()

    


    local function call_back()
        lua_panelMgr:GetPanelOrCreate(FactionSerWarRewardPanel):Open()
        --SceneControler:GetInstance():RequestSceneChange(81000, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, 12003);
    end
    AddButtonEvent(self.rewardBtn.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(FactionSerWarEvent.MatchInfo, handler(self, self.MatchInfo))
    self.events[#self.events +1 ] = self.model:AddListener(FactionSerWarEvent.GuildsInfo,handler(self,self.GuildsInfo))
   -- self.events[#self.events + 1] = self.model:AddListener(FactionSerWarEvent.RankInfo,handler(self,self.RankInfo))
end

function FactionSerWarVsPanel:MatchInfo(data)
   -- data.round1
   -- SetVisible(self.noLeft,table.isempty(data.round1))
    if table.isempty(data.round1) then
        SetVisible(self.noLeft,true)
    else
        SetVisible(self.noLeft,false)
        for i = 1, #data.round1 do
            local item = self.round1Items[i]
            if not item then
                item  = FactionSerWarVsItem(self.FactionSerWarVsItem.gameObject,self.leftContent,"UI")
                self.round1Items[i] = item;
            end
            item:SetData(data.round1[i])
        end
    end


    if table.isempty(data.round2) then
        SetVisible(self.noRight,true)
    else
        SetVisible(self.noRight,false)
        for i = 1, #data.round2 do
            local item = self.round2Items[i]
            if not item then
                item  = FactionSerWarVsItem(self.FactionSerWarVsItem.gameObject,self.rightContent,"UI")
                self.round2Items[i] = item;
            end
            item:SetData(data.round2[i])
        end
    end

end

function FactionSerWarVsPanel:GuildsInfo(data)
    self.scoreText.text = data.my_score
    self.guildRankText.text = string.format(FactionSerWarModel.desTab.rank,data.my_rank)
    if data.my_rank == 0 then
        self.guildRankText.text = FactionSerWarModel.desTab.noRank
    end
end


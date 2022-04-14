---
--- Created by  Administrator
--- DateTime: 2020/5/15 15:41
---
FactionSerWarAppPanel = FactionSerWarAppPanel or class("FactionSerWarAppPanel", BaseItem)
local this = FactionSerWarAppPanel

function FactionSerWarAppPanel:ctor(parent_node, parent_panel)
    self.abName = "faction"
    self.assetName = "FactionSerWarAppPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.model = FactionSerWarModel.GetInstance()
    self.events = {}
    self.itemicon = {}
    self.guildsInfo = {}
    self.roleInfo = RoleInfoModel.GetInstance():GetMainRoleData()
    FactionSerWarAppPanel.super.Load(self)

end

function FactionSerWarAppPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if not table.isempty(self.guildsInfo) then
        for i, v in pairs(self.guildsInfo) do
            v:destroy()
        end
        self.guildsInfo = {}
    end
end

function FactionSerWarAppPanel:LoadCallBack()
    self.nodes = {
        "FactionSerWarAppItem","guilddes/guidlName","scoredes/scoreTex","rewardBtn",
        "appdes/appTimeTex","ScrollView/Viewport/Content",
    }
    self:GetChildren(self.nodes)
    self.guidlName = GetText(self.guidlName)
    self.scoreTex = GetText(self.scoreTex)
    self.appTimeTex = GetText(self.appTimeTex)
    self:InitUI()
    self:AddEvent()

    FactionSerWarController:GetInstance():RequstRankInfo()
    --self.roleInfo
    logError(self.roleInfo.guild)
end

function FactionSerWarAppPanel:InitUI()

end

function FactionSerWarAppPanel:AddEvent()
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(FactionSerWarRewardPanel):Open()
    end
    AddButtonEvent(self.rewardBtn.gameObject,call_back)



    self.events[#self.events +1 ] = self.model:AddListener(FactionSerWarEvent.GuildsInfo,handler(self,self.GuildsInfo))
    self.events[#self.events +1 ] = self.model:AddListener(FactionSerWarEvent.BookInfo,handler(self,self.BookInfo))
    self.events[#self.events + 1] = self.model:AddListener(FactionSerWarEvent.RankInfo,handler(self,self.RankInfo))

end

function FactionSerWarAppPanel:GuildsInfo(data)
    --if self.roleInfo.guild and tostring(self.roleInfo.guild) == "0" then --没有工会
    --    self.guidlName.text = "未上榜";
    --
    --else
    --    local rank = self.model:GetMyGuildRank()
    --    if rank == 0 then
    --        self.guidlName.text = "未上榜";
    --    else
    --        self.guidlName.text = string.format("第%s名",rank)
    --    end
    --   -- self.guidlName.text = self.roleInfo.gname;
    --end
    if data.my_rank == 0 then
        self.guidlName.text = FactionSerWarModel.desTab.noRank;
    else
        self.guidlName.text = string.format(FactionSerWarModel.desTab.rank,data.my_rank)
    end
    self.scoreTex.text = self.model.my_scroe
    self.appTimeTex.text = self.model.booktimes

    self:UpdateGuildInfos()

end

function FactionSerWarAppPanel:UpdateGuildInfos()
    local tab = self.model.guildsInfo
    for i = 1, #tab do
        local item = self.guildsInfo[i]
        if not item then
            item  = FactionSerWarAppItem(self.FactionSerWarAppItem.gameObject,self.Content,"UI")
            self.guildsInfo[i] = item
        end
        item:SetData(tab[i])
    end
end

function FactionSerWarAppPanel:RankInfo()
    FactionSerWarController:GetInstance():RequstGuildsInfo()
end

function FactionSerWarAppPanel:BookInfo(data)
   --logError("预约成功")
    self.appTimeTex.text = self.model.booktimes
    for i = 1, #self.guildsInfo do
        if data.guild_id == self.guildsInfo[i].data.id  then
            self.guildsInfo[i]:BtnState(RoleInfoModel.GetInstance():GetMainRoleData().guild)
        end
    end
end






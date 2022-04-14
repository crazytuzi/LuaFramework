---
--- Created by R2D2.
--- DateTime: 2019/2/20 9:57
---

---主宰神殿主界面
FactionBattleTemplePanel = FactionBattleTemplePanel or class("FactionBattleTemplePanel", BaseItem)
local FactionBattleTemplePanel = FactionBattleTemplePanel
local titleView = require("game.faction.temple.FactionBattleTempleTitleView")

function FactionBattleTemplePanel:ctor()
    self.abName = "faction"
    self.assetName = "FactionBattleTemplePanel"
    self.layer = "UI"

   -- self.panel_type = 2
   -- self.show_sidebar = true
    self.modelEvents = {}
    self.events = {}
    self.dataModel = FactionBattleModel.GetInstance()
    --self.sidebar_data = {
    --    --{ text = ConfigLanguage.FactionBattle.Temple, id = 1, img_title = "faction:faction_faction" },
    --    {text = ConfigLanguage.FactionBattle.Temple, id = 1}
    --}

    self.RoleCount = 3
    BaseItem.Load(self)
end

function FactionBattleTemplePanel:dctor()
    titleView:dctor()

    if (self.UIRoles) then
        for _, v in pairs(self.UIRoles) do
            v:destroy()
        end

        self.UIRoles = nil
    end
    GlobalEvent:RemoveTabListener(self.events)
    self.dataModel:RemoveTabListener(self.modelEvents)
    self.dataModel = nil

    if (self.PosList) then
        for _, value in pairs(self.PosList) do
            value = nil
        end
        self.PosList = nil
    end

    if self.RoleCamera then
        self.RoleCamera.targetTexture = nil
    end
    if self.rawImage then
        self.rawImage.texture = nil
        ReleseRenderTexture(self.rawTexture)
    end

    if self.rewardBtn_red then
        self.rewardBtn_red:destroy()
        self.rewardBtn_red = nil
    end
    if self.func1_red then
        self.func1_red:destroy()
        self.func1_red = nil
    end

    if self.func2_red then
        self.func2_red:destroy()
        self.func2_red = nil
    end
end

function FactionBattleTemplePanel:Open()
    FactionBattleTemplePanel.super.Open(self)
end

function FactionBattleTemplePanel:LoadCallBack()
    --self:SetTileTextImage("faction_image", "faction_title_Temple")
    self.nodes = {
        "Func1",
        "Func2",
        "Func3",
        "roleContainer",
        "roleContainer/Camera",
        "roleContainer/Pos1",
        "roleContainer/Pos2",
        "roleContainer/Pos3",
        "Title1",
        "Title2",
        "Title3",
        "Name",
        "Times",
        "GetBtn",
        "deaconItems",
        "WelfareItems","NoRole",
    }
    self:GetChildren(self.nodes)
   -- logError(self.dataModel:HadWinningStreakAward(),self.dataModel:HadTerminatorAward(),self.dataModel:HadGuildPrize())
    self.rewardBtn_red = RedDot(self.GetBtn, nil, RedDot.RedDotType.Nor)
    self.rewardBtn_red:SetPosition(66, 24)

    self.func1_red = RedDot(self.Func1, nil, RedDot.RedDotType.Nor)
    self.func1_red:SetPosition(25, 30)


    self.func2_red = RedDot(self.Func2, nil, RedDot.RedDotType.Nor)
    self.func2_red:SetPosition(25, 30)

    self:InitUI()
    self:AddEvent()
    self:RequestData()



    ---测试代码--
    --self:OnWinnerData()
    --local role = FactionModel:GetInstance().members[1]
    --self:ShowRoles(role)
    -------------
end

function FactionBattleTemplePanel:InitUI()
    self.guildNameText = GetText(self.Name)
    self.winTimesText = GetText(self.Times)
    self.rawImage = GetRawImage(self.roleContainer)
    self.RoleCamera = GetCamera(self.Camera)
    self.PosList = {self.Pos1, self.Pos2, self.Pos3}

    local texture = CreateRenderTexture() 
    self.RoleCamera.targetTexture = texture
    self.rawImage.texture = texture
    self.rawTexture = texture

    titleView:SetParent(self)
    titleView:AddUI(self.Title1, self.Title2, self.Title3)

    for i = 1, 3 do
        titleView:SetData(i, nil)
    end

    self.guildNameText.text = ""
    self.winTimesText.text = ""
    SetVisible(self.GetBtn, false)

    self:ShowAward()
end

function FactionBattleTemplePanel:RequestData()
    FactionBattleController:GetInstance():RequestBattleWinner()
end

function FactionBattleTemplePanel:ShowAward()
    self.goodItems = {}

    local chiefReward = String2Table(Config.db_game["guildwar_chief_reward"].val)
    local dailyReward = String2Table(Config.db_game["guildwar_daily_reward"].val)

    self:CreateGoods(chiefReward[1], self.deaconItems)
    self:CreateGoods(dailyReward[1], self.WelfareItems)
end

function FactionBattleTemplePanel:CreateGoods(goods, parent)
    for i, v in pairs(goods) do
        local param = {}
        local operate_param = {}
        --param["cfg"] = Config.db_item[v[1]]
        --param["model"] = nil
        --param["can_click"] = true
        --param["num"] =  v[2]
        --param["operate_param"] = operate_param
        --param["size"] = { x = 60, y = 60 }
        local item = GoodsIconSettorTwo(parent)
        --item:SetIcon(param)
        item:SetData(v[1], v[2], true)
        --item:SetData(v[1], v[2])
        --item:AddClickTips()
        table.insert(self.goodItems, item)

        SetLocalScale(item.transform, 1, 1, 1)
        SetLocalPosition(item.transform, 0, (i*-80), 0)
    end
end

function FactionBattleTemplePanel:ShowRoles()
    self.UIRoles = {}
    self.RolesData = self.dataModel.WinnerInfo.roles or {}

    table.sort(
        self.RolesData,
        function(a, b)
            return a.gpost > b.gpost
        end
    )

    for i = 1, self.RoleCount do
        titleView:SetData(i, self.RolesData[i])
    end

    if (self.RolesData[1]) then
        --local res_id = self.RolesData[1].gender == 1 and 11001 or 12001
        self:LoadRole(self.RolesData[1], 1)
    end
end

function FactionBattleTemplePanel:LoadRole(roleData, index)
    self.UIRoles[index] =
        UIRoleModel(self.roleContainer, handler(self, self.LoadModelCallBack), roleData, {index = index})
end

function FactionBattleTemplePanel:LoadModelCallBack(index)
    local r = self.UIRoles[index].transform
    SetChildLayer(r, LayerManager.BuiltinLayer.UI)

    if (self.PosList[index]) then
        r:SetParent(self.PosList[index])
        SetLocalPosition(r, 0, 0, 0)
        SetLocalRotation(r, 0, 0, 0)
    else
        SetLocalPosition(r, -3000, 0, 0) --172.2
        SetLocalRotation(r, 10, 160, -1)
    end

    --self.RoleCamera.cullingMask = BitState.State[r.gameObject.layer + 1];
    index = index + 1
    if (index <= self.RoleCount and self.RolesData[index]) then
        --local res_id = self.RolesData[1].gender == 1 and 11001 or 12001
        --self:LoadRole(res_id, index)
        self:LoadRole(self.RolesData[index], index)
    end
end

function FactionBattleTemplePanel:AddEvent()
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(FactionBattlePrizeListPanel):Open()
    end
    AddClickEvent(self.Func1.gameObject, call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(FactionBattleTerminatorPanel):Open()
    end
    AddClickEvent(self.Func2.gameObject, call_back)

    local function call_back()
        --lua_panelMgr:GetPanelOrCreate(FactionBattlePrizeAssignPanel):Open()
        --lua_panelMgr:GetPanelOrCreate(FactionBattleSettlementPanel):Open()
        local tabPage = RoleInfoModel.GetInstance():GetMainRoleData().guild ~= "0" and 5 or 1
        lua_panelMgr:GetPanelOrCreate(FactionPanel):Open(tabPage)
        --self:Close()
    end
    AddClickEvent(self.Func3.gameObject, call_back)
    SetVisible(self.Func3,false)

    local function call_back()
        if (self.dataModel.WinnerInfo) then
            if (self.dataModel.WinnerInfo.fetch) then
                Notify.ShowText(ConfigLanguage.FactionBattle.ReceivedMemberRewardTip)
                return
            end

            if (self.dataModel.WinnerInfo.guild == 0) then
                Notify.ShowText(ConfigLanguage.FactionBattle.NoWinnerGuildTip)
            else
                local gId = RoleInfoModel.GetInstance():GetMainRoleData().guild

                if (gId == self.dataModel.WinnerInfo.guild) then
                    FactionBattleController:GetInstance():RequestMemberAward()
                else
                    Notify.ShowText(ConfigLanguage.FactionBattle.NotWinnerGuildMemberTip)
                end
            end
        end
    end
    AddClickEvent(self.GetBtn.gameObject, call_back)

    self.modelEvents[#self.modelEvents + 1] =
        self.dataModel:AddListener(
        FactionBattleEvent.FactionBattle_Model_BattleWinnerDataEvent,
        handler(self, self.OnWinnerData)
    )

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(FactionEvent.Faction_GuildWarRedPointEvent, handler(self, self.OnGuildWarRedPoint))
end

function FactionBattleTemplePanel:OnGuildWarRedPoint()

    self.rewardBtn_red:SetRedDotParam(self.dataModel:HadGuildPrize())
    self.func1_red:SetRedDotParam(self.dataModel:HadWinningStreakAward())
    self.func2_red:SetRedDotParam(self.dataModel:HadTerminatorAward())
end

function FactionBattleTemplePanel:OnWinnerData()
    if (self.dataModel.WinnerInfo and self.dataModel.WinnerInfo.guild ~= "0") then
        self.guildNameText.text = self.dataModel:GetGuildNameInField(self.dataModel.WinnerInfo.guild)
        self.winTimesText.text = string.format("Winning Streak: %s", self.dataModel.WinnerInfo.victory)
        SetVisible(self.GetBtn, true)
        SetVisible(self.NoRole,false)
    else
        self.guildNameText.text = ""
        self.winTimesText.text = ""
        SetVisible(self.GetBtn, false)
        SetVisible(self.NoRole,true)
    end

    self:ShowRoles()
    self:OnGuildWarRedPoint()

end

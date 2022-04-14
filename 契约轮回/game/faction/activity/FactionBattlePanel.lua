---
--- Created by  R2D2
--- DateTime: 2019/02/13 17:50
---
FactionBattlePanel = FactionBattlePanel or class("FactionBattlePanel", BaseItem)
local this = FactionBattlePanel

local fieldView = require("game.faction.activity.FactionBattlePanelFieldView")
local roleView = require("game.faction.activity.FactionBattlePaneRoleView")

function FactionBattlePanel:ctor(parent_node, parent_panel)
    self.abName = "faction"
    self.assetName = "FactionBattlePanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.isShow = false
    self.dataModel = FactionBattleModel.GetInstance()
    self.events = {}
    self.itemicon = {}
    FactionBattlePanel.super.Load(self)
end

function FactionBattlePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.dataModel = nil
    if self.itemicon then
        for i, v in pairs(self.itemicon) do
            v:destroy()
        end
        self.itemicon = {}
    end

    if (self.redPoint) then
        self.redPoint:destroy()
        self.redPoint = nil
    end
    if (self.redPoint2) then
        self.redPoint2:destroy()
        self.redPoint2 = nil
    end
    if (self.enterRedPoint) then
        self.enterRedPoint:destroy()
        self.enterRedPoint = nil
    end


    self.parentPanel = nil
    roleView:dctor()
end

function FactionBattlePanel:LoadCallBack()
    self.nodes = {
        "TxtGroup1/Text1_1", "TxtGroup1/Text1_2", "TxtGroup1/Text1_3", "TxtGroup1/Text1_4", "TxtGroup1/Win_L1", "TxtGroup1/Win_R1",
        "TxtGroup2/Text2_1", "TxtGroup2/Text2_2", "TxtGroup2/Text2_3", "TxtGroup2/Text2_4", "TxtGroup2/Win_L2", "TxtGroup2/Win_R2",
        "TxtGroup3/Text3_1", "TxtGroup3/Text3_2", "TxtGroup3/Text3_3", "TxtGroup3/Text3_4", "TxtGroup3/Win_L3", "TxtGroup3/Win_R3",
        "TxtGroup4/Text4_1", "TxtGroup4/Text4_2", "TxtGroup4/Text4_3", "TxtGroup4/Text4_4", "TxtGroup4/Win_L4", "TxtGroup4/Win_R4",
        "TextInfo", "PrizeBtn", "btn_ok",
        "GuildNameBg", "NameBg", "Title", "Title/JobTitle","Title/RoleName", "Name2","NoRole",
        "roleContainer","FuncBtn","rewardObj/rewardParent",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self:RequestData()
    self:RefreshOpenInfo()    
end

function FactionBattlePanel:RequestData()
    FactionBattleController:GetInstance():RequestFieldsInfo()
end

function FactionBattlePanel:InitUI()
    roleView:SetUI(self.roleContainer, self.Title, self.NameBg, self.JobTitle, self.RoleName, self.GuildNameBg, self.Name2,self.NoRole)

    fieldView:AddTextList(1, self.Text1_1, self.Text1_2, self.Text1_3, self.Text1_4)
    fieldView:AddTextList(2, self.Text2_1, self.Text2_2, self.Text2_3, self.Text2_4)
    fieldView:AddTextList(3, self.Text3_1, self.Text3_2, self.Text3_3, self.Text3_4)
    fieldView:AddTextList(4, self.Text4_1, self.Text4_2, self.Text4_3, self.Text4_4)

    fieldView:AddWinSign(1, self.Win_L1, self.Win_R1)
    fieldView:AddWinSign(2, self.Win_L2, self.Win_R2)
    fieldView:AddWinSign(3, self.Win_L3, self.Win_R3)
    fieldView:AddWinSign(4, self.Win_L4, self.Win_R4)

    fieldView:HideAllWinSign()

    self.OpenInfoText = GetText(self.TextInfo)

    self:CreateIcon()
    local function GoBattle ()

        if(self.dataModel.ActivityOpen ) then
            FactionBattleController:GetInstance():RequestGoBattle()
        else
            if(self.dataModel.isWaitNextActivity) then
                Notify.ShowText(ConfigLanguage.FactionBattle.WaitingNextActivity)
            else
                Notify.ShowText(ConfigLanguage.FactionBattle.NoOpeningActivity)
            end
        end
    end
    AddClickEvent(self.btn_ok.gameObject, GoBattle)

    local function OpenTemple()
        UnpackLinkConfig("270@1@4")
    end
    AddClickEvent(self.PrizeBtn.gameObject, OpenTemple)

    local function OpenTemple()
        lua_panelMgr:GetPanelOrCreate(FactionBattlePrizeListPanel):Open()
    end
    AddClickEvent(self.FuncBtn.gameObject, OpenTemple)

end

function FactionBattlePanel:AddEvent()
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(FactionBattleEvent.FactionBattle_FieldsDataEvent, handler(self, self.OnFieldsData))
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(FactionEvent.Faction_GuildWarRedPointEvent, handler(self, self.OnGuildWarRedPoint))
end

---获取战区信息回调
function FactionBattlePanel:OnFieldsData()
    self:RefreshFieldView()
    self:RefreshRedPoint() 

    roleView:RefreshRole()
end

function FactionBattlePanel:OnGuildWarRedPoint()
    self:RefreshRedPoint() 
end

---刷新开放信息
function FactionBattlePanel:RefreshOpenInfo()
    local w, m = self.dataModel:GetOpenInfo()

    if (w and m) then
        local s = {}
     --   table.insert(s, string.format("公会争霸(<color=#74ff30>本周%s</color>)", TimeManager:GetWeekDay(w)))
        table.insert(s, "Guild Clash (<color=#74ff30>New Server Day 3,Day7 and every Sunday.Starts at 21:00 and 21:25</color>)")--公会争霸(<color=#74ff30>开服第3天、第7天和每逢周日，21:00和21:25开始</color>)--公会争霸(<color=#74ff30>开服第3天、第7天和每逢周日</color>)
        for i, v in ipairs(m) do
            local tab = String2Table(v)
            table.insert(s, string.format("       Round %s<color=#74ff30>%02d:%02d</color>", i, tab[1], tab[2]))
        end
        self.OpenInfoText.text = table.concat(s)
    else
        self.OpenInfoText.text = "No opening info yet"
    end
end

---刷新公会对战信息
function FactionBattlePanel:RefreshFieldView()
    for i, _ in pairs(fieldView.FieldList) do
        fieldView:SetText(i, self.dataModel:GetFieldGuildName(i))
        fieldView:SetWinSign(i, self.dataModel:GetFieldWinSign(i))
    end
end

function FactionBattlePanel:CreateIcon()
    local cfg = Config.db_game["guildwar_show_reward"].val
    if cfg then
        local reward = String2Table(cfg)[1]
        for i = 1, #reward do
            --self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
            if self.itemicon[i] == nil then
                self.itemicon[i] = GoodsIconSettorTwo(self.rewardParent)
            end
            local param = {}

            param["model"] = self.model
            param["item_id"] = reward[i][1]
            param["num"] = reward[i][2]
            param["bind"] = reward[i][3]
            param["can_click"] = true
            --  param["size"] = {x = 72,y = 72}
            self.itemicon[i]:SetIcon(param)
        end
    end
end

function FactionBattlePanel:RefreshRedPoint()    
    if self.redPoint == nil then
        self.redPoint = RedDot(self.PrizeBtn, nil, RedDot.RedDotType.Nor)
        self.redPoint:SetPosition(28, 20)
    end
    if self.redPoint2 == nil then
        self.redPoint2 = RedDot(self.FuncBtn, nil, RedDot.RedDotType.Nor)
        self.redPoint2:SetPosition(28, 20)
    end

    if self.enterRedPoint == nil then
        self.enterRedPoint = RedDot(self.btn_ok, nil, RedDot.RedDotType.Nor)
        self.enterRedPoint:SetPosition(63, 23)
    end
    self.redPoint2:SetRedDotParam(self.dataModel:HadWinningStreakAward())
    self.enterRedPoint:SetRedDotParam(self.dataModel.ActivityOpen)
    local isShow = self.dataModel:HadWinningStreakAward() or self.dataModel:HadTerminatorAward() or self.dataModel:HadGuildPrize()
    self.redPoint:SetRedDotParam(isShow)
end

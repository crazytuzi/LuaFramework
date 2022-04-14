---
--- Created by R2D2.
--- DateTime: 2019/2/21 11:52
---
---主宰神殿->终结称霸
FactionBattleTerminatorPanel = FactionBattleTerminatorPanel or class("FactionBattleTerminatorPanel", WindowPanel)
local FactionBattleTerminatorPanel = FactionBattleTerminatorPanel

function FactionBattleTerminatorPanel:ctor()

    self.abName = "faction"
    self.assetName = "FactionBattleTerminatorPanel"
    self.layer = "UI"

    self.panel_type = 5
    self.dataModel = FactionBattleModel.GetInstance()
    self.show_sidebar = false

    self.goodItems = {}
    self.modelEvents = {}
end

function FactionBattleTerminatorPanel:dctor()
    for _, v in pairs(self.goodItems) do
        v:destroy()
    end
    self.goodItems = {}

    self.dataModel:RemoveTabListener(self.modelEvents)
end

function FactionBattleTerminatorPanel:Open()
    FactionBattleTerminatorPanel.super.Open(self)
end

function FactionBattleTerminatorPanel:LoadCallBack()
    self:SetTileTextImage("faction_image", "faction_title_Terminator")
    self.nodes = {
        "Caption3", "Caption7", "Item", "AssignedBtn", "OkBtn",
    }

    self:GetChildren(self.nodes)
    self:InitUI()
    self:AddEvent()

    self:RefreshView()
end

function FactionBattleTerminatorPanel:InitUI()
    self.prizeTipText = GetText(self.Caption3)
    self.buffText = GetText(self.Caption7)

    local function OnAllot()
        if (FactionModel:GetInstance():GetIsPresidentSelf()) then
            lua_panelMgr:GetPanelOrCreate(FactionBattlePrizeAssignPanel):Open(2)
        else
            Notify.ShowText(ConfigLanguage.FactionBattle.NotGuildPresidentTip)
        end
    end
    AddButtonEvent(self.OkBtn.gameObject, OnAllot)

    local function call_back()
        Notify.ShowText(ConfigLanguage.FactionBattle.WinningStreakPrizeAssigned)
    end
    AddButtonEvent(self.AssignedBtn.gameObject, call_back)
end

function FactionBattleTerminatorPanel:AddEvent()
    self.modelEvents[#self.modelEvents + 1] = self.dataModel:AddListener(FactionBattleEvent.FactionBattle_Model_AssignedTerminatorAwardEvent, handler(self, self.OnAssignedTerminatorAward))
end

function FactionBattleTerminatorPanel:OnAssignedTerminatorAward()
    self:RefreshView()
end

function FactionBattleTerminatorPanel:RefreshView()
    self:RefreshPrize()
    self:RefreshBtn()
end

function FactionBattleTerminatorPanel:RefreshPrize()
    local isWinGuild = self.dataModel:IsWinGuild()

    if isWinGuild then
        if (self.dataModel.WinnerInfo.b_allot) then    
            self:ShowPrize(self.dataModel.WinnerInfo.victory, true)
        else
            self:ShowPrize(self.dataModel.WinnerInfo.breakup, false)
        end
    else
        self:ShowPrize(self.dataModel.WinnerInfo.victory, true)
    end

end

---breakTimes: 要显示的次数
---isAssigned：奖励是否分配
function FactionBattleTerminatorPanel:ShowPrize(breakTimes, isAssigned)

    if (breakTimes < 2) then
        self.buffText.text = ConfigLanguage.FactionBattle.NoWinningStreakBuff
        self.prizeTipText.text = ConfigLanguage.FactionBattle.NoWinningStreakPrize

        for _, v in pairs(self.goodItems) do
            v:destroy()
        end
        self.goodItems = {}
        return
    end

    self.prizeTipText.text = isAssigned and ConfigLanguage.FactionBattle.WinningStreakPrizeTip or ConfigLanguage.FactionBattle.WinningStreakPrizeNotAssigned
    self.goodItems = {}

    local tab = self.dataModel:GetTerminatorReward(breakTimes)
    local lv = RoleInfoModel:GetInstance():GetRoleValue("level")
    local rewardTab = String2Table(tab.breakup)


    if (tab == nil) then
        self.buffText.text = ""
        return
    end

    ---根据等级拿取奖品
    local goods = nil
    for _, v in ipairs(rewardTab) do
        if (lv >= v[1] and lv <= v[2]) then
            goods = v[3]
            break
        end
    end

    for _, v in pairs(goods) do
        local item = AwardItem(self.Item)
        item:SetData(v[1], v[2])
        item:AddClickTips()
        table.insert(self.goodItems, item)

        local index = #self.goodItems - 1
        local col = index % 2
        local row = math.floor(index / 2)

        SetLocalScale(item.transform, 1, 1, 1)
        SetLocalPosition(item.transform, col * 80, row * -86, 0)
    end

    local buffTab = String2Table(tab.buff)
    local buffStr = {}

    for _, v in ipairs(buffTab) do
        local buff = Config.db_buff[v]
        if (buff) then
            table.insert(buffStr, buff.desc)
        end
    end

    self.buffText.text = table.concat(buffStr, " ")
end

function FactionBattleTerminatorPanel:RefreshBtn()

    local isWinGuild = self.dataModel:IsWinGuild()
    local info = self.dataModel.WinnerInfo

    if (isWinGuild) then
        if (info.breakup > 1) then
            if (info.b_allot) then
                SetVisible(self.OkBtn, false)
                SetVisible(self.AssignedBtn, false)
            else
                SetVisible(self.OkBtn, true)
                SetVisible(self.AssignedBtn, false)
            end
        else
            SetVisible(self.OkBtn, false)
            SetVisible(self.AssignedBtn, false)
        end
    else
        SetVisible(self.OkBtn, false)
        SetVisible(self.AssignedBtn, false)
    end
end

-- ---此成员是否为会长
-- function FactionBattleTerminatorPanel:IsChairman()
--     local sInfo = FactionModel:GetInstance():GetSelf()
--     return sInfo.post == 5
-- end
---是否获胜公会成员
-- function FactionBattleTerminatorPanel:IsWinGuild()
--     local guild = RoleInfoModel:GetInstance():GetRoleValue("guild")
--     local winGuild = self.dataModel.WinnerInfo.guild
--     return guild == winGuild
-- end
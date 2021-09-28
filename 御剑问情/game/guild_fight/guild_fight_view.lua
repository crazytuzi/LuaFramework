require("game/guild_fight/guild_fight_reward_view")
require("game/guild_fight/guild_fight_track_info_view")

GuildFightView = GuildFightView or BaseClass(BaseView)

function GuildFightView:__init()
    self.ui_config = {"uis/views/guildfight_prefab","GuildFightView"}
    self.view_layer = UiLayer.MainUI

    self.mainui_state = true
end

function GuildFightView:__delete()

end

function GuildFightView:LoadCallBack()
    self.show_or_hide_other_button = GlobalEventSystem:Bind(MainUIEventType.SHOW_OR_HIDE_OTHER_BUTTON,
        BindTool.Bind(self.SwitchButtonState, self))
    self.show_track_info = self:FindVariable("ShowTrackInfo")
    self.ji_fen = self:FindVariable("JiFen")
    self.reward = self:FindVariable("Reward")
    self.rank_panel = self:FindObj("RankPanel")
    self.flag_panel = self:FindObj("FlagPanel")
    self.toggle_group = self.flag_panel.toggle_group

    self.item_cell = {}
    for i = 1, 3 do
        self.item_cell[i] = ItemCell.New()
        self.item_cell[i]:SetInstanceParent(self:FindObj("ItemCell" .. i))
    end
    self:ListenEvent("OpenRank",
        BindTool.Bind(self.OpenRank, self))
    self:ListenEvent("CloseRank",
        BindTool.Bind(self.CloseRank, self))

    local info = GuildFightData.Instance:GetRoleInfo()
    self.last_score = info.history_get_person_credit or 0

    self:InitRankPanel()
    self:InitFlagPanel()
    self:Flush()
end

function GuildFightView:ReleaseCallBack()
    if self.show_or_hide_other_button then
        GlobalEventSystem:UnBind(self.show_or_hide_other_button)
        self.show_or_hide_other_button = nil
    end
    self.show_track_info = nil
    self.ji_fen = nil
    self.reward = nil
    self.rank_panel = nil
    self.flag_panel = nil
    self.toggle_group = nil
    self.rank_info = {}
    self.my_info = {}
    for k,v in pairs(self.item_cell) do
        v:DeleteMe()
    end
    self.item_cell = {}

    for k,v in pairs(self.flag_list) do
        v:DeleteMe()
    end
    self.flag_list = {}
end

function GuildFightView:CloseCallBack()

end

function GuildFightView:OnFlush(param_t)
    for k, v in pairs(param_t) do
        if k == "open_rank" then
            self:OpenRank()
        end
    end
    self.show_track_info:SetValue(self.mainui_state or false)
    self:FlushInfo()
    self:FlushRank()
end

function GuildFightView:SwitchButtonState(state)
    self.mainui_state = state
    self.show_track_info:SetValue(state)
end

function GuildFightView:InitRankPanel()
    self.rank_info = {}
    local name_table = self.rank_panel:GetComponent(typeof(UINameTable))
    for i = 1, 10 do
        local variable_table = name_table:Find("Info" .. i):GetComponent(typeof(UIVariableTable))
        self.rank_info[i] = {}
        self.rank_info[i].name = variable_table:FindVariable("Name")
        self.rank_info[i].grade = variable_table:FindVariable("Grade")
    end
    local info = name_table:Find("MyInfo"):GetComponent(typeof(UIVariableTable))
    self.my_info = {}
    self.my_info.rank = info:FindVariable("Rank")
    self.my_info.name = info:FindVariable("Name")
    self.my_info.grade = info:FindVariable("Grade")
end

function GuildFightView:OpenRank()
    self.rank_panel:SetActive(true)
    self:FlushRank()
end

function GuildFightView:CloseRank()
    self.rank_panel:SetActive(false)
end

function GuildFightView:FlushRank()
    self.my_info.rank:SetValue(0)
    local global_info = GuildFightData.Instance:GetGlobalInfo()
    self.my_info.rank:SetValue(global_info.guild_rank)
    self.my_info.name:SetValue(GuildDataConst.GUILDVO.guild_name)
    self.my_info.grade:SetValue(global_info.guild_score)

    for i = 1, global_info.rank_count do
        local info = global_info.rank_list[i]
        if info then
            self.rank_info[i].name:SetValue(info.guild_name)
            self.rank_info[i].grade:SetValue(info.score)
        end
    end

    for i = global_info.rank_count + 1, 10 do
        self.rank_info[i].name:SetValue(Language.Common.ZanWu)
        self.rank_info[i].grade:SetValue(0)
    end
    for k,v in ipairs(self.flag_list) do
        local data = global_info.hold_point_guild_list[k]
        v:SetData(data)
    end
end

function GuildFightView:FlushInfo()
    local role_info = GuildFightData.Instance:GetRoleInfo()
    if role_info.history_get_person_credit - self.last_score > 0 then
        TipsFloatingManager.Instance:ShowFloatingTips(string.format(Language.GuildBattle.HuoDeJiFen, role_info.history_get_person_credit - self.last_score))
        self.last_score = role_info.history_get_person_credit
    end
    self.ji_fen:SetValue(role_info.history_get_person_credit)
    local config, next_config = GuildFightData.Instance:GetRewardInfoByScore(role_info.history_get_person_credit)
    if not next_config then
        self.reward:SetValue(Language.Guild.QuanBuLingQi)
        next_config = config
    else
        -- self.reward:SetValue(string.format(Language.Guild.DaDaoJiFen, ToColorStr(next_config.reward_credit_min, TEXT_COLOR.GREEN_3)))
        self.reward:SetValue(string.format(Language.Guild.DaDaoJiFen, next_config.reward_credit_min))
    end
    if next_config then
        for i = 1, 3 do
            local item_info = next_config.reward_item[i - 1]
            if item_info then
                self.item_cell[i]:SetParentActive(true)
                self.item_cell[i]:SetData(item_info)
            else
                self.item_cell[i]:SetParentActive(false)
            end
        end
    end
end

function GuildFightView:OnClickFlag(index)
    local x, y = GuildFightData.Instance:GetFlagPositionByIndex(index)
    MoveCache.end_type = MoveEndType.Auto
    GuajiCtrl.Instance:MoveToPos(Scene.Instance:GetSceneId(), x, y, 3, 3)
end

function GuildFightView:InitFlagPanel()
    self.flag_list = {}
    PrefabPool.Instance:Load(AssetID("uis/views/guildfight_prefab", "GuildFightFlagCell"), function(prefab)
        if nil == prefab then
            return
        end
        for i = 1, 5 do
            local obj = GameObject.Instantiate(prefab)
            obj.transform:SetParent(self.flag_panel.transform, false)
            local info_cell = GuildFightFlagCell.New(obj)
            info_cell:SetToggleGroup(self.toggle_group)
            info_cell:SetFlagColor(i == 1 and 0 or 1)
            info_cell:SetIndex(i)
            info_cell:SetClickCallBack(BindTool.Bind(self.OnClickFlag, self, i))
            self.flag_list[i] = info_cell
        end
        PrefabPool.Instance:Free(prefab)
        self:FlushRank()
    end)
end

----------------------------------------------GuildFightFlagCell--------------------------------------------

GuildFightFlagCell = GuildFightFlagCell or BaseClass(BaseCell)

function GuildFightFlagCell:__init()
    self.guild_name = self:FindVariable("GuildName")
    self.value = self:FindVariable("Value")
    self.flag_color = self:FindVariable("FlagColor")
    self.is_my_guild = self:FindVariable("IsMyGuild")
    self.flag_name = self:FindVariable("flag_name")
    self:ListenEvent("OnClick",
        BindTool.Bind(self.OnClick, self))
end

function GuildFightFlagCell:__delete()

end

function GuildFightFlagCell:OnFlush()
    self.is_my_guild:SetValue(false)
    local guild_name = ""

    if self.data and self.data.guild_id then
        local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id or 0

        if self.data.guild_id > 0 then
            guild_name = ToColorStr(self.data.guild_name, RICH_TEXT_COLOR.YELLOW) or ""
            self.is_my_guild:SetValue(self.data.guild_id == guild_id)
        end
     
        self.value:SetValue(self.data.blood / self.data.max_blood)
    end

    if guild_name == "" then
        guild_name = Language.GuildBattle.ZanWuZhanLing
    end

    local flag_name = "" 
    flag_name = GuildFightData.Instance:GetIndexFlagName(self.index) or ""

    self.flag_name:SetValue(flag_name)
    self.guild_name:SetValue(guild_name)
end

function GuildFightFlagCell:SetFlagColor(index)
    self.flag_color:SetValue(index)
end

function GuildFightFlagCell:SetToggleGroup(toggle_group)
    self.root_node.toggle.group = toggle_group
end
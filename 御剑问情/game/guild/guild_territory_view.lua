GuildTerritoryView = GuildTerritoryView or BaseClass(BaseRender)

function GuildTerritoryView:__init(instance)
    if instance == nil then
        return
    end

    self.progress = self:FindObj("Progress")
    self.anim_list = {}
    self.shake_list = {}
    for i = 1, 5 do
        self.anim_list[i] = self:FindObj("Box" .. i).animator
        self.shake_list[i] = false
        self["gray" .. i] = self:FindVariable("Gray" .. i)
    end

    self.cur_territory = self:FindVariable("CurTerritory")
    self.guild_name = self:FindVariable("GuildName")
    self.time = self:FindVariable("Time")
    self.no_territory = self:FindVariable("NoTerritory")
    self.gong_xian = {}
    self.box_image = {}
    self.red_point = {}
    self.show_icon = {}
    for i = 1, 5 do
        self.gong_xian[i] = self:FindVariable("GongXian" .. i)
        self.box_image[i] = self:FindVariable("BoxImage" .. i)
        self.red_point[i] = self:FindVariable("RedPoint" .. i)
        self.show_icon[i] = self:FindVariable("ShowIcon" .. i)
        self:ListenEvent("OnClickBox" .. i,
            function() self:OnClickBox(i) end)
    end

    self.info_list = {}
    for i = 1, 10 do
        self.info_list[i] = GuildTerritoryInfo.New(self:FindObj("Icon" .. i))
        self.info_list[i]:SetCallBack(BindTool.Bind(self.OnClickTerritory, self, i))
    end

    self:ListenEvent("OnClickHelp",
        BindTool.Bind(self.OnClickHelp, self))
    self:ListenEvent("OnClickDonate",
        BindTool.Bind(self.OnClickDonate, self))

    self.gong_xian_config = GuildData.Instance:GetGuildTerritoryGongXian()
    if self.gong_xian_config then
        for i = 1, 4 do
            self.gong_xian[i]:SetValue(self.gong_xian_config[i])
        end
    end
    self.progress.slider.value = 0
    self.cur_shake_index = 1
    self.has_territory = false
    self.rank = 0
    self.no_territory:SetValue(not self.has_territory)
    	self:StartCountDown()
end

function GuildTerritoryView:__delete()
    self:RemoveCountDown()
    for k,v in pairs(self.info_list) do
        v:DeleteMe()
    end
    self.info_list = {}
end

function GuildTerritoryView:Flush()
    local rank = 0
    local has_territory = false
    rank, has_territory = GuildData.Instance:GetTerritoryRank()
    if rank == nil then
        rank = 0
        has_territory = false
    end
    self.rank = rank
    self.has_territory = has_territory
    local index = self.rank + 1
    if index > 6 then
        index = 6
    end
    rank = 0
    if self.has_territory then
        rank = self.rank
    end
    local territory_config = GuildData.Instance:GetTerritoryConfig(rank)
    if territory_config then
        self.cur_territory:SetValue(territory_config.territory_name)
    end

    local opponent_rank = self.rank % 2 == 0 and self.rank - 1 or self.rank + 1
    local guild_id = ClashTerritoryData.Instance:GetGuildIdByRank(opponent_rank)
    if guild_id and guild_id > 0 then
        local info = GuildData.Instance:GetGuildInfoById(guild_id)
        if info then
            self.guild_name:SetValue(info.guild_name)
        end
    else
        self.guild_name:SetValue(Language.Guild.NoOpponentGuild)
    end

    self.time:SetValue(ActivityData.Instance:GetNextOpenWeekTime(ACTIVITY_TYPE.CLASH_TERRITORY) or "")

    local role_guild_info = GuildData.Instance:GetGuildRoleGuildInfo()
    if role_guild_info then
        local daily_guild_gongxian = role_guild_info.daily_guild_gongxian or 0
        for i = 1, 4 do
            self.red_point[i]:SetValue(false)
            self.shake_list[i] = false
            if role_guild_info.territorywar_reward_flag[i] then
                -- self.box_image[i]:SetAsset(ResPath.GetGuildBoxIcon(6, true))
                self.show_icon[i]:SetValue(true)
            else
                -- self.box_image[i]:SetAsset(ResPath.GetGuildBoxIcon(5, false))
                self.show_icon[i]:SetValue(false)
                if daily_guild_gongxian >= self.gong_xian_config[i] then
                    self.red_point[i]:SetValue(true)
                    self.shake_list[i] = true
                end
            end
            if i > 1 then
                if not self.has_territory then
                    self["gray" .. i]:SetValue(true)
                    self.red_point[i]:SetValue(false)
                    self.shake_list[i] = false
                else
                    self["gray" .. i]:SetValue(false)
                end
            end
        end
        self.shake_huizhang_box = false
        self.red_point[5]:SetValue(false)
        self.shake_list[5] = false
        if role_guild_info.territorywar_reward_flag[5] then
            self.box_image[5]:SetAsset(ResPath.GetGuildBoxIcon(4, true))
        else
            self.box_image[5]:SetAsset(ResPath.GetGuildBoxIcon(4, false))
            local post = GuildData.Instance:GetGuildPost()
            if post == GuildDataConst.GUILD_POST.TUANGZHANG and self.has_territory then
                self.red_point[5]:SetValue(true)
                self.shake_list[5] = true
                self.shake_huizhang_box = true
            end
        end
        self.no_territory:SetValue(not self.has_territory)
        self:FlushProgress(daily_guild_gongxian)

        for i = 1, 10 do
            local guild_id, has_territory = ClashTerritoryData.Instance:GetGuildIdByRank(i)
            if guild_id and has_territory then
                self.info_list[i]:SetData({guild_id = guild_id})
            else
                self.info_list[i]:SetData({guild_id = 0})
            end
        end
    end
end

function GuildTerritoryView:RemoveCountDown()
    if self.count_down then
        CountDown.Instance:RemoveCountDown(self.count_down)
        self.count_down = nil
    end
end


function GuildTerritoryView:StartCountDown()
    if self.count_down then return end
    self.count_down = CountDown.Instance:AddCountDown(99999999, 1, BindTool.Bind(self.CountDown, self))
end

function GuildTerritoryView:CountDown(elapse_time, total_time)
    self:ShakeBox()
    self:ShakeHuiZhangBox()
end

function GuildTerritoryView:ShakeBox()
    local flag = true
    for i = 1, 4 do
        if self.shake_list[i] then
            flag = false
            break
        end
    end
    if flag then
        return
    end
    if self.cur_shake_index > 4 then
        self.cur_shake_index = 1
    end
    if self.shake_list[self.cur_shake_index] then
        -- self.anim_list[self.cur_shake_index]:SetTrigger("Shake")
        self.cur_shake_index = self.cur_shake_index + 1
    else
        self.cur_shake_index = self.cur_shake_index + 1
        self:ShakeBox()
    end
end

function GuildTerritoryView:FlushProgress(gong_xian)
    gong_xian = gong_xian or 0
    self.gong_xian[5]:SetValue(gong_xian)
    local value = 0
    for i = 1, 4 do
        if gong_xian < self.gong_xian_config[i] then
            local last_gong_xian = self.gong_xian_config[i - 1] and self.gong_xian_config[i - 1] or 0
            gong_xian = gong_xian - last_gong_xian
            value = value + gong_xian / (self.gong_xian_config[i] - last_gong_xian) * 0.25
            break
        end
        value = value + 0.25
    end
    self.progress.slider:DOValue(value, 0.5, false)
end

function GuildTerritoryView:OnClickBox(index)
    local rank = self.rank
    if rank == 0 then
        rank = 10
    end
    local territory_config = GuildData.Instance:GetTerritoryConfig(rank)
    local guild_president_extra_reward = {}
    if territory_config then
        guild_president_extra_reward[1] = territory_config.guild_president_extra_reward
    end

    local guild_box_reward = {}
    local reward_cfg = GuildData.Instance:GetGuildTerritoryReward(rank, index)
    if reward_cfg then
        guild_box_reward[1] = reward_cfg
    end

    -- 会长宝箱
    if index == 5 then
        local post = GuildData.Instance:GetGuildPost()
        if post ~= GuildDataConst.GUILD_POST.TUANGZHANG then
            if #guild_president_extra_reward > 0 then
                TipsCtrl.Instance:ShowRewardView(guild_president_extra_reward, nil, Language.Guild.BecomeHuiZhang)
            end
            -- SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoPower)
            return
        end
    end

    local role_guild_info = GuildData.Instance:GetGuildRoleGuildInfo()
    local gong_xian = 0
    if role_guild_info then
        gong_xian = role_guild_info.daily_guild_gongxian
        if role_guild_info.territorywar_reward_flag[index] then
            SysMsgCtrl.Instance:ErrorRemind(Language.Guild.BoxIsOpen)
            return
        end
    end

    if index > 1 then
        if not self.has_territory then
            if index == 5 then
                if #guild_president_extra_reward > 0 then
                    TipsCtrl.Instance:ShowRewardView(guild_president_extra_reward, nil, Language.Guild.BecomeHuiZhang)
                end
            else
                if nil ~= guild_box_reward then
                    TipsCtrl.Instance:ShowRewardView(guild_box_reward, nil, Language.Guild.NoTerritory)
                end
                -- SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoTerritory)
            end
            return
        end
    end

    if index == 5 then
        GuildCtrl.Instance:SendGuildTerritoryWelfOperate(GUID_TERRITORY_WELF_OPERATE_TYPE.GTW_FETCH_EXTRA_REWARD, 0)
    else
        if gong_xian < self.gong_xian_config[index] and nil ~= guild_box_reward then
            TipsCtrl.Instance:ShowRewardView(guild_box_reward, nil, Language.Guild.JiFenBuGou)
            -- SysMsgCtrl.Instance:ErrorRemind(Language.Guild.JiFenBuGou)
            return
        end
        GuildCtrl.Instance:SendGuildTerritoryWelfOperate(GUID_TERRITORY_WELF_OPERATE_TYPE.GTW_FETCH_REWARD, index - 1)
    end
    if not role_guild_info.territorywar_reward_flag[index] then
        AudioService.Instance:PlayRewardAudio()
    end
end

function GuildTerritoryView:OnClickHelp()
    TipsCtrl.Instance:ShowHelpTipView(62)
end

function GuildTerritoryView:OnClickDonate()
    GuildCtrl.Instance.view:HandleOpenDonate()
end

function GuildTerritoryView:OnClickTerritory(index, guild_id)
    guild_id = guild_id or 0
    local territory_config = GuildData.Instance:GetTerritoryConfig(index) or {}
    GuildCtrl.Instance:SetTerritoryInfo({territory_config = territory_config, guild_id = guild_id})
end

function GuildTerritoryView:ShakeHuiZhangBox()
	local anim = self:FindObj("Box5").animator
	if self.shake_huizhang_box and self.shake_list[5] then
    	anim:SetBool("Shake", true)
    else
    	anim:SetBool("Shake", false)
    end
end

-------------------------------------------------------GuildTerritoryInfo-----------------------------------------------------

GuildTerritoryInfo = GuildTerritoryInfo or BaseClass(BaseCell)

function GuildTerritoryInfo:__init()
    self.name = self:FindVariable("Name")
    self:ListenEvent("OnClick",
        BindTool.Bind(self.OnClick, self))
end

function GuildTerritoryInfo:__delete()

end

function GuildTerritoryInfo:OnFlush()
    self.name:SetValue(Language.Guild.NoGuild)
    if self.data then
        local guild_id = self.data.guild_id
        if guild_id > 0 then
            local info = GuildData.Instance:GetGuildInfoById(guild_id)
            if info then
                self.name:SetValue(info.guild_name)
            end
        end
    end
end

function GuildTerritoryInfo:SetCallBack(call_back)
    self.call_back = call_back
end

function GuildTerritoryInfo:OnClick()
    if self.call_back then
        self.call_back(self.data.guild_id)
    end
end
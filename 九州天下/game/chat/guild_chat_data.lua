GuildChatData = GuildChatData or BaseClass()

function GuildChatData:__init()
	if GuildChatData.Instance ~= nil then
		print_error("[MagicCardData] Attemp to create a singleton twice !")
	end
	GuildChatData.Instance = self

	self.chat_num = 0
	self.is_lock = false   --是否锁定滚动条,锁定不会自动跳到底部
	self.is_hide_pop_rect = false -- 是否屏蔽气泡框

	-- 配置表数据
	self.guild_chats = ConfigManager.Instance:GetAutoConfig("guild_active_auto").guild_chats
    RemindManager.Instance:Register(RemindName.GuildChat, BindTool.Bind(self.GetGuildChatRemind, self))
    RemindManager.Instance:Register(RemindName.PlayPawn, BindTool.Bind(self.GetPlayPawnRemind, self))
end

function GuildChatData:__delete()
    RemindManager.Instance:UnRegister(RemindName.GuildChat)
    RemindManager.Instance:UnRegister(RemindName.PlayPawn)
	GuildChatData.Instance = nil
end

function GuildChatData:GetGuildChatActivityData()
	local activity_list = TableCopy(self.guild_chats)
	table.sort(activity_list, function(a, b)
		local a_id = a.activity_id
        local b_id = b.activity_id
        local a_is_open = 0
        if a_id ~= "" then
        	a_is_open = ActivityData.Instance:GetActivityIsOpen(a_id) and 1 or 0
        else
            a_is_open = 1
        end
        local b_is_open = 0
        if b_id ~= "" then
        	b_is_open = ActivityData.Instance:GetActivityIsOpen(b_id) and 1 or 0
        else
            b_is_open = 1
        end
        if a_is_open == b_is_open then
            local a_is_over = 0
            if a_id == "" then
            	local have_num = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) or 0
            	a_is_over = have_num >= a.guild_actnum and 1 or 0
            else
            	a_is_over = ActivityData.Instance:GetActivityIsOver(a_id) and 1 or 0
            end
            local b_is_over = 0
            if b_id == "" then
            	local have_num = DayCounterData.Instance:GetDayCount(DAY_COUNT.DAYCOUNT_ID_GUILD_TASK_COMPLETE_COUNT) or 0
            	b_is_over = have_num >= b.guild_actnum and 1 or 0
            else
            	b_is_over = ActivityData.Instance:GetActivityIsOver(b_id) and 1 or 0
            end
            if a_is_over == b_is_over then
                local a_is_open_today = 1
                local b_is_open_today = 1
                if a_id ~= "" then
                    a_is_open_today = ActivityData.Instance:GetActivityIsInToday(a_id) and 1 or 0
                end
                if b_id ~= "" then
                    b_is_open_today = ActivityData.Instance:GetActivityIsInToday(b_id) and 1 or 0
                end
                if a_is_open_today == b_is_open_today then
                    local a_next_open_time = 99999999
                    if a_id ~= "" then
                        a_next_open_time = ActivityData.Instance:GetNextOpenTime(a_id)
                    end
                    local b_next_open_time = 99999999
                    if b_id ~= "" then
                        b_next_open_time = ActivityData.Instance:GetNextOpenTime(b_id)
                    end
                    return a_next_open_time < b_next_open_time
                else
                    return a_is_open_today > b_is_open_today
                end
            else
                return a_is_over < b_is_over
            end
        else
        	return a_is_open > b_is_open
        end
	 end)
	return activity_list
end

function GuildChatData:GetIsHidePopRect()
	return self.is_hide_pop_rect
end

function GuildChatData:SetIsHidePopRect(is_hide)
	self.is_hide_pop_rect = is_hide
end

function GuildChatData:GetChatNum()
	return self.chat_num
end

function GuildChatData:AddChatNum(num)
	self.chat_num = self.chat_num + num
end

function GuildChatData:SetChatNum(num)
	self.chat_num = num
end

function GuildChatData:SetIsLock(is_lock)
	self.is_lock = is_lock
end

function GuildChatData:GetIsLock()
	return self.is_lock
end

function GuildChatData:GetGuildChatRemind()
    local num = 0
    local can_play = PlayPawnData.Instance:CanPlayPwan()
    local sign_flag = GuildData.Instance:GetSigninRedPoint()
    if (can_play and ClickOnceRemindList[RemindName.PlayPawn] == 1)or sign_flag > 0 then
        num = 1
    end
    return num
end

function GuildChatData:GetPlayPawnRemind()
    local num = 0
    local can_play = PlayPawnData.Instance:CanPlayPwan()
    if can_play and ClickOnceRemindList[RemindName.PlayPawn] == 1 then
        num = 1
    end
    return num
end

function GuildChatData:CheckRedPoint()
    RemindManager.Instance:Fire(RemindName.GuildChat)
end
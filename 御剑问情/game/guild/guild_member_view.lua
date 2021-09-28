GuildMemberView = GuildMemberView or BaseClass(BaseView)

function GuildMemberView:__init()
    self.ui_config = {"uis/views/guildview_prefab","MembersContent"}

end
function GuildMemberView:LoadCallBack()
    self.toggle_group = self.root_node:GetComponent("ToggleGroup")
    self.row = 7  -- 每一页有多少行，暂定为7行

    self.info_table = {}

    self.variable_page = self:FindVariable("Page")
    self.panel = self:FindObj("Panel")
    self.is_editor = self:FindVariable("IsEditor")
    self.show_editor_btn = self:FindVariable("ShowEditorBtn")
    self.show_kick_btn = self:FindVariable("ShowKickBtn")
    self.is_editor:SetValue(false)
    self.is_load = false
    self.is_editor_state = false
    self.select_index = 0
    self.current_page = 1
    self.last_flush_page = 0
    self.select_member_data = {}
    self.select_member_list = {}
    self:InitFransfer()
    PrefabPool.Instance:Load(AssetID("uis/views/guildview_prefab", "MemberInfo"), function(prefab)
        if nil == prefab then
            return
        end
        for i = 1, self.row do
            local obj = GameObject.Instantiate(prefab)
            local obj_transform = obj.transform
            obj_transform:SetParent(self.panel.transform, false)
            local info_cell = GuildMemberInfoCell.New(obj)
            info_cell:SetToggleGroup(self.toggle_group)
            info_cell:SetEditor(self.is_editor_state)
            info_cell:SetClickCallBack(BindTool.Bind(self.OnSelectMember, self))
            self.info_table[i] = info_cell
        end

        PrefabPool.Instance:Free(prefab)
        self.is_load = true
        self:Flush()
    end)

    self:ListenEvent("OnPageUp",
        BindTool.Bind(self.OnPageUp, self))
    self:ListenEvent("OnPageDown",
        BindTool.Bind(self.OnPageDown, self))
    self:ListenEvent("OnClickKickOut",
        BindTool.Bind(self.OnClickBundleKickOut, self))
    self:ListenEvent("OnClickEditor",
        BindTool.Bind(self.OnClickEditor, self))
    self:ListenEvent("OnClickExitEditor",
        BindTool.Bind(self.OnClickExitEditor, self))
    self:ListenEvent("Close",
        BindTool.Bind(self.CloseSelf, self))
end

function GuildMemberView:__delete()

end

function GuildMemberView:ReleaseCallBack()
    self.panel = nil
    self.transfer_window = nil
    self.toggle_group = nil
    self.show_kick_btn = nil
    self.post = nil
    self.name = nil
    self.count = nil
    self.show_editor_btn = nil
    self.is_editor = nil
    self.variable_page = nil
    self.select_member_list = nil
    --print_error(self.panel)
    for k,v in pairs(self.info_table) do
        v:DeleteMe()
    end
    -- for k,v in pairs(self.select_member_data) do
    --     v:DeleteMe()
    -- end
end


-- 批量操作模式
function GuildMemberView:OnClickEditor()
    self.is_editor:SetValue(true)
    self.is_editor_state = true
    self.select_member_list = {}
    for k,v in pairs(self.info_table) do
        v:SetEditor(true)
    end
    self:Flush()
end

function GuildMemberView:OnClickExitEditor()
    self.is_editor:SetValue(false)
    self.is_editor_state = false
    for k,v in pairs(self.info_table) do
        v:SetEditor(false)
    end
    self:ResetToggle()
    self:Flush()
end

function GuildMemberView:Flush()
    if not self:IsLoaded() then return end
    local post = GuildData.Instance:GetGuildPost()
    if GuildDataConst.GUILD_POST_WEIGHT[post] >= GuildDataConst.GUILD_POST_WEIGHT[GuildDataConst.GUILD_POST.ZHANG_LAO] then
        self.show_editor_btn:SetValue(true)
    else
        self.show_editor_btn:SetValue(false)
        self.is_editor_state = false
    end
    if #self.select_member_list > 0 then
        self.show_kick_btn:SetValue(true)
    else
        self.show_kick_btn:SetValue(false)
    end
    self.is_editor:SetValue(self.is_editor_state)
    self.info_list = GuildDataConst.GUILD_MEMBER_LIST.list or {}
    if self.is_editor_state then
        local temp_list = {}
        for k,v in pairs(self.info_list) do
            if GuildDataConst.GUILD_POST_WEIGHT[post] > GuildDataConst.GUILD_POST_WEIGHT[v.post] then
                table.insert(temp_list, v)
            end
        end
        self.info_list = temp_list
    end
    self:FlushPageCount()
    -- 刷新当前页
    self.current_page = self.page_count >= self.current_page and self.current_page or self.page_count
    self:FlushPage(self.current_page)
end

function GuildMemberView:CloseSelf()
   self:Close()
end
-- 刷新页面数目
function GuildMemberView:FlushPageCount()
    self.info_count = #self.info_list
    self.page_count = self.info_count / self.row
    self.page_count = math.ceil(self.page_count)
    if(self.page_count == 0) then
        self.page_count = 1
    end
end

-- 更新页面
function GuildMemberView:FlushPage(page)
    if(page > self.page_count or page < 1) or not self.is_load then
        return
    end
    if not self.is_editor_state or self.last_flush_page ~= page then
        self:ResetToggle()
    end
    self.last_flush_page = page
    self.current_page = page
    self.variable_page:SetValue(self.current_page .. "/" .. self.page_count)

    if(page == self.page_count) then  -- 如果是最后一页
        for i = 1, self.row do
            if(i <= page * self.row - self.info_count) then
                self.info_table[self.row + 1 - i]:SetActive(false)
            else
                self.info_table[self.row + 1 - i]:SetActive(true)
            end
        end
    else
        for i = 1, self.row do
            self.info_table[i]:SetActive(true)
        end
    end

    for i = (page - 1) * self.row + 1, page * self.row do
        if(i > self.info_count) then
            break
        end
        self:FlushRow(i)
    end
end

-- 更新每一行的信息
function GuildMemberView:FlushRow(index)
    if(index <= 0) or not self.is_load then
        return
    end

    local current_row = index % self.row
    if(current_row == 0) then
        current_row = self.row
    end
    -- 更新公会其它信息
    local info = self.info_list[index]
    if info then
        info.has_chose = self:IsHasChose(info.uid)
        if self.info_table[current_row] then
            self.info_table[current_row]:SetData(info)
        end
    end
end

-- 是否已经选中
function GuildMemberView:IsHasChose(uid)
    for k,v in pairs(self.select_member_list) do
        if v.uid == uid then
            return true
        end
    end
    return false
end

-- 重置Toggle
function GuildMemberView:ResetToggle()
    for k,v in pairs(self.info_table) do
        -- 这里为了在翻页的时候记录上一页的数据
        v:ClearClickListen()
        v.toggle.isOn = false
        v:AddClickListen()
    end
end

-- 向上翻页
function GuildMemberView:OnPageUp()
    self.current_page = self.current_page - 1
    self.current_page = self.current_page < 1 and 1 or self.current_page
    self:FlushPage(self.current_page)
end

-- 向下翻页
function GuildMemberView:OnPageDown()
    self.current_page = self.current_page + 1
    self.current_page = self.current_page > self.page_count and self.page_count or self.current_page
    self:FlushPage(self.current_page)
end

-- 选择成员
function GuildMemberView:OnSelectMember(data, state)
    if data then
        self.select_member_data = data
        if self.is_editor_state then
            self:AddMember(data, state)
        else
            self:ShowDetails(data, state)
        end
    end
end

-- 添加选中成员
function GuildMemberView:AddMember(data, state)
    if state then
        if not self:IsHasChose(data.uid) then
            table.insert(self.select_member_list, data)
        end
    else
        for k,v in pairs(self.select_member_list) do
            if v.uid == data.uid then
                table.remove(self.select_member_list, k)
                break
            end
        end
    end
    if #self.select_member_list > 0 then
        self.show_kick_btn:SetValue(true)
    else
        self.show_kick_btn:SetValue(false)
    end
end

-- 弹出信息
function GuildMemberView:ShowDetails(data, state)
    if state then
        if data.uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
            local info = GuildData.Instance:GetGuildMemberInfo()
            if info then
                local detail_type = ScoietyData.DetailType.Default
                if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
                    detail_type = ScoietyData.DetailType.GuildTuanZhang
                elseif info.post == GuildDataConst.GUILD_POST.FU_TUANGZHANG or info.post == GuildDataConst.GUILD_POST.ZHANG_LAO then
                    detail_type = ScoietyData.DetailType.Guild
                end
                ScoietyCtrl.Instance:ShowOperateList(detail_type, self.select_member_data.role_name,
                 nil,function() self:ResetToggle() end)
            end
        else
            self:ResetToggle()
        end
    end
end

-- 关闭所有弹窗
function GuildMemberView:CloseAllWindow()
    self.is_editor_state = false
    self.select_member_list = {}
    self:ResetToggle()
    for k,v in pairs(self.info_table) do
        v:SetEditor(false)
    end
end

-- 批量踢出公会
function GuildMemberView:OnClickBundleKickOut()
    local count = #self.select_member_list or 0
    if count > 0 then
        local describe = ""
        if count > 3 then
            describe = string.format(Language.Guild.KickoutMemberBundleTip4, self.select_member_list[1].role_name, self.select_member_list[2].role_name, self.select_member_list[3].role_name, count)
        elseif count > 2 then
            describe = string.format(Language.Guild.KickoutMemberBundleTip3, self.select_member_list[1].role_name, self.select_member_list[2].role_name, self.select_member_list[3].role_name)
        elseif count > 1 then
            describe = string.format(Language.Guild.KickoutMemberBundleTip2, self.select_member_list[1].role_name, self.select_member_list[2].role_name)
        else
            describe = string.format(Language.Guild.KickoutMemberBundleTip1, self.select_member_list[1].role_name)
        end
        local yes_func = function()
            local member_list = {}
            for k,v in pairs(self.select_member_list) do
                table.insert(member_list, v.uid)
            end
            GuildCtrl.Instance:SendKickoutGuildReq(GuildDataConst.GUILDVO.guild_id, count, member_list)
            self.select_member_list = {}
            self:ResetToggle()
        end
        TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
    else
        SysMsgCtrl.Instance:ErrorRemind(Language.Guild.NoSelectRole)
    end
    -- self:FlushPage(self.current_page)
end

function GuildMemberView:OnClickKickout(uid, name)
    local _uid = uid or self.select_member_data.uid
    local _name = name or self.select_member_data.role_name
    local describe = string.format(Language.Guild.KickoutMemberBundleTip1, _name)
    local yes_func = BindTool.Bind(self.OnKickoutMemberHandler, self, _uid)
    TipsCtrl.Instance:ShowCommonAutoView("", describe, yes_func)
end

-- 踢出仙盟二次确认
function GuildMemberView:OnKickoutMemberHandler(uid)
    if nil ~= uid then
        GuildCtrl.Instance:SendKickoutGuildReq(GuildDataConst.GUILDVO.guild_id, 1, {uid})
    end
end

function GuildMemberView:OnClickChangePost()
    local post = GuildData.Instance:GetGuildPost()
    if post == GuildDataConst.GUILD_POST.TUANGZHANG then
        self.count:SetValue(5)
    elseif post == GuildDataConst.GUILD_POST.FU_TUANGZHANG then
        self.count:SetValue(4)
    elseif post == GuildDataConst.GUILD_POST.ZHANG_LAO then
        self.count:SetValue(3)
    else
        self.count:SetValue(0)
    end
    self.name:SetValue(self.select_member_data.role_name)
    self.select_post = 1
    self.post:SetValue(Language.Guild.PuTong)
    self.transfer_window:SetActive(true)
end

function GuildMemberView:OnClickTransfer(uid, name)
    local _uid = uid or self.select_member_data.uid
    local _name = name or self.select_member_data.role_name
    local describe = string.format(Language.Guild.ConfirmTransferMengZhuTip, _name)
    TipsCtrl.Instance:ShowCommonAutoView("", describe,
        function()
            GuildCtrl.Instance:SendGuildAppointReq(GuildDataConst.GUILDVO.guild_id, _uid, GuildDataConst.GUILD_POST.TUANGZHANG)
        end)
end

function GuildMemberView:InitFransfer()
    self.count = self:FindVariable("Count")
    self.name = self:FindVariable("Name")
    self.post = self:FindVariable("Post")
    self.transfer_window = self:FindObj("Transfer")
    for i = 1, 5 do
        self:ListenEvent("ClickTransfer" .. i,
            function() self:ClickTransfer(i) end)
    end
    self:ListenEvent("ClickOK",
        BindTool.Bind(self.ClickOK, self))
end

function GuildMemberView:ClickTransfer(index)
    if index == 1 then
        self.select_post = GUILD_POST.FU_TUANGZHANG
        self.post:SetValue(Language.Guild.FuMengZhu)
    elseif index == 2 then
        self.select_post = GUILD_POST.ZHANG_LAO
        self.post:SetValue(Language.Guild.ZhangLao)
    elseif index == 3 then
        self.select_post = GUILD_POST.HUFA
        self.post:SetValue(Language.Guild.HuFa)
    elseif index == 4 then
        self.select_post = GUILD_POST.JINGYING
        self.post:SetValue(Language.Guild.JingYing)
    elseif index == 5 then
        self.select_post = GUILD_POST.CHENG_YUAN
        self.post:SetValue(Language.Guild.PuTong)
    end
end

function GuildMemberView:ClickOK()
    local uid = self.select_member_data.uid
    GuildCtrl.Instance:SendGuildAppointReq(GuildDataConst.GUILDVO.guild_id, uid, self.select_post)
end

-----------------------------------------------MemberInfoCell------------------------------------------------------

GuildMemberInfoCell = GuildMemberInfoCell or BaseClass(BaseCell)

function GuildMemberInfoCell:__init(instance)
    if instance == nil then
        return
    end

    self.name = self:FindVariable("Name")
    self.post = self:FindVariable("Job")
    self.level = self:FindVariable("Level")
    self.fight_power = self:FindVariable("FightPower")
    self.contribution = self:FindVariable("Contribution")
    self.last_online = self:FindVariable("LastOnline")
    self.gray = self:FindVariable("Gray")
    self.is_editor = self:FindVariable("IsEditor")
    self.toggle = self.root_node:GetComponent("Toggle")
    self.sex = self:FindVariable("Sex")
    -- self:AddClickListen()
end

function GuildMemberInfoCell:SetToggleGroup(toggle_group)
    self.toggle_group = toggle_group
    self.toggle.group = toggle_group
end

function GuildMemberInfoCell:SetEditor(is_editor)
    self.is_editor:SetValue(is_editor)
    if is_editor then
        self.toggle.group = nil
    else
        self.toggle.group = self.toggle_group
    end
end

function GuildMemberInfoCell:OnClick(state)
    if self.click_callback then
        self.click_callback(self.data, state)
    end
end

function GuildMemberInfoCell:AddClickListen()
    self:ListenEvent("OnClick",
        BindTool.Bind(self.OnClick, self))
end

function GuildMemberInfoCell:ClearClickListen()
    self:ClearEvent("OnClick")
end

function GuildMemberInfoCell:OnFlush()
    if self.data then
        self.sex:SetValue(self.data.sex)
        self.name:SetValue(self.data.role_name)
        self.post:SetValue(GuildData.Instance:GetGuildPostNameByPostId(self.data.post))
        local lv = PlayerData.GetLevelString(self.data.level)
        self.level:SetValue(lv)
        self.fight_power:SetValue(self.data.capability)
        self.contribution:SetValue(self.data.gongxian)
        local is_online = self.data.is_online
        if(is_online ~= 0) then
            self.last_online:SetValue(Language.Common.OnLine)
            self.gray:SetValue(true)
        else
            self.gray:SetValue(false)
            local now_time = TimeCtrl.Instance:GetServerTime()  -- 服务器的当前时间
            local last_login_time = self.data.last_login_time
            local t_time = TimeUtil.Timediff(now_time,last_login_time)
            local last_time = self:LastLoginTime(t_time)
            self.last_online:SetValue("<color='#fe3030'>".. last_time .. "</color>")
        end
        if self.data.has_chose then
            self.toggle.isOn = true
        else
            self.toggle.isOn = false
        end
        if GameVoManager.Instance:GetMainRoleVo().role_id == self.data.uid then
            self.toggle.interactable = false
        else
            self.toggle.interactable = true
        end
    end
end

-- 通过相差的时间，返回合适的时间
function GuildMemberInfoCell:LastLoginTime(t_time)
    local last_time = ""
    if t_time.year ~= 0 then
        last_time = string.format(Language.Common.BeforeXXYear, t_time.year)
        return last_time
    end
    if t_time.month ~= 0 then
        string.format(Language.Common.BeforeXXMonth, t_time.month)
        return last_time
    end
    if t_time.day ~= 0 then
        last_time = string.format(Language.Common.BeforeXXDay, t_time.day)
        return last_time
    end
    if t_time.hour ~= 0 then
        last_time = string.format(Language.Common.BeforeXXHour, t_time.hour)
        return last_time
    end
    if t_time.min ~= 0 then
        last_time = string.format(Language.Common.BeforeXXMinute, t_time.min)
        return last_time
    end
    last_time = string.format(Language.Common.BeforeXXSecond, t_time.sec)
    return last_time
end
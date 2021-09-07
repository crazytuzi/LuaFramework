GuildMemberView = GuildMemberView or BaseClass(BaseRender)

function GuildMemberView:__init(instance)
    if instance == nil then
        return
    end
    self.row = 8  -- 每一页有多少行，暂定为8行

    self.info_table = {}
    self.sex_table = {}   --sex图标
    self.variables = {}   --variables组件
    for i = 1, self.row do
        self.info_table[i] = self:FindObj("Info" .. i)
        self.info_table[i]:GetComponent(typeof(UIEventTable)):ListenEvent("OnClick",function() self:OnSelectMember(i) end)
        self.sex_table[i] = {}
        self.sex_table[i].male = U3DObject(self.info_table[i]:GetComponent(typeof(UINameTable)):Find("SexMale"))
        self.sex_table[i].fmale = U3DObject(self.info_table[i]:GetComponent(typeof(UINameTable)):Find("SexFmale"))
        self.variables[i] = {}
        self.variables[i].name = self.info_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Name")
        self.variables[i].post = self.info_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Job")
        self.variables[i].level = self.info_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Level")
        self.variables[i].fight_power = self.info_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("FightPower")
        self.variables[i].contribution = self.info_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Contribution")
        self.variables[i].last_online = self.info_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("LastOnline")
        self.variables[i].gray = self.info_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("Gray")
        self.info_table[i]:GetComponent(typeof(UIEventTable)):ListenEvent("OnClickOp",function() self:OnCickOp(i) end)
        self.variables[i].show_op = self.info_table[i]:GetComponent(typeof(UIVariableTable)):FindVariable("ShowOp")
    end

    self.variable_page = self:FindVariable("Page")
    self.show_oplist = self:FindVariable("ShowOpList")
    self.show_my_info = self:FindVariable("ShowMyInfo")

    self.is_load = false
    self.is_editor_state = false
    self.select_index = 0
    self.current_page = 1
    self.last_flush_page = 0
    self.select_member_data = {}
    self.select_member_list = {}
    self:InitFransfer()

    self:ListenEvent("OnPageUp", BindTool.Bind(self.OnPageUp, self))
    self:ListenEvent("OnPageDown", BindTool.Bind(self.OnPageDown, self))
    self:ListenEvent("OnClickBtnKickOut", BindTool.Bind(self.OnClickBtnKickOut, self))
    self:ListenEvent("OnClickBtnChangePost", BindTool.Bind(self.OnClickBtnChangePost, self))
    self:ListenEvent("OnClickBtnTransfer", BindTool.Bind(self.OnClickBtnTransfer, self))
    self:ListenEvent("CloseOp", BindTool.Bind(self.CloseOp, self))
end

function GuildMemberView:__delete()

end

function GuildMemberView:LoadCallBack()
    self:MemberInfoList()
    self.my_name = self:FindVariable("MyNane")
    self.my_post = self:FindVariable("MyJob")
    self.my_level = self:FindVariable("MyLvevl")
    self.my_fight_power = self:FindVariable("MyFightPower")
    self.my_contribution = self:FindVariable("MyContribution")
    self.show_man_head = self:FindVariable("ShowmanHead")
    self.show_nv_head = self:FindVariable("ShowNvHead")
end

function GuildMemberView:MemberInfoList()
    self.member_list = {}
    self.member_scroller = self:FindObj("Scroller")
    local delegate = self.member_scroller.list_simple_delegate
    -- 生成数量
    delegate.NumberOfCellsDel = function()
        return #GuildData.Instance:GetMemberNumList()
    end
    -- 格子刷新
    delegate.CellRefreshDel = function(cell, data_index)
        data_index = data_index + 1
        local target_cell = self.member_list[cell]
        if nil == target_cell then
            self.member_list[cell] =  MeberListCell.New(cell.gameObject)
            target_cell = self.member_list[cell]
            target_cell.mother_view = self
        end
        local data = GuildData.Instance:GetMemberNumList()
        local cell_data = data[data_index]
        cell_data.data_index = data_index
        target_cell:SetShowHighLight(GuildData.Instance:GetCurIndex() or false)
        target_cell:SetIndex(data_index)
        target_cell:SetData(cell_data)
    end
end

function GuildMemberView:Flush()
    self.info_list = GuildDataConst.GUILD_MEMBER_LIST or {}
    self:FlushPageCount()
    -- 刷新当前页
    self.current_page = self.page_count >= self.current_page and self.current_page or self.page_count
    self:FlushPage(self.current_page)
    if self.member_scroller.scroller.isActiveAndEnabled then
        self.member_scroller.scroller:ReloadData(0)
    end
end

function GuildMemberView:FlushMemberScroller()
    if self.member_scroller.scroller.isActiveAndEnabled then
        self.member_scroller.scroller:RefreshAndReloadActiveCellViews(true)
    end
end

function GuildMemberView:ShowMyInfo()
    local member_my_info = GuildData.Instance:GuildMemberMyInfo()
    self.my_name:SetValue(member_my_info.role_name)
    self.my_post:SetValue(GuildData.Instance:GetGuildPostNameByPostId(member_my_info.post))
    self.my_level:SetValue(member_my_info.level)
    self.my_fight_power:SetValue(member_my_info.capability)
    self.my_contribution:SetValue(member_my_info.gongxian)
    self.show_man_head:SetValue((member_my_info.prof == GameEnum.ROLE_PROF_1) or (member_my_info.prof == GameEnum.ROLE_PROF_3))
    self.show_nv_head:SetValue((member_my_info.prof == GameEnum.ROLE_PROF_2) or (member_my_info.prof == GameEnum.ROLE_PROF_4))
end

-- 刷新页面数目
function GuildMemberView:FlushPageCount()
    self.info_count = self.info_list.count
    self.page_count = self.info_count / self.row
    self.page_count = math.ceil(self.page_count)
    if(self.page_count == 0) then
        self.page_count = 1
    end
end

-- 更新页面
function GuildMemberView:FlushPage(page)
    if page > self.page_count or page < 1 then
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
    if index <= 0 then
        return
    end

    local current_row = index % self.row
    if(current_row == 0) then
        current_row = self.row
    end
    -- 更新公会其它信息
    local info = self.info_list.list[index]
    if(info.prof == GameEnum.ROLE_PROF_1) or (info.prof == GameEnum.ROLE_PROF_3) then                      -- 更改性别图标
        self.sex_table[current_row].male:SetActive(true)
        self.sex_table[current_row].fmale:SetActive(false)
    else
        self.sex_table[current_row].male:SetActive(false)
        self.sex_table[current_row].fmale:SetActive(true)
    end

    self.variables[current_row].name:SetValue(info.role_name)
    self.variables[current_row].post:SetValue(GuildData.Instance:GetGuildPostNameByPostId(info.post))
    local lv, zhuan = PlayerData.GetLevelAndRebirth(info.level)
    self.variables[current_row].level:SetValue(string.format(Language.Common.ZhuanShneng, lv, zhuan))
    self.variables[current_row].fight_power:SetValue(info.capability)
    self.variables[current_row].contribution:SetValue(info.gongxian)
    local is_online = info.is_online
    if(is_online ~= 0) then
        self.variables[current_row].last_online:SetValue(Language.Common.OnLine)
        self.variables[current_row].gray:SetValue(true)
    else
        self.variables[current_row].gray:SetValue(false)
        local now_time = TimeCtrl.Instance:GetServerTime()  -- 服务器的当前时间
        local last_login_time = info.last_login_time
        local t_time = TimeUtil.Timediff(now_time,last_login_time)
        local last_time = self:LastLoginTime(t_time)
        self.variables[current_row].last_online:SetValue(last_time)
    end
    if GameVoManager.Instance:GetMainRoleVo().guild_post == GuildDataConst.GUILD_POST.TUANGZHANG then
        -- self.variables[current_row].show_op:SetValue(info.post ~= GuildDataConst.GUILD_POST.TUANGZHANG)
        -- 屏蔽家族长的设置按钮
        self.variables[current_row].show_op:SetValue(false)
    else
        self.variables[current_row].show_op:SetValue(false)
    end
end

-- 通过相差的时间，返回合适的时间
function GuildMemberView:LastLoginTime(t_time)
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
-- function GuildMemberView:OnSelectMember(data, state)
--     if data then
--         self.select_member_data = data
--         if self.is_editor_state then
--             self:AddMember(data, state)
--         else
--             self:ShowDetails(data, state)
--         end
--     end
-- end

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
    local role_info = ScoietyData.Instance:GetSelectRoleInfo()
    self:OnClickKickout(role_info.role_id,role_info.role_name)
    self.show_oplist:SetValue(false)
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

function GuildMemberView:ShowOpList()
    self.show_oplist:SetValue(true)
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
    self:AddClickListen()
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
        local lv, zhuan = PlayerData.GetLevelAndRebirth(self.data.level)
        self.level:SetValue(string.format(Language.Common.ZhuanShneng, lv, zhuan))
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
            self.last_online:SetValue(last_time)
        end
        if self.data.has_chose then
            self.toggle.isOn = true
        else
            self.toggle.isOn = false
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

-- 重置Toggle
function GuildMemberView:ResetToggle()
    for i = 1, self.row do
        self.info_table[i].toggle.isOn = false
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
function GuildMemberView:OnSelectMember(index)
    if self.select_index ~= index then
        self.select_index = index
    else
        self.info_table[index].toggle.isOn = true
    end
    if(index ~= 0) then
        self.select_member_index = (self.current_page - 1) * self.row + index
        if GuildDataConst.GUILD_MEMBER_LIST.list[self.select_member_index].uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
            local info = GuildData.Instance:GetGuildMemberInfo()
            if info then
                local detail_type = ScoietyData.DetailType.Default
                if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
                    detail_type = ScoietyData.DetailType.GuildTuanZhang
                elseif info.post == GuildDataConst.GUILD_POST.FU_TUANGZHANG or info.post == GuildDataConst.GUILD_POST.ZHANG_LAO then
                    detail_type = ScoietyData.DetailType.Guild
                end
                ScoietyCtrl.Instance:ShowOperateList(detail_type, GuildDataConst.GUILD_MEMBER_LIST.list[self.select_member_index].role_name,
                 nil,function() self:ResetToggle() end)
            end
        end
    end
end

function GuildMemberView:OnCickOp(index)
    self.show_oplist:SetValue(true)
    if index ~= 0 then
        self.select_member_index = (self.current_page - 1) * self.row + index
    end
    PlayerCtrl.Instance:CSFindRoleByName(GuildDataConst.GUILD_MEMBER_LIST.list[self.select_member_index].role_name or "")
end

function GuildMemberView:CloseOp()
    self.show_oplist:SetValue(false)
end

-- 关闭所有弹窗
function GuildMemberView:CloseAllWindow()
end

-- 进入驻地
function GuildMemberView:EnterStation()
    local guild_id = GuildData.Instance.guild_id
    if guild_id and guild_id > 0 then
        GuildCtrl.Instance:SendGuildBackToStationReq(guild_id)
    end
end

function GuildMemberView:OnClickKickout(uid, name)
    local _uid = uid or GuildDataConst.GUILD_MEMBER_LIST.list[self.select_member_index].uid
    local _name = name or GuildDataConst.GUILD_MEMBER_LIST.list[self.select_member_index].role_name
    local describe = string.format(Language.Guild.KickoutMemberTip, _name)
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
    -- self.name:SetValue(GuildDataConst.GUILD_MEMBER_LIST.list[self.select_member_index].role_name)
    self.name:SetValue(GuildDataConst.GUILD_MEMBER_LIST.list[MEBER_LIST_CELL_INDEX].role_name)
    self.select_post = 1
    self.post:SetValue(Language.Guild.PuTong)
    self.transfer_window:SetActive(true)
end

function GuildMemberView:OnClickTransfer(uid, name)
    local _uid = uid or GuildDataConst.GUILD_MEMBER_LIST.list[MEBER_LIST_CELL_INDEX].uid
    local _name = name or GuildDataConst.GUILD_MEMBER_LIST.list[MEBER_LIST_CELL_INDEX].role_name
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
        self.select_post = 3
        self.post:SetValue(Language.Guild.FuMengZhu)
    elseif index == 2 then
        self.select_post = 2
        self.post:SetValue(Language.Guild.ZhangLao)
    elseif index == 3 then
        self.select_post = 6
        self.post:SetValue(Language.Guild.HuFa)
    elseif index == 4 then
        self.select_post = 5
        self.post:SetValue(Language.Guild.JingYing)
    elseif index == 5 then
        self.select_post = 1
        self.post:SetValue(Language.Guild.PuTong)
    end
end

function GuildMemberView:ClickOK()
    -- local uid = GuildDataConst.GUILD_MEMBER_LIST.list[self.select_member_index].uid
    local uid = GuildDataConst.GUILD_MEMBER_LIST.list[MEBER_LIST_CELL_INDEX].uid
    GuildCtrl.Instance:SendGuildAppointReq(GuildDataConst.GUILDVO.guild_id, uid, self.select_post)
end

function GuildMemberView:OnClickBtnKickOut()
    local role_info = ScoietyData.Instance:GetSelectRoleInfo()
    self:OnClickKickout(role_info.role_id,role_info.role_name)
    self.show_oplist:SetValue(false)
end

function GuildMemberView:OnClickBtnChangePost()
   self:OnClickChangePost()
   self.show_oplist:SetValue(false)
end

function GuildMemberView:OnClickBtnTransfer()
   local role_info = ScoietyData.Instance:GetSelectRoleInfo()
   self:OnClickTransfer(role_info.role_id,role_info.role_name)
   self.show_oplist:SetValue(false)
end



------------------------------帮派成员List----------------------------

MeberListCell = MeberListCell or BaseClass(BaseCell)

function MeberListCell:__init()
    self.name = self:FindVariable("Name")
    self.job = self:FindVariable("Job")
    self.level = self:FindVariable("Level")
    self.contri_bution = self:FindVariable("Contribution")
    self.laston_line = self:FindVariable("LastOnline")
    self.gray = self:FindVariable("Gray")
    self.fight_power = self:FindVariable("FightPower")
    self.show_hight = self:FindVariable("ShowHight")
    self.show_op = self:FindVariable("ShowOp")
    self.male = self:FindObj("SexMale")
    self.fmale = self:FindObj("SexFmale")
    self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
    self:ListenEvent("OnClickOp", BindTool.Bind(self.OnClickOp, self))
end

function MeberListCell:__delete()
 
end

function MeberListCell:SetIndex(index)
    self.cell_index = index
end

function MeberListCell:OnClick()
    GuildData.Instance:SetCurIndex(self.cell_index)
    if self.data.uid ~= GameVoManager.Instance:GetMainRoleVo().role_id then
        local info = GuildData.Instance:GetGuildMemberInfo()
        if info then
            local detail_type = ScoietyData.DetailType.Default
            if info.post == GuildDataConst.GUILD_POST.TUANGZHANG then
                detail_type = ScoietyData.DetailType.GuildTuanZhang
            elseif info.post == GuildDataConst.GUILD_POST.FU_TUANGZHANG or info.post == GuildDataConst.GUILD_POST.ZHANG_LAO then
                detail_type = ScoietyData.DetailType.Guild
            end
            ScoietyCtrl.Instance:ShowOperateList(detail_type, self.data.role_name)
        end
    end
    GuildCtrl.Instance:FlushMemberScroller()
end

function MeberListCell:SetShowHighLight(index)
    self.show_hight:SetValue(self.cell_index == index)
end

-- 通过相差的时间，返回合适的时间
function MeberListCell:LastLoginTime(t_time)
    local last_time = ""
    if t_time.year ~= 0 then
        last_time = string.format(Language.Common.XXYear, t_time.year)
        return last_time
    end
    if t_time.month ~= 0 then
        string.format(Language.Common.XXMonth, t_time.month)
        return last_time
    end
    if t_time.day ~= 0 then
        last_time = string.format(Language.Common.XXDay, t_time.day)
        return last_time
    end
    if t_time.hour ~= 0 then
        last_time = string.format(Language.Common.XXHour, t_time.hour)
        return last_time
    end
    if t_time.min ~= 0 then
        last_time = string.format(Language.Common.XXMinute, t_time.min)
        return last_time
    end
    last_time = string.format(Language.Common.XXSecond, t_time.sec)
    return last_time
end

function MeberListCell:OnFlush()
    if nil == self.data then return end
    self.name:SetValue(self.data.role_name)
    self.job:SetValue(GuildData.Instance:GetGuildPostNameByPostId(self.data.post))
    self.level:SetValue(self.data.level)
    self.contri_bution:SetValue(self.data.total_gongxian)

    local is_online = self.data.is_online ~= 0
    if is_online then
        self.laston_line:SetValue(Language.Common.OnLine)
    else
        local now_time = TimeCtrl.Instance:GetServerTime()  -- 服务器的当前时间
        local last_login_time = self.data.last_login_time
        local t_time = TimeUtil.Timediff(now_time,last_login_time)
        local last_time = self:LastLoginTime(t_time)
        self.laston_line:SetValue(Language.Common.OutLine .. last_time)
    end

    if (self.data.prof == GameEnum.ROLE_PROF_1) or (self.data.prof == GameEnum.ROLE_PROF_3) then                      -- 更改性别图标
        self.male:SetActive(true)
        self.fmale:SetActive(false)
    else
        self.male:SetActive(false)
        self.fmale:SetActive(true)
    end

    self.gray:SetValue(self.data.is_online ~= 0)
    self.fight_power:SetValue(self.data.capability)
    -- 屏蔽家族张设置按钮
    -- self.show_op:SetValue(GuildDataConst.GUILD_POST.TUANGZHANG == GameVoManager.Instance:GetMainRoleVo().guild_post and self.data.post ~= GameVoManager.Instance:GetMainRoleVo().guild_post)
    self.show_op:SetValue(false)
    self:SetShowHighLight(GuildData.Instance:GetCurIndex() or false)
end

function MeberListCell:OnClickOp()
    MEBER_LIST_CELL_INDEX = self.cell_index
    GuildCtrl.Instance:ShowOpList()
    PlayerCtrl.Instance:CSFindRoleByName(self.data.role_name or "")
end
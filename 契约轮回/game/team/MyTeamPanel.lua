MyTeamPanel = MyTeamPanel or class("MyTeamPanel", WindowPanel)
local MyTeamPanel = MyTeamPanel

function MyTeamPanel:ctor()
    self.abName = "team"
    self.assetName = "MyTeamPanel"
    self.layer = "UI"

    -- self.change_scene_close = true 				--切换场景关闭
    -- self.default_table_index = 1					--默认选择的标签
    -- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置

    self.panel_type = 2                                --窗体样式  1 1280*720  2 850*545
    --self.show_sidebar = false		--是否显示侧边栏
    --[[if self.show_sidebar then		-- 侧边栏配置
        self.sidebar_data = {
            {text = ConfigLanguage.Custom.Message,id = 1},
        }
    end--]]
    self.table_index = nil
    self.events = {}
    self.team_item_list = {}
    self.team_p_img = {}
    self.model = TeamModel:GetInstance()
    --MyTeamPanel.super.Load(self)

end

function MyTeamPanel:dctor()
    --self.team_item_list = nil
    if self.event_id then
        self.model:RemoveListener(self.event_id)
        self.event_id = nil
    end

    for i, v in pairs(self.events) do
        self.model:RemoveListener(v)
    end

    for i, v in pairs(self.team_item_list) do
        v:destroy()
    end
    self.team_item_list = {}
    self.team_p_img = nil
    if self.remind_schedule then
        GlobalSchedule:Stop(self.remind_schedule)
        self.remind_schedule = nil
    end
end

function MyTeamPanel:Open(new_type_id)
    MyTeamPanel.super.Open(self)
    if new_type_id and new_type_id ~= self.model.team_info.type_id then
        TeamController:GetInstance():RequestChangeTarget(new_type_id)
    end
end

function MyTeamPanel:LoadCallBack()
    self.nodes = {
        "team_target/target",
        "team_target/level",
        "btn_change_target",
        "btn_call",
        "btn_apply_list",
        "bottom/btn_team_list",
        "bottom/btn_quit",
        "bottom/btn_match",
        "bottom/btn_enter",
        "member_scroll/Viewport/Content",
        "btn_remind_captain",
        "btn_remind_captain/remindText",
        "CloseBtn",
        "bottom/team_exp/team/team_p_1",
        "bottom/team_exp/team/team_p_2",
        "bottom/team_exp/team/team_p_3",
        "bottom/team_exp/Text",
        "bottom/btn_enter/TextEnter",
        "btn_call/callText",
        "addfaker","tog",
    }
    self:GetChildren(self.nodes)
    self.team_p_img[1] = self.team_p_1:GetComponent('Image')
    self.team_p_img[2] = self.team_p_2:GetComponent('Image')
    self.team_p_img[3] = self.team_p_3:GetComponent('Image')
    self.exp_text = GetText(self.Text)
    self.remindText = GetText(self.remindText)
    self.callText_txt = GetText(self.callText)
    self.TextEnter = GetText(self.TextEnter)
    self.btn_remind_captain = GetButton(self.btn_remind_captain)
    self.addfaker = GetToggle(self.addfaker)
	self.tog = GetToggle(self.tog)
    SetVisible(self.addfaker, false)
    self:AddEvent()

    if self.need_load_end then
        self:UpdateView()
    end
    --self:SetPanelSize(1065, 615)
    self:SetTileTextImage("team_image", "team_f")
    --self:SetTitleImgPos(177, 292)
end

function MyTeamPanel:AddEvent()
    local function call_back(target, x, y)
        --self:UpdateView()
        lua_panelMgr:GetPanelOrCreate(CreateTeamPanel):Open(true, nil, nil)
    end
    AddClickEvent(self.btn_change_target.gameObject, call_back)

    local function call_back(target, x, y)
        TeamController:GetInstance():RequestQuit()
    end
    AddClickEvent(self.btn_quit.gameObject, call_back)

    local function call_back(target, x, y)
        if table.nums(self.model:GetApplyList()) <= 0 then
            Notify.ShowText(ConfigLanguage.Team.NotPlayerApply)
        else
            lua_panelMgr:GetPanelOrCreate(ApplyListPanel):Open()
        end

    end
    AddClickEvent(self.btn_apply_list.gameObject, call_back)

    local function call_back(target, x, y)
        lua_panelMgr:GetPanelOrCreate(TeamListPanel):Open()
    end
    AddClickEvent(self.btn_team_list.gameObject, call_back)

    local function call_back(target, x, y)
        if self.model.remind_cd > 0 then
            return Notify.ShowText("In cooldown, please try again later")
        end
        local team_info = self.model:GetTeamInfo()
        local type_id = team_info.type_id
        local teamtarget = Config.db_team_target_sub[type_id]
        if teamtarget and teamtarget.dunge_id > 0 then
            TeamController:GetInstance():RequestRemindCaptain()
            Notify.ShowText("Leader noticed")
            self.model.remind_cd = 5
            self.btn_remind_captain.interactable = false
            self.remind_schedule = GlobalSchedule:Start(handler(self,self.UpdateCD), 1, 5)
            self:UpdateCD()
        else
            Notify.ShowText("The team target is not a dungeon scene")
        end
    end
    AddClickEvent(self.btn_remind_captain.gameObject, call_back)

    local function call_back(target, x, y)
        local team_info = self.model:GetTeamInfo()
        if team_info.type_id == 1 then
            Notify.ShowText("You are already in this map")
            return
        elseif team_info.type_id == 2 then
            DailyModel:GetInstance():GoCurHookPos()
        else
            local dunge_id = Config.db_team_target_sub[team_info.type_id].dunge_id
            TeamController:GetInstance():DungeEnterAsk(dunge_id, 1)
        end
        self:Close()
    end
    AddClickEvent(self.btn_enter.gameObject, call_back)

    local function call_back(target, x, y)
        local team_info = self.model:GetTeamInfo()
        if team_info then
            local team_target = Config.db_team_target_sub[team_info.type_id]
            local dunge_id = team_target.dunge_id
            local dunge = Config.db_dunge[dunge_id]
            if not dunge then
                return Notify.ShowText("Unable to recruit when wild automode is in progress")
            end
            local dunge_name = dunge.name
            local dunge_level = dunge.level
            local captain = self.model:GetCaptain(team_info)
            local level = captain.level
            local num = #team_info.members
            if num >= 3 then
                return Notify.ShowText("The team is full")
            end
            local dun_lv = GetLevelShow(dunge_level)
            local lv = GetLevelShow(level)
            local content = string.format(ConfigLanguage.Team.EnlistContent, dun_lv, dunge_name, lv, team_info.id, num)
            ChatController:GetInstance():RequestSendChat(enum.CHAT_CHANNEL.CHAT_CHANNEL_TEAM, 0, content)
            TeamController:GetInstance():AddFaker()
            self.model.auto_call = not self.model.auto_call
            if self.model.auto_call then
                self.callText_txt.text = "Cancel"
            else
                self.callText_txt.text = "Auto Recruitment"
            end
            self.model:Brocast(TeamEvent.AutoCall)
        end
    end
    AddClickEvent(self.btn_call.gameObject, call_back)

    local function call_back(target, bool)
        local addfaker = (bool and 1 or 0)
        self.model:SetAddFaker(addfaker)
    end
    AddValueChange(self.addfaker.gameObject, call_back)

    local function call_back()
        self:UpdateView()
    end
    self.event_id = self.model:AddListener(TeamEvent.ChangeSet, call_back)

    local function call_back()
        self.model:Brocast(TeamEvent.CloseTeamView)
    end
    self.event_id2 = self.model:AddListener(TeamEvent.QuitTeam, call_back)

    local function call_back()
        self.model:Brocast(TeamEvent.CloseTeamView)
    end
    AddClickEvent(self.CloseBtn.gameObject, call_back)

    self.events[#self.events + 1] = self.model:AddListener(TeamEvent.UpdateTeamInfo, handler(self, self.UpdateView))
	local function call_back()
		local team_info = self.model:GetTeamInfo()
		self.tog.isOn = (team_info.is_auto_accept == 1)
	end
	self.events[#self.events + 1] = self.model:AddListener(TeamEvent.UpdateApply, call_back)
	
	local function call_back(target, bool)
		local team_info = TeamModel.GetInstance():GetTeamInfo()
		if (team_info.is_auto_accept == 1 and bool) or (team_info.is_auto_accept == 0 and not bool) then
			return
		end
		is_auto_accept = bool and 1 or 0
		TeamController.GetInstance():RequestChangeTarget(nil, nil, nil, is_auto_accept)
	end
	AddValueChange(self.tog.gameObject, call_back)
end

function MyTeamPanel:UpdateCD()
    if self.model.remind_cd <= 0 then
        GlobalSchedule:Stop(self.remind_schedule)
        self.remind_schedule = nil
        self.remindText.text = "Notice team leader"
        self.btn_remind_captain.interactable = true
    else
        self.remindText.text = string.format("%s sec", self.model.remind_cd)
    end
    self.model.remind_cd = self.model.remind_cd - 1
end

function MyTeamPanel:OpenCallBack()
    self:UpdateView()
end

function MyTeamPanel:DealUpdatTeam()
    local needLoadMember = {}
    local deleMemberItem = {}
    local team_info = self.model:GetTeamInfo()
    local memberCount = 0
    for i, v in pairs(self.team_item_list) do
        if v.data ~= nil then
            memberCount = memberCount + 1
        end
    end
    for i, v in pairs(team_info.members or {}) do
        local has = false
        for ii, vv in pairs(self.team_item_list) do
            if vv.data ~= nil and v.role_id == vv.data.role_id then
                has = true
            end
        end
        if not has then
            table.insert(needLoadMember, v)
        end
    end

    for i, v in pairs(self.team_item_list) do
        local has = false
        for ii, vv in pairs(team_info.members or {}) do
            if v.data ~= nil and v.data.role_id == vv.role_id then
                has = true
            end
        end

        if not has then
            table.insert(deleMemberItem, v)
        end
    end

    for i, v in pairs(deleMemberItem) do
        v:SetData(nil)
    end

    for i, v in pairs(needLoadMember) do
        memberCount = memberCount + 1
        if self.team_item_list[memberCount] ~= nil then
            self.team_item_list[memberCount]:SetData(v)
        end
    end
    self:UpdateExp(team_info.members)
end

function MyTeamPanel:UpdateView()
    if self.is_loaded then
        if self.model.team_info then
            local main_role_id = RoleInfoModel:GetInstance():GetMainRoleId()
            self:SetVisibleBtn(self.model:IsCaptain(main_role_id))
            local team_info = self.model:GetTeamInfo()
            self.target:GetComponent('Text').text = Config.db_team_target_sub[team_info.type_id].name
            local min_level = team_info.min_level
            min_level = GetLevelShow(min_level)
            local max_level = team_info.max_level
            max_level = GetLevelShow(max_level)
            self.level:GetComponent('Text').text = string.format(ConfigLanguage.Team.TeamLevelRange, min_level, max_level)
            local members = team_info.members
            self:UpdateExp(members)
            if team_info.type_id <= 2 then
                self.TextEnter.text = "Go"
            else
                self.TextEnter.text = "Enter Stage"
            end
            if self.model:IsCaptain(RoleInfoModel:GetInstance():GetMainRoleId()) then
                local level = RoleInfoModel:GetInstance():GetRoleValue("level")
                SetVisible(self.addfaker, level >= 200)
            end
            if self.model:GetAddFaker() == 1 then
                self.addfaker.isOn = true
            else
                self.addfaker.isOn = false
            end
			
			local team_info = self.model:GetTeamInfo()
			self.tog.isOn = (team_info.is_auto_accept == 1)
        else
            self:Close()
        end
    else
        self.need_load_end = true
    end

end

function MyTeamPanel:UpdateExp(members)
    local online_num = self.model:GetTeamOnlineMemNum()
    for i = 1, 3 do
        local member = members[i]
        local memberItem
        if self.team_item_list[i] then
            memberItem = self.team_item_list[i]
        else
            memberItem = MyTeamMemberItem(self.Content)
            self.team_item_list[i] = memberItem
        end
        memberItem:SetData(member, i)
        if i <= online_num then
            lua_resMgr:SetImageTexture(self, self.team_p_img[i], "team_image", "team_p_2", false, false, false)
        else
            lua_resMgr:SetImageTexture(self, self.team_p_img[i], "team_image", "team_p_1", false, false, false)
        end
    end
    self.exp_text.text = "Team EXP" .. self.model:GetExpPlus()
    if #members >= 3 then
        self.model.auto_call = false
    end
    if self.model.auto_call then
        self.callText_txt.text = "Cancel"
    else
        self.callText_txt.text = "Auto Recruitment"
    end
end

function MyTeamPanel:CloseCallBack()

end
function MyTeamPanel:SwitchCallBack(index)
    if self.table_index == index then
        return
    end
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    self.table_index = index
    --if self.table_index == 1 then
    -- if not self.show_panel then
    -- 	self.show_panel = ChildPanel(self.transform)
    -- end
    -- self:PopUpChild(self.show_panel)
    --end
end

function MyTeamPanel:SetVisibleBtn(flag)
    SetVisible(self.btn_change_target, flag)
    --SetVisible(self.btn_match, flag)
    SetVisible(self.btn_enter, flag)
    SetVisible(self.btn_apply_list, flag)
    SetVisible(self.btn_remind_captain, not flag)
end
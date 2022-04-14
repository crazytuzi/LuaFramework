DungeTeamItem = DungeTeamItem or class("DungeTeamItem",BaseItem)
local DungeTeamItem = DungeTeamItem

function DungeTeamItem:ctor(parent_node,layer)
	self.abName = "dungeon"
	self.assetName = "DungeTeamItem"
	self.layer = layer

	self.model = TeamModel:GetInstance()
	self.dunge_model = DungeonModel:GetInstance()
	self.item_list = {}
	self.team_events = {}
	self.events = {}
	DungeTeamItem.super.Load(self)
end

function DungeTeamItem:dctor()
	if self.item_list then
		destroyTab(self.item_list)
		self.item_list = nil
	end

	if self.team_events then
		self.model:RemoveTabListener(self.team_events)
		self.team_events = nil
	end

	if self.events then
		self.dunge_model:RemoveTabListener(self.events)
		self.events = nil
	end

	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end

	if self.remind_schedule then
		GlobalSchedule:Stop(self.remind_schedule)
		self.remind_schedule = nil
	end
end

function DungeTeamItem:LoadCallBack()
	self.nodes = {
		"Content","targettitle/target","autoaccept","Content/DungeMyTeamMemberItem",
		"quitbtn","applybtn","callbtn", "callbtn/callText","settingbtn","remindbtn",
		"remindbtn/remindText","addfaker",
	}
	self:GetChildren(self.nodes)
	self.autoaccept = GetToggle(self.autoaccept)
	self.addfaker = GetToggle(self.addfaker)
	self.target = GetText(self.target)
	self.callText_txt = GetText(self.callText)
	self.remindText = GetText(self.remindText)
	self.remindbtn = GetButton(self.remindbtn)
	self.DungeMyTeamMemberItem_go = self.DungeMyTeamMemberItem.gameObject
	SetVisible(self.DungeMyTeamMemberItem_go, false)
	self:AddEvent()
	SetVisible(self.addfaker, false)
	self:UpdateView()
end

function DungeTeamItem:AddEvent()

	local function call_back(target,x,y)
		TeamController.GetInstance():RequestQuit()
	end
	AddButtonEvent(self.quitbtn.gameObject,call_back)

	local function call_back(target,x,y)
		if table.nums(self.model:GetApplyList()) <= 0 then
            Notify.ShowText(ConfigLanguage.Team.NotPlayerApply)
        else
            lua_panelMgr:GetPanelOrCreate(ApplyListPanel):Open()
        end
	end
	AddButtonEvent(self.applybtn.gameObject,call_back)

	local function call_back(target,x,y)
		lua_panelMgr:GetPanelOrCreate(CreateTeamPanel):Open(true, nil, true)
	end
	AddButtonEvent(self.settingbtn.gameObject,call_back)

	local function call_back(target,x,y)
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
			TeamModel:GetInstance():SetAddFaker(0)
            TeamController:GetInstance():AddFaker()
            self.model.auto_call = not self.model.auto_call
            if self.model.auto_call then
                self.callText_txt.text = "Cancel"
            else
                self.callText_txt.text = "World Recruitment"
            end
            self.model:Brocast(TeamEvent.AutoCall)
        end
	end
	AddButtonEvent(self.callbtn.gameObject,call_back)

	local function call_back(target,x,y)
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
            self.remindbtn.interactable = false
            self.remind_schedule = GlobalSchedule:Start(handler(self,self.UpdateCD), 1, 5)
            self:UpdateCD()
        else
            Notify.ShowText("The team target is not a dungeon scene")
        end
	end
	AddButtonEvent(self.remindbtn.gameObject,call_back)

	local function call_back(target, bool)
		local team_info = TeamModel.GetInstance():GetTeamInfo()
		if (team_info.is_auto_accept == 1 and bool) or (team_info.is_auto_accept == 0 and not bool) then
			return
		end
		is_auto_accept = bool and 1 or 0
		TeamController.GetInstance():RequestChangeTarget(nil, nil, nil, is_auto_accept)
	end
	AddValueChange(self.autoaccept.gameObject, call_back)

	--local function call_back(target, bool)
	--	local addfaker = (bool and 1 or 0)
	--	self.model:SetAddFaker(addfaker)
	--end
	--AddValueChange(self.addfaker.gameObject, call_back)

	local function call_back()
		self:ShowRedDot()
	end
	self.team_events[#self.team_events+1] = self.model:AddListener(TeamEvent.UpdateApplyList, call_back)

	local function call_back()
		local team_info = self.model:GetTeamInfo()
		if #team_info.members >= 3 then
			self.model.auto_call = false
            if self.model.auto_call then
                self.callText_txt.text = "Cancel"
            else
                self.callText_txt.text = "World Recruitment"
            end
		end
	end
	self.team_events[#self.team_events+1] = self.model:AddListener(TeamEvent.UpdateTeamInfo, call_back)

	local function call_back()
    	if self.model.auto_call then
           	self.callText_txt.text = "Cancel"
        else
            self.callText_txt.text = "World Recruitment"
        end
    end
    self.team_events[#self.team_events+1] = self.model:AddListener(TeamEvent.AutoCall, call_back)
end

--data:team_info
function DungeTeamItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function DungeTeamItem:UpdateView()
	local team_info = TeamModel.GetInstance():GetTeamInfo()
	if self.data then
		if self.model:IsCaptain(RoleInfoModel:GetInstance():GetMainRoleId()) then
			SetVisible(self.applybtn, true)
			SetVisible(self.remindbtn, false)
			--local level = RoleInfoModel:GetInstance():GetRoleValue("level")
			--SetVisible(self.addfaker, level >= 200)
		else
			SetVisible(self.applybtn, false)
			SetVisible(self.remindbtn, true)
		end
		self.target.text = Config.db_team_target_sub[team_info.type_id].name
		self.autoaccept.isOn = (team_info.is_auto_accept == 1)
		local members = team_info.members
		for i=1, 3 do
	        local member = members[i]
	        local memberItem
	        if self.item_list[i] then
	            memberItem = self.item_list[i]
	        else
	            memberItem = DungeMyTeamMemberItem(self.DungeMyTeamMemberItem_go, self.Content)
	        end
	        memberItem:SetData(member, i)
	        self.item_list[i] = memberItem
		end
		local dunge = self.dunge_model.team_select_dunge
		self.dunge_model:Brocast(DungeonEvent.TeamBossItemClick, dunge)
		self:ShowRedDot()
		--if self.model:GetAddFaker() == 1 then
		--	self.addfaker.isOn = true
		--else
		--	self.addfaker.isOn = false
		--end
	end
end

function DungeTeamItem:UpdateCD()
    if self.model.remind_cd <= 0 then
        GlobalSchedule:Stop(self.remind_schedule)
        self.remind_schedule = nil
        self.remindText.text = "Notice team leader"
        self.remindbtn.interactable = true
    else
        self.remindText.text = string.format("%s sec", self.model.remind_cd)
    end
    self.model.remind_cd = self.model.remind_cd - 1
end

function DungeTeamItem:ShowRedDot()
	local flag = not table.isempty(self.model:GetApplyList())
	if not self.reddot then
		self.reddot = RedDot(self.applybtn)
		SetLocalPositionXY(self.reddot.transform, 44, 14)
	end
	SetVisible(self.reddot, flag)
end
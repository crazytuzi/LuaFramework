TeamListPanel = TeamListPanel or class("TeamListPanel",BasePanel)
local TeamListPanel = TeamListPanel

function TeamListPanel:ctor()
	self.abName = "team"
	self.assetName = "TeamListPanel"
	self.layer = "UI"

	self.use_background = false
	self.change_scene_close = true

	self.menu = {}
	self.sub_menu = {}
	self.team_list = {}
	self.teamlist_height = 0
	self.type_id = 1
	self.sort_type = 2
	self.apply_all = false
	self.globalEvents = {}
	self.panel_type =4
	self.model = TeamModel:GetInstance()
end

function TeamListPanel:dctor()
	for i, v in pairs(self.team_list) do
		v:destroy()
	end
	self.team_list = nil
	
	if self.left_menu then
		self.left_menu:destroy()
	end
	

	if self.event_id then
		self.model:RemoveListener(self.event_id)
		self.event_id = nil
	end

	if self.event_id3 then
		self.model:RemoveListener(self.event_id3)
		self.event_id3 = nil
	end

	if self.event_id4 then
		self.model:RemoveListener(self.event_id4)
		self.event_id4 = nil
	end

	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
end

function TeamListPanel:Open(type_id)
	self.type_id = type_id or 1
	TeamListPanel.super.Open(self)
end

function TeamListPanel:LoadCallBack()
	self.nodes = {
		"bg/btn_close",
		"bg/leftmenu",
		"bg/team_list/Viewport/Content",
		"bg/btn_refresh",
		"bg/btn_createteam",
		"bg/btn_applyquick",
		"bg/toggle_group/captain_level",
		"bg/toggle_group/member_num"
	}
	self:GetChildren(self.nodes)

	self:AddEvent()
	SetAlignType(self.transform, bit.bor(AlignType.Left, AlignType.Null))
end

function TeamListPanel:AddEvent()
	local function leftfirstmenuclick_call_back(ClickIndex, is_Show)
		if is_Show then
			--self:CleanSlotItems()
		else
			local s_index = 0
			if ClickIndex == 1 then
				s_index = 0
			elseif ClickIndex == 2 then
				s_index = 1
			else
				s_index = ClickIndex-1
			end
			GlobalEvent:Brocast(CombineEvent.SelectSecMenuDefault .. self.__cname, self.sub_menu[s_index][1][1])
		end
	end

	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.btn_close.gameObject,call_back)

	local function call_back(target,x,y)
		if self.model.refresh_time and self.model.refresh_time + 5 > os.time() then
			Notify.ShowText("You refreshed too fast, please try again later")
		else
			self.model.refresh_time = os.time()
			TeamController:GetInstance():RequestGetTeamList(self.type_id)
		end
	end
	AddClickEvent(self.btn_refresh.gameObject,call_back)

	local function call_back(target, value)
		if value then
			self.sort_type = 1
			self:SortTeam()
		end
	end
	AddValueChange(self.captain_level.gameObject, call_back)

	local function call_back(target, value)
		if value then
			self.sort_type = 2
			self:SortTeam()
		end
	end
	AddValueChange(self.member_num.gameObject,call_back)

	local function call_back(target,x,y)
		local team_info = self.model:GetTeamInfo()
		if team_info then
			return Notify.ShowText(ConfigLanguage.Team.TeamInTeam)
		else
			--lua_panelMgr:GetPanelOrCreate(CreateTeamPanel):Open(nil, self.type_id)
			GlobalEvent:Brocast(TeamEvent.CreateTeamView, self.type_id)
			self:Close()
		end
	end
	AddClickEvent(self.btn_createteam.gameObject,call_back)

	local function call_back(target,x,y)
		self.apply_all = true
		if self.schedule_id then
			GlobalSchedule:Stop(self.schedule_id)
			self.schedule_id = nil
		end
		self.schedule_id = GlobalSchedule:Start(handler(self,self.ApplyAll), 0.5)
	end
	AddClickEvent(self.btn_applyquick.gameObject,call_back)

	local function call_back()
		self:SortTeam()
	end
	self.event_id = self.model:AddListener(TeamEvent.UpdateTeamList, call_back)

	local function call_back()
		self.apply_all = false
	end
	self.event_id3 = self.model:AddListener(TeamEvent.ApplyTeamSuccess, call_back)

	local function call_back()
		if self.model:GetTeamInfo() then
			self:Close()
		end
	end
	self.event_id4 = self.model:AddListener(TeamEvent.UpdateTeamInfo, call_back)

	local function call_back(menu_id,type_id)
		self.type_id = type_id
		TeamController:GetInstance():RequestGetTeamList(type_id)
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(CombineEvent.LeftSecondMenuClick .. self.__cname, call_back)
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(CombineEvent.LeftFirstMenuClick .. self.__cname, leftfirstmenuclick_call_back)
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(MainEvent.ClickSkiilItem,handler(self,self.Close))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EventName.OpenPanel,handler(self,self.DealOpenPanel) )
end

function TeamListPanel:OpenCallBack()
	self:UpdateView()
end

function TeamListPanel:DealOpenPanel(_name,_layer,_panel_type)
	if  _layer == LayerManager.BuiltinLayer.UI then
		self:Close()
	end
end


function TeamListPanel:DelaySelectFirstMenuDefault()
	GlobalEvent:Brocast(CombineEvent.SelectFstMenuDefault .. self.__cname, 1)
end

function TeamListPanel:SelectTreeMenuDefault(SecTypeId)
	--self:Topbuttonclick_call_back(SecTypeId)
	if self.select_default_fst_menu ~= nil then
		GlobalSchedule:Stop(self.select_default_fst_menu)
	end
	self.select_default_fst_menu = GlobalSchedule:StartOnce(handler(self, self.DelaySelectFirstMenuDefault), 0.09)
end

function TeamListPanel:UpdateView( )
	if not self.left_menu then
		self.left_menu = TreeMenu(self.leftmenu,nil,self)
		self.menu, self.sub_menu = {}, {}
		table.insert(self.menu, {0, ConfigLanguage.Team.TeamAllTeam})
		--table.insert(self.menu, {-1, ConfigLanguage.Team.CrntSceneTeam})
		self.sub_menu[0] = {{0, ConfigLanguage.Team.TeamAllTeam}}
		--self.sub_menu[-1] = {{-1, ConfigLanguage.Team.CrntSceneTeam}}
		for i=1, #Config.db_team_target do
			local item = Config.db_team_target[i]
			local data = {item.id, item.name}
			table.insert(self.menu, data)
			self.sub_menu[item.id] = String2Table(item.sub_types)
		end
		local team_info = self.model:GetTeamInfo()
		local type_id = (self.type_id == 0 and (team_info and team_info.type_id or 1) or self.type_id)
		self.left_menu:SetData(self.menu, self.sub_menu, type_id)
		TeamController:GetInstance():RequestGetTeamList(type_id)
		self:SortTeam()
	end
	--self:SelectTreeMenuDefault()
end

function TeamListPanel:UpdateTeamList(team_list)
	for _, item in pairs(self.team_list) do
		item:destroy()
	end
	self.teamlist_height = 0
	if team_list then
		for i=1, #team_list do
			local team = team_list[i]
			local teamItem = TeamListItem(self.Content)
			teamItem:SetData(team,i)
			self.teamlist_height = self.teamlist_height + teamItem:GetHeight()
			table.insert(self.team_list, teamItem)
		end
		self:RelayoutScroll()
	end
end

function TeamListPanel:SortTeam()
	sort_type = self.sort_type
	local team_list = self.model:GetTeamList() or {}
	--队长等级排序
	if sort_type == 1 then
		local function sort(a, b)
			return a.members[1].level > b.members[1].level
		end
		table.sort(team_list, sort)
	--队伍数量排序
	else
		local function sort(a, b)
			return #a.members > #b.members
		end
		table.sort(team_list, sort)
	end
	self:UpdateTeamList(team_list)
end

function TeamListPanel:CloseCallBack()

end

function TeamListPanel:RelayoutScroll()
	self.Content.sizeDelta = Vector2(self.Content.sizeDelta.x, self.teamlist_height)
end

function TeamListPanel:ApplyAll()
	if self.apply_all then
		local team_list = self.model:GetTeamList()
		local apply_team_ids = self.model:GetApplyTeamIds()
		local myteamifno = self.model:GetTeamInfo()
		local count = 0
		for i=1, #team_list do
			count = count + 1
			local item = team_list[i]
			if item and #item.members < 3 then
				local team_id = item.id
				if (myteamifno and myteamifno.id ~= team_id and not apply_team_ids[team_id])
				  or (not myteamifno and not apply_team_ids[team_id]) then
					TeamController:GetInstance():RequestApply(team_id)
					break
				end
			end
		end
		if count == #team_list then
			self.apply_all = false
		end
	else
		if self.schedule_id then
			GlobalSchedule:Stop(self.schedule_id)
			self.schedule_id = nil
		end
	end
end
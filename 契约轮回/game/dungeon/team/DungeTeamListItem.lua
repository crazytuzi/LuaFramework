DungeTeamListItem = DungeTeamListItem or class("DungeTeamListItem",BaseItem)
local DungeTeamListItem = DungeTeamListItem

function DungeTeamListItem:ctor(parent_node,layer)
	self.abName = "dungeon"
	self.assetName = "DungeTeamListItem"
	self.layer = layer

	self.model = DungeonModel:GetInstance()
	self.team_model = TeamModel:GetInstance()
	self.items = {}
	self.events = {}
	self.team_events = {}
	self.team_list_items = {}
	self.global_events = {}
	DungeTeamListItem.super.Load(self)
end

function DungeTeamListItem:dctor()
	self.tab = nil
	if self.items then
		destroyTab(self.items)
		self.items = nil
	end
	self.model:RemoveTabListener(self.events)
	self.events = nil

	self.team_model:RemoveTabListener(self.team_events)
	self.team_events = nil

	if self.global_events then
		GlobalEvent:RemoveTabListener(self.global_events)
		self.global_events = nil
	end

	if self.team_list_items then
		destroyTab(self.team_list_items)
		self.team_list_items = nil
	end
end

function DungeTeamListItem:LoadCallBack()
	self.nodes = {
		"leftbg/ScrollView/Viewport/ContentMenu","leftbg/ScrollView/Viewport/ContentMenu/DungeTeamBossitem",
		"rightbg/ScrollView","rightbg/ScrollView/Viewport/ContentTeam","rightbg/noteamdesc",
		"rightbg/ScrollView/Viewport/ContentTeam/DungeTeamMemberItem",
	}
	self:GetChildren(self.nodes)
	self.DungeTeamBossitem_go = self.DungeTeamBossitem.gameObject
	self.DungeTeamMemberItem_go = self.DungeTeamMemberItem.gameObject
	SetVisible(self.DungeTeamBossitem_go, false)
	SetVisible(self.DungeTeamMemberItem_go, false)
	self:AddEvent()
	self:UpdateView()
end

function DungeTeamListItem:AddEvent()
	local function call_back(dunge)
		self.dunge = dunge
		self:RequestTeamList(dunge.id)
	end
	self.events[#self.events+1] = self.model:AddListener(DungeonEvent.TeamBossItemClick, call_back)


	local function call_back()
		self:UpdateTeamList()
	end
	self.team_events[#self.team_events+1] = self.team_model:AddListener(TeamEvent.UpdateTeamList, call_back)

	local function call_back()
		if self.dunge then
			self:RequestTeamList(self.dunge.id)
		end
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(TeamEvent.NeedUpdateTeamList, call_back)
end

function DungeTeamListItem:SetData(data, bossid)
	self.data = data
	self.default_boss_id = bossid
	if self.is_loaded then
		self:UpdateView()
	end
end

function DungeTeamListItem:UpdateView()
	if self.data then
		local tab = self.model.allEquipDunge
		--装备本
		if self.data == 1 then
			tab = self.model.allEquipDunge
		--宠物本
		elseif self.data == 2 then
			tab = self.model.allPetDunge
		end
		self.tab = tab

		local selectedItemIndex = 1;
	    local level = RoleInfoModel:GetInstance():GetMainRoleLevel();
	    destroyTab(self.items)
	    self.items = {}
	    for i = 1, #tab do
	        local item = DungeTeamBossitem(self.DungeTeamBossitem_go, self.ContentMenu)
	        item:SetData(tab[i])
	        if self.default_boss_id then
	            if tab[i].id == self.default_boss_id then
	                selectedItemIndex = i
	            end
	        else
	            if tab[i].level and level >= tonumber(tab[i].level) then
	                selectedItemIndex = i
	            end
	        end
	        item.gameObject.name = "DungeTeamBossitem_" .. i
	        self.items[i] = item
	    end
	    self.model.team_select_dunge = self.tab[selectedItemIndex]
	    self.model:Brocast(DungeonEvent.TeamBossItemClick, self.tab[selectedItemIndex])
	    if selectedItemIndex <= 3 then
	        SetLocalPositionY(self.ContentMenu.transform, 0);
	    else
	        SetLocalPositionY(self.ContentMenu.transform, (50 + (selectedItemIndex - 3) * 100));
	    end
	end
end

function DungeTeamListItem:RequestTeamList(dunge_id)
	local subtab = TeamModel:GetInstance():GetSubIDByDungeID(dunge_id)
	TeamController.GetInstance():RequestGetTeamList(subtab.id)
end

function DungeTeamListItem:UpdateTeamList()
	local team_list2 = self.team_model:GetTeamList()
	local team_list = {}
	for i=#team_list2, 1, -1 do
		local team_info = team_list2[i]
		local scene_id = team_info.members[1].scene_id
		local scenecfg = Config.db_scene[scene_id]
		if scenecfg.stype ~= self.dunge.stype then
			table.insert(team_list, team_info)
		end
	end
	--destroyTab(self.team_list_items)
	if table.isempty(team_list) then
		SetVisible(self.ScrollView, false)
		SetVisible(self.noteamdesc, true)
	else
		SetVisible(self.ScrollView, true)
		SetVisible(self.noteamdesc, false)
		--self.team_list_items = {}
		for i=1, #team_list do
			local item = self.team_list_items[i] or DungeTeamMemberItem(self.DungeTeamMemberItem_go, self.ContentTeam)
			item:SetData(team_list[i])
			item:SetVisible(true)
			self.team_list_items[i] = item
		end
		if #self.team_list_items > #team_list then
			for i=#team_list+1, #self.team_list_items do
				self.team_list_items[i]:SetVisible(false)
			end
		end
	end
end


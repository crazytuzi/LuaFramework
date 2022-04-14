DungeCommonInfoItem = DungeCommonInfoItem or class("DungeCommonInfoItem",BaseItem)
local DungeCommonInfoItem = DungeCommonInfoItem

function DungeCommonInfoItem:ctor(parent_node,layer)
	self.abName = "dungeon"
	self.assetName = "DungeCommonInfoItem"
	self.layer = layer

	self.model = DungeonModel:GetInstance()
	self.team_model = TeamModel.GetInstance()
	self.events = {}
	self.team_events = {}
	self.global_events = {}
	self.awarditems = {}
	DungeCommonInfoItem.super.Load(self)
end

function DungeCommonInfoItem:dctor()
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end

	if self.global_events then
		GlobalEvent:RemoveTabListener(self.global_events)
		self.global_events = nil
	end
	if self.awarditems then
		destroyTab(self.awarditems)
		self.awarditems = nil
	end
	if self.team_events then
		self.team_model:RemoveTabListener(self.team_events)
		self.team_events = nil
	end
end

function DungeCommonInfoItem:LoadCallBack()
	self.nodes = {
		"powertitle1/power","powertitle2/mypower","openleveltitle/openlevel","desc","ScrollView/Viewport/Content",
		"counttitle/left_count","combineTog","matchbtn","enterbtn","combineTog/Label","title",
		"createbtn","matchbtn/Textmatch",
	}
	self:GetChildren(self.nodes)
	self.power = GetText(self.power)
	self.mypower = GetText(self.mypower)
	self.openlevel = GetText(self.openlevel)
	self.desc = GetText(self.desc)
	self.left_count = GetText(self.left_count)
	self.combineTog = GetToggle(self.combineTog)
	self.Label = GetText(self.Label)
	self.title = GetText(self.title)
	self.Textmatch = GetText(self.Textmatch)
	self:AddEvent()
	SetVisible(self.combineTog, RoleInfoModel:GetInstance():GetRoleValue("level") >= 300)
	self:UpdateView()
end

function DungeCommonInfoItem:AddEvent()

	local function call_back(dunge)
		self.dunge = dunge
		self:UpdateView()
	end
	self.events[#self.events + 1] = self.model:AddListener(DungeonEvent.TeamBossItemClick, call_back)

	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_SWEEP_REFRESH, handler(self, self.UpdateTimes))
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonTime, handler(self, self.UpdateTimes))

	local function call_back(dungeon_type, data)
        if dungeon_type == self.dunge.stype then
            self:UpdateData(data)
        end
    end
    self.global_events[#self.global_events + 1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonData, call_back)

    local function call_back()
    	local team_info = self.team_model:GetTeamInfo()
		if #team_info.members >= 3 then
			self.team_model.auto_call = false
            if self.team_model.auto_call then
                self.Textmatch.text = "Cancel"
            else
                self.Textmatch.text = "Auto match"
            end
		end
    end
    self.team_events[#self.team_events+1] = self.team_model:AddListener(TeamEvent.UpdateTeamInfo, call_back)

    local function call_back()
    	if self.team_model.auto_call then
           	self.Textmatch.text = "Cancel"
        else
            self.Textmatch.text = "Auto match"
        end
    end
    self.team_events[#self.team_events+1] = self.team_model:AddListener(TeamEvent.AutoCall, call_back)

	local function call_back(target, value)
        local allData = self.model.dungeon_info_list[self.dunge.stype]
        local data = allData.info
        if self.combineTog.isOn then
            if data.rest_times <= 1 then
                Notify.ShowText("Not enough attempts left")
                self.combineTog.isOn = false
                return
            end
            local function ok_func(count)
                self.combineTog.isOn = true
                TeamModel.GetInstance():SetMerge(data.stype, count)
                self.Label.text = string.format("Merge %s times", count)
            end
            local function cancle_func()
                self.combineTog.isOn = false
                self.Label.text = "Combination"
            end
            lua_panelMgr:GetPanelOrCreate(DungeMergePanel):Open(self.dunge.stype,ok_func, cancle_func, data.rest_times)
        else
            TeamModel.GetInstance():SetMerge(data.stype, 1)
            self.Label.text = "Combination"
        end
    end
    AddClickEvent(self.combineTog.gameObject, call_back)

   	local function call_back(target,x,y)
   		local team_info = TeamModel.GetInstance():GetTeamInfo()
   		if team_info then
   			local dunge_name = self.dunge.name
            local dunge_level = self.dunge.level
            local captain = TeamModel.GetInstance():GetCaptain(team_info)
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
            self.team_model.auto_call = not self.team_model.auto_call
            if self.team_model.auto_call then
                self.Textmatch.text = "Cancel"
            else
                self.Textmatch.text = "Auto match"
            end
            self.team_model:Brocast(TeamEvent.AutoCall)
   		else
   			local team_list = TeamModel.GetInstance():GetTeamList()
   			if table.isempty(team_list) then
   				local subtab = TeamModel:GetInstance():GetSubIDByDungeID(self.dunge.id)
	   			local min_level = String2Table(subtab.min_lv)[1][3]
	   			local max_level = String2Table(subtab.max_lv)[1][3]
	   			TeamModel.GetInstance().no_open_team_panel = true
	   			TeamController.GetInstance():RequestCreateTeam(subtab.id, min_level, max_level, 1)
   			else
				local apply_team_ids = TeamModel.GetInstance():GetApplyTeamIds()
				local count = 0
				for i=1, #team_list do
					count = count + 1
					local item = team_list[i]
					if item and #item.members < 3 then
						local team_id = item.id
						if apply_team_ids[team_id] then
							TeamController:GetInstance():RequestApply(team_id)
							break
						end
					end
				end
			end
   		end
   	end
   	AddButtonEvent(self.matchbtn.gameObject,call_back)

   	local function call_back(target,x,y)
   		local roleLevel = RoleInfoModel:GetInstance():GetMainRoleLevel();
		local vipLevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel();
   		if self.dunge.level > roleLevel then
		    Notify.ShowText("Insufficient level. Please upgrade and come back");
		    return
		end
   		local team_info = TeamModel.GetInstance():GetTeamInfo()
   		if not team_info then
   			if TeamController.GetInstance():IsSpecialCreateTeam() then
	            if TeamModel.GetInstance():GetTeamInfo() then
	                TeamController:GetInstance():RequestQuit()
	            end
	            local subtab = TeamModel:GetInstance():GetSubIDByDungeID(self.dunge.id)
	            TeamModel.GetInstance().special_dunge_id = self.dunge.id
	            TeamController.GetInstance():RequestCreateTeam(subtab.id, 100, 800, 1)
	            lua_panelMgr:GetPanel(DungeonEntrancePanel):Close()
	            return
	        end
   			local subtab = TeamModel:GetInstance():GetSubIDByDungeID(self.dunge.id)
   			local min_level = String2Table(subtab.min_lv)[1][3]
   			local max_level = String2Table(subtab.max_lv)[1][3]
   			TeamModel.GetInstance().no_open_team_panel = true
   			TeamController.GetInstance():RequestCreateTeam(subtab.id, min_level, max_level, 1)
   		else
		    if not TeamModel:GetInstance():IsCaptain(RoleInfoModel:GetInstance():GetMainRoleId()) then
		        Notify.ShowText("You are not the leaser, please contact the leader to enter");
		        return ;
		    end

		    local okFun = function()
		        --服务端定一个协议
		        TeamController:GetInstance():DungeEnterAsk(self.dunge.id, 1)
		    end
		    local singleFun = function()
		    	local data = self.model.dungeon_info_list[self.dunge.stype]
		        if data.info.rest_times <= 0 then
		            Dialog.ShowTwo("Tip", "Dungeon attempts used out. Help other players clear dungeons so you can get honor rewards (First 20 every day)", "Confirm", okFun,
		                        nil, "Cancel", nil, nil, "Don't notice me again today", true, false, self.__cname)
		            return
		        else
		            okFun()
		        end
		    end

		    if TeamModel:GetInstance():GetMyTeamMemberNum() == 1 then
		        Dialog.ShowTwo("Tip", "There is only 1 player, enter the dungeon?", "Confirm", singleFun, nil, "Cancel")
		    else
		        singleFun()
		    end
   		end
   	end
   	AddButtonEvent(self.enterbtn.gameObject,call_back)

   	local function call_back(target,x,y)
   		local roleLevel = RoleInfoModel:GetInstance():GetMainRoleLevel();
		local vipLevel = RoleInfoModel:GetInstance():GetMainRoleVipLevel();
   		if self.dunge.level > roleLevel then
		    Notify.ShowText("Insufficient level. Please upgrade and come back");
		    return
		end
		if TeamController.GetInstance():IsSpecialCreateTeam() then
	        if TeamModel.GetInstance():GetTeamInfo() then
	            TeamController:GetInstance():RequestQuit()
	        end
	        local subtab = TeamModel:GetInstance():GetSubIDByDungeID(self.dunge.id)
	        TeamModel.GetInstance().special_dunge_id = self.dunge.id
	        TeamController.GetInstance():RequestCreateTeam(subtab.id, 100, 800, 1)
	        lua_panelMgr:GetPanel(DungeonEntrancePanel):Close()
	        return
	    end
   		local subtab = TeamModel:GetInstance():GetSubIDByDungeID(self.dunge.id)
   		local min_level = String2Table(subtab.min_lv)[1][3]
   		local max_level = String2Table(subtab.max_lv)[1][3]
   		TeamModel.GetInstance().no_open_team_panel = true
   		TeamController.GetInstance():RequestCreateTeam(subtab.id, min_level, max_level, 1)
   	end
   	AddButtonEvent(self.createbtn.gameObject,call_back)
end


function DungeCommonInfoItem:SetData(data)

end

function DungeCommonInfoItem:UpdateView()
	if self.is_loaded then
		self.dunge = self.dunge or self.model.team_select_dunge
		if self.dunge then
			self.power.text = self.dunge.power
			local mypower = RoleInfoModel:GetInstance():GetRoleValue("power")
			if mypower < self.dunge.power then
				self.mypower.text = string.format("<color=#ff0000>%s</color>", mypower)
			else
				self.mypower.text = mypower
			end
			local level = RoleInfoModel:GetInstance():GetRoleValue("level")
			if self.dunge.level > level then
				self.openlevel.text = string.format("<color=#ff0000>%s LvL</color>", GetLevelShow(self.dunge.level))
			else
				self.openlevel.text = string.format("Lv.%s", GetLevelShow(self.dunge.level))
			end
			self.desc.text = string.format("<color=#AA5D25>Rules: </color>%s", self.dunge.des)
			self.title.text = self.dunge.name
			local team_info = TeamModel.GetInstance():GetTeamInfo()
			if team_info then
				SetVisible(self.createbtn, false)
				SetVisible(self.enterbtn, true)
			else
				SetVisible(self.createbtn, true)
				SetVisible(self.enterbtn, false)
			end
			self:UpdateTimes()
			self:ShowAwards()
		end
	end
end

function DungeCommonInfoItem:UpdateTimes()
	local allData = self.model.dungeon_info_list[self.dunge.stype]
    if not allData then
        return
    end
    local sweep = String2Table(self.dunge.sweep_cost)
    if sweep and #sweep > 1 then
        local num = BagModel:GetInstance():GetItemNumByItemID(sweep[1])
        self.saodang_times.text = num .. "/" .. sweep[2]
    end
    local info = allData.info
    if info.rest_times > 0 then
        self.left_count.text = info.rest_times .. "/" .. info.max_times;
    else
        self.left_count.text = "<color=#ff0000>" .. info.rest_times .. "</color>/" .. info.max_times;
    end
end

--收到后端数据更新
function DungeCommonInfoItem:UpdateData(allData)
    local info = allData.info;
    if info.rest_times > 0 then
        self.left_count.text = info.rest_times .. "/" .. info.max_times;
    else
        self.left_count.text = "<color=#ff0000>" .. info.rest_times .. "</color>/" .. info.max_times;
    end

    local merge_count = TeamModel.GetInstance():GetMerge(info.stype)
    if merge_count > 1 then
        self.combineTog.isOn = true
        self.Label.text = string.format("Merge %s times", merge_count)
    else
        self.combineTog.isOn = false
        self.Label.text = "Combination"
    end
end

function DungeCommonInfoItem:RefreshEquipEntranceItem(item)
    if item then
        local data = item.data;
        local awardTab = String2Table(data.reward_show);
        self:InitAwards(awardTab);
    end
end

function DungeCommonInfoItem:ShowAwards()
    destroyTab(self.awarditems)
    self.awarditems = {}
    local tab = String2Table(self.dunge.reward_show)
    for i = 1, #tab do
        local awardItem = GoodsIconSettorTwo(self.Content)
        local param = {}
        param["item_id"] = tab[i];
        param["bind"] = 2
        param["can_click"] = true;
        param["bind"] = true;
        param["size"] = { x = 80, y = 80 }
        awardItem:SetIcon(param);

        table.insert(self.awarditems, awardItem);
    end
end
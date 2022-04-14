TaskTipItem = TaskTipItem or class("TaskTipItem",BaseCloneItem)
local TaskTipItem = TaskTipItem

function TaskTipItem:ctor(obj,parent_node,layer)
	TaskTipItem.super.Load(self)
end

function TaskTipItem:dctor()
	GlobalEvent:RemoveTabListener(self.events)
end

function TaskTipItem:LoadCallBack()
	self.nodes = {
		"icon", "title", "desc", "gotobtn","count","buybtn",
		"gotobtn/gotoText",
	}
	self:GetChildren(self.nodes)
	self.icon = GetImage(self.icon)
	self.title = GetText(self.title)
	self.desc = GetText(self.desc)
	self.count = GetText(self.count)
	self.gotoText = GetText(self.gotoText)
	self.world_level = 0
	self:AddEvent()
	self:UpdateView()
	RoleInfoController.GetInstance():RequestWorldLevel()
end

function TaskTipItem:AddEvent()
	self.events = self.events or {}

	local function call_back(target,x,y)
		if self.data.conData.link_type == 1 then
            --任务
            if self.data.conData.link then
                local link_id = tonumber(String2Table(self.data.conData.link)[1])
                if link_id == 930000 then
                    if RoleInfoModel.GetInstance():GetMainRoleData().guild == "0" then
                        Notify.ShowText("Please join the guild first")
                        return
                    end
                end
                local task_type
                if link_id == 920000 then
                    task_type = enum.TASK_TYPE.TASK_TYPE_DAILY
                elseif link_id == 930000 then
                    task_type = enum.TASK_TYPE.TASK_TYPE_GUILD
                end
                TaskModel.GetInstance():DoTaskByType(task_type)
            end
        elseif self.data.conData.link_type == 3 then
            --界面跳转
            if self.data.conData.link ~= "" then
                local pTab = String2Table(self.data.conData.link)
                OpenLink(unpack(pTab[1]))
            end
        elseif self.data.conData.link_type == 4 then
            --挂机
            local curLv = RoleInfoModel.GetInstance():GetMainRoleLevel()
            local hookData = {}
            hookData.level = 1
            for mapId, mapInfo in pairs(Config.db_afk_map) do
                if mapInfo.level > hookData.level and mapInfo.level <= curLv then
                    hookData = mapInfo
                end
            end
            SceneManager:GetInstance():AttackCreepByTypeId(hookData.creep)
        elseif self.data.conData.link_type == 5 then
            --npc
            if self.data.conData.link then
                SceneManager:GetInstance():FindNpc(String2Table(self.data.conData.link)[1])
            end
        end
        local panel = lua_panelMgr:GetPanel(TaskTipPanel)
        if panel then
        	panel:Close()
        end
	end
	AddButtonEvent(self.gotobtn.gameObject,call_back)

	local function call_back(target,x,y)
		local data = DungeonModel:GetInstance().dungeon_info_list[self.tasktipcfg.dunge_type]
		if data then
			lua_panelMgr:GetPanelOrCreate(DungeonEntranceBuyTip):Open(data.info, self.tasktipcfg.vip_rights)
		end
	end
	AddButtonEvent(self.buybtn.gameObject,call_back)

	local function call_back(stype)
		if self.tasktipcfg.dunge_type == stype then
			self:UpdateView()
		end
	end
	self.events[#self.events+1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonTime, call_back)

	local function call_back(world_level)
		self.world_level = world_level
		if self.data.conData.id == 1006 or self.data.conData.id == 1007 or self.data.conData.id == 1010 then
			self:SetDesc(1)
		end
	end
	self.events[#self.events+1] = GlobalEvent:AddListener(RoleInfoEvent.QUERY_WORLD_LEVEL, call_back)
end

--data:dailytask
function TaskTipItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function TaskTipItem:UpdateView()
	if self.data then
		self.tasktipcfg = Config.db_task_tip[self.data.conData.id]
		lua_resMgr:SetImageTexture(self, self.icon, "iconasset/icon_daily", self.data.conData.pic, true)
		self.title.text = self.data.conData.name
		local left_count = 0
		local total_count = 0
		if self.tasktipcfg.can_buy == 1 then
			local data = DungeonModel.GetInstance().dungeon_info_list[self.tasktipcfg.dunge_type]
			left_count = (data and data.info.rest_times or 0)
		else
			if self.data.taskInfo then
				left_count = self.data.conData.count - self.data.taskInfo.progress
			else
				left_count = self.data.conData.count
			end
		end
		if left_count <= 0 then
			SetVisible(self.count, false)
			SetVisible(self.gotobtn, false)
			if self.tasktipcfg.can_buy == 1 then
				SetVisible(self.buybtn, true)
			end
		else
			SetVisible(self.count, true)
			SetVisible(self.gotobtn, true)
			SetVisible(self.buybtn, false)
		end
		if self.data.conData.act_type == 1 then
			self.count.text = string.format("Attempts: %s/%s", left_count, self.data.conData.count)
		else
			local time = String2Table("{" .. self.data.actData.time .. "}")
			local strTab = {}
			for i=1, #time do
				local startTab = {string.format("%02d", time[i][1][1]), string.format("%02d", time[i][1][2])}
				local start_time = table.concat(startTab, ":")
				local endTab = {string.format("%02d", time[i][2][1]), string.format("%02d", time[i][2][2])}
				local end_time = table.concat(endTab, ":")
				local str = string.format("%s-%s", start_time, end_time)
				strTab[#strTab+1] = str
			end
			self.count.text = table.concat(strTab, "\n")
			if self.data.timeData.state == 1 then
				self.gotoText.text = "Go"
			elseif self.data.timeData.state == 2 then
				self.gotoText.text = "Closed"
			else
				self.gotoText.text = "Expired"
			end
		end
		if self.data.conData.link_type == 4 then
			SetVisible(self.count, false)
			SetVisible(self.gotobtn, true)
			SetVisible(self.buybtn, false)
		end
		
		self:SetDesc(left_count)
	end
end

function TaskTipItem:SetDesc(left_count)
	local level = RoleInfoModel:GetInstance():GetRoleValue("level")
	local id = self.data.conData.id
	local exp = 0
	--读task_loop表,type=3
	if id == 1 then 
		local key = string.format("%s@%s", 3, level)
		local cfg = Config.db_task_loop[key]
		if cfg then
			local tab = String2Table(cfg.loop_reward)
			for i=1, #tab do
				if tab[i][1] == 90010002 then
					exp = tab[i][2]
					break
				end
			end
		end
	--读task_loop,type=4
	elseif id == 4 then
		local key = string.format("%s@%s", 4, level)
		local cfg = Config.db_task_loop[key]
		if cfg then
			local tab = String2Table(cfg.loop_reward)
			for i=1, #tab do
				if tab[i][1] == 90010002 then
					exp = tab[i][2]
					break
				end
			end
		end
	---读exp_acti_base表，用个人等级*配置的系数*剩余次数
	elseif id == 6 then
		local power = GetAttackPowerByList()
		local ratio = power/Config.db_task_tip_fight[level].fight
		exp = math.floor(Config.db_exp_acti_base[level].player_exp * self.tasktipcfg.ratio * ratio)
	elseif id == 5 or id == 1002 or id==1008 or id ==1009 then
		exp = Config.db_exp_acti_base[level].player_exp * self.tasktipcfg.ratio
	--用公式算
	elseif id == 9 then

	--读escort_product，用最高品质的值*剩余次数
	elseif id == 10 then
		local key = string.format("%s@%s", 4, level)
		local cfg = Config.db_escort_product[key]
		if cfg then
			local tab = String2Table(cfg.complete)
			for i=1, #tab do
				if tab[i][1] == 90010002 then
					exp = tab[i][2]
					break
				end
			end
		end
	--读task_tip_exp表
	elseif id == 13 then
		exp = Config.db_task_tip_exp[level].exp
	--读arena_challenge表，用胜利的奖励
	elseif id == 16 then
		local tab = String2Table(Config.db_arena_challenge[level].win)
		for i=1, #tab do
			if tab[i][1] == 90010002 then
				exp = tab[i][2]
				break
			end
		end
	--读escort_product，用最高品质的值*剩余次数*2
	elseif id == 1000 then
		local key = string.format("%s@%s", 4, level)
		local cfg = Config.db_escort_product[key]
		if cfg then
			local tab = String2Table(cfg.complete)
			for i=1, #tab do
				if tab[i][1] == 90010002 then
					exp = tab[i][2]
					break
				end
			end
		end
		exp = exp * 2
	--candyroom_exp表每10秒的值*120
	elseif id == 1004 then
		exp = Config.db_candyroom_exp[level].loop_exp * 120
	---读exp_acti_base表，用世界等级*配置的系数
	elseif id == 1006 then
		local cfg = Config.db_exp_acti_base[self.world_level]
		if cfg then
			exp = cfg.worldlv_exp * self.tasktipcfg.ratio
		end
	---读exp_acti_base表，用世界等级*配置的系数
	elseif id == 1007 then
		local cfg = Config.db_exp_acti_base[self.world_level]
		if cfg then
			exp = cfg.worldlv_exp * self.tasktipcfg.ratio
		end
	---读exp_acti_base表，用世界等级*配置的系数
	elseif id == 1010 then
		local cfg = Config.db_exp_acti_base[self.world_level]
		if cfg then
			exp = cfg.worldlv_exp * self.tasktipcfg.ratio
		end
	end
	exp = exp * left_count
	local flag, level2 = self:can_level_up(level, exp)
	if flag then
		level2 = GetLevelShow(level2)
		self.desc.text = string.format("Estimated <color=#3ab60e>%s</color> Level", level2)
	else
		local exp = GetShowNumber(exp)
		self.desc.text = string.format("Estimated rewards <color=#3ab60e>%s</color> EXP", exp)
	end
	if id == 9 then
		self.desc.text = ""
	end
end

function TaskTipItem:can_level_up(level, exp)
	local cfg = Config.db_role_level[level]
	if not cfg then
		return false
	end
	local need_exp = cfg.exp
	local cur_exp = RoleInfoModel:GetInstance():GetRoleValue("exp")
	local total_exp = cur_exp+exp
	local oldlevel = level
	while total_exp >= need_exp do
		total_exp = total_exp - need_exp
		level = level + 1
	end

	return level > oldlevel, level
end
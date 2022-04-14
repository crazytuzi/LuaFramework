TimeBossPanel = TimeBossPanel or class("TimeBossPanel",BaseItem)
local TimeBossPanel = TimeBossPanel

function TimeBossPanel:ctor(parent_node,layer)
	self.abName = "dungeon"
	self.assetName = "TimeBossPanel"
	self.layer = layer

	self.model = DungeonModel:GetInstance()
	self.timeboss_model = TimeBossModel.GetInstance()
	self.tog_items = {}
	self.boss_floors = {}
	self.items = {}
	self.timeboss_events = {}
	self.reward_items = {}
	TimeBossPanel.super.Load(self)
end

function TimeBossPanel:dctor()
	self.tog_items = nil
	self.boss_floors = nil
	if self.items then
		destroyTab(self.items)
		self.items = nil
	end
	if self.timeboss_events then
		self.timeboss_model:RemoveTabListener(self.timeboss_events)
		self.timeboss_events = nil
	end
	if self.reward_items then
		destroyTab(self.reward_items)
		self.reward_items = nil
	end
	if self.boss_model then
		self.boss_model:destroy()
		self.boss_model = nil
	end
	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
end

function TimeBossPanel:LoadCallBack()
	self.nodes = {
		"ScrollView/Viewport/BossContent","toggle_group","rewards","bossView/model_con","enter_title/enter_num",
		"wenhao","wenhao/tips","left_tilte1/left_count1","left_tilte2/left_count2","enterbtn",
		"rewards/CrossBossRewardItem","rewards/rankreward","rewards/joinreward","bossView",
		"rewards/attackreward","toggle_group/ToggleItem","ScrollView/Viewport/BossContent/TimeBossItem",
		"killlog","dropBtn","bossInfo","is_care","bossView/valueCon/attack","bossView/valueCon/life",
		"bossView/valueCon/def","bossView/valueCon/dod","bossView/valueCon/heart",
		"bossView/valueCon/hit",
	}
	self:GetChildren(self.nodes)
	self.TimeBossItem_go = self.TimeBossItem.gameObject
	self.CrossBossRewardItem_go = self.CrossBossRewardItem.gameObject
	SetVisible(self.TimeBossItem_go, false)
	SetVisible(self.CrossBossRewardItem_go, false)
	self.ToggleItem = GetToggle(self.ToggleItem)
	self.enter_num = GetText(self.enter_num)
	self.tips = GetText(self.tips)
	self.left_count1 = GetText(self.left_count1)
	self.left_count2 = GetText(self.left_count2)
	self.is_care = GetToggle(self.is_care)
	self.attack = GetText(self.attack)
	self.life = GetText(self.life)
	self.def = GetText(self.def)
	self.dod = GetText(self.dod)
	self.heart = GetText(self.heart)
	self.hit = GetText(self.hit)
	self:AddEvent()
	SetVisible(self.dropBtn, false)
	SetVisible(self.bossView, false)
	SetVisible(self.killlog, false)
	self.tips.text = "Refresh: 14:00/18:00/21:00, Tuesday/Thursday/Saturday"
	TimeBossController.GetInstance():RequestBossList()
	self.max_rank_count = String2Table(Config.db_game["timeboss_rank_times"].val)[1]
	self.max_join_count = String2Table(Config.db_game["timeboss_join_times"].val)[1]
	self:UpdateView()
end

function TimeBossPanel:AddEvent()

	local function call_back(bossid)
		self.select_bossid = bossid
		self:ShowRewards(bossid)
	end
	self.timeboss_events[#self.timeboss_events+1] = self.timeboss_model:AddListener(TimeBossEvent.BossItemClick,call_back)

	local function call_back()
		self.enter_num.text = self.timeboss_model.bosses[self.select_bossid].role
		self.is_care.isOn = self.timeboss_model:IsCare(self.select_bossid)
	end
	self.timeboss_events[#self.timeboss_events+1] = self.timeboss_model:AddListener(TimeBossEvent.BossList, call_back)

	local function call_back(op)
		if op == 1 then
			Dialog.ShowTwo("Tip","Followed, 1 min before the boss respawns, you will receive a notice",nil,nil,nil,nil,nil,nil,"Don't notice me again today", true, nil, self.__cname)
		end
	end
	self.timeboss_events[#self.timeboss_events+1] = self.timeboss_model:AddListener(TimeBossEvent.BossCare, call_back)

	local function call_back(target,x,y)
		
	end
	AddButtonEvent(self.killlog.gameObject,call_back)

	local function call_back(target,x,y)
		SetVisible(self.dropBtn, false)
		SetVisible(self.bossInfo, true)
		SetVisible(self.rewards, true)
		SetVisible(self.bossView, false)
	end
	AddButtonEvent(self.dropBtn.gameObject,call_back)

	local function call_back(target,x,y)
		SetVisible(self.dropBtn, true)
		SetVisible(self.bossInfo, false)
		SetVisible(self.rewards, false)
		SetVisible(self.bossView, true)
	end
	AddButtonEvent(self.bossInfo.gameObject,call_back)

	local function call_back(target,x,y)
		local boss = Config.db_timeboss[self.select_bossid]
		local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
		local can_enter = true
	    if main_role_data then
	    	local buffer1 = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_TIMEBOSS_JOIN_TIRED)
	        local buffer2 = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_TIMEBOSS_RANK_TIRED)
	        local use_count1 = (buffer1 and buffer1.value or 0)
	        local use_count2 = (buffer2 and buffer2.value or 0)
	        local bossdata = self.timeboss_model.bosses[self.select_bossid]
	        if use_count1 >= self.max_join_count and use_count2 >= self.max_rank_count and not bossdata.box then
	        	can_enter = false
	        end
	    end
	    if not can_enter then
	    	return Notify.ShowText("No reward, unable to enter the scene")
	    end
		SceneControler.GetInstance():RequestSceneChange(boss.scene, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, 11101)
	end
	AddButtonEvent(self.enterbtn.gameObject,call_back)

	local function call_back(target, value)
		if value and not self.timeboss_model:IsCare(self.select_bossid) then
			TimeBossController.GetInstance():RequestCare(self.select_bossid, 1, 1)
		end
		if not value and self.timeboss_model:IsCare(self.select_bossid) then
			TimeBossController.GetInstance():RequestCare(self.select_bossid, 2, 1)
		end
	end
	AddValueChange(self.is_care.gameObject, call_back)

	local function call_back(target,x,y)
		ShowHelpTip(HelpConfig.Dungeon.timeboss, true)
	end
	AddButtonEvent(self.wenhao.gameObject,call_back)
end

function TimeBossPanel:SetData(data)
	self.selectedBossid = data
end

function TimeBossPanel:UpdateView()
	local lv = RoleInfoModel:GetInstance():GetMainRoleLevel()
	self.selectedItemIndex = 1
	self.currentFloor = 1
	for k, v in pairs(Config.db_timeboss) do
		self.boss_floors[v.floor_client] = self.boss_floors[v.floor_client] or {}
		table.insert(self.boss_floors[v.floor_client], v)
		if v.lock_lv then
            local lockLv = String2Table(v.lock_lv);
            if #lockLv > 0 then
                if lv >= tonumber(lockLv[1]) and lv <= tonumber(lockLv[2]) and self.selectedBossid == nil then
                    self.selectedItemIndex = i
                    self.currentFloor = v.floor_client
                elseif v.id == self.selectedBossid then
                    self.selectedItemIndex = i
                    self.currentFloor = v.floor_client
                end
            end
        end
	end

	local floors = table.keys(self.boss_floors)
	table.sort(floors)
	self.ToggleItem.gameObject:SetActive(true)
	for i=1, #floors do
		local floor = floors[i]
		local tog = newObject(self.ToggleItem)
		tog.gameObject.name = "ToggleItem_" .. floor
		local labelObj = GetChild(tog, "Label");
        if labelObj then
        	local labelText = GetText(labelObj)
            labelText.text = DungeonModel.Timeboss_Floor[floor]
            SetColor(labelText, 255, 255, 255)
        end
        tog.isOn = false
        tog.transform:SetParent(self.toggle_group.transform)
        SetLocalPosition(tog.transform, 0, 0, 0)
        SetLocalScale(tog.transform, 1, 1, 1)
        AddValueChange(tog.gameObject, handler(self, self.FloorItemClick))
        self.tog_items[i] = tog
	end
	self.ToggleItem.gameObject:SetActive(false)

	self.tog_items[self.currentFloor].isOn = true
	self:SetToggleColor(self.tog_items[self.currentFloor])

	self:UpdateCount()
end

--更新次数
function TimeBossPanel:UpdateCount()
	local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    if main_role_data then
    	local buffer1 = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_TIMEBOSS_JOIN_TIRED)
        local buffer2 = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_TIMEBOSS_RANK_TIRED)

        local use_count1 = (buffer1 and buffer1.value or 0)
        local use_count2 = (buffer2 and buffer2.value or 0)
        local left_count1 = self.max_join_count-use_count1
        left_count1 = (left_count1 < 0 and 0 or left_count1)
        self.left_count1.text = string.format("%s/%s", left_count1, self.max_join_count)
        local left_count2 = self.max_rank_count-use_count2
        left_count2 = (left_count2 < 0 and 0 or left_count2)
        self.left_count2.text = string.format("%s/%s", left_count2, self.max_rank_count)
        self:CheckReddot(left_count1, left_count2)
    end
end

function TimeBossPanel:ShowFloorBosses()
	local bosses = self.boss_floors[self.currentFloor] or {}
    destroyTab(self.items)
    self.items = {}
    self.selectedItemIndex = 1
    local function sort_boss(a, b)
    	return a.id < b.id
    end
    table.sort(bosses, sort_boss)
    for i=1, #bosses do
        local bossTab = bosses[i]

        if bossTab.lock_lv then
            local lockLv = String2Table(bossTab.lock_lv);
            if #lockLv > 0 then
                local lv = RoleInfoModel:GetInstance():GetMainRoleLevel();
                if lv >= tonumber(lockLv[1]) and lv <= tonumber(lockLv[2]) and self.selectedBossid == nil then
                    self.selectedItemIndex = i
                elseif bossTab.id == self.selectedBossid then
                    self.selectedItemIndex = i
                end
            end
        end

        local item = TimeBossItem(self.TimeBossItem_go, self.BossContent)
        item:SetData(bossTab)
        item.gameObject.name = "TimeBossItem_" .. i
        self.items[i] = item
    end

    local rt = self.BossContent:GetComponent("RectTransform");
    rt.sizeDelta = Vector2(rt.sizeDelta.x, #bosses * 103.2);
    rt.anchoredPosition = Vector2(0, (self.selectedItemIndex - 1) * 90.2);

    self.timeboss_model:Brocast(TimeBossEvent.BossItemClick, bosses[self.selectedItemIndex].id)
end

function TimeBossPanel:FloorItemClick(target, flag)
	if flag then
		for i=1, #self.tog_items do
			local labelObj = GetChild(self.tog_items[i], "Label")
            if labelObj then
                local LabelText = GetText(labelObj)
                SetColor(LabelText, 255, 255, 255)
            end
			if self.tog_items[i].gameObject == target then
				self.currentFloor = i
				self:ShowFloorBosses()
				self:SetToggleColor(target)
			end
		end
	end
end

function TimeBossPanel:SetToggleColor(target)
    if target then
        local labelObj = GetChild(target, "Label")
        if labelObj then
            local LabelText = GetText(labelObj)
            SetColor(LabelText, 133, 132, 176)
        end
    end
end

function TimeBossPanel:ShowRewards(bossid)
	local boss = Config.db_timeboss[bossid]
	if not self.reward_items[1] then
		self.reward_items[1] = CrossBossRewardItem(self.CrossBossRewardItem_go, self.rankreward)
	end
	self.reward_items[1]:SetData(String2Table(boss.rank_show)[1])
	if not self.reward_items[2] then
		self.reward_items[2] = CrossBossRewardItem(self.CrossBossRewardItem_go, self.joinreward)
	end
	self.reward_items[2]:SetData(String2Table(boss.join_show)[1])
	if not self.reward_items[3] then
		self.reward_items[3] = CrossBossRewardItem(self.CrossBossRewardItem_go, self.attackreward)
	end
	self.reward_items[3]:SetData(String2Table(boss.shield_show)[1])
	self:ShowBossModel(boss)

	self.is_care.isOn = self.timeboss_model:IsCare(bossid)
	self.enter_num.text = (self.timeboss_model.bosses[bossid] and self.timeboss_model.bosses[bossid].role or 0)
end

function TimeBossPanel:ShowBossModel(boss)
	local monsterTab = Config.db_creep[boss.id];
    local scale = boss.res_ratio
	if self.boss_model then
		self.boss_model:destroy()
	end
	local config = {}
    config.pos = { x = -1968, y = -99, z = 300 }
    config.rotate = { x = 0, y = 135, z = 0 }
    config.scale = { x = scale, y = scale, z = scale}
    config.trans_offset = {x=-47.6, y=-39.6}
    config.trans_x = 950
    config.trans_y = 950
    config.carmera_size = 5
	self.boss_model = UIModelCommonCamera(self.model_con, nil, monsterTab.figure)
	self.boss_model:SetConfig(config)

    local monsterTab = Config.db_creep_attr[boss.id];
    self.attack.text = tostring(monsterTab.att);
    self.life.text = tostring(monsterTab.hpmax);
    self.def.text = tostring(monsterTab.def);
    self.heart.text = tostring(monsterTab.hit);
    self.dod.text = tostring(monsterTab.miss)
end

function TimeBossPanel:CheckReddot(left_count1, left_count2)
	if left_count1 > 0 or left_count2 > 0 then
		if not self.reddot then
			self.reddot = RedDot(self.enterbtn)
			SetLocalPosition(self.reddot.transform, 55, 14, 0)
		end
		SetVisible(self.reddot, true)
	else
		if self.reddot then
			SetVisible(self.reddot, false)
		end
	end
end
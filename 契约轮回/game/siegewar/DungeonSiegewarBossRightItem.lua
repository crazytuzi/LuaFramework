DungeonSiegewarBossRightItem = DungeonSiegewarBossRightItem or class("DungeonSiegewarBossRightItem",BaseItem)
local DungeonSiegewarBossRightItem = DungeonSiegewarBossRightItem

function DungeonSiegewarBossRightItem:ctor(parent_node,layer)
	self.abName = "dungeon"
	self.assetName = "DungeonSiegewarBossRightItem"
	self.layer = layer

	self.model = SiegewarModel:GetInstance()
	DungeonSiegewarBossRightItem.super.Load(self)
	self.item_list = {}
	self.last_time = 0
	self.events = {}
end

function DungeonSiegewarBossRightItem:dctor()
	if self.item_list then
		destroyTab(self.item_list)
		self.item_list = nil
	end

	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end

	if self.schedule_id2 then
		GlobalSchedule:Stop(self.schedule_id2)
		self.schedule_id2 = nil
	end

	GlobalEvent:RemoveTabListener(self.events)
	self.events = nil

	if self.role_event then
		RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.role_event)
		self.role_event = nil
	end
end

function DungeonSiegewarBossRightItem:LoadCallBack()
	self.nodes = {
		"parent/bg","parent/rank_btn", "parent/bg/closebtn","parent/bg/ScrollView/Viewport/Content",
		"parent/bg/ScrollView/Viewport/Content/DungeonWorldBossDamageItem",
		"parent/bg/myrank", "parent","parent/bg/tips","parent/tired/tiredtxt",
		"parent/tipbtn","parent/callbtn","parent/bg/name",
	}
	self:GetChildren(self.nodes)
	self.DungeonWorldBossDamageItem_go = self.DungeonWorldBossDamageItem.gameObject
	SetVisible(self.DungeonWorldBossDamageItem_go, false)
	self.myrank = GetText(self.myrank)
	self.tiredtxt = GetText(self.tiredtxt)
	self.name = GetText(self.name)
	self:AddEvent()

	SetVisible(self.bg, true)
	SetVisible(self.rank_btn, false)
	self.myrank.text = "None"
	self.name.text = "Ranking"

	SetAlignType(self.transform, bit.bor(AlignType.Right, AlignType.Null))

	self.schedule_id2 = GlobalSchedule:Start(handler(self,self.CheckShowDamage), 0.5)
	self.tiredtxt.text = string.format("Fatigue: %s/%s", self.model:GetTired())
end

function DungeonSiegewarBossRightItem:AddEvent()
	local function call_back(target,x,y)
		SetVisible(self.bg, true)
		SetVisible(self.rank_btn, false)
	end
	AddButtonEvent(self.rank_btn.gameObject,call_back)

	local function call_back(target,x,y)
		SetVisible(self.bg, false)
		SetVisible(self.rank_btn, true)
	end
	AddButtonEvent(self.closebtn.gameObject,call_back)

	local function call_back(target,x,y)
		--ShowHelpTip(HelpConfig.siegewar.Help, true)
		lua_panelMgr:GetPanelOrCreate(SiegewarTeachPanel):Open()
	end
	AddButtonEvent(self.tipbtn.gameObject,call_back)

	local function call_back(target,x,y)
		local flag, bossid = self:IsNearByBoss()
		if not flag then
			return Notify.ShowText("Not near by the Boss")
		end
		local cd = ChatModel.channel_cd[enum.CHAT_CHANNEL.CHAT_CHANNEL_WORLD]
		if os.time() - self.last_time < cd then
			return Notify.ShowText(string.format("The chat interval of the world channel is %s", cd))
		end
		self.last_time = os.time()
		local bosscfg = Config.db_siegewar_boss[bossid]
		local scene_id = SceneManager:GetInstance():GetSceneId()
		local scenecfg = Config.db_scene[scene_id]
		local content = string.format("I am challenging %s-%s. Let's make efforts to take this place! Go now", scenecfg.name, bosscfg.name)
		ChatController.GetInstance():RequestSendChat(enum.CHAT_CHANNEL.CHAT_CHANNEL_WORLD, 0, content)
	end
	AddButtonEvent(self.callbtn.gameObject,call_back)

	local function call_back(data)
		self:UpdateRanks(data)
	end
	self.events[#self.events + 1] = GlobalEvent:AddListener(SiegewarEvent.UpdateBossDamageRank, call_back)

	local call_back = function()
        self:SetVisible(false)
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(MainEvent.ShowTopRightIcon, call_back)

    local call_back1 = function()
        self:SetVisible(true)
    end

    self.events[#self.events + 1] = GlobalEvent:AddListener(MainEvent.HideTopRightIcon, call_back1)

    local function call_back()
    	self:destroy()
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.GameReset, call_back)

    local function call_back()
    	self.tiredtxt.text = string.format("Fatigue: %s/%s", self.model:GetTired())
    end
    self.role_event = RoleInfoModel:GetInstance():GetMainRoleData():BindData("buffs", call_back)
end

function DungeonSiegewarBossRightItem:SetData(data)

end

function DungeonSiegewarBossRightItem:RequestRank()
	local flag, bossid = self:IsNearByBoss()
	if flag then
		SiegewarController.GetInstance():RequestDamage(bossid)
	end
end

function DungeonSiegewarBossRightItem:UpdateRanks(data)
	local ranks = data.ranking
	destroyTab(self.item_list)
	self.item_list = {}
	local mysuid = RoleInfoModel:GetInstance():GetRoleValue("suid")
	local my_name = RoleInfoModel:GetInstance():GetMainRoleId()
	local my_guildname = RoleInfoModel:GetInstance():GetRoleValue("gname")
	local my_rank = 0
	for i=1, #ranks do
		local item = DungeonSiegewarBossDamageItem(self.DungeonWorldBossDamageItem_go, self.Content)
		item:SetData(ranks[i])
		self.item_list[i] = item
		if ranks[i].type == 3 then
			if mysuid == ranks[i].id then
				my_rank = ranks[i].rank
			end
		elseif ranks[i].type == 2 then
			if my_guildname == ranks[i].name then
				my_rank = ranks[i].rank
			end
		elseif ranks[i].type == 1 then
			if my_name == ranks[i].name then
				my_rank = ranks[i].rank
			end
		end
	end
	SetVisible(self.tips, #ranks==0)
	if my_rank > 0 then
		self.myrank.text = string.format("%s", my_rank)
	else
		self.myrank.text = "None"
	end
end

function DungeonSiegewarBossRightItem:IsNearByBoss()
	local list = SceneManager.GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP) or {}
	for k, obj in pairs(list) do
		if obj.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP then
    		local bosscfg = Config.db_siegewar_boss[obj.object_info.id]
    		if bosscfg then
    			return true, bosscfg.id
    		end
    	end
	end
	return false
end

function DungeonSiegewarBossRightItem:CheckShowDamage()
	if not self:IsNearByBoss() then
		--SetVisible(self.bg, false)
		--SetVisible(self.rank_btn, true)
		if self.schedule_id then
			GlobalSchedule:Stop(self.schedule_id)
			self.schedule_id = nil
			destroyTab(self.item_list)
			self.item_list = {}
			SetVisible(self.tips, true)
			self.myrank.text = "None"
		end
	else
		if not self.schedule_id then
			self:RequestRank()
			self.schedule_id = GlobalSchedule:Start(handler(self,self.RequestRank), 3)
		end
	end
end
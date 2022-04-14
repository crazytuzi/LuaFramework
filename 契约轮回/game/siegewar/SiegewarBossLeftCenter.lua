SiegewarBossLeftCenter = SiegewarBossLeftCenter or class("SiegewarBossLeftCenter",BaseItem)
local SiegewarBossLeftCenter = SiegewarBossLeftCenter

function SiegewarBossLeftCenter:ctor(parent_node,layer)
	self.abName = "dungeon"
	self.assetName = "SiegewarBossLeftCenter"
	self.layer = layer

	self.events = {}
	self.boss_list = {}
	self.model = SiegewarModel:GetInstance()
	self.last_time = 0
	self.first_enter = true
	self.show = true
	SiegewarBossLeftCenter.super.Load(self)
end

function SiegewarBossLeftCenter:dctor()
	if self.boss_list then
		destroyTab(self.boss_list)
		self.boss_list = nil
	end
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
	end
	if self.countdown then
		self.countdown:destroy()
	end
end

function SiegewarBossLeftCenter:LoadCallBack()
	self.nodes = {
		"contents/ScrollView/Viewport/Content","contents/ScrollView/Viewport/Content/SiegewarSceneBossItem",
		"contents/callbtn","contents/callbtn/countdowntext",
	}
	self:GetChildren(self.nodes)
	self.SiegewarSceneBossItem_go = self.SiegewarSceneBossItem.gameObject
	SetVisible(self.SiegewarSceneBossItem_go, false)
	self.callbtn = GetImage(self.callbtn)
	self.countdowntext = GetText(self.countdowntext)
	self.countdowntext.text = ""
	self:AddEvent()
	
	if not self.show then
        SetVisible(self.gameObject, false)
    end

	local scene_id = SceneManager:GetInstance():GetSceneId()
	SiegewarController.GetInstance():RequestBoss(scene_id)
	AutoFightManager:GetInstance():StartAutoFight()
end

function SiegewarBossLeftCenter:AddEvent()
	local function call_back(data)
		local scene_id = SceneManager:GetInstance():GetSceneId()
		if data.scene ~= scene_id then
			return
		end
		local bosses = self.model:GetBosses(scene_id)
		for i=1, #bosses do
			local item = self.boss_list[i] or SiegewarSceneBossItem(self.SiegewarSceneBossItem_go, self.Content)
			item:SetData(bosses[i])
			self.boss_list[i] = item
		end
		if self.first_enter then
			self.first_enter = false
			if self.model.targetPos then
				local targetX = self.model.targetPos.x
                local targetY = self.model.targetPos.y
                OperationManager.GetInstance():TryMoveToPosition(nil, nil, {x=targetX, y=targetY})
                self.model.targetPos = nil
			else
				if not self.model.select_boss then
					self.model:Brocast(SiegewarEvent.LeftBossClick, bosses[1].info.id)
				else
					self.model:Brocast(SiegewarEvent.LeftBossClick, self.model.select_boss)
					self.model.select_boss = nil
				end
			end
		end
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.UpdateBossList, call_back)

	local function call_back(target,x,y)
		local cd = ChatModel.channel_cd[enum.CHAT_CHANNEL.CHAT_CHANNEL_WORLD]
		if os.time() - self.last_time < cd then
			return Notify.ShowText(string.format("The chat interval of the world channel is %s", cd))
		end
		local flag, bossid = self:IsNearByBoss()
		local roleData = RoleInfoModel.Instance:GetMainRoleData()
        local x, y = SceneManager.GetInstance():GetBlockPos(roleData.coord.x, roleData.coord.y)
        SetGray(self.callbtn, true)
		local function call_back2()
			SetGray(self.callbtn, false)
		end
		self.schedule_id = GlobalSchedule:StartOnce(call_back2, cd)
		if not self.countdown then
			local param = {
				formatText = "%s sec",
				duration = 0.033,
			}
			self.countdown = CountDownText(self.callbtn, param)
			local function end_fun()
				self.countdown:destroy()
				self.countdown = nil
			end
			self.countdown:StartSechudle(os.time()+cd, end_fun)
		end
		if not flag then
			local scene_id = SceneManager:GetInstance():GetSceneId()
			local scenecfg = Config.db_scene[scene_id]
			local content = string.format("I'm challenging %s Boss.Let's make efforts to take this place!<a href=mapPos_%s_%s_%s>Go now</a>", scenecfg.name, scene_id, x, y)
			ChatController.GetInstance():RequestSendChat(enum.CHAT_CHANNEL.CHAT_CHANNEL_WORLD, 0, content)
			return
		end
		self.last_time = os.time()
		local bosscfg = Config.db_siegewar_boss[bossid]
		local scene_id = SceneManager:GetInstance():GetSceneId()
		local scenecfg = Config.db_scene[scene_id]
		local content = string.format("I'm challenging %s %s.Let's make efforts to take this place!<a href=mapPos_%s_%s_%s>Go now</a>", scenecfg.name, bosscfg.name, scene_id, x, y)
		ChatController.GetInstance():RequestSendChat(enum.CHAT_CHANNEL.CHAT_CHANNEL_WORLD, 0, content)
	end
	AddButtonEvent(self.callbtn.gameObject,call_back)
end

function SiegewarBossLeftCenter:SetData(data)

end

function SiegewarBossLeftCenter:IsNearByBoss()
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

function SiegewarBossLeftCenter:SetShow(flag)
    self.show = flag
end
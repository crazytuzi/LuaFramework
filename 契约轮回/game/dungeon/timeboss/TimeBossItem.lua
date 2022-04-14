TimeBossItem = TimeBossItem or class("TimeBossItem",BaseCloneItem)
local TimeBossItem = TimeBossItem

function TimeBossItem:ctor(obj,parent_node,layer)
	TimeBossItem.super.Load(self)
end

function TimeBossItem:dctor()
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end

	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
end

function TimeBossItem:LoadCallBack()
	self.nodes = {
		"selected", "bg", "jieText", "bossName", "timeText", "tipbg", "box", 
	}
	self:GetChildren(self.nodes)
	self.model = TimeBossModel.GetInstance()
	self.bossName = GetText(self.bossName)
	self.bg = GetImage(self.bg)
	self.jieText = GetText(self.jieText)
	self.timeText = GetText(self.timeText)
	self.tipbg = GetImage(self.tipbg)
	self:AddEvent()
end

function TimeBossItem:AddEvent()
	self.events = self.events or {}

	local function call_back(bossid)
		SetVisible(self.selected, self.data.id == bossid)
	end
	self.events[#self.events+1] = self.model:AddListener(TimeBossEvent.BossItemClick, call_back)

	local function call_back()
		local boss = self.model.bosses[self.data.id]
		if boss then
			self:UpdateBossState(boss)
		end
	end
	self.events[#self.events+1] = self.model:AddListener(TimeBossEvent.BossList, call_back)

	local function call_back(target,x,y)
		self.model:Brocast(TimeBossEvent.BossItemClick, self.data.id)
	end
	AddClickEvent(self.gameObject,call_back)
end

function TimeBossItem:SetData(data)
	self.data = data
	self:UpdateView()
end

function TimeBossItem:UpdateView()
	local creep = Config.db_creep[self.data.id]
	self.bossName.text = string.format("%s Level: %s", self.data.name, creep.level)
	self.jieText.text = string.format("T%s", self.data.order)
	lua_resMgr:SetImageTexture(self,self.bg, 'iconasset/icon_boss_image', self.data.boss_res,true)
	local level = RoleInfoModel:GetInstance():GetRoleValue("level")
	local scenecfg = Config.db_scene[self.data.scene]
	local reqs = String2Table(scenecfg.reqs)
	local limit_level = reqs[1][2]
	if level < limit_level then
		SetVisible(self.tipbg, true)
		SetVisible(self.box, false)
	else
		SetVisible(self.tipbg, false)
		SetVisible(self.box, true)
	end
	local boss = self.model.bosses[self.data.id]
	if boss then
		self:UpdateBossState(boss)
	end
end

function TimeBossItem:UpdateBossState(boss)
	local scenecfg = Config.db_scene[self.data.scene]
	local level = RoleInfoModel:GetInstance():GetRoleValue("level")
	local reqs = String2Table(scenecfg.reqs)
	local limit_level = reqs[1][2]
	if level < limit_level then
		SetVisible(self.box, false)
	else
		SetVisible(self.box, boss.box)
	end
	local born = boss.born
	local now = os.time()
	if now >= born then
		SetVisible(self.timeText, false)
	else
		SetVisible(self.timeText, true)
		local d, h = self:GetTimeDate(born)
		local d2 = self:GetTimeDate(now)
		if d == d2 then
			self.timeText.text = string.format("Refresh: %s pts", h)
		else
			self.timeText.text = string.format("Refresh: %s %s pts", d, h)
		end
		
		--[[local function HandleBornTime()
			local now_time = os.time()
			if now_time >= born then
				if self.schedule_id then
					GlobalSchedule:Stop(self.schedule_id)
					self.schedule_id = nil
				end
			else
				local timeTab = TimeManager.GetInstance():GetLastTimeData(now_time, born)
				if timeTab then
					self.timeText.text = string.format("%02d:%02d:%02d", timeTab.hour or 0, timeTab.min or 0, timeTab.sec or 0)
				end
			end
		end
		if not self.schedule_id then
			self.schedule_id = GlobalSchedule:Start(HandleBornTime, 0.033)
		end--]]
	end
end

function TimeBossItem:GetTimeDate(time)
	local d = os.date("%A", time)
	local h = os.date("%H", time)
	local str
	if d == "Tuesday" then
		str = "Tuesday"
	elseif d == "Thursday" then
		str = "Thursday"
	elseif d == "Saturday" then
		str = "Saturday"	
	end
	return str, h
end


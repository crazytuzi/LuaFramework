SiegewarSceneBossItem = SiegewarSceneBossItem or class("SiegewarSceneBossItem",BaseCloneItem)
local SiegewarSceneBossItem = SiegewarSceneBossItem

function SiegewarSceneBossItem:ctor(obj,parent_node,layer)
	SiegewarSceneBossItem.super.Load(self)
end

function SiegewarSceneBossItem:dctor()
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end
end

function SiegewarSceneBossItem:LoadCallBack()
	self.nodes = {
		"boss_name", "status", "statustime", "selected", "order_img"
	}
	self:GetChildren(self.nodes)
	self.model = SiegewarModel.GetInstance()
	self.boss_name = GetText(self.boss_name)
	self.statustime = GetText(self.statustime)
	self.order_img = GetImage(self.order_img)
	SetVisible(self.selected, false)
	self:AddEvent()
end

function SiegewarSceneBossItem:AddEvent()
	self.events = self.events or {}
	local function call_back(target,x,y)
		self.model:Brocast(SiegewarEvent.LeftBossClick, self.data.info.id)
	end
	AddClickEvent(self.gameObject,call_back)

	local function call_back(bossid)
		SetVisible(self.selected, self.data.info.id == bossid)
		if self.data.info.id == bossid then
			self:FindBoss()
		end
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.LeftBossClick, call_back)

	local function call_back(data)
		if data.id == self.data.info.id then
			self.data.info.born = data.born
			self:UpdateStatus()
		end
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.UpdateBoss, call_back)
end

--data:{info,cfg}
function SiegewarSceneBossItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self.boss_name.text = string.format("%s %s point", self.data.cfg.name, self.data.cfg.score)
		self:UpdateStatus()
		local order = self.model:GetBossOrder()
		if order >= 3 then
            SetVisible(self.order_img, true)
            lua_resMgr:SetImageTexture(self,self.order_img, 'dungeon_image', 'order_' .. order ,true)
        else
            SetVisible(self.order_img, false)
        end
	end
end

function SiegewarSceneBossItem:UpdateStatus()
	local now = os.time()
	local born = self.data.info.born
	if now >= born then
		SetVisible(self.statustime, false)
		SetVisible(self.status, true)
	else
		SetVisible(self.status, false)
		SetVisible(self.statustime, true)
		local function HandleBornTime()
			local now_time = os.time()
			if now_time >= born then
				if self.schedule_id then
					GlobalSchedule:Stop(self.schedule_id)
					self.schedule_id = nil
				end
				SetVisible(self.statustime, false)
				SetVisible(self.status, true)
			else
				local timeTab = TimeManager.GetInstance():GetLastTimeData(now_time, born)
				if timeTab then
					self.statustime.text = string.format("%02d:%02d:%02d", timeTab.hour or 0, timeTab.min or 0, timeTab.sec or 0)
				end
			end
		end
		if not self.schedule_id then
			self.schedule_id = GlobalSchedule:Start(HandleBornTime, 0.033)
		end
	end
end

function SiegewarSceneBossItem:FindBoss()
	local coord = String2Table(self.data.cfg.coord)
	local end_pos = {x=coord[1], y=coord[2]}
	local function call_back()
		if not AutoFightManager:GetInstance():GetAutoFightState() then
            GlobalEvent:Brocast(FightEvent.AutoFight)
        end
	end
	OperationManager:GetInstance():TryMoveToPosition(nil, nil, end_pos, call_back)
end
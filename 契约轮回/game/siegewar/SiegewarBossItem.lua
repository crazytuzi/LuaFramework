SiegewarBossItem = SiegewarBossItem or class("SiegewarBossItem",BaseCloneItem)
local SiegewarBossItem = SiegewarBossItem

function SiegewarBossItem:ctor(obj,parent_node,layer)
	SiegewarBossItem.super.Load(self)
end

function SiegewarBossItem:dctor()
	if self.events then
		self.model:RemoveTabListener(self.events)
		self.events = nil
	end
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
end

function SiegewarBossItem:LoadCallBack()
	self.nodes = {
		"bg", "selected", "jieText", "bossName", "timeText", "tipbg/point", "tipbg"
	}
	self:GetChildren(self.nodes)
	self.bg = GetImage(self.bg)
	self.jieText = GetText(self.jieText)
	self.bossName = GetText(self.bossName)
	self.timeText = GetText(self.timeText)
	self.point = GetText(self.point)
	self.tipbg = GetImage(self.tipbg)
	self.model = SiegewarModel.GetInstance()
	self:AddEvent()
end

function SiegewarBossItem:AddEvent()
	self.events = self.events or {}
	local function call_back(bossid)
		SetVisible(self.selected, self.data.id == bossid)
		self.model.select_boss = bossid
	end
	self.events[#self.events+1] = self.model:AddListener(SiegewarEvent.ClickBoss, call_back)

	local function call_back(target,x,y)
		self.model:Brocast(SiegewarEvent.ClickBoss, self.data.id)
	end
	AddClickEvent(self.gameObject,call_back)
end

--data:p_siegewar_boss
function SiegewarBossItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function SiegewarBossItem:UpdateView()
	if self.data then
		local bosscfg = Config.db_siegewar_boss[self.data.id]
		local creep = Config.db_creep[self.data.id]
		self.bossName.text = string.format("%s Level: %s", bosscfg.name, creep.level)
		self.jieText.text = string.format("T%s", self.model:GetBossOrder())
		self.point.text = string.format("%s point", bosscfg.score) 
		local res_name = "citybosspoint_bg"
		if bosscfg.score >= 20 and bosscfg.score < 40 then
			res_name = "citybosspoint_bg2"
		elseif bosscfg.score < 20 then
			res_name = "citybosspoint_bg3"
		end
		lua_resMgr:SetImageTexture(self,self.tipbg, 'siegewar_image', res_name)
		lua_resMgr:SetImageTexture(self,self.bg, 'iconasset/icon_boss_image', bosscfg.boss_res,true)

		local now = os.time()
		local born = self.data.born
		if now >= born then
			SetVisible(self.timeText, false)
		else
			SetVisible(self.timeText, true)
			local function HandleBornTime()
				local now_time = os.time()
				if now_time >= born then
					if self.schedule_id then
						GlobalSchedule:Stop(self.schedule_id)
						self.schedule_id = nil
						SetVisible(self.timeText, false)
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
			end
		end
	end
end
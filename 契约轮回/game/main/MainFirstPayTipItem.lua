MainFirstPayTipItem = MainFirstPayTipItem or class("MainFirstPayTipItem",BaseItem)
local MainFirstPayTipItem = MainFirstPayTipItem

function MainFirstPayTipItem:ctor(parent_node,layer)
	self.abName = "main"
	self.assetName = "MainFirstPayTipItem"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	MainFirstPayTipItem.super.Load(self)
end

function MainFirstPayTipItem:dctor()
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
end

function MainFirstPayTipItem:LoadCallBack()
	self.nodes = {
		"countdown","bg","countdown/countdowntext",
	}
	self:GetChildren(self.nodes)
	self.countdowntext = GetText(self.countdowntext)
	self:AddEvent()
	self:UpdateView()
end

function MainFirstPayTipItem:AddEvent()
	local function call_back(target,x,y)
		 lua_panelMgr:GetPanelOrCreate(FirstPayPanel):Open()
	end
	AddClickEvent(self.bg.gameObject,call_back)
end

function MainFirstPayTipItem:SetData(data)

end

function MainFirstPayTipItem:UpdateView()
	local open_time = RoleInfoModel:GetInstance():GetRoleValue("ctime")
	--[[local now = os.time()
	local param = {
        isShowMin = true,
        duration = 0.033,
    }
	self.countdown_item = CountDownText(self.countdown, param)
	local function end_func()
		SetVisible(self.gameObject, false)
	end

	local function update_call_back()
		-- body
	end
	self.countdown_item:StartSechudle(open_time+1800, end_func, update_call_back)--]]

	local end_time = TimeManager.GetInstance():GetServerTimeMs()+1000
	local index = 0
	local function call_back()
		local now = TimeManager.GetInstance():GetServerTimeMs()
		local now_sec = os.time()
		local now_t = TimeManager.GetInstance():GetLastTimeData(now_sec, open_time+1800)
		if not now_t then
			return
		end
		local interval = end_time - now
		interval = math.ceil((interval <= 0 and 0 or interval)/100)
		local str = string.format("%02d:%02d:%02d", now_t.min or 0, now_t.sec or 0, interval)
		index = index + 1
		if index == 10 then
			end_time = now+1000
			index = 0
		end
		self.countdowntext.text = str
	end
	self.schedule_id = GlobalSchedule:Start(call_back, 0.1)
end
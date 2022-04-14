MainFirstPayTipItem2 = MainFirstPayTipItem2 or class("MainFirstPayTipItem2",BaseItem)
local MainFirstPayTipItem2 = MainFirstPayTipItem2

function MainFirstPayTipItem2:ctor(parent_node,layer)
	self.abName = "main"
	self.assetName = "MainFirstPayTipItem2"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	MainFirstPayTipItem2.super.Load(self)
end

function MainFirstPayTipItem2:dctor()
	if self.countdown_item then
		self.countdown_item:destroy()
		self.countdown_item = nil
	end
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
end

function MainFirstPayTipItem2:LoadCallBack()
	self.nodes = {
		"countdown","bg", "clickbg","countdown/countdowntext",
	}
	self:GetChildren(self.nodes)
	self.countdowntext = GetText(self.countdowntext)
	self:AddEvent()
	self:UpdateView()
end

function MainFirstPayTipItem2:AddEvent()
	local function call_back(target,x,y)
		 lua_panelMgr:GetPanelOrCreate(FirstPayPanel):Open()
	end
	AddClickEvent(self.clickbg.gameObject,call_back)
end

function MainFirstPayTipItem2:SetData(data)

end

function MainFirstPayTipItem2:UpdateView()
	--[[if not self.countdown_item then
		local now = os.time()
		local param = {
	        isShowMin = true,
	        duration = 0.033,
	    }
		self.countdown_item = CountDownText(self.countdown, param)
		local function call_back()
			self:destroy()
		end
		self.countdown_item:StartSechudle(now+1800, call_back)
	end
	local function end_func()
		SetVisible(self.gameObject, false)
	end
	GlobalSchedule:StartOnce(end_func, 20)--]]

	local open_time = RoleInfoModel:GetInstance():GetRoleValue("ctime")

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

		--剩余10分钟时和剩余3分钟时分别弹出一次首充提示界面
		if now_t.min == 10 and now_t.sec == 0 and index == 0 then
			GlobalEvent:Brocast(FirstPayEvent.OpenFirstPayTipPanel,10)
		end

		if now_t.min == 3 and now_t.sec == 0 and index == 0 then
			GlobalEvent:Brocast(FirstPayEvent.OpenFirstPayTipPanel,3)
		end

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
---
--- Created by  Administrator
--- DateTime: 2019/8/1 19:38
---
PeakArenaReadyPanel = PeakArenaReadyPanel or class("PeakArenaReadyPanel", BasePanel)
local this = PeakArenaReadyPanel

function PeakArenaReadyPanel:ctor(parent_node, parent_panel)
	self.abName = "peakArena"
	self.assetName = "PeakArenaReadyPanel"
	self.image_ab = "peakArena_image";
	self.layer = "UI"
	self.panelType = 0
	self.use_background = true
	self.events = {}
	self.model = PeakArenaModel:GetInstance()
end

function PeakArenaReadyPanel:dctor()
    self.model:RemoveTabListener(self.events)
	if self.schedule then
		GlobalSchedule:Stop(self.schedule);
	end
	self.schedule = nil;
end

function PeakArenaReadyPanel:LoadCallBack()
    self.nodes = {
		"readyTex","btn","time",
    }
    self:GetChildren(self.nodes)
	self.time = GetText(self.time)
	self.time.text = 60
    self:InitUI()
    self:AddEvent()
end

function PeakArenaReadyPanel:InitUI()

end

function PeakArenaReadyPanel:AddEvent()
	local function callBack() --取消匹配
		PeakArenaController:GetInstance():RequesMatchCancel()
	end
	AddClickEvent(self.btn.gameObject,callBack)
	self.startTime = 60
	self.schedule = GlobalSchedule:Start(handler(self, self.CountDown), 1, -1);
	self.events[#self.events +  1] = self.model:AddListener(PeakArenaEvent.MatchCancel,handler(self,self.PanelClose))
	self.events[#self.events +  1] = self.model:AddListener(PeakArenaEvent.MatchSucc,handler(self,self.PanelClose))
end

function PeakArenaReadyPanel:PanelClose()
	if self.schedule then
		GlobalSchedule:Stop(self.schedule);
	end
	self.schedule = nil;
	self:Close()
end

function PeakArenaReadyPanel:CountDown()
	self.startTime = self.startTime - 1
	if self.startTime <= 0 then
		PeakArenaController:GetInstance():RequesMatchCancel()
		if self.schedule then
			GlobalSchedule:Stop(self.schedule);
		end
		self.schedule = nil;
		Notify.ShowText("Match timed out")
		self:Close()
		return
	end
	self.time.text = self.startTime
end
DailyTaskPanel =BaseClass(CommonBackGround)

function DailyTaskPanel:__init()
	self.id = "DailyTaskPanel"
	self.showBtnClose = true
	self.openTopUI = false
	self.openResources = {}
	self:SetTitle("悬赏任务")
	self.bgUrl = "bg_big1"
	VipController:GetInstance():C_GetPlayerVip()       --发送获取玩家vip信息请求
end

function DailyTaskPanel:__delete()
	if self.dailyTaskContentUI then
		self.dailyTaskContentUI:Destroy()
	end

	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
end

function DailyTaskPanel:Layout()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function DailyTaskPanel:InitData()

end

function DailyTaskPanel:InitUI()
	self.dailyTaskContentUI = nil
	self:InitTaskContentUI()
end

function DailyTaskPanel:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.SynDailyTaskList, function()
		self:RefershContentUI()
	end)
	-- self.handler1 = GlobalDispatcher:AddEventListener(EventName.VIPLV_CHANGE, function()   --vip等级变化刷新每日次数上限
	-- 	self:RefershContentUI()
	-- end)
	-- self.handler2 = GlobalDispatcher:AddEventListener(EventName.GETVIPINFO_CHANGE, function(lv)   --登陆获取vip信息刷新每日次数上限
	-- 	if lv > 0 then
	-- 		local vipID = "vip"..lv
	-- 		local addNumCfgData = GetCfgData("vipPrivilege"):Get(3)[vipID]
	-- 		DailyTaskConst.FreeRefershNum = 3 + addNumCfgData
	-- 		--self:RefershContentUI()
	-- 	end
	-- end)
end

function DailyTaskPanel:InitTaskContentUI()
	if self.dailyTaskContentUI == nil then
		self.dailyTaskContentUI = DailyTaskContent.New()
		self.dailyTaskContentUI:SetXY(140, 108)
		self.container:AddChild(self.dailyTaskContentUI.ui)
	end
	self.dailyTaskContentUI:SetVisible(true)
	self:RefershContentUI()
end

function DailyTaskPanel:RefershContentUI()
	if self.dailyTaskContentUI then
		self.dailyTaskContentUI:SetUI()
	end
end
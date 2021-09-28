RegistModules("Activity/ActivityConst")
RegistModules("Activity/ActivityModel")
RegistModules("Activity/ActivityView")

RegistModules("Activity/Vo/ActivityDynamicVo") 

RegistModules("Activity/View/WeekCellInfoPanel") 
RegistModules("Activity/View/WeekItemCell") 
RegistModules("Activity/View/WeekItem")
RegistModules("Activity/View/WeekTabBtn")
RegistModules("Activity/View/WeekTop") 
RegistModules("Activity/View/ActivityItem") 
RegistModules("Activity/View/DayActivityPanel")
RegistModules("Activity/View/WeekActivityPanel")

ActivityController =BaseClass(LuaController)

function ActivityController:GetInstance()
	if ActivityController.inst == nil then
		ActivityController.inst = ActivityController.New()
	end
	return ActivityController.inst
end

function ActivityController:__init()
	self.model = ActivityModel:GetInstance()
	self.view = nil

	self:InitEvent()
	self:RegistProto()

	self.getDataSuccess = false

	self:C_GetActivityList()
	self.model:SetShowDayActivityPanelFlag(false)
end

function ActivityController:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then
			self.model:Reset()
		end
	end)
end

function ActivityController:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
end

-- 协议注册
function ActivityController:RegistProto()
	self:RegistProtocal("S_GetActivityList") --活动列表
end

function ActivityController:S_GetActivityList(buff)
	local msg = self:ParseMsg(weekactivity_pb.S_GetActivityList(), buff)
	self.model:ParseSynActivityData(msg)

	if not self.view then
		self.view = ActivityView.New()
	end

	if self.model:GetShowDayActivityPanelFlag() then
		self.view:OpenDayActivity()
	end
end

function ActivityController:C_GetActivityList()
	local msg = weekactivity_pb.C_GetActivityList()
	self:SendMsg("C_GetActivityList", msg)
end

function ActivityController:OpenDayActivityPanel()
	self:C_GetActivityList()
	self.model:SetShowDayActivityPanelFlag(true)
end

function ActivityController:Close()
	if self.view then 
		self.view:Close()
	end
end

function ActivityController:__delete()
	self:CleanEvent()
	if self.view then
		self.view:Destroy()
		self.view = nil
	end

	if self.model then
		self.model:Destroy()
		self.model = nil
	end
	ActivityController.inst = nil
end
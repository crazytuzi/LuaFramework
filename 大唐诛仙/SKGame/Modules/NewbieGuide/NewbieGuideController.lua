RegistModules("NewbieGuide/View/NewbieGuidePanel")
RegistModules("NewbieGuide/Vo/NewBieGuideVo")
RegistModules("NewbieGuide/NewbieGuideConst")
RegistModules("NewbieGuide/NewbieGuideModel")
RegistModules("NewbieGuide/NewbieGuideView")

NewbieGuideController = BaseClass(LuaController)

function NewbieGuideController:__init()
	self:InitData()
	self:InitEvent()
end

function NewbieGuideController:__delete()
	self:CleanData()
	self:CleanEvent()
	NewbieGuideController.inst = nil
end

function NewbieGuideController:GetInstance()
	if NewbieGuideController.inst == nil then
		NewbieGuideController.inst = NewbieGuideController.New()
	end
	return NewbieGuideController.inst
end

function NewbieGuideController:InitData()
	self.model = NewbieGuideModel:GetInstance()
	self.view = NewbieGuideView.New()
end

function NewbieGuideController:CleanData()
	if self.model then
		self.model:Destroy()
		self.model = nil
	end

	if self.view then
		self.view:Destroy()
		self.view = nil
	end
end

function NewbieGuideController:InitEvent()
	local function InitGuideList()
		self:SetData()
	end
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.InitTaskList , InitGuideList)

	local function UpdateGuideList()
		self:UpdateData()
	end
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.UpdateTaskList , UpdateGuideList)

	local function HandleStartNewbieGuide(guideTaskId)
		self:StartNewbieGuide(guideTaskId)
	end
	self.handler2 = GlobalDispatcher:AddEventListener(EventName.StartNewbieGuide , HandleStartNewbieGuide)

	local function HandleEndNewbieGuide(guideTaskId)
		self:EndNewbieGuide(guideTaskId)
	end
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.EndNewbieGuide , HandleEndNewbieGuide)

	local function HandleFinishGuideStep()
		self:HandleFinishGuideStep()
	end
	self.handler4 = GlobalDispatcher:AddEventListener(EventName.FinishNewbieGuideStep , HandleFinishGuideStep)

	local function HandleMainRoleDie()
		--玩家死亡,结束当前引导
		self:EndCurNewbieGuide()
	end
	self.handler5 = GlobalDispatcher:AddEventListener(EventName.MAINROLE_DIE , HandleMainRoleDie)
	self.handler6 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then
			self.model:Reset()
		end
	end)
end

function NewbieGuideController:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.handler4)
	GlobalDispatcher:RemoveEventListener(self.handler5)
	GlobalDispatcher:RemoveEventListener(self.handler6)
end

function NewbieGuideController:SetData()
	self.model:SetAllGuideData()
end

function NewbieGuideController:UpdateData()
	self.model:UpdateAllGuideData()
end

function NewbieGuideController:StartNewbieGuide(guideTaskId)
	if guideTaskId then
		local guideId = TaskModel:GetInstance():GetGuideIDByTaskId(guideTaskId)
		if guideId ~= 0 then
			if self.model:IsNewbieGuideRunning() then --当前只能有一个引导处于运行状态
				return
			end

			local guideDataVo = self.model:GetGuideDataByGuideId(guideId)
			if not TableIsEmpty(guideDataVo) then
				if guideDataVo:GetExecCnt() > 0 then
					return
				end
			end
			self.model:SetCurGuideData(guideTaskId)
			self.model:CleanCurGuideStep()
			if guideId ~= 0 then
				local isNeed , uiid = self.model:IsNeedSpecialHandling(guideId)
				if isNeed then
					self.model:DoSpecialHandling(guideId)
				else
					self.model:SetCurGuideStep()
				end

				if guideDataVo:GetExecCnt() == 0 then
					self.model:AddGuideExecCnt(guideId)
					self.view:StartNewbieGuide()
				end

			end
		end
	end
end

function NewbieGuideController:EndNewbieGuide(guideTaskId)
	if guideTaskId then
		if self.model:IsCurGuide(guideTaskId) then
			self.model:CleanCurGuideData()
			self.model:CleanCurGuideStep()
			self.view:EndNewbieGuide()
		end
	end
end

function NewbieGuideController:OpenNewbieGuidePanel()
	if self.view then
		seif.view:OpenNewbieGuidePanel()
	end		
end

function NewbieGuideController:HandleFinishGuideStep()
	self.model:SetCurGuideStep()
	if self.model:IsCurGuideStepEnd() then
		local curGuideTaskId = self.model:GetCurGuideTaskId()
		self:EndNewbieGuide(curGuideTaskId)
	else
		self.model:DispatchEvent(NewbieGuideConst.RefershEvent)
	end
end

--重新开启当前引导
function NewbieGuideController:ReStartCurGuide()
	self.model:CleanCurGuideStep()
	self.model:SetCurGuideStep()
	self.model:DispatchEvent(NewbieGuideConst.RefershEvent)
end

function NewbieGuideController:EndCurNewbieGuide()
	local guideId = self.model:GetCurGuideTaskId()
	if guideId ~= 0 then
		self:EndNewbieGuide(guideId)
	end
end
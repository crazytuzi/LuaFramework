local CScheduleBox = class("CScheduleBox", CBox)

function CScheduleBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Texture = self:NewUI(1, CTexture)
	self.m_DescLabel = self:NewUI(2, CLabel)
	self.m_FinishSpr = self:NewUI(3, CSprite)
	self.m_DayTaskSprite = self:NewUI(4, CSprite)
	self.m_CiShuLabel = self:NewUI(5, CLabel)
	self.m_HuoYueLabel = self:NewUI(6, CLabel)
	
	self.m_CallBack = nil
	self:InitContent()
end

function CScheduleBox.InitContent(self)
	self.m_FinishSpr:SetActive(false)
	self.m_DescLabel:SetText("")
	self:AddUIEvent("click", callback(self,"OnClick"))
end

function CScheduleBox.OnClick(self, obj)
	self:CheckSaveLastSchedule()
	--if self.m_Schedule:CheckGrade() or self.m_Schedule:CheckOpenDay() or self.m_Schedule:CheckOpenWeek() then
	--	g_NotifyCtrl:FloatMsg(self.m_Schedule:GetDesc())
	--else
		if self.m_CallBack then
			self.m_CallBack(self)
		end
	--end
end

function CScheduleBox.CheckSaveLastSchedule(self)
	local oView = CScheduleMainView:GetView()
	if oView then
		local oPage = oView.m_ScheduleMaoXianPage
		if oPage then
			if oPage.m_CurSubTag then
				local iRightTag = oPage.m_CurSubTag.m_TagType
				local iTopTag = oPage.m_CurTag.m_TagType
				if iRightTag == define.Schedule.SubTag.Richang then
					g_ScheduleCtrl:SaveLastSchedule(iRightTag, iTopTag, self.m_ID)
				elseif iRightTag == define.Schedule.SubTag.Xianshi then
					g_ScheduleCtrl:SaveLastSchedule(iRightTag, nil, self.m_ID)
				elseif iRightTag == define.Schedule.SubTag.Yugao then
					g_ScheduleCtrl:SaveLastSchedule()
				end
			end
		end
	end
end

function CScheduleBox.SetCallBack(self, cb)
	self.m_CallBack = cb
end

function CScheduleBox.SetScheduleData(self, dSchedule)
	self.m_Schedule = dSchedule
	self.m_ID = dSchedule:GetValue("id")
	self:Refresh()
end

function CScheduleBox.Refresh(self)
	self:RefreshTexture()
	self:RefreshDescLabel()
	self:RefreshDayTask()
	self:RefreshFinishSpr()
end

function CScheduleBox.RefreshTexture(self)
	local path = string.format("Texture/Schedule/bg_schedule_%d.png", self.m_ID)
	if path == nil or self.m_Texture.m_LoadingPath == path then
		return
	end
	local function cb() end
	self.m_Texture:LoadPath(path, cb)
end

function CScheduleBox.RefreshDescLabel(self)
	if self.m_ID == define.Schedule.ID.Terrawar then
		if not self.m_DescTimer then		
			self.m_DescTimer = Utils.AddTimer(function ()
				if Utils.IsNil(self) then
					return false
				end
				self.m_DescLabel:SetText(self.m_Schedule:GetDesc())
				return true
			end, 1, 0)
		end
	else
		self.m_DescLabel:SetText(self.m_Schedule:GetDesc())
	end
	self.m_Texture:SetGrey(self.m_Schedule:CheckGrey())
end

function CScheduleBox.RefreshDayTask(self)
	if table.index(g_ScheduleCtrl.m_DayTask, self.m_ID) then
		if self.m_Schedule:GetValue("finished") then
			self.m_DayTaskSprite:SetActive(false)
		else
			self.m_DayTaskSprite:SetActive(true)
			self.m_CiShuLabel:SetText(string.format("参加%d次", self.m_Schedule:GetValue("maxtimes")))
			self.m_HuoYueLabel:SetText(string.format("活跃度+%d", self.m_Schedule:GetValue("maxactive")))
		end
	else
		self.m_DayTaskSprite:SetActive(false)
	end
end

function CScheduleBox.RefreshFinishSpr(self)
	--可以显示完成的日程
	if table.index(CSchedule.NeedShowFinishSpr, self.m_ID) then
		self.m_FinishSpr:SetActive(self.m_Schedule:GetSort() == 4)
	else
		self.m_FinishSpr:SetActive(false)
	end
end

return CScheduleBox
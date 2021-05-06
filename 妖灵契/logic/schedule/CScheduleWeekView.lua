local CScheduleWeekView = class("CScheduleWeekView", CViewBase)

function CScheduleWeekView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Schedule/ScheduleWeekView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CScheduleWeekView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_GridBox = self:NewUI(3, CBox)
	self.m_XuanZhongSpr = self:NewUI(4, CSprite)
	self.m_WDayBox = self:NewUI(5, CBox)
	self.m_XuanZhongSpr:SetActive(false)
	self:InitContent()
end

function CScheduleWeekView.InitContent(self)
	self.m_WDayList = {}
	self.m_GridBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self:InitWDayList()
	self:InitGrid()
end

function CScheduleWeekView.InitWDayList(self)
	for i=1,7 do
		self.m_WDayList[i] = self.m_WDayBox:NewUI(i, CLabel)
	end
	local tDate = os.date("*t", g_TimeCtrl:GetTimeS())
	local iCurWeek = tonumber(g_TimeCtrl:GetTimeWeek())
	if iCurWeek == 0 then
		iCurWeek = 7
	end	
	local oLabel = self.m_WDayList[iCurWeek]
	self.m_XuanZhongSpr:SetParent(oLabel.m_Transform)
	self.m_XuanZhongSpr:SetLocalPos(Vector3.New(0, -35, 0))
	self.m_XuanZhongSpr:SetActive(true)
end

function CScheduleWeekView.InitGrid(self)
	local lData = data.scheduledata.WEEK
	for i,v in ipairs(lData) do
		local oBox = self.m_GridBox:Clone()
		oBox.m_Grid = oBox:NewUI(1, CGrid)
		oBox.m_TimeBox = oBox:NewUI(2, CBox)
		oBox.m_TimeBox.m_Label = oBox.m_TimeBox:NewUI(2, CLabel)
		oBox.m_TimeBox.m_Label:SetText(v.time)
		oBox.m_ScheuldeBoxs = {}
		for i=1,7 do
			oBox.m_ScheuldeBoxs[i] = oBox:NewUI(i+2, CBox)
			oBox.m_ScheuldeBoxs[i].m_Label = oBox.m_ScheuldeBoxs[i]:NewUI(2, CLabel)
			local key = "week"..i
			oBox.m_ScheuldeBoxs[i].m_ScheduleID = v[key]
			local txt = ""
			if oBox.m_ScheuldeBoxs[i].m_ScheduleID and oBox.m_ScheuldeBoxs[i].m_ScheduleID > 0 then
				txt = data.scheduledata.SCHEDULE[oBox.m_ScheuldeBoxs[i].m_ScheduleID].name
			end
			oBox.m_ScheuldeBoxs[i].m_Label:SetText(txt)
			oBox.m_ScheuldeBoxs[i]:AddUIEvent("click", callback(self, "OnSchedule"))
		end
		oBox:SetActive(true)
		self.m_Grid:AddChild(oBox)
	end
	self.m_Grid:Reposition()
end

function CScheduleWeekView.OnSchedule(self, oBox)
	if oBox.m_ScheduleID and oBox.m_ScheduleID > 0 then
		CScheduleTipsView:ShowView(function (oView)
			oView:SetScheduleID(oBox.m_ScheduleID)
		end)
	end
end

return CScheduleWeekView
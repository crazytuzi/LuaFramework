local CMonsterAtkCityInfoPart = class("CMonsterAtkCityInfoPart", CBox)

function CMonsterAtkCityInfoPart.ctor(self, obj)
	CBox.ctor(self, obj)
	--self.m_MainBtn = self:NewUI(1, CButton)
	self.m_DWidget = self:NewUI(2, CWidget)
	self.m_DHideBtn = self:NewUI(3, CButton)
	self.m_DPlayerRankBox = self:NewUI(4, CBox)
	self.m_DPlayerRankBox.m_RankLabel = self.m_DPlayerRankBox:NewUI(1, CLabel)
	self.m_DPlayerRankBox.m_PointLabel = self.m_DPlayerRankBox:NewUI(2, CLabel)	
	self.m_DWrapContent = self:NewUI(5, CWrapContent)
	self.m_DRankBox = self:NewUI(6, CBox)
	self.m_DTimeLabel = self:NewUI(7, CLabel)
	self.m_XHideBtn = self:NewUI(8, CButton)
	self.m_XPlayerRankBox = self:NewUI(9, CBox)
	self.m_XPlayerRankBox.m_PointLabel = self.m_XPlayerRankBox:NewUI(2, CLabel)	
	self.m_XTimeLabel = self:NewUI(10, CLabel)
	self.m_XWaveLabel = self:NewUI(11, CLabel)
	self.m_XWidget = self:NewUI(12, CWidget)
	
	self:InitContent()
end

function CMonsterAtkCityInfoPart.InitContent(self)
	self.m_DRankBox:SetActive(false)
	--self.m_MainBtn:AddUIEvent("click", callback(self, "OnMainBtn"))
	self.m_DHideBtn:AddUIEvent("click", callback(self, "ShowXWidget", true))
	self.m_XHideBtn:AddUIEvent("click", callback(self, "ShowDWidget", true))
	g_MonsterAtkCityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMonsterAtkCityEvnet"))
	self:InitDWrapContent()
	self:ShowXWidget(true)
	--self:ShowDWidget(false)
	self:RefreshLeftTime()
end

function CMonsterAtkCityInfoPart.SetActive(self, bAct)
	if bAct then
		if self.m_XWidget:GetActive() then
			self:ShowXWidget(true)
		elseif self.m_DWidget:GetActive() then
			self:ShowDWidget(true)
		end
	end
	CBox.SetActive(self, bAct)
end

function CMonsterAtkCityInfoPart.InitDWrapContent(self)
	self.m_DWrapContent:SetCloneChild(self.m_DRankBox, 
		function(oBox)
			oBox.m_RankLabel = oBox:NewUI(1, CLabel)
			oBox.m_NameLabel = oBox:NewUI(2, CLabel)
			oBox.m_ScoreLabel = oBox:NewUI(3, CLabel)
			return oBox
		end)
	self.m_DWrapContent:SetRefreshFunc(function(oBox, dData)
		if dData then
			oBox.m_PID = dData.pid
			oBox.m_Name = dData.name
			oBox.m_Rank = dData.rank or 0
			oBox.m_Point = dData.point
			if oBox.m_Rank > 0 and oBox.m_Rank <= 50 then
				oBox.m_RankLabel:SetText(tostring(oBox.m_Rank))
			else
				oBox.m_RankLabel:SetText("榜外")
			end
			oBox.m_NameLabel:SetText(oBox.m_Name)
			oBox.m_ScoreLabel:SetText(oBox.m_Point)
			oBox:SetActive(true)
		else
			oBox:SetActive(false)
		end
	end)
end

function CMonsterAtkCityInfoPart.OnMonsterAtkCityEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.MonsterAtkCity.Event.Rank then
		if oCtrl.m_EventData["type"] == define.MonsterAtkCity.RankType.InfoPart then
			self:RefreshDWidget(oCtrl.m_EventData["list"])
		end
	elseif oCtrl.m_EventID == define.MonsterAtkCity.Event.MyRank then
		self:RefreshXWidget()
		self:RefreshDWidget()
	elseif oCtrl.m_EventID == define.MonsterAtkCity.Event.CityDefend then
		self:RefreshLeftTime()
	elseif oCtrl.m_EventID == define.MonsterAtkCity.Event.Open then
		if not g_MonsterAtkCityCtrl:IsOpen() then
			self.m_DPlayerRankBox.m_PointLabel:SetText("0")
			self.m_XPlayerRankBox.m_PointLabel:SetText("0")
		end
		self:RefreshLeftTime()
	elseif oCtrl.m_EventID == define.MonsterAtkCity.Event.RefreshWave then
		self:RefreshLeftTime()
	end
end

function CMonsterAtkCityInfoPart.OnMainBtn(self, obj)
	if self.m_DWidget:GetActive() then
		self:ShowDWidget(false)
	elseif self.m_XWidget:GetActive() then
		self:ShowXWidget(false)
	else
		self:ShowXWidget(true)
	end
end

function CMonsterAtkCityInfoPart.ShowDWidget(self, bShow)
	if bShow then
		self:ShowXWidget(false)
		netrank.C2GSGetRankMsattack(define.MonsterAtkCity.RankType.InfoPart, 1, 50)
	end
	self.m_DWidget:SetActive(bShow)
end

function CMonsterAtkCityInfoPart.ShowXWidget(self, bShow)
	if bShow then
		self:ShowDWidget(false)
		self:RefreshXWidget()
	end
	self.m_XWidget:SetActive(bShow)
end

function CMonsterAtkCityInfoPart.RefreshDWidget(self, list)
	local oBox = self.m_DPlayerRankBox
	local dData = g_MonsterAtkCityCtrl:GetMyRankInfo()
	oBox.m_Point = dData.point or 0
	oBox.m_Rank = dData.rank or 0
	oBox.m_PointLabel:SetText(oBox.m_Point)
	if oBox.m_Rank > 0 and oBox.m_Rank <= 50 then
		oBox.m_RankLabel:SetText(tostring(oBox.m_Rank))
	else
		oBox.m_RankLabel:SetText("榜外")
	end
	if list then
		self.m_DWrapContent:SetData(list, true)
	end
end

function CMonsterAtkCityInfoPart.RefreshXWidget(self)
	local oBox = self.m_XPlayerRankBox
	local dData = g_MonsterAtkCityCtrl:GetMyRankInfo()
	oBox.m_Point = dData.point or 0
	oBox.m_PointLabel:SetText(oBox.m_Point)
end

function CMonsterAtkCityInfoPart.RefreshLeftTime(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	local time = g_MonsterAtkCityCtrl:GetNextTime()
	time = time - g_TimeCtrl:GetTimeS()
	local cur, max = g_MonsterAtkCityCtrl:GetWave()
	self.m_XWaveLabel:SetText(string.format("怪物波数：%d/%d", cur, max))
	local txtD = "怪物波数："..cur.."/"..max
	local txtX = "（下波时间:%s）"
	local function countdown()
		if Utils.IsNil(self) then
			return 
		end
		if time >= 0 and cur < max then
			self.m_DTimeLabel:SetText(string.format(txtD..txtX, g_TimeCtrl:GetLeftTime(time, true)))
			self.m_XTimeLabel:SetText(string.format(txtX, g_TimeCtrl:GetLeftTime(time, true)))
			time = time - 1
			return true
		else
			self.m_DTimeLabel:SetText(txtD)
			self.m_XTimeLabel:SetText("")
		end
	end
	self.m_Timer = Utils.AddTimer(countdown, 1, 0)
end

return CMonsterAtkCityInfoPart
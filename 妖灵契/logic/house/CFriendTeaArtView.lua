local CFriendTeaArtView = class("CFriendTeaArtView", CViewBase)

function CFriendTeaArtView.ctor(self, cb)
	CViewBase.ctor(self, "UI/House/FriendTeaArtView.prefab", cb)
	self.m_ExtendClose = "Black"
	-- self.m_GroupName = "House"
end

function CFriendTeaArtView.OnCreateView(self)
	self.m_CookingPart = self:NewUI(1, CBox)
	self.m_NotCookingPart = self:NewUI(2, CBox)
	self.m_DeskPos = 4

	self:InitContent()
end

function CFriendTeaArtView.InitContent(self)
	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))
	self:InitCookingPart()
	self:InitNotCookingPart()
end

function CFriendTeaArtView.InitCookingPart(self)
	local oCooking = self.m_CookingPart
	oCooking.m_CloseBtn = oCooking:NewUI(1, CButton)
	oCooking.m_ItemSprite = oCooking:NewUI(2, CSprite)
	oCooking.m_Slider = oCooking:NewUI(3, CSlider)
	oCooking.m_StateLabel = oCooking:NewUI(4, CLabel)
	oCooking.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))

	function oCooking.SetData(self, dInfo)
		if dInfo.frd_pid == g_AttrCtrl.pid then
			oCooking.m_StateLabel:SetText("完成后礼物自动进入自己的礼物仓库")
		else
			oCooking.m_StateLabel:SetText("该工作台已被占用")
		end
	end

	function oCooking.Refresh(self, iLeft, iMax)
		if iLeft > 0 then
			local sText = string.format("%02d:%02d:%02d", math.modf(iLeft / 3600), math.modf((iLeft % 3600) /60), (iLeft % 60))
			self.m_Slider:SetSliderText(sText)
			if iLeft > iMax then
				self.m_Slider:SetValue(0)
			else
				self.m_Slider:SetValue((iMax - iLeft)/iMax)
			end
		else
			self.m_Slider:SetValue(0)
			self.m_Slider:SetSliderText("00:00:00")
		end
	end
end

function CFriendTeaArtView.InitNotCookingPart(self)
	local oBox = self.m_NotCookingPart
	oBox.m_CloseBtn = oBox:NewUI(1, CButton)
	oBox.m_CookBtn = oBox:NewUI(2, CButton)
	oBox.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	oBox.m_CookBtn:AddUIEvent("click", callback(self, "OnCook"))
end

function CFriendTeaArtView.OnCook(self)
	nethouse.C2GSUseFriendWorkDesk(self.m_OwnerPid)
end

function CFriendTeaArtView.OnHouseEvent(self, oCtrl)
	if oCtrl.m_EventID == define.House.Event.WorkDeskRefresh then
		if oCtrl.m_EventData == self.m_DeskPos then
			self:RefeshDesk()
		end
	end
end
function CFriendTeaArtView.RefeshDesk(self)
	self.m_Info = g_HouseCtrl:GetWorkDeskInfo(self.m_DeskPos, self.m_OwnerPid)
	local iLeft = self:GetLeftWorkTime()
	self.m_NotCookingPart:SetActive(self.m_Info.status ~= 2)
	self.m_CookingPart:SetActive(self.m_Info.status == 2)
	if self.m_Info.status == 2 then
		self.m_CookingPart:SetData(self.m_Info)
		local iMax = data.housedata.HouseDefine.talent_show_time.value
		if iLeft > 0 then
			if not self.m_Timer then
				self.m_Timer = Utils.AddTimer(callback(self, "RefreshTime"), 0.5, 0)
			end
		else
			self.m_CookingPart:Refresh(iMax, iMax)
		end
	end
end

function CFriendTeaArtView.SetOwner(self, pid)
	self.m_OwnerPid = pid
	self:RefeshDesk()
end

function CFriendTeaArtView.RefreshTime(self)
	local iLeft = self:GetLeftWorkTime()
	local iMax = data.housedata.HouseDefine.talent_show_time.value
	self.m_CookingPart:Refresh(iLeft, iMax)
	if iLeft > 0 then
		return true
	else
		self.m_Timer = nil
		return false
	end
end

function CFriendTeaArtView.GetLeftWorkTime(self)
	local iEnd = self.m_Info.create_time + self.m_Info.talent_time
	local iLeft = iEnd - g_TimeCtrl:GetTimeS()
	return iLeft
end


return CFriendTeaArtView
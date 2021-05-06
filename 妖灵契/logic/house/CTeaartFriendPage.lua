local CTeaartFriendPage = class("CTeaartFriendPage", CPageBase)

function CTeaartFriendPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTeaartFriendPage.OnInitPage(self)
	self.m_CookingPart = self:NewUI(1, CBox)
	self.m_NotCookingPart = self:NewUI(2, CBox)
	self.m_DeskPos = 4
	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))

	self:InitCookingPart()
	self:InitNotCookingPart()
	self:RefeshDesk()
end

function CTeaartFriendPage.InitCookingPart(self)
	local oCooking = self.m_CookingPart
	oCooking.m_CloseBtn = oCooking:NewUI(1, CButton)
	oCooking.m_ItemSprite = oCooking:NewUI(2, CSprite)
	oCooking.m_Slider = oCooking:NewUI(3, CSlider)
	oCooking.m_StateLabel = oCooking:NewUI(4, CLabel)
	oCooking.m_SpeedUpBtn = oCooking:NewUI(5, CButton)
	oCooking.m_SpeedUpBtn:AddUIEvent("click", callback(self, "OnSpeedUp"))
	oCooking.m_CloseBtn:AddUIEvent("click", callback(self, "HideAll"))

	function oCooking.SetData(self, dInfo)
		local friendData = g_FriendCtrl:GetFriend(dInfo.frd_pid)
		oCooking.m_StateLabel:SetText(string.format("您的好友%s正在才艺展示中，帮忙加速吧", friendData.name))
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

function CTeaartFriendPage.InitNotCookingPart(self)
	local oBox = self.m_NotCookingPart
	oBox.m_CloseBtn = oBox:NewUI(1, CButton)
	oBox.m_TipsBtn = oBox:NewUI(2, CBox)

	oBox.m_CloseBtn:AddUIEvent("click", callback(self, "HideAll"))
	oBox.m_TipsBtn:AddUIEvent("click", callback(self, "ShowTips"))
end

function CTeaartFriendPage.ShowTips(self)
	g_NotifyCtrl:FloatMsg("目前暂未好友在您的工作台进行料理。")
end

function CTeaartFriendPage.OnHouseEvent(self, oCtrl)
	if oCtrl.m_EventID == define.House.Event.WorkDeskRefresh then
		if oCtrl.m_EventData == self.m_DeskPos then
			self:RefeshDesk()
		end
	end
end
function CTeaartFriendPage.RefeshDesk(self)
	self.m_Info = g_HouseCtrl:GetWorkDeskInfo(self.m_DeskPos)
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

function CTeaartFriendPage.RefreshTime(self)
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

function CTeaartFriendPage.GetLeftWorkTime(self)
	local iEnd = self.m_Info.create_time + self.m_Info.talent_time
	local iLeft = iEnd - g_TimeCtrl:GetTimeS()
	return iLeft
end




-- function CTeaartFriendPage.RefeshDesk(self)
-- 	local dInfo = g_HouseCtrl:GetWorkDeskInfo(self.m_DeskPos)
	-- local iLeft = self:GetLeftWorkTime()
	-- if iLeft > 0 then
	-- 	if not self.m_Timer then
	-- 		self.m_Timer = Utils.AddTimer(callback(self, "RefreshTime"), 0.5, 0)
	-- 	end
	-- 	self.m_StateLabel:SetText(string.format("您的好友%s正在才艺展示中，帮忙加速吧", dInfo.friend_name))
	-- 	self.m_SpeedUpBtn:SetActive(true)
	-- else
	-- 	self.m_StateLabel:SetText("您的友情工作台目前处于闲置状态")
	-- 	self.m_SpeedUpBtn:SetActive(false)
	-- 	self.m_TimeLabel:SetText("")
	-- end
-- end

-- function CTeaartFriendPage.RefreshTime(self)
-- 	local iLeft = self:GetLeftWorkTime()
-- 	if iLeft > 0 then
-- 		local sText = os.date("%H:%M:%S", iLeft)
-- 		self.m_TimeLabel:SetText(sText)
-- 		return true
-- 	else
-- 		self.m_TimeLabel:SetText("")
-- 		self.m_Timer = nil
-- 		return false
-- 	end
-- end

-- function CTeaartFriendPage.GetLeftWorkTime(self)
-- 	local dInfo = g_HouseCtrl:GetWorkDeskInfo(self.m_DeskPos)
-- 	local iEnd = dInfo.create_time + dInfo.talent_time
-- 	local iLeft = iEnd - g_TimeCtrl:GetTimeS()
-- 	return iLeft
-- end

function CTeaartFriendPage.HideAll(self)
	self.m_ParentView:HideAllPage()
end

function CTeaartFriendPage.OnSpeedUp(self)
	nethouse.C2GSHelpFriendWorkDesk()
end

return CTeaartFriendPage
local CTeaartView = class("CTeaartView", CViewBase)

function CTeaartView.ctor(self, cb)
	CViewBase.ctor(self, "UI/House/TeaArtMainView.prefab", cb)

	self.m_GroupName = "House"
end

function CTeaartView.OnCreateView(self)
	self.m_PlayerBox = self:NewUI(1, CBox)
	self.m_GiftBtn = self:NewUI(2, CButton)
	self.m_FriendBtn = self:NewUI(3, CButton)
	self.m_BackBtn = self:NewUI(4, CButton)
	self.m_QuitBtn = self:NewUI(5, CButton)
	self.m_FeelPage = self:NewPage(6, CTeaartFeelPage)
	self.m_FirendPage = self:NewPage(7, CTeaartFriendPage)
	self.m_WorkDeskGrid = self:NewUI(8, CGrid)
	-- self.m_RewardPart = self:NewUI(9, CHouseTeaArtRewardPart)
	-- self.m_HideBtn = self:NewUI(10, CBox)
	self.m_HelpBtn = self:NewUI(11, CButton)
	self.m_Container = self:NewUI(12, CBox)

	self:InitContent()
end

function CTeaartView.InitPlayerBox(self)
	local oPlayerBox = self.m_PlayerBox
	oPlayerBox.m_AvatarSprite = oPlayerBox:NewUI(1, CSprite)
	oPlayerBox.m_NameLabel = oPlayerBox:NewUI(2, CLabel)
	oPlayerBox.m_GradeLabel = oPlayerBox:NewUI(3, CLabel)
	oPlayerBox.m_ExpSlider = oPlayerBox:NewUI(4, CSlider)

	function oPlayerBox.SetData(self)
		oPlayerBox.m_AvatarSprite:SpriteHouseAvatar(g_AttrCtrl.model_info.shape)
		oPlayerBox.m_NameLabel:SetText(g_AttrCtrl.name)
		local iCurLv = g_HouseCtrl:GetTalentLevel()
		oPlayerBox.m_GradeLabel:SetText(tostring(iCurLv))
		local iCur = g_HouseCtrl:GetTalentValue()
		local iMax = data.housedata.Talent[iCurLv].rate
		oPlayerBox.m_ExpSlider:SetSliderText(string.format("%d/%d", iCur, iMax))
		oPlayerBox.m_ExpSlider:SetValue(iCur/iMax)
	end
end

function CTeaartView.OnClickHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("teaart")
	end)
end

function CTeaartView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container, 4, 4)
	-- UITools.ScaleToFit(self.m_HideBtn, nil)
	-- g_UITouchCtrl:TouchOutDetect(self.m_FeelPage, function ()
	-- 	self.m_FeelPage:SetActive(false)
	-- end)
	local function init(obj, idx)
		local oBox = CWorkDeskBox.New(obj)
		oBox:SetPos(idx)
		oBox:SetParentView(self)
		return oBox
	end
	self.m_WorkDeskGrid:InitChild(init)

	self:InitPlayerBox()
	self.m_PlayerBox:SetData()
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_GiftBtn:AddUIEvent("click", callback(self, "OnFeelPage"))
	self.m_FriendBtn:AddUIEvent("click", callback(self, "OnFriendPage"))
	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnBackCity"))
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBack"))
	-- self.m_HideBtn:AddUIEvent("click", callback(self, "OnHideBox"))

	g_GuideCtrl:CheckOtherGuideWhenTeaar()
	g_GuideCtrl:AddGuideUI("house_cooker_back_btn", self.m_BackBtn)
	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))
	
end

function CTeaartView.OnFriendPage(self)
	self:ShowSubPage(self.m_FirendPage)
end

function CTeaartView.OnFeelPage(self)
	self:ShowSubPage(self.m_FeelPage)
end

function CTeaartView.OnHouseEvent(self, oCtrl)
	if oCtrl.m_EventID == define.House.Event.TalentRefresh then
		self.m_PlayerBox:SetData()
	end
end

function CTeaartView.OnBack(self)
	self:CloseView()
end

function CTeaartView.OnBackCity(self)
	g_HouseCtrl:LeaveHouse()
end

function CTeaartView.ShowReward(self, dInfo)
	-- local itemList = {
	-- 	{
	-- 		sid = dInfo.item_sid,
	-- 		amount = 1,
	-- 	}
	-- }
	-- self.m_RewardPart:SetData(itemList)
end

-- function CTeaartView.OnHideBox(self)
-- 	local childCount = self.m_WorkDeskGrid:GetCount()
-- 	for i = 1, childCount do
-- 		local oBox = self.m_WorkDeskGrid:GetChild(i)
-- 		oBox:HideBox()
-- 	end
-- end

function CTeaartView.Destroy(self)
	CViewBase.Destroy(self)
	g_GuideCtrl:ReCheckHouseGuideEffect()
end

return CTeaartView
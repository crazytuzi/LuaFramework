local CArenaWarResultView = class("CArenaWarResultView", CViewBase)

function CArenaWarResultView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Arena/ArenaWarResultView.prefab", ob)
	self.m_ExtendClose = "Black"
end

function CArenaWarResultView.OnCreateView(self)
	self.m_PointLabel = self:NewUI(1, CLabel)
	self.m_WinMark = self:NewUI(2, CTexture)
	self.m_LoseMark = self:NewUI(3, CTexture)
	self.m_RightInfoBox = self:NewUI(4, CBox)
	self.m_LeftInfoBox = self:NewUI(5, CBox)
	self.m_ScorePart = self:NewUI(6, CBox)
	self:InitContent()
end
function CArenaWarResultView.InitContent(self)
	self.m_Ctrl = nil
	if g_WarCtrl:GetWarType() == define.War.Type.EqualArena then
		self.m_Ctrl = g_EqualArenaCtrl
	elseif g_WarCtrl:GetWarType() == define.War.Type.Arena then
		self.m_Ctrl = g_ArenaCtrl
	end
	
	self:InitInfoBox(self.m_LeftInfoBox)
	self:InitInfoBox(self.m_RightInfoBox)
	self.m_Ctrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	self:SetData()
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvnet"))
	netopenui.C2GSOpenInterface(define.OpenInterfaceType.WarResult)
end

function CArenaWarResultView.InitInfoBox(self, oInfoBox)
	oInfoBox.m_WinBg = oInfoBox:NewUI(1, CTexture)
	oInfoBox.m_AvatarTexture = oInfoBox:NewUI(2, CTexture)
	oInfoBox.m_LoseBg = oInfoBox:NewUI(3, CTexture)
	oInfoBox.m_NameLabel = oInfoBox:NewUI(4, CLabel)
	oInfoBox.m_LoseNameLabel = oInfoBox:NewUI(5, CLabel)
	oInfoBox.m_ParentView = self

	function oInfoBox.SetData(self, oData, isWinner)
		oInfoBox.m_ParentView:SetTexture(oInfoBox.m_AvatarTexture, oData.shape)
		oInfoBox.m_NameLabel:SetText(oData.name)
		oInfoBox.m_LoseNameLabel:SetText(oData.name)
		oInfoBox.m_WinBg:SetActive(isWinner)
		oInfoBox.m_LoseBg:SetActive(not isWinner)
		oInfoBox.m_AvatarTexture:SetGrey(not isWinner)
	end
end

function CArenaWarResultView.OnShowView(self)
	if self.m_Ctrl.m_Result == define.Arena.WarResult.NotReceive then
		self:SetActive(false)
	end
end

function CArenaWarResultView.SetData(self)
	self.m_IsPlayRecord = self.m_Ctrl.m_ViewSide ~= 0
	self.m_ScorePart:SetActive(not self.m_IsPlayRecord)
	local isWinner = false
	local strTemp = "[FFFAAF]积分%d[ff311c](-%d)[-]  获得[00FF00]%d[-]荣誉  本周%d/%d"
	if self.m_Ctrl.m_Result == define.Arena.WarResult.NotReceive then
		self:SetActive(false)
		return
	elseif self.m_Ctrl.m_Result == define.Arena.WarResult.Win then
		isWinner = true
		strTemp = "[FFFAAF]积分%d[00cc00](+%d)[-]  获得[00FF00]%d[-]荣誉  本周%d/%d"
	else

	end
	self.m_WinMark:SetActive(isWinner)
	self.m_LoseMark:SetActive(not isWinner)
	self.m_PointLabel:SetText(string.format(strTemp, self.m_Ctrl.m_ArenaPoint, self.m_Ctrl.m_ResultPoint, self.m_Ctrl.m_ResultMedal, self.m_Ctrl.m_WeekyMedal, self.m_Ctrl:GetGradeDataByPoint(self.m_Ctrl.m_ArenaPoint).weeky_limit))
	self.m_LoadCount = 0
	self.m_LeftInfoBox:SetData(self.m_Ctrl.m_PlayerInfo, isWinner)
	self.m_RightInfoBox:SetData(self.m_Ctrl.m_EnemyInfo, false)
end

function CArenaWarResultView.SetTexture(self, oTexture, shape)
	oTexture:LoadArenaPhoto(shape, callback(self, "AfterLoadPhoto"))
end

function CArenaWarResultView.AfterLoadPhoto(self)
	self.m_LoadCount = self.m_LoadCount + 1
	if self.m_LoadCount >= 2 then
		self:SetActive(true)
	end
end

function CArenaWarResultView.Destroy(self)
	g_ViewCtrl:CloseInterface(define.OpenInterfaceType.WarResult)
	if not self.m_IsPlayRecord then
		g_MainMenuCtrl:SetMainViewCallback(function ()
			self.m_Ctrl:ShowArena()
		end)
	end
	CViewBase.Destroy(self)
end

function CArenaWarResultView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Arena.Event.OnWarEnd or oCtrl.m_EventID == define.EqualArena.Event.OnWarEnd then
		self:SetData()
	end
end

function CArenaWarResultView.CloseView(self)
	g_WarCtrl:SetInResult(false)
end

function CArenaWarResultView.OnWarEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.EndWar then
		CViewBase.CloseView(self)
	end
end

return CArenaWarResultView

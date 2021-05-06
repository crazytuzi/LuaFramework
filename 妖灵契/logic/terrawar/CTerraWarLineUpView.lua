local CTerraWarLineUpView = class("CTerraWarLineUpView", CViewBase)

--~CTerraWarLineUpView:ShowView()
function CTerraWarLineUpView.ctor(self, cb)
	CViewBase.ctor(self, "UI/TerraWar/TerraWarLineUpView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Shelter"
end

function CTerraWarLineUpView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_PosGrid = self:NewUI(2, CBox)
	self.m_TimeLabel = self:NewUI(3, CLabel)
	self.m_SaveBtn = self:NewUI(4, CButton)
	self.m_AutoSaveBtn = self:NewUI(5, CButton)
	self:InitContent()
end

function CTerraWarLineUpView.InitContent(self)
	self.m_ActorList = {}
	self.m_PartnerPosList = {}

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnSaveBtn"))
	self.m_AutoSaveBtn:AddUIEvent("click", callback(self, "OnAutoSaveBtn"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvent"))
	self:InitView()
end

function CTerraWarLineUpView.OnWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.StartWar then
		self:CloseView()
	end
end

function CTerraWarLineUpView.OnSaveBtn(self, oBtn)
	local paridlist = {}
	for i,oPartner in pairs(self.m_PartnerPosList) do
		if oPartner.m_ID then
			table.insert(paridlist, oPartner.m_ID)
		end
	end
	nethuodong.C2GSSetGuard(self.m_Terraid, paridlist)
end

function CTerraWarLineUpView.OnAutoSaveBtn(self)
	local partnerList = g_PartnerCtrl:GetPartnerList()
	local lLineUpParid = {}

	for i,oPartner in ipairs(partnerList) do
		if not oPartner:IsTerraWar() and oPartner:GetValue("grade") >= 20 then
			table.insert(lLineUpParid, oPartner:GetValue("parid"))
		end
	end
	for i=1,4 do
		self:GoDownTerrawar(i)
	end
	for i=1, 3 do
		local parid = 0
		self:GoUpTerrawar(i, lLineUpParid[i])
	end
end

function CTerraWarLineUpView.AutoSave(self)
	if self.m_AutoTimer then
		Utils.DelTimer(self.m_AutoTimer)
		self.m_AutoTimer = nil
	end
	local time = 30
	local function countdown()
		if Utils.IsNil(self) then
			return 
		end
		if time >= 0 then
			self.m_TimeLabel:SetText(string.format("%d秒内未放入，被判定自动放入", time))
			time = time - 1
			return true
		end
		nethuodong.C2GSAutoSetGuard(self.m_Terraid)
	end
	self.m_AutoTimer = Utils.AddTimer(countdown, 1, 0)	
end

function CTerraWarLineUpView.InitView(self, terraid)
	self.m_Terraid = terraid
	self:InitPosGrid()
	self:RefreshPosGrid()
	self:AutoSave()
end

function CTerraWarLineUpView.InitPosGrid(self)
	for i = 1, 4 do
		local oBox = self.m_PosGrid:NewUI(i, CBox)
		oBox.m_AddButton = oBox:NewUI(1, CButton)
		oBox.m_ActorTexture = oBox:NewUI(2, CActorTexture)
		oBox.m_CloseFightBtn = oBox:NewUI(3, CButton)
		oBox.m_NameLabel = oBox:NewUI(4, CLabel)
		oBox.m_WidgetObj = oBox:NewUI(5, CWidget)
		oBox.m_PosIdx = i
		--oBox:AddUIEvent("click", callback(self, "OnPartnerChoose", oBox))
		oBox.m_AddButton:AddUIEvent("click", callback(self, "OnPartnerChoose", oBox))
		oBox.m_ActorTexture:AddUIEvent("click", callback(self, "OnPartnerChoose", oBox))
		oBox.m_CloseFightBtn:AddUIEvent("click", callback(self, "CloseFight", oBox))
		self.m_ActorList[i] = oBox
	end
end

function CTerraWarLineUpView.CloseFight(self, oBox)
	self:GoDownTerrawar(oBox.m_PosIdx, oBox.m_ID)
end

function CTerraWarLineUpView.OnPartnerChoose(self, oBox)
	self.m_SwitchIdx = oBox.m_PosIdx
	CPartnerChooseView:ShowView(function (oView)
		oView:SetConfirmCb(callback(self, "OnChangePartner"))
		oView:SetFilterCb(callback(self, "OnFilterUpGrade"))
	end)
end

function CTerraWarLineUpView.OnChangePartner(self, parid)
	self:GoUpTerrawar(self.m_SwitchIdx, parid)
end

function CTerraWarLineUpView.OnFilterUpGrade(self, parList)
	local list = {}
	local posids = {}
	for k,v in pairs(self.m_PartnerPosList) do
		if v and v.m_ID then
			table.insert(posids, v.m_ID)
		end
	end
	for k, oPartner in ipairs(parList) do
		if not oPartner:IsTerraWar() and oPartner:GetValue("grade") >= 20 
		and not table.index(posids, oPartner.m_ID) then
			table.insert(list, oPartner)
		end
	end
	return list
end

function CTerraWarLineUpView.RefreshPosGrid(self)
	for i, oBox in ipairs(self.m_ActorList) do
		local oPartner = self.m_PartnerPosList[i]
		if oPartner then
			oBox.m_ID = oPartner.m_ID
			oBox.m_ActorTexture:SetActive(true)
			oBox.m_AddButton:SetActive(false)
			local shape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
			oBox.m_ActorTexture:ChangeShape(shape, {})  
			oBox.m_ActorTexture.m_PartnerID = oPartner.m_ID
			oBox.m_NameLabel:SetText(oPartner:GetValue("name"))
			oBox.m_CloseFightBtn:SetActive(true)
		else
			oBox.m_ID = nil
			oBox.m_ActorTexture:SetActive(false)
			oBox.m_AddButton:SetActive(true)
			g_UITouchCtrl:DelDragObject(oBox.m_ActorTexture)
			oBox.m_NameLabel:SetText("")
			oBox.m_CloseFightBtn:SetActive(false)
		end
	end
end

function CTerraWarLineUpView.GoUpTerrawar(self, iPosIdx, iParid)
	self.m_PartnerPosList[iPosIdx] = g_PartnerCtrl:GetPartner(iParid)
	self:RefreshPosGrid()
end

function CTerraWarLineUpView.GoDownTerrawar(self, iPosIdx, iParid)
	self.m_PartnerPosList[iPosIdx] = nil
	self:RefreshPosGrid()
end

function CTerraWarLineUpView.AutoClose(self, end_time)
	if self.m_CloseTimer then
		Utils.DelTimer(self.m_CloseTimer)
		self.m_CloseTimer = nil
	end
	local time = end_time - g_TimeCtrl:GetTimeS()
	local sText = "%d秒内未放入，被判定自动放入" 
	local function countdown()
		if Utils.IsNil(self) then
			return 
		end
		if time >= 0 then
			self.m_TimeLabel:SetText(string.format(sText, time))
			time = time - 1
			return true
		end
		self.m_TimeLabel:SetText("")
		self:OnClose()
	end
	self.m_CloseTimer = Utils.AddTimer(countdown, 1, 0)
end

function CTerraWarLineUpView.CloseView(self)
	g_UITouchCtrl:FroceEndDrag(true)
	g_ViewCtrl:DontDestroyOnCloseAll("CTerraWarLineUpView", false)
	CViewBase.CloseView(self)
end

return CTerraWarLineUpView
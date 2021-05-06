local CPaTaWinView = class("CPaTaWinView", CViewBase)

function CPaTaWinView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/pata/PaTaWinView.prefab", cb)
	self.m_ExtendClose = "Shelter"
	self.m_GroupName = "main"
end

function CPaTaWinView.OnCreateView(self)
	self.m_PlayerTexture = self:NewUI(1, CTexture)
	self.m_PassFloorLabel = self:NewUI(2, CLabel)
	self.m_NextFloorLabel = self:NewUI(3, CLabel)
	self.m_ItemGrid = self:NewUI(4, CGrid)
	self.m_ItemCloneBox = self:NewUI(5, CItemTipsBox)
	self.m_BackBtn = self:NewUI(6, CButton)
	self.m_NextBtn = self:NewUI(7, CButton)
	self.m_BackMidBtn = self:NewUI(8, CButton)
	self.m_ContentBox = self:NewUI(9, CBox)
	self.m_Win = self:NewUI(10, CBox)
	self.m_Container = self:NewUI(11, CBox)
	self.m_WinEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_shengli.prefab", self:GetLayer(), false)
	self.m_WinEffect:SetParent(self.m_Win.m_Transform)
	self.m_WinEffect:SetLocalPos(Vector3.New(193,210,0))
	UITools.ResizeToRootSize(self.m_Container)
	self.m_CurLevel = nil
	self.m_InviteCount = 0
	self.m_ItemList = nil
	self.m_IsShowResult = false
	self:InitContent()

	netopenui.C2GSOpenInterface(define.OpenInterfaceType.WarResult)
end

function CPaTaWinView.InitContent(self)
	self.m_ItemCloneBox:SetActive(false)
	self.m_PlayerTexture:LoadFullPhoto(g_AttrCtrl.model_info.shape, function (oTexture)
		oTexture:MakePixelPerfect()
		--oTexture:SetLocalScale(Vector3.New(0.75,0.75,0.75))
	end)
	self.m_BackBtn:AddUIEvent("click", callback(self, "OnBack"))
	self.m_NextBtn:AddUIEvent("click", callback(self, "OnNext"))	
	self.m_BackMidBtn:AddUIEvent("click", callback(self, "OnBack"))	

	g_PataCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlPataEvent"))
end

function CPaTaWinView.SetContent( self , curLv, inviteCnt, itemList)
	self.m_CurLevel = curLv or 1
	self.m_InviteCount = inviteCnt or 0
	self.m_ItemList = itemList or {}

	self.m_ContentBox:SetActive(true)
	self.m_BackMidBtn:SetActive(false)
	self.m_BackBtn:SetActive(false)
	self.m_NextBtn:SetActive(false)

	self.m_PassFloorLabel:SetText(string.format("通关%d层", self.m_CurLevel - 1))

	if self.m_CurLevel > CPataCtrl.MaxLevel then
		self.m_NextFloorLabel:SetActive(false)
		self.m_BackMidBtn:SetActive(true)
	else
		self.m_NextFloorLabel:SetActive(true)
		local pataData = data.tollgatedata.PATA[self.m_CurLevel]
		if pataData then	
			self.m_NextFloorLabel:SetText(string.format("下一层:%d层    推荐战力:%d", self.m_CurLevel, pataData.recpower))
		end		
		self.m_BackBtn:SetActive(true)
		self.m_NextBtn:SetActive(true)
	end

	if next(self.m_ItemList) then
		for i = 1, #self.m_ItemList do
			local d = self.m_ItemList[i]
			local oItem = CItem.NewBySid(d.shape)
			if d then
				local oBox = self.m_ItemCloneBox:Clone()				
				local config = {isLocal = true, uiType = 3}
				oBox:SetItemData(d.shape, d.amount, nil, config)
				oBox:SetActive(true)
				self.m_ItemGrid:AddChild(oBox)			
			end			
		end
	end
end

function CPaTaWinView.OnCtrlPataEvent(self, oCtrl )
	if oCtrl.m_EventID == define.PaTa.Event.WarResult then
		if self.m_IsShowResult == false then		
			if g_PataCtrl.m_WarResult ~= nil and g_PataCtrl.m_WarResult.win == 1 then
				local result = g_PataCtrl.m_WarResult
				self.m_IsShowResult = true
				self:SetContent(result.curLv, result.inviteCnt, result.itemList)
				g_PataCtrl.m_WarResult = nil
			end
		end
	end
end

function CPaTaWinView.OnBack(self)
	g_WarCtrl:SetInResult(false)
	if self.m_CurLevel then
		g_PataCtrl:PaTaEnterView()
	end
	self:OnClose()
end

function CPaTaWinView.OnNext(self)
	-- if self.m_InviteCount and self.m_InviteCount > 0 then
	-- 	g_PataCtrl:PaTaReadyFight()
	-- else
	-- 	g_PataCtrl:CtrlC2GSPataInvite()
	-- end
	g_PataCtrl:CtrlC2GSPataInvite()
	self:OnClose()
end

function CPaTaWinView.SetDefaultShow(self)
	if g_PataCtrl.m_WarResult ~= nil and g_PataCtrl.m_WarResult.win == 1 then
		local result = g_PataCtrl.m_WarResult
		self.m_IsShowResult = true
		self:SetContent(result.curLv, result.inviteCnt, result.itemList)
		g_PataCtrl.m_WarResult = nil
	else
		self.m_ContentBox:SetActive(false)
		self.m_PassFloorLabel:SetActive(false)
		self.m_BackMidBtn:SetActive(true)		
	end
end

function CPaTaWinView.Destroy(self)
	g_ViewCtrl:CloseInterface(define.OpenInterfaceType.WarResult)
	CViewBase.Destroy(self)
end


return CPaTaWinView
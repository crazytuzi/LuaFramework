local CItemPartnertSelectPackageView = class("CItemPartnertSelectPackageView", CViewBase)

function CItemPartnertSelectPackageView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemPartnertSelectPackageView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black" 
end

function CItemPartnertSelectPackageView.OnCreateView(self)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_PartnerBox = self:NewUI(2, CBox)
	self.m_Container = self:NewUI(3, CWidget)
	self:InitContent()
end

function CItemPartnertSelectPackageView.InitContent(self)
	self.m_PartnerBox:SetActive(false)
	UITools.ResizeToRootSize(self.m_Container)
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CItemPartnertSelectPackageView.OnCtrlEvent(self)

end

function CItemPartnertSelectPackageView.SetData(self, sid, isLink, id)
	self.m_List = {315, 301, 302}
	if sid == 13281 then
		local oItem = CItem.NewBySid(sid)
		local use_reward = oItem:GetValue("use_reward")
		if use_reward and next(use_reward) then
			self.m_UseReward = use_reward
			self.m_List = {}
			for k,v in ipairs(use_reward) do
				local _, parid = g_ItemCtrl:SplitSidAndValue(v.sid)
				table.insert(self.m_List, parid)
			end
		end
	end
	g_ItemCtrl.m_CurUseItemId = id
	self.m_Id = id
	self.m_IsLink = true
	if isLink ~= true and id  then
		self.m_IsLink = false
	end
	for i, v in ipairs(self.m_List) do
		local oBox = self:CreateBox()
		oBox:SetActive(true)
		local d = data.partnerdata.DATA[v]
		oBox.m_ActorTextrue:LoadCardPhoto(d.icon)
		oBox.m_NameLabel:SetText(d.name)
		oBox.m_GetBtn:SetGrey(self.m_IsLink)
		local list = string.split(d.explain, "\n")
		oBox.m_DesLabel1:SetText(list[1] or "")
		oBox.m_DesLabel2:SetText(list[2] or "")
		oBox.m_LeftSpr:ReActive()
		oBox.m_RightSpr:ReActive()
		oBox.m_GetBtn:AddUIEvent("click", callback(self, "OnGetBtn", i))
		oBox.m_LookBtn:AddUIEvent("click", callback(self, "OnLookBtn", d.shape))
		self.m_Grid:AddChild(oBox)
	end
	self:HideAllViews()
end

function CItemPartnertSelectPackageView.OnGetBtn(self, idx)
	if self.m_IsLink or not self.m_Id or not self.m_UseReward then
		return
	end
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSChooseItem"]) then
		netitem.C2GSChooseItem(self.m_Id, {self.m_UseReward[idx].sid}, 1)
	end
	self:CloseView()
end

function CItemPartnertSelectPackageView.OnLookBtn(self, id)
	CPartnerGainView:ShowView(function (oView)
		oView:SetPartnerByType(id)
	end)	
end

function CItemPartnertSelectPackageView.CreateBox(self)
	local oBox = self.m_PartnerBox:Clone()
	oBox.m_ActorTextrue = oBox:NewUI(1, CTexture)
	oBox.m_LookBtn = oBox:NewUI(2, CButton)
	oBox.m_GetBtn = oBox:NewUI(3, CButton)
	oBox.m_NameLabel = oBox:NewUI(4, CLabel)
	oBox.m_DesLabel1 = oBox:NewUI(5, CLabel)
	oBox.m_DesLabel2 = oBox:NewUI(6, CLabel)	
	oBox.m_LeftSpr = oBox:NewUI(7, CSprite)
	oBox.m_RightSpr = oBox:NewUI(8, CSprite)
	return oBox
end

function CItemPartnertSelectPackageView.HideAllViews(self)
	self.m_HideView = {}
	local MaskView = 
	{
	 	["CNotifyView"] = true,	 	
	 	["CLockScreenView"] = true,
	 	["CItemPartnertSelectPackageView"] = true,
	 	["CBottomView"] = true,
	}
	local t = g_ViewCtrl.m_Views
	if t and next(t) then
		for k, oView in pairs(t) do
			if oView:GetActive() == true and MaskView[oView.classname] == nil then
				oView:SetActive(false)
				table.insert(self.m_HideView, oView)
			end
		end
	end	
end

function CItemPartnertSelectPackageView.Destroy(self)
	if self.m_HideView and next(self.m_HideView) then
		for k, oView in pairs(self.m_HideView) do
			if not Utils.IsNil(oView) then
				oView:SetActive(true)
			end
		end		
	end
	CViewBase.Destroy(self)
end

return CItemPartnertSelectPackageView
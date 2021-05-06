local CItemPartnerItemSelectView = class("CItemPartnerItemSelectView", CViewBase)

function CItemPartnerItemSelectView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemPartnerItemSelectView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black" 
end

function CItemPartnerItemSelectView.OnCreateView(self)
	self.m_Grid = self:NewUI(1, CGrid)
	self.m_CloneBox = self:NewUI(2, CBox)
	self.m_MyCntLabel = self:NewUI(3, CLabel)
	self.m_IncreassBtn = self:NewUI(4, CButton)
	self.m_ReduceBtn = self:NewUI(5, CButton)
	self.m_SelectCntBtn = self:NewUI(6, CButton)
	self.m_SelectCntLabel = self:NewUI(7, CLabel)
	self.m_MaxBtn = self:NewUI(8, CButton)
	self.m_OkBtn = self:NewUI(9, CButton)
	self.m_SelectIdx = 0
	self.m_SelectSid = 0
	self.m_SelectCnt = 1
	self.m_MySidCnt = 0
	self.m_SelectMax = 0
	self.m_SelectMin = 0
	self.m_Id = nil
	self.m_BoxList = {}
	self:InitContent()	
end

function CItemPartnerItemSelectView.InitContent(self)
	self.m_CloneBox:SetActive(false)
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnClickOk"))
	self.m_ReduceBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "reduce"))
	self.m_IncreassBtn:AddUIEvent("repeatpress", callback(self, "OnRePeatPress", "increass"))	
	self.m_MaxBtn:AddUIEvent("click", callback(self, "OnBtnClick", "max"))
	self.m_SelectCntBtn:AddUIEvent("click", callback(self, "OnBtnClick", "count"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))

	self:InitGrid()
end

function CItemPartnerItemSelectView.InitGrid(self)
	local d = data.partnerdata.DATA
	self.m_Pool = {}
	for k, v in pairs(d) do
		if v.icon ~= 318 then
			table.insert(self.m_Pool, v)
		end
	end
	table.sort(self.m_Pool, function (a, b)
		if a.rare ~= b.rare then
			return a.rare > b.rare 
		else
			return a.icon < b.icon	
		end
	end)
	for i, v in ipairs(self.m_Pool) do
		local oBox = self.m_BoxList[i]
		if not oBox then
			oBox = self.m_CloneBox:Clone()
			oBox.m_CntLabel = oBox:NewUI(1, CLabel)
			oBox.m_SelectSpr = oBox:NewUI(2, CSprite)
			oBox.m_QualityBgSpr = oBox:NewUI(3, CSprite)
			oBox.m_ShapeSpr = oBox:NewUI(4, CSprite)
			oBox.m_QualitySpr = oBox:NewUI(5, CSprite)
			oBox:SetGroup(self.m_Grid:GetInstanceID())
			self.m_BoxList[i] = oBox
			self.m_Grid:AddChild(oBox)
		end
		oBox.m_Sid = v.icon
		oBox:SetActive(true)
		oBox:AddUIEvent("click", callback(self, "OnClickItem", i, v.icon, oBox))
		oBox:AddUIEvent("longpress", callback(self, "OnLongPressItem", v.icon, oBox))
		oBox.m_ShapeSpr:SpriteAvatarBig(v.icon)
		oBox.m_QualityBgSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(v.rare))
		oBox.m_QualitySpr:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(v.rare))	
		
		oBox.m_SelectSpr:SetActive(false)
	end
	self:RefresCount(true)
end

function CItemPartnerItemSelectView.SetItemId(self, id)
	self.m_Id = id
	self:RefresCount()
end

function CItemPartnerItemSelectView.RefresCount(self, refreshGrid)
	if refreshGrid == true then
		for i, v in ipairs(self.m_BoxList) do
			local oBox = self.m_BoxList[i]
			if oBox then
				local cnt = g_ItemCtrl:GetTargetItemCountBySid(20000 + v.m_Sid)
				oBox.m_CntLabel:SetText(string.format("拥有:%d", cnt))
				oBox.m_SelectSpr:SetActive(i == self.m_SelectIdx)
			end
		end
	end
	
	self.m_MySidCnt = 0
	if self.m_Id then
		self.m_MySidCnt = g_ItemCtrl:GetTargetItemCountById(self.m_Id)
	end
	self.m_MyCntLabel:SetText(tostring(self.m_MySidCnt))
	self.m_SelectMax = self.m_MySidCnt
	if self.m_SelectCnt > self.m_MySidCnt then
		self.m_SelectCnt = self.m_MySidCnt
	end
	self.m_SelectCntLabel:SetText(tostring(self.m_SelectCnt))
end

function CItemPartnerItemSelectView.OnClickOk( self )
	if self.m_SelectIdx == 0 then
		g_NotifyCtrl:FloatMsg("请选择碎片")
		return
	end
	if self.m_SelectCnt == 0 then
		g_NotifyCtrl:FloatMsg("请选数量")
	end
	if not self.m_Id then
		g_NotifyCtrl:FloatMsg("该道具不存在")
		return
	end
	local items = {}
	items[1] = tostring(20000 + self.m_SelectSid)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSChooseItem"]) then
		netitem.C2GSChooseItem(self.m_Id, items, self.m_SelectCnt)
	end
end

function CItemPartnerItemSelectView.OnClickItem( self, idx, sid, oBtn)
	if self.m_SelectIdx ~= idx then
		local oBox = self.m_BoxList[self.m_SelectIdx]
		if oBox then
			oBox.m_SelectSpr:SetActive(false)
		end
		oBox = self.m_BoxList[idx]
		if oBox then
			oBox.m_SelectSpr:SetActive(true)
		end
		self.m_SelectIdx = idx
		self.m_SelectSid = oBox.m_Sid
		self.m_SelectCnt = 1
		self:RefresCount()
	end
end

function CItemPartnerItemSelectView.OnLongPressItem( self, sid, oBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(20000 + sid, {widget = oBox, openView = self})
end

function CItemPartnerItemSelectView.OnRePeatPress(self, tKey , ...)
	local bPress = select(2, ...)
	if bPress ~= true then
			return
	end 

	if tKey == "reduce" then
		self:OnBtnClick("reduce")
	elseif tKey == "increass" then
		self:OnBtnClick("increass")
	end
end

function CItemPartnerItemSelectView.OnBtnClick(self, tKey )
	if self.m_SelectIdx == 0 then
		g_NotifyCtrl:FloatMsg("请选择碎片")
		return
	end			
	if tKey == "reduce" then
		self.m_SelectCnt = self.m_SelectCnt - 1
		if self.m_SelectCnt  < 1 then
			self.m_SelectCnt = 1
		end
		self.m_SelectCntLabel:SetText(tostring(self.m_SelectCnt))

	elseif tKey == "increass" then
		self.m_SelectCnt = self.m_SelectCnt + 1
		if self.m_SelectCnt > self.m_SelectMax then
			self.m_SelectCnt = self.m_SelectMax
			g_NotifyCtrl:FloatMsg("超过最大数量")
		end
		self.m_SelectCntLabel:SetText(tostring(self.m_SelectCnt))

	elseif tKey == "max" then
		self.m_SelectCnt = self.m_SelectMax
		self.m_SelectCntLabel:SetText(tostring(self.m_SelectCnt))

	elseif tKey == "count" then
		local function syncCallback(self, count)
				self.m_SelectCnt = count
				self.m_SelectCntLabel:SetText(tostring(count))
		end
		g_WindowTipCtrl:SetWindowNumberKeyBorad(
		{num = self.m_SelectCnt, min = 1, max = self.m_SelectMax, syncfunc = syncCallback , obj = self},
		{widget=  self, side = enum.UIAnchor.Side.Right ,offset = Vector2.New(0, -75)})
	end
end

function CItemPartnerItemSelectView.OnCtrlItemEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem 
		or oCtrl.m_EventID == define.Item.Event.RefreshBagItem  then	
		local cnt = 0
		if self.m_Id then
			cnt = g_ItemCtrl:GetTargetItemCountById(self.m_Id)
		end
		if cnt == 0 then
			self:CloseView()
			return 
		end
		self:RefresCount(true)
	end
end

return CItemPartnerItemSelectView
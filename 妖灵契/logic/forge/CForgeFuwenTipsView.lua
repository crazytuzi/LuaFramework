local CForgeFuwenTipsView = class("CForgeFuwenTipsView", CViewBase)

function CForgeFuwenTipsView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Forge/ForgeFuwenTipsView.prefab", cb)
	--界面设置
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CForgeFuwenTipsView.OnCreateView(self)
	self.m_AttrFwuenBox = self:NewUI(1, CBox)
	self.m_OneGrid = self:NewUI(2, CGrid)
	self.m_OneBgSpr = self:NewUI(3, CSprite)
	self.m_TwoGrid = self:NewUI(4, CGrid)
	self.m_TwoBgSpr = self:NewUI(5, CSprite)
	self.m_BgSpr = self:NewUI(6, CSprite)
	self.m_OneTitleLabel = self:NewUI(7, CLabel)
	self.m_TwoTitleLabel = self:NewUI(8, CLabel)
	self.m_OneUseBtn = self:NewUI(9, CButton)
	self.m_TwoUseBtn = self:NewUI(10, CButton)
	self.m_OneUseLabel = self:NewUI(11, CLabel)
	self.m_TwoUseLabel = self:NewUI(12, CLabel)
	self.m_ChangeNameBtn = self:NewUI(13, CButton)
	self:InitContent()
end

function CForgeFuwenTipsView.InitContent(self)
	self.m_AttrFwuenBox:SetActive(false)
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemEvent"))
	self.m_OneUseBtn:AddUIEvent("click", callback(self, "OnUse"))
	self.m_TwoUseBtn:AddUIEvent("click", callback(self, "OnUse"))
	self.m_ChangeNameBtn:AddUIEvent("click", callback(self, "OnChangeName"))
	self:RefreshAttr()
	--self:RefreshHeight()
	self:RefreshPlan()
	self:RefreshPlanName()
end

function CForgeFuwenTipsView.CreateAttrBox(self)
	local oBox = self.m_AttrFwuenBox:Clone()
	oBox.m_KeyLabel = oBox:NewUI(1, CLabel)
	oBox.m_ValueLabel = oBox:NewUI(2, CLabel)
	oBox.m_UpSpr = oBox:NewUI(3, CSprite)
	oBox.m_DownSpr = oBox:NewUI(4, CSprite)
	return oBox
end

--result == 0 相同， result == 1 方案2属性高, result == 2 方案1属性高
function CForgeFuwenTipsView.CompareAttr(self, key, plan2attr, plan1)
	local result = 1
	if plan1 and #plan1 > 0 then
		for i = 1, #plan1 do
			local attr = plan1[i]
			if attr.key == key then
				if attr.value > plan2attr then
					result = 2
				elseif attr.value < plan2attr then
					result = 1
				else
					result = 0
				end
				break
			end
		end
	end
	return result
end

function CForgeFuwenTipsView.CheckPlanAttr(self, plan1, plan2)
	if #plan1 == 0 or #plan2 == 0 then
		return plan2	
	end
	for i = 1, #plan1 do
		local attr1 = plan1[i]
		local isExit = false
		for k = 1, #plan2 do
			local attr2 = plan2[k]
			if attr2.key == attr1.key then
				isExit = true
				break			
			end
		end
		if not isExit then
			table.insert(plan2, {key = attr1.key, value = 0})
		end
	end	

	for i = 1, #plan2 do
		local attr2 = plan2[i]
		local isExit = false
		for k = 1, #plan1 do
			local attr1 = plan1[k]
			if attr2.key == attr1.key then
				isExit = true
				break			
			end
		end
		if not isExit then
			table.insert(plan1, {key = attr2.key, value = 0})
		end
	end		

	local t = {}
	for _k, _v in pairs(define.Attr.AttrKey) do 
		for k,v in pairs(plan1) do
			if define.Attr.String[v.key] ~= nil and _v == v.key then
				local d = {key = v.key, value = v.value}
				table.insert(t, d)
			end
		end
	end	
	plan1 = t
	t = {}
	for _k, _v in pairs(define.Attr.AttrKey) do 
		for k,v in pairs(plan2) do
			if define.Attr.String[v.key] ~= nil and _v == v.key then
				local d = {key = v.key, value = v.value}
				table.insert(t, d)
			end
		end
	end
	plan2 = t
	return plan1, plan2
end

function CForgeFuwenTipsView.OnUse(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSUseFuWenPlan"]) then
		netitem.C2GSUseFuWenPlan()
		self:CloseView()
	end
end

function CForgeFuwenTipsView.RefreshPlan(self)
	local curPlan = g_ItemCtrl:GetFuwenPlan()
	if curPlan == 2 then
		self.m_OneUseBtn:SetActive(true)
		self.m_TwoUseBtn:SetActive(false)
		self.m_OneUseLabel:SetActive(false)
		self.m_TwoUseLabel:SetActive(true)
	else
		self.m_OneUseBtn:SetActive(false)
		self.m_TwoUseBtn:SetActive(true)
		self.m_OneUseLabel:SetActive(true)
		self.m_TwoUseLabel:SetActive(false)		
	end
end

function CForgeFuwenTipsView.OnCtrlItemEvent( self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshFuwen then		
		self:RefreshPlan()
		self:RefreshAttr()
	elseif oCtrl.m_EventID == define.Item.Event.RefreshFuwenName then		
		self:RefreshPlanName()
	end
end

function CForgeFuwenTipsView.OnChangeName(self)
	CForgeFuwenChangeNameView:ShowView()
end

function CForgeFuwenTipsView.RefreshPlanName(self)
	self.m_OneTitleLabel:SetText(g_ItemCtrl:GetFuwenPlanName(1))
	self.m_TwoTitleLabel:SetText(g_ItemCtrl:GetFuwenPlanName(2))
end

function CForgeFuwenTipsView.RefreshAttr(self)
	local plan1 = g_ItemCtrl:GetEquipFuwenAttByPlan(1, true)
	local plan2 = g_ItemCtrl:GetEquipFuwenAttByPlan(2, true)
	plan1 = self:RemoveKeyAttr(plan1, "hp")
	plan2 = self:RemoveKeyAttr(plan2, "hp")
	local curPlan = g_ItemCtrl:GetFuwenPlan()
	plan1, plan2 = self:CheckPlanAttr(plan1, plan2)
	if #plan1 > 0 then
		for i = 1, #plan1 do
			local oBox = self.m_OneGrid:GetChild(i)
			if not oBox then
				oBox = self:CreateAttrBox()
				oBox:SetActive(true)
				self.m_OneGrid:AddChild(oBox)
			end		
			oBox.m_UpSpr:SetActive(false)
			oBox.m_DownSpr:SetActive(false)	
			local attr = plan1[i]
			oBox.m_KeyLabel:SetText(string.format("%s", define.Attr.String[attr.key]))
			oBox.m_ValueLabel:SetText(string.format("[159a80]%s", g_ItemCtrl:AttrStringConvert(attr.key, attr.value)))
			if curPlan == 2 then
				local compare = self:CompareAttr(attr.key, attr.value, plan2)
				if compare == 1 then
					oBox.m_UpSpr:SetActive(true)
				elseif compare == 2 then
					oBox.m_ValueLabel:SetText(string.format("[b13a22]%s", g_ItemCtrl:AttrStringConvert(attr.key, attr.value)))					
					oBox.m_DownSpr:SetActive(true)
				end
			end			
		end
	end

	if #plan1 > 0 then
		for i = 1, #plan2 do
			local oBox = self.m_TwoGrid:GetChild(i)
			if not oBox then
				oBox = self:CreateAttrBox()
				oBox:SetActive(true)
				self.m_TwoGrid:AddChild(oBox)
			end
			oBox.m_UpSpr:SetActive(false)
			oBox.m_DownSpr:SetActive(false)				
			local attr = plan2[i]
			oBox.m_KeyLabel:SetText(define.Attr.String[attr.key])			
			oBox.m_ValueLabel:SetText(string.format("[159a80]%s", g_ItemCtrl:AttrStringConvert(attr.key, attr.value)) )
			if curPlan == 1 then
				local compare = self:CompareAttr(attr.key, attr.value, plan1)
				if compare == 1 then
					oBox.m_UpSpr:SetActive(true)
				elseif compare == 2 then
					oBox.m_ValueLabel:SetText(string.format("[b13a22]%s", g_ItemCtrl:AttrStringConvert(attr.key, attr.value)) )
					oBox.m_DownSpr:SetActive(true)
				end
			end						
		end
	end
end

function CForgeFuwenTipsView.RefreshHeight(self)
	self.m_OneBgSpr:SetHeight(self.m_OneGrid:GetCount() * self.m_AttrFwuenBox:GetHeight() + 20 )
	self.m_TwoBgSpr:SetHeight(self.m_TwoGrid:GetCount() * self.m_AttrFwuenBox:GetHeight() + 20 )
	local cnt = self.m_OneGrid:GetCount() > self.m_TwoGrid:GetCount() and self.m_OneGrid:GetCount() or self.m_TwoGrid:GetCount()
	self.m_BgSpr:SetHeight(self.m_BgSpr:GetHeight() + cnt * self.m_AttrFwuenBox:GetHeight() + 60 )
	local h = self.m_BgSpr:GetLocalPos().y - self.m_BgSpr:GetHeight() + 60
	self.m_OneUseBtn:SetLocalPos(Vector3.New(self.m_OneUseBtn:GetLocalPos().x, h , 0))
	self.m_TwoUseBtn:SetLocalPos(Vector3.New(self.m_TwoUseBtn:GetLocalPos().x, h, 0))
end

function CForgeFuwenTipsView.RemoveKeyAttr(self, attr, key)
	for i, v in ipairs(attr) do
		if v.key == key then
			table.remove(attr, i)
		end
		return attr
	end
end

return CForgeFuwenTipsView
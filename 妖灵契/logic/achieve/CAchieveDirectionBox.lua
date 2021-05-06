local CAchieveDirectionBox = class("CAchieveDirectionBox", CBox)

function CAchieveDirectionBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ScrollView = self:NewUI(1, CScrollView)
	self.m_Table = self:NewUI(2, CTable)
	self.m_Box = self:NewUI(3, CBox)
	self:InitContent()
	self:CheckRedDot()
end

function CAchieveDirectionBox.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CAchieveDirectionBox.InitContent(self)
	self.m_ScrollViewW, self.m_ScrollViewH = self.m_ScrollView:GetSize()
	self.m_Box:SetActive(false)
	self.m_DirectionRedPos = Vector3.New(-30, -15, 0)
	self.m_BelongRedPos = Vector3.New(-15, -15, 0)
	self:InitTable()
end

function CAchieveDirectionBox.InitTable(self)
	local list = data.achievedata.DIRECTION
	self.m_Table:Clear()
	self.m_BoxDic = {}
	for i,v in ipairs(list) do
		local oBox = self.m_Box:Clone()
		oBox.m_NameLabel = oBox:NewUI(1, CLabel)
		oBox.m_SelectSprite = oBox:NewUI(2, CSprite)
		oBox.m_BelongGrid = oBox:NewUI(3, CGrid)
		oBox.m_BelongBox = oBox:NewUI(4, CBox)
		oBox.m_JianTouSpr = oBox:NewUI(5, CSprite)
		oBox.m_BelongWidget = oBox:NewUI(6, CWidget)
		oBox.m_SelectSprite:SetActive(false)
		oBox.m_BelongWidget:SetActive(false)
		oBox.m_BelongBox:SetActive(false)
		oBox:SetActive(true)

		oBox.m_Direction = v.id
		oBox.m_SumPoint = v.sum_point
		oBox.m_Sub = v.sub
		oBox.m_NameLabel:SetText(v.name)
		oBox.m_IgnoreCheckEffect = true
		
		oBox.m_BelongBoxDic = {}
		for k,v in ipairs(oBox.m_Sub) do
			local oBelong = oBox.m_BelongBox:Clone()
			oBelong:SetActive(true)
			oBelong.m_IgnoreCheckEffect = true
			oBelong.m_NameLabel = oBelong:NewUI(1, CLabel)
			oBelong.m_SelectSprite = oBelong:NewUI(2, CSprite)
			oBelong.m_Direction = oBox.m_Direction
			oBelong.m_Belong = v.belong
			oBelong.m_NameLabel:SetText(v.name)
			oBelong.m_SelectSprite:SetActive(false)
			oBelong:AddUIEvent("click", callback(self, "OnBelongBox"))
			oBox.m_BelongGrid:AddChild(oBelong)
			oBox.m_BelongBoxDic[oBelong.m_Belong] = oBelong
		end
		oBox.m_BelongGrid:Reposition()

		local count = #v.sub
		local _, h = oBox.m_BelongGrid:GetCellSize()
		h = count * h
		oBox.m_BelongWidget:SetHeight(h)
		local _, oldh = oBox:GetSize()
		oBox.m_HideHeight = oldh 
		oBox.m_ShowHeight = oldh + h

		oBox:AddUIEvent("click", callback(self, "OnBox"))
		self.m_Table:AddChild(oBox)
		self.m_BoxDic[oBox.m_Direction] = oBox
	end
end

function CAchieveDirectionBox.OnBox(self, oBox)
	if self.m_CurDirectionBox then
		self.m_CurDirectionBox.m_SelectSprite:SetActive(false)
		local bAct = self.m_CurDirectionBox.m_BelongWidget:GetActive()
		local rotateZ = 90
		if bAct then
			rotateZ = 0
		end
		self.m_CurDirectionBox.m_JianTouSpr:SetLocalRotation(Quaternion.Euler(0, 0, rotateZ))
	end
	self.m_CurDirectionBox = oBox
	self.m_CurDirectionBox.m_SelectSprite:SetActive(true)
	local bAct = oBox.m_BelongWidget:GetActive()
	oBox.m_BelongWidget:SetActive(not bAct)
	local pos = oBox:GetLocalPos()
	local h = math.abs(pos.y)
	local rotateZ = 90
	if not bAct then
		rotateZ = 0
		h = h + oBox.m_ShowHeight
	end
	oBox.m_JianTouSpr:SetLocalRotation(Quaternion.Euler(0, 0, rotateZ))
	self:RepositionTable(h)
end

function CAchieveDirectionBox.RepositionTable(self, h)
	self.m_Table:Reposition()
	Utils.AddTimer(function ()
		if h and h > self.m_ScrollViewH then
			self.m_ScrollView:MoveRelative(Vector3.New(0, (h - self.m_ScrollViewH), 0))
			self.m_Table:Reposition()
		end
	end,0,0)
end

function CAchieveDirectionBox.OnBelongBox(self, oBelong)
	if self.m_CurBelongBox == oBelong then
		return
	end
	if self.m_CurBelongBox then
		self.m_CurBelongBox.m_SelectSprite:SetActive(false)
	end
	oBelong.m_SelectSprite:SetActive(true)
	self.m_CurBelongBox = oBelong
	g_AchieveCtrl:C2GSAchieveDirection(self.m_CurBelongBox.m_Direction, self.m_CurBelongBox.m_Belong)
end

function CAchieveDirectionBox.GetCurDirection(self)
	return self.m_CurBelongBox.m_Direction

end

function CAchieveDirectionBox.GetCurBelong(self)
	return self.m_CurBelongBox.m_Belong
end

function CAchieveDirectionBox.CheckRedDot(self)
	local lRedDots = g_AchieveCtrl:GetAchieveRedDot() or {}
	for i, oBox in pairs(self.m_BoxDic) do
		local RedDot = lRedDots[oBox.m_Direction]
		if RedDot then
			oBox:AddEffect("RedDot", 20, self.m_DirectionRedPos)
			for k, oBelong in pairs(oBox.m_BelongBoxDic) do
				if table.index(RedDot.blist, oBelong.m_Belong) then
					oBelong:AddEffect("RedDot", 15, self.m_BelongRedPos)
				else
					oBelong:DelEffect("RedDot")
				end
			end
		else
			oBox:DelEffect("RedDot")
			for k, oBelong in pairs(oBox.m_BelongBoxDic) do
				oBelong:DelEffect("RedDot")
			end
		end
	end
end

function CAchieveDirectionBox.DefaultSelect(self, iDirection, iBelong)
	iDirection = iDirection or (self.m_CurDirectionBox and self.m_CurDirectionBox.m_Direction) or 1
	iBelong = iBelong or (self.m_CurBelongBox and self.m_CurBelongBox.m_Belong) or 1
	if iDirection and iBelong then
		local oBox = self.m_BoxDic[iDirection]
		if oBox then
			oBox.m_BelongWidget:SetActive(oBox.m_BelongWidget:GetActive())
			local oBelong = oBox.m_BelongBoxDic[iBelong]
			if oBelong then
				self:OnBelongBox(oBelong)
			end
		end
	end
end

return CAchieveDirectionBox
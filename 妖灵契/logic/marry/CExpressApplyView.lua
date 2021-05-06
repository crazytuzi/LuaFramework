local CExpressApplyView = class("CExpressApplyView", CViewBase)

function CExpressApplyView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Marry/ExpressApplyView.prefab", cb)
	self.m_ExtendClose = "Black"
	-- self.m_GroupName = "main"
	-- self.m_DepthType = "Login"  --层次
end

function CExpressApplyView.OnCreateView(self)
	self.m_OkBtn = self:NewUI(1, CButton)
	-- self.m_CancelBtn = self:NewUI(2, CButton)
	self.m_ConditionGrid = self:NewUI(3, CGrid)
	self.m_ConditionBox = self:NewUI(4, CBox)
	self:InitContent()
end

function CExpressApplyView.InitContent(self)
	self.m_OpenGrade = data.globalcontroldata.GLOBAL_CONTROL["express"].open_grade
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnOkBtn"))
	-- self.m_CancelBtn:AddUIEvent("click", callback(self, "OnClose"))
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	self.m_ConditionData = {
		{desc = "队长身上需携带100水晶作为申请费用", checkFunc = callback(self, "CheckMoney"), },
		{desc = "2人组队并无人暂离", checkFunc = callback(self, "CheckTeam"), },
		{desc = "双方均未有已缔结的情侣关系", checkFunc = callback(self, "CheckExpress"), },
		{desc = string.format("双方角色等级达到%s级", self.m_OpenGrade), checkFunc = callback(self, "CheckGrade"), },
		{desc = "双方均在婚姻登记员附近", checkFunc = callback(self, "CheckNear"), },
	}
	self:SetData()
	self:Refresh()
end

function CExpressApplyView.OnOkBtn(self)
	if g_TeamCtrl:GetMemberSize() ~= 2 then
		g_NotifyCtrl:FloatMsg("只能双人组队申请")
	elseif g_TeamCtrl:HasMemberLeave() then
		g_NotifyCtrl:FloatMsg("队友暂离中，无法申请")
	elseif not self:CheckMoney() then
		g_NotifyCtrl:FloatMsg("队长身上不足100水晶，无法申请")
	elseif not self:CheckExpress() then
		g_NotifyCtrl:FloatMsg(string.format("%s已存在情侣关系", g_MarryCtrl.m_CanExpressTips))
	elseif not self:CheckNear() then
		g_NotifyCtrl:FloatMsg("对方不在婚姻登记员附近")
	elseif not self:CheckGrade() then
		local teamMemberList = g_TeamCtrl:GetMemberByGrade(0, self.m_OpenGrade - 1)
		local sTip
		for k,v in pairs(teamMemberList) do
			if sTip == nil then
				sTip = v.name
			else
				sTip = string.format("%s、%s", sTip, v.name)
			end
		end
		g_NotifyCtrl:FloatMsg(string.format("%s等级不足%s级", sTip, self.m_OpenGrade))
	else
		self:OnClose()
		CExpressEditView:ShowView()
	end
end

function CExpressApplyView.CheckGrade(self)
	local teamMemberList = g_TeamCtrl:GetMemberByGrade(0, self.m_OpenGrade - 1)
	return #teamMemberList <= 0
end

function CExpressApplyView.CheckTeam(self)
	return g_TeamCtrl:GetMemberSize() == 2 and not g_TeamCtrl:HasMemberLeave()
end

function CExpressApplyView.CheckExpress(self)
	return (g_MarryCtrl.m_CanExpressTips == "" or g_MarryCtrl.m_CanExpressTips == nil)
end

function CExpressApplyView.CheckNear(self)
	return g_TeamCtrl:GetMemberSize() == 2 and not g_TeamCtrl:HasMemberOffline()
end

function CExpressApplyView.CheckMoney(self)
	return g_AttrCtrl.goldcoin >= data.marrydata.Rule[1].apply_cost
end

function CExpressApplyView.SetData(self)
	self.m_ConditionBoxArr = {}
	for i,v in ipairs(self.m_ConditionData) do
		self.m_ConditionData[i] = self:CreateConditionBox()
		self.m_ConditionData[i]:SetData(v)
	end
	self.m_ConditionBox:SetActive(false)
end

function CExpressApplyView.CreateConditionBox(self)
	local oConditionBox = self.m_ConditionBox:Clone()
	oConditionBox.m_Label = oConditionBox:NewUI(1, CLabel)
	oConditionBox.m_OkMark = oConditionBox:NewUI(2, CBox)
	oConditionBox.m_NoMark = oConditionBox:NewUI(3, CBox)
	oConditionBox.m_Table = oConditionBox:NewUI(4, CTable)
	oConditionBox.m_NoMarkLabel = oConditionBox:NewUI(5, CLabel)
	self.m_ConditionGrid:AddChild(oConditionBox)

	function oConditionBox.SetData(self, oData)
		oConditionBox.m_Data = oData
		oConditionBox.m_Label:SetText(oConditionBox.m_Data.desc)
		oConditionBox.m_NoMarkLabel:SetText(oConditionBox.m_Data.desc)
	end

	function oConditionBox.Refresh(self)
		local bOk = oConditionBox.m_Data.checkFunc()
		oConditionBox.m_OkMark:SetActive(bOk)
		oConditionBox.m_NoMark:SetActive(not bOk)
		oConditionBox.m_Label:SetActive(bOk)
		oConditionBox.m_NoMarkLabel:SetActive(not bOk)
		oConditionBox.m_Table:Reposition()
	end

	return oConditionBox
end

function CExpressApplyView.Refresh(self)
	for i,v in ipairs(self.m_ConditionData) do
		self.m_ConditionData[i]:Refresh()
	end
end

function CExpressApplyView.OnTeamEvent(self, oCtrl)
	self:Refresh()
end

function CExpressApplyView.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:Refresh()
	end
end


return CExpressApplyView
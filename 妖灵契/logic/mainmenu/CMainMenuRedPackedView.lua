local CMainMenuRedPackedView = class("CMainMenuRedPackedView", CViewBase)

function CMainMenuRedPackedView.ctor(self, cb)
	CViewBase.ctor(self, "UI/MainMenu/RedPackedView.prefab", cb)
	self.m_DepthType = "Menu"
end

function CMainMenuRedPackedView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_Btn = self:NewUI(2, CButton)
	self.m_UIEffect = self:NewUI(3, CUIEffect)
	self.m_OrgBtn = self:NewUI(4, CButton)
	self.m_OrgLabel = self:NewUI(5, CLabel)
	self.m_DataList = {}
	self:InitContent()
end

function CMainMenuRedPackedView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_UIEffect:Above(self.m_Btn)
	self.m_UIEffect:SetActive(true)
	self.m_Btn:AddUIEvent("click", callback(self, "OnGetRedPacked"))
	self.m_OrgBtn:AddUIEvent("click", callback(self, "OnGetOrgRedPacked"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
end

function CMainMenuRedPackedView.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData["dAttr"]["org_id"] then
			if g_AttrCtrl.org_id == 0 then
				self:CloseView()
			end
		end
	end
end

function CMainMenuRedPackedView.SetData(self, iHid, sid)
	self.m_Type = "person"
	self.m_Btn:SetActive(true)
	self.m_OrgBtn:SetActive(false)
	self.m_Btn:SpriteItemShape(sid)
	self.m_ID = iHid
	self:AutoClose()
end

function CMainMenuRedPackedView.AddRedData(self, sType, dData)
	table.insert(self.m_DataList, {sType, dData})
	if sType == "org" then
		self:SetOrgData(dData[1])
	
	elseif sType == "person" then
		self:SetData(dData[1], dData[2])
	end
end

function CMainMenuRedPackedView.SetOrgData(self, dBagList)
	self.m_Type = "org"
	self.m_Btn:SetActive(false)
	local iNum = nil
	local t = {20, 40, 80}
	self.m_OrgIdx = nil
	for i, bHas in ipairs(dBagList) do
		if bHas then
			iNum = t[i]
			self.m_OrgIdx = i
			break
		end
	end
	if iNum then
		self.m_OrgBtn:SetActive(true)
		self.m_OrgLabel:SetText(tostring(iNum))
	else
		self:CloseView()
	end
end

CMainMenuRedPackedView.CloseTime = 60
function CMainMenuRedPackedView.AutoClose(self)
	if self.m_AutoCloseTimer then
		Utils.DelTimer(self.m_AutoCloseTimer)
	end
	self.m_AutoCloseTimer = Utils.AddTimer(function ()
		if not Utils.IsNil(self) then
			self:CloseAndRemove()
		end
	end, 0, CMainMenuRedPackedView.CloseTime)
end

function CMainMenuRedPackedView.OnGetRedPacked(self)
	if self.m_ID then
		g_ChatCtrl:ClickRedPacket(self.m_ID)
		self:CloseAndRemove()
	end
end

function CMainMenuRedPackedView.CloseAndRemove(self)
	local iMax = #self.m_DataList or 1
	if self.m_DataList[iMax] then
		table.remove(self.m_DataList, iMax)
		if self.m_DataList[iMax-1] then
			local sType, dData = self.m_DataList[iMax-1][1], self.m_DataList[iMax-1][2]
			if sType == "org" then
				self:SetOrgData(dData[1])
			
			elseif sType == "person" then
				self:SetData(dData[1], dData[2])
			end
		else
			self:CloseView()
		end
	else
		self:CloseView()
	end
end

function CMainMenuRedPackedView.OnGetOrgRedPacked(self)
	if self.m_OrgIdx then
		netorg.C2GSDrawOrgRedPacket(self.m_OrgIdx)
		self:CloseAndRemove()
	end
end

return CMainMenuRedPackedView
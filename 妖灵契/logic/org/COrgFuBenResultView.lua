local COrgFuBenResultView = class("COrgFuBenResultView", CViewBase)

function COrgFuBenResultView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgFuBenResultView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function COrgFuBenResultView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_Win = self:NewUI(2, CObject)
	self.m_End = self:NewUI(3, CObject)
	self.m_DescLabel = self:NewUI(4, CLabel)
	self.m_ItemPart = self:NewUI(5, CObject)
	self.m_ItemGrid = self:NewUI(6, CGrid)
	self.m_ItemBox = self:NewUI(7, CItemTipsBox)
	self.m_DelayCloseLabel = self:NewUI(8, CLabel)
	self.m_WinEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_shengli.prefab", self:GetLayer(), false)
	self.m_WinEffect:SetParent(self.m_Win.m_Transform)
	self.m_EndEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_zhandoujieshu.prefab", self:GetLayer(), false)
	self.m_EndEffect:SetParent(self.m_End.m_Transform)
	self.m_WinEffect:SetLocalPos(Vector3.New(0, 220, 0))
	self.m_EndEffect:SetLocalPos(Vector3.New(0, 220, 0))
	
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvnet"))
	UITools.ResizeToRootSize(self.m_Container)
end

function COrgFuBenResultView.OnShowView(self)
	self.m_WarID = nil

	self.m_DescLabel:SetText("")
	self.m_DelayCloseLabel:SetActive(false)
	self.m_Win:SetActive(false)
	self.m_End:SetActive(false)
	self.m_ItemPart:SetActive(false)
	self.m_ItemBox:SetActive(false)
	self.m_DelayCloseTimer = nil
	self.m_WarType = g_WarCtrl:GetWarType()
	if self.m_WarType == define.War.Type.EndlessPVE and not g_EndlessPVECtrl.m_ReceiveResult then
		self:SetActive(false)
	end
	netopenui.C2GSOpenInterface(define.OpenInterfaceType.WarResult)
end

function COrgFuBenResultView.OnWarEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.ResultInfo then
		self:RefeshAll()
	elseif oCtrl.m_EventID == define.War.Event.EndWar then
		CViewBase.CloseView(self)
	end
end

function COrgFuBenResultView.SetWarID(self, id)
	self.m_WarID = id
	self:RefeshAll()
end

function COrgFuBenResultView.RefeshAll(self)
	local dResultInfo = g_WarCtrl.m_ResultInfo
	if dResultInfo.war_id ~= self.m_WarID then
		return
	end
	self.m_ItemDatas = dResultInfo.item_list
	self:RefreshItemGrid()
	local sText = dResultInfo.desc or ""
	self.m_DescLabel:SetText(sText)
end

function COrgFuBenResultView.RefreshItemGrid(self)
	self.m_ItemGrid:Clear()
	for i, dItemInfo in ipairs(self.m_ItemDatas) do
		local oBox = self.m_ItemBox:Clone()
		oBox:SetActive(true)
		local config = {isLocal = true, uiType = 3}
		if  dItemInfo.virtual ~= 1010 then
			oBox:SetItemData(dItemInfo.sid, dItemInfo.amount, nil ,config)	
		else
			oBox:SetItemData(dItemInfo.virtual, dItemInfo.amount, dItemInfo.sid ,config)	
		end
		self.m_ItemGrid:AddChild(oBox)
	end
	self.m_ItemPart:SetActive(#self.m_ItemDatas > 0)
end

function COrgFuBenResultView.SetWin(self, bWin)
	self.m_Win:SetActive(bWin)
	self.m_End:SetActive(not bWin)
end

function COrgFuBenResultView.OrgFuBenWarEnd(self)
	g_WarCtrl:SetWarEndAfterCallback(function ()
		if g_OrgCtrl:HasOrg() then
				COrgMainView:ShowView(function ()
				COrgActivityCenterView:ShowView()
			end)
		end
	end)
	--self:CloseView()
end

function COrgFuBenResultView.CloseView(self)
	CViewBase.CloseView(self)
	g_WarCtrl:SetInResult(false)
end

function COrgFuBenResultView.SetDelayCloseView(self)
	if self.m_DelayCloseTimer ~= nil then
		Utils.DelTimer(self.m_DelayCloseTimer)
		self.m_DelayCloseTimer = nil
	end
	self.m_DelayCloseLabel:SetActive(true)
	local cnt = 0
	local function update()
		if Utils.IsNil(self) then
			return
		end
		local str = string.format("%ds后自动关闭", 3 - cnt)
		self.m_DelayCloseLabel:SetText(str)
		if cnt < 3 then
			cnt = cnt + 1
			return true
		end
		self:CloseView()
	end
	self.m_DelayCloseTimer = Utils.AddTimer(update, 1, 0)
end

function COrgFuBenResultView.Destroy(self)
	g_ViewCtrl:CloseInterface(define.OpenInterfaceType.WarResult)
	CViewBase.Destroy(self)
end

return COrgFuBenResultView
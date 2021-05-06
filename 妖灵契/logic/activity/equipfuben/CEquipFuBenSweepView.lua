local CEquipFuBenSweepView = class("CEquipFuBenSweepView", CViewBase)

function CEquipFuBenSweepView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/equipfuben/EquipFuBenSweepView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CEquipFuBenSweepView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	--self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_SweepScrollView = self:NewUI(3, CScrollView)
	self.m_SweepGrid = self:NewUI(4, CGrid)
	self.m_SweepBox = self:NewUI(5, CBox)
	self.m_SweepOneBtn = self:NewUI(6, CButton)
	self.m_SweepMoreBtn = self:NewUI(7, CButton)
	self.m_SweepScrollDrag = self:NewUI(8, CWidget)
	self.m_WaitWidget = self:NewUI(9, CWidget)
	self.m_TipsLabel = self:NewUI(10, CLabel)
	self.m_ScrollViewIdx = 1
	self.m_DeltaxX = 0
	self.m_BtnIsLock = false 
	self.m_IsItemTween = false
	self:InitContent()
end

function CEquipFuBenSweepView.InitContent(self)
	self.m_SweepBox:SetActive(false)
	--self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SweepOneBtn:AddUIEvent("click", callback(self, "OnSweepOneBtn"))
	self.m_SweepMoreBtn:AddUIEvent("click", callback(self, "OnSweepMoreBtn"))
	self.m_SweepScrollDrag:AddUIEvent("drag", callback(self, "OnDrag"))
	self.m_SweepScrollDrag:AddUIEvent("dragend", callback(self, "OnDragEnd"))
	g_EquipFubenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChapterFuBenEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
end

function CEquipFuBenSweepView.OnChapterFuBenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EquipFb.Event.SwpeepResult then
		if oCtrl.m_EventData then
			self:RefreshSweepResult(oCtrl.m_EventData)
		end
	end
end

function CEquipFuBenSweepView.OnAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
     	if oCtrl.m_EventData["dAttr"]["energy"] then
			self:RefreshSweepMoreBtn()
		end
	end
end

function CEquipFuBenSweepView.SetData(self, floorId, costItem, costEnergy, maxTime)
	self.m_FloorId = floorId
	self.m_CostItem = costItem
	self.m_CostEnergy = costEnergy
	self.m_MaxTime = maxTime or 99
	
	self:RefreshSweepMoreBtn()
	local buy_price = data.itemdata.OTHER[10030].buy_price
	self.m_TipsLabel:SetText(string.format("每次扫荡消耗#sdq%d或#w2%d", self.m_CostItem, self.m_CostItem * buy_price))
	self.m_TipsLabel:SetActive(not g_WelfareCtrl:HasZhongShengKa())	
end

function CEquipFuBenSweepView.RefreshSweepMoreBtn(self)
	local cnt = self:GetCanSweepCount()
	self.m_SweepMoreBtn:SetText(string.format("扫荡%d次", math.max(cnt, 2)))
	self.m_SweepMoreBtn:SetGrey(cnt < 2)
end

function CEquipFuBenSweepView.GetCanSweepCount(self)
	local sweepCount = 0
	sweepCount = math.min(math.floor(g_AttrCtrl.energy/self.m_CostEnergy), 5)	
	sweepCount = math.min(sweepCount, g_EquipFubenCtrl:GetFubenRemainTime())
	sweepCount = math.min(sweepCount, self.m_MaxTime)	
	return sweepCount	
end

function CEquipFuBenSweepView.OnSweepOneBtn(self, obj)
	self:CheckCanSweep(1)
end

function CEquipFuBenSweepView.OnSweepMoreBtn(self, obj)
	local sweepCount = math.max(self:GetCanSweepCount(), 2)
	self:CheckCanSweep(sweepCount)
end

--判断扫荡次数次数不足
function CEquipFuBenSweepView.CheckSweepCount(self, sweepCount)
	local b = true
	if sweepCount > g_EquipFubenCtrl:GetFubenRemainTime() then
		g_NotifyCtrl:FloatMsg("今日挑战次数已达上限")
		return false
	end
	return b
end

--判断扫荡体力
function CEquipFuBenSweepView.CheckSweepEnergy(self, sweepCount)
	local b = true
	local energy_cost = self.m_CostEnergy * sweepCount
	if g_AttrCtrl.energy < energy_cost then
		g_NotifyCtrl:FloatMsg("体力不足")
		if g_WelfareCtrl:IsFreeEnergyRedDot() then
			local windowConfirmInfo = {
				msg = "有未领取的体力，是否前往领取？",
				title = "提示",
				okCallback = function () 
					g_WelfareCtrl:ForceSelect(define.Welfare.ID.FreeEnergy)
				end,
				cancelCallback = function ()
					g_NpcShopCtrl:ShowGold2EnergyView()
				end,
				okStr = "确定",
				cancelStr = "取消",
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		else
			g_NpcShopCtrl:ShowGold2EnergyView()
		end
		return false
	end
	return b
end

function CEquipFuBenSweepView.CheckSweepItem(self, sweepCount)
	local b = true
	if g_WelfareCtrl:HasZhongShengKa() then
		return true
	end
	local itemCount = g_ItemCtrl:GetTargetItemCountBySid(10030)
	if itemCount < sweepCount * 2 then
		if g_WindowTipCtrl:IsShowTips("equipfubensweep111") then
			local cost = data.itemdata.OTHER[10030].buy_price
			local windowConfirmInfo = {
				msg				= string.format("扫荡券不足，是否花费#w2%d补足\n终身卡可免费扫荡", (sweepCount * 2 - itemCount) * cost),
				okCallback 		= function()
					self.m_ScrollViewIdx = sweepCount
					nethuodong.C2GSSweepEquipFB(self.m_FloorId, sweepCount)
				end,
				okStr			= "确认",
				selectdata		= {
					text = "今日内不再提示",
					CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "equipfubensweep111"),
				},
				thirdStr  		= "购买终身卡",
				thirdCallback  = function ()
					self:OnClose()
					g_WelfareCtrl:ForceSelect(define.Welfare.ID.Yk)
				end

			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
			return
		end
	end
	return b
end

function CEquipFuBenSweepView.SweepFunction(self, sweepCount)
	nethuodong.C2GSSweepEquipFB(self.m_FloorId, sweepCount)
end

function CEquipFuBenSweepView.CheckCanSweep(self, sweepCount)
	--动画播放中
	if self.m_BtnIsLock then
		g_NotifyCtrl:FloatMsg("正在扫荡中")
		return false
	end
	--次数判断
	if not self:CheckSweepCount(sweepCount) then
		return false
	end

	--体力不足
	if not self:CheckSweepEnergy(sweepCount) then
		return false
	end

	--扫荡卷不足
	if not self:CheckSweepItem(sweepCount) then
		return false
	end
	
	self.m_ScrollViewIdx = sweepCount
	self:SweepFunction(sweepCount)
	return true
end

function CEquipFuBenSweepView.OnDrag(self, obj, deltax)
	self.m_DeltaxX = deltax.x
end

function CEquipFuBenSweepView.OnDragEnd(self, obj, deltax)
	local idx = self.m_ScrollViewIdx
	if not self.m_BtnIsLock then
		if self.m_DeltaxX < -10 then
			self.m_ScrollViewIdx = self.m_ScrollViewIdx + 1
			self.m_ScrollViewIdx = math.min(self.m_ScrollViewIdx, 5)
			if self.m_ScrollViewIdx == idx then
				return
			else
				local oBox = self.m_SweepGrid:GetChild(self.m_ScrollViewIdx)
				if oBox then
					self.m_SweepScrollView:CenterOn(oBox.m_Transform)
				end
			end
		elseif self.m_DeltaxX > 10 then
			self.m_ScrollViewIdx = self.m_ScrollViewIdx - 1
			self.m_ScrollViewIdx = math.max(self.m_ScrollViewIdx, 1)
			if self.m_ScrollViewIdx == idx then
				return
			else
				local oBox = self.m_SweepGrid:GetChild(self.m_ScrollViewIdx)
				if oBox then
					self.m_SweepScrollView:CenterOn(oBox.m_Transform)
				end
			end
		end
	end
	self.m_DeltaxX = 0
end

function CEquipFuBenSweepView.RefreshSweepResult(self, dData)
	self.m_WaitWidget:SetActive(false)
	self.m_SweepScrollView:ResetPosition()
	self.m_SweepGrid:Clear()
	local resultlist = {}
	if dData.rewardList then
		for i,v in ipairs(dData.rewardList) do
			resultlist[i]={
				sweep_time = i,
				reward = v.item,
			}
		end
		self:ShowResult(resultlist)
	end
end

function CEquipFuBenSweepView.ShowResult(self, resultlist)
	self.m_SweepScrollView:ResetPosition()
	self.m_SweepGrid:Clear()
	for i,v in ipairs(resultlist) do
		local oBox = self:CreateSweepBox(v)
		oBox:SetActive(true)
		self.m_SweepGrid:AddChild(oBox)
	end
	self.m_SweepGrid:Reposition()
	
	if self.m_ScrollTimer then
		Utils.DelTimer(self.m_ScrollTimer)
		self.m_ScrollTimer = nil
	end
	self.m_BtnIsLock = true
	local idx = 1
	local function scroll()
		if Utils.IsNil(self) then
			self.m_BtnIsLock = false
			return
		end
		if idx > #resultlist then
			self.m_BtnIsLock = false
			return
		end
		local oBox = self.m_SweepGrid:GetChild(idx)
		self.m_SweepScrollView:CenterOn(oBox.m_Transform)
		idx = idx + 1
		return true
	end
	self.m_ScrollTimer = Utils.AddTimer(scroll, 0.5, 0.5)
end

function CEquipFuBenSweepView.CreateSweepBox(self, d)
	local oBox = self.m_SweepBox:Clone()
	oBox.m_ItemGrid = oBox:NewUI(1, CGrid)
	oBox.m_ItemBox = oBox:NewUI(2, CBox)
	oBox.m_CountLabel = oBox:NewUI(3, CLabel)
	oBox.m_ItemBox:SetActive(false)
	oBox.m_ItemList = {}
	oBox.m_CountLabel:SetText(string.format("第%d次", d.sweep_time))
	for i,v in ipairs(d.reward) do
		local box = oBox.m_ItemBox:Clone()
		box.m_ItemBox = box:NewUI(2, CItemRewardBox)
		box:SetActive(true)
		box.m_ItemBox:SetItemBySid(v.sid, v.amount)
		box.m_ItemBox:AddUIEvent("drag", callback(self, "OnDrag"))
		box.m_ItemBox:AddUIEvent("dragend", callback(self, "OnDragEnd"))
		oBox.m_ItemGrid:AddChild(box)
		table.insert(oBox.m_ItemList, box)
	end
	oBox.m_ItemGrid:Reposition()
	return oBox
end

function CEquipFuBenSweepView.SetLeftTime(self, leftTime)
	self.m_MaxTime = leftTime
	self:RefreshSweepMoreBtn()
end

return CEquipFuBenSweepView
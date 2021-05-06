local CChapterFuBenSweepView = class("CChapterFuBenSweepView", CViewBase)

function CChapterFuBenSweepView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/ChapterFuBen/ChapterFuBenSweepView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CChapterFuBenSweepView.OnCreateView(self)
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

function CChapterFuBenSweepView.InitContent(self)
	self.m_SweepBox:SetActive(false)
	--self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SweepOneBtn:AddUIEvent("click", callback(self, "OnSweepOneBtn"))
	self.m_SweepMoreBtn:AddUIEvent("click", callback(self, "OnSweepMoreBtn"))
	self.m_SweepScrollDrag:AddUIEvent("drag", callback(self, "OnDrag"))
	self.m_SweepScrollDrag:AddUIEvent("dragend", callback(self, "OnDragEnd"))
	g_ChapterFuBenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChapterFuBenEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
end

function CChapterFuBenSweepView.OnChapterFuBenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ChapterFuBen.Event.OnSweepChapterReward then
		if oCtrl.m_EventData then
			self:RefreshSweepResult(oCtrl.m_EventData)
		end
	elseif oCtrl.m_EventID == define.ChapterFuBen.Event.OnUpdateUpdateChapter then
		self:RefreshSweepMoreBtn()
	end
end

function CChapterFuBenSweepView.OnAttrEvent(self, oCtrl)
    if oCtrl.m_EventID == define.Attr.Event.Change then
     	if oCtrl.m_EventData["dAttr"]["energy"] then
			self:RefreshSweepMoreBtn()
		end
	end
end

function CChapterFuBenSweepView.SetChapterLevel(self, chapterid, level, type)
	self.m_ChapterID = chapterid
	self.m_Level = level
	self.m_ChapterType = type
	local dData = DataTools.GetChapterConfig(type, chapterid, level)
	local sweepCost = dData.sweep_cost
	local buy_price = data.itemdata.OTHER[10030].buy_price
	self.m_TipsLabel:SetText(string.format("每次扫荡消耗#sdq%s或#w2%s", sweepCost, buy_price * sweepCost))
	self:RefreshSweepMoreBtn()
end

function CChapterFuBenSweepView.RefreshSweepMoreBtn(self)
	self.m_SweepMoreBtn:SetText(string.format("扫荡%d次", math.max(self:GetCanSweepCount(), 1)))
end

function CChapterFuBenSweepView.GetCanSweepCount(self)
	local dConfig = DataTools.GetChapterConfig(self.m_ChapterType, self.m_ChapterID, self.m_Level)
	local energy_cost = dConfig.energy_cost
	local fight_time = dConfig.fight_time
	local dLevelInfo = g_ChapterFuBenCtrl:GetChapterLevelInfo(self.m_ChapterType, self.m_ChapterID, self.m_Level)
	local sweepCount = 0
	sweepCount = math.min(math.floor(g_AttrCtrl.energy/energy_cost), 5)
	sweepCount = math.min(sweepCount, (fight_time - dLevelInfo.fight_time))
	return sweepCount	
end

function CChapterFuBenSweepView.OnSweepOneBtn(self, obj)
	self:CheckCanSweep(1)
end

function CChapterFuBenSweepView.OnSweepMoreBtn(self, obj)
	local sweepCount = math.max(self:GetCanSweepCount(), 1)
	self:CheckCanSweep(sweepCount)
end

function CChapterFuBenSweepView.CheckCanSweep(self, sweepCount)
	--动画播放中
	if self.m_BtnIsLock then
		g_NotifyCtrl:FloatMsg("正在扫荡中")
		return false
	end
	--次数不足
	local dConfig = DataTools.GetChapterConfig(self.m_ChapterType, self.m_ChapterID, self.m_Level)
	local dLevelInfo = g_ChapterFuBenCtrl:GetChapterLevelInfo(self.m_ChapterType, self.m_ChapterID, self.m_Level)
	if sweepCount + dLevelInfo.fight_time > dConfig.fight_time then
		g_NotifyCtrl:FloatMsg("今日挑战次数已达上限")
		return false
	end
	--体力不足
	local energy_cost = dConfig.energy_cost * sweepCount
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
	--扫荡卷不足
	local itemCount = g_ItemCtrl:GetTargetItemCountBySid(10030)
	if itemCount < sweepCount then
		if g_WindowTipCtrl:IsShowTips("chapterfubensweep") then
			local buy_price = data.itemdata.OTHER[10030].buy_price
			local dData = DataTools.GetChapterConfig(self.m_ChapterType, self.m_ChapterID, self.m_Level)
			local sweep_cost = dData.sweep_cost
			local windowConfirmInfo = {
				msg				= string.format("扫荡券不足，是否花费#w2%d补足", (sweepCount - itemCount) * buy_price * sweep_cost),
				okCallback 		= function()
					self.m_ScrollViewIdx = sweepCount
					nethuodong.C2GSSweepChapterFb(self.m_ChapterID, self.m_Level, sweepCount, self.m_ChapterType)
				end,
				okStr			= "确认",
				selectdata		={
					text = "今日内不再提示",
					CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "chapterfubensweep")
				},
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
			return
		end
	end
	self.m_ScrollViewIdx = sweepCount
	nethuodong.C2GSSweepChapterFb(self.m_ChapterID, self.m_Level, sweepCount, self.m_ChapterType)
	return true
end

function CChapterFuBenSweepView.OnDrag(self, obj, deltax)
	self.m_DeltaxX = deltax.x
end

function CChapterFuBenSweepView.OnDragEnd(self, obj, deltax)
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

function CChapterFuBenSweepView.RefreshSweepResult(self, dData)
	self.m_WaitWidget:SetActive(false)
	if dData.chapter == self.m_ChapterID and dData.level == self.m_Level then
		self.m_SweepScrollView:ResetPosition()
		self.m_SweepGrid:Clear()
		local resultlist = {}
		if dData.reward then
			for i,v in ipairs(dData.reward) do
				local reward = {}
				if v.coin then
					local d = {
						sid = 1002,
						amount = v.coin,
					}
					table.insert(reward, d)
				end
				
				if v.player_exp then
					local d = {
						sid = 1005,
						amount = v.player_exp.gain_exp,
					}
					table.insert(reward, d)
				end
				
				if v.partner_exp and v.partner_exp[1] then
					local d = {
						sid = 1007,
						amount = v.partner_exp[1].gain_exp,
					}
					table.insert(reward, d)
				end

				if v.stable_reward then
					for _,d in ipairs(v.stable_reward) do
						table.insert(reward, d)
					end
				end
				if v.random_reward then
					for _,d in ipairs(v.random_reward) do
						table.insert(reward, d)
					end
				end
				resultlist[i]={
					sweep_time = v.sweep_time,
					reward = reward,
				}
			end
		self:ShowResult(resultlist)
		end
	end
end

function CChapterFuBenSweepView.ShowResult(self, resultlist)
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

function CChapterFuBenSweepView.CreateSweepBox(self, d)
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
		local config = {
			id = v.id,
			virtual = v.virtual,
		}
		box.m_ItemBox:SetItemBySid(v.sid, v.amount, config)
		box.m_ItemBox:AddUIEvent("drag", callback(self, "OnDrag"))
		box.m_ItemBox:AddUIEvent("dragend", callback(self, "OnDragEnd"))
		oBox.m_ItemGrid:AddChild(box)
		table.insert(oBox.m_ItemList, box)
	end
	oBox.m_ItemGrid:Reposition()
	return oBox
end

return CChapterFuBenSweepView
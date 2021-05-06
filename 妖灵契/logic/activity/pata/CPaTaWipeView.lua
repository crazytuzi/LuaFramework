local CPaTaWipeView = class("CPaTaWipeView", CViewBase)

CPaTaWipeView.UIMode =
{	
	Wipe = 1,
	Reward = 2,
	WipeEnd = 3,
}


function CPaTaWipeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/pata/PaTaWipeView.prefab", cb)
	--self.m_ExtendClose = "Shelter"
end

function CPaTaWipeView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CSprite)
	self.m_WipeOutBtn = self:NewUI(2, CButton)
	self.m_QuickWipeOutBtn = self:NewUI(3, CButton)
	self.m_TitleLabel = self:NewUI(4, CLabel)
	self.m_TimeLabel = self:NewUI(5, CLabel)
	self.m_AwardGrid = self:NewUI(6, CGrid)
	self.m_AwardCloneBox = self:NewUI(7, CItemTipsBox)
	self.m_CloseBtn = self:NewUI(8, CButton)
	self.m_TispLabel = self:NewUI(9, CLabel)
	self.m_OkBtn = self:NewUI(10, CButton)
	self.m_WipeOutCostLabel = self:NewUI(11, CLabel)
	self.m_MaskBox = self:NewUI(12, CBox)
	self.m_ContentWidget = self:NewUI(13, CBox)

	self.m_WipeOutTimer = nil
	self.m_UIMode = nil

	self:InitContent()	

	UITools.ResizeToRootSize(self.m_MaskBox)
end

function CPaTaWipeView.InitContent(self)
	local oView = CPaTaView:GetView()
	if oView and oView.m_IsOpenAni == true then
		self.m_Container:SetActive(false)
	else
		self.m_Container:SetActive(true)
	end
	self.m_AwardCloneBox:SetActive(false)
	self.m_WipeOutBtn:AddUIEvent("click", callback(self, "OnWipeOut"))
	self.m_QuickWipeOutBtn:AddUIEvent("click", callback(self, "OnQuickWipeOut"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_MaskBox:AddUIEvent("click", callback(self, "OnMaskClose"))

	g_PataCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlPataEvent"))
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMapEvent"))
end

function CPaTaWipeView.OnWipeOut(self)
	g_PataCtrl:PaTaWipeOut()
end

function CPaTaWipeView.OnQuickWipeOut(self)
	local cost = tonumber(self.m_WipeOutCostLabel:GetText())
	if cost and cost > g_AttrCtrl.goldcoin then
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
	else
		g_PataCtrl:PaTaFastWipeOut()
	end
end

function CPaTaWipeView.OnGetFirstReward(self, level)
	g_PataCtrl:PaTaGetFristReward(level)
end

function CPaTaWipeView.OnGetWipeOutReward(self)
	g_PataCtrl:PaTaGetWipeOutReward()
	self:CloseView()
end

function CPaTaWipeView.CustomCloseView(self)
	self:CloseView()
	CPaTaView:CloseView()
end

function CPaTaWipeView.ShowWipeOut(self)
	self.m_WipeOutBtn:SetActive(true)
	self.m_QuickWipeOutBtn:SetActive(true)
	self.m_OkBtn:SetActive(false)
	self.m_CloseBtn:SetActive(false)
	self.m_TispLabel:SetText("预计获得:")
	self:SetBgSize(CPaTaWipeView.UIMode.Wipe)
	self.m_UIMode = CPaTaWipeView.UIMode.Wipe

	local cost_per_floor = tonumber(data.globaldata.GLOBAL.pata_sweep_cost.value) 
	local wipeOutEndLevel = g_PataCtrl:GetWipdOutEndlevel()
	if wipeOutEndLevel > CPataCtrl.MaxLevel then
		wipeOutEndLevel = CPataCtrl.MaxLevel
	end
	if g_PataCtrl:IsWipeOuting() then 
		self.m_TitleLabel:SetText(string.format("扫荡到%d层",  wipeOutEndLevel))		
		self.m_TimeLabel:SetText(string.format("所需时间:%s", g_PataCtrl:GetWipeOutRemainTimeString()))

		if self.m_WipeOutTimer ~= nil then
			Utils.DelTimer(self.m_WipeOutTimer)
			self.m_WipeOutTimer = nil
		end

		local function timeUpdate()
			local str = g_PataCtrl:GetWipeOutRemainTimeString()
			local time = g_PataCtrl:GetWipeOutRemainTime()
			local cost = math.ceil(time / 15) * cost_per_floor
			self.m_WipeOutCostLabel:SetText(tostring(cost))
			if str ~= "" then			
				self.m_TimeLabel:SetText(string.format("所需时间:%s", str))
				return true
			else
				return false
			end
		end
		local str = g_PataCtrl:GetWipeOutRemainTimeString()
		local time = g_PataCtrl:GetWipeOutRemainTime()
		local cost = math.ceil(time / 15) * cost_per_floor
		self.m_WipeOutCostLabel:SetText(tostring(cost))		
		self.m_WipeOutTimer = Utils.AddTimer(timeUpdate, 0, 1)	

	else
		local cost_gold = (g_PataCtrl:GetWipdOutEndlevel() - g_PataCtrl.m_CurLevel) * cost_per_floor
		self.m_WipeOutCostLabel:SetText(tostring(cost_gold))		
		self.m_TitleLabel:SetText(string.format("扫荡到%d层",  wipeOutEndLevel))
		self.m_TimeLabel:SetText(string.format("预计时间:%s", g_PataCtrl:GetPreviewWipeOutEndTimeString()))
	end

	self.m_AwardGrid:Clear()
	local reward = g_PataCtrl:GetProviewRewardList()

	if next(reward) ~= nil then
		for k, v in ipairs(reward) do
			local oItem = CItem.NewBySid(v.sid)
			local oBox = self.m_AwardCloneBox:Clone()
			oBox:SetActive(true)
			local config = {isLocal = true,}
			oBox:SetItemData(v.sid, v.count, nil, config)
			self.m_AwardGrid:AddChild(oBox)
		end
	end
end

function CPaTaWipeView.ShowWipeOutEnd(self, curLevel)
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnGetWipeOutReward"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "CustomCloseView"))
	self.m_CloseBtn:SetActive(true)
	self.m_WipeOutBtn:SetActive(false)
	self.m_QuickWipeOutBtn:SetActive(false)
	self.m_OkBtn:SetActive(true)
	self.m_TispLabel:SetText("累计获得:")
	self.m_UIMode = CPaTaWipeView.UIMode.WipeEnd

	if curLevel then
		if curLevel > CPataCtrl.MaxLevel then
			curLevel = CPataCtrl.MaxLevel
		end
		self.m_TitleLabel:SetText(string.format("扫荡到%d层",  curLevel))
	else
		local wipeOutEndLevel = g_PataCtrl:GetWipdOutEndlevel()
		if wipeOutEndLevel > CPataCtrl.MaxLevel then
			wipeOutEndLevel = CPataCtrl.MaxLevel
		end
		self.m_TitleLabel:SetText(string.format("扫荡到%d层",  wipeOutEndLevel))	
	end
	self.m_TimeLabel:SetActive(false)
	self:SetBgSize(CPaTaWipeView.UIMode.Reward)
	self.m_AwardGrid:Clear()
	local reward = g_PataCtrl.m_WipeOutRewardList or {}
	if next(reward) ~= nil then
		for k, v in ipairs(reward) do
			local oBox = self.m_AwardCloneBox:Clone()
			oBox:SetActive(true)
			local config = {isLocal = true,}
			oBox:SetItemData(v.shape, v.amount, nil, config)
			self.m_AwardGrid:AddChild(oBox)
		end
	end

end

function CPaTaWipeView.ShowFirstReward(self, level)
	self.m_OkBtn:AddUIEvent("click", callback(self, "OnGetFirstReward", level))
	self.m_WipeOutBtn:SetActive(false)
	self.m_QuickWipeOutBtn:SetActive(false)
	self.m_OkBtn:SetActive(true)
	self.m_CloseBtn:SetActive(false)
	self.m_UIMode = CPaTaWipeView.UIMode.Reward
	self.m_OkBtn:SetActive(g_PataCtrl:IsHaveFirstReward(level) == 1)
	self.m_TispLabel:SetText("首通奖励:")
	self.m_TitleLabel:SetText(string.format("第%d关奖励", level))	
	self.m_TimeLabel:SetActive(false)
	self:SetBgSize(CPaTaWipeView.UIMode.Reward)
	self.m_AwardGrid:Clear()
	local reward = g_PataCtrl:GetFirstRewardListByLevel(level)
	if reward and next(reward) ~= nil then
		for k, v in ipairs(reward) do
			local oBox = self.m_AwardCloneBox:Clone()
			oBox:SetActive(true)
			local config = {isLocal = true,}
			oBox:SetItemData(v.sid, v.count, nil, config)
			self.m_AwardGrid:AddChild(oBox)
		end
	end
end

function CPaTaWipeView.OnCtrlPataEvent(self, oCtrl)
	if oCtrl.m_EventID == define.PaTa.Event.WipeOutBegin then
		self:ShowWipeOut()
	elseif oCtrl.m_EventID == define.PaTa.Event.WipeOutEnd then
		if self.m_WipeOutTimer ~= nil then
			Utils.DelTimer(self.m_WipeOutTimer)
			self.m_WipeOutTimer = nil
		end
		self:ShowWipeOutEnd()
	elseif oCtrl.m_EventID == define.PaTa.Event.FirstReWard then
		self:CloseView()
	end
end

function CPaTaWipeView.Destroy(self)
	if self.m_WipeOutTimer ~= nil then
		Utils.DelTimer(self.m_WipeOutTimer)
		self.m_WipeOutTimer = nil
	end
	--关闭画面时，就确认奖励已经查看过
	g_PataCtrl:CtrlWipeOutRewardConfirm()
	CViewBase.Destroy(self)
end

function CPaTaWipeView.SetBgSize(self, mode)
	if mode == CPaTaWipeView.UIMode.Wipe then
		self.m_Container:SetSize(568, 414)
		self.m_Container:SetLocalPos(Vector3.New(0, 210, 0))
		self.m_ContentWidget:SetLocalPos(Vector3.New(0, -196, 0))
	else
		self.m_Container:SetSize(568, 390)
		self.m_Container:SetLocalPos(Vector3.New(0, 192, 0))
		self.m_ContentWidget:SetLocalPos(Vector3.New(0, -160, 0))
	end
end

function CPaTaWipeView.OnMaskClose(self)
	if self.m_UIMode == CPaTaWipeView.UIMode.Wipe or self.m_UIMode == CPaTaWipeView.UIMode.Reward then
		self:OnClose()
	end
end

function CPaTaWipeView.OnCtrlMapEvent( self, oCtrl )
	if oCtrl.m_EventID == define.Map.Event.MapLoadDone then
		if g_TeamCtrl:IsInTeam() then
			self:CloseView()
		end
	end
end
 
return CPaTaWipeView
local CLimitDrawPage = class("CLimitDrawPage", CPageBase)

CLimitDrawPage.Poiner = {
		Ready = 1, 		--指针准备
		Rotate = 2,		--指针旋转
		SubSpeed = 3,	--指针减速
		Stop 	= 4,	--指针停止
}
CLimitDrawPage.Angles = {
		[1] = 360,
		[2] = 315,
		[3] = 270,
		[4] = 225,
		[5] = 180,
		[6] = 135,
		[7] = 90,
		[8] = 45,
}

function CLimitDrawPage.ctor(self, cb)
	CPageBase.ctor(self, cb)

	self.m_Poiner = CLimitDrawPage.Poiner.Ready
	self.m_Result = nil
	self.m_Type = nil --1是常规，2是npc
	self.m_Full = nil --true是保底，flase是常规
end

function CLimitDrawPage.OnInitPage(self)
	self.m_ZiSeTexture = self:NewUI(1, CTexture)
	self.m_JinSeTexture = self:NewUI(2, CTexture)
	self.m_ZiSeBtn = self:NewUI(3, CButton)
	self.m_JinSeBtn = self:NewUI(4, CButton) 
	self.m_PoinerSprite = self:NewUI(5, CSprite)
	self.m_RestLabel = self:NewUI(6, CLabel)
	self.m_RewardTable = self:NewUI(7, CTable)
	self.m_DescLabel = self:NewUI(8, CLabel)
	self.m_StarEffNode = self:NewUI(9, CWidget)
	self.m_LightEffNode = self:NewUI(10, CWidget)
	self.m_BaoEffNode = self:NewUI(11, CWidget)
	self.m_RewardPanel = self:NewUI(12, CPanel)
	self:InitContent()
end

function CLimitDrawPage.InitContent(self)
	self.m_StarEffNode:SetActive(false)
	self.m_LightEffNode:SetActive(false)
	self.m_BaoEffNode:SetActive(false)

	self:InitEffect("Effect/UI/ui_eff_1155/Prefabs/ui_ctg_1155_xingxing.prefab", self.m_StarEffNode)
	self:InitEffect("Effect/UI/ui_eff_1155/Prefabs/ui_ctg_1155_guang.prefab", self.m_LightEffNode)
	self:InitEffect("Effect/UI/ui_eff_1155/Prefabs/ui_eff_1155_bao.prefab", self.m_BaoEffNode)

	self.m_ZiSeBtn:AddUIEvent("click", callback(self, "OnOperateBtn"))
	self.m_JinSeBtn:AddUIEvent("click", callback(self, "OnOperateBtn"))

	self.m_RewardTable:InitChild(function (obj, idx)
			local oBox = CItemTipsBox.New(obj)
			return oBox
		end)
end

function CLimitDrawPage.OnShowPage(self)
	netfuli.C2GSGetLuckDrawInfo()
end

function CLimitDrawPage.InitEffect(self, sPath, oNode, oAttach)
	local ref = weakref(self)
	local function onpkeffload(oClone, errcode)
		local oAttach = getrefobj(ref)
		if oClone and oAttach then
			local oEff = CObject.New(oClone)
			oEff:SetParent(oNode.m_Transform)
			local mPanel = oClone:GetMissingComponent(classtype.UIPanel)
			mPanel.uiEffectDrawCallCount = 1
			local mRenderQ = oClone:GetMissingComponent(classtype.UIEffectRenderQueue)
			oEff.m_RenderQComponent = mRenderQ
			mRenderQ.needClip = true
			mRenderQ.attachGameObject = oAttach.m_GameObject
		else
			return false
		end
	end
	g_ResCtrl:LoadCloneAsync(sPath, onpkeffload)
end

function CLimitDrawPage.UpdateDrawData(self, iCnt, dRewardList, iCost)
	self.m_RestAmount = iCnt
	self.m_Cost = iCost
	if iCnt and iCnt > 0 then
		self.m_RestLabel:SetText(string.format("剩余%d次", self.m_RestAmount))
	else
		self.m_RestLabel:SetText(string.format("#w2%d", iCost))
	end
	local rewardList = self:GetRewardList(dRewardList)
	for i, oBox in ipairs(self.m_RewardTable:GetChildList()) do
		local data = rewardList[i]
		oBox.m_Idx = data.idx
		if data then
			oBox:SetItemData(data.sid, 1, nil, {isLocal = true, uiType=1})
			oBox.m_QualitySprite:SetActive(false)
			--oBox.m_IconSprite:SetSize(100, 100)
			local oItem = CItem.NewBySid(data.sid)
			--重新注册响应
			local tExtend = {
				itemshape = oItem:GetValue("icon"),
				name = data.name,
				desc = data.desc,
			}
			oBox:AddUIEvent("click", callback(self, "ShowEventTips", 0, tExtend))
		end
	end
end

function CLimitDrawPage.GetRewardList(self, dRewardList)
	local dRwardData = data.welfaredata.LuckyDrawData
	local dClientRewardList = {}
	for i, id in ipairs(dRewardList) do
		local d = {}
		d.sid = dRwardData[id].sid
		d.id = dRwardData[id].id
		d.name = dRwardData[id].name
		d.desc = dRwardData[id].desc
		d.idx = i
		table.insert(dClientRewardList, d)
	end
	return dClientRewardList
end

function CLimitDrawPage.ShowEventTips(self, iType, tExtend, obj)
	if self.m_LightEffNode:GetActive() then
		return
	end
	if iType == 0 then
		g_WindowTipCtrl:SetPreviewItemWindow(tExtend,
			{widget = obj, side = enum.UIAnchor.Side.Center ,offset = Vector2.New( -10, 30)})
	elseif iType == 1 then
		g_WindowTipCtrl:SetPreviewItemWindow(tExtend,
			{widget = obj, side = enum.UIAnchor.Side.Center ,offset = Vector2.New( -10, 30)})
	end
end

function CLimitDrawPage.UpdateDrawResult(self, iPos, iCnt, iCost)
	self.m_Result = iPos
	self.m_RestAmount = iCnt
	self.m_Cost = iCost
	if iCnt and iCnt > 0 then
		self.m_RestLabel:SetText(string.format("剩余%d次", self.m_RestAmount))
	else
		self.m_RestLabel:SetText(string.format("#w2%d", iCost))
	end
end

function CLimitDrawPage.GetDrawResult(self)
	return self.m_Result
end

function CLimitDrawPage.PoinerSubSpeed(self)
	self.m_ZiSeBtn:SetEnabled(false)
	self.m_JinSeBtn:SetEnabled(false)
	self.m_ZiSeBtn:SetGrey(true)
	self.m_JinSeBtn:SetGrey(true)
	self.m_Poiner = CLimitDrawPage.Poiner.SubSpeed
end

function CLimitDrawPage.WaitAction(self)
	--最长10秒后执行self:PoinerSubSpeed()
	local weakid = weakref(self)
	Utils.AddTimer(objcall(self, function(obj) 
		if obj.m_Poiner == CLimitDrawPage.Poiner.Rotate then
			obj:PoinerSubSpeed()
		end
	end), 0, 6)
	
end

function CLimitDrawPage.PoinerRotate(self)
	if self.m_PoinerTimer then
		Utils.DelTimer(self.m_PoinerTimer)
		self.m_PoinerTimer = nil
	end
	local angle = 0
	local interval = 20
	local function rotate()
		if Utils.IsNil(self) then
			self.m_PoinerTimer = nil
			return
		end
		self.m_PoinerSprite:SetLocalRotation(Quaternion.Euler(0,0,angle))
		angle = angle - interval
		if angle < 0 then
			angle = 360 + angle --转换成 [0,360]
		end
		if self.m_Poiner == CLimitDrawPage.Poiner.SubSpeed then
			interval = math.max(3, interval - 0.2)
			if interval == 3 then
				local result, oBox = self:GetRewardItem()
				angle = math.floor(angle)
				if result and angle + 3 >= result and angle - 3 <= result then
					self.m_PoinerSprite:SetLocalRotation(Quaternion.Euler(0,0,result))
					self.m_Poiner = CLimitDrawPage.Poiner.Stop
					self:EndRotation()
					self:GetReward()
					return false
				end
			end
		end
		return true
	end
	self.m_PoinerTimer = Utils.AddTimer(rotate, 0, 0)
end

function CLimitDrawPage.EndRotation(self)
	self.m_Result = nil
	self.m_Poiner = CLimitDrawPage.Poiner.Ready
	self.m_ZiSeBtn:SetText("开始")
	self.m_JinSeBtn:SetText("开始")
	self.m_ZiSeBtn:SetEnabled(true)
	self.m_JinSeBtn:SetEnabled(true)
	self.m_ZiSeBtn:SetGrey(false)
	self.m_JinSeBtn:SetGrey(false)
	self.m_RestLabel:SetActive(true)
	self.m_ParentView:SetLock(false)
end

function CLimitDrawPage.ResetBegin(self)
	
end

function CLimitDrawPage.CloseView(self)
	CViewBase.CloseView(self)
end

function CLimitDrawPage.GetRewardItem(self)
	local angleIdx, oItem = 1, self.m_RewardTable:GetChildList()[1]
	local resultIdx = self:GetDrawResult()
	for i,oBox in ipairs(self.m_RewardTable:GetChildList()) do
		if oBox.m_Idx == resultIdx then
			angleIdx = i
			oItem = oBox
			break
		end
	end
	local angle = CLimitDrawPage.Angles[angleIdx]
	return angle, oItem
end

function CLimitDrawPage.GetReward(self)
	netfuli.C2GSGiveLuckDraw()
end

CLimitDrawPage.Cost = 100
function CLimitDrawPage.OnOperateBtn(self, oBtn)
	local iReady = CLimitDrawPage.Poiner.Ready
	local iRotate = CLimitDrawPage.Poiner.Rotate
	local iPoiner = self.m_Poiner
	if self.m_RestAmount == nil then
		return
	end
	if iPoiner == iReady or  iPoiner == CLimitDrawPage.Poiner.Stop then
		if self.m_RestAmount < 1 and g_WindowTipCtrl:IsShowTips("draw_limitreward_tip") then
			local windowConfirmInfo = {
				msg				= string.format("是否消耗#w2%d开动转盘？", self.m_Cost),
				okCallback		= callback(self, "OnStart"),
				selectdata		={
					text = "今日内不再提示",
					CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "draw_limitreward_tip")
				},
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
			
		else
			self:OnStart()
		end
	
	elseif iPoiner == iRotate then
		self:PoinerSubSpeed()
	end
end

function CLimitDrawPage.OnStart(self)
	if self.m_RestAmount < 1 and g_AttrCtrl.goldcoin < self.m_Cost then
		g_WindowTipCtrl:ShowNoGoldTips(2)
		return
	end
	local iReady = CLimitDrawPage.Poiner.Ready
	local iRotate = CLimitDrawPage.Poiner.Rotate
	local iPoiner = self.m_Poiner
	self.m_Poiner = iRotate
	self.m_StarEffNode:SetActive(true)
	self.m_ZiSeBtn:SetText("停止")
	self.m_JinSeBtn:SetText("停止")
	self.m_RestLabel:SetActive(false)
	self:PoinerRotate()
	self:WaitAction()
	local iType = 1
	if self.m_RestAmount < 1 then
		iType = 2
	end
	netfuli.C2GSStartLuckDraw(iType)
	self.m_ParentView:SetLock(true)
end

return CLimitDrawPage
local CHuntPartnerSoulView = class("CHuntPartnerSoulView", CViewBase)

function CHuntPartnerSoulView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/HuntPartnerSoulView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_GroupName = "main"
	self.m_IsAlwaysShow = true
end

function CHuntPartnerSoulView.OnCreateView(self)
	self.m_HelpBtn = self:NewUI(1, CButton)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_OneKeyPickBtn = self:NewUI(3, CButton)
	self.m_OneKeyHuntBtn = self:NewUI(4, CButton)
	self.m_SellAllBtn = self:NewUI(5, CButton)
	self.m_RefreshTimeLabel = self:NewUI(6, CCountDownLabel)
	self.m_Container = self:NewUI(7, CWidget)
	self.m_CallBtn = self:NewUI(8, CButton)
	self.m_RefreshCostLabel = self:NewUI(9, CLabel)
	-- self.m_BackBtn = self:NewUI(10, CButton)
	self.m_ItemGrid = self:NewUI(11, CGrid)
	self.m_ItemBox = self:NewUI(12, CBox)
	self.m_NpcGrid = self:NewUI(13, CGrid)
	self.m_NpcBox = self:NewUI(14, CBox)
	self.m_GoldCoinLabel = self:NewUI(15, CLabel)
	self.m_CoinLabel = self:NewUI(16, CLabel)
	self.m_AutoSellBtn = self:NewUI(17, CButton)
	self.m_FreeLabel = self:NewUI(18, CLabel)
	self.m_TweenObj = self.m_CallBtn:GetComponent(classtype.TweenScale)
	self:InitContent()
end

function CHuntPartnerSoulView.InitContent(self)
	self.m_CanHunt = true
	self.m_OneKeyTimerID = nil
	self.m_ItemBoxArr = {}
	self.m_MaxItemCnt = self.m_ItemGrid:GetMaxPerLine() * 3
	self.m_RefreshLevel = 4
	self.m_RefreshData = data.huntdata.DATA[self.m_RefreshLevel]
	UITools.ResizeToRootSize(self.m_Container)
	self.m_ItemBox:SetActive(false)
	self.m_AutoSellBtn:ForceSelected(g_HuntPartnerSoulCtrl:IsAutoSell())
	self.m_AutoSellBtn:AddUIEvent("click", callback(self, "OnAutoSell"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnHelp"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OneKeyPickBtn:AddUIEvent("click", callback(self, "OnOneKeyPick"))
	self.m_OneKeyHuntBtn:AddUIEvent("click", callback(self, "OnOneKeyHunt"))
	self.m_SellAllBtn:AddUIEvent("click", callback(self, "OnSellAll"))
	self.m_CallBtn:AddUIEvent("click", callback(self, "OnCallBtn"))
	-- self.m_BackBtn:AddUIEvent("click", callback(self, "OnBack"))
	g_HuntPartnerSoulCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHuntEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	self:InitNpc()
	self:SetData()
	self.m_CallBtn:SetText(self.m_RefreshData.name)
	self.m_RefreshTimeLabel:SetTickFunc(callback(self, "OnCount"))
	self.m_RefreshTimeLabel:SetTimeUPCallBack(callback(self, "OnTimeUp"))
	self:CheckCost()
	self.m_RefreshCostLabel:SetText(string.format("#w2%s", self.m_RefreshData.activate_cost))
	self:RefreshCoin()
	self:RefreshNpc()
end

function CHuntPartnerSoulView.CheckCost(self)
	if g_HuntPartnerSoulCtrl:GetRefreshTime() > 0 then
		self.m_RefreshCostLabel:SetActive(true)
		self.m_FreeLabel:SetActive(false)
	else
		self.m_RefreshCostLabel:SetActive(false)
		self.m_FreeLabel:SetActive(true)
	end
	self.m_RefreshTimeLabel:BeginCountDown(g_HuntPartnerSoulCtrl:GetRefreshTime())
end

function CHuntPartnerSoulView.OnShowView(self)
	self:RefreshCallBtn()
end

function CHuntPartnerSoulView.RefreshCallBtn(self)
	if g_HuntPartnerSoulCtrl:HasRedDot() then
		self.m_TweenObj.enabled = true
	else
		self.m_TweenObj.enabled = false
		self.m_CallBtn:SetLocalScale(Vector3.one)
	end
end

function CHuntPartnerSoulView.OnAutoSell(self)
	if self.m_AutoSellBtn:GetSelected() then
		nethuodong.C2GSSetHuntAutoSale(0)
	else
		nethuodong.C2GSSetHuntAutoSale(1)
		g_HuntPartnerSoulCtrl:OneKeySale()
	end
end

function CHuntPartnerSoulView.RefreshCoin(self)
	self.m_GoldCoinLabel:SetNumberString(g_AttrCtrl.goldcoin)
	self.m_CoinLabel:SetNumberString(g_AttrCtrl.coin)
end

function CHuntPartnerSoulView.OnCount(self, iValue)
	self.m_RefreshTimeLabel:SetText(string.format("%s后免费", g_TimeCtrl:GetLeftTime(iValue)))
end

function CHuntPartnerSoulView.OnTimeUp(self)
	self.m_RefreshCostLabel:SetActive(false)
	self.m_FreeLabel:SetActive(true)
end

function CHuntPartnerSoulView.SetData(self)
	local oData = g_HuntPartnerSoulCtrl:GetSoulList()
	local count = 1
	for i,v in ipairs(oData) do
		if self.m_ItemBoxArr[i] == nil then
			self.m_ItemBoxArr[i] = self:CreateItemBox()
			self.m_ItemGrid:AddChild(self.m_ItemBoxArr[i])
		end
		self.m_ItemBoxArr[i]:SetData(v)
		self.m_ItemBoxArr[i]:SetActive(true)
		count = count + 1

		if i == 1 then
			g_GuideCtrl:AddGuideUI("hunt_partner_soul_1_1_btn", self.m_ItemBoxArr[i])
		end
	end

	for i = count, #self.m_ItemBoxArr do
		self.m_ItemBoxArr[i]:SetActive(false)
	end
	self.m_ItemGrid:Reposition()
end

function CHuntPartnerSoulView.InitNpc(self)
	local oData = data.huntdata.DATA
	self.m_NpcBoxArr = {}
	for i,v in ipairs(oData) do
		self.m_NpcBoxArr[i] = self:CreateNpcBox()
		self.m_NpcGrid:AddChild(self.m_NpcBoxArr[i])
		self.m_NpcBoxArr[i]:SetData(v)
		if i == 1 then
			g_GuideCtrl:AddGuideUI("hunt_partner_soul_list_1_btn", self.m_NpcBoxArr[i])
		end
	end
	self.m_NpcBox:SetActive(false)
end

function CHuntPartnerSoulView.RefreshNpc(self)
	local oInfoList = g_HuntPartnerSoulCtrl:GetNpcList()
	for i,v in ipairs(self.m_NpcBoxArr) do
		self.m_NpcBoxArr[i]:SetSelect(oInfoList[i])
	end
end

function CHuntPartnerSoulView.CreateItemBox(self)
	local oItemBox = self.m_ItemBox:Clone()
	oItemBox.m_IconSprite = oItemBox:NewUI(1, CSprite)
	oItemBox.m_BoderSprite = oItemBox:NewUI(2, CSprite)
	oItemBox.m_AttrSprite = oItemBox:NewUI(3, CSprite)
	oItemBox.m_NameLabel = oItemBox:NewUI(4, CLabel)
	oItemBox.m_Effect1 = oItemBox:NewUI(5, CBox)
	oItemBox.m_Effect2 = oItemBox:NewUI(6, CBox)
	oItemBox.m_Effect3 = oItemBox:NewUI(7, CUIEffect)

	oItemBox.m_Effect3:SetActive(false)
	oItemBox.m_Effect1:SetActive(false)
	oItemBox.m_Effect2:SetActive(false)

	oItemBox:AddUIEvent("click", callback(self, "OnPickItem", oItemBox))
	oItemBox:AddUIEvent("longpress", callback(self, "OnShowItem", oItemBox))
	function oItemBox.SetData(self, oData)
		oItemBox.m_Data = oData
		local oItemData = data.itemdata.PAR_SOUL[oData.id]
		if oItemData then
			oItemBox.m_AttrSprite:SetActive(true)
			oItemBox.m_IconSprite:SpriteItemShape(oItemData.icon)
			oItemBox.m_BoderSprite:SetSpriteName("pic_yuling_" .. oItemData.soul_quality)
			oItemBox.m_AttrSprite:SetSpriteName("pic_parattr_" .. oItemData.attr_type)
			local sName = string.replace(oItemData.name, "·", "\n")
			oItemBox.m_NameLabel:SetText(sName)
			oItemBox.m_Effect3:SetActive(oItemData.soul_quality >= 4)
		elseif oData.type == 2 then
			oItemBox.m_AttrSprite:SetActive(false)
			oItemBox.m_BoderSprite:SetSpriteName("pic_yuling_1")
			oItemBox.m_IconSprite:SpriteItemShape(269)
			oItemBox.m_NameLabel:SetText("灵气渣")
			oItemBox.m_Effect3:SetActive(false)
		else
			oItemBox.m_Effect3:SetActive(false)
			oItemBox.m_NameLabel:SetText(oData.id .. " ,type: "..  oData.type)
		end
	end

	function oItemBox.Show(self)
		oItemBox.m_Effect1:SetActive(true)
		oItemBox.m_Effect2:SetActive(true)
		oItemBox.m_Effect3:Above(oItemBox.m_BoderSprite)
	end
	oItemBox:DelayCall(0, "Show")
	return oItemBox
end

function CHuntPartnerSoulView.OnPickItem(self, oItemBox)
	nethuodong.C2GSPickUpSoul(oItemBox.m_Data.createtime, oItemBox.m_Data.id)
end

function CHuntPartnerSoulView.OnShowItem(self, oItemBox)
	--如果在引导界面中，长按则和点击效果一样
	if CGuideView:GetView() then
		self:OnPickItem(oItemBox)
		g_GuideCtrl:Continue()
		return
	end
	local oItem = CItem.NewBySid(oItemBox.m_Data.id)
	if oItemBox.m_Data.type == 1 then
		g_WindowTipCtrl:SetWindowItemTipsPartnerSoulInfo(oItem, {isLink = true, hideBtn = true})
	elseif oItemBox.m_Data.type == 2 then
		g_WindowTipCtrl:SetWindowItemTipsSellItemInfo(oItem)
	end
end

function CHuntPartnerSoulView.CreateNpcBox(self)
	local oNpcBox = self.m_NpcBox:Clone()
	oNpcBox.m_SelectSprite = oNpcBox:NewUI(1, CSprite)
	oNpcBox.m_AvatarSprite = oNpcBox:NewUI(2, CSprite)
	oNpcBox.m_NameLabel = oNpcBox:NewUI(3, CLabel)
	oNpcBox.m_CostLabel = oNpcBox:NewUI(4, CLabel)
	oNpcBox.m_TopMarkSprite = oNpcBox:NewUI(5, CBox)
	oNpcBox.m_ColorGrid = oNpcBox:NewUI(6, CGrid)
	oNpcBox.m_ColorArr = {}
	oNpcBox.m_ColorGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oNpcBox.m_ColorArr[idx] = oBox
		return oBox
	end)
	oNpcBox:AddUIEvent("click", callback(self, "OnClickNpc", oNpcBox))

	function oNpcBox.SetData(self, oData)
		oNpcBox.m_Data = oData
		oNpcBox.m_TopMarkSprite:SetActive(oData.level == 5)

		for i = 1, #oNpcBox.m_ColorArr do
			oNpcBox.m_ColorArr[i]:SetActive(table.index(oData.color, i) ~= nil)
		end
		
		oNpcBox.m_PreData = data.huntdata.DATA[oData.level - 1] or {}
		oNpcBox.m_AvatarSprite:SetSpriteName(string.format("pic_npc_%s_2", oData.level))
		oNpcBox.m_SelectSprite:SetSpriteName(string.format("pic_npc_%s_1", oData.level))
		oNpcBox.m_NameLabel:SetText(oData.name)
		oNpcBox.m_CostLabel:SetText(string.format("#w1%s", oData.hunt_cost))
	end

	function oNpcBox.SetSelect(self, bValue)
		oNpcBox.m_IsOn = bValue
		oNpcBox.m_SelectSprite:SetActive(bValue)
	end
	return oNpcBox
end

function CHuntPartnerSoulView.OnHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("huntpartnersoul")
	end)
end

function CHuntPartnerSoulView.CanHunt(self, oNpcBox)
	if not oNpcBox.m_IsOn then
		self:DelTimer()
		g_NotifyCtrl:FloatMsg(string.format("%s未激活，在%s处进行猎灵时有概率激活", oNpcBox.m_Data.name, oNpcBox.m_PreData.name or ""))
		return false
	elseif self:IsFull() then
		self:DelTimer()
		g_NotifyCtrl:FloatMsg("列表数量已满")
		return false
	elseif oNpcBox.m_Data.hunt_cost > g_AttrCtrl.coin then
		self:DelTimer()
		g_NotifyCtrl:FloatMsg("您的金币不足")
		g_NpcShopCtrl:ShowGold2CoinView()
		return false
	end
	return true
end

function CHuntPartnerSoulView.OnClickNpc(self, oNpcBox)
	if self:CanHunt(oNpcBox) then
		--新手新到时，特殊获取一个猎灵
		if g_GuideCtrl:IsInTargetGuide("HuntPartnerSoulView") then
			--return
		end
		if self.m_CanHunt == false then
			g_NotifyCtrl:FloatMsg("操作过于频繁")
			return
		end
		self.m_CanHunt = false
		g_HuntPartnerSoulCtrl:Hunt(oNpcBox.m_Data.level)
	end
end

function CHuntPartnerSoulView.DelTimer(self)
	if self.m_OneKeyTimerID ~= nil then
		self.m_OneKeyHuntBtn:SetText("一键猎灵")
		self.m_OneKeyHuntBtn:SetSpriteName("btn_putong_anniu")
		Utils.DelTimer(self.m_OneKeyTimerID)
		self.m_OneKeyTimerID = nil
	end
end

function CHuntPartnerSoulView.IsFull(self)
	return self.m_MaxItemCnt <= #g_HuntPartnerSoulCtrl:GetSoulList()
end

function CHuntPartnerSoulView.OnOneKeyPick(self)
	g_HuntPartnerSoulCtrl:OneKeyPick()
end

function CHuntPartnerSoulView.OnOneKeyHunt(self)
	if self.m_OneKeyTimerID == nil then
		self.m_OneKeyTimerID = Utils.AddTimer(callback(self, "UpdateHunt"), 0.3, 0)
	else
		self:DelTimer()
	end
end

function CHuntPartnerSoulView.UpdateHunt(self)
	if self.m_CanHunt == false then
		return true
	end
	local oNpcBox = self.m_NpcBoxArr[1]
	for i,v in ipairs(self.m_NpcBoxArr) do
		if v.m_IsOn then
			oNpcBox = v
		end
	end

	if self:CanHunt(oNpcBox) then
		self.m_OneKeyHuntBtn:SetText("停止猎灵")
		self.m_OneKeyHuntBtn:SetSpriteName("btn_putong_xuanzhong")
		self.m_CanHunt = false
		g_HuntPartnerSoulCtrl:Hunt(oNpcBox.m_Data.level)
		return true
	else
		return false
	end
end

function CHuntPartnerSoulView.OnSellAll(self)
	if not g_HuntPartnerSoulCtrl:OneKeySale() then
		g_NotifyCtrl:FloatMsg("当前列表未发现灵气渣")
	end
end

function CHuntPartnerSoulView.OnCallBtn(self)
	if self.m_NpcBoxArr[self.m_RefreshLevel].m_IsOn then
		g_NotifyCtrl:FloatMsg(string.format("%s当前已处于激活状态", self.m_RefreshData.name))
	elseif self.m_RefreshTimeLabel.m_CurrentValue > 0 then
		if self.m_RefreshData.activate_cost > g_AttrCtrl.goldcoin then
			self:DelTimer()
			g_NotifyCtrl:FloatMsg("您的水晶不足")
			g_SdkCtrl:ShowPayView()
		else
			nethuodong.C2GSCallHuntNpc(1)
		end
	else
		nethuodong.C2GSCallHuntNpc(0)
	end
end

-- function CHuntPartnerSoulView.OnBack(self)
-- 	printc("OnBack")
-- 	self:OnClose()
-- end

function CHuntPartnerSoulView.OnHuntEvent(self, oCtrl)
	if oCtrl.m_EventID == define.HuntPartnerSoul.Event.OnAddPartnerSoul then
		self:SetData()
	elseif oCtrl.m_EventID == define.HuntPartnerSoul.Event.OnDelPartnerSoul then
		self:SetData()
	elseif oCtrl.m_EventID == define.HuntPartnerSoul.Event.UpdateHuntInfo then
		self:SetData()
		self:RefreshNpc()
		self:CheckCost()
		self:RefreshCallBtn()
	elseif oCtrl.m_EventID == define.HuntPartnerSoul.Event.OnUpdateTime then
		self:RefreshCallBtn()
	elseif oCtrl.m_EventID == define.HuntPartnerSoul.Event.UpdateNpc then
		Utils.AddTimer(function ()
			self.m_CanHunt = true
		end, 0.3, 0)
	end
end

function CHuntPartnerSoulView.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshCoin()
	end
end

return CHuntPartnerSoulView
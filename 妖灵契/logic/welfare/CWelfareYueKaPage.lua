local CWelfareYueKaPage = class("CWelfareYueKaPage", CPageBase)

function CWelfareYueKaPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CWelfareYueKaPage.OnInitPage(self)
	self.m_YkBuyBtn = self:NewUI(1, CButton)
	-- self.m_YkGetBtn = self:NewUI(2, CButton)
	self.m_YkLeftLabel = self:NewUI(2, CLabel)
	-- self.m_YkGetTipLabel = self:NewUI(4, CLabel)
	-- self.m_YkGetPart = self:NewUI(5, CObject)


	self.m_ZskBuyBtn = self:NewUI(3, CButton)
	self.m_BuyMark = self:NewUI(4, CLabel)
	-- self.m_ZskGetBtn = self:NewUI(7, CButton)
	-- self.m_ZskGetTipLabel = self:NewUI(8, CLabel)
	-- self.m_ZskGetPart = self:NewUI(9, CObject)

	self.m_YkDescLabel = self:NewUI(5, CLabel)
	self.m_ZskDescLabel = self:NewUI(6, CLabel)
	self.m_YkDetailBtn = self:NewUI(7, CLabel)
	self.m_ZskDetailBtn = self:NewUI(8, CLabel)
	self.m_YkItemGrid = self:NewUI(9, CGrid)
	self.m_ZskItemGrid = self:NewUI(10, CGrid)
	self.m_ItemTipsBox = self:NewUI(11, CItemTipsBox)

	self.m_YkBuyBtn:AddUIEvent("click", callback(self, "OnBuyYk"))
	self.m_ZskBuyBtn:AddUIEvent("click", callback(self, "OnBuyZsk"))
	-- self.m_YkGetBtn:AddUIEvent("click", callback(self, "OnGetYk"))
	-- self.m_ZskGetBtn:AddUIEvent("click", callback(self, "OnGetZsk"))
	self.m_YkDetailBtn:AddUIEvent("click", callback(self, "OnYkDetial"))
	self.m_ZskDetailBtn:AddUIEvent("click", callback(self, "OnZskDetial"))

	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self.m_YkDescLabel:SetText(data.welfaredata.WelfareControl[define.Welfare.ID.Yk].short_desc)
	self.m_ZskDescLabel:SetText(data.welfaredata.WelfareControl[define.Welfare.ID.Zsk].short_desc)
	self:RefreshYkState()
	self:RefreshZskState()
	self:InitItemGrid()
end

function CWelfareYueKaPage.InitItemGrid(self)
	for i,v in ipairs(data.welfaredata.WelfareControl[define.Welfare.ID.Yk].item_list) do
		local oItemTipsBox = self.m_ItemTipsBox:Clone()
		self.m_YkItemGrid:AddChild(oItemTipsBox)
		oItemTipsBox:SetSid(v.sid, v.amount, {isLocal = true, uiType = 2})
		oItemTipsBox:SetActive(true)
	end
	for i,v in ipairs(data.welfaredata.WelfareControl[define.Welfare.ID.Zsk].item_list) do
		local oItemTipsBox = self.m_ItemTipsBox:Clone()
		self.m_ZskItemGrid:AddChild(oItemTipsBox)
		oItemTipsBox:SetSid(v.sid, v.amount, {isLocal = true, uiType = 2})
		if i == 3 then
			oItemTipsBox.m_IconSprite:AddEffect("circle")
		end
		oItemTipsBox:SetActive(true)
	end
end

function CWelfareYueKaPage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnYueKa then
		local dData = oCtrl.m_EventData
		local oInfo = nil
		if dData.key == "yk" then
			oInfo = data.npcstoredata.RechargeStore[1009]
			self:RefreshYkState()
		elseif dData.key == "zsk" then
			oInfo = data.npcstoredata.RechargeStore[1010]
			self:RefreshZskState()
		end
		if oInfo and #oInfo.random_talk > 0 then
			-- CGuideView:ShowView(function (oView)
			-- 	oView:ShowShopTalk(oInfo)
			-- end)
			Utils.AddTimer(function ()
				CThanksView:ShowView()
			end, 0.03, 0.03)
		end
	end
end

function CWelfareYueKaPage.OnYkDetial(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("yueka")
	end)
	-- CYueKaDetailView:ShowView(function(oView) 
	-- 		oView:SetDetail(data.welfaredata.WelfareControl[define.Welfare.ID.Yk].desc)
	-- 	end)
end

function CWelfareYueKaPage.OnZskDetial(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("zhongshenka")
	end)
	-- CYueKaDetailView:ShowView(function(oView) 
	-- 		oView:SetDetail(data.welfaredata.WelfareControl[define.Welfare.ID.Zsk].desc)
	-- 	end)
end

-- function CWelfareYueKaPage.OnGetYk(self)
-- 	nethuodong.C2GSChargeCardReward("yk")
-- end

-- function CWelfareYueKaPage.OnGetZsk(self)
-- 	nethuodong.C2GSChargeCardReward("zsk")
-- end

function CWelfareYueKaPage.RefreshYkState(self)
	if g_WelfareCtrl:HasYueKa() then
		-- self.m_YkGetPart:SetActive(true)
		-- local bCanGet = (g_WelfareCtrl:GetYueKaData("yk", "val") == 1)
		-- self.m_YkGetBtn:SetActive(bCanGet)
		-- self.m_YkGetTipLabel:SetActive(not bCanGet)
		
		local iLeft = g_WelfareCtrl:GetYueKaData("yk", "left_count")
		self.m_YkLeftLabel:SetText(string.format("剩余%d天到期", iLeft))
		self.m_YkLeftLabel:SetActive(true)
	else
		self.m_YkLeftLabel:SetActive(false)
		-- self.m_YkGetPart:SetActive(false)
	end
end

function CWelfareYueKaPage.RefreshZskState(self)
	if g_WelfareCtrl:HasZhongShengKa() then
		self.m_ZskBuyBtn:SetActive(false)
		self.m_BuyMark:SetActive(true)
		-- self.m_ZskGetPart:SetActive(true)
		-- local bCanGet = (g_WelfareCtrl:GetYueKaData("zsk", "val") == 1)
		-- self.m_ZskGetBtn:SetActive(bCanGet)
		-- self.m_ZskGetTipLabel:SetActive(not bCanGet)
	else
		self.m_ZskBuyBtn:SetActive(true)
		self.m_BuyMark:SetActive(false)
		-- self.m_ZskGetPart:SetActive(false)
	end
end

function CWelfareYueKaPage.OnBuyYk(self)
	local key
	if g_LoginCtrl:IsSdkLogin() then
		if Utils.IsAndroid() then
			key = "com.kaopu.ylq.yk"
		elseif Utils.IsIOS() then
			key = "com.kaopu.ylq.appstore.yk"
		end
	end
	if key then
		g_SdkCtrl:Pay(key, 1)
	else
		if Utils.IsDevUser() and Utils.IsEditor() then
			netother.C2GSGMCmd(string.format("huodong charge 201"))
			g_NotifyCtrl:FloatMsg("直接调用GM指令，超级高危操作！！！只用于测试")
		else
			g_NotifyCtrl:FloatMsg("当前环境不支持购买")
		end
	end
end

function CWelfareYueKaPage.OnBuyZsk(self)
	local key
	if g_LoginCtrl:IsSdkLogin() then
		if Utils.IsAndroid() then
			key = "com.kaopu.ylq.zsk"
		elseif Utils.IsIOS() then
			key = "com.kaopu.ylq.appstore.zsk"
		end
	end
	if key then
		g_SdkCtrl:Pay(key, 1)
	else
		if Utils.IsDevUser() and Utils.IsEditor() then
			netother.C2GSGMCmd(string.format("huodong charge 202"))
			g_NotifyCtrl:FloatMsg("直接调用GM指令，超级高危操作！！！只用于测试")
		else
			g_NotifyCtrl:FloatMsg("当前环境不支持购买")
		end
	end
end

return CWelfareYueKaPage
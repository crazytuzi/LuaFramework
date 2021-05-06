local CCzjjPage = class("CCzjjPage", CPageBase)

--成长基金
function CCzjjPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CCzjjPage.OnInitPage(self)
	self.m_BuyBtn = self:NewUI(1, CSprite)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_BoxClone = self:NewUI(3, CCzjjBox)
	self.m_NumYuanBox = self:NewUI(4, CSprNumberBox)
	self.m_NumBeiBox = self:NewUI(5, CSprNumberBox)
	self.m_NumYuanBox:SetPrefix("pic_numyuan_")
	self.m_NumBeiBox:SetPrefix("pic_numbei_")
	self.m_BoxClone:SetActive(false)
	self.m_BuyBtn:AddUIEvent("click", callback(self, "OnBuy"))
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:RefreshBuyState()
	self:RefreshGrid()
	self:RefreshNumber()
end

function CCzjjPage.RefreshNumber(self)
	self.m_NumYuanBox:SetNumber(98)
	self.m_NumBeiBox:SetNumber(7)
end

function CCzjjPage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnCzjj then
		local dData = oCtrl.m_EventData
		if dData.key == "buy_flag" then
			self:RefreshBuyState()
			local oInfo = data.npcstoredata.RechargeStore[1011]
			if oInfo and #oInfo.random_talk > 0 then
				-- CGuideView:ShowView(function (oView)
				-- 	oView:ShowShopTalk(oInfo)
				-- end)
				Utils.AddTimer(function ()
					CThanksView:ShowView()
				end, 0.03, 0.03)
			end
		else
			self:RefreshGrid()
		end
	end
end

function CCzjjPage.RefreshBuyState(self)
	local bGrey = g_WelfareCtrl:IsBuyCzjj()
	-- self.m_BuyBtn:SetGrey(bGrey)
	-- self.m_BuyBtn:SetEnabled(not bGrey)
	if bGrey then
		self.m_BuyBtn:UITweenStop()
	end
	self.m_BuyBtn:SetSpriteName(bGrey and "pic_goumaichenggong" or "pic_dianjigoumai")
end

function CCzjjPage.OnBuy(self, oBtn)
	if g_WelfareCtrl:IsBuyCzjj() then
		g_NotifyCtrl:FloatMsg("你已经购买过了")
		return
	end
	local key
	if g_LoginCtrl:IsSdkLogin() then
		if Utils.IsAndroid() then
			key = "com.kaopu.ylq.czjj"
		elseif Utils.IsIOS() then
			key = "com.kaopu.ylq.appstore.czjj"
		end
	end
	if key then
		g_SdkCtrl:Pay(key, 1)
	else
		if Utils.IsDevUser() and Utils.IsEditor() then
			netother.C2GSGMCmd(string.format("huodong charge 301"))
			g_NotifyCtrl:FloatMsg("直接调用GM指令，超级高危操作！！！只用于测试")
		else
			g_NotifyCtrl:FloatMsg("当前环境不支持购买")
		end
	end
end

function CCzjjPage.RefreshGrid(self)
	local lDatas = table.values(data.chargedata.CZJJ_DATA)
	local function sortfunc(d1, d2)
		local v1 = g_WelfareCtrl:IsGetCzjjReward(d1.key) and 1 or 0
		local v2 = g_WelfareCtrl:IsGetCzjjReward(d2.key) and 1 or 0
		if v1 == v2 then
			return d1.grade < d2.grade
		else
			return v1 < v2
		end
	end
	table.sort(lDatas, sortfunc)
	self.m_Grid:Clear()
	for i, dData in ipairs(lDatas) do
		local oBox = self.m_BoxClone:Clone()
		oBox:SetActive(true)
		oBox:SetData(dData)
		self.m_Grid:AddChild(oBox)
	end
	self.m_Grid:Reposition()
end

return CCzjjPage
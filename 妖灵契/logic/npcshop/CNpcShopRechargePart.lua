local CNpcShopRechargePart = class("CNpcShopRechargePart", CBox)

function CNpcShopRechargePart.ctor(self, ob)
	CBox.ctor(self, ob)
	self:InitContent()
end

function CNpcShopRechargePart.InitContent(self)
	self.m_TableGrid = self:NewUI(1, CGrid)
	self.m_TableSprite = self:NewUI(2, CSprite)
	self.m_ItemGrid = self:NewUI(3, CGrid)
	self.m_ItemCell = self:NewUI(4, CBox)
	self.m_TipsLabel = self:NewUI(5, CLabel)
	self.m_Platform = 1
	self.m_TableCellPool = {}
	self.m_CbKeyToData = {}
	self:SetTips()
	self:SetData()
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvent"))
	g_NpcShopCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
end

function CNpcShopRechargePart.SetTips(self)
	local sChannel = g_SdkCtrl:GetChannelId()
	local sGameType = Utils.GetGameType()
	local oData = data.npcstoredata.RechargeQQ
	printc("渠道: " .. sChannel)
	printc("包名: " .. sGameType)
	if oData[sChannel] then
		local sQQ = oData[sChannel].qq
		self.m_TipsLabel:SetRichText(string.format("充值遇到问题请联系客服QQ公众号：%s", LinkTools.GenerateCopyLink(sQQ, sQQ)))
	else
		self.m_TipsLabel:SetRichText("")
	end
end

function CNpcShopRechargePart.SetData(self)
	self.m_Data = data.npcstoredata.RechargeStore

	self.m_SortData = {}
	for k,v in pairs(self.m_Data) do
		if self:CanShowShenhe(v.id) then
			if v.payid == "com.kaopu.ylq.001" then
				if Utils.IsDevUser() or (Utils.IsEditor() and v.platform == self.m_Platform) then
					table.insert(self.m_SortData, v)
				end
			else
				if (Utils.IsAndroid() and v.platform == 1) 
					or (Utils.IsIOS() and v.platform == 2) 
					or ((not Utils.IsAndroid()) and (not Utils.IsIOS()) and v.platform == self.m_Platform) then
						table.insert(self.m_SortData, v)
				end
			end
			self.m_CbKeyToData[v.front_str .. v.id] = v
		end
	end
	local function sortFunc(v1, v2)
		return v1.sort_id < v2.sort_id
	end
	table.sort(self.m_SortData, sortFunc)

	self.m_ItemBoxArr = {}
	self.m_ItemCell:SetActive(false)
	self.m_TableSprite:SetActive(false)
	for i,v in ipairs(self.m_SortData) do
		local oItemBox = self:CreateItemCell()
		self.m_ItemGrid:AddChild(oItemBox)
		oItemBox:SetActive(true)
		self.m_ItemBoxArr[i] = oItemBox
		oItemBox:SetData(v)
	end

	self:Refresh()
end

function CNpcShopRechargePart.CanShowShenhe(self, id)
	-- local dServer = g_LoginCtrl:GetConnectServer()
	-- if dServer and dServer.server_id == "iosshenhe_gs10001" then
	-- 	local cantShowList = {2008, 2009, 2010, 1009, 1010, 1011}
	-- 	if table.index(cantShowList, id) then
	-- 		return false
	-- 	else
	-- 		return true
	-- 	end
	-- end

	return true
end

function CNpcShopRechargePart.CreateItemCell(self)
	local oItemBox = self.m_ItemCell:Clone()
	oItemBox.m_NameLabel = oItemBox:NewUI(1, CLabel)
	oItemBox.m_ItemSprite = oItemBox:NewUI(2, CSprite)
	oItemBox.m_CostLabel = oItemBox:NewUI(3, CLabel)
	oItemBox.m_DescLabel = oItemBox:NewUI(4, CLabel)
	oItemBox.m_LimitSprite = oItemBox:NewUI(5, CSprite)
	oItemBox.m_Effect = oItemBox:NewUI(6, CUIEffect)
	
	oItemBox:AddUIEvent("click", callback(self, "OnClickPay", oItemBox))

	function oItemBox.SetData(self, oData)
		oItemBox.m_Data = oData
		oItemBox.m_IsYueKa = oItemBox.m_Data.mark == 2
		oItemBox.m_IsZhongShenKa = oItemBox.m_Data.mark == 3
		oItemBox.m_IsJiJin = oItemBox.m_Data.mark == 4
		oItemBox.m_NameLabel:SetText(oData.name)
		oItemBox.m_ItemSprite:SetSpriteName(oData.icon)
		oItemBox.m_CostLabel:SetText(string.format("%s元", oData.RMB))
		oItemBox.m_DescLabel:SetText(oData.desc)
		oItemBox.m_Effect:Above(oItemBox.m_ItemSprite)
	end

	function oItemBox.Refresh(self)
		local oInfo = g_NpcShopCtrl:GetPayInfo(oItemBox.m_Data.front_str .. oItemBox.m_Data.id)
		local markStr = ""
		oItemBox.m_DescLabel:SetActive(true)
		oItemBox.m_SortID = oItemBox.m_Data.sort_id
		if oItemBox.m_IsYueKa then
			if g_WelfareCtrl:HasYueKa() then
				markStr = "text_chongzhikexu"
				oItemBox.m_SortID = 100
			else
				markStr = "text_jian"
				oItemBox.m_SortID = -103
			end
		elseif oItemBox.m_IsZhongShenKa then
			if g_WelfareCtrl:HasZhongShengKa() then
				-- oItemBox.m_SortID = 101
				-- markStr = "text_dangqianyongyou"
				-- oItemBox.m_DescLabel:SetActive(false)
				oItemBox:SetActive(false)
			else
				oItemBox.m_SortID = -102
				markStr = "text_jian"
			end
		elseif oItemBox.m_IsJiJin then
			if g_WelfareCtrl:IsBuyCzjj() then
				oItemBox:SetActive(false)
			else
				oItemBox.m_SortID = -101
				markStr = "text_jian"
			end
		else
			if oInfo and oInfo.val >= 1 then
				oItemBox.m_DescLabel:SetActive(false)
			else
				markStr = "text_shoucifanbei"
			end
		end
		oItemBox.m_LimitSprite:SetSpriteName(markStr)
		oItemBox.m_LimitSprite:SetActive(markStr ~= "")
		oItemBox.m_LimitSprite:MakePixelPerfect()
	end

	return oItemBox
end

function CNpcShopRechargePart.OnClickPay(self, oItemBox)
	if oItemBox.m_IsYueKa then
		g_WelfareCtrl:ForceSelect(define.Welfare.ID.Yk)
	elseif oItemBox.m_IsZhongShenKa then
		g_WelfareCtrl:ForceSelect(define.Welfare.ID.Yk)
	elseif oItemBox.m_IsJiJin then
		g_WelfareCtrl:ForceSelect(define.Welfare.ID.Czjj)
	elseif g_LoginCtrl:IsSdkLogin() then
		g_SdkCtrl:Pay(oItemBox.m_Data.payid, 1)
	else
		if Utils.IsDevUser() and Utils.IsEditor() then
			netother.C2GSGMCmd(string.format("huodong charge 401 %s", oItemBox.m_Data.id))
			g_NotifyCtrl:FloatMsg("直接调用GM指令，超级高危操作！！！只用于测试")
		else
			g_NotifyCtrl:FloatMsg("当前环境不支持购买")
		end
	end
end

function CNpcShopRechargePart.Refresh(self)
	for k,v in pairs(self.m_ItemBoxArr) do
		v:Refresh()
	end
	local function sortFunc(v1, v2)
		return v1.m_SortID < v2.m_SortID
	end
	table.sort(self.m_ItemBoxArr, sortFunc)
	for i,v in ipairs(self.m_ItemBoxArr) do
		v:SetAsLastSibling()
	end
	local tableNum = math.ceil(self.m_ItemGrid:GetCount() / self.m_ItemGrid:GetMaxPerLine())

	for i = 1, tableNum do
		if self.m_TableCellPool[i] == nil then
			self.m_TableCellPool[i] = self.m_TableSprite:Clone()
			self.m_TableGrid:AddChild(self.m_TableCellPool[i])
		end
		self.m_TableCellPool[i]:SetActive(true)
	end
	tableNum = tableNum + 1
	for i = tableNum, #self.m_TableCellPool do
		self.m_TableCellPool[i]:SetActive(false)
	end
	self.m_ItemGrid:Reposition()
end

function CNpcShopRechargePart.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Store.Event.RefreshPayInfo then
		self:Refresh()
		self:PlayAni(oCtrl.m_EventData)
	end
end

function CNpcShopRechargePart.OnWelfareEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnYueKa then
		self:Refresh()
	elseif oCtrl.m_EventID == define.Welfare.Event.OnCzjj then
		self:Refresh()
	end
end

function CNpcShopRechargePart.PlayAni(self, oInfo)
	-- local oInfo = self.m_CbKeyToData[oInfo.key]
	-- if oInfo and #oInfo.random_talk > 0 then
	-- 	CGuideView:ShowView(function (oView)
	-- 		oView:ShowShopTalk(oInfo)
	-- 	end)
	-- end
	Utils.AddTimer(function ()
		CThanksView:ShowView()
	end, 0.03, 0.03)
end

return CNpcShopRechargePart
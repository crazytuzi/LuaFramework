local CYiYuanLiBaoPage = class("CYiYuanLiBaoPage", CPageBase)

function CYiYuanLiBaoPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CYiYuanLiBaoPage.OnInitPage(self)
	self.m_InfoGrid = self:NewUI(1, CGrid)
	self.m_InfoBox = self:NewUI(2, CBox)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_TimeLabel = self:NewUI(4, CLabel)
	self:InitContent()
end

function CYiYuanLiBaoPage.InitContent(self)
	self.m_InfoBoxArr = {}
	self.m_InfoBox:SetActive(false)
	self:SetData()
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvnet"))
end

function CYiYuanLiBaoPage.SetData(self)
	local sStart = os.date("%Y.%m.%d", g_WelfareCtrl.m_YiYuanLiBaoStartTime)
	local sEnd = os.date("%Y.%m.%d", g_WelfareCtrl.m_YiYuanLiBaoEndTime)
	self.m_TimeLabel:SetText(string.format("%s-%s", sStart, sEnd))
	local oData = {}
	for k,v in pairs(data.welfaredata.YiYuanLiBao) do
		if g_WelfareCtrl.m_YiYuanLiBaoInfo[v.id] then
			table.insert(oData, v)
		end
	end
	local function sortFunc(v1, v2)
		return v1.price < v2.price
	end
	table.sort(oData, sortFunc)

	self.m_InfoBoxDic = {}
	for i,v in ipairs(oData) do
		if self.m_InfoBoxArr[i] == nil then
			self.m_InfoBoxArr[i] = self:CreateInfoBox()
			self.m_InfoGrid:AddChild(self.m_InfoBoxArr[i])
		end
		self.m_InfoBoxDic[v.id] = self.m_InfoBoxArr[i]
		self.m_InfoBoxArr[i]:SetData(v)
		self.m_InfoBoxArr[i]:SetActive(true)
	end
	for i = #oData + 1, #self.m_InfoBoxArr do
		self.m_InfoBoxArr[i]:SetActive(false)
	end
	self:Refresh()
end

function CYiYuanLiBaoPage.CreateInfoBox(self)
	local oInfoBox = self.m_InfoBox:Clone()
	oInfoBox.m_ItemGrid = oInfoBox:NewUI(1, CGrid)
	oInfoBox.m_ItemTipsBox = oInfoBox:NewUI(2, CItemTipsBox)
	oInfoBox.m_SubmitBtn = oInfoBox:NewUI(3, CButton)
	oInfoBox.m_GotMark = oInfoBox:NewUI(4, CBox)
	oInfoBox.m_SubmitBtn:SetActive(false)
	oInfoBox.m_GotMark:SetActive(false)
	oInfoBox.m_SubmitBtn:AddUIEvent("click", callback(self, "OnSubmit", oInfoBox))
	oInfoBox.m_GotMark:AddUIEvent("click", callback(self, "OnGotMark"))
	
	oInfoBox.m_ItemBoxArr = {}

	function oInfoBox.SetData(self, oData)
		oInfoBox.m_Data = oData

		for i,v in ipairs(oData.itemlist) do
			if oInfoBox.m_ItemBoxArr[i] == nil then
				oInfoBox.m_ItemBoxArr[i] = oInfoBox.m_ItemTipsBox:Clone()
				oInfoBox.m_ItemGrid:AddChild(oInfoBox.m_ItemBoxArr[i])
			end
			oInfoBox.m_ItemBoxArr[i]:SetActive(true)
			oInfoBox.m_ItemBoxArr[i]:SetSid(v.sid, v.amount, {isLocal = true,  uiType = 1})
		end
		oInfoBox.m_SubmitBtn:SetText(string.format("%s元购买", oData.price))
		for i=#oData.itemlist + 1, #oInfoBox.m_ItemBoxArr do
			oInfoBox.m_ItemBoxArr[i]:SetActive(false)
		end
	end

	function oInfoBox.Refresh(self)
		if g_WelfareCtrl:IsBuyYiYuanToday(oInfoBox.m_Data.id) then
			oInfoBox.m_SubmitBtn:SetActive(false)
			oInfoBox.m_GotMark:SetActive(true)
		else
			oInfoBox.m_SubmitBtn:SetActive(true)
			oInfoBox.m_GotMark:SetActive(false)
		end
	end

	return oInfoBox
end

function CYiYuanLiBaoPage.Refresh(self)
	for i = 1, #self.m_InfoBoxArr do
		self.m_InfoBoxArr[i]:Refresh()
	end
end

function CYiYuanLiBaoPage.OnSubmit(self, oInfoBox)
	if g_LoginCtrl:IsSdkLogin() then
		if Utils.IsAndroid() then
			g_SdkCtrl:Pay(oInfoBox.m_Data.payid, 1, {request_value = tostring(oInfoBox.m_Data.id), request_key = "one_RMB_gift"})
		elseif Utils.Utils.IsIOS() then
			g_SdkCtrl:Pay(oInfoBox.m_Data.iospayid, 1, {request_value = tostring(oInfoBox.m_Data.id), request_key = "one_RMB_gift"})
		else
			g_NotifyCtrl:FloatMsg("当前环境不支持购买")
		end
	elseif Utils.IsDevUser() and Utils.IsEditor() then
		netother.C2GSGMCmd(string.format("huodong oneRMBgift 101 %s", oInfoBox.m_Data.id))
		g_NotifyCtrl:FloatMsg("直接调用GM指令，超级高危操作！！！只用于测试")
	else
		g_NotifyCtrl:FloatMsg("当前环境不支持购买")
	end
end

function CYiYuanLiBaoPage.OnGotMark(self)
	g_NotifyCtrl:FloatMsg("每天只能购买1次哦")
end

function CYiYuanLiBaoPage.OnWelfareEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnUpdateYiYuanLiBaoList then
		self:SetData()
	elseif oCtrl.m_EventID == define.Welfare.Event.OnUpdateYiYuanLiBao then
		if self.m_InfoBoxDic[oCtrl.m_EventData.key] then
			self.m_InfoBoxDic[oCtrl.m_EventData.key]:Refresh()
		end
	end
end

return CYiYuanLiBaoPage
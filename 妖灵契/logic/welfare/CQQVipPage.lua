local CQQVipPage = class("CQQVipPage", CPageBase)

function CQQVipPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CQQVipPage.OnInitPage(self)
	self.m_TipBtn = self:NewUI(1, CButton)
	self.m_InfoGrid = self:NewUI(2, CGrid)
	self.m_InfoBox = self:NewUI(3, CBox)
	self.m_InputLabel = self:NewUI(4, CInput)
	self.m_GetBtn = self:NewUI(5, CButton)
	self.m_InfoBox:SetActive(false)
	self.m_GetBtn:AddUIEvent("click", callback(self, "OnGetCode"))
	self.m_InputLabel:SetForbidChars({"-"})
	self:SetContent()
end

function CQQVipPage.SetContent(self)
	self.m_TipBtn:AddHelpTipClick("qqvip")
	local d = data.welfaredata.QQVip
	local list = {10004, 10005}
	self.m_InfoGrid:Clear()
	for _, idx in ipairs(list) do
		local oBox = self:CreateInfoBox()
		self:RefreshInfoData(oBox, d[idx])
		self.m_InfoGrid:AddChild(oBox)
	end
	self.m_InfoGrid:Reposition()
end

function CQQVipPage.CreateInfoBox(self)
	local oBox = self.m_InfoBox:Clone()
	oBox.m_OpenBtn = oBox:NewUI(1, CButton)
	oBox.m_ItemTipBox = oBox:NewUI(2, CItemTipsBox)
	oBox.m_TitleLabel = oBox:NewUI(3, CLabel)
	oBox.m_ValueLabel = oBox:NewUI(4, CLabel)
	oBox.m_ItemGrid = oBox:NewUI(5, CGrid)
	oBox:SetActive(true)
	return oBox
end

function CQQVipPage.RefreshInfoData(self, oBox, dData)
	oBox.m_TitleLabel:SetText(dData.des)
	oBox.m_ValueLabel:SetText(tostring(dData.value).."#w2")
	oBox.m_OpenBtn:AddUIEvent("click", callback(self, "OnOpenVip", dData))
	oBox.m_ItemGrid:Clear()
	if dData.title > 0 then
		local oItemBox = oBox.m_ItemTipBox:Clone()
		oItemBox:SetActive(true)
		oItemBox:SetTitle(dData.title)
		oBox.m_ItemGrid:AddChild(oItemBox)
	end
	for i,v in ipairs(dData.reward) do
		local oItemBox = oBox.m_ItemTipBox:Clone()
		oBox.m_ItemGrid:AddChild(oItemBox)
		oItemBox:SetActive(true)
		oItemBox:SetSid(v.sid, v.num, {isLocal = true,  uiType = 1})
	end
end

function CQQVipPage.OnGetCode(self)
	local sCode = self.m_InputLabel:GetText()
	
	local nameLen = #CMaskWordTree:GetCharList(sCode)
	if sCode == "" then
		g_NotifyCtrl:FloatMsg("请输入兑换码")
	elseif not string.isIllegal(sCode) then
		g_NotifyCtrl:FloatMsg("请输入正确的兑换码")
	else
		netfuli.C2GSRedeemcode(sCode)
	end
end

function CQQVipPage.OnOpenVip(self, dData)
	local d = {
		[10004] = "vip",
		[10005] = "svip",
	}
	local skey = d[dData["channel_id"]]
	if skey then
		local dServer = g_LoginCtrl:GetConnectServer()
		local sCode = self:CreateCode()
		printc("sCode", sCode)
		g_AndroidCtrl:QQvipGift(skey, 1, sCode, tostring(g_AttrCtrl.pid), tostring(dServer.server_id))
	else
		g_NotifyCtrl:FloatMsg("未找到开通的礼包")
	end
end

CQQVipPage.CODE_IDX = 1
function CQQVipPage.CreateCode(cls)
	local seconds = g_TimeCtrl:GetTimeS()
	local sTime = os.date("%Y%m%d%H%M%S", seconds)
	local sCode = sTime..tostring(g_AttrCtrl.pid)..string.format("%03d", CQQVipPage.CODE_IDX)
	CQQVipPage.CODE_IDX = CQQVipPage.CODE_IDX + 1
	return sCode
end

return CQQVipPage
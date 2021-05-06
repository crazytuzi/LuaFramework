local COrgRedBagPage = class("COrgRedBagPage", CPageBase)

function COrgRedBagPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
	self:InitContent()
end

function COrgRedBagPage.InitContent(self)
	self.m_SendBtn = self:NewUI(1, CButton)
	self.m_ProgressSpr = self:NewUI(2, CSprite)
	self.m_StarList = {}
	for i = 1, 3 do
		local starbox = self:NewUI(2+i, CBox)
		starbox.m_NoBag = starbox:NewUI(1, CSprite)
		starbox.m_GetBag = starbox:NewUI(2, CSprite)
		starbox.m_HasBag = starbox:NewUI(3, CSprite)
		starbox.m_NoBag:SetActive(true)
		starbox.m_GetBag:SetActive(false)
		starbox.m_HasBag:SetActive(false)
		self.m_StarList[i] = starbox
	end
	self.m_SignDegreeLabel = self:NewUI(6, CLabel)
	self.m_AmountLabel = self:NewUI(7, CLabel)
	self.m_RatioLabel = self:NewUI(8, CLabel)

	self.m_ProgressW, self.m_ProgressH = self.m_ProgressSpr:GetSize()
	self:InitDegree()
	self.m_SendBtn:SetActive(self:IsCanSend())
	self.m_SendBtn:AddUIEvent("click", callback(self, "OnSendRedBag"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrlEvent"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgCtrlEvent"))
	self:RefreshDegree()
end

function COrgRedBagPage.OnShowPage(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	netorg.C2GSOrgOnlineCount()
	local function update()
		if Utils.IsNil(self) or not self.m_IsShow then
			return
		else
			netorg.C2GSOrgOnlineCount()
			return true
		end
	end
	self:RefreshDegree()
	self.m_Timer = Utils.AddTimer(update, 180, 180)
end

function COrgRedBagPage.OnAttrCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshDegree()
	end
end

function COrgRedBagPage.OnOrgCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.UpdateOrgInfo then
		self:RefreshDegree()
	
	elseif oCtrl.m_EventID == define.Org.Event.OnlineCount then
		self:RefreshOnline(oCtrl.m_EventData)
	end
end

function COrgRedBagPage.InitDegree(self)
	local hdata = data.orgdata.RedBag
	local list = {}
	local maxdegree = 0
	for k, v in pairs(hdata) do
		table.insert(list, v)
		maxdegree = math.max(maxdegree, v["sign_degree"])
	end
	self.m_MaxDegree = maxdegree
	table.sort(list, function(a, b)
		if a["sign_degree"] < b["sign_degree"] then
			return true
		end
		return false
	end)
	for i, v in ipairs(list) do
		self.m_StarList[i].m_Degree = v["sign_degree"]
		self.m_StarList[i]:AddUIEvent("click", callback(self, "OnGetBag", i))
	end
end

function COrgRedBagPage.RefreshDegree(self)
	local baglist = g_OrgCtrl:GetRedBagList()
	local bagamount = g_OrgCtrl:GetMyOrgInfo().red_packet
	local sign_degree = g_OrgCtrl.m_Org.info.sign_degree
	for i, star in ipairs(self.m_StarList) do
		if bagamount < i then
			star.m_NoBag:SetActive(true)
			star.m_HasBag:SetActive(false)
			star.m_GetBag:SetActive(false)
			star:AddUIEvent("click", callback(self, "OnGetNoBag", i))
		else
			star.m_NoBag:SetActive(false)
			star.m_HasBag:SetActive(true)
			if baglist[i] == 0 then
				star.m_GetBag:SetActive(false)
			else
				star.m_GetBag:SetActive(true)
			end
			star:AddUIEvent("click", callback(self, "OnGetBag", i))
		end
	end
	self.m_SignDegreeLabel:SetText(string.format("签到进度 %d", sign_degree))
	if self:IsCanSend() then
		self.m_SendBtn:SetEnabled(not g_OrgCtrl:IsSendRedBag())
		self.m_SendBtn:SetGrey(g_OrgCtrl:IsSendRedBag())
	end
	local degree2size = {
		{0, 0}, {20, 125}, {40, 250}, {80, 570}, {100, 734}
	}
	local starw = 0
	local startdegree = 0
	for _, t in ipairs(degree2size) do
		local w = t[2]
		if sign_degree == t[1] then
			self.m_ProgressSpr:SetWidth(w)
			break
		elseif sign_degree < t[1] then
			local per = (sign_degree - startdegree)/(t[1] - startdegree)
			self.m_ProgressSpr:SetWidth(starw + per*(w-starw))
			break
		end
		startdegree = t[1]
		starw = w
	end
	if sign_degree >= 100 then
		self.m_ProgressSpr:SetWidth(731)
	end
end

function COrgRedBagPage.RefreshOnline(self, amount)
	self.m_AmountLabel:SetText(string.format("在线人数：%d", amount))
	local ratio = 0
	for i, d in ipairs(data.orgdata.RedBagRatio) do
		if amount >= d.online_cnt then
			ratio = d.ratio
		else
			break
		end
	end
	self.m_RatioLabel:SetText(string.format("红包加成：%d%%", ratio))
end

function COrgRedBagPage.OnSendRedBag(self)
	if g_OrgCtrl.m_Org.info.sign_degree < 20 then
		g_NotifyCtrl:FloatMsg("签到进度低，无法开启红包玩法 ")
	else
		netorg.C2GSOpenOrgRedPacket()
	end
end

function COrgRedBagPage.OnGetNoBag(self, idegree)
	local hdata = data.orgdata.RedBag
	if g_OrgCtrl:IsSendRedBag() then
		g_NotifyCtrl:FloatMsg("活动开启时，签到进度不足，领取失败")
	else
		if hdata[idegree] then
			local str = string.format("共%d金币分为%d个红包", hdata[idegree]["gold"], hdata[idegree]["amount"])
			g_NotifyCtrl:FloatMsg(str)
		end
	end
end

function COrgRedBagPage.OnGetBag(self, idx)
	netorg.C2GSDrawOrgRedPacket(idx)
end

function COrgRedBagPage.OnGetDetail(self, idx)
	netorg.C2GSOpenOrgRedPacket(idx)
end

function COrgRedBagPage.IsCanSend(self)
	if g_AttrCtrl.org_pos == 1 or g_AttrCtrl.org_pos == 2 then
		return true
	else
		return false
	end
end

return COrgRedBagPage
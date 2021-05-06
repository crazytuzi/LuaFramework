local COrgBuildPage = class("COrgBuildPage", CPageBase)

function COrgBuildPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_RewardList = {}
end

function COrgBuildPage.OnInitPage(self)
	self.m_NowSignLabel = self:NewUI(1 ,CLabel)
	self.m_ProgressSpr = self:NewUI(2, CSprite)
	for i = 1, 3 do
		local oRewardBox = self:NewUI(2+i, CBox)
		oRewardBox.m_IconSprite = oRewardBox:NewUI(1, CSprite)
		oRewardBox.m_SignDegreeLabel = oRewardBox:NewUI(2, CLabel)
		oRewardBox.m_ShanSpr = oRewardBox:NewUI(3, CSprite)
		oRewardBox.m_TweenScale = oRewardBox.m_IconSprite:GetComponent(classtype.TweenScale)
		self.m_RewardList[i] = oRewardBox
	end
	self.m_NotBuildObj = self:NewUI(6, CWidget)
	self.m_BuildGrid = self:NewUI(7, CGrid)
	--self.m_BuildBox = self:NewUI(8, CBox)
	self.m_BuildingObj = self:NewUI(9, CWidget)
	self.m_NameLabel = self:NewUI(10, CLabel)
	self.m_TimeLabel = self:NewUI(11, CLabel)
	self.m_CostLabel = self:NewUI(13, CLabel)
	self.m_SpeedBtn = self:NewUI(14, CButton)
	self.m_FinishBtn = self:NewUI(15, CButton)
	self.m_BuildedObj = self:NewUI(16, CWidget)
	self.m_FinishLabel = self:NewUI(17, CLabel)
	self.m_CashLabel = self:NewUI(18, CLabel)
	self.m_ExpLabel = self:NewUI(19, CLabel)
	self.m_OfferLabel = self:NewUI(20, CLabel)
	self:InitContent()
end

function COrgBuildPage.InitContent(self)
	self.m_ProgressW, self.m_ProgressH = self.m_ProgressSpr:GetSize()
	self.m_SpeedBtn:AddUIEvent("click", callback(self, "OnSpeedBtn"))
	self.m_FinishBtn:AddUIEvent("click", callback(self, "OnFinishBtn"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
	
	self:InitRewardInfo()
	self:InitStatusInfo()
	self:RefreshSgindegree()
end

function COrgBuildPage.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if self.m_Status ~= g_AttrCtrl.org_build_status then
			self:InitStatusInfo()
		end
		self:RefreshRewardInfo()
	end
end

function COrgBuildPage.OnOrgEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.UpdateOrgInfo or 
		oCtrl.m_EventID == define.Org.Event.GetOrgMainInfo then
		self:RefreshSgindegree()
		self:RefreshRewardInfo()
	end
end

function COrgBuildPage.RefreshSgindegree(self)
	local orginfo = g_OrgCtrl:GetMyOrgInfo()
	self.m_NowSignLabel:SetText(orginfo.sign_degree or 0)
	self:RefreshRewardInfo()
end

function COrgBuildPage.InitStatusInfo(self)
	self.m_NotBuildObj:SetActive(false)
	self.m_BuildingObj:SetActive(false)
	self.m_BuildedObj:SetActive(false)

	self.m_Status = g_AttrCtrl.org_build_status
	printc("公会建设Status:", self.m_Status)
	if self.m_Status == define.Org.Build.Status.Not then
		self:ShowNotBuildInfo()
	elseif self.m_Status == define.Org.Build.Status.End or
	       self.m_Status == define.Org.Build.Status.Finish then
		self:ShowBuildedInfo()
	elseif self.m_Status == define.Org.Build.Status.Ordinary or
		   self.m_Status == define.Org.Build.Status.Senior or
	       self.m_Status == define.Org.Build.Status.Super  then
		self:ShowBuildingInfo(self.m_Status)
	end
end

function COrgBuildPage.InitRewardInfo(self)
	local tReward = data.orgdata.OrgSignReward
	local max = tReward[#tReward].sign_degree --最后一个当作最大值
	for i,v in ipairs(tReward) do
		local oBox = self.m_RewardList[i]
		oBox.m_RewardID = tReward[i].id
		oBox.m_Signdegree = tReward[i].sign_degree
		oBox.m_SignDegreeLabel:SetText(oBox.m_Signdegree)
		oBox:AddUIEvent("click", callback(self, "OnOrgSignReward"))
	end
	self:RefreshRewardInfo()
end

function COrgBuildPage.RefreshRewardInfo(self)
	local orginfo = g_OrgCtrl:GetMyOrgInfo()
	local sign_degree = orginfo.sign_degree or 0
	local orgsignreward = g_AttrCtrl.org_sign_reward
	for i,oBox in ipairs(self.m_RewardList) do
		oBox.get = MathBit.andOp(orgsignreward, 2 ^ (i-1)) == 0	
		if oBox.get then
	 		oBox.m_IconSprite:SetSpriteName(string.format("pic_baoxiang_%d_h",i))
	 	else
	 		oBox.m_IconSprite:SetSpriteName(string.format("pic_baoxiang_%d",i))
	 	end
		oBox.tween = oBox.get and sign_degree >= oBox.m_Signdegree
		if oBox.tween then
		 	oBox.m_TweenScale.to = Vector3.New(1.1, 1.1, 1.1)
       	 	oBox.m_TweenScale.from = Vector3.New(1, 1, 1)
        	oBox.m_TweenScale.style = 2
			oBox.m_TweenScale.enabled = true
			oBox.m_ShanSpr:SetActive(true)
		else
			oBox.m_TweenScale.enabled = false
			oBox.m_ShanSpr:SetActive(false)
		end
	end

	local degree2size = {
		{0, 0}, {20, 130}, {40, 290}, {80, 600}, {81, 600}
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
	if sign_degree >= 80 then
		self.m_ProgressSpr:SetWidth(self.m_ProgressW)
	end
end

function COrgBuildPage.OnOrgSignReward(self, oBox)
	if oBox.tween then
		netorg.C2GSOrgSignReward(oBox.m_RewardID)
	elseif oBox.get then
		g_NotifyCtrl:FloatMsg("领取失败，未达到领取要求")
	else
		g_NotifyCtrl:FloatMsg("已领取该奖励")
	end
end

function COrgBuildPage.ShowNotBuildInfo(self)
	self.m_NotBuildObj:SetActive(true)
	local tBuild = data.orgdata.Build
	local dBuild
	local timeinfo
	self.m_BuildGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_BuildNameLabel = oBox:NewUI(1, CLabel)
		oBox.m_AddDegreeLabel = oBox:NewUI(2, CLabel)
		oBox.m_BuildCashLabel = oBox:NewUI(3, CLabel)
		oBox.m_BuildExpLabel = oBox:NewUI(4, CLabel)
		oBox.m_BuildOfferLabel = oBox:NewUI(5, CLabel)
		oBox.m_BuildTimeBtn = oBox:NewUI(6, CButton)
		
		dBuild = tBuild[idx]
		oBox.m_BuildType = dBuild.build_type
		oBox.m_BuildNameLabel:SetText(dBuild.build_name)
		oBox.m_AddDegreeLabel:SetText(string.format("签到进度 + %d", dBuild.sign_degree))
		oBox.m_BuildCashLabel:SetText(string.format("公会资金 + %d", dBuild.cash + dBuild.start_cash))
		oBox.m_BuildExpLabel:SetText(string.format("公会经验 + %d", dBuild.exp + dBuild.start_exp))
		oBox.m_BuildOfferLabel:SetText(string.format("公会贡献 + %d", dBuild.offer + dBuild.start_offer))
		local txt = ""
		if dBuild.cost_coin > 0 then
			local color = g_AttrCtrl.coin < dBuild.cost_coin and "#R" or ""
			txt = string.format("%s %s%d", define.Emote.Text.Coin, color, dBuild.cost_coin)
		elseif dBuild.cost_gold > 0 then
			local color = g_AttrCtrl.goldcoin < dBuild.cost_gold and "#R" or ""
			txt = string.format("%s %s%d", define.Emote.Text.GoldCoin, color, dBuild.cost_gold)
		end
		oBox.m_BuildTimeBtn:SetText(txt)
		oBox.m_BuildTimeBtn:AddUIEvent("click", callback(self, "OnBuildTimeBtn", oBox.m_BuildType)) 
		return oBox
	end)
end

function COrgBuildPage.OnBuildTimeBtn(self, buildtype, oBtn)
	printc("公会建设类型:",buildtype)
	netorg.C2GSOrgBuild(buildtype)
end

function COrgBuildPage.ShowBuildingInfo(self, status)
	self.m_BuildingObj:SetActive(true)
	local tBuild = data.orgdata.Build
	local dBuild = tBuild[status]
	local name, adddesc, stime, iSecs = "", "", "", 0
	if dBuild then
		name = string.format("%s建设中", g_AttrCtrl.name)
		--adddesc = string.format("公会资金 + %d，公会经验 + %d，公会贡献 + %d", dBuild.cash, dBuild.exp, dBuild.offer)
		iSecs = g_AttrCtrl.org_build_time - g_TimeCtrl:GetTimeS()
		iSecs = math.min(iSecs, dBuild.time)
		self.m_NameLabel:SetText(name)
		self.m_CashLabel:SetText(dBuild.cash)
		self.m_ExpLabel:SetText(dBuild.exp)
		self.m_OfferLabel:SetText(dBuild.offer)
		self:UpdateTimeLabel(iSecs)
	end
end

function COrgBuildPage.UpdateTimeLabel(self, iSecs)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	local goldcoin = g_AttrCtrl.goldcoin
	local cost
	local function countdown()
		if Utils.IsNil(self) then
			return
		end
		if iSecs <= 0 then
			self.m_TimeLabel:SetActive(false)
			return false
		end
		self.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(iSecs) )
		iSecs = iSecs - 1
		cost = math.ceil(iSecs/3600)*20
		if goldcoin < cost then
			self.m_CostLabel:SetColor(Color.red)
		else
			self.m_CostLabel:SetColor(Color.white)
		end
		self.m_CostLabel:SetText(cost)
		return true
	end
	self.m_Timer = Utils.AddTimer(countdown, 1, 0)
end

function COrgBuildPage.ShowBuildedInfo(self)
	self.m_BuildedObj:SetActive(true)
	if self.m_Status == define.Org.Build.Status.Finish then
		self.m_FinishBtn:SetActive(true)
	elseif self.m_Status == define.Org.Build.Status.End then
		self.m_FinishLabel:SetText("今日建设完毕")
		self.m_FinishBtn:SetActive(false)
	end
end

function COrgBuildPage.OnSpeedBtn(self, oBtn)
	printc("加速加速")
	netorg.C2GSSpeedOrgBuild(tonumber(self.m_CostLabel:GetText()))
end

function COrgBuildPage.OnFinishBtn(self, oBtn)
	printc("完成建设")
	netorg.C2GSDoneOrgBuild()
end

return COrgBuildPage
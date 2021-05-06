local CTravelLineUpBox = class("CTravelLineUpBox", CBox)

function CTravelLineUpBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_PosListBox = self:NewUI(1, CBox)
	self.m_SpecialPosBox = self:NewUI(2, CBox)
	--self.m_LabelTips = self:NewUI(3, CLabel)
	--self.m_BehindBlack = self:NewUI(4, CTexture)
	self:InitContent()
end

function CTravelLineUpBox.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CTravelLineUpBox.ChechNotTravel(self)
	self.m_NotTravel = g_TravelCtrl:NotTravel()
end

function CTravelLineUpBox.InitContent(self)
	self.m_Type = nil
	self:InitPosGrid()
	self:InitSpecialPosBox()
	g_TravelCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTravelCtrl"))
end

function CTravelLineUpBox.OnTravelCtrl(self, oCtrl)
	if self.m_Type == define.Travel.Type.Mine then
		if oCtrl.m_EventID == define.Travel.Event.MinePos  then
			self:RefreshMinePosBox()
		elseif oCtrl.m_EventID == define.Travel.Event.Frd2Mine then
			self:RefreshMineSpecialBox()
		end
	elseif self.m_Type == define.Travel.Type.Friend then
		self:Refresh(self.m_Type)
	end
end

function CTravelLineUpBox.InitPosGrid(self)
	self.m_PosList = {}
	for i=1,4 do
		local oBox = self.m_PosListBox:NewUI(i, CBox)
		oBox = self:InitPosBox(oBox)
		oBox.m_PosIdx = i
		self.m_PosList[i] = oBox
	end
end

function CTravelLineUpBox.InitSpecialPosBox(self)
	self.m_SpecialPosBox = self:InitPosBox(self.m_SpecialPosBox)
	self.m_SpecialPosBox.m_AddSprTweenScale = self.m_SpecialPosBox.m_AddSpr:GetComponent(classtype.TweenScale)
	self.m_SpecialPosBox.m_AddSprTweenScale.enabled = false
end

function CTravelLineUpBox.InitPosBox(self, oBox)
	oBox.m_BoderSpr = oBox:NewUI(1, CSprite)
	oBox.m_Icon = oBox:NewUI(2, CSprite)
	oBox.m_StarGrid = oBox:NewUI(3, CGrid)
	oBox.m_StarSpr = oBox:NewUI(4, CSprite)
	oBox.m_AwakeSpr = oBox:NewUI(5, CSprite)
	oBox.m_GradeLabel = oBox:NewUI(6, CLabel)
	oBox.m_AddSpr = oBox:NewUI(7, CSprite)
	oBox.m_StarSpr:SetActive(false)
	oBox.m_StarGrid:Clear()
	for i = 1, 5 do
		local oSpr = oBox.m_StarSpr:Clone()
		oSpr:SetActive(true)
		oSpr:SetDepth(9+i)
		oBox.m_StarGrid:AddChild(oSpr)
	end
	oBox.m_StarGrid:Reposition()
	return oBox
end

function CTravelLineUpBox.Refresh(self, iType)
	self.m_Type = iType
	if self.m_Type == define.Travel.Type.Mine then
		self:RefreshMineSpecialBox()
		self:RefreshMinePosBox()
	elseif self.m_Type == define.Travel.Type.Friend then
		self:RefreshFrdSpecialBox()
		self:RefreshFrdPosBox()
	end
end

function CTravelLineUpBox.RefreshMinePosBox(self)
	local traveling = g_TravelCtrl:IsMainTraveling()
	local hasreward = g_TravelCtrl:HasTravelReward()
	local bClose = not traveling and not hasreward
	for i, oBox in ipairs(self.m_PosList) do
		local oPartner = g_TravelCtrl:GetPartnerByPos(i)
		if oPartner then
			oBox.m_Parid = oPartner:GetValue("parid")
			oBox.m_ParName = oPartner:GetValue("name")
			oBox.m_ParShape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
			oBox.m_Icon:SpriteAvatar(oBox.m_ParShape)
			local star = oPartner:GetValue("star")
			for i, oSpr in ipairs(oBox.m_StarGrid:GetChildList()) do
				if star >= i then
					oSpr:SetSpriteName("pic_chouka_dianliang")
				else
					oSpr:SetSpriteName("pic_chouka_weidianliang")
				end
			end
			local awake = oPartner:GetValue("awake")
			oBox.m_AwakeSpr:SetActive(awake == 1)
			local grade = oPartner:GetValue("grade")
			oBox.m_GradeLabel:SetText(string.format("%d", grade))
			oBox.m_AddSpr:SetActive(false)
			oBox.m_BoderSpr:SetActive(true)
		else
			oBox.m_AddSpr:SetActive(true)
			oBox.m_BoderSpr:SetActive(false)
		end
		oBox:AddUIEvent("click", callback(self, "OnShowMineChose", oBox))
	end
end

function CTravelLineUpBox.RefreshMineSpecialBox(self)
	local oBox = self.m_SpecialPosBox
	local dData = g_TravelCtrl:GetFrd2MineParInfo()
	if dData then
		oBox.m_FrdPid = dData.frd_pid
		oBox.m_FrdName = dData.frd_name
		oBox.m_StartTime = dData.start_time
		oBox.m_ServerTime = dData.server_time
		oBox.m_EndTime = dData.end_time
		local parinfo = dData.parinfo
		oBox.m_Parid = parinfo.parid
		oBox.m_ParName = parinfo.par_name
		oBox.m_ParShape = parinfo.par_model and parinfo.par_model.shape
		if oBox.m_ParShape and oBox.m_ParShape > 0  then
			oBox.m_Icon:SetActive(true)
			oBox.m_Icon:SpriteAvatar(oBox.m_ParShape)
		else
			oBox.m_Icon:SetActive(false)
		end
		local star = parinfo.par_star
		for i, oSpr in ipairs(oBox.m_StarGrid:GetChildList()) do
			if star >= i then
				oSpr:SetSpriteName("pic_chouka_dianliang")
			else
				oSpr:SetSpriteName("pic_chouka_weidianliang")
			end
		end
		local awake = parinfo.par_awake
		oBox.m_AwakeSpr:SetActive(awake == 1)
		local grade = parinfo.par_grade
		oBox.m_GradeLabel:SetText(string.format("%d", grade))
		oBox.m_AddSpr:SetActive(false)
		oBox.m_BoderSpr:SetActive(true)
		oBox.m_AddSprTweenScale.enabled = false
		oBox:AddUIEvent("click", callback(self, "OnMineSpecialBox", true))
	else
		oBox.m_AddSpr:SetActive(true)
		oBox.m_BoderSpr:SetActive(false)
		oBox.m_AddSprTweenScale.enabled = true
		oBox:AddUIEvent("click", callback(self, "OnMineSpecialBox", false))
	end
end

function CTravelLineUpBox.OnMineSpecialBox(self, bReturn)
	if bReturn then
		g_NotifyCtrl:FloatMsg("无法操作其他玩家的伙伴")
		return
	end
	if g_TravelCtrl:IsMainTraveling() then
		CTravelInviteFriendView:ShowView()
	else
		g_NotifyCtrl:FloatMsg("开始游历后才可邀请好友")
	end
end

function CTravelLineUpBox.RefreshFrdPosBox(self)
	for i, oBox in ipairs(self.m_PosList) do
		local dData = g_TravelCtrl:GetFrdTravelPos(i)
		if dData then
			oBox.m_Parid = dData.parid
			oBox.m_ParName = dData.par_name
			oBox.m_ParShape = dData.par_model and dData.par_model.shape
			oBox.m_Icon:SpriteAvatar(oBox.m_ParShape)
			local star = dData.par_star or 1
			for i, oSpr in ipairs(oBox.m_StarGrid:GetChildList()) do
				if star >= i then
					oSpr:SetSpriteName("pic_chouka_dianliang")
				else
					oSpr:SetSpriteName("pic_chouka_weidianliang")
				end
			end
			local awake = dData.par_awake
			oBox.m_AwakeSpr:SetActive(awake == 1)
			local grade = dData.par_grade
			oBox.m_GradeLabel:SetText(string.format("%d", grade))
			oBox.m_AddSpr:SetActive(false)
			oBox.m_BoderSpr:SetActive(true)
		else
			oBox.m_AddSpr:SetActive(false)
			oBox.m_BoderSpr:SetActive(false)
		end
		oBox:AddUIEvent("click", callback(self, "OnFrdPosBox", oBox))
	end
end

function CTravelLineUpBox.OnFrdPosBox(self, oBox)
	g_NotifyCtrl:FloatMsg("无法操作他人的游历队伍")
end

function CTravelLineUpBox.RefreshFrdSpecialBox(self)
	local oBox = self.m_SpecialPosBox
	local info = g_TravelCtrl:GetFrdTravelInfo()
	local dData = info.frd_partner
	if dData and dData.frd_pid > 0 then
		oBox.m_FrdPid = dData.frd_pid
		oBox.m_FrdName = dData.frd_name
		oBox.m_StartTime = dData.start_time
		oBox.m_ServerTime = dData.server_time
		oBox.m_EndTime = dData.end_time
		local parinfo = dData.parinfo
		oBox.m_Parid = parinfo.parid
		oBox.m_ParName = parinfo.par_name
		oBox.m_ParShape = parinfo.par_model and parinfo.par_model.shape
		if oBox.m_ParShape and oBox.m_ParShape > 0  then
			oBox.m_Icon:SetActive(true)
			oBox.m_Icon:SpriteAvatar(oBox.m_ParShape)
		else
			oBox.m_Icon:SetActive(false)
		end
		local star = parinfo.par_star
		for i, oSpr in ipairs(oBox.m_StarGrid:GetChildList()) do
			if star >= i then
				oSpr:SetSpriteName("pic_chouka_dianliang")
			else
				oSpr:SetSpriteName("pic_chouka_weidianliang")
			end
		end
		local awake = parinfo.par_awake
		oBox.m_AwakeSpr:SetActive(awake == 1)
		local grade = parinfo.par_grade
		oBox.m_GradeLabel:SetText(string.format("%d", grade))
		oBox.m_AddSpr:SetActive(false)
		oBox.m_BoderSpr:SetActive(true)
		oBox.m_AddSprTweenScale.enabled = false
		oBox:AddUIEvent("click", callback(self, "OnFrdSpecialBox", false))
	else
		oBox.m_AddSpr:SetActive(true)
		oBox.m_BoderSpr:SetActive(false)
		oBox.m_AddSprTweenScale.enabled = true
		oBox:AddUIEvent("click", callback(self, "OnFrdSpecialBox", false))
	end
end

function CTravelLineUpBox.OnFrdSpecialBox(self, bReturn)
	if bReturn then
		return
	end
	local info = g_TravelCtrl:GetFrdTravelInfo()
	local dFrdPartner = info.frd_partner
	local dTravel = info.travel_partner
	if dTravel.status == 1 then
		--self.m_SwitchIdx = oBox.m_PosIdx
		if dFrdPartner and dFrdPartner.frd_pid and dFrdPartner.frd_pid > 0 then
			if dFrdPartner.frd_pid == g_AttrCtrl.pid then
				g_NotifyCtrl:FloatMsg("无法更换寄存伙伴")
			else
				g_NotifyCtrl:FloatMsg("无法操作其他玩家的伙伴")
			end
		else
			CPartnerChooseView:ShowView(function (oView)
				oView:SetConfirmCb(callback(self, "OnChangePartner"))
				oView:SetFilterCb(callback(self, "OnFilterUpGrade"))
			end)
		end
	else
		g_NotifyCtrl:FloatMsg("好友游历已经结束，无法游历")
	end
end

---region 选择伙伴相关---

function CTravelLineUpBox.OnShowMineChose(self, oBox)
	if g_TravelCtrl:NotTravel() then
		self.m_SwitchIdx = oBox.m_PosIdx
		CPartnerChooseView:ShowView(function (oView)
			oView:SetConfirmCb(callback(self, "OnChangePartner"))
			oView:SetFilterCb(callback(self, "OnFilterUpGrade"))
		end)
	elseif g_TravelCtrl:HasTravelReward() then
		g_NotifyCtrl:FloatMsg("请领取奖励后再进行操作")
	else
		g_NotifyCtrl:FloatMsg("请游历结束后再进行操作")
	end
end

function CTravelLineUpBox.OnForceChangePartner(self, iSwitchIdx)
	for i,oBox in ipairs(self.m_PosList) do
		if oBox.m_PosIdx == iSwitchIdx then
			self:OnShowMineChose(oBox)
			return 
		end
	end
end

function CTravelLineUpBox.OnChangePartner(self, parid)
	self:GoUpTravel(self.m_SwitchIdx, parid)
end

function CTravelLineUpBox.OnFilterUpGrade(self, parList)
	local list = {}
	for k, oPartner in ipairs(parList) do
		if not oPartner:IsTravel() and not oPartner:IsInTravel() and 
			oPartner:GetValue("partner_type") ~= 1754 and oPartner:GetValue("partner_type") ~= 1755 then
			table.insert(list, oPartner)
		end
	end
	return list
end

function CTravelLineUpBox.GoUpTravel(self, iPosIdx, iParid)
	if self.m_Type == define.Travel.Type.Mine then
		self:GoUpMineTravel(iPosIdx, iParid)
	elseif self.m_Type == define.Travel.Type.Friend then
		self:GoUpFrdTravel(iPosIdx, iParid)
	end
end

function CTravelLineUpBox.GoUpMineTravel(self, iPosIdx, iParid)
	local oldIdx = self:GetPartnerPosIdx(iParid) --检测自己是否在位置上
	local curPosInfo = self:GetCurPosInfo() --{pos=pos,parid=parid}
	if oldIdx then
		local tempPos = curPosInfo[iPosIdx]
		curPosInfo[oldIdx] = {pos=oldIdx, parid=tempPos.parid}
	end
	curPosInfo[iPosIdx] = {pos=iPosIdx, parid=iParid}
	nettravel.C2GSSetPartnerTravelPos(curPosInfo)
end

function CTravelLineUpBox.GetPartnerPosIdx(self, iParid)
	for i,oBox in ipairs(self.m_PosList) do
		if oBox.m_Parid == iParid then
			return i 
		end
	end
end

function CTravelLineUpBox.GetCurPosInfo(self)
	local curPosInfo = {}
	for i, oBox in ipairs(self.m_PosList) do
		if oBox.m_Parid then
			table.insert(curPosInfo, {pos=oBox.m_PosIdx, parid=oBox.m_Parid})
		else
			table.insert(curPosInfo, {pos=oBox.m_PosIdx, parid=0})
		end
	end
	return curPosInfo
end

function CTravelLineUpBox.GoUpFrdTravel(self, iPosIdx, iParid)
	local title = "选择伙伴"
	local parid = iParid
	local partnername = g_PartnerCtrl:GetPartner(parid).m_Data.name
	local msg = "是否将伙伴【"..partnername.."】加入该游历队伍"
	CTravelPartnerConfirmView:ShowView(function (oView)
		oView:RefreshView(parid, title, msg, function () nettravel.C2GSSetFrdPartnerTravel(parid, g_TravelCtrl:GetFrdPid()) end)
	end)
end

---endregion 选择伙伴相关---

return CTravelLineUpBox
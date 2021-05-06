local CClubArenaPage = class("CClubArenaPage", CPageBase)

function CClubArenaPage.ctor(self, ob)
	CPageBase.ctor(self, ob)
end

function CClubArenaPage.OnInitPage(self)
	self.m_HelpBtn = self:NewUI(1, CButton)
	self.m_BasePart = self:NewUI(2, CBox)
	self.m_DetailPart = self:NewUI(3, CBox)
	self.m_LineupPart = self:NewUI(4, CBox)

	self:InitContent()
end

function CClubArenaPage.InitContent(self)
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrCtrl"))
	g_ClubArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnClubArenaCtrl"))
	
	self.m_CententClub = g_ClubArenaCtrl:GetCurClub()
	self:InitBasePart()
	self:InitDetailPart()
	self:InitLineupPart()

	self:SwitchPart("base")
end

function CClubArenaPage.OnClickHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("clubarena")
	end)
end

function CClubArenaPage.OnAttrCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:RefreshAll()
	end
end

function CClubArenaPage.OnClubArenaCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.ClubArena.Event.Show then
		self:RefreshBase()
		self:RefreshFightCD()
	elseif oCtrl.m_EventID == define.ClubArena.Event.Club then
		self:SwitchPart("detail")
	elseif oCtrl.m_EventID == define.ClubArena.Event.AddTime then

	elseif oCtrl.m_EventID == define.ClubArena.Event.DefenseLineUp then
		self:RefreshPartnerPosList()
	end
end

function CClubArenaPage.SwitchPart(self, key)
	self.m_BasePart:SetActive(false)
	self.m_DetailPart:SetActive(false)
	self.m_LineupPart:SetActive(false)
	if key == "base" then
		self.m_BasePart:SetActive(true)
	elseif key == "detail" then
		self.m_DetailPart:SetActive(true)
	elseif key == "lineup" then
		self.m_LineupPart:SetActive(true)
	end
	self:RefreshAll()
end

function CClubArenaPage.InitBasePart(self)
	local oPart = self.m_BasePart
	oPart.m_ClubLabel = oPart:NewUI(1, CLabel)
	oPart.m_PowerLabel = oPart:NewUI(2, CLabel)
	oPart.m_RuleLabel = oPart:NewUI(3, CLabel)
	oPart.m_FightNumLabel = oPart:NewUI(4, CLabel)
	oPart.m_ShopBtn = oPart:NewUI(5, CButton)
	oPart.m_RewardBtn = oPart:NewUI(6, CButton)
	oPart.m_HistoryBtn = oPart:NewUI(7, CButton)
	oPart.m_MedalLabel = oPart:NewUI(8, CLabel)
	oPart.m_ClubGrid = oPart:NewUI(9, CGrid)
	oPart.m_ClubBox = oPart:NewUI(10, CBox)
	oPart.m_HeroWidget = oPart:NewUI(11, CWidget)
	oPart.m_MasterRewardLabel = oPart:NewUI(12, CLabel)
	oPart.m_ClubRewardLabel = oPart:NewUI(13, CLabel)
	oPart.m_RewardTimeLabel = oPart:NewUI(14, CLabel)
	oPart.m_ClubScroll = oPart:NewUI(15, CScrollView)
	oPart.m_LastClubBtn = oPart:NewUI(16, CButton)
	oPart.m_NextClublBtn = oPart:NewUI(17, CButton)
	oPart.m_HeroIcon = oPart:NewUI(18, CSprite)
	oPart.m_HeroIcon:SetSpriteName(string.format("pic_map_avatar_%d", g_AttrCtrl.model_info.shape))

	oPart.m_ClubGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		local info = data.clubarenadata.Config[idx]
		oBox.m_Idx = idx
		oBox.m_ID = info.id
		oBox.m_SelectSpr = oBox:NewUI(3, CSprite)
		oBox.m_MasterNameLabel = oBox:NewUI(4, CLabel)
		oBox.m_SelectSpr:SetActive(false)
		oBox:AddUIEvent("click", callback(self, "OnClubBox"))
		oBox:AddUIEvent("drag", callback(self, "OnDrag"))
		oBox:AddUIEvent("dragend", callback(self, "OnDragEnd"))
		if oBox.m_Idx == 2 then
			g_GuideCtrl:AddGuideUI("clubarnea_club_2_btn", oBox)	
		end		
		return oBox
	end)

	oPart.m_RewardBtn:AddUIEvent("click", callback(self, "OnRewardBtn"))
	oPart.m_HistoryBtn:AddUIEvent("click", callback(self, "OnHistoryBtn"))
	oPart.m_ShopBtn:AddUIEvent("click", callback(self, "OnShopBtn"))
	oPart.m_LastClubBtn:AddUIEvent("click", callback(self, "OnMoveClubScroll", -1))
	oPart.m_NextClublBtn:AddUIEvent("click", callback(self, "OnMoveClubScroll", 1))

	local t = os.date("*t", g_TimeCtrl:GetTimeS())
	local time = 86400 - (t.hour * 3600 + t.min * 60 + t.sec)
	local function countdown()
		if Utils.IsNil(self) then
			return
		end
		time = time - 1
		if time < 0 then
			t = os.date("*t", g_TimeCtrl:GetTimeS())
			time = 86400 - (t.hour * 3600 + t.min * 60 + t.sec)
			return true
		end
		oPart.m_RewardTimeLabel:SetText(g_TimeCtrl:GetLeftTime(time, true).."后结算")
		return true
	end
	oPart.m_RewardTimer = Utils.AddTimer(countdown, 1, 0)

	local function updatescale()
		if Utils.IsNil(self) then
			return
		end
		local tablePos = oPart.m_ClubScroll:GetLocalPos().x		
		for i,v in ipairs(oPart.m_ClubGrid:GetChildList()) do
			if Utils.IsNil(v) then
				return
			end
			local scaleValue = 1 - (math.abs(v:GetLocalPos().x + tablePos)) * 0.001
			if scaleValue < 0.7 then
				scaleValue = 0.7
			end
			v:SetLocalScale(Vector3.New(scaleValue, scaleValue, scaleValue))
		end
		return true
	end
	if self.m_ScaleTimer == nil then
		self.m_ScaleTimer = Utils.AddTimer(updatescale, 0, 0)
	end

	local function delay()
		if Utils.IsNil(self) then
			return
		end
		self:OnCenter(self.m_CententClub)
	end
	Utils.AddTimer(delay, 0.1, 0.1)
end

function CClubArenaPage.OnMoveClubScroll(self, value)
	local oPart = self.m_BasePart
	if oPart.m_CenterBox then
		local idx = oPart.m_CenterBox.m_Idx
		idx = idx + value
		self:OnCenter(idx)
	end
end

function CClubArenaPage.OnCenter(self, idx)
	local oPart = self.m_BasePart
	if idx < 1 then
		idx = 1
	elseif idx > 6 then
		idx = 6
	end
	if idx == 1 then
		oPart.m_LastClubBtn:SetActive(false)
		oPart.m_NextClublBtn:SetActive(true)
	elseif idx == 6 then
		oPart.m_LastClubBtn:SetActive(true)
		oPart.m_NextClublBtn:SetActive(false)
	else
		oPart.m_LastClubBtn:SetActive(true)
		oPart.m_NextClublBtn:SetActive(true)
	end
	local oBox = oPart.m_ClubGrid:GetChild(idx)
	if oBox then
		oPart.m_ClubScroll:CenterOn(oBox.m_Transform)
		if oPart.m_CenterBox then
			oPart.m_CenterBox.m_SelectSpr:SetActive(false)
		end
		oPart.m_CenterBox = oBox
		oPart.m_CenterBox.m_SelectSpr:SetActive(true)
	end
	self.m_CententClub = idx
end

function CClubArenaPage.OnClubBox(self, oBox)
	if oBox.m_Idx == 2 then
		g_GuideCtrl:TargetGuideStepContinu("ClubArenaView", 2)		
	end
	self:SwitchClub(oBox.m_ID)
	self:OnCenter(oBox.m_Idx)
end

function CClubArenaPage.OnDrag(self, obj, deltax)
	self.m_DeltaxX = deltax.x
end

function CClubArenaPage.OnDragEnd(self, obj, deltax)
	local idx = self.m_CententClub	
	if self.m_DeltaxX < -10 then
		self:OnMoveClubScroll(1)
	elseif self.m_DeltaxX > 10 then
		self:OnMoveClubScroll(-1)
	end
	self.m_DeltaxX = 0
end

function CClubArenaPage.SwitchClub(self, id)
	local iClub = g_ClubArenaCtrl:GetCurClub()
	if id > iClub + 1 then
		g_NotifyCtrl:FloatMsg("不能越馆挑战")
		return
	end
	if id < 1 then
		id = 1
	elseif id > 6 then
		id = 6
	end
	self.m_CententClub = id
	g_ClubArenaCtrl:RequestClubArenaInfo(id)
end

function CClubArenaPage.OnClublLabel(self, value)
	self:SwitchClub(self.m_CententClub + value)
end

function CClubArenaPage.OnRewardBtn(self)
	CClubArenaRewardView:ShowView()
end

function CClubArenaPage.OnShopBtn(self)
	g_NpcShopCtrl:OpenShop(define.Store.Page.HonorShop)
end

function CClubArenaPage.OnHistoryBtn(self)
	g_ClubArenaCtrl:GetArenaHistory()
end

function CClubArenaPage.InitDetailPart(self)
	local oPart = self.m_DetailPart
	oPart.m_DefendBtn = oPart:NewUI(1, CButton)
	oPart.m_PowerLabel = oPart:NewUI(2, CLabel)
	oPart.m_ClubLabel = oPart:NewUI(3, CLabel)
	oPart.m_BackBtn = oPart:NewUI(6, CButton)
	oPart.m_FightNumLabel = oPart:NewUI(7, CLabel)
	oPart.m_AddFightNumBtn = oPart:NewUI(8, CButton)
	oPart.m_RefreshBtn = oPart:NewUI(9, CButton)
	oPart.m_ScrollWidget = oPart:NewUI(10, CWidget)
	oPart.m_EnemyScroll = oPart:NewUI(11, CScrollView)
	oPart.m_EnemyGrid = oPart:NewUI(12, CGrid)
	oPart.m_EnemyBox = oPart:NewUI(13, CBox)
	oPart.m_MasterBox = oPart:NewUI(14, CBox)
	oPart.m_LeftTimeLabel = oPart:NewUI(15, CLabel)
	oPart.m_ResetBtn = oPart:NewUI(16, CButton)
	oPart.m_LockRefreshSpr = oPart:NewUI(17, CSprite)
	oPart.m_WinDescLabel = oPart:NewUI(18, CLabel)

	oPart.m_MasterBox = self:CreateEnemyBox(oPart.m_MasterBox)

	oPart.m_EnemyBox:SetActive(false)
	oPart.m_MasterBox:SetActive(false)
	oPart.m_LockRefreshSpr:SetActive(false)
	--[[
	oPart.m_MasterBox.m_Texture = oPart.m_MasterBox:NewUI(1, CActorTexture)
	oPart.m_MasterBox.m_NameLabel = oPart.m_MasterBox:NewUI(2, CLabel)
	oPart.m_MasterBox.m_OrgLabel = oPart.m_MasterBox:NewUI(3, CLabel)
	oPart.m_MasterBox.m_PowerLabel = oPart.m_MasterBox:NewUI(4, CLabel)
	oPart.m_MasterBox.m_BgSprite = oPart.m_MasterBox:NewUI(5, CSprite)
	oPart.m_MasterBox.m_WinDescLabel = oPart.m_MasterBox:NewUI(6, CLabel)
	oPart.m_MasterBox.m_CostLabel = oPart.m_MasterBox:NewUI(7, CLabel)
	oPart.m_MasterBox.m_NameBgSprite = oPart.m_MasterBox:NewUI(8, CSprite)
	oPart.m_MasterBox.m_CostLabel:SetText("#w1"..data.playconfigdata.CLUBARENA.challenge_cost.val)
	]]


	oPart.m_DefendBtn:AddUIEvent("click", callback(self, "OnDefendBtn"))
	oPart.m_BackBtn:AddUIEvent("click", callback(self, "OnBackBtn"))
	oPart.m_AddFightNumBtn:AddUIEvent("click", callback(self, "OnAddFightNumBtn"))
	oPart.m_RefreshBtn:AddUIEvent("click", callback(self, "OnRefreshBtn"))
	oPart.m_ResetBtn:AddUIEvent("click", callback(self, "OnResetBtn"))
end

function CClubArenaPage.CreateEnemyBox(self, oBox)
	oBox.m_Texture = oBox:NewUI(1, CTexture)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_OrgLabel = oBox:NewUI(3, CLabel)
	oBox.m_PowerLabel = oBox:NewUI(4, CLabel)
	oBox.m_BgSprite = oBox:NewUI(5, CSprite)
	oBox.m_NumGrid = oBox:NewUI(6, CGrid)
	oBox.m_NumSprClone = oBox:NewUI(7, CSprite)
	oBox.m_FightBtn = oBox:NewUI(8, CButton)
	oBox.m_NumSprClone:SetActive(false)
	return oBox
end

function CClubArenaPage.UpdateEnemyBox(self, oBox, dData, bmaster)
	oBox.m_Pid = dData.pid
	oBox.m_Club = dData.club
	oBox.m_Post = dData.post
	local iClub = 1
	if bmaster then
		iClub = self.m_CententClub
	end
	oBox.m_BgSprite:SetSpriteName(string.format("pic_putongdi_%d", iClub))
	oBox.m_NameLabel:SetText(dData.name)
	if dData.orgname and dData.orgname ~= "" then
		oBox.m_OrgLabel:SetText("("..dData.orgname..")")
	else
		oBox.m_OrgLabel:SetText("(未加入公会)")
	end
	oBox.m_PowerLabel:SetText("战："..dData.power)
	local lNum = self:GetNumArr(dData.power)
	oBox.m_NumGrid:Clear()
	for i,v in ipairs(lNum) do
		local oSpr = oBox.m_NumSprClone:Clone()
		oSpr:SetActive(true)
		oSpr:SetSpriteName(string.format("text_normal_%d", v))
		oBox.m_NumGrid:AddChild(oSpr)
	end
	oBox.m_NumGrid:Reposition()

	oBox.m_Texture:LoadPath(string.format("Texture/ClubArena/club_%s.png", dData.model.shape),
		function () 
			local w, h = self:GetTextureWH(dData.model.shape)
			oBox.m_Texture:SetSize(w, h)
		end)
	oBox.m_FightBtn:AddUIEvent("click", callback(self, "OnEnemyBox", oBox))
	return oBox
end

function CClubArenaPage.OnDefendBtn(self)
	netarena.C2GSOpenClubArenaDefense()
	self:SwitchPart("lineup")
end

function CClubArenaPage.OnBackBtn(self)
	self:SwitchPart("base")
end

function CClubArenaPage.OnAddFightNumBtn(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSClubArenaAddFightCnt"]) then
		netarena.C2GSClubArenaAddFightCnt()
	end
end

function CClubArenaPage.OnResetBtn(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSResetClubArena"]) then
		netarena.C2GSCleanClubArenaCD()
	end
end

function CClubArenaPage.OnRefreshBtn(self)
	if self.m_LockRefresh then
		return false
	end
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSResetClubArena"]) then
		netarena.C2GSResetClubArena(self.m_CententClub)
		self.m_Refreshing = true
		self.m_LockRefresh = true
		self.m_DetailPart.m_RefreshBtn:SetText("刷 新(1s)")
		self.m_DetailPart.m_LockRefreshSpr:SetActive(true)
		local function cancellocal()
			if Utils.IsNil(self) then
				return
			end
			self.m_LockRefresh = false
			self.m_DetailPart.m_RefreshBtn:SetText("刷 新")
			self.m_DetailPart.m_LockRefreshSpr:SetActive(false)
		end
		Utils.AddTimer(cancellocal, 1, 1)
	end
end

function CClubArenaPage.InitLineupPart(self)
	local oPart = self.m_LineupPart
	oPart.m_PosGrid = oPart:NewUI(1, CBox)
	oPart.m_SaveBtn = oPart:NewUI(2, CButton)
	oPart.m_CancelBtn = oPart:NewUI(3, CButton)
	oPart.m_PowerLabel = oPart:NewUI(4, CLabel)
	oPart.m_PowerLabel:SetActive(false)

	oPart.m_ActorList = {}
	oPart.m_PartnerPosList = {}

	oPart.m_SaveBtn:AddUIEvent("click", callback(self, "OnSaveBtn"))
	oPart.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancelBtn"))

	self:InitPosGrid()
	self:RefreshPartnerPosList()
end

function CClubArenaPage.OnSaveBtn(self)
	local paridlist = {}
	for i,oPartner in pairs(self.m_LineupPart.m_PartnerPosList) do
		if oPartner.m_ID then
			table.insert(paridlist, oPartner.m_ID)
		end
	end
	if #paridlist < 4 then
		g_NotifyCtrl:FloatMsg("需要设置4个伙伴")
		return
	end
	netarena.C2GSSaveClubArenaLineup(paridlist)
	self:SwitchPart("detail")
end

function CClubArenaPage.OnCancelBtn(self)
	self:SwitchPart("detail")
end

function CClubArenaPage.InitPosGrid(self)
	for i = 1, 4 do
		local oBox = self.m_LineupPart.m_PosGrid:NewUI(i, CBox)
		oBox.m_AddButton = oBox:NewUI(1, CButton)
		oBox.m_ActorTexture = oBox:NewUI(2, CActorTexture)
		oBox.m_CloseFightBtn = oBox:NewUI(3, CButton)
		oBox.m_NameLabel = oBox:NewUI(4, CLabel)
		oBox.m_WidgetObj = oBox:NewUI(5, CWidget)
		oBox.m_PosIdx = i
		oBox.m_AddButton:AddUIEvent("click", callback(self, "OnPartnerChoose", oBox))
		oBox.m_ActorTexture:AddUIEvent("click", callback(self, "OnPartnerChoose", oBox))
		oBox.m_CloseFightBtn:AddUIEvent("click", callback(self, "CloseFight", oBox))
		self.m_LineupPart.m_ActorList[i] = oBox
	end
end

function CClubArenaPage.CloseFight(self, oBox)
	self:GoDownTerrawar(oBox.m_PosIdx, oBox.m_ID)
end

function CClubArenaPage.OnPartnerChoose(self, oBox)
	self.m_SwitchIdx = oBox.m_PosIdx
	CPartnerChooseView:ShowView(function (oView)
		oView:SetConfirmCb(callback(self, "OnChangePartner"))
		oView:SetFilterCb(callback(self, "OnFilterUpGrade"))
	end)
end

function CClubArenaPage.OnChangePartner(self, parid)
	self:GoUpTerrawar(self.m_SwitchIdx, parid)
end

function CClubArenaPage.OnFilterUpGrade(self, parList)
	local list = {}
	local posids = {}
	for k,v in pairs(self.m_LineupPart.m_PartnerPosList) do
		if v and v.m_ID then
			table.insert(posids, v.m_ID)
		end
	end
	for k, oPartner in ipairs(parList) do
		if not table.index(posids, oPartner.m_ID) then
			table.insert(list, oPartner)
		end
	end
	return list
end

function CClubArenaPage.RefreshPartnerPosList(self)
	self.m_LineupPart.m_PartnerPosList = {}
	local lDefines = g_ClubArenaCtrl:GetDefenseLineUp()
	for i,v in ipairs(lDefines) do
		self.m_LineupPart.m_PartnerPosList[i] = g_PartnerCtrl:GetPartner(v)
	end
	self:RefreshPosGrid()
end

function CClubArenaPage.RefreshPosGrid(self)
	for i, oBox in ipairs(self.m_LineupPart.m_ActorList) do
		local oPartner = self.m_LineupPart.m_PartnerPosList[i]
		if oPartner then
			oBox.m_ID = oPartner.m_ID
			oBox.m_ActorTexture:SetActive(true)
			oBox.m_AddButton:SetActive(false)
			local shape = oPartner:GetValue("model_info").shape or oPartner:GetValue("shape")
			oBox.m_ActorTexture:ChangeShape(shape, {})  
			oBox.m_ActorTexture.m_PartnerID = oPartner.m_ID
			oBox.m_NameLabel:SetText(oPartner:GetValue("name"))
			oBox.m_CloseFightBtn:SetActive(true)
		else
			oBox.m_ID = nil
			oBox.m_ActorTexture:SetActive(false)
			oBox.m_AddButton:SetActive(true)
			g_UITouchCtrl:DelDragObject(oBox.m_ActorTexture)
			oBox.m_NameLabel:SetText("")
			oBox.m_CloseFightBtn:SetActive(false)
		end
	end
end

function CClubArenaPage.GoUpTerrawar(self, iPosIdx, iParid)
	self.m_LineupPart.m_PartnerPosList[iPosIdx] = g_PartnerCtrl:GetPartner(iParid)
	self:RefreshPosGrid()
end

function CClubArenaPage.GoDownTerrawar(self, iPosIdx, iParid)
	self.m_LineupPart.m_PartnerPosList[iPosIdx] = nil
	self:RefreshPosGrid()
end

function CClubArenaPage.RefreshAll(self)
	if self.m_BasePart:GetActive() then
		self:RefreshBase()
	elseif self.m_DetailPart:GetActive() then
		self:RefreshDetail()
	end
end

function CClubArenaPage.RefreshBase(self)
	local oPart = self.m_BasePart
	oPart.m_MedalLabel:SetText(g_AttrCtrl.arenamedal)
	self:OnCenter(self.m_CententClub)
	local iClub = g_ClubArenaCtrl:GetCurClub()
	oPart.m_HeroWidget:SetParent(oPart.m_ClubGrid:GetChild(iClub).m_Transform)
	oPart.m_HeroWidget:SetLocalPos(Vector3.New(0, 85, 0))
	local sAmount = "(无限)"
	local d = data.clubarenadata.Config[iClub]
	if d.amount > 0 then
		sAmount = string.format("(%d人)", d.amount)
	end
	oPart.m_ClubLabel:SetText(string.format("所在馆：%s%s", d.desc, sAmount))
	oPart.m_PowerLabel:SetText("总战力："..g_AttrCtrl.power)
	oPart.m_FightNumLabel:SetText("今日挑战次数：".."1".."/".."5")
	if g_ClubArenaCtrl.m_CoinReward and g_ClubArenaCtrl.m_CoinReward > 0 then
		oPart.m_MasterRewardLabel:SetText(string.format("馆主奖励：#w4%d（每10分钟获得#w4%d）", g_ClubArenaCtrl.m_GoldReward, g_ClubArenaCtrl.m_CoinReward))
	else
		oPart.m_MasterRewardLabel:SetText("馆主奖励：无")
	end
	local dConfig = data.clubarenadata.Config[iClub]
	if dConfig and dConfig.club_reward and next(dConfig.club_reward) then
		oPart.m_ClubRewardLabel:SetText(string.format("结算奖励：#w2%d #w4%d", dConfig.club_reward[1].num, dConfig.club_reward[2].num))
	else
		oPart.m_ClubRewardLabel:SetText("结算奖励：无")
	end
	local masters = g_ClubArenaCtrl.m_Masters
	if masters then
		for i,oBox in ipairs(oPart.m_ClubGrid:GetChildList()) do
			if i == 1 then
				oBox.m_MasterNameLabel:SetText("")
			else
				if masters[i-1] and masters[i-1] ~= "" then
					oBox.m_MasterNameLabel:SetText(string.format("馆主-%s", masters[i-1]))
				else
					oBox.m_MasterNameLabel:SetText("馆主-无")
				end
			end
		end
	end
end

function CClubArenaPage.RefreshDetail(self)
	self:RefreshEnemyGrid(self.m_Refreshing)
	self:RefreshFightCD()
end

function CClubArenaPage.RefreshFightCD(self)
	local oPart = self.m_DetailPart
	local iClub = self.m_CententClub
	local lInfo = g_ClubArenaCtrl:GetClubArenaInfo(iClub) or g_AttrCtrl
	local sAmount = "-无限"
	local d = data.clubarenadata.Config[iClub]
	if d.amount > 0 then
		sAmount = string.format("-%d人", d.amount)
	end
	oPart.m_ClubLabel:SetText(data.clubarenadata.Config[iClub].desc..sAmount)
	oPart.m_PowerLabel:SetText("我的战斗力："..lInfo.power)
	oPart.m_FightNumLabel:SetText("今日挑战次数："..g_ClubArenaCtrl.m_UseTimes.."/"..g_ClubArenaCtrl.m_Maxtimes)
	if g_ClubArenaCtrl.m_CDFight and g_ClubArenaCtrl.m_CDFight > 0 then 
		oPart.m_LeftTimeLabel:SetActive(true)
		oPart.m_FightNumLabel:SetActive(false)
		if not oPart.m_LeftTimer then
			local time = g_ClubArenaCtrl.m_CDFight
			local function countdown()
				if Utils.IsNil(self) then
					return
				end
				time = time - 1
				if time <= 0 then
					oPart.m_LeftTimeLabel:SetActive(false)
					oPart.m_FightNumLabel:SetActive(true)
					return
				end
				oPart.m_LeftTimeLabel:SetText(os.date("%M:%S", time).."后可挑战")
				return true
			end
			oPart.m_LeftTimer = Utils.AddTimer(countdown, 1, 0)
		end
	else
		if self.m_DetailPart.m_LeftTimer then
			Utils.DelTimer(self.m_DetailPart.m_LeftTimer)
			self.m_DetailPart.m_LeftTimer = nil
		end
		oPart.m_LeftTimeLabel:SetActive(false)
		oPart.m_FightNumLabel:SetActive(true)
	end
end

function CClubArenaPage.RefreshEnemyGrid(self, bRefresh)
	local iClub = self.m_CententClub
	local lInfo = g_ClubArenaCtrl:GetClubArenaInfo(iClub)
	if not lInfo then
		return
	end
	local oPart = self.m_DetailPart
	if iClub == 1 then
		oPart.m_ScrollWidget:SetSize(1070, 380)
		oPart.m_ScrollWidget:SetLocalPos(Vector3.New(-103, 1, 0))
		oPart.m_EnemyScroll:ResetAndUpdateAnchors()
		oPart.m_EnemyScroll:ResetPosition()
		oPart.m_MasterBox:SetActive(false)
	else
		oPart.m_ScrollWidget:SetSize(770, 380)
		oPart.m_ScrollWidget:SetLocalPos(Vector3.New(53, 1, 0))
		oPart.m_EnemyScroll:ResetAndUpdateAnchors()
		oPart.m_EnemyScroll:ResetPosition()
		local oBox = oPart.m_MasterBox
		oBox:SetActive(true)
		local v = lInfo.master
		oBox = self:UpdateEnemyBox(oBox, v, true)
		local win = lInfo.win or 0
		if oBox.m_Pid == g_AttrCtrl.pid then
			oPart.m_WinDescLabel:SetActive(false)
		elseif win == 5 then
			oPart.m_WinDescLabel:SetActive(true)
			oPart.m_WinDescLabel:SetText(string.format("消耗#w1%d挑战馆主", data.playconfigdata.CLUBARENA.challenge_cost.val))
		else
			oPart.m_WinDescLabel:SetActive(true)
			oPart.m_WinDescLabel:SetText(string.format("本馆胜利%d/5次后可挑战", win))
		end
	end
	local enemy = lInfo.enemy
	if not bRefresh then
		oPart.m_EnemyGrid:Clear()
		for i,v in ipairs(enemy) do
			local oBox = oPart.m_EnemyBox:Clone()
			oBox:SetActive(true)
			oBox = self:CreateEnemyBox(oBox)
			oBox = self:UpdateEnemyBox(oBox, v, false)
			oPart.m_EnemyGrid:AddChild(oBox)
		end
		oPart.m_EnemyGrid:Reposition()
	else
		for i,oBox in ipairs(oPart.m_EnemyGrid:GetChildList()) do
			local v = enemy[i]
			oBox.m_Sequence = DOTween.Sequence(oBox.m_BgSprite.m_Transform)
			local tween1  = DOTween.DOLocalRotate(oBox.m_BgSprite.m_Transform, Vector3.New(0, 90, 0), 0.3)
			DOTween.Append(oBox.m_Sequence, tween1)
			DOTween.OnComplete(tween1, function ()
				oBox.m_BgSprite:SetLocalRotation(Quaternion.Euler(0, -90, 0))
				oBox = self:UpdateEnemyBox(oBox, v, false)
			end)
			local tween2  = DOTween.DOLocalRotate(oBox.m_BgSprite.m_Transform, Vector3.New(0, 0, 0), 0.3)
			DOTween.Insert(oBox.m_Sequence, 0.3 , tween2)	
			DOTween.OnComplete(tween2, function ()
				self.m_Refreshing = false	
			end)
		end
	end
end

function CClubArenaPage.GetTextureWH(self, shape)
	local shape2wh = {
		[110] = {w=261,h=405},
		[113] = {w=394,h=379},
		[120] = {w=261,h=405},
		[123] = {w=394,h=379},
		[130] = {w=261,h=405},
		[133] = {w=394,h=379},
		[140] = {w=261,h=405},
		[143] = {w=394,h=379},
		[150] = {w=261,h=405},
		[153] = {w=394,h=379},
		[160] = {w=261,h=405},
		[163] = {w=394,h=379},
	}
	local w = shape2wh[shape].w or 0
	local h = shape2wh[shape].h or 0
	return w, h
end

function CClubArenaPage.OnEnemyBox(self, oBox)
	if oBox.m_Pid == g_AttrCtrl.pid then
		g_NotifyCtrl:FloatMsg("不能挑战自己")
	elseif g_ClubArenaCtrl.m_CDFight and g_ClubArenaCtrl.m_CDFight > 0 then
		g_NotifyCtrl:FloatMsg("挑战冷却中")
	else
		local b, i = g_ClubArenaCtrl:IsMaster()
		local d = data.clubarenadata.Config
		if b and i and oBox.m_Club > i then
			local windowConfirmInfo = {
				msg = string.format("确认放弃[%s]馆主位置\n晋升至[%s]吗？", d[i].desc, d[oBox.m_Club].desc),
				title = "提示",
				okCallback = function () 
					netarena.C2GSClubArenaFight(oBox.m_Club, oBox.m_Post, oBox.m_Pid)
				end,
				cancelCallback = function ()
				end,
				okStr = "确定",
				cancelStr = "取消",
			}
			g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
		else
			netarena.C2GSClubArenaFight(oBox.m_Club, oBox.m_Post, oBox.m_Pid)
		end
	end
end

function CClubArenaPage.GetNumArr(self, num)
	if not num or type(num) ~= "number" or num == 0 then
		return {0}
	end
	local t = {}
	if num > 0 then
		repeat
			local temp = num % 10
			table.insert(t, temp)
			num = math.floor(num / 10)
		until num <= 0
	end
	local d = {}
	for i = #t, 1, -1 do
		table.insert(d, t[i])
	end
	return d
end

return CClubArenaPage


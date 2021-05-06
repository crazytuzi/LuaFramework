local CWarReplaceMenu = class("CWarReplaceMenu", CBox)

function CWarReplaceMenu.ctor(self, obj)
	CBox.ctor(self, obj)
	-- self.m_PartnerTable = self:NewUI(1, CTable)
	self.m_PartnerCard = self:NewUI(2, CWarPartnerCard)
	self.m_NoParLabel = self:NewUI(3, CLabel)
	self.m_ConfirmBtn = self:NewUI(4, CButton)
	self.m_StateLabel = self:NewUI(5, CLabel)
	self.m_CancelBtn = self:NewUI(6, CButton)
	self.m_CardContainer = self:NewUI(7, CObject)
	self.m_StartWarBtn = self:NewUI(8, CButton)
	self.m_WaitLabel = self:NewUI(9, CLabel)
	self.m_CardGrid = self:NewUI(10, CDragGrid)
	self.m_FilterBox = self:NewUI(11, CBox)
	self.m_BgSprite = self:NewUI(13, CSprite)
	self.m_LastHoverRef = nil
	self.m_FilterRare = 0
	self.m_IsOnlyOneSelf = nil
	self.m_OrderConfirm = nil
	self:InitContent()
end

function CWarReplaceMenu.InitContent(self)
	self.m_PartnerCard:SetActive(false)
	self.m_StartWarBtn:SetActive(false)
	self.m_ConfirmBtn:SetActive(false)
	self.m_WaitLabel:SetActive(false)
	self.m_StateLabel:SetActive(false)
	self.m_BgSprite:SetActive(false)
	self.m_CountDownTimer = nil
	self.m_ConfirmBtn:AddUIEvent("click", callback(self, "OnConfirm"))
	self.m_StartWarBtn:AddUIEvent("click", callback(self, "OnStartWar"))
	self.m_CancelBtn:AddUIEvent("click", callback(self, "OnCancel"))
	local iRootWidth, _ = UITools.GetRootSize()
	local iWidth = self.m_CardGrid:GetWidth() + iRootWidth - 1024
	self.m_CardGrid.m_CellWidth = 148
	self.m_CardGrid.m_ShowCnt = math.max(math.floor(iWidth/self.m_CardGrid.m_CellWidth) - 1, 1)
	self.m_CardGrid.m_WaitShowCnt = 3
	self.m_CardGrid.m_WaitOffset = Vector3.New(-5, -5, 0)
	self:InitFilter()
	self.m_CardGrid:SetRefreshFunc(function(oChild, oPartner)
		oChild:SetPartnerID(oPartner.m_ID)
	end)
	self.m_CardGrid:SetCloneChild(self.m_PartnerCard, 
		function(oChild, i)
			oChild:SetName("Card"..tostring(i))
			oChild:SetActive(true)
			local dArgs = {
				start_func = function(o) return o:IsCanFight() end,
				start_delta = Vector2.New(0, 30),
				cb_dragstart = callback(self, "OnDragStart"),
				cb_dragging = callback(self, "OnDragging"),
				cb_dragend = callback(self, "OnDragEnd"),
				-- long_press = 0.5,
			}
			g_UITouchCtrl:AddDragObject(oChild, dArgs)
			return oChild 
		end)
	self.m_CardGrid:InitGrid()

	self:CheckOnlyOneSelf()
end

function CWarReplaceMenu.CheckOnlyOneSelf(self)
	local list = g_WarCtrl:FindWarriors(function(oWarrior) return 
		oWarrior.m_Type == define.Warrior.Type.Player
	end)
	self.m_IsOnlyOneSelf = #list <= 1
end

function CWarReplaceMenu.InitFilter(self)
	self.m_FilterBox.m_CurRare = self.m_FilterBox:NewUI(1, CSprite)
	self.m_FilterBox.m_BtnList = {}
	self.m_FilterBox.m_RareList = {}
	for i = 1, 4 do
		local btn = self.m_FilterBox:NewUI(1+i, CSprite)
		self.m_FilterBox.m_BtnList[i] = btn
	end
	self.m_FilterBox.m_BG = self.m_FilterBox:NewUI(6, CSprite)
	
	-- self.m_FilterBox.m_CurRare:AddUIEvent("click", callback(self, "OnShowRareFilter"))
	self.m_FilterBox.m_CurRare:SetSpriteName("text_zrare_0")
	self.m_FilterBox.m_BG:SetActive(false)
	self.m_FilterRare = 0
end

function CWarReplaceMenu.OnShowRareFilter(self)
	if self.m_FilterBox.m_BG:GetActive() then
		self.m_FilterBox.m_BG:SetActive(false)
	else
		self.m_FilterBox.m_BG:SetActive(true)
		for i = 1, 4 do
			self.m_FilterBox.m_BtnList[i]:SetActive(true)
		end
		local i = 1
		for iRare = 0, 4 do
			if iRare ~= self.m_FilterRare then
				local spr = self.m_FilterBox.m_BtnList[i]
				spr:SetSpriteName("pic_warrare_"..tostring(iRare))
				if iRare == 0 then
					spr:SetSize(48, 88)
				else
					spr:SetSize(87, 40)
				end
				self.m_FilterBox.m_BtnList[i]:AddUIEvent("click", callback(self, "OnRareFilter", iRare))
				i = i + 1
			end
		end
	end
end

function CWarReplaceMenu.OnCloseRareFilter(self)
	self.m_FilterBox.m_ListPart:SetActive(false)
end

function CWarReplaceMenu.OnRareFilter(self, iRare)
	self.m_FilterRare = iRare
	self.m_FilterBox.m_BG:SetActive(false)
	self.m_FilterBox.m_CurRare:SetSpriteName("text_zrare_"..tostring(iRare))
	local t = {
		{67, 89}, {48, 45}, {42, 45}, {73, 46}, {105, 46},
	}
	self.m_FilterBox.m_CurRare:SetSize(t[iRare+1][1], t[iRare+1][2])
	self:RefershPartners()
end


function CWarReplaceMenu.UpdateMenu(self)
	local bShowBg = false
	if g_WarCtrl:IsPrepare() then
		if not self.m_CountDownTimer then
			self.m_CountDownTimer = Utils.AddTimer(callback(self, "CountDown"), 0.1, 0)
		end
		if g_WarCtrl:IsReplace()then
			bShowBg = not g_WarCtrl:IsLockPreparePartner()
			self.m_StartWarBtn:SetActive(bShowBg)
		else
			self.m_StartWarBtn:SetActive(false)
		end
		self.m_ConfirmBtn:SetActive(false)
	else
		bShowBg = true
		self.m_ConfirmBtn:SetActive(true)
		self.m_StartWarBtn:SetActive(false)
	end
	self.m_CancelBtn:SetActive(not g_WarCtrl:IsPrepare())
	if g_WarCtrl:IsReplace() then
		if g_WarCtrl:IsLockPreparePartner() and self.m_IsLockPrepared ~= true then
			self.m_IsLockPrepared = true
			self:OnStartWar()
		else
			self:RefershPartners()
		end
	else
		self:FroceEndDrag()
		self.m_CardGrid:ClearChild()
	end
	local bAct = g_WarCtrl:IsReplace()
	self.m_CardContainer:SetActive(bAct)
	self.m_FilterBox:SetActive(bAct)
	self.m_WaitLabel:SetActive(false)
	-- self.m_BgSprite:SetActive(bShowBg)
end

function CWarReplaceMenu.OnStartWar(self)
	local lWarPartners = g_WarCtrl:GetPartnersInWar()
	local lPos = {}
	if g_WarCtrl:IsFirstWarrior() then
		for i=2, 4 do
			if g_WarCtrl.m_AllyPlayerCnt > 1 then
				if g_WarCtrl.m_AllyPlayerCnt < i then
					table.insert(lPos, i)
				end
			else
				table.insert(lPos, i)
			end
		end
		table.insert(lPos, 1, define.War.MainPartnerPos)
	else
		local oWarrior = g_WarCtrl:GetWarrior(g_WarCtrl.m_HeroWid)
		if oWarrior then
			lPos = {oWarrior.m_CampPos+define.War.MainPartnerPos-1}
		end
	end
	local dMap = {}
	for i, dPartner in ipairs(lWarPartners) do
		dMap[dPartner.pos] = dPartner
	end
	local parlist = {}
	local iMax = #lPos
	for i, iPos in ipairs(lPos) do
		local dPartner = dMap[iPos]
		if dPartner then
			table.insert(parlist, {pos=iPos, parid=dPartner.parid})
		else
			local bFindReplace = false
			for j=i+1, iMax do
				local dPartner = dMap[lPos[j]]
				if dPartner then
					table.insert(parlist, {pos=iPos, parid=dPartner.parid})
					dMap[lPos[j]] = nil
					bFindReplace = true
					break
				end
			end
			if not bFindReplace then
				break
			end
		end
	end
	g_WarCtrl:ResumeAfterReplace()
	g_WarCtrl:HeroPrepareDone()
	netwar.C2GSWarPrepareCommand(g_WarCtrl:GetWarID(), parlist)
	if g_WarCtrl:GetWarType() == define.War.Type.Arena 
		or g_WarCtrl:GetWarType() == define.War.Type.EqualArena 
		or g_WarCtrl:GetWarType() == define.War.Type.TeamPvp 
		or g_WarCtrl:GetWarType() == define.War.Type.ClubArena then
		local oView = CWarMainView:GetView()
		if oView then
			oView:SetActive(false)
		end
		oView = CWarFloatView:GetView()
		if oView then
			oView:SetActive(false)
		end
		oView = CMainMenuView:GetView()
		if oView then
			oView:SetActive(false)
		end
	end
end

function CWarReplaceMenu.OnConfirm(self)
	self.m_OrderConfirm = false
	local list = {}
	g_WarCtrl:SetReplace(false)
	for wid, info in pairs(g_WarCtrl.m_ReplaceInfos) do
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if oWarrior.m_PartnerID and oWarrior.m_PartnerID ~= info.parid then
			self.m_OrderConfirm = true
			table.insert(list, {pos=oWarrior.m_CampPos, parid=oWarrior.m_PartnerID})
		end
	end
	if self.m_OrderConfirm then
		netwar.C2GSWarPartner(g_WarCtrl:GetWarID(), list)
	end
	g_WarCtrl:ResumeAfterReplace()
end

function CWarReplaceMenu.OnCancel(self)
	self.m_OrderConfirm = false
	g_WarCtrl:SetReplace(false)
	g_WarCtrl:ResumeAfterReplace()
end

function CWarReplaceMenu.LastHoverWarrior(self)
	return getrefobj(self.m_LastHoverRef)
end

function CWarReplaceMenu.RefershPartners(self)
	self.m_CardGrid:Clear()
	self.m_CardGrid.m_StartIdx = 1
	self.m_CardGrid:InitGrid()
	self.m_CardGrid:ResetChilds()
	local list = {}
	if self.m_FilterRare == 0 then
		list = g_PartnerCtrl:GetPartnerList(true)
	else
		list = g_PartnerCtrl:GetPartnerByRare(self.m_FilterRare, true)
	end
	
	table.sort(list, callback(self, "PartnerSortFunc"))
	self.m_CardGrid:RefresAll(list)
	self.m_NoParLabel:SetActive(#list == 0)
end

function CWarReplaceMenu.PartnerSortFunc(self, oPartner1, oPartner2)
	local pos1 = g_PartnerCtrl:GetFightPos(oPartner1:GetValue("parid")) or 9999
	local pos2 = g_PartnerCtrl:GetFightPos(oPartner2:GetValue("parid")) or 9999
	if pos1 ~= pos2 then
		return pos1 < pos2
	end
	local iPowner1 = oPartner1:GetValue("power")
	local iPowner2 = oPartner2:GetValue("power")
	if iPowner1 and iPowner2 and iPowner1 ~= iPowner2 then
		return iPowner2 < iPowner1
	end
	local iRare1 = oPartner1:GetValue("rare")
	local iRare2 = oPartner2:GetValue("rare")
	if iRare1 and iRare2 and iRare1 ~= iRare2 then
		return oPartner1:GetValue("rare") > oPartner2:GetValue("rare")
	end
	return oPartner1:GetValue("parid") < oPartner2:GetValue("parid")
end

function CWarReplaceMenu.OnDragStart(self, oCard)
	self.m_CardGrid:EnableTouch(false)
	oCard:SetAlpha(0.5)
	self.m_CardGrid:SetActive(false)
	g_WarCtrl:CheckReplace(true)
end

function CWarReplaceMenu.OnDragging(self, oCard)
	local worldPos = oCard:GetCenterPos()
	local oCam = g_CameraCtrl:GetUICamera()
	local screenPos = oCam:WorldToScreenPoint(worldPos)
	local oWarrior = g_WarTouchCtrl:GetTouchWarrior(screenPos.x, screenPos.y)
	local oLastWarrior = self:LastHoverWarrior()
	if oLastWarrior ~= oWarrior then
		if oLastWarrior then
			oLastWarrior:DelBindObj("light")
		end
		if oWarrior and oWarrior:IsCanReplace() then
			oWarrior:AddBindObj("light")
			self.m_LastHoverRef = weakref(oWarrior)
		else
			self.m_LastHoverRef = nil
		end
	end
end

function CWarReplaceMenu.OnDragEnd(self, oCard)
	oCard:SetAlpha(1)
	local oLastWarrior = self:LastHoverWarrior()
	if oLastWarrior then
		printc("交换", oLastWarrior.m_ID)
		oLastWarrior:DelBindObj("light")
		oLastWarrior:SetUseMagic(nil)
		if g_WarCtrl:IsPrepare() then
			netwar.C2GSWarPartner(g_WarCtrl:GetWarID(), {{pos=oLastWarrior.m_CampPos, parid=oCard.m_PartnerID}})
		else
			g_WarCtrl:ReplacePartner(oLastWarrior.m_ID, oCard.m_PartnerID)
		end
	else
		local worldPos = oCard:GetCenterPos()
		local oCam = g_CameraCtrl:GetUICamera()
		local screenPos = oCam:WorldToScreenPoint(worldPos)
		local oWarrior = g_WarTouchCtrl:GetTouchWarrior(screenPos.x, screenPos.y)
		if oWarrior and oWarrior.m_IsFightLock then
			g_NotifyCtrl:FloatMsg(g_WarCtrl:GetLockReplaceTip())
		end
	end
	self.m_LastHoverRef = nil
	self.m_CardGrid:SetActive(true)
	self.m_CardGrid:EnableTouch(true)
	g_WarCtrl:CheckReplace(false)
end

function CWarReplaceMenu.FroceEndDrag(self)
	g_UITouchCtrl:FroceEndDrag()
	local oLastWarrior = self:LastHoverWarrior()
	if oLastWarrior then
		oLastWarrior:DelBindObj("light")
	end
	self.m_LastHoverRef = nil
	self.m_CardGrid:SetActive(true)
	self.m_CardGrid:EnableTouch(true)
	g_WarCtrl:CheckReplace(false)
end

function CWarReplaceMenu.CountDown(self)
	if not Utils.IsNil(self) then
		if g_WarCtrl:IsPrepare() then
			local iRemain = g_WarCtrl:GetRemainPrepareTime()
			if iRemain and iRemain>0 then
				self.m_StateLabel:SetActive(true)
				self.m_StateLabel:SetText(tostring(iRemain))
				return true
			else
				if self.m_StartWarBtn:GetActive() then
					self:OnStartWar()
				end
				self.m_WaitLabel:SetActive(true and not self.m_IsOnlyOneSelf)
				self.m_StateLabel:SetActive(false)
				self.m_StartWarBtn:SetActive(false)
				self.m_CountDownTimer = nil
			end
		end
	end
end

function CWarReplaceMenu.SetActive(self, bActive)
	local bAct = self:GetActive()
	if bAct and not bActive and not self.m_OrderConfirm then
		self:OnCancel()
	end
	CBox.SetActive(self, bActive)
end

return CWarReplaceMenu
local CHeroboxView = class("CHeroboxView", CViewBase)
CHeroboxView.Max = 21
function CHeroboxView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/Herobox/HeroboxView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Shelter"

	g_NetCtrl:SetCacheProto("herobox", true)
	g_NetCtrl:ClearCacheProto("herobox", true)	
end

function CHeroboxView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_StopBtn = self:NewUI(3, CButton)
	self:InitContent()
	g_MapTouchCtrl:StopAutoWalk()
	g_MapTouchCtrl:SetLockTouch(true)
end

function CHeroboxView.InitContent(self)
	self.m_Stop = nil
	self.m_Queues = nil
	self.m_CurIdx = 1
	self.m_BoxList = {}
	self.m_Grid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_SelectSpr = oBox:NewUI(1, CSprite)
		oBox.m_ItemBox = oBox:NewUI(2, CItemRewardBox)
		oBox.m_QualitySprite = oBox:NewUI(3, CSprite)
		oBox.m_NameLabel = oBox:NewUI(4, CLabel)
		oBox.m_UIEffect = oBox:NewUI(5, CUIEffect)
		oBox.m_UIEffect:Above(oBox.m_SelectSpr)
		oBox.m_SelectSpr:SetActive(false)
		self.m_BoxList[idx] = oBox
		return oBox
	end)
	self.m_StopBtn:AddUIEvent("click", callback(self, "OnStopBtn"))
end

function CHeroboxView.OnStopBtn(self)
	if self.m_AutoTimer then
		Utils.DelTimer(self.m_AutoTimer)
		self.m_AutoTimer = nil
	end
	self.m_StopBtn:SetGrey(true)
	self.m_Stop = true
end

function CHeroboxView.SetData(self, lData)
	local lrandom = {}
	while next(lData) do
		local idx = Utils.RandomInt(1, #lData)
		table.insert(lrandom, table.remove(lData, idx))
	end
	--类型4的2个必定触发奖励位置为第二行和第三行最后一格即14，21
	local tmp = {}
	for i,v in ipairs(lrandom) do
		if v.type == 4 then
			if lrandom[7].type ~= 4 then
				local tmp = v
				lrandom[i] = lrandom[7]
				lrandom[7] = tmp
			elseif lrandom[14].type ~= 4 then
				local tmp = v
				lrandom[i] = lrandom[14]
				lrandom[14] = tmp
			elseif lrandom[21].type ~= 4 then
				local tmp = v
				lrandom[i] = lrandom[21]
				lrandom[21] = tmp
			end
		end
	end
	local config = {isLocal = true,}
	for i,oBox in ipairs(self.m_Grid:GetChildList()) do
		local d = lrandom[i]
		if d then
			oBox.m_ItemBox:SetItemBySid(d.sid, d.amount, config)
			local itemdata_quality = oBox.m_ItemBox:GetItemDataQuality()
			local name = oBox.m_ItemBox:GetName()
			oBox.m_QualitySprite:SetBagNameBgQuality(itemdata_quality)
			oBox.m_NameLabel:SetText(name)
			oBox.m_UIEffect:SetActive(d.type == 4 or d.type == 3)
			if d.hit == 1 then
				self.m_Result = i
				self.m_Tag = self.m_Result - 3
				if self.m_Tag <= 0 then
					self.m_Tag = CHeroboxView.Max + self.m_Tag
				end
			end
		end
	end
	self:AutoStop()
	self:NormalAnim()
end

function CHeroboxView.AutoStop(self)
	if not self.m_AutoTimer then
		local time = 30
		local function autostop()
			if Utils.IsNil(self) then
				return
			end
			if time == 0 then
				self:OnStopBtn()
				return
			end
			time = time - 1
			return true
		end
		self.m_AutoTimer = Utils.AddTimer(autostop, 1, 0)
	end
end

function CHeroboxView.NormalAnim(self)
	if not self.m_NormalTimer then
		local function normalanim()
			if Utils.IsNil(self) then
				return
			end
			local oBox = self.m_BoxList[self.m_CurIdx]
			if oBox then
				if self.m_CurBox then
					self.m_CurBox.m_SelectSpr:SetActive(false)
				end
				self.m_CurBox = oBox
				self.m_CurBox.m_SelectSpr:SetActive(true)
				g_AudioCtrl:PlaySound(define.Audio.SoundPath.Btn)
			end
			self.m_CurIdx = self.m_CurIdx + 1
			if self.m_CurIdx > CHeroboxView.Max then
				self.m_CurIdx = 1
			end
			if self.m_Stop then
				if self.m_CurIdx == self.m_Tag then
					self:StopAnim()
					return false
				end
			end
			return true
		end
		self.m_NormalTimer = Utils.AddTimer(normalanim, 0.1, 0)
	end
end

function CHeroboxView.StopAnim(self)
	if self.m_NormalTimer then
		Utils.DelTimer(self.m_NormalTimer)
		self.m_NormalTimer = nil		
	end
	if not self.m_StopTimer then
		local function stopanim()
			if Utils.IsNil(self) then
				return
			end
			local oBox = self.m_BoxList[self.m_CurIdx]
			if oBox then
				if self.m_CurBox then
					self.m_CurBox.m_SelectSpr:SetActive(false)
				end
				self.m_CurBox = oBox
				self.m_CurBox.m_SelectSpr:SetActive(true)
				g_AudioCtrl:PlaySound(define.Audio.SoundPath.Btn)
			end
			if self.m_CurIdx == self.m_Result  then
				self:AddHorseRace()
				self:DelayClose()
				return false
			end
			self.m_CurIdx = self.m_CurIdx + 1
			if self.m_CurIdx > CHeroboxView.Max then
				self.m_CurIdx = 1
			end
			return true
		end
		self.m_StopTimer = Utils.AddTimer(stopanim, 0.5, 0.1)
	end
end

function CHeroboxView.SetHorseRace(self, horse_race)
	self.m_HorseRace = horse_race
end

function CHeroboxView.AddHorseRace(self)
	nethuodong.C2GSFinishGetReward("herobox")
	if self.m_HorseRace then
		g_ChatCtrl:AddMsg(self.m_HorseRace)
	end
end

function CHeroboxView.DelayClose(self)
	local function delay()
		CItemTipsMainView:CloseView()
		CItemTipsSimpleInfoView:CloseView()
		local itemlist = g_ItemCtrl:GetItemIDListBySid(10040)
		local itemid = itemlist[1]
		if itemid then
			local oItem = g_ItemCtrl:GetItem(itemid)
			table.insert(g_ItemCtrl.m_QuickUseIdCache, itemid)
			g_ItemCtrl:LocalShowQuickUse()
		end
		self:CloseView()
	end
	Utils.AddTimer(delay, 2, 2)
end

function CHeroboxView.CloseView(self)
	g_NetCtrl:SetCacheProto("herobox", false)
	g_NetCtrl:ClearCacheProto("herobox", true)
	g_MapTouchCtrl:SetLockTouch(false)
	CViewBase.CloseView(self)
end

--~CHeroboxView:ShowView()
return CHeroboxView
local CTravelItemBox = class("CTravelItemBox", CBox)

function CTravelItemBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_Type = nil
	self.m_IconSprite = self:NewUI(1, CSprite)
	self.m_QulitySprite = self:NewUI(2, CSprite)
	self.m_EffectLabel = self:NewUI(3, CLabel)
	self.m_TimeLabel = self:NewUI(4, CLabel)
	self.m_AddSprite = self:NewUI(5, CSprite)
	self:AddUIEvent("click", callback(self, "OnClick"))
end

function CTravelItemBox.OnClick(self, obj)
	if self.m_Type == define.Travel.Type.Mine then
		CTravelItemView:ShowView()
		if next(g_ItemCtrl:GetTravelItems()) and not IOTools.GetRoleData("travel_item_first") then
			IOTools.SetRoleData("travel_item_first", true)
			self.m_AddSprite:DelEffect("circle")
		end
	elseif self.m_Type == define.Travel.Type.Friend then
		g_NotifyCtrl:FloatMsg("无法对好友游历添加道具")
	end
end

function CTravelItemBox.Refresh(self, iType)
	self.m_Type = iType
	if self.m_Type == define.Travel.Type.Mine then
		self:RefreshMine()
	elseif self.m_Type == define.Travel.Type.Friend then
		self:RefreshFriend()
	end
end

function CTravelItemBox.RefreshMine(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	local dData = g_TravelCtrl:GetTravelMineItemInfo()
	if dData and dData.sid and dData.sid ~= 0 and dData.end_time and dData.server_time then
		local sid = dData.sid
		local oItem = CItem.NewBySid(sid)	
		self.m_IconSprite:SpriteItemShape(oItem:GetValue("icon"))
		self.m_QulitySprite:SetItemQuality(oItem:GetValue("quality"))
		self.m_EffectLabel:SetText(oItem:GetValue("description"))
		self.m_AddSprite:SetActive(false)
		self.m_AddSprite:DelEffect("circle")
		local time = math.min(dData.end_time - g_TimeCtrl:GetTimeS(), oItem:GetValue("add_time"))
		local function countdown()
			if Utils.IsNil(self) then
				return 
			end
			if time >= 0 then
				self.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(time, true))
				time = time - 1
				return true
			end
		end
		self.m_Timer = Utils.AddTimer(countdown, 1, 0)		
	else
		self.m_EffectLabel:SetText("")
		self.m_TimeLabel:SetText("")
		self.m_IconSprite:SetSpriteName(nil)
		self.m_QulitySprite:SetSpriteName(nil)
		self.m_AddSprite:SetActive(self.m_Type == define.Travel.Type.Mine)
		if self.m_Type == define.Travel.Type.Mine and next(g_ItemCtrl:GetTravelItems()) and not IOTools.GetRoleData("travel_item_first") then
			self.m_AddSprite:AddEffect("circle")
		end
	end
end

function CTravelItemBox.RefreshFriend(self)
	local dData = g_TravelCtrl:GetFrdTravelItem()
	if dData and dData.sid and dData.sid ~= 0 and dData.end_time then
		local sid = dData.sid
		local oItem = CItem.NewBySid(sid)	
		self.m_IconSprite:SpriteItemShape(oItem:GetValue("icon"))
		self.m_QulitySprite:SetItemQuality(oItem:GetValue("quality"))
		self.m_EffectLabel:SetText(oItem:GetValue("description"))
		self.m_AddSprite:SetActive(false)
		if self.m_Timer then
			Utils.DelTimer(self.m_Timer)
			self.m_Timer = nil
		end
		local time = dData.end_time - g_TimeCtrl:GetTimeS()
		local function countdown()
			if Utils.IsNil(self) then
				return 
			end
			if time >= 0 then
				self.m_TimeLabel:SetText(g_TimeCtrl:GetLeftTime(time, true))
				time = time - 1
				return true
			end
		end
		self.m_Timer = Utils.AddTimer(countdown, 1, 0)
	else
		if self.m_Timer then
			Utils.DelTimer(self.m_Timer)
			self.m_Timer = nil
		end
		self.m_EffectLabel:SetText("")
		self.m_TimeLabel:SetText("")
		self.m_IconSprite:SetSpriteName(nil)
		self.m_QulitySprite:SetSpriteName(nil)
		self.m_AddSprite:SetActive(self.m_Type == define.Travel.Type.Mine)
	end
end

return CTravelItemBox
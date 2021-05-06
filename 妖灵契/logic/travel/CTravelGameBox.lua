local CTravelGameBox = class("CTravelGameBox", CBox)

function CTravelGameBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_Type = nil
	self.m_ActorTexture = self:NewUI(2, CActorTexture)
	self.m_DuiHuaLabel = self:NewUI(3, CLabel)

	self.m_ActorTexture:ChangeShape(1016)
	--self:AddUIEvent("click", callback(self, "OnClick"))
end

function CTravelGameBox.OnClick(self, obj)
	CTravelGameView:ShowView()
end

function CTravelGameBox.Refresh(self, iType)
	self.m_Type = iType
	if self.m_Type == define.Travel.Type.Mine then
		self:RefreshMine()
	elseif self.m_Type == define.Travel.Type.Friend then
		self:RefreshFriend()
	end
end

function CTravelGameBox.RefreshMine(self)
	self:SetActive(g_TravelCtrl:GetTravelGameInfo())
end

function CTravelGameBox.SetActive(self, bActive)
	CObject.SetActive(self, bActive)
	self:OpenSay(bActive)
	if not bActive then
		g_TravelCtrl:SetTravelGameRedDot(false)
	end
end

function CTravelGameBox.OpenSay(self, bOpen)
	if bOpen then
		local time = 10
		local function say()
			if Utils.IsNil(self) then
				return
			end
			if time % 10 == 0 then
				local dData = table.randomvalue(data.traveldata.TRAVEL_NPCSAY)
				self.m_DuiHuaLabel:SetActive(true)
				self.m_DuiHuaLabel:SetText(dData.desc)
			elseif time % 5 == 0 then
				self.m_DuiHuaLabel:SetActive(false)
			end
			time = time - 1
			if time == 0 then
				time = 10
			end
			return true
		end
		if not self.m_SayTimer then
			self.m_SayTimer = Utils.AddTimer(say, 1, 0) 
		end
	else
		if self.m_SayTimer then
			Utils.DelTimer(self.m_SayTimer)
			self.m_SayTimer = nil
		end
	end
end

function CTravelGameBox.RefreshFriend(self)
	self:SetActive(false)
end

return CTravelGameBox
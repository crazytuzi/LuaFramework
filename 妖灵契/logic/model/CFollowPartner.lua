local CFollowPartner = class("CFollowPartner", CMapWalker)

function CFollowPartner.ctor(self)
	CMapWalker.ctor(self)

	self.m_ClientNpc = nil
	self.m_Timer = nil
	self:SetCheckInScreen(true)
end

function CFollowPartner.SetData(self, clientNpc)
	self.m_Actor:SetLocalRotation(Quaternion.Euler(0, taskNpc.rotateY or 150, 0))
end

function CFollowPartner.SetChatData(self, iShape)
	local d = data.partnerchatdata.PartnerChat
	if d[iShape] then
		local chatdata = {}
		if d[iShape][g_MapCtrl:GetMapID()] then
			chatdata = d[iShape][g_MapCtrl:GetMapID()]
		else
			chatdata = table.values(d[iShape])[1]
		end
		if chatdata then
			local chatmsg = chatdata["chatmsg"] or ""
			self.m_ChatList = string.split(chatmsg, "|")
		end
	end
	self:CreateChatTimer()
end

function CFollowPartner.CreateChatTimer(self)
	if self.m_ChatTimer then
		Utils.DelTimer(self.m_ChatTimer)
	end
	if not self.m_ChatList then
		return
	end
	self.m_DelaySecond = math.Random(60, 100)
	self.m_CurSecond = 0
	local function update()
		if Utils.IsNil(self) then
			return false
		end
		self.m_CurSecond = self.m_CurSecond + 1
		if self.m_CurSecond >= self.m_DelaySecond then
			self:DoChatAction()
			self.m_CurSecond = 0
			self.m_DelaySecond = math.Random(60, 100)
		end
		return true
	end
	self.m_ChatTimer = Utils.AddTimer(update, 1, 1)
end

function CFollowPartner.DoChatAction(self)
	if self.m_ChatList then
		local msg = table.randomvalue(self.m_ChatList)
		local msgobj = CChatMsg.New(0, {channel = type, text = msg})
		self:ChatMsg(msgobj)
	end
end

function CFollowPartner.ChangeShape(self, iShape, tDesc, func)
	self:SetChatData(iShape)
	CMapWalker.ChangeShape(self, iShape, tDesc, func)
end

function CFollowPartner.OnTouch(self)
	CMapWalker.OnTouch(self, self.m_ClientNpc.npcid)
end

function CFollowPartner.Trigger(self)

end

function CFollowPartner.Destroy(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	CMapWalker.Destroy(self)
end

return CFollowPartner
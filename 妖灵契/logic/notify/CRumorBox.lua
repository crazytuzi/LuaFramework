local CRumorBox = class("CRumorBox", CBox)

function CRumorBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Label = self:NewUI(1, CLabel)
	self.m_Bg = self:NewUI(2, CSprite)
	self.m_MsgList = {}
	self.m_DisplayMsg = nil
	self.m_Bg:SetActive(false)
end

function CRumorBox.Clear(self)
	self.m_MsgList = {}
	self:Hide()
end

function CRumorBox.AddMsg(self, oMsg)
	table.insert(self.m_MsgList, oMsg)
	if not self.m_DisplayMsg then
		self:PlayNext()
	end
end

function CRumorBox.DisplayOne(self)
	local oMsg = self.m_MsgList[1]
	table.remove(self.m_MsgList, 1)
	self.m_DisplayMsg = oMsg
	self.m_Bg:SetActive(true)
	self.m_Label:SetRichText("[FFF1C0FF]"..oMsg:GetText().."[-]", true)

	local labelW, _ = self.m_Label:GetSize()
	local bgW, _ = self.m_Bg:GetSize()
	self.m_Bg:ResetAndUpdateAnchors()
	local function delay()
		Utils.AddTimer(callback(self, "PlayNext"), 0, 0)
	end
	
	local starx = bgW/2
	local endx = -(bgW/2 + labelW)
	self.m_Label:SetLocalPos(Vector3.New(starx, 0, 0))
	local v = data.chatdata.HORSESPEED[1]["speed"]
	local t = (starx - endx) / v
	local function move()
		local pos = self.m_Label:GetLocalPos()
		local oAction = CStableMove.New(self.m_Label, t, pos, Vector3.New(endx, pos.y, pos.z))
		oAction:SetEndCallback(delay)
		g_ActionCtrl:AddAction(oAction)
	end
	Utils.AddTimer(move, 0, 0.5)
end

function CRumorBox.PlayNext(self)
	if next(self.m_MsgList) then
		self:DisplayOne()
	else
		Utils.AddTimer(callback(self, "Hide"), 0, 1)
	end
end

function CRumorBox.Hide(self)
	self.m_DisplayMsg = nil
	self.m_Bg:SetActive(false)
end

return CRumorBox
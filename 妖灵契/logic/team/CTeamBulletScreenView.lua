CBulletScreenView = require "logic.partner.CBulletScreenView"
local CTeamBulletScreenView = class("CTeamBulletScreenView", CBulletScreenView)

function CTeamBulletScreenView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	local w, h = UITools.GetRootSize()
	self.m_Width = w
	self.m_BG:SetSize(w, 300)
	self:InitState()
	g_ChatCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CTeamBulletScreenView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Chat.Event.AddMsg then
		local oMsg = oCtrl.m_EventData
		local iChannel = oMsg:GetValue("channel")
		
		if iChannel ~= define.Channel.Team then
			return
		end
		self:AddMsg(oMsg)
	end
end

function CTeamBulletScreenView.AddMsg(self, oMsg)
	table.insert(self.m_MsgList, oMsg)
	self:PlayNext()
end

function CTeamBulletScreenView.CreateLable(self, oMsg, iTrack)
	local sMsg = oMsg:GetBulletScreenText()
	local pid = oMsg:GetRoleInfo("pid")
	local label = self.m_Label:Clone()
	if pid == g_AttrCtrl.pid then
		label = self.m_SelfLabel:Clone()
		label:SetParent(self.m_SelfLabel:GetParent())
	else
		label:SetParent(self.m_Label:GetParent())
	end
	
	label:SetActive(true)
	label:SetRichText(sMsg, true)
	local lw, lh = label:GetSize()
	local p = label:GetLocalPos()
	p.x = self.m_Width/2 + lw
	p.y = p.y - iTrack*40
	label:SetLocalPos(p)
	return label
end

return CTeamBulletScreenView
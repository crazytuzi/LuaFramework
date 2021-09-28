RankSelectPanel = BaseClass(LuaUI)

function RankSelectPanel:__init(...)
	self.URL = "ui://7dvfcqznqjbsn";
	self:__property(...)
	self:Config()
end

function RankSelectPanel:SetProperty(...)
	
end

function RankSelectPanel:Config()
	
end

function RankSelectPanel:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Rank","RankSelectPanel");

	self.n0 = self.ui:GetChild("n0")
	self.headIcon = self.ui:GetChild("headIcon")
	self.bnt1 = self.ui:GetChild("bnt1")
	self.playerName = self.ui:GetChild("playerName")
	self.groupName = self.ui:GetChild("groupName")
	self.bnt2 = self.ui:GetChild("bnt2")
	self.bnt3 = self.ui:GetChild("bnt3")
	self.bnt4 = self.ui:GetChild("bnt4")

	self.bnt1:GetChild("colName5").text = "加好友"
	self.bnt2:GetChild("colName5").text = "私聊"
	self.bnt3:GetChild("colName5").text = "组队"
	self.bnt4:GetChild("colName5").text = "查看信息"

	self:AddEvent()
end

function RankSelectPanel.Create(ui, ...)
	return RankSelectPanel.New(ui, "#", {...})
end

function RankSelectPanel:AddEvent()
	self.bnt1.onClick:Add(self.OnBnt1Handler, self)
	self.bnt2.onClick:Add(self.OnBnt2Handler, self)
	self.bnt3.onClick:Add(self.OnBnt3Handler, self)
	self.bnt4.onClick:Add(self.OnBnt4Handler, self)
end

function RankSelectPanel:RemoveEvent()
	self.bnt1.onClick:Remove(self.OnBnt1Handler, self)
	self.bnt2.onClick:Remove(self.OnBnt2Handler, self)
	self.bnt3.onClick:Remove(self.OnBnt3Handler, self)
	self.bnt4.onClick:Remove(self.OnBnt4Handler, self)
end

function RankSelectPanel:OnBnt1Handler()
	self:Hide()
end

function RankSelectPanel:OnBnt2Handler()
	self:Hide()
end

function RankSelectPanel:OnBnt3Handler()
	self:Hide()
end

function RankSelectPanel:OnBnt4Handler()
	GlobalDispatcher:DispatchEvent(EventName.CheckOtherPlayerInfo, self.data.playerId)
	self:Hide()
end

function RankSelectPanel:Hide()
	self:SetVisible(false)
end

function RankSelectPanel:Update(data)
	self:SetVisible(true)
	self.data = data

	self.headIcon.icon = "Icon/Head/r"..self.data.career
	self.playerName.text = self.data.playerName
	if self.data.guildName == "" then
		self.groupName.text = "帮派 无"
	else
		self.groupName.text = StringFormat("帮派 {0}",self.data.guildName)
	end
end

function RankSelectPanel:__delete()
	self:RemoveEvent()
end
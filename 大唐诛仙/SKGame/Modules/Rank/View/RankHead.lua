RankHead = BaseClass(LuaUI)

function RankHead:__init(...)
	self.URL = "ui://7dvfcqznjg8tl";
	self:__property(...)
	self:Config()
end

function RankHead:SetProperty(...)
	
end

function RankHead:Config()
	
end

function RankHead:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Rank","RankHead");

	self.n0 = self.ui:GetChild("n0")
	self.headIcon = self.ui:GetChild("headIcon")
	self.name = self.ui:GetChild("name")
	self.property = self.ui:GetChild("property")
	self.rank = self.ui:GetChild("rank")

	self.data = nil

	self:AddEvent()
end

function RankHead.Create(ui, ...)
	return RankHead.New(ui, "#", {...})
end

function RankHead:AddEvent()
	self.ui.onClick:Add(self.OnRankHeadClickHandler, self)
end

function RankHead:RemoveEvent()
	self.ui.onClick:Remove(self.OnRankHeadClickHandler, self)
end

function RankHead:OnRankHeadClickHandler(context)
	if not self.data then return end

	if SceneModel:GetInstance():GetMainPlayer().playerId == self.data.playerId then
		return
	end
			
	local data = {}
	data.playerId = self.data.playerId
	data.funcIds = {PlayerFunBtn.Type.AddFriend, PlayerFunBtn.Type.Chat, PlayerFunBtn.Type.InviteTeam, PlayerFunBtn.Type.CheckPlayerInfo}
	GlobalDispatcher:DispatchEvent(EventName.ShowPlayerFuncPanel, data)
end

function RankHead:SetData(data)
	self.data = data

	self.headIcon.icon = "Icon/Head/r"..self.data.career
	self.name.text = self.data.playerName
	self.property.text = self.data.value
	self.rank.text = self.data.rank
end

function RankHead:ShowEmpty()
	self.data = nil
	self.headIcon.icon = nil
	self.name.text = "----"
	self.property.text = "----"
	self.rank.text = ""
end


function RankHead:__delete()
	self:RemoveEvent()
end
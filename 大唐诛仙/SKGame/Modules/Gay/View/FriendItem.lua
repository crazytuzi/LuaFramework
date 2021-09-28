FriendItem = BaseClass(LuaUI)
function FriendItem:__init(...)
	self.URL = "ui://jn83skxku3cyc";
	self:__property(...)
	self:Config()
end
function FriendItem:SetProperty(...)
	
end
function FriendItem:Config()
	self.model = FriendModel:GetInstance()
	self:InitEvent()
end

function FriendItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Gay","FriendItem");

	self.button = self.ui:GetController("button")
	self.bg_btn = self.ui:GetChild("bg_btn")
	self.headIcon = self.ui:GetChild("headIcon")
	self.btn_lookInfo = self.ui:GetChild("btn_lookInfo")
	self.playerName = self.ui:GetChild("playerName")
	self.playerKind = self.ui:GetChild("playerKind")
	self.zhiyeName = self.ui:GetChild("zhiyeName")
	self.offlineTime = self.ui:GetChild("offlineTime")
	self.redIcon = self.ui:GetChild("redIcon")
	self.playerId = 0
	
end

function FriendItem:AddEvent()
	
end

function FriendItem:InitEvent()
	self.handler0 = self.model:AddEventListener(FriendConst.PrivateChatRed, function(chatVo) 
		self:Red(chatVo)
	end)
	self.handler1 = self.model:AddEventListener(FriendConst.CloseRedItem,function(playerId)
		if self.playerId == playerId then
			self.redIcon.visible = false
		end
	end)
end

function FriendItem:Red(chatVo)
	if chatVo.sendPlayerId == self.playerId then
		self.redIcon.visible = true
	end
end

function FriendItem.Create(ui, ...)
	return FriendItem.New(ui, "#", {...})
end
function FriendItem:__delete()
	if self.model then
		self.model:RemoveEventListener(self.handler0)
		self.model:RemoveEventListener(self.handler1)
	end
end
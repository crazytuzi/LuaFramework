PlayerInfo =BaseClass(LuaUI)

function PlayerInfo:__init( ... )
	self.URL = "ui://0042gniteg11ak";
	self:__property(...)
	self:Config()
end

function PlayerInfo:SetProperty( ... )
end

function PlayerInfo:Config()

end

function PlayerInfo:InitPlayerInfo()
	local role = SceneModel:GetInstance():GetMainPlayer()
	if role then
		--print("RefreshPlayerInfo=====>>>>", role.hp, role.hpMax)
		self.levelLabel.text = StringFormat("{0}",role.level)
		self.hpBar.max = role.hpMax
		self.hpBar.value = math.max(role.hp,0)
		self.mpBar.max = role.mpMax
		self.mpBar.value = math.max(role.mp,0)
		self.headIcon.url = StringFormat("Icon/Head/r{0}",role.career)
		self.powerLabel.text = StringFormat("i{0}",role.battleValue)
	end
end

function PlayerInfo:RefreshPlayerInfo()
	local role = SceneModel:GetInstance():GetMainPlayer()
	if role then
		--print("RefreshPlayerInfo=====>>>>", role.hp, role.hpMax)
		self.levelLabel.text = StringFormat("{0}",role.level)
		self.hpBar.max = role.hpMax
		self.hpBar.value = math.max(role.hp,0)
		self.mpBar.max = role.mpMax
		self.mpBar.value = math.max(role.mp,0)
		self.headIcon.url = StringFormat("Icon/Head/r{0}",role.career)
		self.powerLabel.text = StringFormat("i{0}",role.battleValue)
	end
end
function PlayerInfo:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","PlayerInfo")
	self.bgName = self.ui:GetChild("BgName")
	self.hpBar = self.ui:GetChild("HpBar")
	self.mpBar = self.ui:GetChild("MpBar")
	self.headIcon = self.ui:GetChild("HeadIcon")
	self.powerLabel = self.ui:GetChild("PowerLabel")
	self.levelLabel = self.ui:GetChild("LevelLabel")
end

function PlayerInfo.Create( ui, ...)
	return PlayerInfo.New(ui, "#", {...})
end

function PlayerInfo:__delete()
	
	self.bgName = nil
	self.hpBar = nil
	self.mpBar = nil
	self.headIcon = nil
	self.powerLabel = nil
	self.levelLabel = nil
end
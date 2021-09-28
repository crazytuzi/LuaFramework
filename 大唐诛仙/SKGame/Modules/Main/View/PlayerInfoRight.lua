PlayerInfoRight =BaseClass(LuaUI)

function PlayerInfoRight:__init( ... )
	self.URL = "ui://0042gnitnnjff3";
	self:__property(...)
	self:Config()
end

function PlayerInfoRight:SetProperty( ... )
end

function PlayerInfoRight:Config()

end

function PlayerInfoRight:InitPlayerInfo(role)
	if role then
		self.guid = role.guid
		self.levelLabel.text = StringFormat("{0}",role.level)
		self.hpBar.max = role.hpMax
		self.hpBar.value = math.max(role.hp,0)
		self.mpBar.max = role.mpMax
		self.mpBar.value = math.max(role.mp,0)
		self.headIcon.url = StringFormat("Icon/Head/r{0}",role.career)
		self.powerLabel.text = StringFormat("i{0}",role.battleValue or 0)
		self:IniBuffContainer()
	end
end

function PlayerInfoRight:RefreshPlayerInfo(k, v)
	if k == "level" then
		self.levelLabel.text = StringFormat("{0}", v)
	elseif k == "hpMax" then
		self.hpBar.max = v
	elseif k == "hp" then
		self.hpBar.value = math.max(v, 0)
	elseif k == "mpMax" then
		self.mpBar.max = v
	elseif k == "mp" then
		self.mpBar.value = math.max(v, 0)
	elseif k == "career" then
		self.headIcon.url = StringFormat("Icon/Head/r{0}", v)
	elseif k == "battleValue" then
		self.powerLabel.text = StringFormat("i{0}", v)
	end
end

function PlayerInfoRight:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","PlayerInfoRight")
	self.bgName = self.ui:GetChild("BgName")
	self.hpBar = self.ui:GetChild("HpBar")
	self.mpBar = self.ui:GetChild("MpBar")
	self.headIcon = self.ui:GetChild("HeadIcon")
	self.powerLabel = self.ui:GetChild("PowerLabel")
	self.levelLabel = self.ui:GetChild("LevelLabel")
	self.buffList = self.ui:GetChild("buffContainer")
	self.buffDescPanel = self.ui:GetChild("buffDescPanel")
	self:AdjustUI()
end

function PlayerInfoRight:AdjustUI()
	local hpTitle = self.hpBar:GetChild("title")
	hpTitle.scaleX = -1
	hpTitle.x = 210
	local mpTitle = self.mpBar:GetChild("title")
	mpTitle.scaleX = -1
	mpTitle.x = 210
	self.powerLabel.scaleX = -1
	self.levelLabel.scaleX = -1
	self.powerLabel.x = 280
end

function PlayerInfoRight.Create( ui, ...)
	return PlayerInfoRight.New(ui, "#", {...})
end

function PlayerInfoRight:__delete()
	if self.buffUIManager then
		self.buffUIManager:Destroy()
	end
	self.bgName = nil
	self.hpBar = nil
	self.mpBar = nil
	self.headIcon = nil
	self.powerLabel = nil
	self.levelLabel = nil
	self.buffList = nil
	self.model = nil
end

function PlayerInfoRight:IniBuffContainer()
	if self.buffUIManager then
		self.buffUIManager:Destroy()
		self.buffUIManager = nil
	end
	if not self.buffUIManager then
		self.buffUIManager = BuffUIManager.New(self.buffList, self.guid, self.buffDescPanel, true)
	end
end
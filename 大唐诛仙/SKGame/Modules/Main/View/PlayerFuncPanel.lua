PlayerFuncPanel = BaseClass(LuaUI)

function PlayerFuncPanel:__init( ... )
	self.ui = UIPackage.CreateObject("Main","PlayerFuncPanel");
	
	self.headIcon = self.ui:GetChild("headIcon")
	self.playerName = self.ui:GetChild("playerName")
	self.groupName = self.ui:GetChild("groupName")

	self.container = GComponent.New()
	self.container.x = self.headIcon.x
	self.container.y = self.headIcon.y + self.headIcon.height
	self.ui:AddChild(self.container)

	self.btns = {}
end

function PlayerFuncPanel:Update(data, funcs)
	self.data = data
	self.playerId = self.data.playerId
	self.funcIds = funcs

	self:SetInfo()
	self:SetFuncs()
end

function PlayerFuncPanel:SetInfo()
	self.playerName.text = self.data.playerName
	if self.data.familyName ~= "" then
		self.groupName.text = "家族:"..self.data.familyName
	end
	self.headIcon.icon = "Icon/Head/r"..self.data.career
	self.headIcon.title = self.data.playerLevel
end

function PlayerFuncPanel:SetFuncs()
	local x = 0
	local y = 0
	local row = 0
	local col = 0
	local totalHeight = 0
	for i = 1, #self.funcIds do
		local btn = PlayerFunBtn.New()
		x = (PlayerFunBtn.Width + 8)*col
		y = (PlayerFunBtn.Height + 8)*row
		if i%2 == 0 then
			row = row + 1
			col = 0
		else
			col = col + 1
		end

		btn:SetXY(x, y)
		btn:SetType(self.funcIds[i], self)
		totalHeight = btn.ui.y + PlayerFunBtn.Height
		self.container:AddChild(btn.ui)
		self.btns[i] = btn
	end

	self.ui.height = self.container.y + totalHeight + 18
end

function PlayerFuncPanel:__delete()
	if self.btns then
		for i,v in ipairs(self.btns) do
			v:Destroy()
		end
	end
	self.btns = nil
end
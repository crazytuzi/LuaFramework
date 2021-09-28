StyleActivePanel = BaseClass(LuaUI)

function StyleActivePanel:__init( ... )
	self.URL = "ui://jqof8qcov83rc";
	self:__property(...)
	self:Config()
end

-- Set self property
function StyleActivePanel:SetProperty( ... )
end

-- start
function StyleActivePanel:Config()
	
end

-- wrap UI to lua
function StyleActivePanel:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Style","StyleActivePanel");

	self.role3D = self.ui:GetChild("role3D")
	self.eft1 = self.ui:GetChild("eft1")
	self.eft2 = self.ui:GetChild("eft2")
	self.name = self.ui:GetChild("name")

	self.eftId1 = "4403"
	self.eftId2 = "4402"

	self.ui.onClick:Add(function()
		UIMgr.HidePopup()
	end, self)
end

function StyleActivePanel:SetData(data)
	self.data = data

	self.name.text = self.data.name
	self:CreatePlayerModel(self.data.dressStyle)

	EffectMgr.AddToUI(self.eftId1, self.eft1, 0.3, pos, scale, eulerAngles, id, function(eft)
		EffectMgr.AddToUI(self.eftId2, self.eft2)
	end)
end

--创建角色3d模型
function StyleActivePanel:CreatePlayerModel(dressStyle)
	self.role3D.visible = true
	local callback = function ( o )
		if o == nil then return end
		if self.playerModel then
			destroyImmediate(self.playerModel) 
		end
		self.playerModel = GameObject.Instantiate(o)
		self.playerModel.name = dressStyle
		self.playerModel.transform.localScale = Vector3.New(260, 260, 260)
		self.playerModel.transform.localPosition = Vector3.New(40, -80, 1000)
		self.playerModel.transform.localEulerAngles = Vector3.New(0, 180, 0)

		self.role3D:SetNativeObject(GoWrapper.New(self.playerModel)) -- ui 3d对象加入
	end
	if (not self.playerModel) or (self.playerModel and tostring(self.playerModel.name) ~= tostring(dressStyle)) then
		LoadPlayer(dressStyle, callback)
	end
end

-- Combining existing UI generates a class
function StyleActivePanel.Create( ui, ...)
	return StyleActivePanel.New(ui, "#", {...})
end

function StyleActivePanel:__delete()
	if self.playerModel then
		if self.data and self.data.dressStyle then
			UnLoadPlayer(self.data.dressStyle , false)
		end
		destroyImmediate(self.playerModel) 
	end
	self.playerModel = nil
	self.data = nil

end
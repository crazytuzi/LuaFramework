WingActivePanel = BaseClass(LuaUI)
WingActivePanel.isOpen = false
function WingActivePanel:__init( ... )
	self.URL = "ui://d3en6n1nv83r1l";
	self:__property(...)
	self:Config()
	WingActivePanel.isOpen = true
end

-- Set self property
function WingActivePanel:SetProperty( ... )
end

-- start
function WingActivePanel:Config()
	
end

-- wrap UI to lua
function WingActivePanel:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Wing","WingActivePanel");

	self.role3D = self.ui:GetChild("role3D")
	self.activiteIcon = self.ui:GetChild("activiteIcon")
	self.name = self.ui:GetChild("name")
	self.eft1 = self.ui:GetChild("eft1")
	self.eft2 = self.ui:GetChild("eft2")

	self.eftId1 = "4403"
	self.eftId2 = "4402"

	self.ui.onClick:Add(function()
		UIMgr.HidePopup()
		WingActivePanel.isOpen = false
	end, self)
end

function WingActivePanel:SetData(data)
	self.data = data

	self.name.text = self.data.name
	self:CreateWingModel()

	EffectMgr.AddToUI(self.eftId1, self.eft1, 5, pos, scale, eulerAngles, id, function(eft)
		EffectMgr.AddToUI(self.eftId2, self.eft2)
	end)
end

--创建角色3d模型
function WingActivePanel:CreateWingModel()
	self.role3D.visible = true
	local callback = function ( prefab )
		if prefab == nil then return end
		self.wingModel = GameObject.Instantiate(prefab)
		self.wingModel.transform.localPosition = Vector3.New(35, -125, 1500)
		self.wingModel.transform.localScale = Vector3.New(400, 400, 400)
		self.wingModel.transform.localEulerAngles = Vector3.New(0, 90, 0)
		self.role3D:SetNativeObject(GoWrapper.New(self.wingModel)) -- ui 3d对象加入
	end
	LoadWing(self.data.dressStyle, callback)
end

-- Combining existing UI generates a class
function WingActivePanel.Create( ui, ...)
	return WingActivePanel.New(ui, "#", {...})
end

function WingActivePanel:__delete()
	if self.wingModel then
		destroyImmediate(self.wingModel) 
	end
	self.wingModel = nil
	self.data = nil
	WingActivePanel.isOpen = false
end
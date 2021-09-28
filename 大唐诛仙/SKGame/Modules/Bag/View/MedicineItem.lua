MedicineItem = BaseClass(LuaUI)
function MedicineItem:__init(root, x, y, cfg)
	self:RegistUI()
	root:AddChild(self.ui)
	self:SetXY(x, y)
	self.model = PkgModel:GetInstance()
	self.roleVo = LoginModel:GetInstance():GetLoginRole()
	self.isOnLevel = false -- 是否在等级内
	self.state = 0 -- 0 未装备, 1 装备
	self:Update(cfg)
end
function MedicineItem:RegistUI()
	self.ui = UIPackage.CreateObject("Pkg","MedicineItem")
	self.bg = self.ui:GetChild("bg")
	self.goodsIcon = self.ui:GetChild("goodsIcon")
	self.txtName = self.ui:GetChild("txtName")
	self.txtDesc = self.ui:GetChild("txtDesc")
	self.btn = self.ui:GetChild("btn")
	self.mask = self.ui:GetChild("mask")
	self.state0 = UIPackage.GetItemURL("Common","btn_000")
	self.state1 = UIPackage.GetItemURL("Common","btn_001")
end

function MedicineItem:Update(cfg)
	self.data = cfg
	if not cfg then return end
	self.goodsIcon.icon = "Icon/Goods/"..cfg.icon
	self.goodsIcon:GetChild("bg").url="Icon/Common/grid_cell_2"
	self.txtName.text = cfg.name
	self.txtDesc.text = cfg.des
end

function MedicineItem:LevelCheck()
	self.mask.visible = self.data.level > self.roleVo.level

	if self.data.level > self.roleVo.level or (not self.model:IsOnBagByBid(self.data.id)) then
		self.btn.enabled = false
		self.isOnLevel = false
	else
		self.btn.enabled = true
		self.isOnLevel = true
	end
	self.btn:GetChild("title").color = newColorByString( "FFFFCC" )
end

function MedicineItem:SetState(state)
	self.state = state
	if state == 0 then
		self.btn.title = "装备"
		self.btn.icon = self.state0
	else
		self.btn.title = "卸下"
		self.btn.icon = self.state1
	end
	self:LevelCheck()
end
function MedicineItem:SetClickCallback( cb )
	self.btn.onClick:Add(function ()
		cb(self.data.id, self.state)
	end)
end


function MedicineItem:__delete()
	self.roleVo = nil
end
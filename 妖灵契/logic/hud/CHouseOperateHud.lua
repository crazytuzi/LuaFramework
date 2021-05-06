local CHouseOperateHud = class("CHouseOperateHud", CAsyncHud)

function CHouseOperateHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/HouseOperateHud.prefab", cb, true)
end

function CHouseOperateHud.OnCreateHud(self)
	self.m_Container = self:NewUI(1, CObject)
	self.m_OperateBtns = {
		upgrade = self:NewUI(2, CButton),
		adorn = self:NewUI(3, CButton),
		lock = self:NewUI(4, CButton),
	}
	self.m_TimeLabel = self:NewUI(5, CLabel)
	self.m_Furniture = nil
	self.m_OperateBtns["upgrade"]:AddUIEvent("click", callback(self, "OnUpgrade"))
	self.m_OperateBtns["adorn"]:AddUIEvent("click", callback(self, "OnAdorn"))
	self.m_OperateBtns["lock"]:AddUIEvent("click", callback(self, "OnLock"))
	self.m_TimeLabel:AddUIEvent("click", callback(self, "OnUpgrade"))
	self:HideAll()
end

function CHouseOperateHud.ShowOperate(self, sOperate)
	if sOperate == "upgrade" then
		local oFurniture = self:GetOwner()
		if oFurniture then
			if oFurniture:GetLeftUpgradeTime() > 0 then
				self.m_OperateBtns["upgrade"]:SetGrey(false)
				self:StartUpgradeTimer()
			else
				self.m_OperateBtns["upgrade"]:SetGrey(oFurniture:IsMeetUpgradeRequire())
			end
			local bShowTime = oFurniture:GetLeftUpgradeTime() > 0
			self.m_TimeLabel:SetActive(bShowTime)
		end
	end
	for k, v in pairs(self.m_OperateBtns) do
		v:SetActive(not self.m_TimeLabel:GetActive() and (k == sOperate))
	end
end

function CHouseOperateHud.HideAll(self)
	for k, v in pairs(self.m_OperateBtns) do
		v:SetActive(false)
	end
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	self.m_TimeLabel:SetActive(false)
end

function CHouseOperateHud.StartUpgradeTimer(self)
	if not self.m_Timer then
		self.m_Timer = Utils.AddTimer(callback(self, "RefreshLabel"), 0.05, 0)
	end
end

function CHouseOperateHud.RefreshLabel(self)
	local owener = self:GetOwner()
	if Utils.IsNil(self) or not owener or owener:GetLeftUpgradeTime() <= 0 then
		return false
	else
		self.m_TimeLabel:SetActive(true)
		local sText = os.date("%M:%S", owener:GetLeftUpgradeTime())
		self.m_TimeLabel:SetText(sText)
		return true
	end
end

function CHouseOperateHud.OnUpgrade(self)
	local oFurniture = self:GetOwner()
	if not oFurniture then
		return
	end
	printc("升级", oFurniture.m_Key)
	CFurnitureUpgradeView:ShowView(function(oView)
		oView:SetFurniture(oFurniture)
	end)
end

function CHouseOperateHud.OnAdorn(self)
	local oFurniture = self:GetOwner()
	if not oFurniture then
		return
	end
	local oView = CHouseMainView:GetView()
	if not oView then
		return
	end
	oView:SetAdornBox(oFurniture, self.m_OperateBtns["adorn"])
end

function CHouseOperateHud.OnLock(self)
	printc("还没解锁", self.m_Furniture.m_Key)
end

return CHouseOperateHud
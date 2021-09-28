DescSpecialProUI =BaseClass(LuaUI)
function DescSpecialProUI:__init( ... )
	self.URL = "ui://0oudtuxpqjex3y";

	self.ui = UIPackage.CreateObject("PlayerInfo","DescSpecialProUI")

	self.n0 = self.ui:GetChild("n0")
	self.n1 = self.ui:GetChild("n1")
	self.n2 = self.ui:GetChild("n2")
	self.n3 = self.ui:GetChild("n3")
	self.closeBtn = self.ui:GetChild("closeBtn")
	self.baseBg = self.ui:GetChild("BaseBg")
	self.list = self.ui:GetChild("list")

	self:AddEvent()
	self:Update()
end

function DescSpecialProUI:AddEvent()
	self.closeBtn.onClick:Add(self.ClosePanel, self)
end

function DescSpecialProUI:RemoveEvent()
	self.closeBtn.onClick:Remove(self.ClosePanel, self)
end

function DescSpecialProUI:Update()
	local playerSpecialProp = PlayerInfoModel:GetInstance():GetPlayerSpecialProp()
	if playerSpecialProp then
		for i, v in ipairs(playerSpecialProp) do
			local item = self.list:AddItemFromPool()
			item:GetChild("PropName").text = StringFormat("{0}",v.name)
			if v.propId == 21 or v.propId == 22 or v.propId == 23 then
				local strValue = string.format("%.1f", v.value *0.01).."%"
				item:GetChild("PropValue").text= strValue
	   		else
				item:GetChild("PropValue").text= StringFormat("{0}",v.value)
	   		end
		end
	end
end

-- --关闭界面
function DescSpecialProUI:ClosePanel()
	PropInfo.IsDescSpecialProShowing = false
	UIMgr.HidePopup()
end

-- Dispose use DescSpecialProUI obj:Destroy()
function DescSpecialProUI:__delete()
	self:RemoveEvent()

	self.n0 = nil
	self.n1 = nil
	self.n2 = nil
	self.n3 = nil
	self.closeBtn = nil
	self.baseBg = nil
	self.list = nil
	if self.ui then
		self.ui:Dispose()
	end
	self.ui = nil
end
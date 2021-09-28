DescBaseProUI =BaseClass(LuaUI)
function DescBaseProUI:__init( ... )
	self.URL = "ui://0oudtuxpqjex3x";

	self.ui = UIPackage.CreateObject("PlayerInfo","DescBaseProUI")
	
	self.n3 = self.ui:GetChild("n3")
	self.closeBtn = self.ui:GetChild("closeBtn")
	self.n0 = self.ui:GetChild("n0")
	self.n1 = self.ui:GetChild("n1")
	self.n2 = self.ui:GetChild("n2")
	self.baseBg = self.ui:GetChild("BaseBg")
	self.list = self.ui:GetChild("list")

	self:AddEvent()
	self:Update()
end

function DescBaseProUI:AddEvent()
	self.closeBtn.onClick:Add(self.ClosePanel, self)
end

function DescBaseProUI:RemoveEvent()
	self.closeBtn.onClick:Remove(self.ClosePanel, self)
end

function DescBaseProUI:Update()
	local descData = PlayerInfoConst.ProDesc
	for i = 1, #descData do
		local item = self.list:AddItemFromPool()
		item:GetChild("desc").text = PlayerInfoConst.ProDesc[i]
	end

	local career = SceneController:GetInstance():GetScene():GetMainPlayer().vo.career
	local careerData = GetCfgData( "newroleDefaultvalue" ):Get(career)
	local careerDesc = careerData.careerDesc or ""

end

-- --关闭界面
function DescBaseProUI:ClosePanel()
	PropInfo.IsDescBaseProShowing = false
	UIMgr.HidePopup()
end

-- Dispose use DescBaseProUI obj:Destroy()
function DescBaseProUI:__delete()
	self:RemoveEvent()
	
	self.n3 = nil
	self.closeBtn = nil
	self.n0 = nil
	self.n1 = nil
	self.n2 = nil
	self.baseBg = nil
	self.list = nil
	self.baseBg_2 = nil

	if self.ui then
		self.ui:Dispose()
	end
	self.ui = nil
end
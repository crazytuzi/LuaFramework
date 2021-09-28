WeekTop = BaseClass(LuaUI)

function WeekTop:__init(...)
	self.URL = "ui://oa3ahys9mfyic";
	self:__property(...)
	self:Config()
end

function WeekTop:SetProperty(...)
	
end

function WeekTop:Config()
	
end

function WeekTop:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Activity","WeekTop");

	self.b1 = self.ui:GetChild("b1")
	self.b8 = self.ui:GetChild("b8")
	self.b7 = self.ui:GetChild("b7")
	self.b6 = self.ui:GetChild("b6")
	self.b5 = self.ui:GetChild("b5")
	self.b4 = self.ui:GetChild("b4")
	self.b3 = self.ui:GetChild("b3")
	self.b2 = self.ui:GetChild("b2")

	self.b1:GetChild("name").text = "时间"
	self.b2:GetChild("name").text = "星期一"
	self.b3:GetChild("name").text = "星期二"
	self.b4:GetChild("name").text = "星期三"
	self.b5:GetChild("name").text = "星期四"
	self.b6:GetChild("name").text = "星期五"
	self.b7:GetChild("name").text = "星期六"
	self.b8:GetChild("name").text = "星期日"

	self.b1:GetChild("select").visible = false
	self.b2:GetChild("select").visible = false
	self.b3:GetChild("select").visible = false
	self.b4:GetChild("select").visible = false
	self.b5:GetChild("select").visible = false
	self.b6:GetChild("select").visible = false
	self.b7:GetChild("select").visible = false
	self.b8:GetChild("select").visible = false
end

function WeekTop.Create(ui, ...)
	return WeekTop.New(ui, "#", {...})
end

function WeekTop:__delete()
end
LoadingBackToCity =BaseClass(LuaUI)
function LoadingBackToCity:__init( ... )
	self.URL = "ui://2bw6ypvmj4usd";
	self:__property(...)
	self:Config()
end
function LoadingBackToCity:SetProperty( ... )
	
end
function LoadingBackToCity:Config()
	
end
function LoadingBackToCity:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Collect","LoadingBackToCity");

	self.process_bar_back_to_city = self.ui:GetChild("process_bar_back_to_city")
	self.label_process_title = self.ui:GetChild("label_process_title")
end
function LoadingBackToCity.Create( ui, ...)
	return LoadingBackToCity.New(ui, "#", {...})
end
function LoadingBackToCity:__delete()
	
	self.process_bar_back_to_city = nil
	self.label_process_title = nil
end
NPCHeadUIPanel =BaseClass(BaseView)

-- (Constructor) use NPCHeadUIPanel.New(...)
function NPCHeadUIPanel:__init( ... )
	self.URL = "ui://y1al0f5qtjjer";

	self.ui = UIPackage.CreateObject("NPCDialog","NPCHeadUIPanel");
	
	self.id = "NPCHeadUIPanel"
	
	self.icon = self.ui:GetChild("icon")


	self:InitEvent()

end

function NPCHeadUIPanel:InitEvent()
		self.closeCallback = function () end
		self.openCallback  = function () end
end

function NPCHeadUIPanel:SetUI()

end



-- Dispose use NPCHeadUIPanel obj:Destroy()
function NPCHeadUIPanel:__delete()
	
	self.icon = nil

end
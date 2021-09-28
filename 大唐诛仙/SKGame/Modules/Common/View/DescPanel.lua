DescPanel = BaseClass(LuaUI)
function DescPanel:__init( ... )

	self.ui = UIPackage.CreateObject("Common","DescPanel");
	
	self.content = self.ui:GetChild("content")
	self.n1 = self.ui:GetChild("n1")
end
function DescPanel:SetContent(descId)
	local cfg = GetCfgData("systemDesc"):Get(descId)
	if cfg then
		self.content.text = cfg.s
	end
end

function DescPanel:MyWidth()
	return self.n1.width
end

function DescPanel:MyHeight()
	return self.n1.height
end

-- Dispose use DescPanel obj:Destroy()
function DescPanel:__delete()
end
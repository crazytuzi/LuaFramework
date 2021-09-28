GgRealNamePanel = BaseClass(LuaUI)
function GgRealNamePanel:__init(parentContainer)
	self:Config()
	self:Layout(parentContainer)
	self:SetXY(348,121)
end
function GgRealNamePanel:Config()
	
end

function GgRealNamePanel:Layout(parentContainer)
	self.ui = UIPackage.CreateObject("GongGao","GgRealNamePanel")
	if parentContainer then parentContainer:AddChild(self.ui) end
	local ggRealNamePanel = self:CreatePanelV(0, 0, 848, 586)

	local offH = 0
	local cfg = GetCfgData("name2")
	for i,v in ipairs(cfg) do
		offH = self:CreateRichText(v.s,ggRealNamePanel, v.x,offH, v.w, v.size, v.color)
	end		

end

function GgRealNamePanel:CreatePanelV( x, y, w, h)
	local panel = UIPackage.CreateObject("Common" , "CustomLayerV")
	self.ui:AddChild(panel)
	if x then panel.x = x end
	if y then panel.y = y end
	if w then panel.width = w end
	if h then panel.height = h end
	return panel
end
function GgRealNamePanel:CreateRichText(content,root,x, y,w,size,color)
	local txt = createRichText2(nil,root, x,y, 100, 100, true)
	txt.width = w
	setTxtAutoSizeType(txt,2)
	setTxtSize(txt,size,newColorByString(color))
	setRichTextContent(txt,content)
	return txt.textHeight+txt.y
end
function GgRealNamePanel:SetVisible( bool)
		self.ui.visible = bool
end

function GgRealNamePanel.Create(ui, ...)
	return GgRealNamePanel.New(ui, "#", {...})
end
function GgRealNamePanel:__delete()
end
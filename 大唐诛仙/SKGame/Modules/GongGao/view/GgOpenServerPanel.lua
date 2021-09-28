GgOpenServerPanel = BaseClass(LuaUI)
function GgOpenServerPanel:__init(parentContainer)
	self:Layout(parentContainer)
	self:Config()
	self:SetXY(348,121)
end
function GgOpenServerPanel:Config()
	
end


function GgOpenServerPanel:Layout(parentContainer)
	self.ui = UIPackage.CreateObject("GongGao","GgOpenServerPanel")
	if parentContainer then parentContainer:AddChild(self.ui) end
	local ggOpenServerPanel = self:CreatePanelV(0, 0, 848, 586)
	local offH = 0
	local cfg = GetCfgData("gonggao")
	for i,v in ipairs(cfg) do
		offH = self:CreateRichText(v.s,ggOpenServerPanel, v.x,offH, v.w, v.size, v.color)
	end
end


function GgOpenServerPanel:CreatePanelV( x, y, w, h)
	local panel = UIPackage.CreateObject("Common" , "CustomLayerV")
	self.ui:AddChild(panel)
	if x then panel.x = x end
	if y then panel.y = y end
	if w then panel.width = w end
	if h then panel.height = h end
	return panel
end

function GgOpenServerPanel:CreateRichText(content, root,x, y,w,size,color)
	local txt = createRichText2(content, root, x,y, 100, 100, true)
	txt.width = w
	setTxtAutoSizeType(txt,2)
	setTxtSize(txt,size,newColorByString(color))
	setRichTextContent(txt,content)
	return txt.textHeight+txt.y
end

function GgOpenServerPanel:SetVisible( bool)
		self.ui.visible = bool
end

function GgOpenServerPanel.Create(ui, ...)
	return GgOpenServerPanel.New(ui, "#", {...})
end
function GgOpenServerPanel:__delete()
end
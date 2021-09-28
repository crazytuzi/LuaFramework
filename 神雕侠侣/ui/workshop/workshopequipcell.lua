require "ui.dialog"

Workshopequipcell = {
	Item,
	Name,
	Level,
	Mark,
	id = 0,
}
setmetatable(Workshopequipcell, Dialog)
Workshopequipcell.__index = Workshopequipcell

function Workshopequipcell.new(parent, posindex)
	local newcell = {}
	setmetatable(newcell, Workshopequipcell)
	newcell.__index = Workshopequipcell
	newcell:OnCreate(parent, Workshopequipcell.id)
	local height = newcell.m_pMainFrame:getHeight():asAbsolute(0)
	local offset = height * posindex or 1
	newcell.m_pMainFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
	Workshopequipcell.id = Workshopequipcell.id + 1
	return newcell
end

function Workshopequipcell:OnCreate(parent, index)
	Dialog.OnCreate(self, parent, index)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.Frame = winMgr:getWindow(index.."workshopequipcell/back")
	self.Item = CEGUI.Window.toItemCell(winMgr:getWindow(index.."workshopequipcell/back/item"))
	self.Name = winMgr:getWindow(index.."workshopequipcell/back/name") 
	self.Level =  winMgr:getWindow(index.."workshopequipcell/back/level") 
	self.Mark = winMgr:getWindow(index.."workshopequipcell/back/mark")
	local childcount = self.Frame:getChildCount()
	for i = 0, childcount - 1 do
		local child = self.Frame:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
	self.Frame:setMousePassThroughEnabled(false)
end

function Workshopequipcell.GetLayoutFileName()
	print("Workshopequipcell:GetLayoutFileName\n")
	return "workshopequipcell.layout"
end

return Workshopequipcell
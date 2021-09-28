require "ui.dialog"
require "utils.log"

PetSkillBookCell = {
	count = 0,
}
setmetatable(PetSkillBookCell, Dialog)
PetSkillBookCell.__index = PetSkillBookCell

function PetSkillBookCell.new(parent)
	local cell = {}
	setmetatable(cell, PetSkillBookCell)
	cell:OnCreate(parent, PetSkillBookCell.count)
	PetSkillBookCell.count = PetSkillBookCell.count + 1
	return cell
end

function PetSkillBookCell:OnCreate(parent, name_prefix)
	Dialog.OnCreate(self, parent, name_prefix)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.Item = CEGUI.toItemCell(winMgr:getWindow(name_prefix.."petskillbookcell/item"))
	self.Name = winMgr:getWindow(name_prefix.."petskillbookcell/name")
	self.Frame = winMgr:getWindow(name_prefix.."petskillbookcell/back")
	local childcount = self.Frame:getChildCount()
	for i = 0, childcount - 1 do
		local child = self.Frame:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
	self.Item:setMousePassThroughEnabled(false)
	require "utils.mhsdutils".SetBagWindowShowtips(self.Item)
	self.Frame:setMousePassThroughEnabled(false)
end

function PetSkillBookCell:GetLayoutFileName()
	return "petskillbookcell.layout"
end
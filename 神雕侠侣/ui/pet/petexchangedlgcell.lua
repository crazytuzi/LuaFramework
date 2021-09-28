local Dialog = require "ui.dialog"

PetExchangeDlgCell = {}
setmetatable(PetExchangeDlgCell, Dialog)
PetExchangeDlgCell.__index = PetExchangeDlgCell

------------------- public: -----------------------------------
function PetExchangeDlgCell.CreateNewDlg(pParentDlg, id)
	print("enter PetExchangeDlgCell.CreateNewDlg")
	local newDlg = PetExchangeDlgCell:new()
	newDlg:OnCreate(pParentDlg, id)
    return newDlg
end

function PetExchangeDlgCell.GetLayoutFileName()
    return "petexchangecell.layout"
end

function PetExchangeDlgCell:OnCreate(pParentDlg, id)
	print("enter PetExchangeDlgCell oncreate" .. tostring(id))
    Dialog.OnCreate(self, pParentDlg, id)
	self.m_pWnd = self:GetWindow()
	self.m_id = id

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pIcon = winMgr:getWindow(tostring(id) .. "petexchangecell/image")
	self.m_pName = winMgr:getWindow(tostring(id) .. "petexchangecell/name")
	self.m_pType = winMgr:getWindow(tostring(id) .. "petexchangecell/type")
	self.m_pLight = winMgr:getWindow(tostring(id) .. "petexchangecell/light")

    -- subscribe event
	self.m_pWnd:subscribeEvent("MouseClick", PetExchangeDlgCell.HandleOKBtnClicked, self)

	print("exit PetExchangeDlgCell OnCreate")
end

------------------- public: -----------------------------------

function PetExchangeDlgCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PetExchangeDlgCell)
    return self
end

--icon     头像
--name     名字
--petType  类型
function PetExchangeDlgCell:SetInfo(icon, name, petType)
	self.m_pIcon:setProperty("Image",icon)
	self.m_pName:setText(name)
	self.m_pType:setText(petType)
	self:SetLight(false)
end

function PetExchangeDlgCell:HandleOKBtnClicked(arg)
	LogInfo("PetExchangeDlgCell:HandleOKBtnClicked " .. self.m_id)
	local PetExchangeDlg = require "ui.pet.petexchangedlg"
	if PetExchangeDlg.getInstanceNotCreate() then
		PetExchangeDlg.getInstanceNotCreate():SetInfo(self.m_id)
	end
end

function PetExchangeDlgCell:SetLight(arg)
	self.m_pLight:setVisible(arg)
end

return PetExchangeDlgCell

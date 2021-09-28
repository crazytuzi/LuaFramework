local ShijuezhenCell = {}

setmetatable(ShijuezhenCell, Dialog)
ShijuezhenCell.__index = ShijuezhenCell

function ShijuezhenCell.CreateNewDlg(pParentDlg, id)
	LogInfo("enter ShijuezhenCell.CreateNewDlg")
	local newDlg = ShijuezhenCell:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

function ShijuezhenCell.GetLayoutFileName()
    return "shijuezhencell.layout"
end

function ShijuezhenCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ShijuezhenCell)

    return self
end

function ShijuezhenCell:OnCreate(pParentDlg, id)
	LogInfo("enter ShijuezhenCell oncreate")
    Dialog.OnCreate(self, pParentDlg, id)

    id = tostring(id)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_nameText = winMgr:getWindow(id .. "shijuezhencell/back/name/txt")
	self.m_headImage = winMgr:getWindow(id .. "shijuezhencell/back/head")
	self.m_descText = winMgr:getWindow(id .. "shijuezhencell/back/touming/txt")
	self.m_numText = winMgr:getWindow(id .. "shijuezhencell/back/numback/num")
	self.m_pozhen = winMgr:getWindow(id .. "shijuezhencell/back/pozhen")
	self.m_arrow = winMgr:getWindow(id .. "shijuezhencell/zhishi")
	
	
	self.pWnd = self:GetWindow()
	self.m_width = self:GetWindow():getPixelSize().width

	LogInfo("exit ShijuezhenCell OnCreate")
end

return ShijuezhenCell

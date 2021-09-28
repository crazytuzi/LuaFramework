local QiandaosongliCell = {}

setmetatable(QiandaosongliCell, Dialog)
QiandaosongliCell.__index = QiandaosongliCell

function QiandaosongliCell.CreateNewDlg(pParentDlg, id)
	LogInfo("enter QiandaosongliCell.CreateNewDlg")
	local newDlg = QiandaosongliCell:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

function QiandaosongliCell.GetLayoutFileName()
    return "qiandaosonglicell.layout"
end

function QiandaosongliCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, QiandaosongliCell)

    return self
end

function QiandaosongliCell:OnCreate(pParentDlg, id)
	LogInfo("enter QiandaosongliCell oncreate")
    Dialog.OnCreate(self, pParentDlg, id)

    id = tostring(id)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_item = CEGUI.toItemCell(winMgr:getWindow(id .. "qiandaosonglicell/back/item"))
	self.m_check = winMgr:getWindow(id .. "qiandaosonglicell/up")
	self.m_check:setAlwaysOnTop(true)
	self.m_double = winMgr:getWindow(id .. "qiandaosonglicell/back/img")
	self.m_double:setAlwaysOnTop(true)
	self.m_effect = winMgr:getWindow(id .. "qiandaosonglicell/back")
	winMgr:getWindow(id .. "qiandaosonglicell/back/effect"):setVisible(false)
	
	self.pWnd = self:GetWindow()
	self.m_width = self:GetWindow():getPixelSize().width
	self.m_height = self:GetWindow():getPixelSize().height
	LogInfo("exit QiandaosongliCell OnCreate")
end

return QiandaosongliCell

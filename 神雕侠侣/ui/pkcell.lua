PKCell = {}

setmetatable(PKCell, Dialog)
PKCell.__index = PKCell
local id = 0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function PKCell.CreateNewDlg(pParentDlg, id)
	LogInfo("enter PKCell.CreateNewDlg")
	local newDlg = PKCell:new()
	newDlg:OnCreate(pParentDlg, id)

    return newDlg
end

----/////////////////////////////////////////------

function PKCell.GetLayoutFileName()
    return "pkcelldialog.layout"
end

function PKCell:OnCreate(pParentDlg, id)
	LogInfo("enter PKCell oncreate")
    Dialog.OnCreate(self, pParentDlg, id)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.pRank = winMgr:getWindow(tostring(id) .. "pkcelldialog/role/num")
	self.pHead = winMgr:getWindow(tostring(id) .. "pkcelldialog/role/icon")
	self.pName = winMgr:getWindow(tostring(id) .. "pkcelldialog/name")
	self.pLevel = winMgr:getWindow(tostring(id) .. "pkcelldialog/level")
	self.pSchool = winMgr:getWindow(tostring(id) .. "pkcelldialog/level1")
	self.pButton = CEGUI.Window.toPushButton(winMgr:getWindow(tostring(id) .. "pkcelldialog/btn"))
	self.pWnd = self:GetWindow()

	LogInfo("exit PKCell OnCreate")
end

------------------- public: -----------------------------------

function PKCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PKCell)

    return self
end

return PKCell

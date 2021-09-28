require "utils.mhsdutils"
RingCell = {}


setmetatable(RingCell, Dialog)
RingCell.__index = RingCell
local prefix = 0
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function RingCell.CreateNewDlg(pParentDlg)
	LogInfo("enter RingCell.CreateNewDlg")
	local newDlg = RingCell:new()
	newDlg:OnCreate(pParentDlg)

    return newDlg
end


----/////////////////////////////////////////------

function RingCell.GetLayoutFileName()
    return "ringcell.layout"
end

function RingCell:OnCreate(pParentDlg)
	LogInfo("enter RingCell oncreate")
	prefix = prefix + 1
    Dialog.OnCreate(self, pParentDlg, prefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pCell = {}
	self.m_pLight = {}
	for i = 0, 2 do 
		if i == 0 then
			self.m_pCell[i] = CEGUI.Window.toItemCell(winMgr:getWindow(tostring(prefix) .. "ringcell/cell0"))
			self.m_pLight[i] = winMgr:getWindow(tostring(prefix) .. "ringcell/light0")
		else
			self.m_pCell[i] = CEGUI.Window.toItemCell(winMgr:getWindow(tostring(prefix) .. "ringcell/cell" .. tostring(i)))
			self.m_pLight[i] = winMgr:getWindow(tostring(prefix) .. "ringcell/light" .. tostring(i))
		end
	end

	for i = 0, 2 do
		self.m_pLight[i]:setVisible(false)
		self.m_pCell[i]:setVisible(false)
	end
	LogInfo("exit RingCell OnCreate")
end

------------------- public: -----------------------------------

function RingCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, RingCell)
    return self
end

return RingCell

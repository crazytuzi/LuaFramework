require "ui.dialog"

SelectServersAreaCell = {}
setmetatable(SelectServersAreaCell, Dialog)
SelectServersAreaCell.__index = SelectServersAreaCell

SUniqueID = 0

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function SelectServersAreaCell.CreateNewDlg(pParentDlg)
	print("enter SelectServersAreaCell.CreateNewDlg")
	local newDlg = SelectServersAreaCell:new()
	newDlg:OnCreate(pParentDlg)

    return newDlg
end

----/////////////////////////////////////////------

function SelectServersAreaCell.GetLayoutFileName()
    return "selectserversareacell.layout"
end

function SelectServersAreaCell:OnCreate(pParentDlg)
	print("enter SelectServersAreaCell oncreate")

	-- unique name prefix, SUniqueID is static 
	SUniqueID = SUniqueID + 1
	local namePrefix = tostring(SUniqueID)

    Dialog.OnCreate(self, pParentDlg, namePrefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_CellBack = winMgr:getWindow(namePrefix .. "SelectServersareacell")
    self.m_CellGBtn = 
		CEGUI.Window.toGroupButton(winMgr:getWindow(namePrefix .. "SelectServersareacell/btn") )

    -- subscribe event
	self.m_CellGBtn:subscribeEvent("MouseButtonDown", 
			SelectServersDialog.HandleSelectAreaStateChanged, SelectServersDialog.getInstance()) 

	print("exit SelectServersAreaCell OnCreate")
end

------------------- public: -----------------------------------

function SelectServersAreaCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SelectServersAreaCell)

    return self
end
----/////////////////////////////////////////------

function SelectServersAreaCell:SetCellVisible(bVisible)
	self.m_CellBack:setVisible(bVisible)
end

----/////////////////////////////////////////------
--
function SelectServersAreaCell:SetSelectedState(selectedid)
	LogInfo("select area setselectedstate id " .. selectedid)
	local gbtnselstate =  (self.m_CellGBtn:getID() == selectedid)
	self.m_CellGBtn:setSelected(gbtnselstate)
end

----/////////////////////////////////////////------

function SelectServersAreaCell:SetCellInfo(areakey, areaname, selectedname)
	print("SelectServersAreaCell:SetCellInfo key: " .. areakey .. " name: " .. areaname)

	self.m_CellGBtn:setText(areaname)
	self.m_CellBack:setID(areakey)
	self.m_CellGBtn:setID(areakey)
	self:SetCellVisible(true)
end

function SelectServersAreaCell:GetBtn(bVisible)
	return self.m_CellGBtn
end
------------------- end -----------------------------------

return SelectServersAreaCell

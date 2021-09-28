require "ui.dialog"

SelectServersDialogCell = {}
setmetatable(SelectServersDialogCell, Dialog)
SelectServersDialogCell.__index = SelectServersDialogCell

SUniqueID = 0

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
function SelectServersDialogCell.CreateNewDlg(pParentDlg)
	print("enter SelectServersDialogCell.CreateNewDlg")
	local newDlg = SelectServersDialogCell:new()
	newDlg:OnCreate(pParentDlg)

    return newDlg
end

----/////////////////////////////////////////------

function SelectServersDialogCell.GetLayoutFileName()
    return "selectserversbotcell.layout"
end

function SelectServersDialogCell:OnCreate(pParentDlg)
	print("enter SelectServersDialogCell oncreate")

	-- unique name prefix, SUniqueID is static 
	SUniqueID = SUniqueID + 1
	local namePrefix = tostring(SUniqueID)

    Dialog.OnCreate(self, pParentDlg, namePrefix)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_CellGBtn1 = 
		CEGUI.Window.toGroupButton(winMgr:getWindow(namePrefix ..  "SelectServers/server1") )
    self.m_CellGBtn2 = 
		CEGUI.Window.toGroupButton(winMgr:getWindow(namePrefix ..  "SelectServers/server2") )

    -- subscribe event
	self.m_CellGBtn1:subscribeEvent("MouseButtonUp", 
			SelectServersDialog.HandleSelectServerStateChanged, SelectServersDialog.getInstance()) 
    self.m_CellGBtn2:subscribeEvent("MouseButtonUp", 
			SelectServersDialog.HandleSelectServerStateChanged, SelectServersDialog.getInstance()) 

    --init settings

	print("exit SelectServersDialogcell OnCreate")
end

------------------- public: -----------------------------------

function SelectServersDialogCell:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SelectServersDialogCell)

    return self
end
----/////////////////////////////////////////------

function SelectServersDialogCell:SetCellVisible(index, bVisible)
	if index == 1 then
		self.m_CellGBtn1:setVisible(bVisible)
	end
	if index == 2 then
		self.m_CellGBtn2:setVisible(bVisible)
	end
end

----/////////////////////////////////////////------
--
function SelectServersDialogCell:SetSelectedState(selectedid)
	print("select servers setselectedstate id " .. selectedid)
	local gbtn1selstate =  (self.m_CellGBtn1:getID() == selectedid)
	self.m_CellGBtn1:setSelected(gbtn1selstate)

	local gbtn2selstate =  (self.m_CellGBtn2:getID() == selectedid)
	self.m_CellGBtn2:setSelected(gbtn2selstate)
end

----/////////////////////////////////////////------

function SelectServersDialogCell:SetCellInfo(server1key, server1info, server2key, server2info, selectedname)
	if server1info then
		self.m_CellGBtn1:setText(server1info["servername"])
		self.m_CellGBtn1:setID(server1key)
		self:SetCellVisible(1, true)
		if server1info["servername"] == selectedname then
			self.m_CellGBtn1:setSelected(true)
		end
	else
		self.m_CellGBtn1:setText("")
		self:SetCellVisible(1, false);
	end

	if server2info then
		self.m_CellGBtn2:setText(server2info["servername"])
		self.m_CellGBtn2:setID(server2key)
		self:SetCellVisible(2, true)
		if server2info["servername"] == selectedname then
			self.m_CellGBtn2:setSelected(true)
		end
	else
		self.m_CellGBtn2:setText("")
		self:SetCellVisible(2, false);
	end
end
------------------- end -----------------------------------

return SelectServersDialogCell

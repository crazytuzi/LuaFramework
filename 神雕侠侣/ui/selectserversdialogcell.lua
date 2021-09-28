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
	self.m_CellBack = winMgr:getWindow(namePrefix .. "SelectServers/back/Bot/back1")
	self.m_Status = winMgr:getWindow(namePrefix .. "selectserversbotcell/state")
    self.m_CellGBtn = 
		CEGUI.Window.toGroupButton(winMgr:getWindow(namePrefix ..  "SelectServers/server1") )
	self.m_Name = winMgr:getWindow(namePrefix .. "SelectServers/servername")
	self.m_Desc = winMgr:getWindow(namePrefix .. "SelectServers/serverinfo")
	self.m_Level = winMgr:getWindow(namePrefix .. "SelectServers/server1/rolename")
	self.m_Icon  = winMgr:getWindow(namePrefix .. "SelectServers/back/Bot/back1/role")

    -- subscribe event
	self.m_CellGBtn:subscribeEvent("MouseButtonDown", 
			SelectServersDialog.HandleSelectServerStateChanged, SelectServersDialog.getInstance()) 

    --init settings
    self.m_Status:setProperty("Image", "set:LoginBack1 image:weihu")

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

function SelectServersDialogCell:SetCellVisible(bVisible)
	self.m_CellBack:setVisible(bVisible)
end

----/////////////////////////////////////////------
--
function SelectServersDialogCell:SetSelectedState(selectedid)
	LogInfo("select servers setselectedstate id " .. selectedid)
	local gbtnselstate =  (self.m_CellBack:getID() == selectedid)
	self.m_CellGBtn:setSelected(gbtnselstate)
end

----/////////////////////////////////////////------

function SelectServersDialogCell:SetCellInfo(serverkey, serverinfo, selectedname, serverroleinfo)
	if serverinfo then
		self.m_Name:setText(serverinfo["servername"])
		if serverinfo["opentime"] == "0" then
			self.m_Desc:setText(serverinfo["desc"])
		else
			local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
			local runyear, runmonth, runday, runhour, runminute, runseconds = serverinfo["opentime"]:match(pattern)
			local convertedTime = os.time({year=runyear, month=runmonth, day=runday, hour=runhour, min=runminute, sec=runseconds})
			if convertedTime <= os.time() then
				self.m_Desc:setText(serverinfo["descopened"])
			else
				self.m_Desc:setText(serverinfo["desc"])
			end
		end
		self.status = serverinfo["status"]
    	self.m_Status:setProperty("Image", "set:LoginBack1 image:weihu")
		self.m_CellBack:setID(serverkey)
		self.m_CellGBtn:setID(serverkey)
		self:SetCellVisible(true)
		if serverinfo["servername"] == selectedname then
			self.m_CellGBtn:setSelected(true)
		end

		if serverroleinfo then
			self.m_Icon:setProperty("Image", GetIconManager():GetImagePathByID(serverroleinfo["icon"]):c_str())
			self.m_Level:setText("lv." .. serverroleinfo["lvl"])
		end
	end
end

function SelectServersDialogCell.GetIconByStatus(status)
	print("status is " .. status)
	--已开放新服
	if status == "1" then
		return "set:LoginBack1 image:new"
	end
	--火爆
	if status == "2" then
		return "set:LoginBack1 image:hot"
	end
	--流畅
	if status == "3" then
		return "set:LoginBack1 image:good"
	end
	--未开新服
	if status == "4" then
		return "set:LoginBack1 image:new"
	end

	return "set:LoginBack1 image:good"
end
------------------- end -----------------------------------

return SelectServersDialogCell

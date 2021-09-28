require "ui.dialog"

local PVPServiceSeasonEndDlg = {}
setmetatable(PVPServiceSeasonEndDlg, Dialog)
PVPServiceSeasonEndDlg.__index = PVPServiceSeasonEndDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function PVPServiceSeasonEndDlg.getInstance()
	print("enter get pvpserviceseasonenddlg dialog instance")
    if not _instance then
        _instance = PVPServiceSeasonEndDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function PVPServiceSeasonEndDlg.getInstanceAndShow()
	print("enter pvpserviceseasonenddlg dialog instance show")
    if not _instance then
        _instance = PVPServiceSeasonEndDlg:new()
        _instance:OnCreate()
	else
		print("set pvpserviceseasonenddlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PVPServiceSeasonEndDlg.getInstanceNotCreate()
    return _instance
end

function PVPServiceSeasonEndDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function PVPServiceSeasonEndDlg.ToggleOpenClose()
	if not _instance then 
		_instance = PVPServiceSeasonEndDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

----/////////////////////////////////////////------

function PVPServiceSeasonEndDlg.GetLayoutFileName()
    return "pvpserviceseasonend.layout"
end

function PVPServiceSeasonEndDlg:OnCreate()
	print("pvpserviceseasonenddlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pShengLi = CEGUI.Window.toEditbox(winMgr:getWindow("pvpserviceseasonendcell/num0"))
	self.m_pShiBai  = CEGUI.Window.toEditbox(winMgr:getWindow("pvpserviceseasonendcell/num1"))
	self.m_pNumPeople = CEGUI.Window.toEditbox(winMgr:getWindow("pvpserviceseasonendcell/num2"))

	-- init windows
	self.m_pShengLi:setText(tostring(0))
	self.m_pShiBai:setText(tostring(0))
	self.m_pNumPeople:setText(tostring(0))

	print("pvpserviceseasonenddlg dialog oncreate end")
end

------------------- private: -----------------------------------


function PVPServiceSeasonEndDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PVPServiceSeasonEndDlg)
    return self
end

function PVPServiceSeasonEndDlg:Refresh(shengli, shibai)
	self.m_pShengLi:setText(tostring(shengli))
	self.m_pShiBai:setText(tostring(shibai))
end

function PVPServiceSeasonEndDlg:RefreshRemainNumber( num )
	self.m_pNumPeople:setText(tostring(num))
end

return PVPServiceSeasonEndDlg

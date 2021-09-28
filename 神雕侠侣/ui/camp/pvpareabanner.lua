require "ui.dialog"
require "utils.mhsdutils"


PVPAreaBanner = {}
setmetatable(PVPAreaBanner, Dialog)
PVPAreaBanner.__index = PVPAreaBanner

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function PVPAreaBanner.getInstance()
	LogInfo("enter get pvpareabanner instance")
    if not _instance then
        _instance = PVPAreaBanner:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function PVPAreaBanner.getInstanceAndShow()
	LogInfo("enter pvpareabanner instance show")
    if not _instance then
        _instance = PVPAreaBanner:new()
        _instance:OnCreate()
	else
		LogInfo("set pvpareabanner visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PVPAreaBanner.getInstanceNotCreate()
    return _instance
end

function PVPAreaBanner.DestroyDialog()
	if _instance then 
		LogInfo("destroy pvpareabanner")
		_instance:OnClose()
		_instance = nil
	end
end

function PVPAreaBanner.ToggleOpenClose()
	if not _instance then 
		_instance = PVPAreaBanner:new() 
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

function PVPAreaBanner.GetLayoutFileName()
    return "pvparea.layout"
end

function PVPAreaBanner:OnCreate()
	LogInfo("pvpareabanner oncreate begin")
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pImage = winMgr:getWindow("pvparea/image")

	self.m_pImage:subscribeEvent("MouseClick", PVPAreaBanner.HandleBannerClicked)

	GetGameUIManager():AddMessageTipById(145373)
	LogInfo("pvpareabanner oncreate end")
end

------------------- private: -----------------------------------


function PVPAreaBanner:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PVPAreaBanner)
    return self
end

function PVPAreaBanner:HandleBannerClicked(args)
	LogInfo("PVPAreaBanner handle banner clicked")
    GetGameUIManager():AddMessageTipById(145113);
end

return PVPAreaBanner

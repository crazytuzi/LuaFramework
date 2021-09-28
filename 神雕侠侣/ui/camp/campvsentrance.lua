require "ui.dialog"
require "utils.mhsdutils"
require "protocoldef.knight.gsp.battle.ccampbattlestart"


CampVSEntrance = {}
setmetatable(CampVSEntrance, Dialog)
CampVSEntrance.__index = CampVSEntrance

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CampVSEntrance.getInstance()
	LogInfo("enter get CampVSEntrance instance")
    if not _instance then
        _instance = CampVSEntrance:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CampVSEntrance.getInstanceAndShow()
	LogInfo("enter CampVSEntrance instance show")
    if not _instance then
        _instance = CampVSEntrance:new()
        _instance:OnCreate()
	else
		LogInfo("set CampVSEntrance visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CampVSEntrance.getInstanceNotCreate()
    return _instance
end

function CampVSEntrance.DestroyDialog()
	if _instance then 
		LogInfo("destroy CampVSEntrance")
		_instance:OnClose()
		_instance = nil
	end
end

function CampVSEntrance.ToggleOpenClose()
	if not _instance then 
		_instance = CampVSEntrance:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CampVSEntrance.HandleStart(args)
	local start = CCampBattleStart:Create()
	LuaProtocolManager.getInstance():send(start)
  	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end
----/////////////////////////////////////////------

function CampVSEntrance.GetLayoutFileName()
    return "campvsentrance.layout"
end

function CampVSEntrance:OnCreate()
	LogInfo("CampVSEntrance oncreate begin")
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow("campvsentrance/btn"))

	self.m_pBtn:subscribeEvent("Clicked", CampVSEntrance.HandleButtonClicked)

	LogInfo("CampVSEntrance oncreate end")
end

------------------- private: -----------------------------------


function CampVSEntrance:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CampVSEntrance)
    return self
end

function CampVSEntrance:HandleButtonClicked(args)
	LogInfo("CampVSEntrance handle banner clicked")
	local start = CCampBattleStart:Create()
	LuaProtocolManager.getInstance():send(start)
end

return CampVSEntrance

require "ui.activity.activitydlg"
require "ui.activity.activitycell"
require "ui.activity.activityentrance"
CrossServerManager = {}
CrossServerManager.__index = CrossServerManager

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CrossServerManager.getInstance()
	LogInfo("enter get CrossServerManager instance")
    if not _instance then
        _instance = CrossServerManager:new()
    end
    
    return _instance
end

function CrossServerManager.getInstanceNotCreate()
    return _instance
end

function CrossServerManager.Destroy()
	if _instance then 
		LogInfo("destroy CrossServerManager")
		_instance = nil
	end
end

------------------- private: -----------------------------------

function CrossServerManager:new()
    	local self = {}
	setmetatable(self, CrossServerManager)
	self:Init()

    	return self
end

function CrossServerManager:Init(ticket, crossip, crossport, account)
	LogInfo("CrossServerManager Init")
	self.m_ticket = ticket
	self.m_crossip = crossip
	self.m_crossport = crossport
	self.m_account = account
end


return CrossServerManager

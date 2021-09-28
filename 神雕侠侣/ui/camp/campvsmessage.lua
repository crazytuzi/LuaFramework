require "utils.tableutil"
CampVSMessage = {}
CampVSMessage.__index = CampVSMessage

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local MAX_NUM = 30
local SHOW_ALL = 0
local SHOW_MYSELF = 1
function CampVSMessage.getInstance()
	LogInfo("enter get CampVSMessage instance")
    if not _instance then
        _instance = CampVSMessage:new()
    end
    
    return _instance
end

function CampVSMessage.getInstanceNotCreate()
    return _instance
end

function CampVSMessage.Destroy()
	if _instance then 
		LogInfo("destroy CampVSMessage")
		_instance = nil
	end
end

------------------- private: -----------------------------------

function CampVSMessage:new()
    local self = {}
	setmetatable(self, CampVSMessage)
	self.m_lMessageList = {}
    return self
end

function CampVSMessage:AddMessage(ismine, flag, rolename1, camp1, rolename2, camp2, comwin)
	LogInfo("CampVSMessage AddMessage")
	local message = {}
	message.ismine = ismine
	message.flag = flag
	message.rolename1 = rolename1
	message.camp1 = camp1
	message.rolename2 = rolename2
	message.camp2 = camp2
	message.win = comwin
	if CampVS.getInstanceNotCreate() then
		CampVS.getInstanceNotCreate():AddMessage(message)
	end
	table.insert(self.m_lMessageList, message)
end

function CampVSMessage:refresh(flag)
	LogInfo("CampVSMessage refresh")
	if flag == SHOW_ALL then
		local length = TableUtil.tablelength(self.m_lMessageList)
		local needToRemove = length - MAX_NUM
		if needToRemove > 0 then
			for i = 1, needToRemove do
				table.remove(self.m_lMessageList, 1)
			end
		end
	end
	for k,v in pairs(self.m_lMessageList) do 
		if CampVS.getInstanceNotCreate() then
			CampVS.getInstanceNotCreate():AddMessage(v)
		end
	end
end


return CampVSMessage


BeanConfigManager = {}
BeanConfigManager.__index = BeanConfigManager

------------------- public: -----------------------------------

---- singleton /////////////////////////////////////////------
local _instance;
function BeanConfigManager.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = BeanConfigManager:new()
    end

    return _instance
end

function BeanConfigManager.removeInstance()
	_instance = nil
end


---- member function /////////////////////////////////////////------
--
function BeanConfigManager:Initialize(xmlpath, binpath)
	self.m_xmlPath = xmlpath
	self.m_binPath = binpath
end

------------------- private: -----------------------------------

function BeanConfigManager:new()
    local self = {}
    setmetatable(self, BeanConfigManager)

	self.m_xmlPath = ""
	self.m_tableInstance = {}
    return self
end

function BeanConfigManager:MakeTableValue(tablename)
	local xmlfilename  = self.m_xmlPath .. tablename .. ".xml"
	local binfilename  = self.m_binPath .. tablename .. ".bin"
	local mod = require("luabean." .. tablename)
	self.m_tableInstance[tablename] = mod:new()
	if not self.m_tableInstance[tablename]:LoadBeanFromBinFile(binfilename) then
		self.m_tableInstance[tablename]:LoadBeanFromXmlFile(xmlfilename)
	end
end

function BeanConfigManager:GetTableByName(tablename)
	if not self.m_tableInstance[tablename] then
		self:MakeTableValue(tablename)
	end
	return self.m_tableInstance[tablename]
end

return BeanConfigManager

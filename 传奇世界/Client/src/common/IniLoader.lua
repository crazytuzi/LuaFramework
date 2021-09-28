--Author:		bishaoqing
--DateTime:		2016-05-05 17:08:51
--Region:		ini配置文件
local IniLoader = class("IniLoader")

function IniLoader:ctor( sIniFileName )
	-- body
	if not IsWin32() then
		return
	end
	self.stIni_ = CGameFunc:GetIniCach()
end

--设置ini文件
function IniLoader:SetIni( sIniFileName )
	-- body
	
end

--获取ini列表
function IniLoader:GetIni( ... )
	-- body
	return self.stIni_
end

--获取指定app，key的value值(默认是都是string)
function IniLoader:GetPrivateEx(sAppName, sKeyName)
	-- body
	if not self.stIni_ then
		return
	end
	if not sAppName or not sKeyName then
		return
	end
	local t = self.stIni_[tostring(sAppName)]
	if t then
		return t[tostring(sKeyName)]
	end
end

function IniLoader:GetPrivateString(sAppName, sKeyName)
	-- body
	local sRet = self:GetPrivateEx(sAppName, sKeyName)
	if sRet then
		return tostring(sRet)
	end
end

function IniLoader:GetPrivateInt(sAppName, sKeyName)
	-- body
	local sRet = self:GetPrivateEx(sAppName, sKeyName)
	if sRet then
		return tonumber(sRet)
	end
end

function IniLoader:GetPrivateBool(sAppName, sKeyName)
	-- body
	local sRet = self:GetPrivateEx(sAppName, sKeyName)
	if sRet then
		return sRet == "true" or sRet == "True" or sRet == "TRUE" or sRet ~= "0"
	end
end

return IniLoader
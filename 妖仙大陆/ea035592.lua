



local _M = {}
_M.__index = _M

local function GetStepKey(parent)
	local r = parent:GetRootEvent()
	local key = 'drama_'..r:GetName()
	return key	
end




function _M.SendStep(parent,step)
	local key = GetStepKey(parent)
	step = step or ''
	local value = tostring(step)
	GlobalHooks.SetClientConfig(key,value)
end

function _M.SendSpecificStep(parent,script_name,step)
	local key = 'drama_'..script_name
	step = step or ''
	local value = tostring(step)
	GlobalHooks.SetClientConfig(key,value)
end


function _M.GetStep(parent)
	local key = GetStepKey(parent)
	return DataMgr.Instance.UserData:GetClientConfig(key)
end

function _M.GetScriptStep(parent,script_name)
	local key = 'drama_'..script_name
	return DataMgr.Instance.UserData:GetClientConfig(key)
end

function _M.SetClientConfig(parent,key,value)
	GlobalHooks.SetClientConfig(key,value or '')
end

function _M.GetClientConfig(parent,key)
	return DataMgr.Instance.UserData:GetClientConfig(key)
end

function _M.Clear(parent)
end

return _M

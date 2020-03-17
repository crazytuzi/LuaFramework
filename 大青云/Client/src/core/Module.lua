--[[
Module基类
lizhuangzhuang
2014年7月20日18:09:08
]]
_G.classlist['Module'] = 'Module'
_G.Module = {}; --should be Model, now just use module
_G.Module.objName = 'Module'
function Module:new()
	local obj = {};
	for i,v in pairs(Module) do
		if type(v)=="function" then
			obj[i] = v;
		end
	end
	return obj;
end

function Module:sendNotification(name, body)
	Notifier:sendNotification(name, body);
end
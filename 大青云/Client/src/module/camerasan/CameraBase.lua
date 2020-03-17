--[[
摄像机动作
liyuan
2014年10月15日21:33:06
]]

_G.C_CameraBase = { }
function C_CameraBase:new()
	local obj = {}
	setmetatable(obj, {__index = C_CameraBase})
	return obj
end

function C_CameraBase:getCamera() 
end

function C_CameraBase:Update()
end

function C_CameraBase:StopAllAction()
end
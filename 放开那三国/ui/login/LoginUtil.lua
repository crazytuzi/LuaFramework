-- Filename：	LoginUtil.lua
-- Author：		Cheng Liang
-- Date：		2015-02-10
-- Purpose：		登陆时的一些工具方法

module("LoginUtil", package.seeall)

local kDeviceBindIdKey = "sanguo_bind_key"
local VISTOR_BIND_KEY = "vistor_bind_key"

function getDeviceBindId()

	local deviceToken = NSBundleInfo:getValueFromKeyChain(kDeviceBindIdKey)
	if(deviceToken == nil or deviceToken == "")then
		deviceToken = "0"
	end
	

	return deviceToken
end

function saveDeviceBindId( p_bind )
	if(p_bind)then
		NSBundleInfo:saveToKeyChain(kDeviceBindIdKey, p_bind)
	end
end

--------------------- 游客登录 --------------------------
function getVistorBindId()

	local vistorToken = NSBundleInfo:getValueFromKeyChain(VISTOR_BIND_KEY)
	if(vistorToken == nil or vistorToken == "")then
		vistorToken = "0"
	end
	return vistorToken
end

function saveVistorBindId( vistorToken )
	if(vistorToken)then
		NSBundleInfo:saveToKeyChain(VISTOR_BIND_KEY, vistorToken)
	end
end

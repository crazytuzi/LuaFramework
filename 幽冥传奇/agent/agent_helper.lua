
local agent_helper = {}

-- 登录
function agent_helper:Login(callback, arg)
	PlatformBinder:JsonCall("call_agent_login", arg or "", "", callback)
end

-- 登出
function agent_helper:Logout(info_str)
	PlatformBinder:JsonCall("call_agent_logout", info_str or "")
end

-- 支付
function agent_helper:Pay(info_str, callback)
	PlatformBinder:JsonCall("call_agent_pay", info_str, "", callback)
end

-- 获取SessionId
function agent_helper:GetSessionId()
	return PlatformBinder:JsonCall("call_agent_get_sid")
end

-- 设置登出回调
function agent_helper:SetLogoutCallback(callback)
	PlatformBinder:JsonBind("event_agent_logout", callback)
end

-- 悬浮按钮
function agent_helper:ShowFloatButton(x, y, visable)
	local param = cjson.encode({["x"] = x, ["y"] = y, ["visable"] = visable})
	PlatformBinder:JsonCall("call_agent_show_float_button", param)
end

-- 上报数据
function agent_helper:SubmitExtendData(data)
	PlatformBinder:JsonCall("call_agent_submit_extend_data", data)
end

-- 进入用户中心
function agent_helper:EnterUserCenter(callback)
	PlatformBinder:JsonCall("call_agent_enter_user_center", param, "", callback)
end

-- 退出
function agent_helper:Exit(callback)
	PlatformBinder:JsonCall("call_agent_exit", "", "", callback)
end

function agent_helper:SetUIEventCallback(callback)
	PlatformBinder:JsonBind("event_agent_sdk_ui", callback)
end

function agent_helper:GoInServer(data)
	PlatformBinder:JsonCall("call_agent_goInServer", data)
end

function agent_helper:Recharge(recharge_info)
	return PlatformBinder:JsonCall("call_agent_recharge", recharge_info, "")
end

function agent_helper:SetRechargeCallback(callback)
	PlatformBinder:JsonBind("event_agent_recharge", callback)
end

function agent_helper:GetPayInfo()
	return PlatformBinder:JsonCall("call_agent_get_pay_info", "", "")
end

return agent_helper

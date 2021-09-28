local json = require "cjson"

LogHttp = {}
local logInstance = LogHelp.instance
LogHttp.info = logInstance:GetDeviceInfo()
LogHttp.deviceInfo = nil
LogHttp.logHttpUrl = GameConfig.instance.host
function LogHttp.GetDeviceInfo()
	if(LogHttp.deviceInfo == nil and LogHttp.info ~= "") then
		LogHttp.deviceInfo = json.decode(LogHttp.info)
	end
	return LogHttp.deviceInfo
end

function LogHttp.SendLog(url, data)
	coroutine.start(LogHttp._SendLog, url, data)
end
function LogHttp._SendLog(url, data)
	if(LogHttp.deviceInfo == nil and LogHttp.info ~= "") then
		LogHttp.deviceInfo = json.decode(LogHttp.info)
	end
	
	--    if (Application.isMobilePlatform and not Application.isEditor) then
	local form = WWWForm.New()
	form:AddField("sign", logInstance.logSign);
	form:AddField("platform_tag", GameConfig.instance.strPlatformId);
	form:AddField("channel_id", logInstance.channel_id);
	form:AddField("app_ver", logInstance.app_ver);
	form:AddField("network", logInstance:GetNetworkState())
	if(LogHttp.deviceInfo) then
		for k, v in pairs(LogHttp.deviceInfo) do
			if(k == "group_id") then
				form:AddField(tostring(k), tonumber(v))
			else
				form:AddField(tostring(k), v)
			end
		end
	end
	
	if(data) then
		for k, v in pairs(data) do
			form:AddField(tostring(k), v)
		end
	end
	
	local path = LogHttp.logHttpUrl .. url
	local www = WWW(path, form);
	coroutine.www(www)
	--    end
end

function LogHttp.SendOperaLog(str)
	SocketClientLua.Get_ins():SendMessage(CmdType.Opera_Log, {op = str});
end 
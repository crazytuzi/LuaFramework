local CUploadDataCtrl = class("CUploadDataCtrl")

function CUploadDataCtrl.ctor(self)

end 


function CUploadDataCtrl.CreateRoleUpload(self, tData)
	print(tData and tData.click)
	local platid = 3
	if Utils.IsAndroid() then
		platid =  1
	elseif Utils.IsIOS() then
		platid = 2
	end

	local v1, v2, v3 = C_api.Utils.GetResVersion()
	local version = string.format("%s.%s.%s",v1, v2, v3)
	local t = {
		logname = "RoleUi",
		content = "json",
		account_id = g_LoginCtrl:GetLoginInfo("account"),
		ip = Utils.GetLocalIP(),
		device_model = Utils.GetDeviceModel(),
		udid = Utils.GetDeviceUID(),
		os = UnityEngine.SystemInfo.operatingSystem,
		version = version,
		app_channel = g_SdkCtrl:GetChannelId(),
		sub_channel = g_SdkCtrl:GetSubChannelId(),
		server = g_LoginCtrl:GetConnectServer().id,
		plat = platid,
	}
	table.update(t, tData)
	local headers = {
		["Content-Type"]= "application/x-www-form-urlencoded",
	}
	local url = string.format("%s/clientdata/", Utils.GetCenterServerUrl())
	g_HttpCtrl:Post(url, nil, headers, cjson.encode(t))
end

return CUploadDataCtrl
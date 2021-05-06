local CIOSCtrl = class("CIOSCtrl")

function CIOSCtrl.ctor(self)

end

function CIOSCtrl.OnLoginProcess(self, tEvent)
	if tEvent.code == 0 then
		local sChannelId = g_SdkCtrl:GetChannelId()
		local keymap = {
			sm = {sid = "sessionId", uid = "uid"},
			game78 = {sid = "sessionId", uid = "uid"},
			kaopu = {sid = "vurl", uid = "openID"},
		}
		local tData = decodejson(tEvent.data)
		local keys = keymap[sChannelId]
		if tData[keys.sid] then
			g_SdkCtrl:Setter("m_SdkSid", tData[keys.sid])
			g_SdkCtrl:Setter("m_SdkUid", tData[keys.uid])
			g_SdkCtrl:RequestDemiToken()
			g_SdkCtrl:Setter("m_IsLogin", true)
		else
			g_SdkCtrl:Setter("m_IsLogin", false)
			g_SdkCtrl:ShowLoginWithMsg("sdk返回数据sid为空")
		end
	else
		g_SdkCtrl:Setter("m_IsLogin", false)
		g_SdkCtrl:ShowLoginWithMsg("sdk登录错误,返回码:"..tostring(tEvent.code))
		g_NotifyCtrl:HideConnect()
	end
end

function CIOSCtrl.GetUploadData(self, iUploadType)
	local dServer = g_LoginCtrl:GetConnectServer()
	local dUpload = {
		type = tostring(iUploadType),
		serviceid = dServer.server_id,
		roleid = tostring(g_AttrCtrl.pid),
		servicename = dServer.name,
		rolename = g_AttrCtrl.name,
		rolelevel = tostring(g_AttrCtrl.grade),
		rolectime = tostring(g_AttrCtrl.kp_sdk_info.create_time),
		rolelevelmtime = tostring(g_AttrCtrl.kp_sdk_info.upgrade_time),
	}
	if dUpload.rolelevelmtime == "0" then
		dUpload.rolelevelmtime = dUpload.rolectime
	end
	return dUpload
end

function CIOSCtrl.GetJsonPayData(self, dPayInfo)
	local dData
	local iChannelId = g_SdkCtrl:GetChannelId()
	local dServer = g_LoginCtrl:GetConnectServer()
	if iChannelId == "sm" or iChannelId == "game78" then
		dData = {
			serverId = g_ServerCtrl:ServerKeyToNumer(dServer.server_id),
			appOrderId = dPayInfo.order_id,
			productPrice = dPayInfo.product_value,
			productId = dPayInfo.product_key,
		}
	else
		dData = {
			productId = dPayInfo.product_key,
			productName = data.paydata.IOSPay[dPayInfo.product_key].name,
			price = dPayInfo.product_value,
			buyNum = dPayInfo.product_amount,
			roleName = g_AttrCtrl.name,
			orderID = dPayInfo.order_id,
			serverName = g_ServerCtrl:GetCurServerName(),
		}
	end
	return cjson.encode(dData)
end

return CIOSCtrl

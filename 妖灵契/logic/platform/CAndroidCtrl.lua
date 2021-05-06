local CAndroidCtrl = class("CAndroidCtrl")

function CAndroidCtrl.ctor(self)

end

function CAndroidCtrl.OnLoginProcess(self, tEvent)
	if tEvent.code == 0 then
		local tData = decodejson(tEvent.data)
		if tData.sessionId then
			g_SdkCtrl:Setter("m_SdkSid", tData.sessionId)
			if g_SdkCtrl:GetChannelId() == "kaopu" then
				local tData = decodejson(tData.uid)
				g_SdkCtrl:Setter("m_SdkUid", tData.openid)
				g_SdkCtrl:Setter("m_SdkToken", tData.token)
			else
				g_SdkCtrl:Setter("m_SdkUid", tData.uid)
			end

			g_SdkCtrl:RequestDemiToken()
			g_SdkCtrl:Setter("m_IsLogin", true)
		else
			-- g_SdkCtrl:RetryLoginDlg("提示", "sessionId为空, 请重试")
			g_SdkCtrl:Setter("m_IsLogin", false)
			g_SdkCtrl:ShowLoginWithMsg("sdk返回数据sid为空")
		end
	else
		-- g_SdkCtrl:RetryLoginDlg("提示", "返回码:"..tostring(tEvent.code).."，请重试")
		g_SdkCtrl:Setter("m_IsLogin", false)
		if tEvent.code == 2 then
			print("sdk登录取消")
		elseif tEvent.code == 3 then
			print("sdk登录失败")
		else
			g_SdkCtrl:ShowLoginWithMsg("sdk登录错误, 返回码:"..tostring(tEvent.code))
		end
		g_NotifyCtrl:HideConnect()
	end
end

function CAndroidCtrl.GetUploadData(self, sUploadType)
	local dServer = g_LoginCtrl:GetConnectServer()
	local dUpload = {
		submittype = 1,
		roleId = tostring(g_AttrCtrl.pid),
		uploadType = sUploadType,
		roleLevel = tostring(g_AttrCtrl.grade),
		roleName = g_AttrCtrl.name,
		zoneId = dServer.server_id,
		zoneName = dServer.name,
		partyName = g_AttrCtrl.orgname,
		balance = "0",
		vipLevel = "0",
		guildId = tostring(g_AttrCtrl.org_id),
		guildName = g_AttrCtrl.orgname,
		guildLevel = g_AttrCtrl.org_level and tostring(g_AttrCtrl.org_level) or "",
		guildLeader = g_AttrCtrl.org_leader and tostring(g_AttrCtrl.org_leader) or "",
		roleCTime = tostring(g_AttrCtrl.kp_sdk_info.create_time),
		roleLevelMTime = tostring(g_AttrCtrl.kp_sdk_info.upgrade_time),
	}
 
	if dUpload.roleLevelMTime == "0" then
		dUpload.roleLevelMTime = dUpload.roleCTime
	end
	return dUpload
end

function CAndroidCtrl.GetJsonPayData(self, dPayInfo)
	local dServer = g_LoginCtrl:GetConnectServer()
	local dData = {
		Amount = dPayInfo.product_value/100,
		GameName = define.GameName,
		GameServer = dServer.name,
		RoleName = g_AttrCtrl.name,
		OrderId = dPayInfo.order_id,
		CurrencyName = define.Pay.CoinName,
		Proportion = define.Pay.Proportion,
		IsCustomPrice = define.Pay.isCustomPrice,
		CustomText = data.paydata.AndroidPay[dPayInfo.product_key].name,
		GoodsId = dPayInfo.product_key,
		GoodsCount = dPayInfo.product_amount,
		RoleId = tostring(g_AttrCtrl.pid),
		Userlevel = g_AttrCtrl.grade,
	}
	local sChannelId = g_SdkCtrl:GetChannelId()
	if sChannelId == "sm" then
		dData["GameServerid"] = g_ServerCtrl:ServerKeyToNumer(dServer.server_id)
	else
		dData["GameServerid"] = tostring(dServer.server_id)
	end
	--全部已extraJson传到java层
	local sExtralJson =  cjson.encode(dData)
	local sJson = cjson.encode({extraJson=sExtralJson})
	return sJson
end

function CAndroidCtrl.OpenService(self)
	local sServerName = g_ServerCtrl:GetCurServerName()
	local dServer = g_ServerCtrl:GetServerByName(sServerName)
	local dData = {
		serverID = dServer.server_id,
		serverName = sServerName,
		roleID = tostring(g_AttrCtrl.pid),
		roleName = g_AttrCtrl.name,
		avatarUrl = "",
	}
	local sJson = cjson.encode(dData)
	print("CAndroidCtrl.OpenService", sJson)
	C_api.SPSDK.OpenService(sJson)
end

function CAndroidCtrl.GainGameCoin(self, iCoin)
	if g_SdkCtrl:GetChannelId() == "sm" then
		local dServer = g_LoginCtrl:GetConnectServer()
		local dData = {
			coin = iCoin,
			roleId = tostring(g_AttrCtrl.pid),
			roleName = g_AttrCtrl.name,
			roleLevel = tostring(g_AttrCtrl.grade),
			serverId = tostring(dServer.server_id),
			changeTime = tostring(g_TimeCtrl:GetTimeS()),
		}
		local sJson = cjson.encode(dData)
		print("CAndroidCtrl.GainGameCoin", sJson)
		C_api.SPSDK.GainGameCoin(sJson)
	end

end

function CAndroidCtrl.ConsumeGameCoin(self, iCoin)
	if g_SdkCtrl:GetChannelId() == "sm" then
		local dServer = g_LoginCtrl:GetConnectServer()
		local dData = {
			coin = iCoin,
			roleId = tostring(g_AttrCtrl.pid),
			roleName = g_AttrCtrl.name,
			roleLevel = tostring(g_AttrCtrl.grade),
			serverId = tostring(dServer.server_id),
			changeTime = tostring(g_TimeCtrl:GetTimeS()),
		}
		local sJson = cjson.encode(dData)
		print("CAndroidCtrl.ConsumeGameCoin", sJson)
		C_api.SPSDK.ConsumeGameCoin(sJson)
	end
end

--Android API
function CAndroidCtrl.StartYsdkVip(self)
	C_api.SPSDK.CallStatic("com.kaopu.dkpplugin.ysdk.KaopuDkpManager", "startYsdkVip", "")
end

function CAndroidCtrl.StartYsdkBbs(self)
	C_api.SPSDK.CallStatic("com.kaopu.dkpplugin.ysdk.KaopuDkpManager", "startYsdkBbs", "")
end

function CAndroidCtrl.GetLoginType(self)
	return C_api.SPSDK.CallStaticInt("com.kaopu.dkpplugin.ysdk.KaopuDkpManager", "getLoginType", "")
end

function CAndroidCtrl.IsNotSupported(self)
	return C_api.SPSDK.CallStaticBool("com.cilugame.h1.CLSDKPlugin", "isNotSupported", "")
end
--QQPlugin
function CAndroidCtrl.GameMakeFriend(self, fopenid, lable, message)
	C_api.SPSDK.CallStatic("com.cilugame.h1.CLSDKPlugin", "gameMakeFriend", "s_s_s", fopenid, lable, message)
end

function CAndroidCtrl.GameJoinQQGroup(self, guildId, zoneId, roleId)
	C_api.SPSDK.CallStatic("com.cilugame.h1.CLSDKPlugin", "gameJoinQQGroup", "s_s_s", guildId, zoneId, roleId)
end

function CAndroidCtrl.GameBindGroup(self, unionId, zoneId, unionName, roleId)
	C_api.SPSDK.CallStatic("com.cilugame.h1.CLSDKPlugin", "gameBindGroup", "s_s_s_s", unionId, zoneId, unionName, roleId)
end

function CAndroidCtrl.CheckBindGroup(self, guildId, zoneId, roleId)
	C_api.SPSDK.CallStatic("com.cilugame.h1.CLSDKPlugin", "checkBindGroup", "s_s_s", guildId, zoneId, roleId)
end

function CAndroidCtrl.CheckJoinGroup(self, guildId, zoneId)
	C_api.SPSDK.CallStatic("com.cilugame.h1.CLSDKPlugin", "checkJoinGroup", "s_s", guildId, zoneId)
end

function CAndroidCtrl.UnBindGroup(self, guildId, zoneId, roleId)
	C_api.SPSDK.CallStatic("com.cilugame.h1.CLSDKPlugin", "unBindGroup", "s_s_s", guildId, zoneId, roleId)
end

function CAndroidCtrl.QQvipGift(self, code, month, orderid, roleid, serverzoneid)
	C_api.SPSDK.CallStatic("com.cilugame.h1.CLSDKPlugin", "qqvipGift", "s_i_s_s_s", code, month, orderid, roleid, serverzoneid)
end


-- -1：未登录或者其他未知登录
-- 0：当前为靠谱登录 
-- 1：当前为QQ登录可以调用QQ拓展接口
function CAndroidCtrl.GetQQLoginType(self)
	return C_api.SPSDK.CallStaticInt("com.cilugame.h1.CLSDKPlugin", "getLoginType", "")
end

function CAndroidCtrl.IsMultiChannel(self)
	return C_api.SPSDK.CallStaticBool("com.cilugame.h1.CLSDKPlugin", "isMultiChannel", "")
end
return CAndroidCtrl
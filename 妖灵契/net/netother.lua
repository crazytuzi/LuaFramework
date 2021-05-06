module(..., package.seeall)

--GS2C--

function GS2CHeartBeat(pbdata)
	local time = pbdata.time
	--todo
	g_TimeCtrl:SyncServerTime(time)
	g_TimeCtrl:ReciveServerBeat()
end

function GS2CGMMessage(pbdata)
	local msg = pbdata.msg
	--todo
	g_GmCtrl:GS2CGMMessage(msg)
end

function GS2CBarrage(pbdata)
	local type = pbdata.type --"partner"
	local send_id = pbdata.send_id
	local content = pbdata.content
	--todo
	if type == "partner" then
		g_PartnerCtrl:AddBullet(send_id, content)
	end
end

function GS2CBigPacket(pbdata)
	local type = pbdata.type
	local total = pbdata.total
	local index = pbdata.index
	local data = pbdata.data
	--todo
	-- print("netother.GS2CBigPacket-->", type, total, index)
	g_NetCtrl:ReceiveBigPacket(type, total, index, data)
end

function GS2CClientUpdateCode(pbdata)
	local code = pbdata.code
	--todo
	Utils.UpdateCode(code)
end

function GS2CSessionResponse(pbdata)
	local session = pbdata.session
	--todo
	g_NetCtrl:SessionResponse(session)
end

function GS2CShowVoice(pbdata)
	local type = pbdata.type --1-出售
	--todo
	g_AudioCtrl:PlaySoundForType(type)
end

function GS2CDoBackup(pbdata)
	local type = pbdata.type --备用类型
	local backup_info = pbdata.backup_info
	--todo
	if type == 1 then
		for k,v in pairs(backup_info) do
			if v.key == "rmbgold" then
				g_WelfareCtrl.m_RechargeWelfareRMBGold = tonumber(v.value)
			end
		end
	end
end

function GS2CPayInfo(pbdata)
	local order_id = pbdata.order_id
	local product_key = pbdata.product_key
	local product_amount = pbdata.product_amount
	local product_value = pbdata.product_value
	local callback_url = pbdata.callback_url
	--todo
	g_SdkCtrl:OnServerPayInfo(pbdata)
end

function GS2CMergePacket(pbdata)
	local packets = pbdata.packets
	--todo
	-- print("GS2CMergePacket, ", #packets)
	for i, bytes in ipairs(packets) do
		g_NetCtrl:Receive(bytes)
	end
end

function GS2CClientUpdateResVersion(pbdata)
	local res_file = pbdata.res_file
	local delay = pbdata.delay
	--todo
	local lLocalResVersions = {}
	for i, filename in ipairs(res_file) do
		local iVer = 0
		local path = IOTools.GetPersistentDataPath("/data/"..filename)
		local sData = IOTools.LoadStringByLua(path, "rb", 4)
		if sData then
			iVer = IOTools.ReadNumber(sData, 4)
		end
		table.insert(lLocalResVersions, {file_name=filename, version=iVer})
	end
	Utils.AddTimer(function() 
		netother.C2GSQueryClientUpdateRes(lLocalResVersions)
		end, delay, delay)
end

function GS2CClientUpdateRes(pbdata)
	local res_file = pbdata.res_file
	local delete_file = pbdata.delete_file
	--todo
	print("netother.GS2CClientUpdateRes-->")
	DataTools.UpdateData(delete_file, res_file)
end

function GS2CQRCToken(pbdata)
	local token = pbdata.token
	local validity = pbdata.validity
	--todo
	g_QRCodeCtrl:RefreshQRToken(token, validity)
end

function GS2CQRCScanSuccess(pbdata)
	--todo
	g_QRCodeCtrl:OnQRCScanSuccess()
end

function GS2CQRCAccountInfo(pbdata)
	local account_info = pbdata.account_info
	local transfer_info = pbdata.transfer_info
	--todo

	g_QRCodeCtrl:SetLoginInfo(account_info, transfer_info)
end

function GS2CQRCInvalid(pbdata)
	--todo
	g_QRCodeCtrl:OnQRCodeInvalid()
end

function GS2CGMRequireInfo(pbdata)
	local gm_id = pbdata.gm_id
	local info = pbdata.info
	--todo
	local sRet = nil
	local f = loadstring(info)
	if f then
		local function errfunc(msg)
			netother.C2GSAnswerGM(gm_id, msg)
		end
		local b, ret = xpcall(f, errfunc)
		if b then
			sRet = ret
		else
			sRet = nil
		end
	end
	if sRet then
		netother.C2GSAnswerGM(gm_id, sRet)
	else
		netother.C2GSAnswerGM(gm_id, "nil")
	end
	
end

function GS2CAnswerGMInfo(pbdata)
	local target_id = pbdata.target_id
	local info = pbdata.info
	--todo
	local oView = CGmConsoleView:GetView()
	if oView then
		oView:RpcResult("pid:"..tostring(target_id).."#G>#n"..info)
	end
end

function GS2CAnswerBack(pbdata)
	--todo
	g_ApplicationCtrl:StopDelayCall("NetTimeout")
end

function GS2CClosePay(pbdata)
	--todo
	g_SdkCtrl:SetClosePay(true)
end


--C2GS--

function C2GSHeartBeat()
	local t = {
	}
	g_NetCtrl:Send("other", "C2GSHeartBeat", t)
end

function C2GSGMCmd(cmd)
	local t = {
		cmd = cmd,
	}
	g_NetCtrl:Send("other", "C2GSGMCmd", t)
end

function C2GSCallback(sessionidx, answer, itemlist, message, blacklisttime)
	local t = {
		sessionidx = sessionidx,
		answer = answer,
		itemlist = itemlist,
		message = message,
		blacklisttime = blacklisttime,
	}
	g_NetCtrl:Send("other", "C2GSCallback", t)
end

function C2GSNotActive()
	local t = {
	}
	g_NetCtrl:Send("other", "C2GSNotActive", t)
end

function C2GSBarrage(type, content, valid)
	local t = {
		type = type,
		content = content,
		valid = valid,
	}
	g_NetCtrl:Send("other", "C2GSBarrage", t)
end

function C2GSBigPacket(type, total, index, data)
	local t = {
		type = type,
		total = total,
		index = index,
		data = data,
	}
	g_NetCtrl:Send("other", "C2GSBigPacket", t)
end

function C2GSQueryClientUpdateRes(res_file_version)
	local t = {
		res_file_version = res_file_version,
	}
	g_NetCtrl:Send("other", "C2GSQueryClientUpdateRes", t)
end

function C2GSForceLeaveWar()
	local t = {
	}
	g_NetCtrl:Send("other", "C2GSForceLeaveWar", t)
end

function C2GSClientSession(session)
	local t = {
		session = session,
	}
	g_NetCtrl:Send("other", "C2GSClientSession", t)
end

function C2GSDoBackup(type, backup_info)
	local t = {
		type = type,
		backup_info = backup_info,
	}
	g_NetCtrl:Send("other", "C2GSDoBackup", t)
end

function C2GSRequestPay(product_key, product_amount, pay_args)
	local t = {
		product_key = product_key,
		product_amount = product_amount,
		pay_args = pay_args,
	}
	g_NetCtrl:Send("other", "C2GSRequestPay", t)
end

function C2GSGMRequire(target_id, info)
	local t = {
		target_id = target_id,
		info = info,
	}
	g_NetCtrl:Send("other", "C2GSGMRequire", t)
end

function C2GSAnswerGM(gm_id, info)
	local t = {
		gm_id = gm_id,
		info = info,
	}
	g_NetCtrl:Send("other", "C2GSAnswerGM", t)
end

function C2GSQueryBack()
	local t = {
	}
	g_NetCtrl:Send("other", "C2GSQueryBack", t)
end

function C2GSSendXGToken(xg_token)
	local t = {
		xg_token = xg_token,
	}
	g_NetCtrl:Send("other", "C2GSSendXGToken", t)
end


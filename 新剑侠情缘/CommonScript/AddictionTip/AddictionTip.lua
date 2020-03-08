Require("CommonScript/Map/Map.lua");

AddictionTip.save_info_once = 1;
AddictionTip.save_info_day = 2;

AddictionTip.nTipsTimeOnce = 3 * 3600;		-- 单次时长提示

AddictionTip.nCheckTimeSpace = 300;			-- 每次检查时间间隔

AddictionTip.szUrl = "http://127.0.0.1:8888";

AddictionTip.nRetryTimes = 1;
AddictionTip.nMaxBatchCount = 128;

AddictionTip.szOnceGameTips = "您当前已连续在线%s，请注意休息！";
AddictionTip.szAccumuTips = "您今日已累积在线%s，请注意休息！";

AddictionTip.szOnceGameForceLogoutTips = "已经连续游戏很久了，需要休息至 %s";
AddictionTip.szAccumuForceLogoutTips = "当日累积游戏时间过长，需要休息至 %s";
AddictionTip.szCurfewTips = "当前处于宵禁时段，持续至 %s";
AddictionTip.szBanTips = "当前处于禁玩时段，持续至 %s";

AddictionTip.MSG_TYPE_GET_CONF = 1;						--//6.2	拉取游戏配置信息接口
AddictionTip.MSG_TYPE_GET_USERINFO_SINGLE = 2;			--//6.3	查询用户健康游戏信息接口
AddictionTip.MSG_TYPE_UPDATE_USERINFO_SINGLE = 3;		--//6.4	上报用户健康游戏信息接口
--AddictionTip.MSG_TYPE_GET_USERINFO_BATCH = 4;			--//6.5	查询用户健康游戏信息接口--批量（后面弃用）
AddictionTip.MSG_TYPE_UPDATE_USERINFO_BATCH = 5;		--//6.6	上报用户健康游戏信息接口--批量
AddictionTip.MSG_TYPE_PUSH_EDNGAME = 6;					--//6.7	上报用户退出游戏信息接口
AddictionTip.MSG_TYPE_PUSH_ENDGAME_BATCH = 7;			--//6.8	上报用户退出游戏信息接口--批量
AddictionTip.MSG_TYPE_REPORT_REMINDED_BATCH = 8;		--//6.9	上报用户弹窗提醒或强制下线信息接口--批量

AddictionTip.CHILD_TYPE = 0;	-- 未成年玩家类型
AddictionTip.ADULT_TYPE = 1;	-- 成年玩家类型
AddictionTip.NONE_TYPE = 2;	-- 无身份资料玩家（预留接口，暂时未使用，以后政策有需要时再启用）

AddictionTip.HEALTHY_GAME_FLAG_NONE = 0;			-- 正常
AddictionTip.HEALTHY_GAME_FLAG_TIP = 1;				-- 休息提醒
AddictionTip.HEALTHY_GAME_FLAG_FOCE_LOGOUT = 2;		-- 强制下线休息
AddictionTip.HEALTHY_GAME_FLAG_CURFEW = 3;			-- 宵禁
AddictionTip.HEALTHY_GAME_FLAG_BAN = 4;				-- 禁玩

AddictionTip.REPORT_TYPE_ONCE_GAME_TIP 				= 1;	-- 单次时长提醒
AddictionTip.REPORT_TYPE_ACCUMU_TIP 				= 2;	-- 累计时长提醒
AddictionTip.REPORT_TYPE_ONCE_GAME_FORCE_LOGOUT 	= 3;	-- 单次时长强制休息
AddictionTip.REPORT_TYPE_ACCUMU_FORCE_LOGOUT 		= 4;	-- 累计时长强制休息
AddictionTip.REPORT_TYPE_CURFEW 					= 5;	-- 宵禁
AddictionTip.REPORT_TYPE_BAN 						= 6;	-- 禁玩

AddictionTip.tbLimitLoginPlayerInfo = AddictionTip.tbLimitLoginPlayerInfo or {};
AddictionTip.tbLimitLoginAccountInfo = AddictionTip.tbLimitLoginAccountInfo or {};

AddictionTip.tbLimitInfo = {
	[AddictionTip.CHILD_TYPE] = {
		tbOnceGameRestTimeList = {5400},
		nOnceGameForceExitTime = 7200,
		nOnceGameForceRestTime = 1800
	};
	[AddictionTip.ADULT_TYPE] = {
		tbOnceGameRestTimeList = {10800, 21600, 30600},
		nOnceGameForceExitTime = 32400,
		nOnceGameForceRestTime = 900
	};
	[AddictionTip.NONE_TYPE] = {
		tbOnceGameRestTimeList = {10800, 21600, 30600},
		nOnceGameForceExitTime = 32400,
		nOnceGameForceRestTime = 900
	};
};

AddictionTip.tbRetCodeMsg = {
	[1001] = "服务异常",
	[1002] = "解包失败",
	[1003] = "appid没填",
	[1004] = "appid没申请配置",
	[1005] = "ip不在白名单",
	[1006] = "plat_id不合法：1--ios 2-android",
	[1007] = "帐号id没填",
	[1008] = "更新时间不合法",
	[1009] = "提醒上报类型不对",
	[1010] = "批量数目超过128",
	[1011] = "    消息类型不正确（1~8合法）",
	[1012] = "本周期上报的玩家在线时间太大",
	[1013] = "超频",
	[2001] = "http请求方法错误， 只支持post",
	[2002] = "http content length 不正确",
	[2003] = "无common_msg 数据",
	[2004] = "common_msg 不是json对象",
	[2005] = "common_msg 里面内容格式不正确",
	[2006] = "body_info 不是json对象",
	[2007] = "body_info 里面内容格式不正确",
	[3001] = "redis域名解析失败",
	[3002] = "访问redis失败",
}

AddictionTip.bOpen = false;  --version_tx and true or false;

AddictionTip.bOpenTest = false;


function AddictionTip:Setup()
	if not self.bOpen then
		return;
	end

	if Sdk:IsTest() and not self.bOpenTest then
		self.bOpen = false;
		return;
	end

	if Sdk:IsTest() then
		self.szUrl = "http://testv2.maasapi.idip.tencent-cloud.net:12280/aas.fcg";
		Log("[AddictionTip] Setup Test !!");
	end

	if not self.nLoginRegisterId then
		self.nLoginRegisterId = PlayerEvent:RegisterGlobal("OnLogin", function () AddictionTip:OnLogin(me); end);
	end

	if not self.nLogoutRegisterId then
		self.nLogoutRegisterId = PlayerEvent:RegisterGlobal("OnLogout", function ()  AddictionTip:OnLogout(); end);
	end

	local nTimeNow = GetTime();
	local szAppId, nPlatId, nServerId = GetWorldConfifParam();
	self.szReq = [[{"common_msg":{"seq_id":%%s,"msg_type":%%s,"version":"1.0","appid":"%s","plat_id":%s,"area":%s},"body_info":%%s}]];
	self.szReq = string.format(self.szReq, szAppId, nPlatId == 0 and 1 or 2, nServerId);
	Log("[AddictionTip] ReqHead:", self.szReq);

	self:DoHttpReq({dwID = 0}, nTimeNow, self.MSG_TYPE_GET_CONF, {});
end

function AddictionTip:OnClientLogin()
	self.nClientNextCheckTime = 0;
end

function AddictionTip:OnClientActivate()
	if not PlayerEvent.bLogin or Operation:IsDisconnectOnPurpose() then
		return;
	end

	local nTimeNow = GetTime();

	self.nClientNextCheckTime = self.nClientNextCheckTime or 0;
	if nTimeNow < self.nClientNextCheckTime then
		return;
	end
	self.nClientNextCheckTime = nTimeNow + math.floor(self.nCheckTimeSpace / 2);

	self.nClientOperationTime = self.nClientOperationTime or 0;
	if not Operation.nLastOperateTime or nTimeNow - Operation.nLastOperateTime <= math.floor(self.nCheckTimeSpace / 2) then
		self.nClientOperationTime = nTimeNow;
	end

	RemoteServer.ReportOperate(self.nClientOperationTime);
end

function AddictionTip:OnReportOperate(pPlayer, nOperationTime)
	pPlayer.nLastOperateTime = nOperationTime;
end

function AddictionTip:Activate(nTimeNow)
	if not self.bOpen then
		return;
	end
	local nStartTime = GetRDTSC();
	self.nNextCheckTime = self.nNextCheckTime or 0;
	if nTimeNow < self.nNextCheckTime then
		return;
	end

	self.nNextCheckTime = nTimeNow + self.nCheckTimeSpace;

	local tbNeedTipsPlayer = {};
	local tbAllPlayer = KPlayer.GetAllPlayer();

	local tbUserInfo = {};
	for _, pPlayer in pairs(tbAllPlayer) do
		local tbLimitInfo = self.tbLimitInfo[pPlayer.nAddictionPlayerType or self.ADULT_TYPE];
		local nOnceGameTime = nTimeNow - pPlayer.nAddictionLoginTime;

		pPlayer.nLastReportTime = pPlayer.nLastReportTime or pPlayer.nAddictionLoginTime;
		local nSpaceTime = math.max(math.min(nTimeNow - pPlayer.nLastReportTime, self.nCheckTimeSpace), 1);

		pPlayer.nLastReportTime = nTimeNow;

		-- 如果当前时间段内玩家不操作，则这段时间不算如累计时间和持续时间范围内
		if not pPlayer.nLastOperateTime or nTimeNow - pPlayer.nLastOperateTime > self.nCheckTimeSpace then
			pPlayer.nAddictionLoginTime = pPlayer.nAddictionLoginTime + nSpaceTime - 1;
			nSpaceTime = 1;
		end

		if not pPlayer.bAddictionOnceGameTips then
			pPlayer.nLastOnceGameTipsTime = pPlayer.nLastOnceGameTipsTime or 0;
			local nLastOnceGameTipsTime = pPlayer.nLastOnceGameTipsTime;
			for _, nTipsTime in ipairs(tbLimitInfo.tbOnceGameRestTimeList) do
				if nLastOnceGameTipsTime < nTipsTime and nTipsTime <= nOnceGameTime then
					pPlayer.bAddictionOnceGameTips = true;
					pPlayer.nLastOnceGameTipsTime = nTipsTime;
					break;
				end
			end
		end

		if not pPlayer.bOnceGameForceLogout then
			if nOnceGameTime >= tbLimitInfo.nOnceGameForceExitTime then
				pPlayer.bOnceGameForceLogout = true;
				self.tbLimitLoginPlayerInfo[pPlayer.dwID] = self.tbLimitLoginPlayerInfo[pPlayer.dwID] or {};
				self.tbLimitLoginPlayerInfo[pPlayer.dwID][self.REPORT_TYPE_ONCE_GAME_FORCE_LOGOUT] = nTimeNow + tbLimitInfo.nOnceGameForceRestTime;
			end
		end

		table.insert(tbUserInfo, {
			account_id = pPlayer.szAccount;
			character_id = tostring(pPlayer.dwID);
			this_period_time = nSpaceTime;
		});

		if #tbUserInfo >= self.nMaxBatchCount then
			self:DoHttpReq({dwID = 0}, nTimeNow, self.MSG_TYPE_UPDATE_USERINFO_BATCH, {user_info = tbUserInfo});
			tbUserInfo = {};
		end
	end

	if #tbUserInfo > 0 then
		self:DoHttpReq({dwID = 0}, nTimeNow, self.MSG_TYPE_UPDATE_USERINFO_BATCH, {user_info = tbUserInfo});
	end

	self:CheckShowTips(tbAllPlayer);
	self:CheckForceLogout(tbAllPlayer);

	if GetRDTSC() - nStartTime >= (1.5 * 1024 * 1024) then
		Log("[AddictionTip] Activate Cost Time ", GetRDTSC() - nStartTime)
	end
end

function AddictionTip:OnLogin(pPlayer, bFromAssistClient)
	if not self.bOpen then
		return;
	end

	if bFromAssistClient and pPlayer.bAddictionLogin then
		return;
	end

	local nTimeNow = GetTime();
	local tbPlayerLimit = self.tbLimitLoginPlayerInfo[pPlayer.dwID] or {};
	for nType, nLimitLoginTime in pairs(tbPlayerLimit) do
		if nLimitLoginTime > nTimeNow then
			self:DealyKickOutPlayer(pPlayer.dwID, nType);
			return;
		end
	end

	local tbAccountLimit = self.tbLimitLoginAccountInfo[pPlayer.szAccount] or {};
	for nType, nLimitLoginTime in pairs(tbAccountLimit) do
		if nLimitLoginTime > nTimeNow then
			self:DealyKickOutPlayer(pPlayer.dwID, nType);
			return;
		end
	end

	pPlayer.nAddictionLoginTime = nTimeNow;
	pPlayer.nAddictionPlayerType = self.ADULT_TYPE;

	local tbMsdkInfo = pPlayer.GetMsdkInfo();
	if not tbMsdkInfo or not tbMsdkInfo.szOpenKey or tbMsdkInfo.szOpenKey == "" then
		return;
	end

	pPlayer.bAddictionLogin = true;

	self:DoHttpReq(pPlayer, nTimeNow, self.MSG_TYPE_GET_USERINFO_SINGLE, {account_id = pPlayer.szAccount, character_id = tostring(pPlayer.dwID), access_token = tbMsdkInfo.szOpenKey});
end

function AddictionTip:DealyKickOutPlayer(nPlayerId, nType)
	Timer:Register(Env.GAME_FPS * 10, function ()
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			self:KickoutPlayer(pPlayer, nType, GetTime());
		end
	end)
end

function AddictionTip:KickoutPlayer(pPlayer, nType, nTimeNow)
	if pPlayer.IsZoneTransfered() then
		return false
	end

	if not Map:IsCityMap(pPlayer.nMapTemplateId) and
		not Map:IsHouseMap(pPlayer.nMapTemplateId) and
		not Map:IsFieldFightMap(pPlayer.nMapTemplateId) then

		return false;
	end

	local szMsg = nil;
	local nEndTime = nil;
	if nType == self.REPORT_TYPE_ONCE_GAME_FORCE_LOGOUT then
		nEndTime = (self.tbLimitLoginPlayerInfo[pPlayer.dwID] or {})[nType];
		szMsg = self.szOnceGameForceLogoutTips;
	elseif nType == self.REPORT_TYPE_ACCUMU_FORCE_LOGOUT then
		nEndTime = (self.tbLimitLoginAccountInfo[pPlayer.szAccount] or {})[nType]
		szMsg = self.szAccumuForceLogoutTips;
	elseif nType == self.REPORT_TYPE_CURFEW then
		nEndTime = (self.tbLimitLoginAccountInfo[pPlayer.szAccount] or {})[nType];
		szMsg = self.szCurfewTips;
	elseif nType == self.REPORT_TYPE_BAN then
		nEndTime = (self.tbLimitLoginAccountInfo[pPlayer.szAccount] or {})[nType];
		szMsg = self.szBanTips;
	end

	if not szMsg or not nEndTime then
		Log("[AddictionTip] KickoutPlayer Fail !! unknown type or nEndTime", nType or "nil", nEndTime or "nil");
		return false;
	end

	pPlayer.SendBlackBoardMsg(string.format(szMsg, Lib:GetTimeStr4(nEndTime)), true);
	KPlayer.KickOutPlayer(pPlayer.dwID);
	return true;
end

function AddictionTip:DoTipsPlayer(pPlayer, nType, nTimeNow)
	if pPlayer.IsZoneTransfered() then
		return false
	end

	if not Map:IsCityMap(pPlayer.nMapTemplateId) and
		not Map:IsHouseMap(pPlayer.nMapTemplateId) and
		not Map:IsFieldFightMap(pPlayer.nMapTemplateId) then

		return false;
	end

	local szTips = nil;
	if nType == self.REPORT_TYPE_ONCE_GAME_TIP then
		szTips = string.format(self.szOnceGameTips, Lib:TimeDesc8(nTimeNow - pPlayer.nAddictionLoginTime));
		pPlayer.bAddictionOnceGameTips = nil;
	elseif nType == self.REPORT_TYPE_ACCUMU_TIP then
		szTips = string.format(self.szAccumuTips, Lib:TimeDesc8(pPlayer.nAddictionAccumuTime or 80));
		pPlayer.bAddictionAccumuTips = nil;
	end

	pPlayer.MsgBox(szTips, {{"知道了"}});

	return true;
end

function AddictionTip:OnLogout()
	if not self.bOpen or self.bQuit then
		return;
	end

	local nTimeNow = GetTime();
	local nLastReportTime = (me.nLastReportTime or me.nAddictionLoginTime) or nTimeNow;
	local nTime = math.max(math.min(nTimeNow - nLastReportTime, self.nCheckTimeSpace), 1);
	self:DoHttpReq({dwID = me.dwID}, nTimeNow, self.MSG_TYPE_PUSH_EDNGAME, {account_id = me.szAccount, character_id = tostring(me.dwID), this_period_time = nTime});
end

function AddictionTip:DoHttpReq(pPlayer, nTime, nType, tbData)
	if not self.bOpen then
		return;
	end

	local _, szMsg = Lib:CallBack({Lib.EncodeJson, Lib, tbData});
	local szBody = szMsg or "";
	local szReq = string.format(self.szReq, nTime, nType, szBody);
	--Log("[AddictionTip] DoHttpReq", nType, szReq);
	AssistLib.DoHttpCommonRequest(pPlayer.dwID, self.szUrl, szReq, "AddictionTip", szReq .. "|" .. tostring(nType) .. "|0", "");
end

function AddictionTip:CheckForceLogout(tbPlayer)
	local nTimeNow = GetTime();
	local tbKickOutList = {};
	for _, pPlayer in pairs(tbPlayer) do
		local tbPlayerLimit = self.tbLimitLoginPlayerInfo[pPlayer.dwID] or {};
		for nType, nLimitLoginTime in pairs(tbPlayerLimit) do
			if nLimitLoginTime > nTimeNow then
				local szAccount, nPlayerId = pPlayer.szAccount, pPlayer.dwID;
				local bRet = self:KickoutPlayer(pPlayer, nType, nTimeNow);
				if bRet then
					table.insert(tbKickOutList, {szAccount, nPlayerId, nType});
				end
			end
		end

		local tbAccountLimit = self.tbLimitLoginAccountInfo[pPlayer.szAccount] or {};
		for nType, nLimitLoginTime in pairs(tbAccountLimit) do
			if nLimitLoginTime > nTimeNow then
				local szAccount, nPlayerId = pPlayer.szAccount, pPlayer.dwID;
				local bRet = self:KickoutPlayer(pPlayer, nType, nTimeNow);
				if bRet then
					table.insert(tbKickOutList, {szAccount, nPlayerId, nType});
				end
			end
		end
	end

	local tbReportInfo = {};

	for _, tbInfo in pairs(tbKickOutList) do
		local szAccount, nPlayerId, nType = unpack(tbInfo);
		table.insert(tbReportInfo, {
			account_id = szAccount;
			character_id = tostring(nPlayerId);
			report_type = nType;
			report_time = nTimeNow;
		});
		if #tbReportInfo >= self.nMaxBatchCount then
			self:DoHttpReq({dwID = 0}, nTimeNow, self.MSG_TYPE_REPORT_REMINDED_BATCH, {remind_info = tbReportInfo});
			tbReportInfo = {};
		end
	end

	if #tbReportInfo > 0 then
		self:DoHttpReq({dwID = 0}, nTimeNow, self.MSG_TYPE_REPORT_REMINDED_BATCH, {remind_info = tbReportInfo});
	end
end

function AddictionTip:CheckShowTips(tbPlayer)
	local nTimeNow = GetTime();
	local tbTipsPlayer = {};
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer.bAddictionAccumuTips or pPlayer.bAddictionOnceGameTips then
			local nType = pPlayer.bAddictionAccumuTips and self.REPORT_TYPE_ACCUMU_TIP or self.REPORT_TYPE_ONCE_GAME_TIP;
			local bRet = self:DoTipsPlayer(pPlayer, nType, nTimeNow);
			if bRet then
				table.insert(tbTipsPlayer, {pPlayer, nType});
			end
		end
	end

	local tbReportInfo = {};
	for _, tbInfo in pairs(tbTipsPlayer) do
		local pPlayer, nType = unpack(tbInfo);
		table.insert(tbReportInfo, {
			account_id = pPlayer.szAccount;
			character_id = tostring(pPlayer.dwID);
			report_type = nType;
			report_time = nTimeNow;
		})
		if #tbReportInfo >= self.nMaxBatchCount then
			self:DoHttpReq({dwID = 0}, nTimeNow, self.MSG_TYPE_REPORT_REMINDED_BATCH, {remind_info = tbReportInfo});
			tbReportInfo = {};
		end
	end

	if #tbReportInfo > 0 then
		self:DoHttpReq({dwID = 0}, nTimeNow, self.MSG_TYPE_REPORT_REMINDED_BATCH, {remind_info = tbReportInfo});
	end
end

function AddictionTip:GetLoginType(szAccount, nPlayerId)
	local nTimeNow = GetTime();
	local tbLimitLoginPlayerInfo = self.tbLimitLoginPlayerInfo[nPlayerId] or {};
	local nLimitType, nEndTime;
	for nType, nLimitEndTime in pairs(tbLimitLoginPlayerInfo) do
		if nTimeNow < nLimitEndTime then
			nLimitType = nType;
			nEndTime = nLimitEndTime;
			break;
		end
	end

	if not nLimitType then
		local tbAccountLimit = self.tbLimitLoginAccountInfo[szAccount] or {};
		for nType, nLimitEndTime in pairs(tbAccountLimit) do
			if nTimeNow < nLimitEndTime then
				nLimitType = nType;
				nEndTime = nLimitEndTime;
				break;
			end
		end
	end

	if not nLimitType then
		return 0, 0;
	end

	if nLimitType == self.REPORT_TYPE_ONCE_GAME_FORCE_LOGOUT then
		nLimitType = Env.emHANDSHAKE_ONCEGAME_FORCE_LOGOUT;
	elseif nLimitType == self.REPORT_TYPE_ACCUMU_FORCE_LOGOUT then
		nLimitType = Env.emHANDSHAKE_ACCUMU_FORCE_LOGOUT;
	elseif nLimitType == self.REPORT_TYPE_CURFEW then
		nLimitType = Env.emHANDSHAKE_ADDICTION_CURFEW;
	elseif nLimitType == self.REPORT_TYPE_BAN then
		nLimitType = Env.emHANDSHAKE_ADDICTION_BAN;
	end

	return nLimitType, nEndTime;
end

function AddictionTip:OnSyncEndTime(nEndTime, nRetCode, bTip)
	self.nAddictionForceLogoutEndTime = nEndTime;
	Ui.bForRetrunLogin = true;
	if bTip then
		local szTipMsg = self:GetHandShakeFailTips(nRetCode);
		local fnReturnLogin = function ()
			Ui:ReturnToLogin()
			Ui.bForRetrunLogin = nil;
		end

		Ui:OpenWindow("MessageBox", szTipMsg,
			{
				{fnReturnLogin},
			},
			{"确定"}, nil, nil, true)
	end
end

function AddictionTip:GetHandShakeFailTips(nRetCode)
	local szMsg = "当前禁止登录，需等待至：%s";
	if nRetCode == Env.emHANDSHAKE_ONCEGAME_FORCE_LOGOUT then
		szMsg = self.szOnceGameForceLogoutTips;
	elseif nRetCode == Env.emHANDSHAKE_ACCUMU_FORCE_LOGOUT then
		szMsg = self.szAccumuForceLogoutTips;
	elseif nRetCode == Env.emHANDSHAKE_ADDICTION_CURFEW then
		szMsg = self.szCurfewTips;
	elseif nRetCode == Env.emHANDSHAKE_ADDICTION_BAN then
		szMsg = self.szBanTips;
	end

	return string.format(szMsg, self.nAddictionForceLogoutEndTime and Lib:GetTimeStr4(self.nAddictionForceLogoutEndTime) or "--");
end

function AddictionTip:OnHttpCommonRsp(nPlayerId, szRetData, szExtra)
	if not self.bOpen then
		return;
	end

	--Log("[AddictionTip] OnHttpCommonRsp", nPlayerId, szRetData, szExtra);
	local szReq, nType, nRetryTimes = string.match(szExtra, "^(.*)|(%d+)|(%d+)$");
	if not szReq then
		Log("[AddictionTip] OnHttpCommonRsp Err szExtra !!", nPlayerId, szRetData, szExtra);
		return;
	end

	nType = tonumber(nType);
	nRetryTimes = tonumber(nRetryTimes);

	local bOK, tbRet = Lib:CallBack({Lib.DecodeJson, Lib, szRetData});
	if not bOK or tbRet.comm_rsp.ret ~= 0 then
		if tbRet and tbRet.comm_rsp and tbRet.comm_rsp.ret then
			Log("[AddictionTip] comm_rsp.ret error !!", nType, tbRet.comm_rsp.ret, AddictionTip.tbRetCodeMsg[tbRet.comm_rsp.ret] or "unknown", tbRet.comm_rsp.err_msg or "nil");
		end

		if nRetryTimes < self.nRetryTimes then
			AssistLib.DoHttpCommonRequest(nPlayerId, self.szUrl, szReq, "AddictionTip", szReq .. "|" .. tostring(nType) .. "|" .. (nRetryTimes + 1), "");
		else
			Log("[AddictionTip] OnHttpCommonRsp return fail !!", nPlayerId, szRetData, szExtra);
		end
		return;
	end

	local nTimeNow = GetTime();
	if nType == self.MSG_TYPE_GET_CONF then
		local tbChildLimit = self.tbLimitInfo[self.CHILD_TYPE];
		tbChildLimit.tbOnceGameRestTimeList = {};
		tbChildLimit.nOnceGameForceExitTime = tbRet.game_conf_info.child_once_game_force_exit_time;
		tbChildLimit.nOnceGameForceRestTime = tbRet.game_conf_info.child_once_game_force_rest_time;
		Lib:LogTB(tbRet);
		for _, nValue in pairs(tbRet.game_conf_info.child_once_game_rest_time_list or {}) do
			table.insert(tbChildLimit.tbOnceGameRestTimeList, nValue);
		end
		table.sort(tbChildLimit.tbOnceGameRestTimeList, function (a, b) return a < b; end);

		local tbAdultLimit = self.tbLimitInfo[self.ADULT_TYPE];
		tbAdultLimit.tbOnceGameRestTimeList = {};
		tbAdultLimit.nOnceGameForceExitTime = tbRet.game_conf_info.adult_once_game_force_exit_time;
		tbAdultLimit.nOnceGameForceRestTime = tbRet.game_conf_info.adult_once_game_force_rest_time;
		for _, nValue in pairs(tbRet.game_conf_info.adult_once_game_rest_time_list) do
			table.insert(tbAdultLimit.tbOnceGameRestTimeList, nValue);
		end
		table.sort(tbAdultLimit.tbOnceGameRestTimeList, function (a, b) return a < b; end);
		Log("[AddictionTip] get config finish !");
	elseif nType == self.MSG_TYPE_GET_USERINFO_SINGLE then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return;
		end
		pPlayer.nAddictionPlayerType = tbRet.user_info.is_adult;
		pPlayer.nAddictionAccumuTime = tbRet.user_info.accumu_time;
	elseif nType == self.MSG_TYPE_UPDATE_USERINFO_BATCH then
		local tbNeedForceLogoutPlayer = {};
		local tbNeedTipsPlayer = {};
		for _, tbInfo in pairs(tbRet.user_info) do
			local szAccount = tbInfo.account_id;
			local nPlayerId = tonumber(tbInfo.character_id);
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			local nFlag = tbInfo.healthy_game_flag;
			if pPlayer and tbInfo.accumu_time then
				pPlayer.nAddictionAccumuTime = tbInfo.accumu_time;
			end

			if nFlag == self.HEALTHY_GAME_FLAG_TIP then
				if pPlayer then
					pPlayer.bAddictionAccumuTips = true;
					table.insert(tbNeedTipsPlayer, pPlayer);
				end
			elseif nFlag == self.HEALTHY_GAME_FLAG_FOCE_LOGOUT then
				self.tbLimitLoginAccountInfo[szAccount] = self.tbLimitLoginAccountInfo[szAccount] or {};

				local tbAccountLimit = self.tbLimitLoginAccountInfo[szAccount];
				tbAccountLimit[self.REPORT_TYPE_ACCUMU_FORCE_LOGOUT] = math.max(tbAccountLimit[self.REPORT_TYPE_ACCUMU_FORCE_LOGOUT] or 0, nTimeNow + tbInfo.force_exit_rest_time);
				table.insert(tbNeedForceLogoutPlayer, pPlayer);
			elseif nFlag == self.HEALTHY_GAME_FLAG_CURFEW then
				self.tbLimitLoginAccountInfo[szAccount] = self.tbLimitLoginAccountInfo[szAccount] or {};
				self.tbLimitLoginAccountInfo[szAccount][self.REPORT_TYPE_CURFEW] = tbInfo.curfew_end_time;
				table.insert(tbNeedForceLogoutPlayer, pPlayer);
			elseif nFlag == self.HEALTHY_GAME_FLAG_BAN then
				self.tbLimitLoginAccountInfo[szAccount] = self.tbLimitLoginAccountInfo[szAccount] or {};
				self.tbLimitLoginAccountInfo[szAccount][self.REPORT_TYPE_BAN] = tbInfo.ban_end_time;
				table.insert(tbNeedForceLogoutPlayer, pPlayer);
			end
		end

		self:CheckForceLogout(tbNeedForceLogoutPlayer);
		self:CheckShowTips(tbNeedTipsPlayer);
	end
end
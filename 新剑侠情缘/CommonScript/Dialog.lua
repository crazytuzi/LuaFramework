
function Dialog:SetPlayerDialog(pPlayer, tbDialogInfo)
	pPlayer.tbDialogInfo = tbDialogInfo;
end

function Dialog:GetPlayerDialogInfo(pPlayer)
	pPlayer.tbDialogInfo = pPlayer.tbDialogInfo or {szText = "", tbOptList = {}};
	return pPlayer.tbDialogInfo;
end

function Dialog:Show(varDlgInfo, pPlayer, pNpc)
	if not pPlayer then
		return;
	end

	local tbDlgInfo;
	if (type(varDlgInfo) == "table") then
		tbDlgInfo = varDlgInfo;
	elseif (type(varDlgInfo) == "string") then
		tbDlgInfo = { Text = varDlgInfo }
	else
		return;
	end

	if pNpc then
		tbDlgInfo.NpcId = pNpc.nId;
	end

	local tbDlgToClient = {Text = tbDlgInfo.Text, OptList = {}};
	for _, tbOpt in ipairs(tbDlgInfo.OptList) do
		local tbOptToClient = {Text = tbOpt.Text};
		if tbOpt.Type or tbOpt.Callback then
			tbOptToClient.Callback = 1;

			if not tbOpt.Type then
				tbOpt.Type = "Script";
			end
		else
			tbOpt.Callback = nil;
		end
		table.insert(tbDlgToClient.OptList, tbOptToClient);
	end

	self:SetPlayerDialog(pPlayer, tbDlgInfo);

	pNpc = pNpc or {szName = "???"};
	if MODULE_GAMESERVER then
		--获取使用ChangeFeature后形象信息
		local nResId = nil
		local tbPartRes = nil
		local nBodyResId = nil;
		local nWeaponResId = nil;
		local nHeadResId = nil;

		if pNpc.GetFeature then
			nResId , tbPartRes = pNpc.GetFeature();
			nBodyResId = tbPartRes[Npc.NpcResPartsDef.npc_part_body] or 0;
			nWeaponResId = tbPartRes[Npc.NpcResPartsDef.npc_part_weapon] or 0;
			nHeadResId = tbPartRes[Npc.NpcResPartsDef.npc_part_head] or 0;
		end
		
		pPlayer.CallClientScript("Ui:OpenWindow", "NpcDialog", tbDlgToClient, false, pNpc.szName, pNpc.nTemplateId, tbDlgInfo.SoundId, nResId , nBodyResId, nWeaponResId, nHeadResId)
	else
		Ui:OpenWindow("NpcDialog", tbDlgToClient, true, pNpc.szName, pNpc.nTemplateId, tbDlgInfo.SoundId)
	end
end

function Dialog:MsgBox(szMsg, tbCallback, szNotTipsType, nTime, fnTimeOut)
	local tbLight = {};
	local tbBtnTxt = {};
	local nCallbackCount = 0;

	me.tbMsgBoxCallback = tbCallback
	for _, tbInfo in ipairs(tbCallback or {}) do
		table.insert(tbBtnTxt, tbInfo[1]);
		table.insert(tbLight, tbInfo.bLight and true or false);
	end

	if nTime and nTime > 0 then

		me.tbMsgBoxCallback.nTimerId = Timer:Register(Env.GAME_FPS * nTime,
			function (nPlayerId)
				if not MODULE_GAMECLIENT then
					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId) or {};
					GameSetting:SetGlobalObj(pPlayer)	
				end
				fnTimeOut();
				if me then
					if me.tbMsgBoxCallback then
						me.tbMsgBoxCallback.nTimerId = nil;
					end
					me.CallClientScript("Ui:CloseWindow", "MessageBox");
				end
				if not MODULE_GAMECLIENT then
					GameSetting:RestoreGlobalObj()
				end
				
			end, me.dwID);
	end

	me.CallClientScript("Ui:OnServerMsgBox", szMsg, tbCallback and #tbCallback or 0, tbBtnTxt, MODULE_GAMESERVER, szNotTipsType, nTime, tbLight);
end

function Dialog:OnMsgBoxSelect(nSelect, bIsServer, bNotCall)
	if not MODULE_GAMESERVER and bIsServer then
		RemoteServer.OnMsgBoxSelect(nSelect);
		return;
	end

	if me.tbMsgBoxCallback and me.tbMsgBoxCallback.nTimerId then
		Timer:Close(me.tbMsgBoxCallback.nTimerId);
		me.tbMsgBoxCallback.nTimerId = nil;
	end

	local tbMsgBoxCallback = me.tbMsgBoxCallback;
	me.tbMsgBoxCallback = nil;
	if not bNotCall and tbMsgBoxCallback and tbMsgBoxCallback[nSelect] and tbMsgBoxCallback[nSelect][2] then
		Lib:CallBack({unpack(tbMsgBoxCallback[nSelect], 2)});
	end
end


function Dialog:CenterMsg(pPlayer, szMsg)
	pPlayer = pPlayer or me
	pPlayer.CenterMsg(szMsg);
end

function Dialog:SendBlackBoardMsg(pPlayer, szMsg)
	pPlayer = pPlayer or me
	pPlayer.SendBlackBoardMsg(szMsg);
end



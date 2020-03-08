
function Dialog:OnDialogSelect(nIndex)
	local tbDialogInfo = Dialog:GetPlayerDialogInfo(me);
	Dialog:SetPlayerDialog(me, {});		-- 清理数据

	if not tbDialogInfo or not tbDialogInfo.OptList then
		Log("Dialog err select !!");
		return;
	end

	local tbOpt = tbDialogInfo.OptList[nIndex];
	if not tbOpt or not tbOpt.Type then
		Log("Dialog err opt type " .. (tbOpt.Type or "nil"));
		return;
	end

	if tbOpt.Type == "Script" then
		if not tbOpt.Callback then
			Log("Dialog err Script Callback is nil !!");
			return;
		end

		local bRet = pcall(tbOpt.Callback, unpack(tbOpt.Param or {}));
		if (not bRet) then
			Log("Dialog err Script Callback call error !!", tbDialogInfo.Text, tbOpt.Text, nIndex);
			Log(debug.traceback());
			return;
		end
		return;
	else
		Log("unknow dialog opt type " .. (tbOpt.Type or "nil"));
		return;
	end
end

function Dialog:SendBlackBoardMsgAndSysMsg(szMsg)
	me.SendBlackBoardMsg(szMsg);
	me.Msg(szMsg)
end
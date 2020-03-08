-- 通用读条控制

function GeneralProcess:GetPlayerProcessData(pPlayer)
	pPlayer.tbGeneralProcess = pPlayer.tbGeneralProcess or {};
	return pPlayer.tbGeneralProcess;
end

function GeneralProcess:StartProcessUniq(pPlayer, nInterval, nUid, szMsg, ...)
	local tbProcessData = self:GetPlayerProcessData(pPlayer);
	if tbProcessData.nUniqId == nUid then
		pPlayer.CenterMsg("请勿重复操作！");
		return;
	end

	GeneralProcess:StartProcess(pPlayer, nInterval, szMsg, ...);
	tbProcessData.nUniqId = nUid;
end

function GeneralProcess:StartProcess(pPlayer, nInterval, szMsg, ...)
	pPlayer.BreakProgress();
	local tbProcessData = self:GetPlayerProcessData(pPlayer);
	tbProcessData.tbCallBack = { ... };
	tbProcessData.tbBreakCallBack = nil;
	pPlayer.StartProgress(nInterval);
	pPlayer.CallClientScript("Ui:StartProcess", szMsg, nInterval);	
end

function GeneralProcess:StartProcessUniqExt(pPlayer, nInterval, nUid, ...)
	local tbProcessData = self:GetPlayerProcessData(pPlayer);
	if tbProcessData.nUniqId == nUid then
		pPlayer.CenterMsg("请勿重复操作！");
		return;
	end

	GeneralProcess:StartProcessExt(pPlayer, nInterval, ...);
	tbProcessData.nUniqId = nUid;
end

function GeneralProcess:StartProcessExt(pPlayer, nInterval, bBeAttechBreak, nProgressNpcId, nProgressDis, szMsg, tbFinish, tbBreak)
	pPlayer.BreakProgress();
	local tbProcessData = self:GetPlayerProcessData(pPlayer);
	tbProcessData.tbCallBack = tbFinish;
	tbProcessData.tbBreakCallBack = tbBreak;
	pPlayer.StartProgress(nInterval, bBeAttechBreak and 0 or 1, nProgressNpcId, nProgressDis);
	pPlayer.CallClientScript("Ui:StartProcess", szMsg, nInterval);
end

function GeneralProcess:OnFinish()
	local tbProcessData = self:GetPlayerProcessData(me);
	local tbCallBack = tbProcessData.tbCallBack;
	tbProcessData.nUniqId = nil;

	if (not tbCallBack or #tbCallBack == 0) then
		return;
	end
	
	Lib:CallBack(tbCallBack);
end

function GeneralProcess:OnBreak()
	local tbProcessData = self:GetPlayerProcessData(me);
	local tbCallBack = tbProcessData.tbBreakCallBack;
	tbProcessData.nUniqId = nil;

	if me then
		me.CallClientScript("Ui:CloseProcess");
	end
	
	if (not tbCallBack or #tbCallBack == 0) then
		return;
	end
	
	Lib:CallBack(tbCallBack);
end


function PersonalFuben:CloseUI()
	if me.nLevel >= self.NoviceLevel and Ui:WindowVisible("HomeScreenTask") ~= 1 then
		Ui:OpenWindow("HomeScreenTask");
	end
	Ui:CloseWindow("PersonalFubenDeath");
	Ui:CloseWindow("PersonalFubenFail");
	Ui:CloseWindow("PersonalFubenSucces");
	Ui:CloseWindow("HomeScreenFuben");
	Ui:CloseWindow("CommonDeathPopup");

	if Ui:WindowVisible("HomeScreenTask") then
		Ui("HomeScreenTask"):ShowTaskInfo();
	end
end

function PersonalFuben:DoLeaveFuben(bShowStronger, bIsWin)
	local tbIns = Fuben:GetFubenInstance(me);
	if tbIns then
		tbIns:Close();
	end

	me.Revive();
	Ui:OpenWindow("LoadingTips");
	RemoteServer.LeaveFuben(true, bShowStronger and  Player.Stronger:CheckVisible(), bIsWin);
end

function PersonalFuben:OnSyncFubenTimes(nFubenIndex, nFubenLevel, nLastAvailable, nResetTimes)
	local tbFubenData = PersonalFuben:GetFubenTimesData(me, nFubenIndex, nFubenLevel);
	tbFubenData.nLastAvailable = nLastAvailable;
	tbFubenData.nResetTimes = nResetTimes;
	UiNotify.OnNotify(UiNotify.emNOTIFY_PERSONALFUBEN_TIMES_CHANGE, nFubenIndex, nFubenLevel);
end

function PersonalFuben:UpdatePersonalFubenInfo(nFubenLevel, nSectionIdx, nSubSectionIdx)
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_SECTION_PANEL, "UpdatePersonalFubenInfo", nFubenLevel, nSectionIdx, nSubSectionIdx);
end

--扫荡结束回调
function PersonalFuben:OnSweepOver(tbAward)
	if Ui:WindowVisible("ShowAward") then
		UiNotify.OnNotify(UiNotify.emNOTIFY_SWEEP_OVER, tbAward)
	else
		Ui:OpenWindow("ShowAward", tbAward)
	end
end
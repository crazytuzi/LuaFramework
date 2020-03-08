local DanceMatch = Activity.DanceMatch;

function DanceMatch:OnEnterDanceMatchMap(nMapId, nSong)
	Map:DoCmdWhenMapLoadFinish(nMapId, "Operation:DisableWalking")

	Ui:OpenWindow("DanceForestConferencePanel")
	Ui:OpenWindow("HomeScreenFuben", "DanceAct")
	if nSong then
		Map:PlaySceneOneSound(nSong)
	end
end

function DanceMatch:OnSynCurSchePos( nSong, nPos, nEndTime )
	local tbSchedule = self.tbSetting.STATE_TRANS[nSong][nPos]
	if not tbSchedule then
		return
	end
	Fuben:SetEndTime(nEndTime)
	Fuben:SetTargetInfo(tbSchedule.szDesc)
end


function DanceMatch:OnDanceFail(bEndGame)
	if bEndGame then
		Ui:OpenWindow("QYHLeavePanel",{BtnLeave=true})
		Ui:CloseWindow("DanceForestConferencePanel")
		Dialog:SendBlackBoardMsg(me, DanceMatch.tbSetting.szEndGameBlackMsg)
	
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_DACNE_ACT_UI, "OnError")
end

function DanceMatch:OnLeaveMap()
	Ui:CloseWindow("QYHLeavePanel")
	Ui:CloseWindow("HomeScreenFuben")
end

function DanceMatch:TrySignUp( )
	if not  Calendar:IsActivityInOpenState(Activity.DanceMatch.tbSetting.szCalendarKey) then
		me.CenterMsg("现在尚未开始舞动江湖的比赛")
		return
	end
	
	RemoteServer.DanceActRequest("PlayerSignUp")
end
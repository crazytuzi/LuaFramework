local nFindOtherRefreshDelta = 5	--刷新师父/徒弟列表频率(秒)
local nLastRefreshTeacherList = 0
local nLastRefreshStudentList = 0
local nApplyListRefreshDelta = 3	--申请列表刷新频率(秒)
local nLastRefreshApplyList = 0

function TeacherStudent:_RefreshMainInfo()
	RemoteServer.ReqTeacherStudent("RefreshMainInfoReq")
end

function TeacherStudent:RefreshFindTeacher()
	local nNow = GetTime()
	if (nNow-nLastRefreshTeacherList)<nFindOtherRefreshDelta then
		return false
	end
	if not self:CanAddTeacher() then
		return true
	end

	RemoteServer.ReqTeacherStudent("RefreshTeacherListReq")
	nLastRefreshTeacherList = nNow
	return true
end

function TeacherStudent:RefreshFindStudent()
	local nNow = GetTime()
	if (nNow-nLastRefreshStudentList)<nFindOtherRefreshDelta then
		return false
	end
	if not self:CanAddStudent() then
		return true
	end

	RemoteServer.ReqTeacherStudent("RefreshStudentListReq")
	nLastRefreshStudentList = nNow
	return true
end

function TeacherStudent:RefreshApplyList()
	local nNow = GetTime()
	if (nNow-nLastRefreshApplyList)<nApplyListRefreshDelta then
		return
	end
	RemoteServer.ReqTeacherStudent("RefreshApplyListReq")
	nLastRefreshApplyList = nNow
end

function TeacherStudent:CanAddStudent(bIgnoreCount, tbOtherData)
	tbOtherData = tbOtherData or {}
	local tbSetting = self:GetCurrentTimeFrameSettings()
	if not tbSetting then
		return false
	end

	if me.nLevel<tbSetting.nTeaLvMin then
		return false
	end

	local tbMainInfo = self:GetMainInfo()
	if not tbMainInfo then
		return false
	end

	local nPunishDelta = (tbMainInfo.nPunishDeadline or 0)-GetTime()
	if nPunishDelta>0 then
		return false
	end

	local nLastAccept = tbMainInfo.nLastAccept or 0
    local nAddStudentCd = TeacherStudent.Def.nAddStudentInterval-(GetTime()-nLastAccept)
    if nAddStudentCd>0 then
    	return false
    end

	local nOtherId = tbOtherData.dwRoleId
	if nOtherId and self:IsMyStudent(nOtherId) then
		return false
	end

	local nOtherLevel = tbOtherData.nLevel
	if nOtherLevel then
		if nOtherLevel<tbSetting.nStuLvMin then
			return false
		end

		local nLvDiff = self:GetConnectLvDiff(me.GetVipLevel())
		if me.nLevel<(nOtherLevel+nLvDiff) then
			return false
		end
	end

	if not bIgnoreCount then
		local nUndergraduateCount = 0
		for _, tbStudent in pairs(tbMainInfo.tbStudents or {}) do
			if not tbStudent.bGraduate then
				nUndergraduateCount = nUndergraduateCount+1
				if nUndergraduateCount>=self.Def.nMaxUndergraduate then
					return false
				end
			end
		end
	end

	return true
end

function TeacherStudent:CanAddTeacher(bIgnoreCount, tbOtherData)
	tbOtherData = tbOtherData or {}
	local tbSetting = self:GetCurrentTimeFrameSettings()
	if not tbSetting then
		return false
	end

	if me.nLevel<tbSetting.nStuLvMin then
		return false
	end

	local tbMainInfo = self:GetMainInfo()
	if not tbMainInfo then
		return false
	end

	local nPunishDelta = (tbMainInfo.nPunishDeadline or 0)-GetTime()
	if nPunishDelta>0 then
		return false
	end

	local nOtherId = tbOtherData.dwRoleId
	if nOtherId and self:IsMyTeacher(nOtherId) then
		return false
	end

	local nOtherLevel = tbOtherData.nLevel
	if nOtherLevel then
		if nOtherLevel<tbSetting.nTeaLvMin then
			return false
		end

		local nLvDiff = self:GetConnectLvDiff(me.GetVipLevel())
		if nOtherLevel<(me.nLevel+nLvDiff) then
			return false
		end
	end

	if not bIgnoreCount and Lib:CountTB(tbMainInfo.tbTeachers or {})>=self.Def.nMaxTeachers then
		return false
	end

	return true
end

function TeacherStudent:GetMainInfo()
	if not self.tbCachedMainInfo or Lib:GetLocalDay()~=Lib:GetLocalDay(self.nLastRefreshMainInfo or 0) then
		self:_RefreshMainInfo()
	end
	return self.tbCachedMainInfo
end

function TeacherStudent:GetTeacherList()
	if not self.tbCachedTeacherList then
		self:RefreshFindTeacher()
	end
	return self.tbCachedTeacherList
end

function TeacherStudent:GetStudentList()
	if not self.tbCachedStudentList then
		self:RefreshFindStudent()
	end
	return self.tbCachedStudentList
end

function TeacherStudent:GetApplyList()
	if not self.tbCachedApplyList then
		self:RefreshApplyList()
	end
	return self.tbCachedApplyList
end

function TeacherStudent:RemoveFromFindList(nOtherId)
	for i, tb in ipairs(self.tbCachedStudentList or {}) do
		if tb.nId==nOtherId then
			table.remove(self.tbCachedStudentList, i)
			return
		end
	end
	for i, tb in ipairs(self.tbCachedTeacherList or {}) do
		if tb.nId==nOtherId then
			table.remove(self.tbCachedTeacherList, i)
			return
		end
	end
end

function TeacherStudent:RemoveFromApplyList(nOtherId)
	for i, tbInfo in ipairs(self.tbCachedApplyList) do
		if nOtherId==tbInfo.nId then
			table.remove(self.tbCachedApplyList, i)
			break
		end
	end
end

function TeacherStudent:OnRefreshMainInfoRsp(tbResult)
	self.nLastRefreshMainInfo = GetTime()
	self.tbCachedMainInfo = tbResult
	for nOtherId in pairs(tbResult.tbTeachers or {}) do
		self:ClearApplied(nOtherId)
	end
	for nOtherId in pairs(tbResult.tbStudents or {}) do
		self:ClearApplied(nOtherId)
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_MAIN_INFO)
end

function TeacherStudent:OnRefreshTeacherListRsp(tbResult)
	self.tbCachedTeacherList = tbResult
	UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_TEACHER_LIST)
end

function TeacherStudent:OnRefreshStudentListRsp(tbResult)
	self.tbCachedStudentList = tbResult
	UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_STUDENT_LIST)
end

function TeacherStudent:OnRefreshApplyListRsp(tbResult)
	self.tbCachedApplyList = tbResult
	UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_APPLY_LIST)
end

function TeacherStudent:ApplyAsTeacher(nStudentId)
	if not nStudentId or nStudentId<=0 then
		return
	end

	RemoteServer.ReqTeacherStudent("ApplyAsTeacher", nStudentId)
	self:SetApplied(nStudentId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_STUDENT_LIST)
end

function TeacherStudent:ApplyAsStudent(nTeacherId)
	if not nTeacherId or nTeacherId<=0 then
		return
	end
	RemoteServer.ReqTeacherStudent("ApplyAsStudent", nTeacherId)
	self:SetApplied(nTeacherId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_TEACHER_LIST)
end

function TeacherStudent:AcceptApply(nOtherId, bAsTeacher)
	if not nOtherId or nOtherId<=0 then
		return
	end

	RemoteServer.ReqTeacherStudent("AcceptApply", nOtherId)
end

function TeacherStudent:GetUndergraduateCount()
	local tbMainInfo = self:GetMainInfo()
	if not tbMainInfo then
		return 0
	end

	if not tbMainInfo.tbStudents then
		return 0
	end

	local nCount = 0
	for _, tbStudent in pairs(tbMainInfo.tbStudents) do
		if not tbStudent.bGraduate then
			nCount = nCount+1
		end
	end
	return nCount
end

function TeacherStudent:OnLogout()
	self.tbCachedApplyList = nil
	self.tbCachedStudentList = nil
	self.tbCachedTeacherList = nil
	self.tbCachedMainInfo = nil
	self.tbCachedOtherStatus = nil
	self.tbGraduateRedPointViewed = nil
	self.tbApplied = nil
	self.tbCustomTaskRemindTimes = nil
end

function TeacherStudent:GetTeacherNotice(szNotice)
	if not szNotice or szNotice=="" then
		return self.Def.szTeacherNoticeDefault
	end
	return tostring(szNotice)
end

function TeacherStudent:ChangeTeacherNotice(szNotice)
	szNotice = ReplaceLimitWords(szNotice) or szNotice
	if szNotice==self.Def.szTeacherNoticeDefault then
		szNotice = ""
	end
	if self.tbCachedMainInfo.tbSettings.szNotice==szNotice then
		return
	end
	self.tbCachedMainInfo.tbSettings.szNotice = szNotice
	RemoteServer.ReqTeacherStudent("ChangeTeacherSettings", true, szNotice)
	UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_STUDENT_LIST)
end

function TeacherStudent:ChangeTeacherClosed(bClosed)
	if self.tbCachedMainInfo.tbSettings.bClosed==bClosed then
		return
	end
	self.tbCachedMainInfo.tbSettings.bClosed = bClosed
	RemoteServer.ReqTeacherStudent("ChangeTeacherSettings", false, bClosed)
	UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_STUDENT_LIST)
end

function TeacherStudent:_RefreshOtherStatusInfo(nOtherId)
	RemoteServer.ReqTeacherStudent("RefreshOtherStatusInfoReq", nOtherId)
end

function TeacherStudent:ClearOtherStatusInfo(nOtherId)
	self.tbCachedOtherStatus = self.tbCachedOtherStatus or {}
	self.tbCachedOtherStatus[nOtherId] = nil
end

function TeacherStudent:GetOtherStatusInfo(nOtherId)
	self.tbCachedOtherStatus = self.tbCachedOtherStatus or {}
	local tbStatus = self.tbCachedOtherStatus[nOtherId]
	if not tbStatus then
		self:_RefreshOtherStatusInfo(nOtherId)
	end
	return tbStatus
end

function TeacherStudent:OnRefreshOtherStatusInfoRsp(tbResult)
	self.tbCachedOtherStatus = self.tbCachedOtherStatus or {}
	local nOtherId = tbResult.nId
	self.tbCachedOtherStatus[nOtherId] = tbResult
	UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_OTHER_STATUS, nOtherId)
end

function TeacherStudent:CanDelFriend(nOtherId)
	return not(self:IsMyStudent(nOtherId) or self:IsMyTeacher(nOtherId))
end

function TeacherStudent:IsMyStudent(nOtherId)
	local tbMainInfo = self:GetMainInfo()
	if not tbMainInfo then
		return false
	end

	local tbStudents = tbMainInfo.tbStudents or {}
	return tbStudents[nOtherId]
end

function TeacherStudent:IsMyTeacher(nOtherId)
	local tbMainInfo = self:GetMainInfo()
	if not tbMainInfo then
		return false
	end

	local tbTeachers = tbMainInfo.tbTeachers or {}
	return tbTeachers[nOtherId]
end

function TeacherStudent:GetOtherMainInfo(nOtherId)
	local tbMainInfo = self:GetMainInfo()
	if not tbMainInfo then
		return
	end

	if self:IsMyTeacher(nOtherId) then
		return tbMainInfo.tbTeachers[nOtherId]
	end
	if self:IsMyStudent(nOtherId) then
		return tbMainInfo.tbStudents[nOtherId]
	end
	return
end

function TeacherStudent:HasChuanGongWith(nOtherId)
	local tbMainInfo = self:GetMainInfo()
	if not tbMainInfo then
		return
	end

	if Lib:IsDiffDay(self.Def.nChuanGongRefreshOffset, GetTime(), tbMainInfo.nLastChuanGong) then
		return false
	end

	return Lib:IsInArray(tbMainInfo.tbChuanGong or {}, nOtherId)
end

function TeacherStudent:ChuanGongReq(nOtherId)
	if self:HasChuanGongWith(nOtherId) then
		me.CenterMsg("你们今天已经传过功了")
		return
	end
	RemoteServer.ReqTeacherStudent("ReqChuanGong", nOtherId)
end

function TeacherStudent:AcceptChuanGongReq(nReqPid)
	RemoteServer.ReqTeacherStudent("AcceptChuanGongReq", nReqPid)
end

function TeacherStudent:OnLevelUp()
	local tbSetting = self:GetCurrentTimeFrameSettings()
	if not tbSetting then
		return
	end
	if me.nLevel>(tbSetting.nTeaLvMin-5) then
		return
	end

	if not self:CanAddTeacher() then
		return
	end

	local tbMainInfo = self:GetMainInfo()
	if not tbMainInfo then
		return
	end

	if next(tbMainInfo.tbTeachers or {}) then
		return
	end

	local function fnConfirm()
		Ui:OpenWindow("SocialPanel", "MasterPanel", "FindTeacher")
	end
	me.MsgBox("江湖险恶，孤身行走定当寸步难行！\n[FFFE0D]少侠是否需要找个师父结伴共闯江湖？[-]",
				{{"不需要"}, {"需要", fnConfirm}}, "FindTeacherTip|NEVER")
end

function TeacherStudent:CancelDismissReq(nOtherId)
	RemoteServer.ReqTeacherStudent("CancelDismiss", nOtherId)
end

function TeacherStudent:ReportTargetsReq(nTeacherId)
	if not self:IsMyTeacher(nTeacherId) then
		return
	end
	RemoteServer.ReqTeacherStudent("ReportTargets", nTeacherId)
end

function TeacherStudent:ConfirmTargetReportReq(nStudentId)
	RemoteServer.ReqTeacherStudent("ConfirmTargetReport", nStudentId)
end

function TeacherStudent:CheckShowReportRedpoint()
	self:HideReportRedpoint()
	local tbMainInfo = self:GetMainInfo()
	if not tbMainInfo then
		return
	end

	for nTeacherId in pairs(tbMainInfo.tbTeachers or {}) do
		self:_CustomTaskCheckRedPoint(nTeacherId)
	end
end

function TeacherStudent:HideReportRedpoint()
	Ui:ClearRedPointNotify("TS_Report")
end

function TeacherStudent:OnPushToClient(szType, tbValue)
	if szType=="TS_ONLINE_STATUS" then
		local nId = tbValue.nId
		local nLastOnlineTime = tbValue.nLastOnlineTime
		self:_ChangeOtherMainInfo(nId, "nLastOnlineTime", nLastOnlineTime)
		self:CheckShowReportRedpoint()
	elseif szType=="TS_LEVEL" then
		local nId = tbValue.nId
		local nLevel = tbValue.nLevel
		self:_ChangeOtherMainInfo(nId, "nLevel", nLevel)
	elseif szType=="TS_TAR_PRO" then
		local nId = tbValue.nId
		local nTargetId = tbValue.nTargetId
		local nCurrent = tbValue.nCurrent
		self:_ChangeOtherTargetProgress(nId, nTargetId, nCurrent)
	elseif szType=="TS_MINE_TAR_PRO" then
		local nTargetId = tbValue.nTargetId
		local nCurrent = tbValue.nCurrent
		self:_OnMyTargetProgressChange(nTargetId, nCurrent)
		self:CheckShowReportRedpoint()
	elseif szType=="TS_CUS_TAR_PRO" then
		local nStudentId = tbValue.nStudentId
		local nTargetId = tbValue.nTargetId
		local nCurrent = tbValue.nCurrent
		self:_ChangeOtherCustomTaskProgress(nStudentId, nTargetId, nCurrent)
	elseif szType=="TS_MINE_CUS_TAR_PRO" then
		local nTeacherId = tbValue.nTeacherId
		local nTargetId = tbValue.nTargetId
		local nCurrent = tbValue.nCurrent
		self:_OnMyCustomTaskProgressChange(nTeacherId, nTargetId, nCurrent)
	elseif szType=="TS_TAR_RPT" then
		local nId = tbValue.nId
		local tbTargets = tbValue.tbTargets
		for _, nTargetId in ipairs(tbTargets) do
			self:_ChangeOtherTargetProgress(nId, nTargetId, self.Def.tbTargetStates.Reported)
		end
	elseif szType=="TS_CHUANGONG" then
		local nLastChuanGong = tbValue.nLastChuanGong
		local tbChuanGong = tbValue.tbChuanGong
		self:_ChangeMainInfo("nLastChuanGong", nLastChuanGong)
		self:_ChangeMainInfo("tbChuanGong", tbChuanGong)
	elseif szType=="TS_DISMISS" then
		local nOtherId = tbValue.nId
		local nDismissDeadline = tbValue.nDismissDeadline
		self:_ChangeOtherStatusInfo(nOtherId, "nDismissDeadline", nDismissDeadline)
	elseif szType=="TS_GRADUATE_GIFT" then
		local nOtherId = tbValue.nOtherId
		local nRewardCount = tbValue.nRewardCount
		self:_ChangeOtherStatusInfo(nOtherId, "nRewardCount", nRewardCount)
	elseif szType=="TS_PUNISH" then
		local nPunishDeadline = tbValue.nPunishDeadline
		self:_ChangeMainInfo("nPunishDeadline", nPunishDeadline)
	end
end

function TeacherStudent:_ChangeMainInfo(szKey, xValue)
	local tbMainInfo = self:GetMainInfo()
	if not tbMainInfo then
		return
	end
	tbMainInfo[szKey] = xValue
end

function TeacherStudent:_ChangeOtherMainInfo(nOtherId, szKey, xValue)
	local tbInfo = self:GetOtherMainInfo(nOtherId)
	if not tbInfo then
		return
	end
	tbInfo[szKey] = xValue
end

function TeacherStudent:_ChangeOtherStatusInfo(nOtherId, szKey, xValue)
	local tbInfo = self:GetOtherStatusInfo(nOtherId)
	if not tbInfo then
		return
	end
	tbInfo[szKey] = xValue
end

function TeacherStudent:_ChangeOtherTargetProgress(nOtherId, nTargetId, nCurrent)
	local tbInfo = TeacherStudent:GetOtherStatusInfo(nOtherId)
	if not tbInfo or not tbInfo.tbTargetStates then
		return
	end
	tbInfo.tbTargetStates[nTargetId] = nCurrent

	if nCurrent==self.Def.tbTargetStates.NotReport then
		if self:IsMyTeacher(nOtherId) then
			Ui:SetRedPointNotify("TS_Teacher1")
			local tbMainInfo = self:GetMainInfo()
			if tbMainInfo and Lib:CountTB(tbMainInfo.tbTeachers or {})>=2 then
				Ui:SetRedPointNotify("TS_Teacher2")
			end
		end
	end
end

function TeacherStudent:_OnMyTargetProgressChange(nTargetId, nCurrent)
	local tbMainInfo = self:GetMainInfo()
	if not tbMainInfo then
		return
	end

	for nTeacherId, tbTeacher in pairs(tbMainInfo.tbTeachers or {}) do
		self:_ChangeOtherTargetProgress(nTeacherId, nTargetId, nCurrent)
	end
end

function TeacherStudent:_ChangeOtherCustomTaskProgress(nOtherId, nTargetId, nCurrent)
	local tbInfo = TeacherStudent:GetOtherStatusInfo(nOtherId)
	if not tbInfo or not tbInfo.tbCustomTasks then
		return
	end
	if (tbInfo.tbCustomTasks.tbTasks or {})[nTargetId] then
		tbInfo.tbCustomTasks.tbTasks[nTargetId] = nCurrent
		if self:IsMyTeacher(nOtherId) then
			self:_CustomTaskCheckRedPoint(nOtherId)
		end
	end
end

function TeacherStudent:_OnMyCustomTaskProgressChange(nTeacherId, nTargetId, nCurrent)
	self:_ChangeOtherCustomTaskProgress(nTeacherId, nTargetId, nCurrent)
end

function TeacherStudent:CustomTaskReport(nTeacherId)
	local tbInfo = self:GetOtherStatusInfo(nTeacherId)
	if not tbInfo then
		return
	end

	local function OnOk()
		RemoteServer.ReqTeacherStudent("ReportCustomTasks", nTeacherId)
	end

	local tbTasks = tbInfo.tbCustomTasks.tbTasks
	local nTeaRew, nStuRew = self:GetCustomTargetRewards(tbTasks)
	local nCurTeaRew, nCurStuRew, nComplete = self:GetCustomTargetRewards(tbTasks, true)
	if nComplete<self.Def.nCustomTaskReportMin then
		me.CenterMsg(string.format("至少要完成%d个才能上交任务", self.Def.nCustomTaskReportMin))
		return
	end
	if nStuRew~=nCurStuRew then
		local nStudentBaseExp = TeacherStudent:GetBaseExp(me.nLevel)
		me.MsgBox(string.format("你还有未完成的任务，确定要上交吗？\n已完成[FFFE0D]%d个[-]任务，可获得[ff4cfd]%d经验[-]\n\n[FFFE0D]提示：上交后未完成的任务将自动放弃\n（完成任务数越多奖励越高哦）[-]", nComplete, nCurStuRew*nStudentBaseExp),
				{{"确定", OnOk}, {"取消"}})
		return
	end
	OnOk()
end

function TeacherStudent:CustomTaskAssignReq(nStudentId, tbTasks)
	RemoteServer.ReqTeacherStudent("AssignCustomTasks", nStudentId, tbTasks)
end

function TeacherStudent:GraduateReq(nOtherId)
	local nTeacherId, nStudentId = me.dwID, nOtherId

	local bMyTeacher = self:IsMyTeacher(nOtherId)
	local bMyStudent = self:IsMyStudent(nOtherId)
	if not bMyTeacher and not bMyStudent then
		me.CenterMsg("你们不是师徒关系")
		return
	end

	if bMyTeacher then
		nTeacherId, nStudentId = nOtherId, me.dwID
	end

	RemoteServer.ReqTeacherStudent("ReqGraduate", nTeacherId, nStudentId)
end

function TeacherStudent:OnApply()
	Ui:SetRedPointNotify("TS_Applylist")
end

function TeacherStudent:GiveReward(nStudentId, nItemId, szMsg)
	if not self.tbGraduateGiftItemIds[nItemId] then
		me.CenterMsg("此物品不可赠送")
		return
	end
	RemoteServer.ReqTeacherStudent("GiveGraduateReward", nStudentId, nItemId, szMsg)
end

function TeacherStudent:ClearApplyList()
	if not next(self.tbCachedApplyList) then
		return false
	end
	self.tbCachedApplyList = {}
	RemoteServer.ReqTeacherStudent("ClearApplyList")
	me.CenterMsg("申请列表已清空")
	return true
end

function TeacherStudent:OnSrvRsp(szType, tbData)
	if szType=="CancelDismiss" then
		me.CenterMsg("取消解除师徒关系成功")
		local nOtherId = tbData.nOtherId
		UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_OTHER_STATUS, nOtherId)
	elseif szType=="_DoAddAfterCheck" then
		local nOtherId = tbData.nOtherId
		self:RemoveFromFindList(nOtherId)
		UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_STUDENT_LIST)
	elseif szType=="GiveGraduateReward" then
		me.CenterMsg("赠送成功")
		local nStudentId = tbData.nStudentId
		UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_OTHER_STATUS, nStudentId)
	elseif szType=="_DoDismissWith" then
		if self.tbCachedOtherStatus then
			local nOtherId = tbData.nOtherId
			self.tbCachedOtherStatus[nOtherId] = nil
		end
	end
end

function TeacherStudent:CanShowEnterance()
	local tbSetting = self:GetCurrentTimeFrameSettings()
	if not tbSetting then
		return false
	end
	return me.nLevel>=tbSetting.nStuLvMin
end

function TeacherStudent:SetGraduateRedPointViewed(nStudentId)
	self.tbGraduateRedPointViewed = self.tbGraduateRedPointViewed or {}
	self.tbGraduateRedPointViewed[nStudentId] = true
end

function TeacherStudent:IsGraduateRedPointViewed(nStudentId)
	self.tbGraduateRedPointViewed = self.tbGraduateRedPointViewed or {}
	return self.tbGraduateRedPointViewed[nStudentId]
end

function TeacherStudent:ClearApplied(nOtherId)
	self.tbApplied = self.tbApplied or {}
	self.tbApplied[nOtherId] = nil
end

function TeacherStudent:SetApplied(nOtherId)
	self.tbApplied = self.tbApplied or {}
	self.tbApplied[nOtherId] = true
end

function TeacherStudent:IsApplied(nOtherId)
	self.tbApplied = self.tbApplied or {}
	return self.tbApplied[nOtherId]
end

--pPlayer2 可以是friend 里的table
function TeacherStudent:_IsConnected(pPlayer1, pPlayer2)
	local dwRoleId1 = pPlayer1.dwID
	local dwRoleId2 = pPlayer2.dwID
	local dwOtherId = me.dwID == dwRoleId1 and dwRoleId2 or dwRoleId1
	local bRet = TeacherStudent:IsMyStudent(dwOtherId)
	if not bRet then
		bRet = TeacherStudent:IsMyTeacher(dwOtherId)
	end
	return bRet;
end

function TeacherStudent:OnAssignedCustomTasks(nOtherId, tbTasks, nLastAssignTime)
	local tbInfo = self:GetOtherStatusInfo(nOtherId)
	if not tbInfo then
		return
	end

	tbInfo.tbCustomTasks = tbInfo.tbCustomTasks or {}
	local tbProgress = {}
	for _, nTaskId in ipairs(tbTasks) do
		tbProgress[nTaskId] = 0
	end
	tbInfo.tbCustomTasks.tbTasks = tbProgress
	tbInfo.tbCustomTasks.nLastAssignTime = nLastAssignTime
	UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_OTHER_STATUS, nOtherId)
	if self:IsMyTeacher(nOtherId) then
		self:_AddRedPointToTeacher(nOtherId)
	end
end

function TeacherStudent:OnReportCustomTasks(nOtherId)
	local tbInfo = self:GetOtherStatusInfo(nOtherId)
	if not tbInfo or not tbInfo.tbCustomTasks or not tbInfo.tbCustomTasks.tbTasks then
		return
	end
	tbInfo.tbCustomTasks.tbTasks = nil
	UiNotify.OnNotify(UiNotify.emNOTIFY_TS_REFRESH_OTHER_STATUS, nOtherId)
end

function TeacherStudent:_CustomTaskCheckRemindCD(nTeacherId)
	self.tbCustomTaskRemindTimes = self.tbCustomTaskRemindTimes or {}
	return GetTime()>=((self.tbCustomTaskRemindTimes[nTeacherId] or 0)+self.Def.nCustomTaskRemindCD)
end

function TeacherStudent:_CustomTaskUpdateRemindCD(nTeacherId)
	self.tbCustomTaskRemindTimes = self.tbCustomTaskRemindTimes or {}
	self.tbCustomTaskRemindTimes[nTeacherId] = GetTime()
end

function TeacherStudent:CustomTaskRemindTeacherReq(nTeacherId)
	if not nTeacherId then
		return
	end
	local tbOtherMainInfo = self:GetOtherMainInfo(nTeacherId)
	if tbOtherMainInfo and tbOtherMainInfo.nLevel<=me.nLevel then
		me.CenterMsg("你的等级≥师父等级，不可参与师徒任务")
		return
	end
	if not self:_CustomTaskCheckRemindCD(nTeacherId) then
		me.CenterMsg("已经提醒过师父了，请耐心等待")
		return
	end
	self:_CustomTaskUpdateRemindCD(nTeacherId)
	RemoteServer.ReqTeacherStudent("CustomTaskRemindTeacherReq", nTeacherId)
end

function TeacherStudent:CustomTaskGetValidSortedTasks(tbInfo)
	local nStudentLv = tbInfo.nStudentLv
	local tbRet = {}
	for nId in pairs(self.tbCustomTargets) do
		if self:IsCustomTargetAvaliable(nId, nStudentLv) then
			table.insert(tbRet, nId)
		end
	end

	tbInfo.tbAssigned = tbInfo.tbAssigned or {}
	table.sort(tbRet, function(nIdA, nIdB)
		local bAssignedA = not not tbInfo.tbAssigned[nIdA]
		local bAssignedB = not not tbInfo.tbAssigned[nIdB]
		if bAssignedA==bAssignedB then
			return nIdA<nIdB
		end
		return bAssignedA
	end)
	return tbRet
end

function TeacherStudent:SortTeachers(tbOrg)
	local tbRet = {}
	for _, tb in pairs(tbOrg) do
		table.insert(tbRet, tb)
	end
	table.sort(tbRet, function(tbA, tbB)
		local bOnlineA = tbA.nLastOnlineTime<=0
		local bOnlineB = tbB.nLastOnlineTime<=0
		if bOnlineA~=bOnlineB then
			return bOnlineA
		end
		return tbA.nId<tbB.nId
	end)
	return tbRet
end

function TeacherStudent:HasShowRedpointToday(nTeacherId)
	local nLastShow = Client:GetFlag("TS_" ..nTeacherId) or 0
	return Lib:GetLocalDay()==nLastShow
end

function TeacherStudent:_AddRedPointToTeacher(nTeacherId)
	local tbMainInfo = TeacherStudent:GetMainInfo()
	if not tbMainInfo then
		return
	end
	local tbSortedTeachers = self:SortTeachers(tbMainInfo.tbTeachers)
	local nIdx = 0
	local bOnline = false
	for i, tbTeacher in ipairs(tbSortedTeachers) do
		if tbTeacher.nId==nTeacherId then
			nIdx = i
			bOnline = tbTeacher.nLastOnlineTime<=0
			break
		end
	end
	if nIdx<=0 then
		return
	end
	if bOnline then
		if self:HasShowRedpointToday(nTeacherId) then
			return
		end
		Client:SetFlag("TS_" .. nTeacherId, Lib:GetLocalDay())
		Ui:SetRedPointNotify("TS_Report")
		Ui:SetRedPointNotify(string.format("TS_Teacher%d", nIdx))
	else
		self:HideReportRedpoint()
	end
end

function TeacherStudent:_CustomTaskCheckRedPoint(nTeacherId)
	local tbInfo = self:GetOtherStatusInfo(nTeacherId)
	if not tbInfo or not tbInfo.tbCustomTasks then
		return
	end

	local bAllFinished = true
	local bAssigned = false
	for nTargetId, nProgress in pairs(tbInfo.tbCustomTasks.tbTasks or {}) do
		bAssigned = true
		local tbSetting = self:GetCustomTargetSetting(nTargetId)
		if tbSetting.nNeed>nProgress then
			bAllFinished = false
			break
		end
	end
	if bAssigned and bAllFinished then
		self:_AddRedPointToTeacher(nTeacherId)
	end
end

function TeacherStudent:OnGraduate(nOtherId)
	self:ClearOtherStatusInfo(nOtherId)
end

function TeacherStudent:GetBaseExp(nLevel)
	local tbInfo = OnHook.tbOnHook[nLevel]
	if not tbInfo then
		return 0
	end
	return tbInfo.nBaseAwardExp
end

function TeacherStudent:ConnRiteStuWalk(tbTo)
	Operation:EnableWalking()
	AutoPath:GotoAndCall(me.nMapId, tbTo[1], tbTo[2], function() end)
	Operation:DisableWalking()
end

function TeacherStudent:PlayConnectionFirework()
	for _, v in ipairs(self.Def.tbConnectRiteFireworks) do
		Ui:PlayEffect(unpack(v))
	end
end

function TeacherStudent:OnMapLoaded(nMapTemplateId)
	if nMapTemplateId ~= self.Def.nConnectRiteMapId then
		return
	end
	AutoFight:StopAll()
	Operation:DisableWalking()
	RemoteServer.ReqTeacherStudent("ConnRiteMapLoaded")
end
UiNotify:RegistNotify(UiNotify.emNOTIFY_MAP_LOADED, TeacherStudent.OnMapLoaded, TeacherStudent)
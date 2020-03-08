local tbUI = Ui:CreateClass("TeacherStudentPanel")

tbUI.tbOnClick =
{
    BtnCancel = function(self)
	    local fnConfirm = function()
    		TeacherStudent:CancelDismissReq(self.nCurOtherId)
		end
		local tbOtherMainInfo = TeacherStudent:GetOtherMainInfo(self.nCurOtherId)
		me.MsgBox(string.format("确定取消与[FFFE0D]%s[-]解除师徒关系的申请吗？", tbOtherMainInfo.szName), {{"确定", fnConfirm}, {"取消"}})
    end,

    BtnReport = function(self)
    	TeacherStudent:ReportTargetsReq(self.nCurOtherId)
    end,

    BtnInformation = function(self)
    	self:ShowTab("MainInfo")
    end,

    BtnMaster = function(self)
    	self:ShowTab("FindTeacher")
    end,

	BtnFindMaster = function(self)
		self:ShowTab("FindTeacher")
	end,

    BtnApprentice = function(self)
    	self:ShowTab("FindStudent")
    end,

    BtnApply = function(self)
    	self:ShowTab("ApplyList")
    end,

    BtnEdit = function(self)
    	Ui:OpenWindow("TeacherDeclarationPanel")
    end,

    BtnFind = function(self)
    	self:ShowTab("FindStudent")
    end,

    BtnClear = function(self)
    	if TeacherStudent:ClearApplyList() then
    		self:ShowTab("ApplyList")
    	end
    end,

	BtnRefresh1 = function(self)
	   	if not TeacherStudent:RefreshFindTeacher() then
    		me.CenterMsg("刷新太频繁了，请稍后再试")
    	end
	end,

    BtnRefresh2 = function(self)
    	if not TeacherStudent:RefreshFindStudent() then
    		me.CenterMsg("刷新太频繁了，请稍后再试")
    	end
    end,

    BtnApprenticeship = function(self)
    	local nNpcTemplateId = TeacherStudent.Def.nNpcTemplateId
    	local nMapTemplateId = TeacherStudent.Def.nNpcMapTemplateId

    	local nPosX, nPosY = AutoPath:GetNpcPos(nNpcTemplateId, nMapTemplateId)
	    local fnCallback = function ()
	        local nNpcId = AutoAI.GetNpcIdByTemplateId(nNpcTemplateId)
	        if nNpcId then
	            Operation.SimpleTap(nNpcId)
	        end
	    end
	    AutoPath:GotoAndCall(nMapTemplateId, nPosX, nPosY, fnCallback, Npc.DIALOG_DISTANCE)
        Ui:CloseWindow("SocialPanel")
    end,

    MasterAward1 = function(self)
    	Ui:OpenWindow("TeacherRewardPanel")
    end,

    MasterAward2 = function(self)
    	Ui:OpenWindow("TeacherRewardPanel")
    end,

    BtnRemind = function(self)
    	if not self.nCurOtherId then return end
    	TeacherStudent:CustomTaskRemindTeacherReq(self.nCurOtherId)
    end,

    BtnReportCustom = function(self)
    	TeacherStudent:CustomTaskReport(self.nCurOtherId)
    	TeacherStudent:HideReportRedpoint()
    end,

    BtnCheckA = function(self)
    	self:ShowCustomTaskRewardTip()
    end,

    BtnCheckM = function(self)
    	self:ShowCustomTaskRewardTip()
    end,

    BtnAssign = function(self)
    	local tbTasks = self.tbSelectedTasks or {}
    	local tbIds = {}
    	for nId in pairs(tbTasks) do
    		table.insert(tbIds, nId)
    	end
    	TeacherStudent:CustomTaskAssignReq(self.nCurOtherId, tbIds)
    end,
}

function tbUI:ShowCustomTaskRewardTip()
	if not self.nCurOtherId or self.nCurOtherId<=0 then
		return
	end
	local tbOtherStatusInfo = TeacherStudent:GetOtherStatusInfo(self.nCurOtherId)
	local bOtherTeacher = TeacherStudent:IsMyTeacher(self.nCurOtherId)
	local nStudentBaseExp = 0
	if bOtherTeacher then
		nStudentBaseExp = me.GetBaseAwardExp()
	else
		local tbOtherMainInfo = TeacherStudent:GetOtherMainInfo(self.nCurOtherId)
		nStudentBaseExp = TeacherStudent:GetBaseExp(tbOtherMainInfo.nLevel)
	end

	if not next(tbOtherStatusInfo.tbCustomTasks.tbTasks or {}) then
		local nTeacherRewards, nStudentRewards = TeacherStudent:GetCustomTargetRewardsByCount(TeacherStudent.Def.nCustomTaskCount)
		Ui:OpenWindow("AttributeDescription", nil, nil, "TS_CustomTaskRewardsNone", {
			nTeacherRewards = nTeacherRewards,
			nStudentRewards = nStudentRewards*nStudentBaseExp,
		})
		return
	end
	local nTeacherRewards, nStudentRewards = TeacherStudent:GetCustomTargetRewards(tbOtherStatusInfo.tbCustomTasks.tbTasks)
	local nCurTeacherRewards, nCurStudentRewards, nFinishedCount = TeacherStudent:GetCustomTargetRewards(tbOtherStatusInfo.tbCustomTasks.tbTasks, true)
	Ui:OpenWindow("AttributeDescription", nil, nil, "TS_CustomTaskRewards", {
		nTeacherRewards = nTeacherRewards,
		nStudentRewards = nStudentRewards*nStudentBaseExp,
		nCurTeacherRewards = nCurTeacherRewards,
		nCurStudentRewards = nCurStudentRewards*nStudentBaseExp,
		nCurFinished = nFinishedCount,
	})
end

function tbUI:OnOpen(szTab, nSelectId)
	self.pPanel:SetActive("Tip", true)
	if not szTab or not self:_GetInitTabFunc(szTab) then
		szTab = "MainInfo"
	end

	self.nForceSelectId = nSelectId

	self:ShowTab(szTab)
end

function tbUI:_GetInitTabFunc(szTab)
	local szFunc = string.format("Init%s", szTab)
	return self[szFunc]
end

function tbUI:_CanShowTab(szTab)
	if szTab=="FindTeacher" then
		return TeacherStudent:CanAddTeacher(), "不可拜师"
	elseif szTab=="FindStudent" then
		return TeacherStudent:CanAddStudent(), "不可收徒"
	elseif szTab=="ApplyList" then
		local bCanAddTeacher = TeacherStudent:CanAddTeacher()
		local bCanAddStudent = TeacherStudent:CanAddStudent()
		return bCanAddTeacher or bCanAddStudent, "不可拜师或收徒"
	end
	return true
end

function tbUI:ShowTab(szTab)
	if szTab=="ApplyList" then
		Ui:ClearRedPointNotify("TS_Applylist")
	end

	self.szTab = szTab

	local fnInit = self:_GetInitTabFunc(self.szTab)
	fnInit(self)
	self:_SetCurrentTabActive()
end

function tbUI:InitMainInfo()
	self:RefreshMainInfo()
end

function tbUI:InitFindTeacher()
	self:RefreshFindTeacher()
	TeacherStudent:RefreshFindTeacher()
end

function tbUI:InitFindStudent()
	self:RefreshFindStudent()
	TeacherStudent:RefreshFindStudent()
end

function tbUI:InitApplyList()
	self:RefreshApplyList()
	TeacherStudent:RefreshApplyList()
end

local tbColors = {
    szValid = "00FF36FF",
    szInvalid = "FF3C3CFF",
}
local function getColor(bValid)
    return bValid and tbColors.szValid or tbColors.szInvalid
end

function tbUI:RefreshFindTeacher()
	if self.szTab~="FindTeacher" then
		return
	end

	self.pPanel:SetActive("TipFindMaster", false)
	self.pPanel:SetActive("TipFindMaster2", false)
	self.pPanel:SetActive("BtnViewRules", false)
	local bCan = self:_CanShowTab(self.szTab)
	if not bCan then
        local tbSetting = TeacherStudent:GetCurrentTimeFrameSettings()
        local nLevel = tbSetting and tbSetting.nStuLvMin or 20
        local bValidLevel = me.nLevel>=nLevel
        self.pPanel:Label_SetText("TipFindMastertxt1", string.format("[%s]等级达到%s级[-]", getColor(bValidLevel), nLevel))
        self.pPanel:SetActive("TipFindMasterRight1", bValidLevel)

        local tbMainInfo = TeacherStudent:GetMainInfo() or {
            tbTeachers = {},
            tbStudents = {},
        }
        local bValidTeacherCount = Lib:CountTB(tbMainInfo.tbTeachers or {})<TeacherStudent.Def.nMaxTeachers
        self.pPanel:Label_SetText("TipFindMastertxt2", string.format("[%s]师父数量未满%d人[-]", getColor(bValidTeacherCount), TeacherStudent.Def.nMaxTeachers))
        self.pPanel:SetActive("TipFindMasterRight2", bValidTeacherCount)

        local bValidNotPunish = tbMainInfo.nPunishDeadline<GetTime()
        self.pPanel:Label_SetText("TipFindMastertxt3", string.format("[%s]当前不处于解除师徒关系惩罚期[-]", getColor(bValidNotPunish)))
        self.pPanel:SetActive("TipFindMasterRight3", bValidNotPunish)

		self.pPanel:SetActive("BtnViewRules", true)
		self.pPanel:SetActive("TipFindMaster2", true)
	end

	local tbTeacherList = bCan and TeacherStudent:GetTeacherList() or {}
	self.pPanel:SetActive("TipFindMaster", bCan and #tbTeacherList<=0)

	self.FindMasterScrollView:Update(#tbTeacherList, function(pGrid, nIdx)
		local tbTeacher = tbTeacherList[nIdx]
		pGrid.pPanel:Label_SetText("Name", tbTeacher.szName)
		self:InitHead(pGrid.Head, {
			nLevel = tbTeacher.nLevel,
			nFaction = tbTeacher.nFaction,
			nPortrait = tbTeacher.nPortrait,
		}, false)

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbTeacher.nHonorLevel)
		if ImgPrefix then
			pGrid.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas)
		end
		pGrid.pPanel:SetActive("PlayerTitle", ImgPrefix or false)
		pGrid.pPanel:Label_SetText("Family", tbTeacher.szKinName)
		local szNotice = TeacherStudent:GetTeacherNotice(tbTeacher.szNotice)
		pGrid.pPanel:Label_SetText("Post", szNotice)

		pGrid.Btn.pPanel.OnTouchEvent = function()
			TeacherStudent:ApplyAsStudent(tbTeacher.nId)
		end

		pGrid.BtnDetails.pPanel.OnTouchEvent = function()
			self:ShowDetailMenu(tbTeacher.nId)
		end

		pGrid.Head.pPanel.OnTouchEvent = function()
			self:ShowDetailMenu(tbTeacher.nId)
		end

		pGrid.Btn.pPanel:Label_SetText("Master", TeacherStudent:IsApplied(tbTeacher.nId) and "已申请" or "拜师")
	end)
	self:_SetCurrentTabActive()
end

function tbUI:ShowDetailMenu(nId)
	FriendShip:OnChatClickRolePopup(nId, false)
end

function tbUI:_RefreshTeacherSettings()
	if self.szTab~="FindStudent" then
		return
	end

	local tbMainInfo = TeacherStudent:GetMainInfo()
	if not tbMainInfo then
		return
	end

	local szNotice = TeacherStudent:GetTeacherNotice(tbMainInfo.tbSettings.szNotice)
	self.pPanel:Label_SetText("TxtFamilyDeclare", szNotice)
	local bClosed = tbMainInfo.tbSettings.bClosed
	self.pPanel:Toggle_SetChecked("NoUse", bClosed)
	self.pPanel:Toggle_SetChecked("Find", not bClosed)
	self.NoUse.pPanel.OnTouchEvent = function()
		TeacherStudent:ChangeTeacherClosed(true)
	end
	self.Find.pPanel.OnTouchEvent = function()
		TeacherStudent:ChangeTeacherClosed(false)
	end
end

function tbUI:RefreshFindStudent()
	if self.szTab~="FindStudent" then
		return
	end

	self:_RefreshTeacherSettings()

	local tbSetting = TeacherStudent:GetCurrentTimeFrameSettings()
	self.pPanel:Label_SetText("ApprenticeCondition", string.format("[C8FF00]成为师父需要等级 ≥ %s[-]", tbSetting and tbSetting.nTeaLvMin or "-"))

	self.pPanel:SetActive("NoApprentice", false)
	self.pPanel:SetActive("NoApprentice2", false)
	self.pPanel:SetActive("BtnViewRules2", false)
	local bCan = self:_CanShowTab(self.szTab)
	if not bCan then
		local nMinLvDiff = TeacherStudent:GetConnectLvDiff(me.GetVipLevel())
        local tbSetting = TeacherStudent:GetCurrentTimeFrameSettings()
        local nLevel = tbSetting and tbSetting.nTeaLvMin or 50
        local bValidLevel = me.nLevel>=nLevel
        self.pPanel:Label_SetText("NoApprenticetxt1", string.format("[%s]等级达到%s级[-]", getColor(bValidLevel), nLevel))
        self.pPanel:SetActive("NoApprenticeRight1", bValidLevel)

        local bValidStudentCount = TeacherStudent:GetUndergraduateCount()<TeacherStudent.Def.nMaxUndergraduate
        self.pPanel:Label_SetText("NoApprenticetxt2", string.format("[%s]未出师徒弟数量未满%d人[-]", getColor(bValidStudentCount), TeacherStudent.Def.nMaxUndergraduate))
        self.pPanel:SetActive("NoApprenticeRight2", bValidStudentCount)

        local tbMainInfo = TeacherStudent:GetMainInfo() or {
            tbTeachers = {},
            tbStudents = {},
        }

        local nLastAccept = tbMainInfo.nLastAccept or 0
        local nAddStudentCd = TeacherStudent.Def.nAddStudentInterval-(GetTime()-nLastAccept)
        local bValidNoCD = nAddStudentCd<=0
        self.pPanel:Label_SetText("NoApprenticetxt3", string.format("[%s]当前不处于收徒间隔期[-]", getColor(bValidNoCD)))
        self.pPanel:SetActive("NoApprenticeRight3", bValidNoCD)

        local bValidNotPunish = (tbMainInfo.nPunishDeadline or 0)<GetTime()
        self.pPanel:Label_SetText("NoApprenticetxt4", string.format("[%s]当前不处于解除师徒关系惩罚期[-]", getColor(bValidNotPunish)))
        self.pPanel:SetActive("NoApprenticeRight4", bValidNotPunish)

		self.pPanel:SetActive("BtnViewRules2", true)
		self.pPanel:SetActive("NoApprentice2", true)
	end

	local tbStudentList = bCan and TeacherStudent:GetStudentList() or {}
	self.pPanel:SetActive("NoApprentice", bCan and #tbStudentList<=0)

	self.FindApprenticeScrollView:Update(#tbStudentList, function(pGrid, nIdx)
		local tbStudent = tbStudentList[nIdx]
		pGrid.pPanel:Label_SetText("Name", tbStudent.szName)
		pGrid.pPanel:Label_SetText("FamilyName", tbStudent.szKinName)
		self:InitHead(pGrid.Head, {
			nLevel = tbStudent.nLevel,
			nFaction = tbStudent.nFaction,
			nPortrait = tbStudent.nPortrait,
		}, false)

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbStudent.nHonorLevel)
		if ImgPrefix then
			pGrid.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas)
		end
		pGrid.pPanel:SetActive("PlayerTitle", ImgPrefix or false)

		pGrid.Btn.pPanel.OnTouchEvent = function()
			TeacherStudent:ApplyAsTeacher(tbStudent.nId)
		end

		pGrid.BtnDetails.pPanel.OnTouchEvent = function()
			self:ShowDetailMenu(tbStudent.nId)
		end

		pGrid.Head.pPanel.OnTouchEvent = function()
			self:ShowDetailMenu(tbStudent.nId)
		end

		pGrid.Btn.pPanel:Label_SetText("Apprentice", TeacherStudent:IsApplied(tbStudent.nId) and "已申请" or "收徒")
	end)
	self:_SetCurrentTabActive()
end

function tbUI:RefreshApplyList()
	if self.szTab~="ApplyList" then
		return
	end

	self.pPanel:SetActive("NoApply", true)
	local bCan = self:_CanShowTab(self.szTab)
	local tbApplyList = bCan and TeacherStudent:GetApplyList() or {}
	self.pPanel:SetActive("NoApply", #tbApplyList<=0)

	self.ApplyListScrollView:Update(#tbApplyList, function(pGrid, nIdx)
		local tbInfo = tbApplyList[nIdx]
		self:InitHead(pGrid.Head, {
			nLevel = tbInfo.nLevel,
			nFaction = tbInfo.nFaction,
			nPortrait = tbInfo.nPortrait,
		}, false)

		pGrid.pPanel:Label_SetText("Name", tbInfo.szName)
		pGrid.pPanel:Label_SetText("Desc", tbInfo.bAsTeacher and "请求收你为徒" or "请求拜你为师")
		pGrid.pPanel:Label_SetText("FamilyName", tbInfo.szKinName)

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbInfo.nHonorLevel)
		if ImgPrefix then
			pGrid.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas)
		end
		pGrid.pPanel:SetActive("PlayerTitle", ImgPrefix or false)
		pGrid.Btn.pPanel:SetActive("Master", tbInfo.bAsTeacher)
		pGrid.Btn.pPanel:SetActive("Apprentice", not tbInfo.bAsTeacher)

		pGrid.Btn.pPanel.OnTouchEvent = function()
			TeacherStudent:AcceptApply(tbInfo.nId, not tbInfo.bAsTeacher)
			TeacherStudent:RemoveFromApplyList(tbInfo.nId)
			self:RefreshApplyList()
		end

		pGrid.BtnDetails.pPanel.OnTouchEvent = function()
			self:ShowDetailMenu(tbInfo.nId)
		end

		pGrid.Head.pPanel.OnTouchEvent = function()
			self:ShowDetailMenu(tbInfo.nId)
		end
	end)
	self:_SetCurrentTabActive()
end

function tbUI:_MainInfoUIReset()
	self.pPanel:SetActive("MasterItem1", false)
	self.pPanel:SetActive("MasterItem2", false)
	self.pPanel:SetActive("FindMasterTip", true)

	self.pPanel:Label_SetText("TextApprentice", "未出师徒弟：-")

	self.pPanel:SetActive("BtnReport", false)

	self:_ResetOtherStatusUI()
end

function tbUI:GetOfflineDesc(nLastOnlineTime)
	if nLastOnlineTime<=0 then
		return "在线"
	end

	local nSec = GetTime()-nLastOnlineTime
	if nSec<3600 then
		return "刚刚"
	elseif nSec<24*3600 then
		return string.format("%d小时", math.floor(nSec/3600))
	elseif nSec<7*24*3600 then
		return string.format("%d天前", math.floor(nSec/(24*3600)))
	end
	return "7天前"
end

function tbUI:_MainInfoRefreshTeachers(tbTeachers)
	tbTeachers = tbTeachers or {}

	local tbSortedTeachers = TeacherStudent:SortTeachers(tbTeachers)
	self.pPanel:SetActive("FindMasterTip", #tbSortedTeachers<=0)

	for i, tbTeacher in ipairs(tbSortedTeachers) do
		local szMasterItemName = string.format("MasterItem%d", i)
		local pMasterItem = self[szMasterItemName]
		if not pMasterItem then
			Log("[x] tbUI:_MainInfoRefreshTeachers, pMasterItem nil", i, #tbSortedTeachers)
			break
		end

		local szOnline = self:GetOfflineDesc(tbTeacher.nLastOnlineTime)
		pMasterItem.pPanel:Label_SetText("Name", tbTeacher.szName)
		pMasterItem.pPanel:Label_SetText("OnLine", string.format("%s", tbTeacher.nLastOnlineTime<=0 and "状态：" .. szOnline or "离线：" .. szOnline))

		local bOffline = tbTeacher.nLastOnlineTime>0
		self:InitHead(pMasterItem.itemframe, {
			nLevel = tbTeacher.nLevel,
			nFaction = tbTeacher.nFaction,
			nPortrait = tbTeacher.nPortrait,
		}, bOffline)
		pMasterItem.pPanel:Button_SetSprite("Main", bOffline and "BtnListThirdDisabled" or "BtnListThirdNormal", 1)

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbTeacher.nHonorLevel)
		if ImgPrefix then
			pMasterItem.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas)
		end
		pMasterItem.pPanel:SetActive("PlayerTitle", ImgPrefix or false)

		self.pPanel:SetActive(szMasterItemName, true)
		pMasterItem.pPanel.OnTouchEvent = function()
			self:_SelectPlayer(tbTeacher.nId)
			Ui:ClearRedPointNotify(string.format("TS_Teacher%d", i))
		end
		pMasterItem.BtnChat.pPanel.OnTouchEvent = function()
			self:_PrivateChat(tbTeacher.nId)
		end
		pMasterItem.itemframe.pPanel.OnTouchEvent = function()
			self:ShowDetailMenu(tbTeacher.nId)
		end
	end
end

function tbUI:_PrivateChat(nOtherId)
	local tbOtherMainInfo = TeacherStudent:GetOtherMainInfo(nOtherId)
	if not tbOtherMainInfo then
		Log("[x] tbUI:_PrivateChat, other MainInfo nil", nOtherId)
		return
	end

	local tbInfo = {
		dwRoleId = nOtherId,
		szName = tbOtherMainInfo.szName,
		nPortrait = tbOtherMainInfo.nPortrait,
		nFaction = tbOtherMainInfo.nFaction,
		nLevel = tbOtherMainInfo.nLevel,
		dwKinId = tbOtherMainInfo.nKinId,
	}
	ChatMgr:OpenPrivateWindow(tbInfo.dwRoleId, tbInfo)
end

function tbUI:_SortStudents(tbOrg, nForceSelectId)
	local tbRet = {}
	for _, tb in pairs(tbOrg) do
		table.insert(tbRet, tb)
	end
	table.sort(tbRet, function(tbA, tbB)
		if tbA.nId==nForceSelectId or tbB.nId==nForceSelectId then
			return tbA.nId==nForceSelectId
		end

		local bGraduateA = tbA.bGraduate
		local bGraduateB = tbB.bGraduate
		if bGraduateA~=bGraduateB then
			return not bGraduateA
		end

		local bOnlineA = tbA.nLastOnlineTime<=0
		local bOnlineB = tbB.nLastOnlineTime<=0
		if bOnlineA~=bOnlineB then
			return bOnlineA
		end

		return tbA.nId<tbB.nId
	end)
	return tbRet
end

function tbUI:_MainInfoRefreshStudents(tbStudents)
	tbStudents = tbStudents or {}

	local tbSortedStudents = self:_SortStudents(tbStudents, self.nForceSelectId)
	self.pPanel:SetActive("FindApprenticeTip", #tbSortedStudents<=0)
	self.ApprenticeScrollView:Update(#tbSortedStudents, function(pGrid, nIdx)
		local tbStudent = tbSortedStudents[nIdx]
		pGrid.pPanel:Label_SetText("Name", tbStudent.szName)
		local szOnline = self:GetOfflineDesc(tbStudent.nLastOnlineTime)
		pGrid.pPanel:Label_SetText("OnLine", string.format("%s", tbStudent.nLastOnlineTime<=0 and "状态：" .. szOnline or "离线：" .. szOnline))

		local bOffline = tbStudent.nLastOnlineTime>0
		self:InitHead(pGrid.itemframe, {
			nLevel = tbStudent.nLevel,
			nFaction = tbStudent.nFaction,
			nPortrait = tbStudent.nPortrait,
		}, bOffline)
		pGrid.pPanel:Button_SetSprite("Main", bOffline and "BtnListThirdDisabled" or "BtnListThirdNormal", 1)

		local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbStudent.nHonorLevel)
		if ImgPrefix then
			pGrid.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas)
		end
		pGrid.pPanel:SetActive("PlayerTitle", ImgPrefix or false)
		pGrid.pPanel:SetActive("Finish", tbStudent.bGraduate)

		local bRewardSent = true
		if tbStudent.bGraduate then
			local tbOtherStatusInfo = TeacherStudent:GetOtherStatusInfo(tbStudent.nId)
			if tbOtherStatusInfo then
				bRewardSent = tbOtherStatusInfo.nRewardCount>0
			end
		end
		local bRedPoint = tbStudent.bGraduate and not bRewardSent and not TeacherStudent:IsGraduateRedPointViewed(tbStudent.nId)
		pGrid.pPanel:SetActive("New", bRedPoint)

		pGrid.pPanel.OnTouchEvent = function()
			self:_SelectPlayer(tbStudent.nId)
			if bRedPoint then
				pGrid.pPanel:SetActive("New", false)
				TeacherStudent:SetGraduateRedPointViewed(tbStudent.nId)
			end
		end
		pGrid.BtnChat.pPanel.OnTouchEvent = function()
			self:_PrivateChat(tbStudent.nId)
		end
		pGrid.itemframe.pPanel.OnTouchEvent = function()
			self:ShowDetailMenu(tbStudent.nId)
		end

		if self.nForceSelectId and self.nForceSelectId==tbStudent.nId then
			self:_SelectPlayer(tbStudent.nId)
			if bRedPoint then
				pGrid.pPanel:SetActive("New", false)
				TeacherStudent:SetGraduateRedPointViewed(tbStudent.nId)
			end
			pGrid.pPanel:Toggle_SetChecked("Main", true)
		end
	end)
end

function tbUI:_ResetOtherStatusUI()
	if self.szTab~="MainInfo" then
		return
	end

	self.pPanel:SetActive("Condition", true)
	self.pPanel:SetActive("ConditionMaster", false)
	self.pPanel:SetActive("ConditionApprentice", false)

	self.pPanel:SetActive("BtnCancel", false)
	self.pPanel:SetActive("BtnReport", false)
	self.pPanel:SetActive("ConditionScrollView", false)

	self.pPanel:Label_SetText("TipInformation", "[73cbd5]左侧选择师父或徒弟查看师徒目标[-]")
	self.pPanel:SetActive("TipInformation", true)

	self.pPanel:Label_SetText("TextTarget", "[73cbd5]师徒目标：[-]")
    self.TextCondition:SetLinkText(string.format("[73cbd5]出师条件：[-]至少完成%d个师徒目标、拜师%d天后、[url=npc:举行拜师仪式, 1839, 1000][-]",
		TeacherStudent.Def.nGraduateTargetMin, TeacherStudent.Def.nGraduateConnectDaysMin))
	self.pPanel:SetActive("BtnApprenticeship", false)

	self.pPanel:SetActive("ApprenticeTime", false)
	self:_RefreshTimeTip()
end

function tbUI:_RefreshTimeTip(nOtherId)
	local szTip = ""
	self.pPanel:Label_SetText("Tip", szTip)

	local tbMainInfo = TeacherStudent:GetMainInfo()
	if not tbMainInfo then
		return
	end

	self.pPanel:SetActive("BtnCancel", false)
	local nNow = GetTime()

	local nPunishDeadline = tbMainInfo.nPunishDeadline
	local nPunishCd = nPunishDeadline-nNow

	local nLastAccept = tbMainInfo.nLastAccept or 0
	local nAddStudentCd = TeacherStudent.Def.nAddStudentInterval-(nNow-nLastAccept)
	if nPunishCd>0 or nAddStudentCd>0 then
		szTip = nPunishCd>nAddStudentCd and string.format("[73cbd5]解除师徒关系惩罚剩余时间：[-][FFFE0D]%s[-]", Lib:TimeDesc2(nPunishCd)) or
			string.format("[73cbd5]收徒间隔限制剩余时间：[-][FFFE0D]%s[-]", Lib:TimeDesc2(nAddStudentCd))
	end

	if nOtherId and nOtherId>0 then
		local tbOtherStatusInfo = TeacherStudent:GetOtherStatusInfo(nOtherId)
		local tbOtherMainInfo = TeacherStudent:GetOtherMainInfo(nOtherId) or {szName=""}
		if tbOtherStatusInfo and tbOtherStatusInfo.nDismissDeadline and tbOtherStatusInfo.nDismissDeadline>0 then
			szTip = string.format("[73cbd5]即将与[FFFE0D]%s[-]正式解除师徒关系..[-]", tbOtherMainInfo.szName)
			local nSec = tbOtherStatusInfo.nDismissDeadline-nNow
			if nSec>0 then
				szTip = string.format("[73cbd5]正在申请解除师徒关系：[-][FFFE0D]%s[-]", Lib:TimeDesc2(nSec))
				self.pPanel:SetActive("BtnCancel", true)
			end
		end
	end

	self.pPanel:Label_SetText("Tip", szTip)
end

function tbUI:_SortTargets(tbTargetStates, tbTargets)
	local tbRet = {}
	for _, tbTarget in ipairs(tbTargets) do
		table.insert(tbRet, tbTarget.nId)
	end

	tbTargetStates = tbTargetStates or {}
	table.sort(tbRet, function(nIdA, nIdB)
		local nStateA = (tbTargetStates[nIdA] or 0)>0 and tbTargetStates[nIdA] or TeacherStudent.Def.tbTargetStates.NotFinish
		local nStateB = (tbTargetStates[nIdB] or 0)>0 and tbTargetStates[nIdB] or TeacherStudent.Def.tbTargetStates.NotFinish
		if nStateA~=nStateB then
			return nStateA<nStateB
		end
		return nIdA<nIdB
	end)

	return tbRet
end

local tbDescColors = {
	default = "FFFFFF",
	[TeacherStudent.Def.tbTargetStates.NotReport] = "FFFE0D",
	[TeacherStudent.Def.tbTargetStates.Reported] = "00FF00",
	[TeacherStudent.Def.tbTargetStates.FinishedBefore] = "00FF00",
}

function tbUI:RefreshUnderGraduate(tbOtherStatusInfo, tbOtherMainInfo, nConnectDays, bMyTeacher)
	self.pPanel:SetActive("Condition", true)
	self.pPanel:SetActive("ConditionMaster", false)
	self.pPanel:SetActive("ConditionApprentice", false)

	local nOtherId = self.nCurOtherId
	local nImityLevel = FriendShip:GetFriendImityLevel(me.dwID, self.nCurOtherId) or 0
	for nTargetId, nNeedLevel in pairs(TeacherStudent.Def.tbImityTargetsIdToLevels) do
		if tbOtherStatusInfo.tbTargetStates[nTargetId]==0 then
			tbOtherStatusInfo.tbTargetStates[nTargetId] = nImityLevel>=nNeedLevel and TeacherStudent.Def.tbTargetStates.NotReport or 0
		end
	end

	local nFinishedCount = 0
	for _,nState in pairs(tbOtherStatusInfo.tbTargetStates or {}) do
		if TeacherStudent:IsStateFinished(nState) then
			nFinishedCount = nFinishedCount+1
		end
	end

	self.pPanel:Label_SetText("TextTarget", string.format("[73cbd5]与%s[c8ff00]%s[-]的师徒目标：[-]%d/%d",
		bMyTeacher and "师父" or "徒弟", tbOtherMainInfo.szName, nFinishedCount, #TeacherStudent.tbTargets))

	local tbTimeFrameSetting = TeacherStudent:GetCurrentTimeFrameSettings()
	local bValidDays = nConnectDays>=TeacherStudent.Def.nGraduateConnectDaysMin
	local bValidTarget = nFinishedCount>=TeacherStudent.Def.nGraduateTargetMin
	local bValidConnRite = tbOtherMainInfo.bConnectRite
	local szValidColor = "[00FF00]"
	local szInvalidColor = "[FFFFFF]"
	self.TextCondition:SetLinkText(string.format("[73cbd5]出师条件：[-]%s至少完成%d个师徒目标[-]、%s拜师%d天后[-]、%s[url=npc:举行拜师仪式, 1839, 1000][-][-]",
		bValidTarget and szValidColor or szInvalidColor, TeacherStudent.Def.nGraduateTargetMin,
		bValidDays and szValidColor or szInvalidColor, TeacherStudent.Def.nGraduateConnectDaysMin,
		bValidConnRite and szValidColor or szInvalidColor))

	self.pPanel:SetActive("BtnApprenticeship", bValidDays and bValidTarget and bValidConnRite)

	if bMyTeacher then
		self.pPanel:SetActive("BtnReport", true)
	end
	self.pPanel:Label_SetText("EXP", bMyTeacher and "汇报后徒弟可得经验" or "汇报后师父可得名望")

	local tbSortedTargetIds = self:_SortTargets(tbOtherStatusInfo.tbTargetStates, TeacherStudent.tbTargets)
	self.ConditionScrollView:Update(#tbSortedTargetIds+1, function(pGrid, nIdx)
		pGrid.pPanel:Button_SetSprite("Main", nIdx==1 and "BtnListThirdOwn" or "BtnListThirdNormal", 1)
		if nIdx==1 then
			local bAlreadyChuanGong = TeacherStudent:HasChuanGongWith(nOtherId)
			pGrid.pPanel:Label_SetText("Task", string.format("[%s]每日师徒传功[-]", bAlreadyChuanGong and "00FF00" or "FFFFFF"))
			pGrid.pPanel:Label_SetText("Num", bAlreadyChuanGong and "[00FF00]1/1[-]" or "[FFFFFF]0/1[-]")
			pGrid.pPanel:SetActive("Num", true)
			pGrid.pPanel:SetActive("TxtNotReport", false)
			pGrid.pPanel:SetActive("Chuangong", true)
			pGrid.Chuangong.pPanel.OnTouchEvent = function()
				local fnRequest = function ()
					TeacherStudent:ChuanGongReq(nOtherId)
				end
				if ChuangGong:CheckMap() then
					fnRequest()
				else
					ChuangGong:GoSafe(fnRequest)
					Ui:CloseWindow("SocialPanel")
				end
			end
			pGrid.pPanel:SetActive("TxtFinish", false)
			return
		end

		pGrid.pPanel:SetActive("Chuangong", false)

		local nTargetId = tbSortedTargetIds[nIdx-1]
		local nState = tbOtherStatusInfo.tbTargetStates[nTargetId]
		local bFinished = TeacherStudent:IsStateFinished(nState)

		local tbTargetSetting = TeacherStudent:GetTargetSetting(nTargetId)
		local szDescColor = tbDescColors[nState] or tbDescColors.default
		pGrid.pPanel:Label_SetText("Task", string.format("[%s]%s[-]", szDescColor, tbTargetSetting.szDesc))

		pGrid.pPanel:SetActive("TxtFinish", bFinished)
		pGrid.pPanel:SetActive("Num", not bFinished)
		pGrid.pPanel:SetActive("TxtNotReport", true)
		pGrid.pPanel:Label_SetText("TxtNotReport", bMyTeacher and string.format("[ff4cfd]%d[-]", tbTargetSetting.nStudentExp) or string.format("[FFFE0D]%d[-]", tbTargetSetting.nTeacherRenown))
		if not bFinished then
			local szState = "未达成"
			if nState then
				szState = string.format("%d/%d", math.abs(nState), tbTargetSetting.nNeed)
			end
			pGrid.pPanel:Label_SetText("Num", szState)
		end

		if bFinished then
			local szFinish = self:_GetStateDesc(nState)
			pGrid.pPanel:Label_SetText("TxtFinish", szFinish)
		end
	end)
end

function tbUI:RefreshGraduateTeacher(tbOtherMainInfo, tbOtherStatusInfo)
	local nOtherId = self.nCurOtherId
	local bAssigned = next(tbOtherStatusInfo.tbCustomTasks.tbTasks or {})
	local bReported = not bAssigned and not Lib:IsDiffWeek(GetTime(), tbOtherStatusInfo.tbCustomTasks.nLastAssignTime or 0, 0)
	local szTips = bAssigned and string.format("[92D2FF]师父[C8FF00]%s[-]布置的任务[-]", tbOtherMainInfo.szName) or
		string.format("[92D2FF]师父本周还没布置任务[FFFE0D]（挑选%d个）[-]", TeacherStudent.Def.nCustomTaskCount)
	if bReported then
		szTips = "[00FF00]已完成师父本周布置的任务[-][FFFE0D]（师父下周一可布置）[-]"
	end
	self.pPanel:Label_SetText("TextTargetA", szTips)
	self.pPanel:SetActive("BtnRemind", not bAssigned and not bReported)
	self.pPanel:SetActive("BtnCheckA", not not (bAssigned or bReported))
	local bCanReport = not not (bAssigned and not bReported)
	self.pPanel:Button_SetEnabled("BtnReportCustom", bCanReport)
	self.pPanel:Button_SetText("BtnReportCustom", bReported and "已上交" or "上交任务")
	TeacherStudent:HideReportRedpoint()

	local tbInfo = {}
	tbInfo.nStudentLv = me.nLevel
	tbInfo.tbAssigned = tbOtherStatusInfo.tbCustomTasks.tbTasks
	local tbSortedTasks = TeacherStudent:CustomTaskGetValidSortedTasks(tbInfo)
	local nRow = #tbSortedTasks
	self.ScrollViewA:Update(nRow, function(pGrid, nIdx)
		local nTaskId = tbSortedTasks[nIdx]
		local tbSetting = TeacherStudent:GetCustomTargetSetting(nTaskId)
		local bChecked = (tbOtherStatusInfo.tbCustomTasks.tbTasks or {})[nTaskId]
		pGrid.pPanel:Button_SetSprite("Main", bChecked and "BtnListThirdPress" or "BtnListThirdNormal", 1)
		local nCur = bChecked and tbOtherStatusInfo.tbCustomTasks.tbTasks[nTaskId] or 0
		if bAssigned then
			if bChecked then
				local szColor = nCur>=tbSetting.nNeed and "00FF00" or "FFFFFF"
				pGrid.pPanel:Label_SetText("Task", string.format("[%s]%s[-]", szColor, tbSetting.szDesc))
				pGrid.pPanel:Label_SetText("Num", string.format("[%s]%d/%d[-]", szColor, nCur, tbSetting.nNeed))
			else
				local szColor = "C8C8C8"
				pGrid.pPanel:Label_SetText("Task", string.format("[%s]%s[-]", szColor, tbSetting.szDesc))
				pGrid.pPanel:Label_SetText("Num", string.format("[%s]--[-]", szColor))
			end
		else
			local szColor = "FFFFFF"
			pGrid.pPanel:Label_SetText("Task", string.format("[%s]%s[-]", szColor, tbSetting.szDesc))
			pGrid.pPanel:Label_SetText("Num", string.format("[%s]%d/%d[-]", szColor, 0, tbSetting.nNeed))
		end
	end)
end

function tbUI:RefreshGraduateStudentTip(bAssigned, tbOtherMainInfo, tbOtherStatusInfo)
	local szMsg = bAssigned and
		string.format("[92D2FF]已经给徒弟[c8ff00]%s[-]布置任务[-]", tbOtherMainInfo.szName) or
		string.format("[92D2FF]快给徒弟布置任务吧，已选择：[-]%d/%d", Lib:CountTB(self.tbSelectedTasks or {}), TeacherStudent.Def.nCustomTaskCount)
	if not bAssigned then
		if me.nLevel<=tbOtherMainInfo.nLevel then
			szMsg = "[92D2FF]只能给比自己等级低的徒弟布置任务[-]"
		end
		if not Lib:IsDiffWeek(GetTime(), tbOtherStatusInfo.tbCustomTasks.nLastAssignTime or 0, 0) then
			szMsg = string.format("[92D2FF]徒弟[c8ff00]%s[-]已上交你本周布置的任务[-]", tbOtherMainInfo.szName)
		end
	end
	self.pPanel:Label_SetText("TextTargetM", szMsg)
end

function tbUI:RefreshGraduateStudent(bHideGiveGift, tbOtherStatusInfo, tbOtherMainInfo)
	local nOtherId = self.nCurOtherId

	local bAssigned = next(tbOtherStatusInfo.tbCustomTasks.tbTasks or {})
	local bReported = not bAssigned and not Lib:IsDiffWeek(GetTime(), tbOtherStatusInfo.tbCustomTasks.nLastAssignTime or 0, 0)
	self.pPanel:SetActive("BtnCheckM", true)
	self:RefreshGraduateStudentTip(bAssigned, tbOtherMainInfo, tbOtherStatusInfo)
	self.pPanel:Button_SetText("BtnAssign", bAssigned and "已布置" or "布置任务")
	self.pPanel:Button_SetEnabled("BtnAssign", not bAssigned)

	if bAssigned then
		self.tbSelectedTasks = {}
		for nId, nProgress in pairs(tbOtherStatusInfo.tbCustomTasks.tbTasks) do
			self.tbSelectedTasks[nId] = nProgress
		end
	end

	local tbInfo = {}
	tbInfo.nStudentLv = tbOtherMainInfo.nLevel
	tbInfo.tbAssigned = self.tbSelectedTasks
	local tbSortedTasks = TeacherStudent:CustomTaskGetValidSortedTasks(tbInfo)
	local nGiftRow = bHideGiveGift and 0 or 1
	local nRow = nGiftRow+#tbSortedTasks
	self.ScrollViewM:Update(nRow, function(pGrid, nIdx)
		local bGift = nIdx<=nGiftRow
		pGrid.pPanel:SetActive("Btn", bGift)
		pGrid.pPanel:SetActive("Toggle", not bGift)
		if bGift then
			pGrid.pPanel:Label_SetText("Task", "给徒弟赠送额外的出师奖励")
			pGrid.pPanel:Label_SetText("Num", "0/1")
			pGrid.Btn.pPanel.OnTouchEvent = function()
				Ui:OpenWindow("TeacherGiftPanel", nOtherId)
			end
			pGrid.pPanel:Button_SetSprite("Main", "BtnListThirdOwn", 1)
			return
		end

		local nTaskId = tbSortedTasks[nIdx-nGiftRow]
		local tbSetting = TeacherStudent:GetCustomTargetSetting(nTaskId)
		local bChecked = (self.tbSelectedTasks or {})[nTaskId]
		pGrid.pPanel:Button_SetSprite("Main", bChecked and "BtnListThirdPress" or "BtnListThirdNormal", 1)
		local nCur = 0
		if tbOtherStatusInfo.tbCustomTasks.tbTasks and tbOtherStatusInfo.tbCustomTasks.tbTasks[nTaskId] then
			nCur = tbOtherStatusInfo.tbCustomTasks.tbTasks[nTaskId]
		end
		local szColor = nCur>=tbSetting.nNeed and "00FF00" or "FFFFFF"
		if bAssigned and not bChecked then
			szColor = "C8C8C8"
		end
		pGrid.pPanel:Label_SetText("Task", string.format("[%s]%s[-]", szColor, tbSetting.szDesc))
		pGrid.pPanel:Toggle_SetChecked("Toggle", bChecked)
		local szProgress = (not bAssigned or bChecked) and string.format("%d/%d", nCur, tbSetting.nNeed) or "--"
		pGrid.pPanel:Label_SetText("Num", string.format("[%s]%s[-]", szColor, szProgress))
		pGrid.pPanel:Toggle_SetEnale("Toggle", not bAssigned)
		pGrid.Toggle.pPanel.OnTouchEvent = function()
			self.tbSelectedTasks = self.tbSelectedTasks or {}
			self.tbSelectedTasks[nTaskId] = nil
			local bChecked = pGrid.pPanel:Toggle_GetChecked("Toggle")
			if bChecked then
				if bReported then
					pGrid.pPanel:Toggle_SetChecked("Toggle", false)
					me.CenterMsg("本周已布置过任务，请下周一再布置")
					return
				end
				self.tbSelectedTasks[nTaskId] = true
				if Lib:CountTB(self.tbSelectedTasks)>TeacherStudent.Def.nCustomTaskCount then
					self.tbSelectedTasks[nTaskId] = nil
					pGrid.pPanel:Toggle_SetChecked("Toggle", false)
					me.CenterMsg(string.format("只能挑选%d个布置给徒弟", TeacherStudent.Def.nCustomTaskCount))
					return
				end
			end
			pGrid.pPanel:Button_SetSprite("Main", bChecked and "BtnListThirdPress" or "BtnListThirdNormal", 1)
			self:RefreshGraduateStudentTip(bAssigned, tbOtherMainInfo, tbOtherStatusInfo)
		end
	end)
end

function tbUI:RefreshGraduate(tbOtherStatusInfo, bMyTeacher, tbOtherMainInfo)
	self.tbSelectedTasks = nil

	self.pPanel:SetActive("Condition", false)
	self.pPanel:SetActive("ConditionMaster", not bMyTeacher)
	self.pPanel:SetActive("ConditionApprentice", bMyTeacher)

	local bRewardSent = tbOtherStatusInfo.nRewardCount>0
	local bHideGiveGift = bRewardSent or bMyTeacher
	if bMyTeacher then
		self:RefreshGraduateTeacher(tbOtherMainInfo, tbOtherStatusInfo)
	else
		self:RefreshGraduateStudent(bHideGiveGift, tbOtherStatusInfo, tbOtherMainInfo)
	end
end

function tbUI:RefreshOtherStatus(nRefreshedId)
	if self.szTab~="MainInfo" then
		return
	end

	if nRefreshedId and nRefreshedId~=self.nCurOtherId then
		return
	end

	local nOtherId = self.nCurOtherId
	local tbOtherMainInfo = TeacherStudent:GetOtherMainInfo(nOtherId)
	if not tbOtherMainInfo then
		return
	end

	local tbOtherStatusInfo = TeacherStudent:GetOtherStatusInfo(nOtherId)
	if not tbOtherStatusInfo then
		return
	end

	local nConnectDays = Lib:SecondsToDays(GetTime()-tbOtherStatusInfo.nConnectTime)
	self.pPanel:Label_SetText("ApprenticeTime", string.format("于%s结为师徒%s", Lib:GetTimeStr3(tbOtherStatusInfo.nConnectTime),
		nConnectDays>0 and string.format("（已结为师徒%d天）", nConnectDays) or ""))
	self.pPanel:SetActive("ApprenticeTime", true)

	self.pPanel:SetActive("TipInformation", false)
	self:_RefreshTimeTip(nOtherId)

	local bMyTeacher = TeacherStudent:IsMyTeacher(nOtherId)
	if not tbOtherMainInfo.bGraduate then
		self:RefreshUnderGraduate(tbOtherStatusInfo, tbOtherMainInfo, nConnectDays, bMyTeacher)
	else
		self:RefreshGraduate(tbOtherStatusInfo, bMyTeacher, tbOtherMainInfo)
	end
	self.pPanel:SetActive("ConditionScrollView", true)
end

local tbStateDesc = {
	[TeacherStudent.Def.tbTargetStates.NotReport] = "[FFFE0D]可汇报[-]",
	[TeacherStudent.Def.tbTargetStates.Reported] = "[00FF00]已汇报[-]",
	[TeacherStudent.Def.tbTargetStates.FinishedBefore] = "[00FF00]拜师前达成[-]",
}
function tbUI:_GetStateDesc(nState)
	return tbStateDesc[nState] or ""
end

function tbUI:_SelectPlayer(nOtherId)
	self.nCurOtherId = nOtherId
	self:_ResetOtherStatusUI()
	self:RefreshOtherStatus()
end

function tbUI:RefreshMainInfo()
	if self.szTab~="MainInfo" then
		return
	end

	self:_MainInfoUIReset()
	local tbMainInfo = TeacherStudent:GetMainInfo()
	if not tbMainInfo then
		return
	end

	self:_MainInfoRefreshTeachers(tbMainInfo.tbTeachers)
	self:_MainInfoRefreshStudents(tbMainInfo.tbStudents)

	local nUndergraduateCount = TeacherStudent:GetUndergraduateCount()
	self.pPanel:Label_SetText("TextApprentice", string.format("[73cbd5]未出师徒弟：[-]%d/%d", nUndergraduateCount, TeacherStudent.Def.nMaxUndergraduate))

	self:_SetCurrentTabActive()

	if self.nCurOtherId and self.nCurOtherId>0 then
		self:_SelectPlayer(self.nCurOtherId)
	end
end

local tbTabCfg = {
	MainInfo = {"BtnInformation", "Information"},
	FindTeacher = {"BtnMaster", "FindMaster"},
	FindStudent = {"BtnApprentice", "FindApprentice"},
	ApplyList = {"BtnApply", "ApplyList"},
}
function tbUI:_SetCurrentTabActive()
	for szTab, tbInfo in pairs(tbTabCfg) do
		local bCurrent = self.szTab==szTab
		local szBtn, szPanel = unpack(tbInfo)
		self.pPanel:SetActive(szPanel, bCurrent)
		self.pPanel:Toggle_SetChecked(szBtn, bCurrent)
	end
end

function tbUI:InitHead(pGrid, tbData, bOffline)
	pGrid.pPanel:Label_SetText("lbLevel", tbData.nLevel)
	local szFactionIcon = Faction:GetIcon(tbData.nFaction)
	local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbData.nPortrait)
	pGrid.pPanel:Sprite_SetSprite("SpFaction", szFactionIcon)
	if bOffline then
		pGrid.pPanel:Sprite_SetSpriteGray("SpRoleHead",  szHead, szAtlas)
	else
		pGrid.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas)
	end
end
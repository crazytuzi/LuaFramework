local CTeamHandyBuildPage = class("CTeamHandyBuildPage", CPageBase)

function CTeamHandyBuildPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CTeamHandyBuildPage.OnInitPage(self)
	self.m_TargetBoxBtn = self:NewUI(1, CButton)
	self.m_CreateBtn = self:NewUI(2, CButton)
	self.m_AutoMatchBtn = self:NewUI(3, CButton)
	self.m_Refresh = self:NewUI(4, CButton)
	self.m_ApplyBox = self:NewUI(5, CTeamHandyApplyBox)
	self.m_ApplyGrid = self:NewUI(6, CGrid)
	self.m_TeamCntLabel = self:NewUI(7, CLabel)
	self.m_TargetLevelBtn = self:NewUI(8, CButton)
	self.m_FastTalkBtn = self:NewUI(9, CButton)
	self.m_TargetLabel = self:NewUI(10, CLabel)
	self.m_AutoMatchLabel = self:NewUI(11, CLabel)
	self.m_TargetLevelLabel = self:NewUI(12, CLabel)
	self.m_TargetFlagSprite = self:NewUI(13, CSprite)
	self.m_MemberCntLabel = self:NewUI(14, CLabel)
	self.m_TargetFlagSprite.TweenRotation = self.m_TargetFlagSprite:GetComponent(classtype.TweenRotation)
	self.m_TargetLevelFlagSprite = self:NewUI(15, CSprite)
	self.m_TargetLevelFlagSprite.TweenRotation = self.m_TargetLevelFlagSprite:GetComponent(classtype.TweenRotation)
	self.m_TeamTargetInfoBtn = self:NewUI(16, CButton)
	self.m_MinGrade = 0 
	self.m_MaxGrade = 0
	self.m_RefreshTargetTimer = nil
	self.m_SelectedTaskId = nil
	self.m_TeamApplyBoxList = {}
	self:InitContent()
end

function CTeamHandyBuildPage.InitContent(self)
	self.m_ApplyBox:SetActive(false)
	self.m_CreateBtn:AddUIEvent("click", callback(self, "OnCreateTeam"))
	self.m_FastTalkBtn:AddUIEvent("click", callback(self, "OnFastTalk"))
	self.m_TargetLevelBtn:AddUIEvent("click", callback(self, "OnTargetLevel"))
	self.m_Refresh:AddUIEvent("click", callback(self, "OnRefreshTeam"))
	self.m_AutoMatchBtn:AddUIEvent("click", callback(self, "OnAutoMatch"))
	self.m_TargetBoxBtn:AddUIEvent("click", callback(self, "OnOpenTarget"))
	self.m_TeamTargetInfoBtn:AddUIEvent("click", callback(self, "OnClickTeamTargetInfo"))	

	g_GuideCtrl:AddGuideUI("teamhandybuild_target_btn", self.m_TargetBoxBtn)
	local guide_ui = {"teamhandybuild_target_btn"}
	g_GuideCtrl:LoadTipsGuideEffect(guide_ui)	
	g_GuideCtrl:FinishTeamHandyBuildTipsStep(3)
	g_TeamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrTeamlEvent"))
end

function CTeamHandyBuildPage.ShowPage(self, taskId)
	CPageBase.ShowPage(self)

	local isJoTeam = g_TeamCtrl:IsJoinTeam()
	local isPlayerAutoMatch = g_TeamCtrl:IsPlayerAutoMatch()
	local isTeamAutoMatch = g_TeamCtrl:IsTeamAutoMatch()
	--如果打开时，传入指定目标
	if taskId ~= nil then
		self:RefreshAutoMatch({auto_target = taskId})
		
	--如果当前在组队
	elseif isJoTeam  then 
		local targetInfo = g_TeamCtrl:GetTeamTargetInfo()
		self:RefreshAutoMatch(targetInfo)

	--如果当前玩家未组队，切在自动匹配
	elseif isPlayerAutoMatch then
		local targetInfo = g_TeamCtrl:GetPlayerTargetInfo()
		self:RefreshAutoMatch(targetInfo)

	--默认显示全部任务
	else
		self:RefreshAutoMatch()
	end
	self:OnRefreshTeam(self.m_Refresh, true)
	self:RefreshAll()
end

function CTeamHandyBuildPage.RefreshAll(self)
	self:RefreshButtonState()
	self:RefreshCountLabel()
	self:RefreshHandyApply()
end

function CTeamHandyBuildPage.OnCtrTeamlEvent(self, oCtrl)
	local bIsJoinTeam = g_TeamCtrl:IsJoinTeam()
	local bIsPlayerAutoMatch = g_TeamCtrl:IsPlayerAutoMatch()

	if oCtrl.m_EventID == define.Team.Event.AddTargetTeam then
		self:RefreshHandyApply()

	elseif oCtrl.m_EventID == define.Team.Event.AddTeam then
		if bIsJoinTeam then
			self:OnRefreshTeam(self.m_Refresh, true)
		end
		self:RefreshButtonState()

	elseif oCtrl.m_EventID == define.Team.Event.DelTeam then
		if not bIsJoinTeam then
			self:OnRefreshTeam(self.m_Refresh, true)
		end
		self:RefreshButtonState()

	elseif oCtrl.m_EventID == define.Team.Event.NotifyAutoMatch then
		self:OnRefreshTeam(self.m_Refresh, true)
		self:RefreshButtonState()

	elseif oCtrl.m_EventID == define.Team.Event.NotifyCountAutoMatch then
		self:RefreshCountLabel()
	end
end

function CTeamHandyBuildPage.RefreshAutoMatch(self, targetInfo)
	if targetInfo == nil then
		targetInfo = {}
		targetInfo.auto_target = CTeamCtrl.TARGET_NONE
		targetInfo.min_grade, targetInfo.max_grade = g_TeamCtrl:GetTeamTargetDefaultLevel(CTeamCtrl.TARGET_NONE)
	end
	self.m_SelectedTaskId = targetInfo.auto_target
	local tData = data.teamdata.AUTO_TEAM[self.m_SelectedTaskId]
	if tData then
		self.m_TargetLabel:SetText(tData.title_name)		
	end
	if targetInfo.min_grade and targetInfo.max_grade then
		self.m_MinGrade = targetInfo.min_grade
		self.m_MaxGrade	 = targetInfo.max_grade
		self:SetLevelButtonText(self.m_MinGrade, self.m_MaxGrade)
	end
end

function CTeamHandyBuildPage.RefreshButtonState(self)
	local isJoTeam = g_TeamCtrl:IsJoinTeam()
	local isLeaer = g_TeamCtrl:IsLeader()
	self.m_CreateBtn:SetActive(not isJoTeam)
	self.m_FastTalkBtn:SetActive(isJoTeam and isLeaer)
	self.m_AutoMatchBtn:SetActive(true)
	self.m_TargetLevelBtn:SetActive(true)
	self.m_TeamTargetInfoBtn:SetLocalPos(Vector3.New(162, 1.5, 0))
	if isJoTeam then
		if isLeaer then					
			if g_TeamCtrl:IsTeamAutoMatch() and g_TeamCtrl:GetTeamTargetInfo().auto_target == g_TeamCtrl:ConverTargetId(self.m_SelectedTaskId) then
				self.m_AutoMatchBtn:SetText("取消匹配")			
			else
				self.m_AutoMatchBtn:SetText("自动匹配")
			end
		else
			self.m_AutoMatchBtn:SetActive(false)
			self.m_TargetLevelBtn:SetActive(false)
			self.m_TeamTargetInfoBtn:SetLocalPos(Vector3.New(-77, 1.5, 0))
		end
	else	
		if g_TeamCtrl:IsPlayerAutoMatch() and 
			g_TeamCtrl:GetPlayerAutoTarget() == g_TeamCtrl:ConverTargetId(self.m_SelectedTaskId) then
			self.m_AutoMatchBtn:SetText("取消匹配")
		else
			self.m_AutoMatchBtn:SetText("自动匹配")
		end	
	end
end

function CTeamHandyBuildPage.RefreshCountLabel(self)
	local iTeamCount = 0
	local iMemberCount = 0
	local dCountInfo = g_TeamCtrl:GetCountAutoMatch(self.m_SelectedTaskId)
	if dCountInfo then
		iTeamCount = dCountInfo.team_count
		iMemberCount = dCountInfo.member_count
	end
	self.m_TeamCntLabel:SetText(string.format("%d", iTeamCount))
	self.m_MemberCntLabel:SetText(string.format("%d", iMemberCount))
end

function CTeamHandyBuildPage.RefreshHandyApply(self)
	local lTeam = g_TeamCtrl:GetTargetTeamList(self.m_SelectedTaskId)
	for i, dTeam in ipairs(lTeam) do
		local oBox = self.m_TeamApplyBoxList[i]
		if not oBox then
			oBox = self:AddHandyApplyBox()
		end
		oBox:SetActive(true)
		oBox:SetHandyApply(dTeam)
	end

	if #lTeam < #self.m_TeamApplyBoxList then
		for i = #lTeam + 1, #self.m_TeamApplyBoxList do
			local oBox = self.m_TeamApplyBoxList[i]
			if oBox then
				oBox:SetActive(false)
			end
		end
	end
end

function CTeamHandyBuildPage.AddHandyApplyBox(self)
	local oBox = self.m_ApplyBox:Clone(self.m_ParentView)
	self.m_ApplyGrid:AddChild(oBox)
	table.insert(self.m_TeamApplyBoxList, oBox)
	return oBox
end

function CTeamHandyBuildPage.OnCreateTeam(self )
	if self.m_SelectedTaskId == CTeamCtrl.TARGET_NONE then
		g_NotifyCtrl:FloatMsg("请选择具体的组队目标创建队伍")
	else
		g_TeamCtrl:C2GSCreateTeam(self.m_SelectedTaskId, self.m_MinGrade, self.m_MaxGrade)
	end
end

function CTeamHandyBuildPage.OnRefreshTeam(self, oBox, bForceRefresh )
	if bForceRefresh then
		self:StartAutoUpdateTeamInfo()
	else
		if g_TeamCtrl:CanRefreshTeamTarget() then
			self:StartAutoUpdateTeamInfo()
		end
	end
end

function CTeamHandyBuildPage.OnAutoMatch(self )
	local taskId = g_TeamCtrl:ConverTargetId(self.m_SelectedTaskId)
	if g_TeamCtrl:IsJoinTeam() then
		if g_TeamCtrl:IsLeader() then
			local targetInfo = g_TeamCtrl:GetTeamTargetInfo()
			if taskId ~= g_TeamCtrl.TARGET_NONE then
				if g_TeamCtrl:IsTeamAutoMatch() then
					--如果当前匹配的目标和选中的目标一样，则取消匹配，否则更换匹配目标

					if targetInfo.auto_target == taskId then
						g_TeamCtrl:C2GSTeamAutoMatch(taskId, self.m_MinGrade, self.m_MaxGrade, 0)
					else
						-- local d  = data.teamdata.AUTO_TEAM[self.m_SelectedTaskId]
						-- if d and d.is_parent ~= 0 then
						-- 	if d.select_target_tips and d.select_target_tips ~= "" then
						-- 		g_NotifyCtrl:FloatMsg(d.select_target_tips)
						-- 	end	
						-- 	return
						-- end						
						g_TeamCtrl:C2GSTeamAutoMatch(taskId, self.m_MinGrade, self.m_MaxGrade, 1)
					end				
				else

					-- local d  = data.teamdata.AUTO_TEAM[self.m_SelectedTaskId]
					-- if d and d.is_parent ~= 0 then
					-- 	if d.select_target_tips and d.select_target_tips ~= "" then
					-- 		g_NotifyCtrl:FloatMsg(d.select_target_tips)
					-- 	end	
					-- 	return
					-- end

					--开始队长匹配	
					if g_TeamCtrl:CanAutoMatchTeam(taskId, self.m_MinGrade, self.m_MaxGrade) then
						g_TeamCtrl:C2GSTeamAutoMatch(taskId, self.m_MinGrade, self.m_MaxGrade, 1)
					end
				end
			else
				g_NotifyCtrl:FloatMsg("选择具体的匹配目标才能开始匹配哦")
			end
		end
	else	
		if taskId ~= g_TeamCtrl.TARGET_NONE then

			if g_TeamCtrl:IsPlayerAutoMatch() and g_TeamCtrl:GetPlayerAutoTarget() == taskId then
				g_TeamCtrl:C2GSPlayerCancelAutoMatch()				
			else
				g_TeamCtrl:C2GSPlayerAutoMatch(taskId, self.m_MinGrade, self.m_MaxGrade)							
			end
		else
			g_NotifyCtrl:FloatMsg("选择具体的匹配目标才能开始匹配哦")
		end
	end
end

function CTeamHandyBuildPage.OnFastTalk(self )
	if self.m_SelectedTaskId == g_TeamCtrl.TARGET_NONE then
		g_NotifyCtrl:FloatMsg("请先调整目标")
		return
	end
	if g_TeamCtrl:CanFastTalk() then
		local tData = data.teamdata.AUTO_TEAM[self.m_SelectedTaskId]
		local iMatchCount = tData.match_count
		local sTeamCount  = string.format("(%d/%d)", g_TeamCtrl:GetMemberSize(), iMatchCount)		
		local sTarget = string.format("%s 等级%d 组队目标:%s(等级%d~%d级) %s", g_AttrCtrl.name, g_AttrCtrl.grade, tData.name, self.m_MinGrade, self.m_MaxGrade, sTeamCount)		
		local filterLink = LinkTools.GenerateGetTeamFilterLink(self.m_MinGrade, self.m_MaxGrade)
		local targetLink = LinkTools.GenerateGetTeamInfoLink(g_TeamCtrl.m_TeamID, sTarget)
		local applyLink = LinkTools.GenerateApplyTeamLink(g_TeamCtrl.m_LeaderID)
		local msg = filterLink..targetLink..applyLink
		local extraargs = 1 --一键喊话额外参数
		g_ChatCtrl:SendMsg(msg, define.Channel.Team, extraargs)
		g_ChatCtrl:SendMsg(msg, define.Channel.Team)
		g_NotifyCtrl:FloatMsg("成功发布组队信息，请耐心等待队员加入")
		self.m_ParentView:CloseView()
	end
end

function CTeamHandyBuildPage.OnOpenTarget(self)
	g_GuideCtrl:ReqTipsGuideFinish("teamhandybuild_target_btn")
	g_WindowTipCtrl:SetWindowTeamTarget(
	 	{
	 	  valueCallback = callback(self, "OnTargetChange"),
	 	  closeCallback = callback(self, "OnTargetChangeEnd"),
	 	  taskId = self.m_SelectedTaskId,
	 	},
	 	{ widget = self.m_TargetBoxBtn, side = enum.UIAnchor.Side.Bottom, offset = Vector2.New(5, -5)}
	 )
end

function CTeamHandyBuildPage.OnTargetLevel(self )
	g_WindowTipCtrl:SetWindowTeamLevel(	
		{	
			iTaskId = self.m_SelectedTaskId,
			iMaxGrade = self.m_MaxGrade,
		    iMinGrade = self.m_MinGrade,
		    valueCallback = callback(self, "OnLevelChange"),
		    okCallback =  callback(self, "OnLeveOk")
		},
		{ widget = self.m_TargetLevelBtn, side = enum.UIAnchor.Side.Bottom, offset = Vector2.New(5, -25)}
	)
	self.m_TargetLevelFlagSprite.TweenRotation:Toggle()
end

function CTeamHandyBuildPage.OnTargetChangeEnd(self )
	self.m_TargetFlagSprite.TweenRotation:Toggle()
end

function CTeamHandyBuildPage.OnTargetChange(self, taskId)
	--更换目标时，如果目标与当前目标相同则忽略
	--如果切换的目标，是父目标也忽略
	local tData = data.teamdata.AUTO_TEAM[taskId]
	if taskId ~= self.m_SelectedTaskId and tData and (tData.is_parent ~= 1 or tData.is_show == 1)then
		local changeTarget = {}
		local targetInfo = {}
		changeTarget.auto_target = taskId
		if g_TeamCtrl:IsJoinTeam() then
			targetInfo = g_TeamCtrl:GetTeamTargetInfo()
		else
			targetInfo = g_TeamCtrl:GetPlayerTargetInfo()
		end
		if taskId == targetInfo.auto_target then
			changeTarget.min_grade = targetInfo.min_grade
			changeTarget.max_grade = targetInfo.max_grade
		else
			local min, max = g_TeamCtrl:GetTeamTargetDefaultLevel(taskId)
			changeTarget.min_grade = min
			changeTarget.max_grade = max
		end		
		self:RefreshAutoMatch(changeTarget)
		self:OnRefreshTeam(self.m_Refresh, true)
	end
	self:RefreshButtonState()
end

function CTeamHandyBuildPage.OnLevelChange(self, iMin, iMax)
	self:SetLevelButtonText(iMin, iMax)
end

function CTeamHandyBuildPage.OnLeveOk(self, iMin, iMax)
	self.m_TargetLevelFlagSprite.TweenRotation:Toggle()
	if iMax < iMin then
		iMax, iMin = iMin, iMax
	end
	if g_TeamCtrl:IsJoinTeam() and g_TeamCtrl:IsLeader() then
		local taskId = g_TeamCtrl:GetTeamTargetInfo().auto_target
		if g_TeamCtrl:IsTeamAutoMatch() then	
			--如果目前在自动匹配，则更新更新自动匹配信息			
			g_TeamCtrl:C2GSTeamAutoMatch(taskId, iMin, iMax, 1)
		else
			--如果目前没有在自动匹配，则更新组队目标			
			g_TeamCtrl:C2GSSetTeamTarget(taskId, iMin, iMax)
		end
	else
		if g_TeamCtrl:IsPlayerAutoMatch() then		
			g_TeamCtrl:C2GSPlayerAutoMatch(self.m_SelectedTaskId, iMin, iMax)			
		end
	end
	self:SetLevelButtonText(iMin, iMax)
end

function CTeamHandyBuildPage.SetLevelButtonText(self, iMin, iMax )
	self.m_MinGrade = iMin
	self.m_MaxGrade = iMax
	local sMin = iMin < 10 and (" " .. tostring(iMin)) or tostring(iMin)
	local sMax = iMax < 10 and (" " .. tostring(iMax)) or tostring(iMax)
	self.m_TargetLevelLabel:SetText(string.format("等级:%d - %d", sMin, sMax)) 	
end

function CTeamHandyBuildPage.OnHidePage(self)
	self:StopAutoUpdateTeamInfo()
	CPageBase.OnHidePage(self)
end

function CTeamHandyBuildPage.StartAutoUpdateTeamInfo(self)
	local taskId = self.m_SelectedTaskId or CTeamCtrl.TARGET_NONE
	taskId = g_TeamCtrl:ConverTargetId(taskId)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSGetTargetTeamInfo"]) then
		netteam.C2GSGetTargetTeamInfo(taskId)	
	end
	if self.m_RefreshTargetTimer ~= nil then
		Utils.DelTimer(self.m_RefreshTargetTimer)
		self.m_RefreshTargetTimer = nil
	end
	if not g_TeamCtrl:IsJoinTeam() or g_TeamCtrl:IsLeader() then
		--self.m_RefreshTargetTimer = Utils.AddTimer(callback(self, "StartAutoUpdateTeamInfo"), 0, 5)	
	end
end

function CTeamHandyBuildPage.StopAutoUpdateTeamInfo(self)
	if self.m_RefreshTargetTimer ~= nil then
		Utils.DelTimer(self.m_RefreshTargetTimer)
		self.m_RefreshTargetTimer = nil
	end
end

function CTeamHandyBuildPage.OnClickTeamTargetInfo(self)
	CTeamFilterView:ShowView(function(oView)
		oView:SetLocalTargetInfo(self.m_SelectedTaskId, self.m_MinGrade, self.m_MaxGrade)
	end)
end

return CTeamHandyBuildPage
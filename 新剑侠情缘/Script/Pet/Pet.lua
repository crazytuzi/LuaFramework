function Pet:FollowMe(nNpcId)
	if not self:CanFollowMe(nNpcId) then
		me.CenterMsg("宠物当前状态不可执行此操作")
		return
	end
	RemoteServer.PetReq("FollowMe", nNpcId)
end

function Pet:StopFollowMe(nNpcId)
	if not self:CanStopFollowMe(nNpcId) then
		me.CenterMsg("宠物当前状态不可执行此操作")
		return
	end
	RemoteServer.PetReq("StopFollowMe", nNpcId)
end

function Pet:Play(nNpcId)
	if not self:CanFollowMe(nNpcId) then
		me.CenterMsg("宠物当前状态不可执行此操作")
		return
	end
	RemoteServer.PetReq("Play", nNpcId)
end

function Pet:OnFollow(nNpcId, nPlayerId)
	self.tbFollowing = self.tbFollowing or {}
	self.tbFollowing[nNpcId] = nPlayerId
end

function Pet:CanFollowMe(nNpcId)
	local nFollowId = self:GetFollowId(nNpcId)
	return nFollowId<=0
end

function Pet:CanStopFollowMe(nNpcId)
	local nFollowId = self:GetFollowId(nNpcId)
	return nFollowId==me.dwID
end

function Pet:GetFollowId(nNpcId)
	self.tbFollowing = self.tbFollowing or {}
	return self.tbFollowing[nNpcId] or 0
end

function Pet:Feed(nIdx)
	if not self:CheckFeedCount(me) then
		me.CenterMsg("今日喂食次数已达上限")
		return
	end

	local function fnReq()
		RemoteServer.PetReq("Feed", nIdx)
	end

	local nLastFeedIdx = me.GetUserValue(self.Def.SaveGrp, self.Def.SaveKeyFeedIdx)
    local pNpc = me.GetNpc()
    if not pNpc then
    	nLastFeedIdx = 0
    else
		local nOldBuffId = me.GetUserValue(self.Def.SaveGrp, self.Def.SaveKeyBuffId)
		local tbState = pNpc.GetSkillState(nOldBuffId)
		if not tbState or tbState.nEndFrame<=0 then
			nLastFeedIdx = 0
	    end
    end

	if nLastFeedIdx>nIdx then
		me.MsgBox("喂食后，[FFFE0D]低级的增益状态[-]将替换掉[FFFE0D]高级的增益状态[-]，确定吗？", {{"确定", fnReq}, {"取消"}})
	else
		fnReq()
	end
end

function Pet:ChangeName(nPetTemplateId, szNewName)
	local bOk, szErr = self:CheckNameAvailable(szNewName)
	if not bOk then
		me.CenterMsg(szErr)
		return
	end
	RemoteServer.PetReq("ChangeName", nPetTemplateId, szNewName)
end

function Pet:OpenFeedPanel(nPetTemplateId)
	RemoteServer.PetReq("OpenFeedPanel", nPetTemplateId)
end

function Pet:OnFeedResult(nBuffId, nLevel)
	local nOldBuffId = me.GetUserValue(self.Def.SaveGrp, self.Def.SaveKeyBuffId)
	local nOldBuffLvl = me.GetUserValue(self.Def.SaveGrp, self.Def.SaveKeyBuffLvl)

	local tbOldStateEffect = FightSkill:GetStateEffectBySkill(nOldBuffId, nOldBuffLvl) or {}
	local szOldBuffName = tbOldStateEffect.StateName or ""

	local tbNewStateEffect = FightSkill:GetStateEffectBySkill(nBuffId, nLevel) or {}
	local szNewBuffName = tbNewStateEffect.StateName or ""

	local szMsg = string.format("将当前[11adf6][url=openwnd:%s, BuffTip2, %d, %d][-]替换成新的[11adf6][url=openwnd:%s, BuffTip2, %d, %d][-]属性效果，替换吗？",
		szOldBuffName, nOldBuffId, nOldBuffLvl, szNewBuffName, nBuffId, nLevel)
	me.MsgBox(szMsg, {{"替换", function()
			RemoteServer.PetReq("OnFeedConfirm", true)
		end}, {"保留"}})

	UiNotify.OnNotify(UiNotify.emNOTIFY_PET_FEED_REFRESH)
end

function Pet:OnFeed()
	UiNotify.OnNotify(UiNotify.emNOTIFY_PET_FEED_REFRESH)
end

function Pet:OnChangeName(nPetTemplateId, szNewName)
	local tbUi = Ui.tbUi["PetFeedPanel"]
	if not tbUi or not tbUi.tbPets then
		return
	end
	for _, tb in ipairs(tbUi.tbPets) do
		if tb.nPetTemplateId==nPetTemplateId then
			tb.szName = szNewName
			break
		end
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_PET_FEED_REFRESH)
	me.CenterMsg("改名成功")
end
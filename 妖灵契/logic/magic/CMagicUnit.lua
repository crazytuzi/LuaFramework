CMagicUnit = class("CMagicUnit")

function CMagicUnit.ctor(self, id)
	self.m_ID = id
	self.m_MagicID = 1
	self.m_MagicIdx = 1
	self.m_Data = {} --atkobj, vicobjs 等数据
	self.m_CmdList = {} --执行播放技能指令列表
	self.m_ElapseTime = 0 --已执行时间
	self.m_PreLoadRes = {}
	self.m_PreLoadDone = false
	self.m_CurCmdIdx = 1
	self.m_HitCallback = nil
	self.m_EndCallback = nil
	self.m_Active = true
	self.m_Layer = nil
	self.m_RunEnv = nil
	self.m_HitInfos = {}
	self.m_SubActionListTime = nil
	self.m_Running = false
	self.m_AtkStopHit = true
	self.m_WaitGoback = true
	self.m_LastHitInfoIndex = nil
	self.m_ControlObjs = {} --取得控制的对象
	self.m_IsEndIdx = false
	self.m_IsFirstIdx = false
end

function CMagicUnit.SetDataValue(self, k, v)
	self.m_Data[k] = v
end

function CMagicUnit.SetIsEndIdx(self, bEnd)
	self.m_IsEndIdx = bEnd
end

function CMagicUnit.SetIsFirstIdx(self, bFirst)
	self.m_IsFirstIdx = bFirst
end

function CMagicUnit.ControlNextObject(self, sName)
	self.m_NextObjectName = sName
end

function CMagicUnit.NewMagicCmd(self, funcname, starttime, args)
	if self.m_RunEnv == "war" then
		return CWarMagicCmd.New(funcname, starttime, args, self)
	elseif self.m_RunEnv == "createrole" then
		return CCreateRoleMagicCmd.New(funcname, starttime, args, self)
	elseif self.m_RunEnv == "dialogueani" then
		return CDialogueAniMagicCmd.New(funcname, starttime, args, self)
	end
end

function CMagicUnit.Start(self, oCmd)
	self.m_Running = true
	print("法术开始:", self.m_MagicID, self.m_MagicIdx, self.m_ID)
	local oAtkObj = self:GetAtkObj()
	if oAtkObj then
		oAtkObj:SetPlayMagicID(self.m_MagicID)
	end
	if oCmd and self.m_LastHitInfoIndex then
		for i, oWarrior in ipairs(self:GetVicObjs()) do
			local dVary = oCmd:GetWarriorVary(oWarrior.m_ID)
			oCmd:LockVary(dVary, true)
			if dVary.protect_id then
				local dProtectVary = oCmd:GetWarriorVary(oWarrior.m_ID)
				if dProtectVary then
					oCmd:LockVary(dProtectVary, true)
				end
			end
			oWarrior:SetPlayMagicID(self.m_MagicID)
		end
	end
	self:PreLoadRes()
	if self.m_StartCallback then
		self.m_StartCallback(self)
	end
end

function CMagicUnit.IsRunning(self)
	return self.m_Running
end

function CMagicUnit.SetSubActionListTime(self, time)
	self.m_SubActionListTime = time
end

function CMagicUnit.GetSubActionListTime(self)
	return self.m_SubActionListTime
end

function CMagicUnit.GetEvalEnv(self)
	return {
		slv = 5,
	}
end

function CMagicUnit.SetMagicIDAndIdx(self, id, idx)
	self.m_MagicID = id
	self.m_MagicIdx = idx
end


function CMagicUnit.BuildCmds(self, dFile)
	self.m_CmdList = {}
	for i, dCmdData in ipairs(dFile.cmds) do
		local oCmd = self:NewMagicCmd(dCmdData.func_name, dCmdData.start_time, dCmdData.args)
		self:InsertCmd(i, oCmd)
	end
end

function CMagicUnit.InsertCmd(self, idx, oCmd)
	if oCmd.m_FuncName == "VicHitInfo" then
		if self.m_LastHitInfoIndex == nil or idx > self.m_LastHitInfoIndex then
			self.m_LastHitInfoIndex = idx
		end
	end
	table.insert(self.m_CmdList, idx, oCmd)
end

function CMagicUnit.MergeGroupCmds(self, sGroupName)
	if not sGroupName then
		return
	end
	local lGroupCmds = self.m_GroupCmds[sGroupName]
	if not lGroupCmds then
		print("不存在指令组", sGroupName)
		return
	end
	local iCmdLen = #self.m_CmdList
	local iCheckStart = self.m_CurCmdIdx + 1
	for i, dCmdData in ipairs(lGroupCmds) do
		for j = iCheckStart, iCmdLen do
			local cmd = self.m_CmdList[j]
			if cmd.m_StartTime >= dCmdData.start_time then
				local oCmd = self:NewMagicCmd(dCmdData.func_name, dCmdData.start_time, dCmdData.args)
				self:InsertCmd(j, oCmd)
				if self.m_LastHitInfoIndex and j <= self.m_LastHitInfoIndex then
					self.m_LastHitInfoIndex = self.m_LastHitInfoIndex + 1
				end
				iCmdLen = iCmdLen + 1
				iCheckStart = j + 1
				break
			else
				iCheckStart = j
			end
		end
	end
	print("MergeGroupCmds:", sGroupName)
end

function CMagicUnit.InsertGroupCmds(self, iStartTime, lGroupNames)
	if not lGroupNames or next(lGroupNames) == nil then
		return
	end
	local iDuration = 0
	local iInsertIdx = self.m_CurCmdIdx + 1
	for _, sGroup in ipairs(lGroupNames) do
		local lGroupCmds = self.m_GroupCmds[sGroup]
		if lGroupCmds then
			local iSubDuration = 0
			local bRefreshSubDuration = true
			for _, dCmdData in ipairs(lGroupCmds) do
				if dCmdData.func_name == "GroupTime" then
					iSubDuration = dCmdData.args.duration
					bRefreshSubDuration = false
				else
					local oCmd = self:NewMagicCmd(dCmdData.func_name, iStartTime+iDuration+dCmdData.start_time, dCmdData.args)
					self:InsertCmd(iInsertIdx, oCmd)
					if self.m_LastHitInfoIndex and iInsertIdx <= self.m_LastHitInfoIndex then
						self.m_LastHitInfoIndex = self.m_LastHitInfoIndex + 1
					end
					iInsertIdx = iInsertIdx + 1
					if bRefreshSubDuration and iSubDuration < dCmdData.start_time then
						iSubDuration = dCmdData.start_time
					end
				end
			end
			iDuration = iDuration + iSubDuration
		end
	end
	printc("InsertGroupCmds-->", lGroupNames[1], iStartTime, self.m_CurCmdIdx, iDuration)
	--改变组指令之后的指令时间
	local iLen = #self.m_CmdList
	for i= iInsertIdx, iLen do
		local oCmd = self.m_CmdList[i]
		oCmd.m_StartTime = oCmd.m_StartTime + iDuration
	end
end

function CMagicUnit.SetHitCallback(self, callback)
	self.m_HitCallback = callback
end

function CMagicUnit.SetStartCallback(self, callback)
	self.m_StartCallback = callback
end

function CMagicUnit.SetEndCallback(self, callback)
	self.m_EndCallback = callback
end

function CMagicUnit.SetLayer(self, layer)
	self.m_Layer = layer
end

function CMagicUnit.GetLayer(self, sLayer)
	if sLayer == "bottom" then
		return define.Layer.MapTerrain
	elseif sLayer == "top" then
		return define.Layer.Magic
	else
		return self.m_Layer
	end

end

function CMagicUnit.SetRequiredData(self, d)
	self.m_Data = d
end


function CMagicUnit.GetAtkObj(self)
	return getrefobj(self.m_Data.refAtkObj)
end

function CMagicUnit.GetVicObjs(self)
	local list = {}
	for i, refObj in ipairs(self.m_Data.refVicObjs) do
		local oWarrior = getrefobj(refObj)
		if oWarrior then
			table.insert(list, oWarrior)
		end
	end
	return list
end

function CMagicUnit.GetVicObjFirst(self)
	for i, refObj in ipairs(self.m_Data.refVicObjs) do
		local oWarrior = getrefobj(refObj)
		if oWarrior then
			return oWarrior
		end
	end
end

function CMagicUnit.GetTargets(self, bAlly, bAtk, bVic, bAlive)
	local oAtkObj = self:GetAtkObj()
	local oVicObjs = self:GetVicObjs()
	local lTargets = {}
	for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		local bValid = false
		if bAlly then
			bValid = oWarrior.m_CampID == oAtkObj.m_CampID
		else
			bValid = oWarrior.m_CampID ~= oAtkObj.m_CampID
		end
		if bValid then
			if not bAtk then
				bValid= oWarrior.m_ID ~= oAtkObj.m_ID
			end
			if bValid then
				if not bVic then
					for i, oVic in ipairs(oVicObjs) do
						if oVic.m_ID == oWarrior.m_ID then
							bValid = false
							break
						end
					end
				end
				if bValid then
					if bAlive == nil or oWarrior:IsAlive() == bAlive then
						table.insert(lTargets, oWarrior)
					end
				end
			end
		end
	end
	return lTargets
end

function CMagicUnit.SetActive(self, b)
	self.m_Active = b
end

function CMagicUnit.IsActive(self)
	return self.m_Active
end

function CMagicUnit.PreLoadRes(self)
	if self.m_PreLoadRes then
		local reslist = {}
		for i, path in ipairs(self.m_PreLoadRes) do
			if g_ResCtrl:IsExist(path) then
				g_ResCtrl:LoadCloneAsync(path, callback(self, "OnLoadOne", path), true)
				table.insert(reslist, path)
			end
		end
		self.m_PreLoadRes = reslist
	end
end

function CMagicUnit.CheckPreLoad(self)
	if not self.m_PreLoadDone then
		if (not self.m_PreLoadRes or next(self.m_PreLoadRes) == nil) then
			self.m_PreLoadDone = true
		end
	end
end

function CMagicUnit.OnLoadOne(self, path, oClone)
	if oClone then
		g_ResCtrl:PutCloneInCache(path, oClone)
	end
	local idx = table.index(self.m_PreLoadRes, path)
	if idx then
		table.remove(self.m_PreLoadRes, idx)
	end
end

function CMagicUnit.ParseFileDict(self, dFile)
	self.m_RunEnv = dFile.run_env
	self.m_PreLoadRes = dFile.pre_load_res
	self.m_GroupCmds = dFile.group_cmds or {}
	self.m_AtkStopHit = dFile.atk_stophit
	self.m_WaitGoback = dFile.wait_goback
	self.m_LastHitInfoIndex = dFile.last_hitinfo_idx
	self:BuildCmds(dFile)
end
 
function CMagicUnit.Wait(self, func, ...)
	local t = {func, {...}, select("#", ...)}
	
	self.m_WaitFunc = function()
		local func, args, arglen = unpack(t, 1, 3)
		local ret = func(unpack(args, 1, arglen))
		return ret
	end
end

function CMagicUnit.IsWait(self)
	if self.m_WaitFunc then
		if self.m_WaitFunc() == true then
			self.m_WaitFunc = nil
			return false
		else
			return true
		end
	else
		return false
	end
end

function CMagicUnit.CombHit(self)
	for i, v in ipairs(self:GetVicObjs()) do
		v.m_Actor:Play("hit")
	end
end

function CMagicUnit.AddHitInfo(self, iHitTime, iHurtDelta, bFaceAtk, bAnim, bDamageFollow, bConsiderHight)
	local atkObj = self:GetAtkObj()
	local vicObjs = self:GetVicObjs()
	bFaceAtk = bFaceAtk == nil and true or bFaceAtk
	local dInfo = {
		cmd_idx=self.m_CurCmdIdx, 
		iHitTime=iHitTime, 
		iHurtDelta=iHurtDelta, 
		atkObj=atkObj, 
		vicObjs=vicObjs, 
		face_atk = bFaceAtk, 
		play_anim = bAnim, 
		damage_follow = bDamageFollow, 
		consider_hight = bConsiderHight
	}
	self.m_HitInfos[iHitTime] = dInfo
end

function CMagicUnit.Update(self, dt)
	if not self:IsRunning() then
		-- print("Not Running", self.m_ID)
		return
	end
	self:CheckPreLoad()
	if not self.m_PreLoadDone then
		return
	end
	if self:IsWait() then
		return
	end
	self.m_ElapseTime = self.m_ElapseTime + dt
	if self.m_SubActionListTime and self.m_ElapseTime >= self.m_SubActionListTime then
		self.m_SubActionListTime = nil
		g_WarCtrl:MoveActionListMainToSub()
	end
	if next(self.m_HitInfos) and self.m_HitCallback then
		for k, hitinfo in pairs(self.m_HitInfos) do
			if self.m_ElapseTime >= hitinfo.iHitTime then
				local bLastHit = (self.m_LastHitInfoIndex == nil) and false or (self.m_LastHitInfoIndex==hitinfo.cmd_idx)
				self.m_HitCallback(self, hitinfo, bLastHit)
				self.m_HitInfos[k] = nil
			end
		end
	else
		self.m_HitInfos = {}
	end
	
	local iLen = #self.m_CmdList
	if self.m_CurCmdIdx <= iLen then
		for i = self.m_CurCmdIdx, iLen do
			local oCmd = self.m_CmdList[i]
			if oCmd and self.m_ElapseTime >= oCmd.m_StartTime then
				oCmd.m_Idx = self.m_CurCmdIdx
				local b, ret = xxpcall(oCmd.Excute, oCmd)
				if b and ret and self.m_NextObjectName  then
					self.m_ControlObjs[self.m_NextObjectName] = ret
					self.m_NextObjectName = nil
				end 
				self.m_CurCmdIdx = self.m_CurCmdIdx + 1
			else
				break
			end
		end
	elseif iLen > 0 then
		local list = {}
		for i, oCmd in ipairs(self.m_CmdList) do
			if not oCmd:IsCanRemove() then
				table.insert(list, oCmd)
			end
		end
		self.m_CmdList = list
	end
end

function CMagicUnit.End(self)
	local oAtkObj = self:GetAtkObj()
	if oAtkObj then
		oAtkObj:SetPlayMagicID(nil)
	end
	for i, oWarrior in pairs(self:GetVicObjs()) do
		if oWarrior:IsAlive() then
			if oWarrior:HasDontHitBuff() then
				oWarrior:CrossFade("idleWar", 0.1)
			end
		else
			oWarrior:Die()
		end
		oWarrior:SetPlayMagicID(nil)
	end
	self.m_SubActionListTime = nil
	self.m_IsEnd = true
	if self.m_EndCallback then
		self.m_EndCallback(self)
	end
end

function CMagicUnit.CheckClearVary(self, oCmd)
	for wid, dVary in pairs(oCmd.m_VaryInfo) do
		if not dVary.lock then
			oCmd:ClearWarriorVary(wid, dVary)
		end
	end
	if oCmd.m_SummonWids then
		for i, wid in ipairs(oCmd.m_SummonWids) do
			local oWarrior = g_WarCtrl:GetWarrior(wid)
			if oWarrior then
				oWarrior:ShowWarrior()
			end
		end
		oCmd.m_SummonWids = nil
	end
end

function CMagicUnit.GetDesc(self)
	return string.format("%s_%s_%s", self.m_MagicID, self.m_MagicIdx, self.m_ID)
end

function CMagicUnit.IsGarbage(self)
	if not next(self.m_CmdList) and self.m_IsEnd and not next(self.m_HitInfos) then
		local obj = self:GetAtkObj()
		if not obj or not obj.m_Actor:IsComboing() then
			return true
		end
	end
	return false
end

function CMagicUnit.ClearUnit(self)
	for i, oCmd in ipairs(self.m_CmdList) do
		oCmd:ClearCmd()
	end
	self.m_CmdList = {}
end

return CMagicUnit
local CWarCmd = class("CWarCmd")

function CWarCmd.ctor(self, NameorFunc)
	self.m_ID = Utils.GetUniqueID()
	self.m_Func = NameorFunc
	self.m_IsUsed = false
	self.m_VaryInfo = {} --这回合状态的改变，只有部分cmd才能记录
	self.m_IsExcuteInSort = false
	self.m_SummonWids = nil
end

function CWarCmd.CheckAddWarriors(self)
	if self.m_AddWarriorCmds then
		for i, oCmd in ipairs(self.m_AddWarriorCmds) do
			local oWarrior = oCmd:Excute()
			oWarrior.m_IsSummon = true
			self:AddSummonWarrior(oWarrior)
		end
		self.m_AddWarriorCmds = nil
	end
end

function CWarCmd.AddWarriorCmd(self, oCmd)
	if not self.m_AddWarriorCmds then
		self.m_AddWarriorCmds = {}
	end
	table.insert(self.m_AddWarriorCmds, oCmd)
end

function CWarCmd.AddSummonWarrior(self, oWarrior)
	oWarrior:HideWarrior()
	if not self.m_SummonWids then
		self.m_SummonWids = {}
	end
	table.insert(self.m_SummonWids, oWarrior.m_ID)
end

function CWarCmd.EnableExcuteInSort(self)
	self.m_IsExcuteInSort = true
	g_WarCtrl:AppendWarCmdID(self.m_ID)
end

function CWarCmd.ProcessErrCmd(self)
	for k, v in pairs(self.m_VaryInfo) do
		self:ClearWarriorVary(k)
	end
	self.m_VaryInfo = {}
end

function CWarCmd.Excute(self)
	if Utils.IsEditor() then
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "IsCanMoveNext", true)
		if g_WarCtrl.m_IsTestMode then
			printc("NextStep")
			g_WarCtrl.m_NextStep = g_WarCtrl.m_NextStep - 1
			if g_WarCtrl.m_NextStep < 0 then
				g_WarCtrl.m_NextStep = 0
			end
			g_WarCtrl:OnEvent(define.War.Event.OnTestStep)
			-- table.print(self, "Excuting--------------->" .. self.m_Func)
		end
	end
	self:SetUsed(true)
	if self.m_IsExcuteInSort then
		g_WarCtrl:RemoveWarCmdID(self.m_ID)
	end
	if type(self.m_Func) == "function" then
		return self.m_Func()
	else
		local f = self[self.m_Func]
		if f then
			return f(self)
		else
			printerror("CWarCmd not funndFunc"..self.m_Func)
		end
	end
end


function CWarCmd.ClearWarriorVary(self, wid)
	local dVary = self.m_VaryInfo[wid]
	if dVary then 
		local lKeys = {"damage_list", "buff_list", "skill_list", "sp_list", "counterhurt_list"}
		for _, key in ipairs(lKeys) do
			local list = dVary[key]
			if list and next(list) then
				for i, oCmd in ipairs(list) do
					oCmd:Excute()
				end
			end
			dVary[key] = nil
		end

		local lKeys = {"del_cmd"}
		for _, key in ipairs(lKeys) do
			local oCmd = dVary[key]
			if key == "del_cmd" then
				if oCmd then
					oCmd:Excute()
				end
			end
			dVary[key] = nil
		end	

		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if oWarrior then 
			local lHP = dVary.hp_list
			if lHP and next(lHP) then
				dVary.hp_list = {lHP[#lHP]} --用最后的血量去刷新
				oWarrior:RefreshBlood(dVary)
			end
			if dVary.status then
				oWarrior:SetAlive(dVary.status == define.War.Status.Alive)
			end
			oWarrior:UpdateStatus(dVary)
		end
		dVary["hp_list"] = nil
	end
end

function CWarCmd.LockVary(self, dVary, bLock)
	dVary.lock = dVary
end

function CWarCmd.IsUsed(self)
	return self.m_IsUsed
end

function CWarCmd.SetUsed(self, b)
	self.m_IsUsed = b
end

function CWarCmd.SetVary(self, wid, k, v)
	local d = self.m_VaryInfo[wid]
	if not d then
		d = {}
	end
	d[k] = v
	self.m_VaryInfo[wid] = d
end

function CWarCmd.GetVary(self, wid, k)
	local d = self.m_VaryInfo[wid]
	if d then
		return d[k]
	end
end

function CWarCmd.GetWarriorVary(self, wid)
	return self.m_VaryInfo[wid] or {}
end

--help func
function CWarCmd.WaitOne(tOne, k, v, ...)
	if Utils.IsNil(tOne) then
		return true
	end
	local vv = tOne[k]
	if type(vv) == "function" then
		vv = vv(tOne, ...)
	end
	local b = table.equal(vv, v)
	WarTools.DebugWait(b, tOne, k, v, vv, ...)
	return b
end

function CWarCmd.WaitOneNotDebug(tOne, k, v, ...)
	if Utils.IsNil(tOne) then
		return true
	end
	local vv = tOne[k]
	if type(vv) == "function" then
		vv = vv(tOne, ...)
	end
	local b = table.equal(vv, v)
	return b
end

function CWarCmd.WaitAll(tAll, k, v)
	for _, tOne in pairs(tAll) do
		if not CWarCmd.WaitOne(tOne, k, v) then
			return false
		end
	end
	return true
end

function CWarCmd.InsertDelOrAlive(dVary, oWarrior, insertfunc)
	if dVary.del_cmd then
		local oCmd = dVary.del_cmd
		local delObj = g_WarCtrl:GetWarrior(oCmd.wid)
		if not delObj then
			return
		end
		if oCmd.type == 1 then
			insertfunc(CWarrior.FlyOut, delObj)
		elseif oCmd.type == 2 then
			insertfunc(CWarrior.DelAndDie, delObj)
		else
			insertfunc(CWarrior.Blink, delObj)
		end
		insertfunc(CWarCmd.WaitOne, delObj, "IsBusy", false)
		dVary.del_cmd = nil
	elseif dVary.status then
		local bAlive = dVary.status == define.War.Status.Alive
		insertfunc(CWarrior.SetAlive, oWarrior, bAlive)
		dVary.status = nil
	end
end

function CWarCmd.InsertAliveValue(dVary, oWarrior, insertfunc)
	if dVary.status then
		local bAlive = dVary.status == define.War.Status.Alive
		insertfunc(CWarrior.SetAlive, oWarrior, bAlive, true)
	end
end

function CWarCmd.GetWarResultFunc(cls, iWarType)
	local warType2Ctrl = {
		[define.War.Type.Pata] = g_PataCtrl,
		[define.War.Type.Arena] = g_EqualArenaCtrl,
		[define.War.Type.EqualArena] = g_EqualArenaCtrl,
		[define.War.Type.ClubArena] = g_ClubArenaCtrl,
		[define.War.Type.EquipFuben] = g_EquipFubenCtrl,
		[define.War.Type.AnLei] = g_AnLeiCtrl,
		[define.War.Type.EndlessPVE] = g_EndlessPVECtrl,
		[define.War.Type.Boss] = CWorldBossView,
		[define.War.Type.BossKing] = CWorldBossView,
		[define.War.Type.YjFuben] = g_ActivityCtrl:GetYJFbCtrl(),
		[define.War.Type.FieldBoss] = g_FieldBossCtrl,
		[define.War.Type.FieldBossPVP] = g_FieldBossCtrl,
		[define.War.Type.ChapterFuBen] = g_ChapterFuBenCtrl,
		[define.War.Type.TeamPvp] = g_TeamPvpCtrl,
		[define.War.Type.Convoy] = g_ConvoyCtrl,
		[define.War.Type.OrgWar] = g_OrgWarCtrl,
		[define.War.Type.Guide1] = g_ChapterFuBenCtrl,
		[define.War.Type.Guide2] = g_ChapterFuBenCtrl,
		[define.War.Type.Guide4] = g_ChapterFuBenCtrl,
		[define.War.Type.MonsterAtkCity] = g_MonsterAtkCityCtrl,
		[define.War.Type.PEFuben] = g_ActivityCtrl:GetPEFbCtrl(),
	}
	local warType2Func = {
		[define.War.Type.OrgBoss] = {g_OrgCtrl, "ShowOrgBossWarResult"},
		[define.War.Type.Lilian] = {g_ActivityCtrl, "ShowLilianWarResult"},
		[define.War.Type.DailyTrain] = {g_ActivityCtrl, "ShowDailyTrainWarResult"},
		[define.War.Type.Terrawar] = {g_TerrawarCtrl, "ShowTerraWarResult"},
	}
	if warType2Ctrl[iWarType] then
		return warType2Ctrl[iWarType], "ShowWarResult"
	elseif warType2Func[iWarType] then
		return warType2Func[iWarType][1], warType2Func[iWarType][2]
	end
end

function CWarCmd.WarResultView(oCmd)
	local iWarType = g_WarCtrl:GetWarType()
	printc("WarResultProcess", iWarType, oCmd.win)
	if oCmd.win == false then
		if g_AttrCtrl.grade >= 10 and not g_GuideCtrl:IsCustomGuideFinishByKey("Complete_War_Faild") then
			g_GuideCtrl:ReqCustomGuideFinish("Complete_War_Faild")				
		end
	end
	local oCtrl, funcName = CWarCmd:GetWarResultFunc(iWarType)
	if oCtrl then
		oCtrl[funcName](oCtrl, oCmd)
	else
		CWarResultView:ShowView(function(oView)
			oView:SetWarID(oCmd.war_id)
			oView:SetWin(oCmd.win)
		end)
	end

end
--cmd func
function CWarCmd.WarResultAnim(oCmd)
	local iTotalTime = 0
	local iTotalCnt = 0
	for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		if oWarrior:IsAlly() then
			if oCmd.win then
				if oWarrior:IsAlive() then
					local iTime = 0
					if oWarrior:IsPlayerModel() then
						oWarrior:CrossFade("win", 0.1)
						iTime = oWarrior.m_Actor:GetAnimClipInfo("win").length
					else
						oWarrior:CrossFade("show", 0.1)
						iTime = oWarrior.m_Actor:GetAnimClipInfo("show").length
					end
					 --超过4秒的动作，太长
					iTotalTime = iTotalTime + math.min(4, iTime)
					iTotalCnt = iTotalCnt + 1
				end
			end
		end
	end
	if iTotalTime > 0 then
		local iDelay = math.min(iTotalTime/iTotalCnt*0.7, 1)
		Utils.AddTimer(callback(oCmd, "WarResultView"), 0, iDelay)
	else
		oCmd:WarResultView()
	end
	
end

function CWarCmd.WaitAllFinish(oCmd)
	g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "IsAllExcuteFinish", true)
end

function CWarCmd.WarResult(oCmd)
	if not g_WarCtrl:IsWar() then
		return
	end
	if g_WarCtrl.m_IsInResult then
		return
	end
	g_WarCtrl:SetInResult(true)
	g_WarCtrl:UpdateTimeScale()
	g_WarTouchCtrl:SetLock(true)
	g_ViewCtrl:CloseAll(define.War.ExceptViews)
	for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		-- oWarrior.m_ShadowObj:SetActive(false)
		oWarrior:ClearBuff()
		oWarrior:ClearBindObjs()
		if oWarrior:IsAlly() then
			oWarrior:StopHit()
		else
			local c = oWarrior.m_Actor:GetMatColor()
			local oFadeAction = CActionColor.New(oWarrior.m_Actor, 0.5, "SetMatColor", Color.New(c.r, c.g, c.b, c.a * 0.5), Color.New(c.r, c.g, c.b, 0))
			local f = 
			oFadeAction:SetEndCallback(objcall(oWarrior, function(obj) 
						obj:HideWarrior()
				end))
			g_ActionCtrl:AddAction(oFadeAction)
		end
	end
	if g_WarCtrl.m_HeroWid then
		-- g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "IsAllGoBack", true)
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "IsAllExcuteFinish", true)
		g_WarCtrl:SimulateMagicCmd(define.Magic.SpcicalID.WarSimulate, 2, false, oCmd)
	else
		oCmd:WarResultAnim()
	end
	g_WarCtrl:InsertAction(CWarCmd.WaitOneNotDebug, g_WarCtrl, "m_IsInResult", false)

	g_GuideCtrl:StopWarReplaceGuide()
end

function CWarCmd.End(oCmd)
	WarTools.Print("CWarCmd.End")
	-- g_WarCtrl:End()
	-- g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "IsAllGoBack", true)
	g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "IsAllExcuteFinish", true)
	g_WarCtrl:InsertAction(g_WarCtrl.End, g_WarCtrl)
end

function CWarCmd.BoutStart(oCmd)
	g_WarCtrl:BoutStart(oCmd.bout_id)
end

function CWarCmd.BoutEnd(oCmd)
	g_WarCtrl:BoutEnd(oCmd.bout_id)
end

function CWarCmd.SectionStart(oCmd)
	g_WarTouchCtrl:SetLock(false)
	local oWarriorList = g_WarCtrl:GetWarriors()
	for k,oWarrior in pairs(oWarriorList) do
		oWarrior:SetOrderDone(true)
	end
	g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "IsAllExcuteFinish", true)
	g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "WaitSectionStart", true, oCmd)
end

function CWarCmd.AddWarrior(oCmd)
	local oWarrior = WarTools.CreateWarrior(oCmd.type, oCmd.camp_id, oCmd.info)
	if oWarrior:IsAlly() or g_WarCtrl:GetWarType() == define.War.Type.Arena 
		or g_WarCtrl:GetWarType() == define.War.Type.EqualArena 
		or g_WarCtrl:GetWarType() == define.War.Type.TeamPvp 
		or g_WarCtrl:GetWarType() == define.War.Type.PVP
		or g_WarCtrl:GetWarType() == define.War.Type.ClubArena then
		if not g_WarCtrl:IsInAction() then
			oWarrior:SetReady(false)
		end
	end
	g_WarCtrl:AddWarrior(oWarrior.m_ID, oWarrior)
	if oWarrior:IsAlly() and g_WarCtrl:IsPrepare() then
		local bReplace = oWarrior:IsCanReplace()
		if not bReplace and oWarrior.m_ID ~= g_WarCtrl.m_HeroWid then
			local c = oWarrior.m_Actor:GetMatColor()
			oWarrior:SetMatColor(Color.New(c.r * 0.5, c.g * 0.5, c.b * 0.5, c.a))
		end
	end
	return oWarrior
end

function CWarCmd.DelWarrior(oCmd)
	local list = {}
	local insert = WarTools.GetQuickInsertActionFunc(list)
	local delObj = g_WarCtrl:GetWarrior(oCmd.wid)
	if delObj then
		insert(CWarrior.FadeDel, delObj)
		insert(CWarCmd.WaitOne, delObj, "IsBusy", false)
		g_WarCtrl:AddSubActionList(list)
	end
end

function CWarCmd.Wave(oCmd)
	if oCmd.cur_wave > 1 then
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_MagicCtrl, "IsExcuteMagic", false)
	end
	g_WarCtrl:InsertAction(CWarCtrl.UpdateNewWaveTag, g_WarCtrl, true)
	g_WarCtrl:InsertAction(CWarCtrl.SetWave, g_WarCtrl, oCmd.cur_wave, oCmd.sum_wave)
end

function CWarCmd.GoBack(oCmd)
	local objs = {}
	local bMainAction = oCmd.wait and not g_WarCtrl.m_WaitSectionStart
	for i, wid in ipairs(oCmd.wid_list) do
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if oWarrior then
			local insert
			local list = {}
			if bMainAction then
				insert = function(...) g_WarCtrl:InsertAction(...) end
			else
				insert = WarTools.GetQuickInsertActionFunc(list)
			end
			insert(CWarCmd.WaitOne, oWarrior, "m_PlayMagicID", nil)
			insert(CWarCmd.WaitOne, oWarrior, "IsBusy", false)
			if oWarrior:IsAlive() and not oWarrior:IsNearOriPos(oWarrior:GetLocalPos()) and g_MagicCtrl:TryGetFile(define.Magic.SpcicalID.GoBack, oWarrior:GetShape()) then
				local requiredata = {
					refAtkObj = weakref(oWarrior), refVicObjs = {},
				}
				
				local oBackUnit = g_MagicCtrl:NewMagicUnit(define.Magic.SpcicalID.GoBack, oWarrior:GetShape(), requiredata)
				
				local function onEnd()
					if Utils.IsExist(oWarrior) then
						if not oWarrior:IsAlive() then
							oWarrior:Die()
						end
						oWarrior:SetBusy(false, "goback")
					end
				end
				oBackUnit:SetEndCallback(onEnd)
				insert(CMagicUnit.Start, oBackUnit)
				insert(CWarrior.SetBusy, oWarrior, true, "goback")
			else
				insert(CWarrior.GoBack, oWarrior)
			end
			if bMainAction then
				table.insert(objs, oWarrior)
			else
				g_WarCtrl:AddSubActionList(list)
			end
		end
	end
	if bMainAction then
		g_WarCtrl:InsertAction(CWarCmd.WaitAll, objs, "IsBusy", false)
	end
end


function CWarCmd.Buff(oCmd)
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		oWarrior:RefreshBuff(oCmd.buff_id, oCmd.bout, oCmd.level, oCmd.need_tips, oCmd.from_wid)
	end
end

function CWarCmd.WarriorStatus(oCmd)
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		if oCmd.status.status then
			local bAlive = oCmd.status.status == define.War.Status.Alive
			oWarrior:SetAlive(bAlive)
		end
		oWarrior:UpdateStatus(oCmd.status)
	end
end

function CWarCmd.Magic(oCmd)
	oCmd:CheckAddWarriors()
	local atkid = oCmd.atkid_list[1]
	local atkObj= g_WarCtrl:GetWarrior(atkid)
	if not atkObj then
		oCmd:ProcessErrCmd()
		print("atkObj is nil", oCmd.magic_id, oCmd.magic_index)
		return
	end
	local refAtkObj = weakref(atkObj)
	local refVicObjs = {}

	if #oCmd.vicid_list == 0 and oCmd.m_SummonWids then
		oCmd.vicid_list = oCmd.m_SummonWids
	end
	for i, id in ipairs(oCmd.vicid_list) do
		local oWarrior = g_WarCtrl:GetWarrior(id)
		if oWarrior then
			table.insert(refVicObjs, weakref(oWarrior))
		end
	end
	local requiredata = {
		refAtkObj = refAtkObj,
		refVicObjs = refVicObjs,
		refWarCmd = oCmd.ref_war_cmd or oCmd,
	}
	local oMagicUnit = g_MagicCtrl:NewMagicUnit(oCmd.magic_id, oCmd.magic_index, requiredata)
	print("CWarCmd.Magic", oMagicUnit:GetDesc())
	WarTools.TimeStart(oMagicUnit:GetDesc())
	oMagicUnit:SetLayer(UnityEngine.LayerMask.NameToLayer("War"))
	oMagicUnit:SetHitCallback(callback(oCmd, "MagicHitCallback"))
	if oCmd.start_func then
		oMagicUnit:SetStartCallback(oCmd.start_func)
	end
	oMagicUnit:SetEndCallback(	function() 
		g_WarCtrl:OnEvent(define.War.Event.CommandDone, atkid)
		if oCmd.end_func  then
			oCmd.end_func()
		end
	end)

	local oVic = oMagicUnit:GetVicObjFirst()
	local bWaitGoback = true
	local time

	local dMagicInfo = g_WarCtrl:GetBoutMagicInfo(oCmd.m_ID, 0)
	--下一个法术是保护的话, 则不提前法术执行时间
	if dMagicInfo and not dMagicInfo.is_next_protect then

		local lNextVics = g_WarCtrl:GetNextCmdVics(oCmd.m_ID)
		local lIntersect = {}
		-- table.print(oCmd.vicid_list, "当前指令受击者:")
		-- table.print(lNextVics, "下一指令受击者:")
		--群攻不被单体攻击连击
		if not (#oCmd.vicid_list > 1 and #lNextVics <= 1) then
			lIntersect = table.intersect(oCmd.vicid_list, lNextVics)
		end
		-- table.print(lIntersect, "受击者交集:")
		 -- 如果当前受击者不在下一次法术受击者列表中
		 -- 则表示这一次法术是这次浮空的结束
		
		if #lIntersect > 0 then
			for i, wid in ipairs(lIntersect) do
				local oWarrior = g_WarCtrl:GetWarrior(wid)
				if oWarrior then
					local bIsFloat = oWarrior:IsFloatAtkID(atkObj.m_ID)
					-- print("检测是否浮空", oMagicUnit:GetDesc(), wid, bIsFloat)
					-- table.print(oWarrior.m_FloatHitInfo, "受击者浮空信息")
					if bIsFloat then
						time = g_WarCtrl:GetNexCmdRunTime(wid, oCmd.m_ID)
						if time then 
							bWaitGoback = false
							print(oCmd.magic_id, "浮空移到子行动列表时间:", time, "攻击者:", atkid)
							oMagicUnit:SetSubActionListTime(time)
							break
						end
					end
				end
			end
		end
	end
	if oMagicUnit.m_AtkStopHit then
		g_WarCtrl:InsertAction(CWarrior.StopHit, atkObj)
	end
	
	if dMagicInfo then
		dMagicInfo.magic_unit_id = oMagicUnit.m_ID
		dMagicInfo.sub_time = time
		oMagicUnit:SetIsFirstIdx(dMagicInfo.is_first_idx==true)
		oMagicUnit:SetIsEndIdx(dMagicInfo.is_end_idx==true)
	end

	local dPreMagicInfo = g_WarCtrl:GetBoutMagicInfo(oCmd.m_ID, -1)
	if dPreMagicInfo then
		-- print("上一法术信息", dPreMagicInfo.maigic, dPreMagicInfo.sub_time)
		if not dPreMagicInfo.sub_time then
			if oMagicUnit.m_WaitGoback then
				print("等待归位", dPreMagicInfo.maigic)
				g_WarCtrl:InsertAction(CWarCmd.WaitAll, g_WarCtrl:GetWarriors(), "IsBusy", false)
			end
			local oPreUnit = g_MagicCtrl:GetMagicUnit(dPreMagicInfo.magic_unit_id)
			if dPreMagicInfo.is_end_idx and  not dPreMagicInfo.is_first_idx and oPreUnit then
				print(oCmd.magic_id, "等待前一法术播放完毕", oPreUnit:GetDesc(), oPreUnit:IsGarbage())
				g_WarCtrl:InsertAction(CWarCmd.WaitOne, oPreUnit, "IsGarbage", true)
			end
		end
	end
	g_WarCtrl:InsertAction(CMagicUnit.Start, oMagicUnit, oCmd)
	g_WarCtrl:InsertAction(CWarCmd.WaitOne, oMagicUnit, "m_IsEnd", true)
	if not oMagicUnit.m_LastHitInfoIndex or (not next(refVicObjs)) then
		g_WarCtrl:InsertAction(CMagicUnit.CheckClearVary, oMagicUnit, oCmd)
	end
	WarTools.TimeEnd(oMagicUnit:GetDesc())
	local oGobackCmd = oCmd:GetVary(atkid, "go_back")
	if oGobackCmd then
		oCmd:SetVary(atkid, "go_back", nil)
		if oMagicUnit.m_IsEndIdx then
			oGobackCmd.wait = bWaitGoback
			g_WarCtrl:InsertAction(CWarCmd.Excute, oGobackCmd)
			print("增加归位指令", oMagicUnit:GetDesc(), bWaitGoback, oGobackCmd.m_ID)
		else
			print("不处理归位指令", oMagicUnit:GetDesc())
		end
	end
end

function CWarCmd.MagicHitCallback(oCmd, oMagicUnit, dHitInfo, bLastHit)
	local atkObj = dHitInfo.atkObj
	local dAtkVary = oCmd:GetWarriorVary(atkObj.m_ID)
	for i, vicObj in ipairs(dHitInfo.vicObjs) do
		local list = {}
		local insert = WarTools.GetQuickInsertActionFunc(list)
		local dVicVary = oCmd:GetWarriorVary(vicObj.m_ID)
		if dVicVary.damage_list then
			insert(CWarrior.BeginHit, vicObj, atkObj, dVicVary, dHitInfo.face_atk, dHitInfo.play_anim, dHitInfo.consider_hight)
			if bLastHit then
				CWarCmd.InsertAliveValue(dVicVary, vicObj, insert)
			end
		end
		if dHitInfo.iHurtDelta > 0 then
			insert(CWarrior.WaitTime, vicObj, dHitInfo.iHurtDelta)
			insert(CWarCmd.WaitOne, vicObj, "IsBusy", false)
		end
		if dVicVary.damage_list then
			insert(CWarrior.Hurt, vicObj, dVicVary, dHitInfo.damage_follow)
		end
		if dAtkVary.damage_list then
			insert(CWarrior.Hurt, atkObj, dAtkVary, dHitInfo.damage_follow)
		end

		--技能格挡，反伤
		if dAtkVary.counterhurt_list then
			insert(CWarrior.CounterHurt, atkObj, dAtkVary)
		end
		if dVicVary.counterhurt_list then
			insert(CWarrior.CounterHurt, vicObj, dVicVary)
		end

		if dVicVary.skill_list then
			insert(CWarrior.WarSkill, vicObj, dVicVary)
		end
		if dAtkVary.skill_list then
			insert(CWarrior.WarSkill, atkObj, dAtkVary)
		end
		insert(CWarCmd.WaitOne, vicObj, "IsBusy", false)

		if bLastHit then
			CWarCmd.InsertDelOrAlive(dVicVary, vicObj, insert)
			
			if i == #dHitInfo.vicObjs then
				CWarCmd.InsertDelOrAlive(dAtkVary, atkObj, insert)
				insert(CMagicUnit.CheckClearVary, oMagicUnit, oCmd)
			end
			insert(CWarCmd.ClearWarriorVary, oCmd, vicObj.m_ID)
		end
		
		g_WarCtrl:AddSubActionList(list)
	end
end

function CWarCmd.Protect(oCmd)
	--protectObj保护单位，protectedObj被保护单位，attackObj攻击单位
	local protectObj = g_WarCtrl:GetWarrior(oCmd.action_wid)
	local protectedObj = g_WarCtrl:GetWarrior(oCmd.select_wid)
	local attackObj = g_WarCtrl:GetWarrior(oCmd.attack_wid)
	local dir = protectedObj:InverseTransformDirection(protectedObj.m_RotateObj:GetForward())
	local pos = protectedObj:GetLocalPos() + dir * 0.8
	local endAngle = protectedObj.m_RotateObj:GetLocalEulerAngles()
	g_WarCtrl:InsertAction(CWarCmd.WaitAll, g_WarCtrl:GetWarriors(), "IsBusy", false)
	g_WarCtrl:InsertAction(CWarrior.RunTo, protectObj, pos, nil, endAngle)
end

function CWarCmd.Escape(oCmd)
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.action_wid)
	if oWarrior then
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, oWarrior, "IsBusy", false)
		if oWarrior:IsAlive() then
			g_WarCtrl:InsertAction(CWarrior.Escape, oWarrior, oCmd.success)
		else
			g_WarCtrl:InsertAction(CWarrior.Blink, oWarrior)
		end
		g_WarCtrl:InsertAction(CWarCmd.WaitOne, oWarrior, "IsBusy", false)
	end
end

function CWarCmd.Prepare(oCmd)
	if g_WarCtrl:IsGuideWar() then
		--printerror("指引战斗不需要战前配置")
		--return
	end
	UITools.ShowUI()
	-- WarTools.Print("CWarCmd.Prepare")
	g_WarCtrl:SetPrepare(true, oCmd.sces)
	for i, oWarrior in pairs(g_WarCtrl.m_Warriors) do
		if oWarrior:IsAlly() then
			local bReplace = oWarrior:IsCanReplace()
			if not bReplace and oWarrior.m_ID ~= g_WarCtrl.m_HeroWid then
				local c = oWarrior.m_Actor:GetMatColor()
				oWarrior:SetMatColor(Color.New(c.r * 0.5, c.g * 0.5, c.b * 0.5, c.a))
			end
		end
	end
end

function CWarCmd.CommandStart(oCmd)
	-- WarTools.Print("CWarCmd.CommandStart")
	g_WarCtrl:CommandStart(oCmd.wid)
end

function CWarCmd.WarSpeed(oCmd)
	-- WarTools.Print("CWarCmd.WarSpeed")
	
end

function CWarCmd.SkillCD(oCmd)
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		for i, info in pairs(oCmd.skill_cd) do
			oWarrior:SetMagicCD(info.skill_id, info.bout)
		end
	end
end

function CWarCmd.WarSP(oCmd)
	local iViewSide = g_WarCtrl:GetViewSide()
	if iViewSide then
		g_WarCtrl:SetSP(oCmd.sp, iViewSide == oCmd.camp_id)
	else
		g_WarCtrl:SetSP(oCmd.sp, g_WarCtrl:GetAllyCamp() == oCmd.camp_id, oCmd.skiller, oCmd.addsp)
	end
end

function CWarCmd.WarDamage(oCmd)
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		if oCmd.damage < 0 and oCmd.atkid_list and oCmd.has_hit == false and table.index(oCmd.atkid_list, oCmd.wid) == nil then
			oWarrior:Hit()
		end
		oWarrior:ShowDamage(oCmd.damage, oCmd.iscrit, oCmd.damage_follow, oCmd.damage_type)
	end
end

--战斗指挥
function CWarCmd.WarBattleCmd(oCmd)
	local cmddic = table.list2dict(table.copy(oCmd.cmd), "wid")
	for k,oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		if cmddic[oWarrior.m_ID] then
			oWarrior:SetWarriorCommand(cmddic[oWarrior.m_ID].cmd)
			cmddic[oWarrior.m_ID] = nil
		else
			oWarrior:SetWarriorCommand()
		end
	end
end

function CWarCmd.GetNextBoutRecord(oCmd)
	-- printc("GetNextBoutRecord g_WarCtrl:GetBout(): " .. g_WarCtrl:GetBout())
	netwar.C2GSEndFilmBout(g_WarCtrl:GetWarID(), g_WarCtrl:GetBout() + 1)
end

function CWarCmd.ShowWarSkill(oCmd)
	local oWarrior = g_WarCtrl:GetWarrior(oCmd.wid)
	if oWarrior then
		oWarrior:ShowWarSkillByServer(oCmd.skill, oCmd.type)
	end
end

function CWarCmd.WarNotify(oCmd)
	g_NotifyCtrl:FloatMsg(oCmd.msg)
end

function CWarCmd.BoutAnimFinish(oCmd)
end

function CWarCmd.SectionAnimFinish(oCmd)
	if not g_WarCtrl:GetViewSide() and not g_ShowWarCtrl:IsShowWar() then
		if not g_WarCtrl.m_ShowSceneEndWar and not g_WarCtrl.m_ReciveResultProto then
			-- --新手引导处理			
			-- if g_WarCtrl:GetWarType() == define.War.Type.Guide3 and oCmd.section_id == 1 then				
			-- 	netwar.C2GSWarStop(g_WarCtrl:GetWarID())
			-- 	netwar.C2GSWarAutoFight(g_WarCtrl:GetWarID(), 0)			
		-- end
		netwar.C2GSNextActionEnd(g_WarCtrl:GetWarID(), oCmd.section_id)
		end
	end
end

function CWarCmd.RefreshSpeed(oCmd)
	g_WarCtrl:SetSpeedList(oCmd.speed_list)
end

return CWarCmd


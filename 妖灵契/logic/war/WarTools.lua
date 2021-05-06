module(..., package.seeall)
g_TimeStart= {}
g_DebugInfo = {wait={}, error={}}
function ClearDebugInfo()
	g_DebugInfo = {wait={}, error={}} 
end

function DebugWait(b, tOne, k, v, vv, ...)
	-- local sDebugKey = Utils.GetPrintStr(tOne, k, v)
	-- if g_DebugInfo["error"][sDebugKey] then
	-- 	return
	-- end
	-- if not g_DebugInfo["wait"][sDebugKey] then
	-- 	g_DebugInfo["wait"][sDebugKey] = g_TimeCtrl:GetTimeMS()
	-- end
	-- local iTimeMS = g_TimeCtrl:GetTimeMS() - g_DebugInfo["wait"][sDebugKey] 
	-- if iTimeMS > 60000 then
	-- 	g_DebugInfo["error"][sDebugKey] = true
	-- 	printerror("DebugWait:", iTimeMS/1000, sDebugKey,  vv, ...)
	-- end
end

function Print(...)
	printc(...)
end


function CreateWarrior(type, camp_id, info)
	local oWarrior = CWarrior.New(info.wid)
	oWarrior.m_Pid = info.pid
	oWarrior.m_OwnerWid = info.owner
	oWarrior.m_PartnerID = info.parid
	oWarrior.m_CampID = camp_id
	oWarrior.m_CampPos = info.pos
	oWarrior.m_Type = type
	oWarrior.m_NpcWarriorType = info.w_type
	oWarrior.m_ShowSkills = info.show_skill 
	oWarrior.m_ServerInfo = info
	oWarrior.m_MagicAndLevelList = info.pflist or {}
	oWarrior.m_MagicList = GetMagicList(oWarrior.m_MagicAndLevelList)
	oWarrior.m_Level = info.show_lv
	table.sort(oWarrior.m_MagicList)
	local model_info = info.status.model_info or {}
	oWarrior:ChangeShape(model_info.shape, model_info)
	oWarrior:SetStatus(info.status)
	oWarrior:SetName(info.status.name)
	oWarrior:SetLevel(info.show_lv)
	oWarrior:SetAlive(info.status.status == define.War.Status.Alive)
	-- info.special_skill = {skill_id=1, sum_grid=4, cur_grid=0}
	if info.special_skill and info.special_skill.skill_id then
		oWarrior.m_NpcSpSkill = table.copy(info.special_skill)
		oWarrior:RefreshNpcSkill()
	end
	if info.status.status then
		oWarrior:SetAlive(info.status.status == define.War.Status.Alive)
	end
	return oWarrior
end

function GetMagicList(list)
	local t = {}
	if list and next(list) then
		for i = 1, #list do
			if type(list[i]) == "number" then
				table.insert(t, list[i])
			elseif type(list[i]) == "table" then
				table.insert(t, list[i].id)
			end
		end
	end
	return t
end

function GetWorldDir(stratPos, endPos)
	local dir = (endPos - stratPos).normalized
	local oRoot = g_WarCtrl:GetRoot()
	return oRoot:TransformDirection(dir)
end

function GetHorizontalDis(pos1, pos2)
	return math.sqrt((pos1.x - pos2.x)^2 + (pos1.z - pos2.z)^2)
end

function CheckInDistance(pos1, pos2, max)
	return ((pos1.x-pos2.x)^2+(pos1.z - pos2.z)^2) <= max^2
end

function WarToUIPos(warpos)
	local oWarCam = g_CameraCtrl:GetWarCamera()
	local oUICam = g_CameraCtrl:GetUICamera()	
	local viewPos = oWarCam:WorldToViewportPoint(warpos)
	viewPos.x = viewPos.x * oWarCam.m_Camera.rect.size.x + oWarCam.m_Camera.rect.position.x
	viewPos.y = viewPos.y * oWarCam.m_Camera.rect.size.y + oWarCam.m_Camera.rect.position.y
	local oUIPos = oUICam:ViewportToWorldPoint(viewPos)
	oUIPos.z = 0
	return oUIPos
end

function WarToViewportPos(warpos)
	local oWarCam = g_CameraCtrl:GetWarCamera()
	local viewPos = oWarCam:WorldToViewportPoint(warpos)
	viewPos.x = viewPos.x * oWarCam.m_Camera.rect.size.x + oWarCam.m_Camera.rect.position.x
	viewPos.y = viewPos.y * oWarCam.m_Camera.rect.size.y + oWarCam.m_Camera.rect.position.y
	return viewPos
end

function GetAttackPos(atkObj, vicObj)
	if not(atkObj and vicObj) then
		return Vector3.zero
	end
	local atkpos = atkObj:GetLocalPos()
	local vicpos = vicObj:GetLocalPos()
	local dis = GetHorizontalDis(atkpos, vicpos)
	if dis > define.War.Atk_Distance then
		local rate = (dis - define.War.Atk_Distance) / dis
		local v = Vector3.Lerp(atkpos, vicpos, rate)
		return v
	end
	return atkpos
end

function GetQuickInsertActionFunc(list)
	local function f(func, ...)
		local action = g_WarCtrl:CreateAction(func, ...)
		table.insert(list, action)
	end
	return f
end

function GetMainInsertActionFunc()
	local function f(func, ...)
		g_WarCtrl:InsertAction(func, ...)
	end
	return f
end

function TimeStart(typename)
	-- if Utils.g_IsLog then
		-- g_WarCtrl:InsertAction(function()
				-- printerror("TimeStart", typename, g_TimeCtrl:GetTimeMS())
				-- g_TimeStart[typename] = g_TimeCtrl:GetTimeMS()
			-- end)
	-- end
end

function TimeEnd(typename)
	-- if Utils.g_IsLog then
		-- g_WarCtrl:InsertAction(function()
				-- local iStart = g_TimeStart[typename]
				-- if iStart then
					-- local s = (string.format("%s时间:%d",typename, g_TimeCtrl:GetTimeMS()-iStart))
					-- printerror(s, g_TimeCtrl:GetTimeMS(), iStart)
					-- print(s)
					-- if Utils.IsEditor() then
						-- netwar.C2GSDebugPerform(g_WarCtrl:GetWarID(), s)
					-- end
				-- end
			-- end)
	-- end
end

function OutViewPortPos(pos, dir, iTime)
	local oCam = g_CameraCtrl:GetWarCamera()
	v = oCam:WorldToViewportPoint(pos)
	local iMax = 1.1
	local iMin = -0.1
	local iSafeFlag = 200
	while (v.x >= iMin and v.x <= iMax and v.y >= iMin and v.y <=iMax) and iSafeFlag > 0 do
		pos = pos + dir
		v = oCam:WorldToViewportPoint(pos)
		iSafeFlag = iSafeFlag - 1
	end
	return pos
end

function GetWarriorByCampPos(bAlly, iCmapPos)
	for i, oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		if oWarrior:IsAlly() == bAlly then
			if oWarrior.m_CampPos == iCmapPos then
				return oWarrior
			end
		end
	end
end

function GetResultInfo(dPlayerExp, lPartnerExps, lItems)
	local dResultInfo = {exp_list = {}, item_list = {}}
	dPlayerExp = table.copy(dPlayerExp)
	if dPlayerExp then
		local t = {
				cur_exp = g_AttrCtrl:GetCurGradeExp(dPlayerExp.grade, dPlayerExp.exp),
				add_exp = dPlayerExp.gain_exp or 0,
				cur_grade = dPlayerExp.grade,
				limit_grade = dPlayerExp.limit_grade,
				shape = g_AttrCtrl.model_info.shape,
				max_exp_func= callback(g_AttrCtrl, "GetUpgradeExp"),
				is_over_grade = dPlayerExp.is_over_grade or false,
			}
		table.insert(dResultInfo.exp_list, t)
	end
	for i, dInfo in ipairs(lPartnerExps) do
		local oPartner = g_PartnerCtrl:GetPartner(dInfo.parid)
		if oPartner then
			local t = {
					cur_exp = oPartner:GetCurExp(dInfo.grade, dInfo.exp),
					add_exp = dInfo.gain_exp,
					cur_grade = dInfo.grade,
					limit_grade = dInfo.limit_grade,
					shape = oPartner:GetValue("model_info").shape,
					max_exp_func= callback(oPartner, "GetNeedExp"),
					is_over_grade = dPlayerExp.is_over_grade or false,
				}
			table.insert(dResultInfo.exp_list, t)
		else
			print("有战斗经验, 没有伙伴:", dInfo.parid)
		end
	end
	if lItems and next(lItems) then
		for i = 1, #lItems do 
			lItems[i].virtual = lItems[i].virtual or 0
		end
	end
	dResultInfo.item_list = lItems
	return dResultInfo
end

function GetSortFuncSpeed(sortAlive)
	local func = function (wid1, wid2)
		local oWarrior1 = g_WarCtrl:GetWarrior(wid1)
		if oWarrior1 then
			local oWarrior2 = g_WarCtrl:GetWarrior(wid2)
			if oWarrior2 then
				if sortAlive then
					if oWarrior1:IsAlive() and not oWarrior2:IsAlive() then
						return true
					elseif (not oWarrior1:IsAlive()) and oWarrior2:IsAlive() then
						return false
					end
				end
				local speed1 = oWarrior1:GetSpeed()
				local speed2 = oWarrior2:GetSpeed()
				if speed1 == speed2 then
					return oWarrior1.m_CampPos < oWarrior2.m_CampPos
				else
					return speed2 < speed1
				end
			else
				return true
			end
		else
			return false
		end
	end
	return func
end

function ExcuteCmdInSort(oCmd)
	local oWaitCmd = CWarCmd.New(function()
			g_WarCtrl:InsertAction(CWarCmd.WaitOne, g_WarCtrl, "WaitWarCmdID", oCmd.m_ID, oCmd.m_ID)
		end)
	g_WarCtrl:InsertCmd(oWaitCmd)
	g_WarCtrl:InsertCmd(oCmd)
end

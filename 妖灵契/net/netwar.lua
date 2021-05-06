module(..., package.seeall)

--GS2C--

function GS2CShowWar(pbdata)
	local war_id = pbdata.war_id
	local war_type = pbdata.war_type --战斗类型1:npc,2:pvp,3次元妖兽
	local observer_view = pbdata.observer_view --观察者视角,1,2:阵营,
	local war_flim = pbdata.war_flim --1:录像
	local extra_info = pbdata.extra_info --额外信息
	local flim_ver = pbdata.flim_ver --录像版本号
	local lineup = pbdata.lineup --阵法
	--todo
	g_TaskCtrl:StopWalingTask()
	g_MapCtrl:StopHeroWalk()
	g_NetCtrl:ClearCacheProto("warend", true)			--战斗前，清空上场战斗缓存的协议
	if g_NetCtrl:IsProtoRocord() then
		g_WarCtrl.m_ViewSide = g_NetCtrl:GetRecordValue("side") or 1
		g_WarCtrl.m_IsPlayRecord = true
		g_WarCtrl.m_IsClientRecord = true
	else
		g_WarCtrl.m_IsClientRecord = false
		if observer_view ~= 0 then
			g_WarCtrl.m_ViewSide = observer_view
			if war_type  == define.War.Type.Arena then
				g_ArenaCtrl.m_ViewSide = g_WarCtrl.m_ViewSide
				g_ArenaCtrl.m_Result = define.Arena.WarResult.NotReceive
			elseif war_type == define.War.Type.EqualArena then
				g_EqualArenaCtrl.m_ViewSide = g_WarCtrl.m_ViewSide
				g_EqualArenaCtrl.m_Result = define.EqualArena.WarResult.NotReceive
			elseif war_type == define.War.Type.TeamPvp then
				g_TeamPvpCtrl.m_ViewSide = g_WarCtrl.m_ViewSide
				g_TeamPvpCtrl.m_Result = define.TeamPvp.WarResult.NotReceive
			elseif war_type == define.War.Type.ClubArena then
				g_ClubArenaCtrl.m_ViewSide = g_WarCtrl.m_ViewSide
				g_ClubArenaCtrl.m_Result = define.ClubArena.WarResult.NotReceive
			end
		else
			g_WarCtrl.m_ViewSide = nil
			g_TeamPvpCtrl.m_ViewSide = 0
			g_ArenaCtrl.m_ViewSide = 0
			g_EqualArenaCtrl.m_ViewSide = 0
		end
		g_WarCtrl.m_IsPlayRecord = war_flim == 1
	end

	g_EndlessPVECtrl.m_ReceiveResult = false
	g_NetCtrl:SetRecordType(nil) -- 清除当前的
	g_NetCtrl:SetRecordType("war_record")
	printc("war_id: " .. war_id)
	g_WarCtrl:Start(war_id, war_type)
	g_WarCtrl.m_Lineup = tonumber(lineup)
	if extra_info and #extra_info > 0 then
		for _, info in pairs(extra_info) do
			if info.key then
				if info.key == "patalv" then
					g_PataCtrl:SetPataWarFloor(tonumber(info.value))
				elseif info.key == "enemy_escape_cnt" then
					g_WarCtrl.m_EnemyPlayerCnt = tonumber(info.value)
				elseif info.key == "escape_cnt" then
					g_WarCtrl.m_AllyPlayerCnt = tonumber(info.value)
				elseif info.key == "diff" and info.value == "large" then
					g_MonsterAtkCityCtrl.m_MSBossWarEnd = true
				end
			end
		end
	end
end

function GS2CWarResult(pbdata)
	local war_id = pbdata.war_id
	local win_side = pbdata.win_side
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	if g_WarCtrl.m_ReciveResultProto then
		return
	end
	--如果是观战模式的话，有可能在cmd执行的时候m_ReciveResultProto已经true，导致CWarrior.FadeDel无法正常执行
	if not g_WarCtrl.m_ViewSide then
		g_WarCtrl.m_ReciveResultProto = true
	end
	g_WarCtrl.m_IsReceiveDone = true
	if g_WarCtrl:IsPlayRecord() then
		if g_NetCtrl:IsProtoRocord() then
			return
		-- elseif g_WarCtrl:GetWarType() == define.War.Type.Arena then
		-- 	g_ArenaCtrl.m_Result = win_side == g_ArenaCtrl.m_PlayerInfo.camp
		-- elseif g_WarCtrl:GetWarType() == define.War.Type.EqualArena then
		-- 	g_EqualArenaCtrl.m_Result = win_side == g_EqualArenaCtrl.m_PlayerInfo.camp
		elseif g_WarCtrl:IsBanRecordWarEnd() then
			return
		end
	end
	local oCmd = CWarCmd.New("WaitAllFinish")
	g_WarCtrl:InsertCmd(oCmd)
	
	local oCmd = CWarCmd.New("WarResult")
	oCmd.win = win_side == g_WarCtrl.m_AllyCmap
	oCmd.war_id = war_id
	oCmd.win_side = win_side
	g_WarCtrl:InsertCmd(oCmd)
	g_WarCtrl:BoutEnd()
end

function GS2CWarBoutStart(pbdata)
	local war_id = pbdata.war_id
	local bout_id = pbdata.bout_id
	local left_time = pbdata.left_time
	--todo
	printc("--->GS2CWarBoutStart:", bout_id)
	local oCmd = CWarCmd.New("BoutStart")
	oCmd.bout_id = bout_id
	g_WarCtrl:InsertCmd(oCmd)
	g_WarCtrl.m_ProtoBout = bout_id
end

function GS2CWarBoutEnd(pbdata)
	local war_id = pbdata.war_id
	local bout_id = pbdata.bout_id
	--todo
	if g_WarCtrl:IsPlayRecord() and (g_WarCtrl:GetWarType() == define.War.Type.Arena or g_WarCtrl:GetWarType() == define.War.Type.EqualArena or g_WarCtrl:GetWarType() == define.War.Type.ClubArena) and not g_NetCtrl:IsProtoRocord() then
		local oCmd = CWarCmd.New("GetNextBoutRecord")
		-- oCmd.m_ExcuteWhenNoneAction = true
		oCmd.bout_id = bout_id
		g_WarCtrl:InsertCmd(oCmd)
	end
	local oCmd = CWarCmd.New("BoutEnd")
	oCmd.bout_id = bout_id
	g_WarCtrl:InsertCmd(oCmd)
	g_WarCtrl.m_ProtoBout = bout_id
end

function GS2CWarAddWarrior(pbdata)
	local war_id = pbdata.war_id
	local camp_id = pbdata.camp_id
	local type = pbdata.type --1 player,2 npc,4 partner
	local warrior = pbdata.warrior
	local npcwarrior = pbdata.npcwarrior
	local partnerwarrior = pbdata.partnerwarrior
	local add_type = pbdata.add_type --添加类型,0:正常添加,1:回合中添加
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	local oCmd = CWarCmd.New("AddWarrior")
	oCmd.type = type
	local info = {}
	if type == define.Warrior.Type.Player then
		info = warrior
	elseif type == define.Warrior.Type.Npc then
		info = npcwarrior
	elseif type == define.Warrior.Type.Partner then
		info = partnerwarrior
	elseif type == define.Warrior.Type.OfflinePlayer then
		info = warrior
	elseif type == define.Warrior.Type.OfflinePartner then
		info = partnerwarrior
	end

	if info.status then
		local status = g_NetCtrl:DecodeMaskData(info.status, "WarriorStatus")
		--服务端发整数，把大小*100发过来的
		if status.model_info then
			status.model_info = table.copy(status.model_info)
			ModelTools.ModelInfoScale(status.model_info, 1/100)
		end
		info.status = status
	end
	oCmd.info = table.copy(info)
	--比武场BOSS标记特殊处理
	if type == define.Warrior.Type.Npc and (g_WarCtrl:GetWarType() == define.War.Type.Arena or g_WarCtrl:GetWarType() == define.War.Type.EqualArena or g_WarCtrl:GetWarType() == define.War.Type.ClubArena) then
		oCmd.info.w_type = 0
	end
	oCmd.camp_id = camp_id
	--操作中替换add_type = 1
	if not g_WarCtrl:IsClientRecord() and not g_WarCtrl:IsInAction() and add_type == 1 then
		oCmd:Excute()
	else
		local bProcess = false
		local oVaryCmd = g_WarCtrl:GetVaryCmd()
		if oVaryCmd then
			--召唤出来的角色
			local dSectionInfo = table.safeget(g_WarCtrl.m_MagicInfos, g_WarCtrl.m_ProtoWave, g_WarCtrl.m_ProtoBout, g_WarCtrl.m_ProtoSection)
			if dSectionInfo then
				local dLastInfo = dSectionInfo.info_list[#dSectionInfo.info_list]
				--技能特殊处理，召唤特效显示在召唤物身上 
				if table.index(define.Magic.SummonMagic, dLastInfo.maigic) ~= nil then
					oVaryCmd.vicid_list = {info.wid}
					oVaryCmd:AddWarriorCmd(oCmd)
					bProcess = true
				end
			end
		end
		if not bProcess then
			g_WarCtrl:InsertCmd(oCmd)
		end
	end
	if g_WarCtrl.m_ProtoBout == 0 then --战前布阵阶段
		if type == define.Warrior.Type.Player then
			local iSide = g_WarCtrl:GetViewSide()
			if iSide and iSide == camp_id then
				g_WarCtrl.m_HeroPid = oCmd.info.pid
			end
			if oCmd.info.pid == g_WarCtrl:GetHeroPid() then
				g_WarCtrl.m_AllyCmap = camp_id
				g_WarCtrl.m_HeroWid = oCmd.info.wid
			end
			local bAlly = g_WarCtrl.m_AllyCmap == camp_id
			if bAlly then
				g_WarCtrl.m_AllyPlayerCnt = g_WarCtrl.m_AllyPlayerCnt + 1
			else
				g_WarCtrl.m_EnemyPlayerCnt = g_WarCtrl.m_EnemyPlayerCnt + 1
			end
		elseif type == define.Warrior.Type.Partner then
			local bAlly = g_WarCtrl.m_AllyCmap == camp_id
			if bAlly then
				g_WarCtrl.m_AllyPartnerWids[oCmd.info.wid] = true
			else
				g_WarCtrl.m_EnemyPartnerWids[oCmd.info.wid] = true
			end
		elseif type == define.Warrior.Type.Npc then
			local bAlly = g_WarCtrl.m_AllyCmap == camp_id
			if bAlly then

			else
				g_WarCtrl.m_EnemyNpcCnt = g_WarCtrl.m_EnemyNpcCnt + 1
			end
		elseif type == define.Warrior.Type.OfflinePlayer then
			local iSide = g_WarCtrl:GetViewSide()
			if iSide and iSide == camp_id then
				g_WarCtrl.m_HeroPid = oCmd.info.pid
			end
			if oCmd.info.pid == g_WarCtrl:GetHeroPid() then
				g_WarCtrl.m_AllyCmap = camp_id
				g_WarCtrl.m_HeroWid = oCmd.info.wid
			end
			local bAlly = g_WarCtrl.m_AllyCmap == camp_id
			if bAlly then
				g_WarCtrl.m_AllyPlayerCnt = g_WarCtrl.m_AllyPlayerCnt + 1
			else
				g_WarCtrl.m_EnemyPlayerCnt = g_WarCtrl.m_EnemyPlayerCnt + 1
			end
		elseif type == define.Warrior.Type.OfflinePartner then
			local bAlly = g_WarCtrl.m_AllyCmap == camp_id
			if bAlly then
				g_WarCtrl.m_AllyPartnerWids[oCmd.info.wid] = true
			else
				g_WarCtrl.m_EnemyPartnerWids[oCmd.info.wid] = true
			end
		else
			printc("no type: " .. type)
		end
	end
end

function GS2CWarDelWarrior(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local del_type = pbdata.del_type --删除类型,0:正常删除,1:回合中删除
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	if not g_WarCtrl:IsClientRecord() and not g_WarCtrl:IsInAction() and del_type == 1 and not g_WarCtrl.m_ViewSide then
		g_WarCtrl:DelWarrior(wid)
	else
		local oCmd = CWarCmd.New("DelWarrior")
		oCmd.wid = wid
		oCmd.type = del_type
		local oVaryCmd = g_WarCtrl:GetVaryCmd()
		if oVaryCmd then
			oVaryCmd:SetVary(wid, "del_cmd", oCmd)
		else
			g_WarCtrl:InsertCmd(oCmd)
		end
	end
	if g_WarCtrl.m_ProtoBout == 0 then
		g_WarCtrl.m_AllyPartnerWids[wid] = nil
		g_WarCtrl.m_EnemyPartnerWids[wid] = nil
	end
end

function GS2CWarNormalAttack(pbdata)
	local war_id = pbdata.war_id
	local action_wid = pbdata.action_wid
	local select_wid = pbdata.select_wid
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	local oCmd = CWarCmd.New("NormalAttack")
	oCmd.atkid = action_wid
	oCmd.vicid = select_wid
	g_WarCtrl:SetVaryCmd(oCmd)
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarSkill(pbdata)
	local war_id = pbdata.war_id
	local action_wlist = pbdata.action_wlist
	local select_wlist = pbdata.select_wlist
	local skill_id = pbdata.skill_id
	local magic_id = pbdata.magic_id
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	local oCmd = CWarCmd.New("Magic")
	oCmd.atkid_list = action_wlist
	oCmd.vicid_list = select_wlist
	--无视服务端的变量名skill_id， magic_id
	--客户端法术只有magic_id， magic_index
	oCmd.magic_id = skill_id
	oCmd.magic_index = magic_id
	g_WarCtrl:AddMagicInfo(action_wlist[1], select_wlist, skill_id, magic_id, oCmd.m_ID)
	g_WarCtrl:SetVaryCmd(oCmd)
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarProtect(pbdata)
	local war_id = pbdata.war_id
	local action_wid = pbdata.action_wid --保护单位
	local select_wid = pbdata.select_wid --被保护单位
	local attack_wid = pbdata.attack_wid
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end	
	local oCmd = CWarCmd.New("Protect")
	oCmd.action_wid = action_wid
	oCmd.select_wid = select_wid
	oCmd.attack_wid = attack_wid
	g_WarCtrl:InsertCmd(oCmd)
	local dSectionInfo = table.safeget(g_WarCtrl.m_MagicInfos, g_WarCtrl.m_CurWave, g_WarCtrl.m_CurBout, g_WarCtrl.m_CurSection)
	if dSectionInfo then
		local dLastInfo = dSectionInfo.info_list[#dSectionInfo.info_list]
		if dLastInfo then
			dLastInfo.is_next_protect = true --下一个法术是否保护
		end
	end
end

function GS2CWarEscape(pbdata)
	local war_id = pbdata.war_id
	local action_wid = pbdata.action_wid
	local success = pbdata.success
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	g_WarCtrl:SetIsEscape(success)
	local oCmd = CWarCmd.New("Escape")
	oCmd.action_wid = action_wid
	oCmd.success = success
	g_WarCtrl:SetVaryCmd(nil)
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarDamage(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local type = pbdata.type --1 miss 2 defense
	local iscrit = pbdata.iscrit --1 crit
	local damage = pbdata.damage
	local damage_type = pbdata.damage_type --0 默认,1加血
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	local oCmd = CWarCmd.New("WarDamage")
	oCmd.wid = wid
	oCmd.damage = damage
	oCmd.damage_type = damage_type
	oCmd.has_hit = false
	oCmd.iscrit = iscrit == 1
	oCmd:EnableExcuteInSort()
	local oVaryCmd = g_WarCtrl:GetVaryCmd()	
	if oVaryCmd then
		local dSectionInfo = table.safeget(g_WarCtrl.m_MagicInfos, g_WarCtrl.m_CurWave, g_WarCtrl.m_CurBout, g_WarCtrl.m_CurSection)
		if dSectionInfo then
			local dLastInfo = dSectionInfo.info_list[#dSectionInfo.info_list]
			if dLastInfo and dLastInfo.is_next_counterhurt then
				dLastInfo.is_next_counterhurt = false
				local counterhurt_list = oVaryCmd:GetVary(wid, "counterhurt_list") or {}
				oCmd.atkid_list = oVaryCmd.atkid_list
				table.insert(counterhurt_list, oCmd)
				oVaryCmd:SetVary(wid, "counterhurt_list", counterhurt_list)
				return
			end
		end
		local damage_list = oVaryCmd:GetVary(wid, "damage_list") or {}
		oCmd.atkid_list = oVaryCmd.atkid_list
		table.insert(damage_list, oCmd)
		oVaryCmd:SetVary(wid, "damage_list", damage_list)
	else
		WarTools.ExcuteCmdInSort(oCmd)
	end
end

function GS2CWarWarriorStatus(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local type = pbdata.type
	local status = pbdata.status
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	local status = g_NetCtrl:DecodeMaskData(status, "WarriorStatus")
	if status.model_info then
		ModelTools.ModelInfoScale(status.model_info, 1/100)
	end
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		if status.hp or status.max_hp then
			local hp_list = oVaryCmd:GetVary(wid, "hp_list") or {}
			table.insert(hp_list, {hp=status.hp, max_hp=status.max_hp})
			oVaryCmd:SetVary(wid, "hp_list", hp_list)
			status["hp"] = nil
			status["max_hp"] = nil
		end
		for k, v in pairs(status) do
			oVaryCmd:SetVary(wid, k, v)
		end
	else
		local oCmd = CWarCmd.New("WarriorStatus")
		oCmd.wid = wid
		oCmd.status = status
		if status.auto_skill then
			oCmd:Excute()
		else
			oCmd:EnableExcuteInSort()
			WarTools.ExcuteCmdInSort(oCmd)
		end
	end
end

function GS2CWarGoback(pbdata)
	local war_id = pbdata.war_id
	local action_wid = pbdata.action_wid
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	local oCmd = CWarCmd.New("GoBack")
	oCmd.wid_list = {action_wid}
	oCmd.wait = true
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd and oVaryCmd.atkid_list and table.index(oVaryCmd.atkid_list, action_wid) then
		oVaryCmd:SetVary(action_wid, "go_back", oCmd)
		g_WarCtrl:SetVaryCmd(nil)
	else
		g_WarCtrl:InsertCmd(oCmd)
	end
end

function GS2CWarBuffBout(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local buff_id = pbdata.buff_id
	local bout = pbdata.bout
	local level = pbdata.level
	local produce_wid = pbdata.produce_wid --引发者
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	local oCmd = CWarCmd.New("Buff")
	oCmd.wid = wid
	oCmd.buff_id = buff_id
	oCmd.bout = bout
	oCmd.level = level
	oCmd.need_tips = not g_WarCtrl:IsWarStart()
	oCmd.from_wid = produce_wid
	oCmd:EnableExcuteInSort()
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		local buff_list = oVaryCmd:GetVary(wid, "buff_list") or {}
		table.insert(buff_list, oCmd)
		oVaryCmd:SetVary(wid, "buff_list", buff_list)
	else
		WarTools.ExcuteCmdInSort(oCmd)
	end
end

function GS2CWarPasssiveSkill(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local skill_id = pbdata.skill_id
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		local list = oVaryCmd:GetVary(wid, "passive_skill_list") or {}
		table.insert(list, skill_id)
		oVaryCmd:SetVary(wid, "passive_skill_list", list)
	end
end

function GS2CPlayerWarriorEnter(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local partner_list = pbdata.partner_list
	local command_list = pbdata.command_list --执行了指令的单位
	local sp = pbdata.sp
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	for i, wid in ipairs(command_list) do
		local oWarrior = g_WarCtrl:GetWarrior(wid)
		if oWarrior then
			oWarrior:SetOrderDone(true)
		end
	end
	g_WarCtrl.m_AlreadyWarPartner = table.copy(partner_list)
	g_WarCtrl:SetSP(sp)
	g_WarCtrl.m_IsReceiveDone = true
end

function GS2CWarConfig(pbdata)
	local war_id = pbdata.war_id
	local secs = pbdata.secs --秒数
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) or g_WarCtrl:IsPlayRecord() then
		return
	end
	local oCmd = CWarCmd.New("Prepare")
	oCmd.sces = secs
	g_WarCtrl.m_FillFullPos = true
	g_WarCtrl.m_IsReceiveDone = true
	g_WarCtrl:InsertCmd(oCmd)
	if not g_WarCtrl:IsLockPreparePartner() then
		g_CameraCtrl:SetAnimatorPercent(0.534)
	end
end

function GS2CWarCommand(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	local oWarrior = g_WarCtrl:GetWarrior(wid)
	if oWarrior then
		oWarrior:SetOrderDone(true)
	end
end

function GS2CWarSpeed(pbdata)
	local war_id = pbdata.war_id
	local speed_list = pbdata.speed_list
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	local oCmd = CWarCmd.New("RefreshSpeed")
	oCmd.speed_list = speed_list
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarAction(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	-- g_WarCtrl:AddWillActWid(wid)
	local oCmd = CWarCmd.New("CommandStart")
	oCmd.wid = wid
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarStatus(pbdata)
	local war_id = pbdata.war_id
	local status = pbdata.status --1:开始,0:结束
	local left_time = pbdata.left_time --当前回合剩余时间
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	g_WarCtrl:SetPause(status == 0 and left_time)
end

function GS2CWarSkillCD(pbdata)
	local war_id = pbdata.war_id --战斗id
	local wid = pbdata.wid --战士id
	local skill_cd = pbdata.skill_cd --技能cd信息
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	local oCmd = CWarCmd.New("SkillCD")
	oCmd.wid = wid
	oCmd.skill_cd = skill_cd
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CWarSP(pbdata)
	local war_id = pbdata.war_id
	local camp_id = pbdata.camp_id
	local sp = pbdata.sp --怒气值
	local attack = pbdata.attack
	local skiller = pbdata.skiller --技能使用者
	local addsp = pbdata.addsp --本次增减怒气
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	local oCmd = CWarCmd.New("WarSP")
	oCmd.camp_id = camp_id
	oCmd.sp = sp
	oCmd.skiller = skiller
	oCmd.addsp = addsp
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	oCmd:EnableExcuteInSort()
	if oVaryCmd and attack ~= 0 then --因为被打造成sp改变
		local sp_list = oVaryCmd:GetVary(attack, "sp_list") or {}
		table.insert(sp_list, oCmd)
		oVaryCmd:SetVary(attack, "sp_list", sp_list)
	else
		WarTools.ExcuteCmdInSort(oCmd)
	end
end

function GS2CWarEndUI(pbdata)
	local war_id = pbdata.war_id
	local player_exp = pbdata.player_exp
	local partner_exp = pbdata.partner_exp
	local player_item = pbdata.player_item --道具奖励
	local win = pbdata.win --1:win 0:fail
	local win_tips = pbdata.win_tips
	local fail_tips = pbdata.fail_tips
	local apply = pbdata.apply --玩法参数
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	g_WarCtrl:RefreshResultInfo(player_exp, partner_exp, player_item, win_tips, fail_tips, apply)
end

function GS2CWarTarget(pbdata)
	local war_id = pbdata.war_id
	local war_target = pbdata.war_target
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	for i, dTarget in ipairs(war_target) do
		local oWarrior = g_WarCtrl:GetWarrior(dTarget.select_wid)
		if oWarrior then
			oWarrior:SetJihuoTag(dTarget.type == 1)
			g_GuideCtrl:CheckWar5Guide(dTarget.type)
		end
	end
end

function GS2CWarFloat(pbdata)
	local war_id = pbdata.war_id
	local float_info = pbdata.float_info
	--todo
	-- if (g_WarCtrl.m_WarID ~= war_id) or (g_WarCtrl.m_EnterWar == false) then
	-- 	return
	-- end
	-- g_WarCtrl:SetBoutFloatInfo(float_info)
end

function GS2CSwitchPos(pbdata)
	local war_id = pbdata.war_id
	local pos_list = pbdata.pos_list
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	for i, dSwitchPos in ipairs(pos_list) do
		local oWarrior = g_WarCtrl:GetWarrior(dSwitchPos.wid)
		if oWarrior then
			oWarrior.m_CampPos = dSwitchPos.pos
			oWarrior:UpdateOriginPos()
		end
	end
end

function GS2CWarWave(pbdata)
	local cur_wave = pbdata.cur_wave --当前波数
	local sum_wave = pbdata.sum_wave --总波数
	--todo
	printc("--->GS2CWarWave:", cur_wave, sum_wave)
	local oCmd = CWarCmd.New("Wave")
	oCmd.cur_wave = cur_wave
	oCmd.sum_wave = sum_wave
	g_WarCtrl:InsertCmd(oCmd)
	g_WarCtrl.m_ProtoWave = cur_wave
end

function GS2CConfigFinish(pbdata)
	local war_id = pbdata.war_id
	local camp = pbdata.camp --阵营1,2
	local wid = pbdata.wid --玩家ID
	--todo
	for k,oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		if wid == oWarrior.m_ID or wid == oWarrior.m_OwnerWid then
			oWarrior:SetReady(true)
		end
	end
	if wid == g_WarCtrl.m_HeroWid then
		for k,oWarrior in pairs(g_WarCtrl:GetWarriors()) do
			oWarrior:ReSetDefaultMatColor()
		end		
	end	
	if wid == g_WarCtrl.m_HeroWid then
		local oFloatView = CWarFloatView:GetView()
		if oFloatView then
			oFloatView.m_BoutTimeBox:ShowWait(true)
		end
	end
	g_WarCtrl.m_IsReceiveDone = true
end

function GS2CShowWarSkill(pbdata)
	local wid = pbdata.wid --触发者
	local skill = pbdata.skill --技能ID
	local type = pbdata.type --type 1.伙伴,2.门派,3符文,4.装备,5.buff,6.se
	--todo
	local oCmd = CWarCmd.New("ShowWarSkill")
	oCmd.wid = wid
	oCmd.skill = skill
	oCmd.type = type
	local oVaryCmd = g_WarCtrl:GetVaryCmd()
	if oVaryCmd then
		local skill_list = oVaryCmd:GetVary(wid, "skill_list") or {}
		table.insert(skill_list, oCmd)
		oVaryCmd:SetVary(wid, "skill_list", skill_list)
	else
		g_WarCtrl:InsertCmd(oCmd)
	end
	--1002格挡特殊处理
	if skill == 1002 and type == 6 then
		local dSectionInfo = table.safeget(g_WarCtrl.m_MagicInfos, g_WarCtrl.m_CurWave, g_WarCtrl.m_CurBout, g_WarCtrl.m_CurSection)
		if dSectionInfo then
			local dLastInfo = dSectionInfo.info_list[#dSectionInfo.info_list]
			if dLastInfo then
				dLastInfo.is_next_counterhurt = true --下一个法术是格挡
			end
		end
	end
end

function GS2CWarNotify(pbdata)
	local cmd = pbdata.cmd --信息
	--todo
	local oCmd = CWarCmd.New("WarNotify")
	oCmd.msg = cmd
	g_WarCtrl:InsertCmd(oCmd)
end

function GS2CSelectCmd(pbdata)
	local cmd = pbdata.cmd --指令
	--todo
	g_WarCtrl:CheckShowDefaultMagic(cmd)
end

function GS2CEnterWar(pbdata)
	--todo
	g_WarCtrl.m_EnterWar = true
end

function GS2CWarSetPlaySpeed(pbdata)
	local war_id = pbdata.war_id
	local play_speed = pbdata.play_speed
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	play_speed = math.min(play_speed, 2)
	g_WarCtrl.m_WatchAnimSpeed = play_speed
	g_WarCtrl.m_AnimSpeed = play_speed
	g_WarCtrl:UpdateTimeScale()
end

function GS2CWarBattleCmd(pbdata)
	local war_id = pbdata.war_id
	local cmd = pbdata.cmd
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	--如果是正常战斗或者观战就直接
	local cmddic = table.list2dict(table.copy(cmd), "wid")
	for k,oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		if cmddic[oWarrior.m_ID] then
			oWarrior:SetWarriorCommand(cmddic[oWarrior.m_ID].cmd)
			cmddic[oWarrior.m_ID] = nil
		else
			oWarrior:SetWarriorCommand()
		end
	end
	for k,v in pairs(cmddic) do
		g_WarCtrl:SetCacheWarBattleCmd(v.wid, v.cmd)
	end
	--如果是战斗录像就走指令形式
	if g_WarCtrl:IsPlayRecord() or g_WarCtrl:IsClientRecord() then
		local oCmd = CWarCmd.New("WarBattleCmd")
		oCmd.war_id = war_id
		oCmd.cmd = cmd
		g_WarCtrl:InsertCmd(oCmd)
	end
end

function GS2CWarChapterInfo(pbdata)
	local start_time = pbdata.start_time
	--todo

end

function GS2CActionStart(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local action_id = pbdata.action_id
	local left_time = pbdata.left_time
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	if g_WarCtrl.m_ReciveResultProto then
		editor.error("GS2CWarResult后面不应该有GS2CActionStart, 服务端查下")
		return
	end

	-- if bout_id == 1 and g_WarCtrl.m_ProtoWave == 1 then
		-- if g_WarCtrl:IsPlayRecord() and 
		-- 	g_WarCtrl:GetWarType() ~= define.War.Type.Arena 
		-- 	and g_WarCtrl:GetWarType() ~= define.War.Type.EqualArena 
		-- 	and g_WarCtrl:GetWarType() ~= define.War.Type.TeamPvp then
		-- 	UITools.HideUI()
		-- end
		-- g_HudCtrl:SetRootActive(false)
		-- g_WarCtrl:SimulateMagicCmd(define.Magic.SpcicalID.WarSimulate, 1, true) -- 战斗开始法术指令'
	-- end
	printc("--->Proto SectionStart:", action_id)
	local oCmd = CWarCmd.New("SectionStart")
	-- oCmd.m_ExcuteWhenNoneAction = true
	oCmd.sction_id = action_id
	oCmd.left_time = left_time
	oCmd.order_wid = wid
	g_WarCtrl:SetVaryCmd(nil)
	g_WarCtrl:InsertCmd(oCmd)
	g_WarCtrl.m_ProtoSection = action_id
	g_WarCtrl.m_IsReceiveDone = true

	for k,oWarrior in pairs(g_WarCtrl:GetWarriors()) do
		oWarrior:ReSetDefaultMatColor()
	end	
end

function GS2CActionEnd(pbdata)
	local war_id = pbdata.war_id
	local wid = pbdata.wid
	local action_id = pbdata.action_id
	--todo
	if not g_WarCtrl:IsVaildProto(war_id) then
		return
	end
	g_WarCtrl:SetVaryCmd(nil)
	if action_id == 0 then
		g_WarCtrl:SectionEnd()
	else
		g_WarCtrl:SectionEnd(action_id)
	end

	local oCmd = CWarCmd.New("SectionAnimFinish")
	oCmd.section_id = action_id
	g_WarCtrl:InsertCmd(oCmd)
	g_WarCtrl.m_IsReceiveDone = true
end


--C2GS--

function C2GSWarSkill(war_id, action_wlist, select_wlist, skill_id)
	local t = {
		war_id = war_id,
		action_wlist = action_wlist,
		select_wlist = select_wlist,
		skill_id = skill_id,
	}
	g_NetCtrl:Send("war", "C2GSWarSkill", t)
end

function C2GSWarNormalAttack(war_id, action_wid, select_wid)
	local t = {
		war_id = war_id,
		action_wid = action_wid,
		select_wid = select_wid,
	}
	g_NetCtrl:Send("war", "C2GSWarNormalAttack", t)
end

function C2GSWarProtect(war_id, action_wid, select_wid)
	local t = {
		war_id = war_id,
		action_wid = action_wid,
		select_wid = select_wid,
	}
	g_NetCtrl:Send("war", "C2GSWarProtect", t)
end

function C2GSWarEscape(war_id, action_wid)
	local t = {
		war_id = war_id,
		action_wid = action_wid,
	}
	g_NetCtrl:Send("war", "C2GSWarEscape", t)
end

function C2GSWarDefense(war_id, action_wid)
	local t = {
		war_id = war_id,
		action_wid = action_wid,
	}
	g_NetCtrl:Send("war", "C2GSWarDefense", t)
end

function C2GSWarPrepareCommand(war_id, partner_list)
	local t = {
		war_id = war_id,
		partner_list = partner_list,
	}
	g_NetCtrl:Send("war", "C2GSWarPrepareCommand", t)
end

function C2GSWarPartner(war_id, partner_list)
	local t = {
		war_id = war_id,
		partner_list = partner_list,
	}
	g_NetCtrl:Send("war", "C2GSWarPartner", t)
end

function C2GSWarStop(war_id)
	local t = {
		war_id = war_id,
	}
	g_NetCtrl:Send("war", "C2GSWarStop", t)
end

function C2GSWarStart(war_id)
	local t = {
		war_id = war_id,
	}
	g_NetCtrl:Send("war", "C2GSWarStart", t)
end

function C2GSWarTarget(war_id, select_wid, type)
	local t = {
		war_id = war_id,
		select_wid = select_wid,
		type = type,
	}
	g_NetCtrl:Send("war", "C2GSWarTarget", t)
end

function C2GSWarAutoFight(war_id, type)
	local t = {
		war_id = war_id,
		type = type,
	}
	g_NetCtrl:Send("war", "C2GSWarAutoFight", t)
end

function C2GSChangeAutoSkill(war_id, wid, auto_skill)
	local t = {
		war_id = war_id,
		wid = wid,
		auto_skill = auto_skill,
	}
	g_NetCtrl:Send("war", "C2GSChangeAutoSkill", t)
end

function C2GSSolveKaji()
	local t = {
	}
	g_NetCtrl:Send("war", "C2GSSolveKaji", t)
end

function C2GSEndFilmBout(war_id, bout)
	local t = {
		war_id = war_id,
		bout = bout,
	}
	g_NetCtrl:Send("war", "C2GSEndFilmBout", t)
end

function C2GSSelectCmd(war_id, wid, skill)
	local t = {
		war_id = war_id,
		wid = wid,
		skill = skill,
	}
	g_NetCtrl:Send("war", "C2GSSelectCmd", t)
end

function C2GSNextBoutStart(war_id, bout)
	local t = {
		war_id = war_id,
		bout = bout,
	}
	g_NetCtrl:Send("war", "C2GSNextBoutStart", t)
end

function C2GSWarSetPlaySpeed(war_id, play_speed)
	local t = {
		war_id = war_id,
		play_speed = play_speed,
	}
	g_NetCtrl:Send("war", "C2GSWarSetPlaySpeed", t)
end

function C2GSDebugPerform(war_id, debug)
	local t = {
		war_id = war_id,
		debug = debug,
	}
	g_NetCtrl:Send("war", "C2GSDebugPerform", t)
end

function C2GSWarBattleCommand(war_id, wid, cmd)
	local t = {
		war_id = war_id,
		wid = wid,
		cmd = cmd,
	}
	g_NetCtrl:Send("war", "C2GSWarBattleCommand", t)
end

function C2GSCleanWarBattleCommand(war_id, wid)
	local t = {
		war_id = war_id,
		wid = wid,
	}
	g_NetCtrl:Send("war", "C2GSCleanWarBattleCommand", t)
end

function C2GSNextActionEnd(war_id, action_id)
	local t = {
		war_id = war_id,
		action_id = action_id,
	}
	g_NetCtrl:Send("war", "C2GSNextActionEnd", t)
end


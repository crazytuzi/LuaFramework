_G.ArenaBattle = {}
ArenaBattle.playerList = {}
ArenaBattle.mapId = 10400010
ArenaBattle.selfPos = {x = -10, y = -10}
ArenaBattle.winId = 1
ArenaBattle.arenaState = false
ArenaBattle.timePlan = {}
ArenaBattle.CDList = {[1] = {}, [2] = {}}
ArenaBattle.posList = {
	[1] = {x = -74, y = 50, dir = math.pi / 4},
	[2] = {x = 22, y = -47, dir = math.pi * 5/4},
}
ArenaBattle.posList1 = {
	[1] = {x = -42, y = 17, speed = 50},
	[2] = {x = -10, y = -15, speed = 50},
}
ArenaBattle.stiff_time = 0 
ArenaBattle.inArenaScene = 0

function ArenaBattle:EnterScene(msg)
	--初始化数据
	ArenaBattle.inArenaScene = 1
	ArenaBattle.timePlan = {}
	ArenaBattle.playerList = {}
	ArenaBattle.CDList = {[1] = {}, [2] = {}}
	if msg.result == 0 then 
		ArenaBattle.winId = 1
	else
		ArenaBattle.winId = 2
	end
	--打开loading图
	UILoadingScene:Open(false)
	--隐藏UI
	ArenaBattle:HideAllUI()
	--隐藏主玩家
	ArenaBattle:HideSelfPlayer()
	--切场景到竞技场场景
	local sInfo = {posX = ArenaBattle.selfPos.x, posY = -ArenaBattle.selfPos.y, dungeonId = 0, dir = 0, result = 1, mapID = ArenaBattle.mapId, lineID = 1}
	local callback = function()
		CPlayerMap.setAllPlayer = {}
		ArenaBattle:InitPlayer(msg)
		GameController:OnChangeSceneMap()
		UILoadingScene:Hide()
		ArenaBattle:StartStory()
		ArenaBattle:HideSelfPlayer()
	end
	CPlayerMap:DoChangeMap(sInfo, callback)
end

--开始战斗
function ArenaBattle:StarFig()
	ArenaBattle.arenaState = true
	-- 5s后出现跳过按钮
	ArenaBattle:StartSkipShowTimer()
end

local skipShowTimer
function ArenaBattle:StartSkipShowTimer()
	if skipShowTimer then return end
	skipShowTimer = TimerManager:RegisterTimer(function()
		self:ShowSkipBtn()
	end, 2000, 1)
end

function ArenaBattle:StopSkipShowTimer()
	if skipShowTimer then
		TimerManager:UnRegisterTimer(skipShowTimer)
		skipShowTimer = nil
	end
end

function ArenaBattle:ShowSkipBtn()
	self:StopSkipShowTimer()
	UIArenaSkip:Show()
end

function ArenaBattle:HideSkipBtn()
	self:StopSkipShowTimer()
	UIArenaSkip:Hide()
end

function ArenaBattle:Update()
	if ArenaBattle.arenaState then
		ArenaBattle:AutoBattle()
		local ret = ArenaBattle:CheckResult()
		if ret then
			ArenaBattle:ShowResult()
		end
	end
end

function ArenaBattle:SetSkillCD(id, skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
	ArenaBattle.CDList[id][skillId] = GetCurTime() + skillConfig.cd
end

function ArenaBattle:CheckSkillCD(id, skillId)
	if ArenaBattle.CDList[id][skillId] and ArenaBattle.CDList[id][skillId] > GetCurTime() then
		return false
	end
	return true
end

function ArenaBattle:HideSelfPlayer()
	local selfPlayer = MainPlayerController:GetPlayer()
	selfPlayer.isShowHeadBoard = false
	local avatar = selfPlayer:GetAvatar()
	avatar.setSkipNormal = {}
	if avatar and avatar.objNode then
		avatar.objNode.visible = false
		avatar:SetPendantsVisible(false);
	end
	if selfPlayer:GetMagicWeaponFigure() then
		local wavatar = selfPlayer:GetMagicWeaponFigure()
		if wavatar and wavatar.objNode then
			wavatar.objNode.visible = false
		end
	end
	if selfPlayer:GetLingQiFigure() then
		local wavatar = selfPlayer:GetLingQiFigure()
		if wavatar and wavatar.objNode then
			wavatar:StopAutoIdle()
			wavatar.objNode.visible = false
		end
	end
	if selfPlayer:GetMingYuFigure() then
		local wavatar = selfPlayer:GetMingYuFigure()
		if wavatar and wavatar.objNode then
			wavatar.objNode.visible = false
		end
	end
	if selfPlayer.tianshen then
		if selfPlayer.tianshen.objNode then
			selfPlayer.tianshen.objNode.visible = false
		end
	end
	local npc = NpcController.questNpc
	if npc then
		npc:HideSelf(true)
	end
	local pet = selfPlayer.pet
	if pet then
		if pet.objNode then
			pet.objNode.visible = false
		end
	end
end

function ArenaBattle:ShowSelfPlayer()
	local selfPlayer = MainPlayerController:GetPlayer()
	selfPlayer.isShowHeadBoard = true
	local npc = NpcController.questNpc
	if npc then
		npc:HideSelf(false)
	end
end

function ArenaBattle:HideAllUI()
	--设置鼠标键盘不可以用
	CControlBase:SetControlDisable(true)
	--关闭所有ui
	UIManager:HideLayerBeyond("story", "float", "loading")
	UIArena:Hide()
end

function ArenaBattle:ShowAllUI()
	UIManager:RecoverAllLayer()
	FuncManager:OpenFunc(FuncConsts.Arena, true)
end

function ArenaBattle:ResetArenaBattle()
	ArenaBattle.inArenaScene = 0
	--设置鼠标键盘可用
	TimerManager:RegisterTimer(function()
		CControlBase:SetControlDisable(false)
	end, 1000, 1)
end

function ArenaBattle:InitPlayer(msg)
	for i = 1, 2 do 
		local playerInfo = msg.ArenaMemlist[i]
		local player = ArenaBattle:AddPlayer(i, playerInfo)
	    ArenaBattle.playerList[i] = player
	end
end

function ArenaBattle:AddPlayer(index, playerInfo)
	local info = {}
	info.dwRoleID = index
	info.dwSex = playerInfo.sex
	info.dwProf = playerInfo.prof
	info.dwArms = playerInfo.arms
	info.dwDress = playerInfo.dress
	info.dwFashionsHead = playerInfo.fashionshead
	info.dwFashionsArms = playerInfo.fashionsarms
	info.dwFashionsDress = playerInfo.fashionsdress
	info.dwWing = playerInfo.wing
	info.suitflag = playerInfo.suitflag
	info.dwLevel = playerInfo.level
	info.szRoleName = playerInfo.roleName
	info.dwCurrHP = playerInfo.hp * 7
	info.dwMaxHP = playerInfo.hp * 7
	info.posX = ArenaBattle.posList[index].x
	info.posY = ArenaBattle.posList[index].y
	info.dir = ArenaBattle.posList[index].dir
	info.wuhun = playerInfo.wuhunId
	info.magicWeapon = playerInfo.shenbing
	info.lingQi = playerInfo.lingqi
	info.mingYu = playerInfo.mingyu
	local player = CPlayer:new(info.dwRoleID)
	if not player then
		Error("new Player Error")
		return
	end
	if not player:Create(info) then
		Error("Create Player Error")
		return
	end
	player:SetPlayerInfoByType(enAttrType.eaHp, info.dwCurrHP)
 	player:SetPlayerInfoByType(enAttrType.eaMaxHp, info.dwCurrHP)
 	player.skillList = {}
 	for _, SkillVO in pairs(playerInfo.skillList) do
 		if SkillVO.skillid ~= 0 then
 			table.insert(player.skillList, SkillVO.skillid)
 		end
 	end
 	if #player.skillList == 0 then
 		local defSkillId = MainPlayerController:GetNormalAttackSkillIdByProf(playerInfo.prof)
 		if defSkillId and defSkillId ~= 0 then
 			table.insert(player.skillList, defSkillId)
 		end
 	end
    local atk = playerInfo.atk
 	local subdef = playerInfo.subdef
 	local def = playerInfo.def
 	local cri = playerInfo.cri
 	local crivalue = playerInfo.crivalue
 	local absatk = playerInfo.absatk
 	local defcri = playerInfo.defcri
 	local subcri = playerInfo.subcri
 	local dmgsub = playerInfo.dmgsub
 	local dmgadd = playerInfo.dmgadd
 	local level = playerInfo.level
	player.battleInfo = {atk = atk,
						  subdef = subdef,
						  def = def,
						  cri = cri,
						  crivalue = crivalue,
						  absatk = absatk,
						  defcri = defcri,
						  subcri = subcri,
						  dmgsub = dmgsub,
						  dmgadd = dmgadd,
						  level = level,
						}
	player.icon = playerInfo.icon
	player.prof = playerInfo.prof
	player.power = playerInfo.power
	player:EnterMap(CPlayerMap.objSceneMap, info.posX, info.posY, info.dir)
    player:GetAvatar():ChangeArms()
    player:ResetPfx()
    CPlayerMap:AddPlayer(player)
    return player
end

function ArenaBattle:StartAction()
	for i, player in pairs(ArenaBattle.playerList) do
		player:DoMoveTo({x = ArenaBattle.posList1[i].x, y = ArenaBattle.posList1[i].y}, function()
			player:GetAvatar():StopMoveByRender()
			player:PlayHeti()
			local wuhunId = player:GetWuhun()
			player:PlayWuhunXiuXianPfx(wuhunId)
			player:ResetPfx()
		end , false, ArenaBattle.posList1[i].speed)
	end
	TimerManager:RegisterTimer(function()
		UIArenahp:Show()
		local fun = function()
			ArenaBattle:StarFig()
		end
		TimerManager:RegisterTimer(function()
			UIArenaVsAn:PlayAnimation(fun)
		end, 500, 1)
	end, 3000, 1)
end

function ArenaBattle:StartStory()
	local info = ArenaModel : GetMyroleInfo()
	
	local callback1 = function()
		ArenaBattle:HideAllUI()
		ArenaBattle:HideSelfPlayer()
		ArenaBattle:StartAction()
	end
	if info.chal ~= 0 then 
        callback1();
	 	return
	end
	StoryController:StoryStartArena("jing1001", callback1)
end

function ArenaBattle:StopPlayerAction()
	for _, timeID in pairs(ArenaBattle.timePlan) do
		if timeID then
			TimerManager:UnRegisterTimer(timeID)
		end
	end
	ArenaBattle.timePlan = {}
	for _, player in pairs(ArenaBattle.playerList) do
		local avatar = player:GetAvatar()
		avatar.setSkipNormal = {}
	end
end

function ArenaBattle:ShowResult()
	ArenaBattle.arenaState = false
	ArenaBattle:StopPlayerAction()
	ArenaBattle:ShowCloseUI()
	ArenaBattle:HideSkipBtn()
end

function ArenaBattle:ShowCloseUI()
	TimerManager:RegisterTimer(function()
		local fun = function()
			ArenaBattle:Close()
		end
		UIArenaResult:setShow(fun)
	end, 3000, 1)
end

function ArenaBattle:Close()
	UIArenahp:Hide()
	ArenaBattle:ExitScene()
end

function ArenaBattle:ExitScene()
	ArenaBattle:ShowAllUI()
	UILoadingScene:Open(false)
	CPlayerMap:DelRole(1)
	CPlayerMap:DelRole(2)
	ArenaBattle.inArenaScene = 2
	ArenaBattle:ShowSelfPlayer()
	ArenaController:ReqQuitArena()
end


--a 对 b释放了技能skillId
function ArenaController:GetDamage(skillId, player_a, player_b)
    local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local skillLevel = skillConfig.level
	local atk_a = player_a.battleInfo.atk --攻击力
	local subdef_a = player_a.battleInfo.subdef --减防
	local def_a = player_a.battleInfo.def-- 防御
	local cri_a = player_a.battleInfo.cri--暴击率
	local crivalue_a = player_a.battleInfo.crivalue--暴击倍率
	local absatk_a = player_a.battleInfo.absatk--绝对伤害
	local defcri_a = player_a.battleInfo.defcri--免暴
	local subcri_a = player_a.battleInfo.subcri--减免暴击伤害
	local dmgsub_a = player_a.battleInfo.dmgsub--减伤
	local dmgadd_a = player_a.battleInfo.dmgadd--伤害加深
	local level_a = player_a.battleInfo.level --等级

	local atk_b = player_b.battleInfo.atk --攻击力
	local subdef_b = player_b.battleInfo.subdef --减防
	local def_b = player_b.battleInfo.def-- 防御
	local cri_b = player_b.battleInfo.cri--暴击率
	local crivalue_b = player_b.battleInfo.crivalue--暴击倍率
	local absatk_b = player_b.battleInfo.absatk--绝对伤害
	local defcri_b = player_b.battleInfo.defcri--韧性
	local subcri_b = player_b.battleInfo.subcri--减免暴击伤害
	local dmgsub_b = player_b.battleInfo.dmgsub--减伤
	local dmgadd_b = player_b.battleInfo.dmgadd--伤害加深
	local level_b = player_b.battleInfo.level --等级

	--第一步 计算防御
	local tar_defvalue = math.max(1, def_b - subdef_a)
	--第二步 计算免伤率
	local subdef_param1 = t_lvup[skillLevel].lv_subdamage  -- 随人物等级变化读取配置表
	local subdef_param2 = 0.8
	local subdef_param3 = 0
	local tar_subdef_rate = tar_defvalue / (tar_defvalue + level_a * subdef_param1) * subdef_param2 + subdef_param3
	local atk_min = 0.95
	local atk_max = 1.05
	local skill_damge_param, skill_exter_damage = SkillController:GetDamage(skillId) -- 读效果表
	local f1 = (atk_a * math.random(atk_min, atk_max) * skill_damge_param + skill_exter_damage) * (1 - tar_subdef_rate)
	--第三步 计算暴伤
	local cri_rate_param1 = 0.6
	local cri_rate_param2 = 0
	local cri_rate_param3 = 3
	local cri_param1 = 0
	local cri_param2 = 0.2
	local cri_rate = cri_a / (cri_a + defcri_b * cri_rate_param3) * cri_rate_param1 + cri_rate_param2
	local cri_value =math.max(crivalue_a - subcri_b + cri_param1, cri_param2)
	--第四步 计算伤害
	--暴击
	local criDamage = (f1 + absatk_a) * (1 + cri_value)
	--未暴击
	local damage = f1 + absatk_a
	local cri = false
	if cri_rate > math.random(0, 1) then
		cri = true
	end
	return cri, criDamage, damage
end

function ArenaBattle:AutoBattle()
	local nowTime = GetCurTime()
	for id, player in pairs(ArenaBattle.playerList) do
		if not player.stiff_time then
			player.stiff_time = 0
		end
		if player.stiff_time <= nowTime then
			local skillIndex = math.random(1, #player.skillList)
			local skillId = player.skillList[skillIndex]
			if t_skill[skillId] 
				and (player.lastSkillId ~= skillId or player.lastSkillId == player:GetDefSkillId())
				and ArenaBattle:CheckSkillCD(id, skillId) then
				--计算伤害次数和硬直时间
				local stiff_time, damage_delay_time = ArenaBattle:GetSkillStiffTime(skillId)
				--算伤害
				local selfPlayer = nil
				local otherPlayer = nil
				local castCid = id
				local targetCid = 0
				if id == 1 then
					selfPlayer = ArenaBattle.playerList[1]
					otherPlayer = ArenaBattle.playerList[2]
					targetCid = 2
				elseif id == 2 then
					selfPlayer = ArenaBattle.playerList[2]
					otherPlayer = ArenaBattle.playerList[1]
					targetCid = 1
				end
				local is_cri, cri_damage, nor_damage = ArenaController:GetDamage(skillId, selfPlayer, otherPlayer)
				
				local selfHP = selfPlayer:GetPlayerInfoByType(enAttrType.eaHp)
				local otherHP = otherPlayer:GetPlayerInfoByType(enAttrType.eaHp)
				local selfMaxHP = selfPlayer:GetPlayerInfoByType(enAttrType.eaMaxHp)
				local otherMaxHP = otherPlayer:GetPlayerInfoByType(enAttrType.eaMaxHp)
				
				--血量少就暴击
				if selfHP < selfMaxHP * 0.1 or otherHP < otherMaxHP * 0.1 then 
					if ArenaBattle.winId == id and selfHP < otherHP then
						is_cri = true
					elseif ArenaBattle.winId ~= id and selfHP > otherHP then
						is_cri = false
					end
				end

				local sumdamage = 0
				if is_cri then
					sumdamage = (#damage_delay_time) * cri_damage
				else
					sumdamage = (#damage_delay_time) * nor_damage
				end

				--判断这次伤害是否将人打死 打死就miss
				local miss = false
				if otherHP <= sumdamage and ArenaBattle.winId ~= id then
					miss = true
				end

				--展示伤害
				local flags = 0
				local damage = 0
				if is_cri then
					damage = cri_damage
					flags = 2
				else
					damage = nor_damage
				end
				if miss then
					flags = 1
				end

				if damage > 0 and stiff_time > 0 then
					selfPlayer.stiff_time = nowTime + stiff_time + 300
					selfPlayer:GetAvatar():PlaySkillOnArena(skillId)
					selfPlayer.lastSkillId = skillId
					ArenaBattle:SetSkillCD(id, skillId)
					for _, delayTime in pairs(damage_delay_time) do
						local timeID = TimerManager:RegisterTimer(function()
							SkillController:CastEffect(castCid, targetCid, skillId, damage, flags)
							if not miss then								
								local currHp = otherPlayer:GetPlayerInfoByType(enAttrType.eaHp)
								currHp = math.max(0, currHp - damage)
								otherPlayer:SetPlayerInfoByType(enAttrType.eaHp, currHp)
								Notifier:sendNotification(NotifyConsts.ArenaRoleInfoChang)
							end
					    end, delayTime, 1)
						table.insert(ArenaBattle.timePlan, timeID)
					end
				end
			end
		end
	end
end

function ArenaBattle:CheckResult()
	for index, player in pairs(ArenaBattle.playerList) do
		local currHp = player:GetPlayerInfoByType(enAttrType.eaHp)
		if currHp <= 0 and ArenaBattle.winId ~= index then
			player:Dead()
			return true
		end
	end
	return false
end

function ArenaBattle:GetSkillStiffTime(skillId)
	local stiff_time = 0
	local damage_delay_time = {}
	local skillConfig = t_skill[skillId]
	if skillConfig then
		local delay_time = SkillController:GetSkillDelayTime(skillId)
		local skill_type = skillConfig.oper_type
		if skill_type == SKILL_OPER_TYPE.PREP then
			local time = math.min(skillConfig.prep_time, 1000)
			delay_time = delay_time + time
			table.insert(damage_delay_time, delay_time)
			stiff_time = skillConfig.stiff_time + time
		elseif skill_type == SKILL_OPER_TYPE.CHAN then
			local chant_inter = skillConfig.chant_inter
			local chant_time = skillConfig.chant_time
			local count = math.ceil(chant_time / chant_inter) + 1
			for i = 1, count do
				table.insert(damage_delay_time, delay_time)
				delay_time = delay_time + chant_inter
			end 
			stiff_time = skillConfig.chant_time
		elseif skill_type == SKILL_OPER_TYPE.COMBO then
			-- local count = math.floor(skillConfig.combo_time / skillConfig.stiff_time)
			-- stiff_time = count * skillConfig.stiff_time
			-- for i = 1, count do
			-- 	table.insert(damage_delay_time, delay_time)
			-- 	delay_time = delay_time + delay_time
			-- end
		elseif skill_type == SKILL_OPER_TYPE.MULTI then
			
		elseif skill_type == SKILL_OPER_TYPE.JUMP then
			stiff_time = SkillController:GetRollTime(skillId)
			table.insert(damage_delay_time, delay_time)
		elseif skill_type == SKILL_OPER_TYPE.DEF then
			stiff_time = skillConfig.stiff_time
			table.insert(damage_delay_time, delay_time)
		end
	end
	return stiff_time, damage_delay_time
end

function ArenaBattle:SetResult()
	for index, player in pairs(ArenaBattle.playerList) do
		if ArenaBattle.winId ~= index then
			player:SetPlayerInfoByType(enAttrType.eaHp, 0)
			Notifier:sendNotification(NotifyConsts.ArenaRoleInfoChang)
		end
	end
end
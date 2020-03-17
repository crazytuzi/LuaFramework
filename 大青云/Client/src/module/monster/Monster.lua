_G.classlist['Monster'] = 'Monster'
_G.Monster = {}
Monster.objName = 'Monster'

local metaMonster = {__index = Monster}
function Monster:new()
	local monster = {}
	setmetatable(monster, metaMonster)
	return monster
end

function Monster:NewMonster(cid, monsterId, x, y, faceto, speed)
	local cfgMonster = t_monster[monsterId]
	if not cfgMonster then
		Error("don't exist this monster  monsterId" .. monsterId)
		return
	end
	local monster = Monster:new()
	monster.monsterId = monsterId
	monster.cid = cid
	monster.x = x
	monster.y = y
	monster.__type = "monster"
	monster.faceto = faceto
	monster.speed = speed or 0
	monster.avatar = MonsterAvatar:NewMonsterAvatar(cid, monsterId)	
	if not monster:IsShowLoading() then
		monster.avatar.avatarLoader.unShowLoading = true;
	end
	monster.avatar.avatarLoader:beginRecord(true)
	monster.avatar:InitAvatar()
	monster.avatar.avatarLoader:endRecord()
	monster.isDead = false
	monster.currHP = 0
	monster.maxHP = 0
	monster.battleState = false
	monster.buffInfo = BuffInfo:new()
	monster.stateInfo = StateInfo:new()
	monster.leisureTime = GetCurTime() + 10000
	monster.randomLeisureTime = math.random(1, 3) * 1000
	monster.whiteLightTime = nil
	monster.isShowHeadBoard = true
	monster.headBorad = nil
	monster.monstertalk = {}
	monster.monstersay = nil
	monster.mRealName = nil
	monster.mRealIcon = nil
	--剧情怪的巡逻
	monster.dwDumpTime = 0
	monster.dunpTime = 1000 * math.random(0,5)
	monster.startX = x
	monster.startY = y
	monster.isStory = nil
	monster.delayTimeKey = nil	
	
	if cfgMonster.monstersay and cfgMonster.monstersay ~= "" then
		monster.monstersay = GetCommaTable(cfgMonster.monstersay)		
	end
	return monster
end

function Monster:IsShowLoading()
	local monsterCfg = t_monster[self.monsterId]
	if monsterCfg then
		if monsterCfg.isHideLoading and monsterCfg.isHideLoading == 1 then
			return false	
		end
	end
	
	return true
end

function Monster:GetMonsterId()
	return self.monsterId 
end

function Monster:GetCid()
	return self.cid
end

function Monster:GetDir()
	return self:GetAvatar():GetDirValue()
end

--怪物名
function Monster:GetName()
	local monsterCfg = t_monster[self.monsterId]
	if _G.isDebug and self.avatar then
		return monsterCfg.name .. self.avatar:GetStatInfo();
	end
	return monsterCfg.name
end

function Monster:GetPos()
	if self.avatar then
		return self.avatar:GetPos()
	end
end

function Monster:GetCurrHP()
	return toint(self.currHP, 0.5)
end

function Monster:SetCurrHP(currHP)
	self.currHP = currHP
end

function Monster:GetMaxHP()
	return self.maxHP
end

function Monster:SetMaxHP(maxHP)
	self.maxHP = maxHP
end

function Monster:GetAvatar()
	return self.avatar
end

function Monster:IsDead()
	if self.isDead then
		return true
	end
	if self:GetStateInfoByType(PlayerState.UNIT_BIT_DEAD) == 1 then
		return true
	end
	return false
end

function Monster:GetActionIdByName(actionName)
	local monster_id = self.monsterId
	local cfgMonster = t_monster[monster_id]
	if not cfgMonster then
		Error("don't exist this monster monsterId" .. monster_id)
		return
	end
	local model = t_model[cfgMonster.modelId]
	if not model then
		Error("don't exist this monster model" .. cfgMonster.modelId)
		return
	end
	return model["san_" .. actionName]
end

function Monster:Update(interval)
	self:DrawHeadBoard()
	self:Leisure()
	self:UpdateBuff(interval)
	--剧情怪的巡逻
	if self:GetIsStory() and not self:IsMoveState() then
		self.dwDumpTime = self.dwDumpTime + interval
		
		if self.dwDumpTime > self.dunpTime then
			self.dwDumpTime = self.dwDumpTime - self.dunpTime
			self.dunpTime = 1000 * math.random(0,5)
			local speed = 20
			local endX = self.startX + math.random(-20,20)
			local endY = self.startY + math.random(-20,20)
			if AreaPathFinder:CheckPoint(endX,endY) then
				self:MoveTo(endX, endY, speed)
			end
		end
	end
end

function Monster:SetIsStory(value)
	self.isStory = value
end

function Monster:GetIsStory()
	return self.isStory
end

function Monster:AddSkipNumber(noticeType, value)
	if StoryController:IsStorying() then return end

	local noticeInfo = NOTICE["other"][noticeType]
	if not noticeInfo then
		return
	end
	
	local skipConfig = noticeInfo.skipConfig
	local text = noticeInfo.text
	local number = math.abs(value)

	local param = {
		config = skipConfig,
		text = text,
		number = number,
	}
	self:GetAvatar():DrawSkipNumber(param)
end


-- id,30#id,50

function Monster:UpdateHPInfo(currHP, maxHP)
	if currHP then
		self:SetCurrHP(currHP)
	end
	if maxHP then
		self:SetMaxHP(maxHP)
	end
	
	local cfg = t_monster[self.monsterId]
	-- cfg.monstertalk = "1,30#2,50"
	if cfg and cfg.monstertalk and cfg.monstertalk ~= "" then
		local cfgList = split(cfg.monstertalk, "#")
		local curTalkHp = self.currHP/self.maxHP*100		
		for k,v in pairs (cfgList) do
			local talkStrList = split(v, ",")
			local talkId = tonumber(talkStrList[1])
			local talkHp = tonumber(talkStrList[2])
			if curTalkHp <= talkHp then
				if self.monstertalk and not self.monstertalk[talkHp] then
					-- 播放冒泡
					self:OnTalk(talkId)
					self.monstertalk[talkHp] = true
					break
				end
			end
		end
	end
end

function Monster:UpdateSpeed(speed)
	self:SetSpeed(speed)
	self.avatar:UpdateSpeed(speed)
end

function Monster:SetSpeed(speed)
	self.speed = speed
end

function Monster:GetSpeed()
	return self.speed
end

function Monster:StopMoveFormerPlace()
	if self:IsMoveState() then
		self.avatar:StopMove(self:GetPos(), self:GetDir())
	end
end

function Monster:ClearTarget()
	if self.cid == SkillController:GetCurrTargetCid() then
		SkillController:ClearTarget()
	end
end

function Monster:GetDeadType(skillId)
	local result = 0
	local flyDis = 0
	local monster_id = self.monsterId
	local cfgMonster = t_monster[monster_id]
	if not cfgMonster then
		Error("don't exist this monster monsterId" .. monster_id)
		return 0, 0
	end

	if cfgMonster.can_fly == 1 then
		return 0, 0
	end

	local model = t_model[cfgMonster.modelId]
	if not model then
		Error("don't exist this monster model" .. monster_id)
		return 0, 0
	end

	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return 0, 0
    end

	local flyRandomConfig = skillConfig.knockback
	if not flyRandomConfig or flyRandomConfig == "" then
		return 0, 0
	end

	local flyConfig = GetVerticalTable(flyRandomConfig)
	if #flyConfig ~= 3 then
		return 0, 0
	end

	local flyConfig1 = flyConfig[1]
	local flyConfig2 = flyConfig[2]
	local flyConfig3 = flyConfig[3]

	local flyTable1 = GetPoundTable(flyConfig1)
	local flyTable2 = GetPoundTable(flyConfig2)
	local flyTable3 = GetPoundTable(flyConfig3)

	local flyRandom = math.random(1, 100)
	if flyRandom <= tonumber(flyTable1[1]) then
		result = 1
		flyDis = math.random(tonumber(flyTable1[2]), tonumber(flyTable1[3]))
	elseif flyRandom <= tonumber(flyTable1[1]) + tonumber(flyTable2[1]) then
		result = 2
		flyDis = math.random(tonumber(flyTable2[2]), tonumber(flyTable2[3]))
	else
		result = 3
		flyDis = math.random(tonumber(flyTable3[2]), tonumber(flyTable3[3]))
	end

	if flyDis <= 0 then
		result = 0
	elseif flyDis <= 10 then
		result = 1
	end

	if not model["san_deadfly"] or model["san_deadfly"] == "" then
		if flyDis > 0 then
			result = 1
		else
			result = 0
		end
	end
	return result, flyDis
end

function Monster:GetFlyPos(flyDis)
	local pos = self.avatar:GetPos()
	local pos1 = MainPlayerController:GetPlayer():GetPos()
	local dir = GetDirTwoPoint(pos, pos1)
	SkillController:CharChangeDirToPos(self.cid, pos1)
	local x = pos.x - flyDis * math.sin(dir)
	local y = pos.y + flyDis * math.cos(dir)
	local z = CPlayerMap:GetSceneMap():getSceneHeight(x, y)
	return {x = x, y = y, z = z}
end

function Monster:ClearMonsterTalk()
	if #self.monstertalk > 0 then
		self.monstertalk = nil
		self:OnTalk(nil)
	end
	if self.monstersay and #self.monstersay > 0 then
		self.monstersay = nil
		self:OnTalk(nil)
	end
end

--怪物死亡
function Monster:Dead(skillId, killerId,effectType)	
	Notifier:sendNotification(NotifyConsts.MascotComeKillID,{monsterID = self.monsterId});
	effectType = effectType or 0;
	if effectType > 0 then
		self.avatar.EffectLimit = function() return self:EffectLimit(); end;
	end
	self:ClearMonsterTalk()	
	self.isDead = true
	self:ClearTarget()
	self:StopAlarm()
	self:StopMoveFormerPlace()
	self.avatar:StopAllAction()
	self.avatar:SetNullPick()
	self.avatar.setSkipNormal = {}
	self:DeadStory(killerId)
	self:DeadSound()
	local result, flyDis = self:GetDeadType(skillId)
	if result == 0 then
		local deadActionFile = self:GetActionIdByName("dead")
	    self.avatar:DoAction(deadActionFile, false, function() end)
	elseif result == 1 then
		local selfPos = self:GetPos()
		local flyPos = self:GetFlyPos(flyDis)
    	local dis = math.sqrt((flyPos.x - selfPos.x)^2 + (flyPos.y - selfPos.y)^2)
		local deadActionFile = self:GetActionIdByName("dead")
	    self.avatar:DoAction(deadActionFile, false, function() end)
	    if dis > 0 then
	    	local speed = 50
			local time = dis / speed * 1000
	    	self.avatar.objNode.transform:mulTranslationRight(flyPos.x - selfPos.x, flyPos.y - selfPos.y, flyPos.z - selfPos.z, time)
	    end
	elseif result == 2 then
		local selfPos = self:GetPos()
		local flyPos = self:GetFlyPos(flyDis)
    	local dis = math.sqrt((flyPos.x - selfPos.x)^2 + (flyPos.y - selfPos.y)^2)
		local deadActionFile = self:GetActionIdByName("deadfly")
		local deadTable = GetPoundTable(deadActionFile)
	    self.avatar.flyState = true
	    self.avatar:DoAction(deadTable[1], true)
	    if dis > 0 then
		    local speed = 100
			local time = dis / speed * 1000
	 		self.avatar.objNode.transform:mulTranslationRight(flyPos.x - selfPos.x, flyPos.y - selfPos.y, flyPos.z - selfPos.z, time)
		    if self.deadFlyTime then
				TimerManager:UnRegisterTimer(self.deadFlyTime)
			end
		    self.deadFlyTime = TimerManager:RegisterTimer(function()
		        self.avatar:StopAction(deadTable[1])
		        if deadTable[2] then
		    		self.avatar:DoAction(deadTable[2], false, function()
		    			self.avatar.flyState = false
		    		end)
		    	else
		    		self.avatar.flyState = false
			    end
		    end, time, 1)
		end
	elseif result == 3 then
		local selfPos = self:GetPos()
		local flyPos = self:GetFlyPos(flyDis)
    	local dis = math.sqrt((flyPos.x - selfPos.x)^2 + (flyPos.y - selfPos.y)^2)
		local deadActionFile = self:GetActionIdByName("deadfly")
		local deadTable = GetPoundTable(deadActionFile)
	    self.avatar.flyState = true
	    self.avatar:DoAction(deadTable[1], true)
	    if dis > 0 then
		    local speed = 150
			local time = dis / speed * 1000
			self.avatar:BezierTo(flyPos, time, function()
				self.avatar:StopAction(deadTable[1])
		        if deadTable[2] then
		    		self.avatar:DoAction(deadTable[2], false, function()
		    			self.avatar.flyState = false
		    		end)
		    	else
		    		self.avatar.flyState = false
			    end
			end)
		end
	end
end

function Monster:EffectLimit()
	return false;
end

function Monster:DeadSound()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	if not cfgMonster.DeathSound then
		return
	end
	if cfgMonster.DeathSound == 0 then
		return
	end
	SoundManager:PlaySfx(cfgMonster.DeathSound)
end

function Monster:DeadStory(killerId)
	if self:IsHide() then
		return
	end
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	if cfgMonster.dead_story and cfgMonster.dead_story == 0 then
		return
	end
	_app.speed = 0.5
	StoryController:ZoomInCamera()
	TimerManager:RegisterTimer(function()
        _app.speed = 1
    end, 3000, 1)
end

function Monster:KnockBack(time, pos)
	self.avatar.knockBackState = true
	pos.z = CPlayerMap:GetSceneMap():getSceneHeight(pos.x, pos.y)
	local selfPos = self:GetPos()
    self.avatar.objNode.transform:mulTranslationRight(pos.x - selfPos.x, pos.y - selfPos.y, pos.z - selfPos.z, time * 0.9)
    if self.knockbackTime then
		TimerManager:UnRegisterTimer(self.knockbackTime)
	end
    self.knockbackTime = TimerManager:RegisterTimer(function()
    	if self:IsDead() == false then
	       	self.avatar.knockBackState = false
		end
    end, time, 1)
end

function Monster:GetBuffInfo()
	return self.buffInfo
end

function Monster:Stun()
	local stunActionFile = self:GetActionIdByName("stun")
	self.avatar:DoAction(dstunActionFile, true)
	self:AddStun()
end

local stunV = _Vector3.new()
local stunM = _Matrix3D.new()
function Monster:AddStun()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	local npcNameZ = cfgMonster.height or 1
	stunV.z = npcNameZ
	stunM:setTranslation(stunV)
	self.avatar:PlayerPfxByMat(10008, stunM)
end

function Monster:StopStun()
	local stunActionFile = self:GetActionIdByName("stun")
	self.avatar:DoStopAction(dstunActionFile)
	self.avatar:StopPfx(10008)
end

function Monster:SetTranslucence()
	self.translucence = true
	self.avatar:SetBlender( 0x8fffffff )
end

function Monster:DeleteTranslucence()
	if self.translucence == true then
		self.translucence = false
		self.avatar:DeleteBlender()
	end
end

function Monster:SetBattleState(battleState)
	if self:IsDead() then
		return
	end
	self.avatar:SetAttackAction(battleState)
	if battleState == false then
		if self:IsMoveState() then
			self:SetTranslucence()
		end
		self.battleState = battleState
	else
		self:AddAlarm()
		self:DeleteTranslucence()
		self.battleState = battleState
	end
end

function Monster:StopMove(x, y, faceto)
	if self:IsDead() then
		return
	end
	local currPos = self:GetPos()
	if not currPos then
		return
	end
	local vecPos = {x = x, y = y}
	-- local dis = math.sqrt((currPos.x - vecPos.x)^2 + (currPos.y - vecPos.y)^2) 
	-- if dis > 15 then
	-- 	local speed = self:GetSpeed()
	-- 	self:MoveTo(x, y, speed)		
	-- else
		if self:IsMoveState() then
			self:DeleteTranslucence()
		end
		self.avatar:StopMove(vecPos, faceto)
	-- end
end

function Monster:MoveTo(x, y, speed)
	if self:IsDead() then
		return
	end
	self:SetSpeed(speed)
	local vecPos = {x = x, y = y}
	self.avatar:MoveTo(vecPos, function()
		self:DeleteTranslucence()
		self.avatar:StopMove()
	end, speed)
end

function Monster:Show()
	self.avatar:EnterMap(self.x, self.y, self.faceto)
	self:AddFootPfx()
	self:AddStarLight()
	self:AddPickbox()
end

function Monster:SetBornVisible()
	if self:IsBornVisible() then
		self.avatar.objNode.visible = false
	end
end

function Monster:AddStarLight()
	if not self:IsStar() then
		return
	end
	local objStarLight = CSceneMap.skyMonsterStar
	self.avatar:SetSelectLight( objStarLight )
end

function Monster:SetHighLight()
	if self:IsStar() then
		return
	end
	local objSelectLight = CSceneMap.skyMonsterSelect
	self.avatar:SetSelectLight( objSelectLight )
end

function Monster:DelHighLight()
	if self:IsStar() then
		return
	end
	if self.cid ~= SkillController:GetCurrTargetCid() then
		self.avatar:DeleteSelectLight()
	end
end

function Monster:ExitMap()
	self:ClearMonsterTalk()	
	MonsterModel:DeleteMonsterByCid(self.cid)
	self:ClearTimePlan()
	self.buffInfo = nil
	self.stateInfo = nil
	self.isStory = nil
	self.avatar:ExitMap()
	self.avatar = nil
	if self.headBorad then
		self.headBorad:Destory()
		self.headBorad = nil
	end
end

function Monster:AddFootPfx()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	if cfgMonster.foot_pfx and cfgMonster.foot_pfx ~= "" then
		self.avatar:PlayerPfxOnSkeleton(cfgMonster.foot_pfx)
	end
end

function Monster:DeleteFootPfx()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	if cfgMonster.foot_pfx and cfgMonster.foot_pfx ~= "" then
		self.avatar:StopPfxByName(cfgMonster.foot_pfx)
	end
end

local alarmM = _Matrix3D.new()
function Monster:AddAlarm()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	local npcNameZ = cfgMonster.height or 1
	local scale = cfgMonster.scale or 1
 	alarmM:setTranslation(0, 0, npcNameZ/scale)
	self.avatar:PlayerPfxByMat(10000, alarmM)
end

function Monster:StopAlarm()
	self.avatar:StopPfx(10000)
end

function Monster:GetMonsterType()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	local monsterType = cfgMonster.type
	return monsterType
end

function Monster:IsPunish()
	local avatar = self:GetAvatar()
	if avatar.jumpState then
		return false
	end
	if avatar.flyState then
		return false
	end
	if avatar.rollState then
		return false
	end
	if avatar.knockBackState then
		return false
	end
	if avatar.stoneGazeState then
		return false
	end
	return true
end

function Monster:SetMouseOver(flag)
	self.isMouseOver = flag
end

function Monster:DrawHeadBoard()
	if not self.isShowHeadBoard then
		return
	end
	if not CPlayerControl.showName then
		return
	end
	if not self.avatar then return end
	if not self.avatar.objNode then return end
	if not self.avatar.objMesh then return end
	if self:IsDead() then
		return
	end
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	if SetSystemController.hideMonster == false or SetSystemController.hideMonsterName then
		if cfgMonster.show_name == 0
			and not (self.isMouseOver == true  or self.cid == SkillController.targetCid or self.battleState == true)then
			return
		end
	end

    local mePos = self:GetPos()
	if not self.headBorad then 
		-- 境界图标
		local cfg = CUICardConfig[999]
		-- FTrace(cfgMonster)
		local txtcolor = nil
		if MonsterController:MonsterIsAttack(self.cid) then
			txtcolor = cfg.monster_name_txtcolor_battle
		else
			txtcolor = cfg.monster_name_txtcolor_friend
		end
		self.headBorad = MonsterHeadBoard:new(cfgMonster.height, self:GetName(), cfgMonster.title, cfgMonster.title_image, cfgMonster.starLvl, cfg.monster_name_edgecolor_battle, txtcolor) 
	end
	if not mePos then 
		Debug('Error:Monster self:GetPos() is nil') return
	else 
		self.headBorad:Update(self:GetMonsterId(), mePos.x, mePos.y, mePos.z, self:GetCurrHP(), self:GetMaxHP(), cfgMonster.show_name)
	end
end

function Monster:SetHeadBoardColor()
	if self.headBorad then
		local cfg = CUICardConfig[999]
		local textColor = nil
		local edgeColor = nil
		if MonsterController:MonsterIsAttack(self.cid) then
			textColor = cfg.monster_name_txtcolor_battle
			edgeColor = cfg.monster_name_edgecolor_battle
		else
			textColor = cfg.monster_name_txtcolor_friend
			edgeColor = cfg.monster_name_edgecolor_battle
		end
		self.headBorad:SetColor(textColor, edgeColor)
	end
end

function Monster:GetWidth()
	local monster_id = self.monsterId
	local cfgMonster = t_monster[monster_id]
	if not cfgMonster then
		Error("don't exist this monster monsterId" .. npcId)
		return
	end
	return ((cfgMonster.width and cfgMonster.width ~= 0) and cfgMonster.width or 10) 
end

local scale_mat = _Matrix3D.new()
function Monster:Born()
	if self:IsBornVisible() then
		self.bornTime = TimerManager:RegisterTimer(function()
			if self.avatar and self.avatar.objNode then
				self.avatar.objNode.visible = true
			end
		end, 250, 1)
	end
	local actionName = self:GetActionIdByName("born")
	if actionName and actionName ~= "" then
		self.avatar:DoAction(actionName, false)
		local monsterId = self.monsterId
		local cfgMonster = t_monster[monsterId]
		if cfgMonster.born_pfx and cfgMonster.born_pfx ~= "" then
			local width = cfgMonster.width or 10
	        scale_mat:setScaling(width/10, width/10, width/10)
	        self.avatar:PlayerPfxOnSkeleton(cfgMonster.born_pfx, scale_mat)
		end
	end
end

function Monster:GetStateInfo()
	return self.stateInfo
end

function Monster:GetStateInfoByType(stateType)
	return self.stateInfo:GetValue(stateType)
end

function Monster:IsMoveState()
	return self:GetAvatar().moveState
end

function Monster:IsLeisureState()
	if not self:GetAvatar() then
		return false
	end
	if self:IsDead() then
		return false
	end
	if not self:IsPunish() then
		return false
	end
	if self:IsMoveState() then
		return false
	end
	if self:GetStateInfoByType(PlayerState.UNIT_BIT_GOD) == 1 then
		return false
	end
	if self:GetStateInfoByType(PlayerState.UNIT_BIT_INCOMBAT) == 1 then
		return false
	end
	return true
end

function Monster:IsGod()
	if self:GetStateInfoByType(PlayerState.UNIT_BIT_GOD) == 1 then
		return true
	end
	return false
end

function Monster:Leisure()
	local nowTime = GetCurTime()
	if not self:IsLeisureState() then
		self.leisureTime = nowTime
		self:StopLeisureAction()
	else
		if self.leisureTime and nowTime - self.leisureTime > _G.MONSTER_XIUXIAN_GAP + self.randomLeisureTime then
			self:DoLeisureAction()
			self.leisureTime = nowTime
		end
	end
end

function Monster:UpdateBuff(interval)
	local buffInfo = self:GetBuffInfo();
	if buffInfo then
		buffInfo:Update(interval);
	end
end

function Monster:DoLeisureAction()
	local actionName = self:GetActionIdByName("leisure")
	if actionName and actionName ~= "" then
		local actionTable = GetPoundTable(actionName)
		local actionFile = actionTable[math.random(1, #actionTable)]
		self.actionFile = actionFile
		self.avatar:DoAction(actionFile, false)
	end
end

function Monster:StopLeisureAction()
	--local actionName = self:GetActionIdByName("leisure")
	if self.actionFile and self.actionFile ~= "" then
		if self.avatar then
			self.avatar:DoStopAction(self.actionFile, false)
		end
	end
end

function Monster:PlayDeadAction()
	self.avatar:StopAllAction()
	self.avatar:SetNullPick()
	self.avatar.setSkipNormal = {}
	local deadActionFile = self:GetActionIdByName("dead")
	self.avatar:DoAction(deadActionFile, false, function() end)
end

function Monster:PlayHurtAction(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    if self:IsDead() then
        return
    end
	if self:IsStiff() then
		return
	end
	self.avatar:PlayerPfx(10015)
    local actionFile = self:GetActionIdByName("hurt")
    if not actionFile or actionFile == "" then
    	return
    end
    self.avatar:DoAction(actionFile, false, NULL_FUNCTION)
end

function Monster:PlayHurtPfx(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local pfx_hurt = skillConfig.pfx_hurt
    if pfx_hurt and pfx_hurt ~= "" then
    	self:GetAvatar():PlayPfxOnBone("beatpoint", pfx_hurt, pfx_hurt)
    end
    local soundId = skillConfig.gethit_sound_id
    if soundId and t_music[soundId] then
   		SoundManager:PlaySkillSfx(soundId)
   	end
end

function Monster:PlayQTEPfx()
	local pos = self:GetPos()
	local selfPlayerPos = MainPlayerController:GetPlayer():GetPos()
	local qteMat = _Matrix3D.new()
	qteMat:mulFaceToLeft(-1, 0, 0, pos.x - selfPlayerPos.x, pos.y - selfPlayerPos.y, 0)
	self.avatar:PlayerPfxByMat(10022, qteMat)
end

function Monster:PlaySkill(skillId, targetCid, targetPos)
	if self:IsDead() then
		Debug("this monster is dead, Why does it try to attack others")
	end
	--print("================", skillId)
	self:SetStiffTime(skillId)
	self:GetAvatar():PlaySkill(skillId, targetCid, targetPos)
end

function Monster:IsBoss()
	local monsterType = self:GetMonsterType()
    if monsterType == MonsterConsts.Type_Normal 
    	or monsterType == MonsterConsts.Type_Quest
    	or monsterType == MonsterConsts.Type_Boss_Quest
    	or monsterType == MonsterConsts.Type_Dungeon_Thing
    	or monsterType == MonsterConsts.Type_False
		or monsterType == MonsterConsts.Type_Boss_XianYuanCave_Small
		or monsterType == MonsterConsts.Type_Boss_XianYuanCave_JingYing then
    	return false
    end
    return true
end

function Monster:IsFengyao()
	local monsterId = self.monsterId
	return MonsterController:IsFengyaoMonster(monsterId)
end

function Monster:IsHalo()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	local halo = cfgMonster.halo
	if halo == 1 then
		return true
	end
	return false
end

function Monster:ClearTimePlan()
	if self.delayTimeKey then 
		TimerManager:UnRegisterTimer(self.delayTimeKey)
	end
	if self.deadFlyTime then
		TimerManager:UnRegisterTimer(self.deadFlyTime)
	end
	if self.knockbackTime then
		TimerManager:UnRegisterTimer(self.knockbackTime)
	end
	if self.fadeTimePlan then
		TimerManager:UnRegisterTimer(self.fadeTimePlan)
	end
	if self.bornTime then
		TimerManager:UnRegisterTimer(self.bornTime)
	end
	self.delayTimeKey = nil
	self.deadFlyTime = nil
	self.knockbackTime = nil
	self.fadeTimePlan = nil
	self.bornTime = nil
	
	if self.avatar then
		if self.avatar.prepTimePlan then
			TimerManager:UnRegisterTimer(self.avatar.prepTimePlan)
		end
		self.avatar.prepTimePlan = nil
	end
end

function Monster:GetMesh()
	return self:GetAvatar().objMesh
end

function Monster:FadeOut()
	local mesh = self:GetMesh()
	if mesh then
		mesh.objBlender = _Blender.new()
    	mesh.objBlender:blend( 0xbfffffff , 0x1fffffff, 2000)
	end
	local selfPos = self:GetPos()
	local cid = self:GetCid()
	self.avatar.objNode.transform:mulTranslationRight(0, 0, -10, 2000)
	if self.fadeTimePlan then
		TimerManager:UnRegisterTimer(self.fadeTimePlan)
	end
	self.fadeTimePlan = TimerManager:RegisterTimer(function()
        MonsterController:DestroyMonster(cid)
    end, 2010, 1)
end

function Monster:SetState(ubit)
	if not ubit then
		return
	end
	local stateInfo = self:GetStateInfo()
   	for i = 1, 32 do
   		local stateType = i
   		local bitNumber = math.pow(2, i)
   		local stateValue = bit.band(ubit, bitNumber) == bitNumber and 1 or 0
   		stateInfo:SetValue(stateType, stateValue)
   	end
end

function Monster:GetBoxWidth()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	local size = cfgMonster.size or 0
	return size
end

function Monster:IsStar()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	local starLevel = cfgMonster.starLvl or 0
	return starLevel > 0 and true or false
end

function Monster:IsDrawDecal()
	if SetSystemController.hideMonster then
		return
	end
	if not self.avatar then
		return false
	end
	if not self.avatar.objNode then
		return false
	end
	if not self.avatar.objNode.visible then
		return false
	end
	if self:IsDead() then
		return false
	end
	if self:IsGod() then
		return false
	end
	return true
end

function Monster:SetCamp(camp)
	self.camp = camp
	self:SetHeadBoardColor()
end

function Monster:GetCamp(camp)
	return self.camp or 1
end

function Monster:IsPickbox()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	local pickbox = cfgMonster.pickbox or 0
	return pickbox > 0 and true or false
end

function Monster:AddPickbox()
	if self:IsPickbox() then
		local avatar = self:GetAvatar()
		if avatar and avatar.objNode then
			avatar.objNode.pickBox = true
		end
	end
end

function Monster:IsBornVisible()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	local born_visible = cfgMonster.born_visible or 0
	return born_visible > 0 and true or false
end

function Monster:SetBelongInfo(belongType, belongID)
	self.belongType = belongType
	self.belongID = belongID
	self:SetHeadBoardColor()
end

function Monster:IsAtkCamp()
	local player = MainPlayerController:GetPlayer()
	local selfCamp = player:GetCamp()
	local monsterCamp = self:GetCamp()
	if t_camp[selfCamp]
		and t_camp[selfCamp]["faction" .. monsterCamp]
		and t_camp[selfCamp]["faction" .. monsterCamp] == 2 then
		return true
	end
	return false
end

function Monster:CheckBelong()
	if self.belongType == MonsterBelongType.Belong_Player then
		local selfCid = MainPlayerController:GetRoleID()
		if selfCid == self.belongID then
			return false
		else
			return true
		end
	elseif self.belongType == MonsterBelongType.Belong_Player_Atk then
		local selfCid = MainPlayerController:GetRoleID()
		if selfCid == self.belongID then
			return true
		else
			return false
		end
	elseif self.belongType == MonsterBelongType.Belong_Guild then
		if UnionModel.MyUnionInfo.guildId == self.belongID then
			return false
		else
			return true
		end
	elseif self.belongType == MonsterBelongType.Belong_Guild_Atk then
		if UnionModel.MyUnionInfo.guildId == self.belongID then
			return true
		else
			return false
		end
	elseif self.belongType == MonsterBelongType.Belong_Server then
		if InterServicePvpModel:GetGroupId() == GuidToInt(self.belongID) then
			return false
		else
			return true
		end
	elseif self.belongType == MonsterBelongType.Belong_Server_Atk then
		if InterServicePvpModel:GetGroupId() == GuidToInt(self.belongID) then
			return true
		else
			return false
		end
	end
	return true
end

-- isHide 隐藏掉自己  显示自己 
-- isDelayHide 延时隐藏
function Monster:HideSelf(isHide, isDelayHide)
	self.isHide = isHide
	local avatar = self:GetAvatar()
	if not avatar then
		return
	end
	if not avatar.objNode then
		return
	end
	if not avatar.objNode.entity then
		return
	end
	
	local hideFunc = function()
		if not avatar or not avatar.objNode then
			return
		end
	
		if isHide then
			self.isShowHeadBoard = false
			avatar.objNode.visible = false
		else
			self.isShowHeadBoard = true
			avatar.objNode.visible = true
		end
	end
	
	if isDelayHide then
		local monsterCfg = t_monster[self.monsterId]
		if monsterCfg and monsterCfg.hidedelay_time and monsterCfg.hidedelay_time > 0 then
			if self.delayTimeKey then 
				TimerManager:UnRegisterTimer(self.delayTimeKey)
				self.delayTimeKey = nil
			end
				self.delayTimeKey = TimerManager:RegisterTimer(function()
						hideFunc()
					end, monsterCfg.hidedelay_time, 1)
		else
			hideFunc()
		end
	else
		hideFunc()
	end
end

--剧情中显示自己 isHide=false 但是不显示
function Monster:ShowSelfByStory()
	self.isHide = false;
	local avatar = self:GetAvatar()
	if not avatar then
		return
	end
	if not avatar.objNode then
		return
	end
	if not avatar.objNode.entity then
		return
	end
	self.isShowHeadBoard = false
	avatar.objNode.visible = false
end

function Monster:OnTalk(talkId)
	if not talkId then
		StoryController:RemoveBubble()
		return
	end
	
	if self.isHide then
		return
	end 	
	StoryController:ShowBubble(talkId, self)
end

function Monster:IsHide()
	return self.isHide
end

local ret2d = _Vector2.new()
local namePos = _Vector3.new()
function Monster:GetNamePos()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]

    local mePos = self:GetPos()
	if not mePos then return nil end
    namePos.x = 0
    namePos.y = 0
    namePos.z = cfgMonster.height or 1

    namePos.x = mePos.x + namePos.x
    namePos.y = mePos.y + namePos.y
    namePos.z = mePos.z + namePos.z
    _rd:projectPoint( namePos.x, namePos.y, namePos.z, ret2d)
	return ret2d
end

function Monster:SetStiffTime(skillId)
    local skillConfig = t_skill[skillId]
    self.stiffTime = GetCurTime() + skillConfig.stiff_time
end

function Monster:IsStiff()
	if not self.stiffTime then
		return false
	end
    if self.stiffTime > GetCurTime() then
        return true
    end
    return false
end

function Monster:GetScale()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	return cfgMonster.scale or 1
end

local threatM = _Matrix3D.new()
function Monster:AddThreat()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	local npcNameZ = cfgMonster.height or 1
	local scale = cfgMonster.scale or 1
 	threatM:setTranslation(0, 0, npcNameZ/scale)
	self.avatar:PlayerPfxByMat(10031, threatM)
end

function Monster:StopThreat()
	self.avatar:StopPfx(10031)
end
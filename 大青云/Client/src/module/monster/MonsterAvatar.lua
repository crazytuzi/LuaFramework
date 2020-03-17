_G.classlist['MonsterAvatar'] = 'MonsterAvatar'
_G.MonsterAvatar = {}
MonsterAvatar.objName = 'MonsterAvatar'
setmetatable(MonsterAvatar, {__index = CAvatar})
local metaMonsterAvatar = {__index = MonsterAvatar}

function MonsterAvatar:new()
	local monsterAvatar = CAvatar:new()
    setmetatable(monsterAvatar, metaMonsterAvatar)
	return monsterAvatar
end


function MonsterAvatar:NewMonsterAvatar(cid, monsterId)
	local monsterAvatar = MonsterAvatar:new()
	monsterAvatar.cid = cid
	monsterAvatar.monsterId = monsterId
	monsterAvatar.setSkipNumber = {}
	monsterAvatar.lastSkipTime = 0
	monsterAvatar.bIsAttack = false
    monsterAvatar.avtName = "monsterAvatar"
	return monsterAvatar
end

function MonsterAvatar:InitAvatar()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	if not cfgMonster then
		Error("don't exist this npc  monsterId", monsterId)
		return
	end
	local lookId = cfgMonster.modelId
	local scale = cfgMonster.scale or 1
	local look = t_model[lookId]
	if not look then
		Error("don't exist this npc lookid", lookId)
		return
	end
	local sklFile = look.skl
	local sknFile = look.skn
	local subSknFile = look.sub_skn
	local defAnima = look.san_idle
	local walkAction = look.san_walk

	local meshResource = Assets:GetNpcMesh(sknFile)
	if not meshResource or meshResource == "" then
		Error("Get Monster Mesh Error", sknFile, lookId)
		return
	end
	local sklResource = Assets:GetNpcSkl(sklFile)
	if not sklResource or sklResource == "" then
		Error("Get Monster Skl Error", sklFile, lookId)
		return
	end

	self:AddSubMesh(subSknFile)
	self:SetPart("Body", meshResource,look.close_material)
	self:ChangeSkl(sklResource)
	
	local defAnimaResource = Assets:GetNpcAnima(defAnima)
	if not defAnimaResource or defAnimaResource == "" then
		Error("Get Monster Anima Error", defAnima, lookId)
	else
		self:SetIdleAction(defAnimaResource, true)
	end
	local walkActionResource = Assets:GetNpcAnima(walkAction)
	if walkActionResource and walkActionResource ~= "" then
		self:SetMoveAction(walkActionResource)
	end

	self.dwNpcID = monsterId
	self.dwSklFile = sklFile
	self.dwSknFile = sknFile
	self.dwDefAnima = defAnima

	self:SetCfgScale(scale)
end

function MonsterAvatar:EnterMap(x, y, faceto)
    local currScene = CPlayerMap:GetSceneMap()
	self:EnterSceneMap(
		currScene,
		_Vector3.new(x, y, 0),
		faceto
	)
	self.objNode.dwType = enEntType.eEntType_Monster
    if self:IsRealShadow() then
        self.objNode.needRealShadow = true
    end
end

function MonsterAvatar:IsRealShadow()
	local monsterId = self.monsterId
	local cfgMonster = t_monster[monsterId]
	if cfgMonster.real_shadow == 1 then
		return true
	end
	return false
end

function MonsterAvatar:OnEnterScene(objNode)
end

function MonsterAvatar:ClearSkipNumber()
	self.setSkipNumber = {}
end

function MonsterAvatar:ExitMap()
	DestroyTbl(self.setSkipNumber)
	self.dwNpcID = nil
	self.dwSklFile = nil
	self.dwSknFile = nil
	self.dwDefAnima = nil
	self:ExitSceneMap()
	self:Destroy()
	self.EffectLimit = nil;
end

local newPos = _Vector3.new()
function MonsterAvatar:MoveAvatar(x, y)
	newPos.x = x; newPos.y = y;
    self:SetPos(newPos)
end

function MonsterAvatar:DoAction(animaID, isLoop, callBack)
	local szFile = Assets:GetNpcAnima(animaID)
	if szFile then
		self:ExecAction(szFile, isLoop, callBack)
	end
end

function MonsterAvatar:DoStopAction(animaID)
	 local szFile = Assets:GetNpcAnima(animaID)
	if szFile then
		self:StopAction(szFile)
	end
end

function MonsterAvatar:SetHighLightState(lState)
	self.blState = lState
end

function MonsterAvatar:OnUpdate(e)
	self:UpdateSkipNumber()
end

function MonsterAvatar:DrawSkipNumber(arrParam)
	local number = #self.setSkipNumber
	if number >= SkipNoticeConfig.MaxNum then
		return
	end
	table.insert(self.setSkipNumber, arrParam)
end

function MonsterAvatar:UpdateSkipNumber()
	if #self.setSkipNumber <= 0 then
		return
	end
	if GetCurTime() - self.lastSkipTime < SkipNoticeConfig.NormalTick then
		return
    end
	self:RenderSkipNumber(self.setSkipNumber[1])
	table.remove(self.setSkipNumber, 1)
	self.lastSkipTime = GetCurTime()
end

function MonsterAvatar:GetSelfMonster()
	return MonsterController:GetMonster(self.cid)
end

local tmat = _Matrix3D.new()
local smat = _Matrix3D.new()
local pmat = _Matrix3D.new()
function MonsterAvatar:PlaySkill(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
    	print("Error:", "monster not exist this skill ", skillId, self.monsterId)
        return
    end
    local skill_type = skillConfig.oper_type
    if skill_type == SKILL_OPER_TYPE.PREP then
    	self:PlayPrep(skillId, targetCid, targetPos)
    else
    	self:PlayDef(skillId, targetCid, targetPos)
    end
end

function MonsterAvatar:PlayPrep(skillId, targetCid, targetPos)
	local skillConfig = t_skill[skillId]
	if not skillConfig then
		return
	end
	local skill_action = t_skill_action[tonumber(skillConfig.skill_action)]
	local actionFile = skill_action.animation
	local actionTable = GetPoundTable(actionFile)
	if #actionTable ~= 2 then
		return
	end
	local action1String = actionTable[1]
	local action1Table = GetColonTable(action1String)
	if #action1Table ~= 3 then
		return
	end
	local animaFile1 = action1Table[1]
	local time = tonumber(action1Table[2])
	local pfx = action1Table[3]
	local animaFile2 = actionTable[2]
	self:PlaySkillAction(animaFile1, true)
	self:PlayerPfxOnSkeleton(pfx)
	if self.prepTimePlan then
		TimerManager:UnRegisterTimer(self.prepTimePlan)
	end
	self.prepTimePlan = TimerManager:RegisterTimer(function()
        self:StopPfxByName(pfx)
        self:StopAction(animaFile1)
        self:PlaySkillAction(animaFile2, false)
    end, time, 1)
end

function MonsterAvatar:PlayDef(skillId, targetCid, targetPos)
	local monster = self:GetSelfMonster()
	if not monster then
		return
	end

	local skillConfig = t_skill[skillId]
	if not skillConfig then
		return
	end

    local actionFile = nil
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if skill_action then
        actionFile = skill_action.animation
    else
    	actionFile = monster:GetActionIdByName("atk")
    end
	if not actionFile or actionFile == "" then
		print("Error:", "monster not atk action ", skillId, self.monsterId)
		return
	end
	local actionTable = GetPoundTable(actionFile)
	local animaFile = nil
	if #actionTable > 1 then
		if not self.animaIndex then
			self.animaIndex = 0
		end
		self.animaIndex = self.animaIndex + 1
		if self.animaIndex > #actionTable then
			self.animaIndex = 1
		end
		animaFile = actionTable[self.animaIndex]
	else
		animaFile = actionFile
	end
	if not animaFile or animaFile == "" then
		return
	end 
	local targetChar = CharController:GetCharByCid(targetCid)
	if targetChar and skillConfig.pfx_type == 1 then
		local selfPos = self:GetPos()
		smat:setTranslation(selfPos)
		smat.ignoreWorld = true

		pmat = targetChar:GetAvatar().objNode.transform
		pmat.ignoreWorld = true
		local skl = targetChar:GetAvatar():GetSkl()
		local beatpointMat = skl:getBone('beatpoint')
		if beatpointMat then
			tmat = beatpointMat
		else
			tmat = _Matrix3D.new()
		end
		tmat.parent = pmat
		local pp = _ParticleParam.new('fly')
		pp:addMarker('source', smat)
		pp:addMarker('target', tmat)
		pp:addDuration('bind_target', 300)

		self:GetSkl().pfxPlayer:clearParams()
		self:GetSkl().pfxPlayer:addParam(pp)
	end
    self:PlaySkillAction(animaFile, false)
end

function MonsterAvatar:SetAttackAction(bIsAttack)
	local monster = self:GetSelfMonster()
	if not monster then
		return
	end
	local oldAttack = self.bIsAttack
	self.bIsAttack = bIsAttack
    if self.bIsAttack then
		self.dwIdleAnimaID = monster:GetActionIdByName("battle")
		self.dwMoveAnimaID = monster:GetActionIdByName("move")
	else
		self.dwIdleAnimaID = monster:GetActionIdByName("idle")
		self.dwMoveAnimaID = monster:GetActionIdByName("walk")
	end
	
	if oldAttack == false and bIsAttack == true and self.moveState == false then
		local animaFile = monster:GetActionIdByName("translation")
		if animaFile and animaFile ~= "" then
			local file = monster:GetActionIdByName("idle")
			local anima = self:GetAnimaByFileName(file)
			anima:stopPfxEvents(true)
			anima:stop()
			self:DoAction(animaFile, false, function()
				self:StartDefAction()
			end)
		else
			self:StartDefAction()
		end
	else
		self:StartDefAction()
	end
end

function MonsterAvatar:StartDefAction()
	self:SetIdleAction(self.dwIdleAnimaID, true)
	self:SetMoveAction(self.dwMoveAnimaID)
end

function MonsterAvatar:PlaySkillOnUI(skillId)
	local skillConfig = t_skill[skillId]
    if not skillConfig then
        return
    end
    local actionFile = nil
    local skill_action = t_skill_action[tonumber(skillConfig.skill_action)] 
    if skill_action then
        actionFile = skill_action.animation
    else
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
    	actionFile = model["san_atk"]
    end
	if not actionFile or actionFile == "" then
		return
	end
    self:PlaySkillAction( actionFile, false )
end

function MonsterAvatar:DoExtendAnima(event)
	if not event then
		return;
	end
	
	if not self.objNode then
		return;
	end
	
	if self.EffectLimit and self.EffectLimit() then
		return;
	end
	
	if string.find(event,'Radialblur') then
		local script = 'local '..event..' return Radialblur';
		local param = assert(loadstring(script))();
		CPlayerMap:PlayEffectBlur(param);
	end
	
	if string.find(event,'CameraShake') then
		local script = 'local '..event..' return CameraShake';
		local param = assert(loadstring(script))();
		_rd.camera:shake(param.min,param.max,param.time);
	end
	
end

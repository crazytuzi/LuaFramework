
Skill =BaseClass()
--施法表现类型
PreviewType =
{
	Nothing = 0,				 --无
	RangeSector360 = 1,			 --定向扇形aoe(360°)
	RangeSector60 = 2,	  	 --定向扇形aoe(60°)
	RangeSector90 = 3,	  	 --定向扇形aoe(90°)
	RangeSector180 = 4,	 	 --定向扇形aoe(180°)
	GroundAttack  = 5,			 --地面施法
	ArrowSmall = 6,				 --窄箭头
	PointToRangeSector60 = 7,  	 --指向扇形aoe(60°)
	PointToRangeSector90 = 8,  	 --指向扇形aoe(90°)
	PointToRangeSector180 = 9,   --指向扇形aoe(180°)
	PointToCenterSector90 = 10,  --指向扇形中心线单选(90°)
	ArrowBig = 11,  			 --宽箭头
}

--弹道类型
BallisticType = 
{
	TargetPos = 1,		--目标点
	MyAnchor = 2,		--自身锚点
	OneWayParabolic = 3,--单向抛物
	OneWayDirect = 4,	--单向直射
	RainDown = 5,		--雨系降落
	TheCharge = 6,		--冲锋
	Teleport = 7,		--瞬移
	ThreeToDirect = 8,	--3方向直射
	SixToDirect = 9,	--6方向直射
}

--技能目标类型
SkillTargetType = 
{
	My = 000,			 --自己
	Friendly = 100,	 --友方目标
	Enemy = 200,		 --敌方目标
	FriendlyBody = 300,--友方尸体
	Ground = 400,		 --地面目标
	Ddirection = 500,	 --方向
	NoTarget = 600,	 --无需目标

	Me_ = 1,   --自己
	MemberIncludeMe_ = 2, --队员包含自己
	MemberNotIncludeMe_ = 3,	--队员不包含自己
	Enemy_ = 4,	--敌人
	ALL_ = 5,	--所有单位
	ALLFriend_ = 6,	--所有友方单位
}

--范围类型
AreaType = 
{
	Monomer = 0,				--单体
	Rectangle = 1,				--矩形
	Sector = 2,					--扇形
	Circular = 3,				--圆形
	ProCallTheRoll = 4, 		--职业点名
	RanCallTheRoll = 5,			--随机点名
	FullScreenTheSelected = 6,	--全屏反选
	OrganCircular = 7,			--机关点圆形
}

--骨骼绑定效果
BoneHandEffect = 
{
	RightHand = "Bip001 R Hand",
	LeftHand = "Bip001 L Hand",
}

Skill.persistChenk = false
Skill.curIdx = 0

function Skill:__init()
	self._skillVo = nil
	self.sceneCtrl = SceneController:GetInstance()
	self.sceneModel = SceneModel:GetInstance()
	self.moveHitTarget = nil --已受击列表
	Skill.curIdx = (Skill.curIdx + 1) % 500
	self.moveRenderKey = "moveskill_" .. tostring(Skill.curIdx)
end

function Skill:Init(fighter, skillVo, autoDestroy)
	self.autoDestroy = autoDestroy
	self._fighter = fighter
	self.fightVo = nil 
	self.target = nil
	self._skillVo = skillVo
	self.isColliding = false
	self.collidingEffectId = nil
	self.needSkillEndCall = false
	self.isCd = false
	self.emptyPos = nil
	self.releasePoint = nil
	if self._fighter then
		self.isMainPlayer =  self.sceneModel:IsMainPlayer( self._fighter.guid )
	end
end

function Skill:__delete()
	self.fightVo = nil 
	self._skillVo = nil
	self.moveHitTarget = nil

	self._fighter = nil
	self.target = nil
	self._skillVo = nil
	self.collidingEffectId = nil
	self.needSkillEndCall = nil
	self.emptyPos = nil
	self.releasePoint = nil
	RenderMgr.Realse(self.moveRenderKey)
end

function Skill:PlaySound()
	local aud = self._skillVo.skillAudio
	if #aud == 2 then
		local delay = aud[2] *0.001
		DelayCall(function() 
			soundMgr:PlayEffect(tostring(aud[1]))
		end, delay)
	end
end

function Skill:SkillBegin()
	if self.isMainPlayer then
		GlobalDispatcher:DispatchEvent(EventName.SkillUseBegin, self._skillVo.un32SkillID)
	end	 
	self._fighter:Lock()
end

--重置状态
--@param delay
function Skill:SkillEnd()
	if self.needSkillEndCall then
		 self.moveHitTarget = nil	
		 self.emptyPos = nil
		 self._fighter:Reset()
		 if self.isMainPlayer then
		 	GlobalDispatcher:DispatchEvent(EventName.SkillUseEnd, self._skillVo.un32SkillID)
		 end
		 self.needSkillEndCall = false
		 local mjs = CustomJoystick.mainJoystick
		if mjs and mjs.joystick.selected and self._fighter and self._fighter.isMainRole then
		 	self._fighter:MoveByAngle( mjs.joystick.rotation )
		end

		if self._fighter:IsMonster()  and not self._fighter:IsDie() then -- 由于怪物放技能要停止移动， so放完技能再次移动到最终目标点
			local obj = SceneModel:GetInstance():GetMon(self._fighter.guid)
			if obj.newPos then 
				if not MapUtil.IsNearV3DistanceByXZ( self._fighter:GetPosition(), obj.newPos, 0.1) then
					self._fighter:MoveToPositionByAgent( obj.newPos )
				end
			end		
		end
	end
	if self.autoDestroy then
		DelayCall(function() self:Destroy() end, 5)
	end
end

function Skill:IsCD()
	return self.isCd
end

function Skill:EnterCD()
	self.isCd = true
end

function Skill:RelieveCD()
	self.isCd = false
end

function Skill:CheckDizzy()
	return self.sceneCtrl and self.sceneCtrl:IsMainPlayerDizzy()
end

--触发技能, 执行技能各阶段表现
function Skill:UseSkill(fightVo)
	if self:CheckDie() then return end
	--if self:CheckDizzy() then return end
	self.fightVo = fightVo 

	if self._fighter then   
		local skillTime = self._skillVo.n32SkillLastTime *0.001
		self:SkillBegin()
		self.needSkillEndCall = true
		DelayCall(function() self:SkillEnd() end, skillTime)

		local cdTime = self._skillVo.n32CoolDown *0.001
		self:EnterCD()
		DelayCall(function() self:RelieveCD() end, cdTime)

		self.target = nil
		if fightVo and fightVo.target then
			self.target = fightVo.target
		end
		self.emptyPos = nil
		local ftf=self._fighter.transform
		if self._skillVo.bIfNomalAttack == 1 and self._skillVo.skillType == 1 and self.target == nil and not ToLuaIsNull(ftf) then --空放普攻发射技能
			self.emptyPos = ftf.position + ftf.forward*(self._skillVo.fReleaseDist * 0.01)
		end

		self.releasePoint = nil
		if fightVo and fightVo.targetPoint then
			self.releasePoint = fightVo.targetPoint
		end

		self._fighter.isFlyEffectSing = false
		self._fighter.curSkillId = self._skillVo.un32SkillID

		self:CheckWarmup() --单机版直接调起手阶段
		self:CheckShake()
	end

end

--震屏检测
--@param skillId 技能Id
--@param callModelPhases 模块调用阶段
function Skill:CheckShake()
	if self._fighter:IsHuman() and not self.isMainPlayer then return end --玩家技能只能震撼到自己

	local skillVo = self._skillVo
	if skillVo and #skillVo.shockType > 0 then
		local shakeData = nil
		for i = 1, #skillVo.shockType do
			shakeData = skillVo.shockType[i]
			if shakeData and #shakeData == 6 then
				DelayCall(function()
					local msg = {}
					msg.param1 = shakeData[2] -- 持续时间
					msg.param2 = shakeData[3] -- 待定
					msg.param3 = shakeData[4] -- 待定
					msg.param4 = shakeData[5] -- 待定
					msg.param5 = shakeData[6] -- 待定
					GlobalDispatcher:DispatchEvent(EventName.Shake, msg)
				end, shakeData[1])
			end
		end
	end
end

--1.检测起手动作
function Skill:CheckWarmup()
	if self:CheckDie() then return end
	local actionName
	if self._skillVo.warmup > 0 then --有起手动作
		actionName = BehaviourMgr.GetActionName( self._skillVo.warmup )
		local function warmupEndCallBack() --起手动作结束
			self:CheckMyPlayerDir()
			self:CheckSingAction() --单机版直接调吟唱阶段
		end
		self._fighter:PlayAction(actionName, 0, warmupEndCallBack)
	else  --没有起手动作
		self:CheckMyPlayerDir()
		self:CheckSingAction() --单机版直接调吟唱阶段
	end
end

--变换施法者方向，使其朝向目标
function Skill:CheckMyPlayerDir()
	if self._skillVo and self._skillVo.eSkillTargetCate == 4 and self.fightVo.fightDirection ~= MapUtil.NoDirMark then --技能目标为敌人，则朝向目标
		self._fighter:SetRotationByAngle(self.fightVo.fightDirection)
	end
end

--检测施法者是否死亡
function Skill:CheckDie()
	if self._fighter and self._fighter:IsDie() then
		self:SkillEnd()
		return true
	end
	return false
end

function Skill:CheckFighterIsOK()
	if not self._fighter or (self._fighter and self._fighter:IsDie()) then
		return false
	else
		return true
	end
end

--2.检测吟唱动作
function Skill:CheckSingAction()
	if self:CheckDie() then return end
	local actionName

	local singeTime = 0
	if self._skillVo.singTime > 0 then
 		singeTime = self._skillVo.singTime *0.001
	else
 		singeTime = 1
	end

	if self._skillVo.singAction > 0 then --有吟唱动作
		if self._skillVo.ballisticType == BallisticType.OneWayDirect then
			self._fighter.isFlyEffectSing = true
		end
		actionName = BehaviourMgr.GetActionName(self._skillVo.singAction)
		if #self._skillVo.singanimation > 0 then
			local singanimations = self._skillVo.singanimation
			local singeItem = nil
			local singeInfo = nil
			local boneName = ""
			for i = 1, #singanimations do
				singeItem = singanimations[i]
				if singeItem then
					EffectMgr.CreateSkillEffect(singeItem, self._fighter, singeTime)
				end
			end
		end
		self._fighter:PlayByTime(actionName, singeTime, function() end)
		DelayCall(
			function() 
				self:CheckAttackAction()
		 end, singeTime)
	else --没有吟唱动作,直接检测施法动作
		self:CheckAttackAction()
	end
	self:WainingSwitch()
end

--3.检测施法动作
function Skill:CheckAttackAction()
	if self:CheckDie() then return end
	if self._skillVo.attackAction <= 0 then return end --没有施法动作则直接结束
	local actionName = BehaviourMgr.GetActionName( self._skillVo.attackAction )
	
	if #self._skillVo.attackanimation > 0 then --释放特效
		local attackanimations = self._skillVo.attackanimation
		local attackItem = nil
		local attackInfo = nil
		local boneName = ""
		for i = 1, #attackanimations do
			attackItem = attackanimations[i]
			if attackItem then
				EffectMgr.CreateSkillEffect(attackItem, self._fighter)
			end
		end
	end
	local function attackActionEndCallBack()
		if self._fighter then
			if self._fighter:IsMainPlayer() then
				--连招模式，不切idle
				if SkillBtnUI_Base.QuickAttackTarget ~= nil then 
					return
				end
	 	   		self._fighter:PlayAction("idle")
			else
		 	   self._fighter:PlayAction("idle")
			end
			self._fighter:GetAnimator():SetSpeed(1) --设置播放速度
		end
	end
	-- self._fighter:GetAnimator():SetSpeed(2) --设置播放速度
	self._fighter:PlayAction(actionName, 0, attackActionEndCallBack)
	self:AttackEffectAnalysis() --前摇时间结束后进入调模块效果阶段
	self:PlaySound()
end

--4.攻击特效解析
function Skill:AttackEffectAnalysis()
	if self:CheckDie() then return end
	local dependModeSource = self._skillVo.dependModelList
	local delayTimes = self._skillVo.n32Delay
	local delayTime = 0
	for i = 1, #dependModeSource do
		delayTime = delayTimes[i] *0.001
		DelayCall(function() 
			self:AttackEffectSwitchType(dependModeSource[i]) 

		end, delayTime) --前摇时间结束后进入调模块效果阶段
	end
end

--攻击类型特效匹配
--@param modelVo 模块数据
--@param targets 模块目标对象列表
function Skill:AttackEffectSwitchType(modelVo, target)
	if modelVo == nil then return end
	local ModelType = SkillVo.ModelType
	local t = modelVo.eSkillModelType
	if t == ModelType.BufModel then --buf模块
		self:BuffEffectModel(modelVo, target)
	elseif t == ModelType.EmitModel then --发射模块
		self:EmitEffectModel(modelVo, target)
	elseif t == ModelType.MoveModel then --移动模块
		self:MoveEffectModel(modelVo, target)
	elseif t == ModelType.RangeModel then --范围模块
		self:RangeEffectModel(modelVo, target)
	elseif t == ModelType.SwitchModel then --匹配模块
		self:SwitchEffectModel(modelVo, target)
	elseif t == ModelType.SummonModel then --召唤模块
		self:SummonEffectModel(modelVo, target)
	end
end

--范围特效表现模块
--@param rangeModelVo 范围模块数据
--@param preTarget 上层模块传递的目标对象
function Skill:RangeEffectModel(rangeModelVo, preTarget)
	if not self._fighter or self:CheckDie() then return end
	local ftf=self._fighter.transform
	if rangeModelVo == nil or ToLuaIsNull(ftf) then return end
	local partical = rangeModelVo.RangePartical[1]
	if self._skillVo.eSkillTargetCate == SkillTargetType.ALLFriend_ then --友方单位
		local targetList = SkillManager.ResultTargetCheck(self._skillVo, rangeModelVo, ftf, self._fighter, self.target)
		if #rangeModelVo.RangePartical > 0 then
		   EffectMgr.CreateSkillEffect(partical, self._fighter)
		end
		DelayCall(function() 
				if not self:CheckFighterIsOK() then return end
				SkillManager.SendSkillAffectTargets(self._fighter.guid, self._skillVo.un32SkillID, targetList, self._fighter, 
													rangeModelVo.dependModelList[1].un32SkillModelID, nil, self.fightVo.msg.targetId)
		end, rangeModelVo.n32Delay * 0.001)

	elseif rangeModelVo.eSkillAOECate == 1 or rangeModelVo.eSkillAOECate == 2 then
		local targetList = nil
		if preTarget then 
			targetList = {}
			table.insert(targetList, preTarget)
		else
			targetList = SkillManager.ResultTargetCheck(self._skillVo, rangeModelVo, ftf, self._fighter, self.target)
		end

		if self._skillVo.eSkillTargetCate == SkillTargetType.Enemy_ and #rangeModelVo.RangePartical > 0 then --敌人目标类型
			if #rangeModelVo.n32RangePar1 > 1 then --技能机关点
				local tarGridList = SkillManager.GetOrganCircularPos(self._fighter, rangeModelVo.n32RangePar1)
				if #tarGridList > 0 then--有坐标算出显示的特效
					--以自己为中心
					if rangeModelVo.eSkillAOECate == 1 then 
						for i = 1, #tarGridList do
							local tpos = Vector3.New(MapUtil.GridToLocalX(tarGridList[i][1]), ftf.position.y, MapUtil.GridToLocalX(tarGridList[i][2]))
							local scale = Vector3.New(tarGridList[i][3], 1, tarGridList[i][3])
							EffectMgr.CreateSkillEffect(partical, self._fighter, nil, tpos, scale)
						end
					end
					--以目标为中心|以自己到目标的偏移坐标点|以固定坐标点
					if rangeModelVo.eSkillAOECate == 2 or rangeModelVo.eSkillAOECate == 3 then 
						local target = nil
						for i = 1, #targetList do
							target = targetList[i]
							local scale = Vector3.New(tarGridList[i][3], 1, tarGridList[i][3])
							EffectMgr.CreateSkillEffect(partical, target, nil, nil, scale)
						end
					end
				end
			else
				if rangeModelVo.eSkillAOECate == 1 then --以自己为中心
					EffectMgr.CreateSkillEffect(partical, self._fighter)
				end

				local target = nil
				for i = 1, #targetList do
					target = targetList[i]
					if rangeModelVo.eSkillAOECate == 2 then --以目标为中心
						EffectMgr.CreateSkillEffect(partical, target, nil, target.transform.position)
					end
					if rangeModelVo.eSkillAOECate == 3 then --以自己到目标的偏移坐标点
						EffectMgr.CreateSkillEffect(partical, target, nil, target.transform.position)
					end
				end
			end
		end

		DelayCall(function() 
			if not self:CheckFighterIsOK() then return end
			if preTarget then --上层模块传递的目标直接命中
			else
				targetList = SkillManager.ResultTargetCheck(self._skillVo, rangeModelVo, ftf, self._fighter, self.target)
			end
			SkillManager.SendSkillAffectTargets(self._fighter.guid, self._skillVo.un32SkillID, targetList, self._fighter, 
												rangeModelVo.dependModelList[1].un32SkillModelID, nil, self.fightVo.msg.targetId)
		end, rangeModelVo.n32Delay * 0.001)

	elseif rangeModelVo.eSkillAOECate == 4 then --地面施法
		local releasePoint = self.releasePoint 
		if rangeModelVo.eTargetType == 1 then 
			releasePoint = ftf.position
		elseif rangeModelVo.eTargetType == 2 then
			releasePoint = self.releasePoint
		 end
		self:CreatePersistEffect(self._skillVo.un32SkillID, self._fighter.guid, releasePoint, self.fightVo.msg.wigId, rangeModelVo.n32Delay * 0.001)

	elseif rangeModelVo.eSkillAOECate == 5 then --目标点施法
		local releasePoint = self.releasePoint
		
		EffectMgr.CreateSkillEffect(partical, nil, rangeModelVo.n32LifeTime, releasePoint, nil, function(eid)
			local eftObj = EffectMgr.GetEffectById(eid)
			local judgeSource = eftObj.gameObject.transform
			DelayCall(function() 
				if not self:CheckFighterIsOK() then return end
				local hitTargets = SkillManager.ResultTargetCheck(self._skillVo, rangeModelVo, judgeSource, self._fighter, self.target)
				SkillManager.SendSkillAffectTargets(self._fighter.guid, self._skillVo.un32SkillID, hitTargets, self._fighter, rangeModelVo.dependModelList[1].un32SkillModelID, nil, self.fightVo.msg.targetId)
			end, rangeModelVo.n32Delay * 0.001)
		end)

	elseif rangeModelVo.eSkillAOECate == 6 then -- 施法者空间坐标点
		EffectMgr.AddToPos(partical, ftf.position, nil, nil, true, nil, function(eid)
				if not self._fighter or ToLuaIsNull(ftf) then
					EffectMgr.RealseEffect(eid)
					return
				end
				local effectObj = EffectMgr.GetEffectById(eid)
				effectObj.transform.rotation = ftf.rotation
			end)
		DelayCall(function() 
			if not self:CheckFighterIsOK() then return end
			local targetList = nil
			if preTarget then 
				targetList = {}
				table.insert(targetList, preTarget)
			else
				targetList = SkillManager.ResultTargetCheck(self._skillVo, rangeModelVo, ftf, self._fighter, self.target)
			end
			
			SkillManager.SendSkillAffectTargets(self._fighter.guid, self._skillVo.un32SkillID, targetList, self._fighter, 
												rangeModelVo.dependModelList[1].un32SkillModelID, nil, self.fightVo.msg.targetId)
		end, rangeModelVo.n32Delay * 0.001)

	elseif rangeModelVo.eSkillAOECate == 7 then --施法者空间坐标点持续
		self:CreatePersistEffect(self._skillVo.un32SkillID, self._fighter.guid, ftf.position, nil, rangeModelVo.n32Delay * 0.001)
	end 
	
end

--发射特效表现模块
--@param emitModelVo 发射模块数据
--@param preTarget 上层模块传递的目标对象
function Skill:EmitEffectModel(emitModelVo, preTarget)
	if not self._fighter or self:CheckDie() then return end
	if emitModelVo == nil or ToLuaIsNull(self._fighter.transform) then return end
	local ftf=self._fighter.transform
	if self._skillVo.eSkillTargetCate == 1 then --对自己释放
		SkillManager.SendSkillAffectTargets(self._fighter.guid, self._skillVo.un32SkillID, {self._fighter}, self._fighter, 
											emitModelVo.dependModelList[1].un32SkillModelID, nil, self.fightVo.msg.targetId)
		return
	end
	if self.emptyPos then --空放发射技能
		self:CreateFlyEffect(emitModelVo.EmitPartical[1], emitModelVo.n32ProjFlySpeed, ftf.position, 
			ftf.rotation,
			function()
				if emitModelVo.n32ProjFlySpeed > 0 then
					if not self:CheckFighterIsOK() then return end
					SkillManager.SendSkillAffectTargets(self._fighter.guid, self._skillVo.un32SkillID, nil, self._fighter, 
									emitModelVo.dependModelList[1].un32SkillModelID, nil, self.fightVo.msg.targetId)
				end
			end, 
			nil, self.emptyPos)
	else
		local targetList = SkillManager.ResultTargetCheck(self._skillVo, emitModelVo, preTarget and preTarget or not ToLuaIsNull(ftf), self._fighter, self.target)
		local target = nil
		for i = 1, #targetList do --对每个目标施加发射模块效果
			target = targetList[i]
			local eftName = ""
			if #emitModelVo.EmitPartical > 0 then 
				eftName = emitModelVo.EmitPartical[1]
			end
			if self._skillVo.eSkillTargetCate == 4 then
				if emitModelVo.n32ProjFlySpeed > 0 then --需要移动,弹道飞行特效
					DelayCall(function() 
						if not self:CheckFighterIsOK() then return end
						--创建飞行特效
						self:CreateFlyEffect(eftName, emitModelVo.n32ProjFlySpeed, ftf.position, ftf.rotation, 
						target, function()
							if not self:CheckFighterIsOK() then return end
							SkillManager.SendSkillAffectTargets(self._fighter.guid, self._skillVo.un32SkillID, {target}, self._fighter, 
																emitModelVo.dependModelList[1].un32SkillModelID, nil, self.fightVo.msg.targetId)
						end, nil)

					end, emitModelVo.n32FlyPar1 * 0.001)
				else --直接在目标身上播放特效

					local eft = nil
					local eftNode = nil
					if eftName ~= "" then
						eftNode = GameObject.New()
						eftNode.name = "eftNode_"..eftName
						local tf = eftNode.transform
						if emitModelVo.n32ProjectileAngle == 0 then
							tf.parent = target.transform
							tf.localPosition = Vector3.zero
							tf.localRotation = Quaternion.Euler(0, 0, 0)
						else
							tf.parent = ftf
							tf.position = target.transform.position
							tf.rotation = ftf.rotation
						end

						EffectMgr.CreateSkillEffect(eftName, eftNode, nil, nil, nil, function(eid)
							 eft = EffectMgr.GetEffectById(eid)	
							 tf.parent = eft.transform
						end)
					end

					DelayCall(function() 
						if not self:CheckFighterIsOK() then return end
						if not ToLuaIsNull(eftNode) then
							eftNode.transform.parent = nil
							DelayCall(function() destroyImmediate(eftNode) end, 1)
						end

						SkillManager.SendSkillAffectTargets(self._fighter.guid, self._skillVo.un32SkillID, {target}, self._fighter, 
															emitModelVo.dependModelList[1].un32SkillModelID, nil, self.fightVo.msg.targetId)
					end, emitModelVo.n32Delay * 0.001) --n32Delay时间后调用下层模块
				end
			end
		end
	end
end

--Buff特效表现模块
--@param buffModelVo Buff特效模块数据
--@param preTarget 上层模块传递的目标对象
function Skill:BuffEffectModel(buffModelVo, preTarget)
end

--移动特效表现模块
--@param moveModelVo 移动特效模块数据
--@param preTarget 上层模块传递的目标对象
function Skill:MoveEffectModel(moveModelVo, preTarget)
	if not self._fighter or self:CheckDie() then return end
	if moveModelVo == nil or ToLuaIsNull(self._fighter.transform) then return end
	local ftf=self._fighter.transform
	if moveModelVo.eMovedTargetType == 1 then --自身移动
		local distance = nil
		local targetPos = nil
		if moveModelVo.eMoveToTargetType == 5 then --移动指定距离
			distance = moveModelVo.n32Distance *0.01
			targetPos = ftf.position + ftf.forward*(moveModelVo.n32Distance *0.01)
		elseif moveModelVo.eMoveToTargetType == 6 then --移动到目标点
			distance = Vector3.Distance(ftf.position, self.target.transform.position)
			targetPos = self.target.transform.position
		end
		local direct = (targetPos - ftf.position):Normalize()
		local speed = moveModelVo.n32Speed *0.01
		local time = distance / speed

		self.moveHitTarget = nil
		self.moveHitTarget = {}
		self.isColliding = true
		self.collidingEffectId = nil

		local reslutCheck = function()
			if not self.moveHitTarget then return end
			if not self:CheckFighterIsOK() then return end
			local targetList = SkillManager.ResultTargetCheck(self._skillVo, moveModelVo, preTarget and preTarget or ftf, self._fighter, self.target)
			if targetList then
				local newHitTargets = {}
				for i = 1, #targetList do
					local hit = true
					for j = 1, #self.moveHitTarget do
						if self.moveHitTarget[j] == targetList[i] then
							hit = false
							break
						end
					end
					if hit then
						table.insert(self.moveHitTarget, targetList[i])		
						table.insert(newHitTargets, targetList[i])			
					end
				end
				if #newHitTargets > 0 then
					SkillManager.SendSkillAffectTargets(self._fighter.guid, self._skillVo.un32SkillID, newHitTargets, self._fighter, 
														moveModelVo.dependModelList[1].un32SkillModelID, nil, self.fightVo.msg.targetId)
				end
			end
		end

		local endCall = function()
			if moveModelVo.IfMoveAttack ~= 1 then --移动结束时伤害
				reslutCheck()
			end

			if self.isColliding then
				if self._fighter then
					self._fighter:UnColliding()
				end
				self.isColliding = false
			end

			local function destroyEff()
				if self.collidingEffectId and self.isLoadEnd then
				 	EffectMgr.RealseEffect(self.collidingEffectId)
					self.collidingEffectId = nil
					RenderMgr.Realse(self.moveRenderKey)
				end
			end
			if self.isLoadEnd then
				destroyEff()
			else
				RenderMgr.AddInterval(destroyEff, self.moveRenderKey, 0.03, 3)
			end
		end

		local movingCall = function(vec3) 
			local gx, gy = MapUtil.LocalToGrid(vec3)
			-- if Astar.isBlock(gx, gy) then
			-- 	endCall()
			-- else
			-- 	ftf.position = vec3
			-- end
			if not Astar.isBlock(gx, gy) then
				ftf.position = vec3
			end

			if moveModelVo.IfMoveAttack == 1 then --移动时伤害判定
				reslutCheck()
			end
		end
		self.isLoadEnd = false
		local function loadCb()
			self.isLoadEnd = true
		end
		if #moveModelVo.MovePartical > 0 then
			self.collidingEffectId = EffectMgr.CreateSkillEffect(moveModelVo.MovePartical[1], self._fighter, time*1000, nil, nil, loadCb)[1]
		end

		local actionName = BehaviourMgr.GetActionName( self._skillVo.attackAction )
		self._fighter:Colliding()
		self._fighter:PlayByTime(actionName, time, function() 
			if not self:CheckFighterIsOK() then return end
			self._fighter:StopTimerByAction() 
		end)
		self._fighter:CollideToPos(direct, distance, time, movingCall, endCall)
	end	

	if moveModelVo.eMovedTargetType == 3 then --移动伤害源
		self:CreateSourceEffect(self._fighter, self._skillVo, moveModelVo)
	end
end

--开关特效表现模块
--@param switchModelVo 开关模块数据
--@param preTarget 上层模块传递的目标对象
function Skill:SwitchEffectModel(switchModelVo, preTarget)
	if not self._fighter or self:CheckDie() then return end
	if switchModelVo == nil then return end
	SkillManager.ResultTargetCheck(self._skillVo, switchModelVo, preTarget and preTarget or self._fighter.transform, self._fighter, self.target)
end

--召唤特效表现模块
--@param summonModelVo 召唤模块数据
--@param preTarget 上层模块传递的目标对象
function Skill:SummonEffectModel(summonModelVo, preTarget)
	if not self._fighter or not self._fighter.transform then print("error?") debugFollow() return end
	if #summonModelVo.SummonBirthPartical then
		EffectMgr.AddToPos(summonModelVo.SummonBirthPartical[1], self._fighter.transform.position, 5)
	end
	
	DelayCall(function() 
		if not self:CheckFighterIsOK() then return end
		local msg = {}
		msg.guid = self._fighter.guid
		msg.skillId = self._skillVo.un32SkillID
		msg.targetIds = {}
		msg.figther = self._fighter
		msg.accountModelId = summonModelVo.nNPCId --召唤技能的时候,accountModelId为召唤怪物id
		msg.wigId = 0
		msg.permissionGuid = 0
		GlobalDispatcher:DispatchEvent(EventName.Hit, msg)
	end, summonModelVo.n32Delay*0.001)
end

--预警特效匹配
function Skill:WainingSwitch()
	if #self._skillVo.aimanimation > 0 then
		local aimanimation = self._skillVo.aimanimation
		local target = nil
		local lifeTime = self._skillVo.singTime + self._skillVo.n32Delay[1]
		local targetPos = nil
		local scale = nil
		local targetIsParent = false
		local params = self._skillVo.value
		local length = nil
		local wide = nil
		local radius = nil

		if aimanimation == "aim_red_1" or aimanimation == "aim_red_2" then
			target = self._fighter
			length = params[1]*0.01
			wide = params[2]*0.01
			scale = Vector3.New(wide, 1, length)
			self:CreateWarningEffect(aimanimation, target, lifeTime, targetPos, scale, targetIsParent)

		elseif aimanimation == "aim_red_3" then
			target = self.target
			scale = Vector3.New(1, 1, 1)
			self:CreateWarningEffect(aimanimation, target, lifeTime, targetPos, scale, targetIsParent)

		elseif aimanimation == "aim_red_4" or aimanimation == "aim_red_5" or 
				aimanimation == "aim_red_6" or aimanimation == "aim_red_7" or 
		 		aimanimation == "aim_red_8" then
		 	target = self._fighter
		 	radius = params[1]*0.01
		 	scale = Vector3.New(radius, 1, radius)
		 	self:CreateWarningEffect(aimanimation, target, lifeTime, targetPos, scale, targetIsParent)

		elseif aimanimation == "aim_red_9" then
			target = self._fighter
			if #params > 1 then
				local tarGridList = SkillManager.GetOrganCircularPos(self._fighter, params)
				for i = 1, #tarGridList do
					local v = targetList[i]
					scale = Vector3.New(v[3], 1, v[3])
					targetPos = Vector3.New(MapUtil.GridToLocalX(v[1]), 0.1, MapUtil.GridToLocalX(v[2]))
			 		self:CreateWarningEffect(aimanimation, target, lifeTime, targetPos, scale, targetIsParent)
				end		
			else
				radius = params[1]*0.01
				scale = Vector3.New(radius, 1, radius)
				self:CreateWarningEffect(aimanimation, target, lifeTime, targetPos, scale, targetIsParent)
			end
		elseif aimanimation == "aim_red_10" or aimanimation == "aim_red_11" then
			if self.target then
				target = self.target
				radius = params[1]*0.01
				scale = Vector3.New(radius, 1, radius)
				self:CreateWarningEffect(aimanimation, target, lifeTime, targetPos, scale, targetIsParent)
			end
		end
	end
end

--创建预警特效
--@param aimanimation 特效名
--@param target 特效目标
--@param lifeTime 生命周期
--@param targetPos 目标点
--@param scale 缩放比
--@param targetIsParent 目标是否为父级对象
function Skill:CreateWarningEffect(aimanimation, target, lifeTime, targetPos, scale, targetIsParent)
	if target == nil then return end
	local warningEff = WarningEffect.New()		
	warningEff:CreateEffect(aimanimation, target, lifeTime, targetPos, scale, targetIsParent)
	self.sceneCtrl:GetScene():AddWarningEffect(warningEff)
end

--创建飞行特效
--@param effectName 特效名
--@param speed 速度
--@param initPos 初始化坐标
--@param initRot 初始化旋转角
--@param target 目标对象
--@param callBack 回调
--@param emptyPos 空放目标点
function Skill:CreateFlyEffect(effectName, speed, initPos, initRot, target, callBack, emptyPos)
	if target == nil then return end
	local flyEff = FlyEffect.New()
	flyEff:SetEffect(effectName, speed, initPos, initRot, target, callBack, emptyPos)
	self.sceneCtrl:GetScene():AddFlyEfffect(flyEff)
end

--创建伤害源特效
--@param fighter 战斗对象
--@param skillVo 技能数据
--@param moveModelVo 移动模块数据
function Skill:CreateSourceEffect(fighter, skillVo, moveModelVo)
	if fighter == nil then return end
	local sourceEff = SourceEffect.New()
	sourceEff:SetData(fighter, skillVo, moveModelVo)
	sourceEff:Play()
	self.sceneCtrl:GetScene():AddSourceEfffect(sourceEff)
end

--创建持续性特效
--@param skillId 技能Id
--@param fighterGuid 战斗对象Id
--@param releasePoint 目标释放点
--@param createGuid 唯一标记(由服务端同步的，没有则nil)
--@param delay 延迟
function Skill:CreatePersistEffect(skillId, fighterGuid, releasePoint, createGuid, delay)
	local persistEffect = PersistEffect.New(skillId, fighterGuid, releasePoint, nil, createGuid, delay)
	self.sceneCtrl:GetScene():AddPersistEffect(persistEffect)
end

function Skill:GetSkillVo()
	return self._skillVo
end
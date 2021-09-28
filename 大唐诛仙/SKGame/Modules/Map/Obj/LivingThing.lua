-- 活物
LivingThing =BaseClass(Thing)

LivingThing.MainRoleDebug = false
LivingThing.MonsterDebug = false
LivingThing.AILockTimeDebug = false

function LivingThing:__init(...)
	self.isLivingThing = true
	self.characterController = nil -- 角色控制器
	self.agentDriver = nil -- 寻路组件
	self.fightSoundMgr = nil -- 音效组件
	self.collider = nil -- 触发器
	
	self.normalAttackStep = 1 -- 当前普攻的步数

	self.moveEndPos = nil -- 目标结束点
	self.targetDir = nil -- 目标方向 Quaternion
	self.rotationSpeed = 10

	self.targetPos = nil --目标坐标
	self.isTalking = false -- 是否说话
	self.isHitPlayer = false -- 是否撞到玩家(怪物)
	self.hitObj = nil -- 碰撞到的对象
	self.useSkillQueue = {}
	self.curSkillId = 0 --当前使用的技能  如果动作自动回归idle stand run 清0
	self.moveSpeed = 0	--移动速度
	self.beHitEffect = nil --被击提示特效
	self.hatredTarget = nil --仇恨目标
	self.isFlyEffectSing = false   --是否在释放飞行道具吟唱中
	self.moveDir = nil --自身当前方向
	self.buffManager = BuffManager.New(self)	--buff管理器

	self.interactiveDist = nil -- 交互距离

	self.isNeedCheckMoveToTransform = false --是否需要移动接近检测
	self.targetTransformForMoveTo = nil --移动跟踪目标
	self.nearDistanceForMoveTo = 0 --移动接近距离
	self.callBackForMoveTo = nil --移动接近后回调

	self.isLock = false 		--是否锁定
	self.isFrozen = false  		--是否定身
	self.isColliding = false 	--是否冲撞
	self.isCloaking= false 		--是否隐身

	self.isAIExecuting = false

	self.aiSkillId = -1
	self.curAIActionId = -1

	self.collideEffect = nil
	self.CollideSpeedAdd = 0
	self.collideMovingCall = nil

	self.isDying = false
	self.isDizzy = false
	self:InitEventBase()
end

function LivingThing:InitEventBase()
	self.handlerBase1 = GlobalDispatcher:AddEventListener(EventName.BuffDataChanged,function ( data ) self:UpdateDizzyState(data) end)
end

function LivingThing:RemoveEventBase()
	GlobalDispatcher:RemoveEventListener(self.handlerBase1)
end

function LivingThing:__delete()
	self:RemoveEventBase()
	self.characterController = nil -- 角色控制器
	self.collider = nil -- 触发器
	self.moveEndPos = nil -- 目标结束点
	self.targetDir = nil -- 目标方向 Quaternion
	self.targetPos = nil --目标坐标
	self.hitObj = nil -- 碰撞到的对象
	self.useSkillQueue = nil
	self.beHitEffect = nil --被击提示特效
	self.hatredTarget = nil --仇恨目标
	self.moveDir = nil --自身当前方向

	self.isNeedCheckMoveToTransform = false --是否需要移动接近检测
	self.targetTransformForMoveTo = nil --移动跟踪目标
	self.callBackForMoveTo = nil --移动接近后回调
	self.collideEffect = nil
	self.collideMovingCall = nil
	self.isHitPlayer = nil
	self.interactiveDist = nil
	if self.agentDriver then
		self.agentDriver:Destroy()
	end
	self.agentDriver = nil
	if self.fightSoundMgr then
		self.fightSoundMgr:Destroy()
	end
	self.fightSoundMgr = nil

	if self.buffManager then
		self.buffManager:Destroy()
	end
	self.buffManager = nil
end

function LivingThing:InitEvent()
	
end

function LivingThing:Update(dt)
	Thing.Update(self, dt)
	if self:IsDie() then return end

	if self.agentDriver and self.gameObject and self.transform and self.vo and (not self.isDizzy) then
		self.agentDriver:Update()
	end

	if self.skillManager then
		self.skillManager:_update()
	end

	if self.buffManager then
		self.buffManager:Update()
	end
end

function LivingThing:SetFollowTarget( target )
	self.followTarget = target
end

function LivingThing:SetHatredTarget( target )
	self.hatredTarget = target
end

-- 移动 
		--按方向移动
		function LivingThing:MoveByDir(dir) --玩家控制移动
			if self:IsFrozen() or self:IsLock() then return end
			if not self.isColliding then --非碰撞状态，摇杆才有效
				self.agentDriver:MoveByDir(dir)
				if self:IsMainPlayer() then
					self.sceneCtrl:GetScene():StopAutoFight(true)

					if CommonController:GetInstance():IsReturning() then
						GlobalDispatcher:DispatchEvent(EventName.StopReturnMainCity) -- 停止回城动作
					end
				end
			end
		end

		--移动到目标点
		function LivingThing:MoveToPositionByAgent( targetPos )
			if self:IsFrozen() or self:IsLock() or self.agentDriver==nil then return end
			self.agentDriver:MoveToPos(targetPos, nil, nil)
		end
		
		--目标点冲撞
		--@param direct 移动方向
		--@param distance 移动距离
		--@param time 冲撞时间
		--@param movingCall 冲撞过程回调
		--@param endCall 冲撞结束回调
		function LivingThing:CollideToPos(direct, distance, time, movingCall, endCall)
			if self:IsFrozen() then return end
			EffectMgr.MoveByDirection(self.transform.position, direct, distance, time, movingCall, endCall, 1)
		end

		-----------------朝向相关 begin---------------------------
		--设置朝向目标点(立即转向)
		--@param pos
		function LivingThing:SetDirByTargetRightNow(pos)
			local transform = self.transform
			if not transform then return end
			if not pos then return end
			local rot = MapUtil.GetRotation(transform.position, pos)
			if rot then
				transform.rotation = rot
			end
		end

		--使用角度设置朝向
		--@param angle 角度
		function LivingThing:SetRotationByAngle( angle )
			local y_angle = angle
			local rot = Vector3.New(0,y_angle,0)
			local transform = self.transform
			if not transform then return end
			transform.rotation = Quaternion.Euler(rot.x, rot.y, rot.z)
		end

		-- 使用V3设置朝向
		--@param v3 三维向量
		function LivingThing:SetRotationByV3( v3 )
			local transform = self.transform
			if not transform then return end
			if not v3 then return end
			transform.rotation = Quaternion.Euler(v3.x, v3.y, v3.z)
		end
		-----------------朝向相关 end---------------------------
--

function LivingThing:SetGameObject( gameObject )
	Thing.SetGameObject(self, gameObject)
	LuaBindSceneObj.Add(gameObject, self)
	if not self:IsNPC() then
		self.agentDriver = AgentDriver.New(self)
		if self.vo then
			self.agentDriver:SetMoveSpeed(self.vo.moveSpeed or 0)
		end
	end

	if self:IsDie() then
		self:ToDie()
		if self:GetAnimator() then
			self:GetAnimator().animator:CrossFade("die", 0, 0, 1)
		end
	else
		self:DoStand()
	end

	if self.isMainRole then
		self.agentDriver.navMeshAgent.enabled = true
		self.collider = gameObject:AddComponent(typeof(UnityEngine.CapsuleCollider))
		self:SetColliderInfo("radius", self.hitRadius, self.collider)
		self:SetColliderInfo("height", self.bodyHeight, self.collider)
		self:SetColliderInfo("center", Vector3.New(0, self.bodyHeight*0.5, 0), self.collider)

		self.rigidbody = gameObject:AddComponent(typeof(UnityEngine.Rigidbody))
		self.rigidbody.isKinematic = true

		if self.fightSoundMgr then
			self.fightSoundMgr:Destroy()
			self.fightSoundMgr = nil
		end
		self.fightSoundMgr = FightSoundMgr.New(self.vo.career)
	else
		self.collider = gameObject:AddComponent(typeof(UnityEngine.CapsuleCollider))
		self.collider.isTrigger = true
		self:SetColliderInfo("radius", self.hitRadius, self.collider)
		self:SetColliderInfo("height", self.bodyHeight, self.collider)
		self:SetColliderInfo("center", Vector3.New(0, self.bodyHeight*0.5, 0), self.collider)
	end


end

function LivingThing:SetFlyEffect( gameObject, pos )
	Thing.SetFlyEffect(self, gameObject, pos)
end
--增加一个接口，给物体增加一个碰撞触发器，进行检测

function LivingThing:SetVo(vo)
	if vo == nil or self.vo ~= nil then error("[LivingThing] vo 无效!") return end
	Thing.SetVo(self, vo )
	self:SetMoveSpeed((vo.moveSpeed or 0))
	self:SetBuff()
end

function LivingThing:SetBuff()
	if not self.buffManager then
		self.buffManager = BuffManager.New(self)
	end
	if self.vo.buffVoList and #self.vo.buffVoList > 0 then
		self.buffManager:UpdateByList(self.vo.buffVoList)
	end

	local buffList = self.sceneModel:GetBuffList()
	if not TableIsEmpty(buffList) then
		for k , v in pairs(buffList) do
			if k == self.guid then
				self.buffManager:UpdateByList(v)
			end
		end				
	end
end

function LivingThing:UpdateVo()
	
end

-- 强制移动停止
function LivingThing:StopMove()
	if self.agentDriver then
		self.agentDriver:StopMove()
	end
end

-- 跑动
function LivingThing:DoRun()
	self:PlayAction("run")
end

-- 站立
function LivingThing:DoStand()
	self.walkDir = nil
	if not self:GetGameObject()  then return end
	self.interactiveDist = nil
	self:PlayAction("idle")
	self.moveEndPos = nil
end

--执行AI行为
--@param actionId	  AI执行ID
--@param target		接近目标
--@param fightDistance 攻击距离
--@param fightVo	   战斗Vo
function LivingThing:AIAction(actionId, target, fightDistance, fightVo)
	if self.isAIExecuting then return end
	if ToLuaIsNull(self.transform) then return end

	self.curAIActionId = actionId
	self.isAIExecuting  = true
	self:StopMove()
	local myGuid = nil
	local role = self.sceneModel:GetMainPlayer()
	if role and role.guid then
		myGuid = role.guid
	end

	SkillManager.UseSkill(self, fightVo)
end

--使用技能攻击目标(怪物攻击玩家)
--@param target 目标实体对象
--@param skillId 技能Id
function LivingThing:AttackWithSkillId(target, skillId)
	if self:IsLock() then return end
	local fightTargetId = target.guid
	local fighterPos = self:GetPosition()
	local targetPos= target:GetPosition()
	local fightRot = MapUtil.GetRotation(self.transform.position, target.transform.position)
	local fightDirection = fightRot and fightRot.eulerAngles.y or 0

	self.aiSkillId = skillId

	-- --怪物技能单机测试
	-- local msg = {}
	-- msg.guid = self.guid  --fightPlayerId 攻击者Id
	-- msg.fightTarget = fightTargetId --攻击目标Id
	-- msg.fightType = skillId --攻击类型(技能id)
	-- msg.fightDirection = fightDirection --攻击朝向
	-- msg.targetPoint = target.transform.position --目标释放点
	-- GlobalDispatcher:DispatchEvent(EventName.MonsterAttack, msg)
end

--技能触发
--@param audio 	  	  声音
--@param type 	  	  施法类型
--@param targetId 	  目标Id
--@param skillId 	  技能Id
--@param direction 	  释放技能时的朝向
--@param target 	  接近目标(为空则不执行移动接近逻辑)
--@param nearDistance 接近距离
--@param targetPoint  目标释放点
--@param isAIControll AI控制(挂机行为)
function LivingThing:SkillTrigger(audio, type, targetId, skillId, direction, target, nearDistance, targetPoint, isAIControll)
	if ToLuaIsNull(self.transform) then return end
	if self:IsLock() then return end
	
	local triggerSkill = function() 
		local msg = {}
		msg.type = type --施法类型
		msg.guid = self.guid--fightPlayerId 攻击者Id
		msg.fightTarget = targetId --攻击目标Id
		msg.fightType = skillId --攻击类型(技能id)
		msg.fightDirection = direction --攻击朝向
		msg.targetPoint = targetPoint --目标释放点
		self.fightSoundMgr:Attack()

		GlobalDispatcher:DispatchEvent(EventName.PlayerAttack, msg)
	end

	if isAIControll then 
		if target then
			if Vector3.Distance(target.transform.position, self.transform.position) <= nearDistance then
				triggerSkill()
			else
				self.agentDriver:MoveToTarget(target, nil, nil, nil, nearDistance, function()
					self:StopMove()
					triggerSkill()
				end)
			end
		else
			triggerSkill()
		end
	else
		triggerSkill()
	end
end

--执行战斗
function LivingThing:ToFight(fightVo) 
	if self.isMainRole then
		--主角释放技能
		if self.skillManager then
			self.skillManager:UseSkillByFightVo(fightVo)
		end
	elseif SkillManager.GetStaticSkillVo(fightVo.fightType) then
		--怪物、其他玩家释放技能(同步技能)
		local actionId = 1
		local target = fightVo.target
		local fightDistance = SkillManager.GetStaticSkillVo(fightVo.fightType).fReleaseDist*0.01
		local skillId = fightVo.fightType
		self:AIAction(actionId, target, fightDistance, fightVo)
	end
end

function LivingThing:MultyHitPlay()
	MultyHit:GetInstance():PlayAni()
end

--受击
--@param fighter 攻击者
--@param skillId 技能Id
--@param accountModel 结算模块
--@param dmg 伤害
function LivingThing:ToHit(fighter, skillId, accountModel, dmg) -- 受击
	
	if ToLuaIsNull(self.transform) or not fighter or not fighter.vo then return end
	if self:IsColliding() then return end --冲撞不受击
	local accountModel = accountModel
	local atkInterrupt = accountModel.interrupt
	
	--受击特效
	if #accountModel.bombPartical > 0 then
		local eftName = accountModel.bombPartical[1]
		local eftInfo = StringSplit(eftName, "_")
		local handlerType = eftInfo[2]
		if string.lower(handlerType) == "b" then --绑到指定骨骼
			EffectMgr.BindTo(eftName, self:GetCenterBone(), nil, nil, true)
		else --绑定到目标点
			EffectMgr.AddToPos(eftName, self.transform.position, nil, nil, true)
		end
	end
	if dmg <= 0 then return end
	if self:IsMainPlayer() then
		GlobalDispatcher:DispatchEvent(EventName.StopReturnMainCity) -- 停止回城动作
		GlobalDispatcher:DispatchEvent(EventName.StopCollect) -- 停止采集
	end
	if self.fightSoundMgr then
		if self.sceneModel:IsMainPlayer( fighter.guid ) then
			self.fightSoundMgr:hitOn()
		end
		self.fightSoundMgr:Hurt()
	else
		if self.sceneModel:IsMainPlayer(fighter.guid) and fighter.fightSoundMgr then
			fighter.fightSoundMgr:hitOn()
		end
	end

	EffectMgr.HitColor( self, Color.New(2.5,2.5,2.5), 1)
	
	if self:IsHuman() then --人
		local hitFunc = function()
			self:PlayAction("hit", 0, function()
				local js = CustomJoystick.mainJoystick.joystick
				if self.isMainRole and js.selected then --摇杆继续移动处理
					self:MoveByAngle(js.rotation)
				end
				self:PlayAction("idle", 0, nil, true)
			end)
		end

		local canWakeUp = true
		local wakeUpFunc = function()
			if not canWakeUp then return end
			local js = CustomJoystick.mainJoystick.joystick
			if self.isMainRole and js.selected then --摇杆继续移动处理
				self:MoveByAngle(js.rotation)
			end
			if self:IsMainPlayer() then
				local msg = {}
				msg.guid = self.guid
				msg.direction = self:GetEulerAngles()
				msg.position = self.transform.position
				GlobalDispatcher:DispatchEvent(EventName.ReqUpdatePosition, msg)
			end

			self:PlayAction("wakeup_01", 0, function()
				self:Reset()
				self:PlayAction("idle") --包含一个其他动作的执行，否则回调卡死
			end)
			self:UpdateOnGround()
			canWakeUp = false
		end

		local hitupFunc = function()
			self:Lock()
			local pos = self.transform.position
			local hitDirect = (pos - fighter.transform.position):Normalize()
			local hitDistance = 3
			local rotatePos = pos + (-hitDirect)*hitDistance
			self:SetDirByTargetRightNow(rotatePos)
			self:PlayAction("hitup", 0, function() end) --不加动作结束回调，会表现为两次起身，原因暂时未知 

			EffectMgr.MoveByDirection(pos, hitDirect, hitDistance, 0.5,
				function ( vec3 )
					local gx, gy = MapUtil.LocalToGrid(vec3)
					if Astar.isBlock(gx, gy) then
						DelayCall(function() wakeUpFunc() end,0.4)
					else
						vec3.y = pos.y --防止被击浮空
						pos = vec3
					end
				end, 
			wakeUpFunc)
		end
		local ani = self:GetAnimator()
		local battle = self:GetBattle()
		if self:CurSkillIsUseNext() then --当前没有播放技能动作，走一般逻辑
			if atkInterrupt == 1 and ani and ani.curAction ~= "run" then --受击
				hitFunc()
			elseif atkInterrupt == 2 then --击飞
				hitupFunc()
			end
		elseif battle and battle.skillVo then --当前有播放技能动作，走打断逻辑
			if atkInterrupt == 1 and ani.curAction ~= "run" and atkInterrupt > battle.skillVo.interruptArmor then --受击
				hitFunc()
			elseif atkInterrupt == 2 and atkInterrupt > battle.skillVo.interruptArmor then --击飞
				hitupFunc()
			elseif atkInterrupt > battle.skillVo.interruptArmor then --击飞
				hitFunc()
			end
		end

	elseif self:IsMonster() then --怪物
		if ani and ani.curAction == "idle" then
			self:PlayAction("hit", 0, function ()
				self:ToRelife()
			end)
		end
	end
end

--角色转向 使用之前要给 self.moveDir 赋值 先用↑ SetTargetPoint()
function LivingThing:ChangeDirByMoveDir(dt)
	local transform = self.transform
	local rot = transform.localRotation
	local m_rot = rot.eulerAngles
	m_rot.y = self.moveDir or 0
	rot.eulerAngles = m_rot
	if dt then 
		transform.localRotation = Quaternion.Slerp(transform.rot, rot, self.rotationSpeed * dt)
	else
		transform.localRotation = rot
	end
end

function LivingThing:ToFrozen() -- 冰冻
	
end

function LivingThing:ToVertigo() -- 眩晕
	
end

function LivingThing:ToBump() -- 冲撞
	
end

function LivingThing:ToDie() -- 死亡 或 被击倒
	if self.fightSoundMgr then
		self.fightSoundMgr:Dead()
	end

	if self.buffManager then
		self.buffManager:Destroy()
		self.buffManager = nil
	end
	self:ShowShadow(false)
	if not self:GetGameObject() then return end
	self.interactiveDist = nil
	self.moveEndPos = nil
end

function LivingThing:ToRelife() -- 复活
	if self.vo then
		self.vo:SetValue("die", false)
	end
	if self:IsHuman() then
		self.isDying = true
		self:Lock()
		self:PlayAction("wakeup", 0, function()
				self.isDying = false
				self:Reset()
				self:DoStand(true)--包含一个其他动作的执行，否则回调卡死
			end)
	else
		self:PlayAction("idle", 0, nil)
		self:Reset()
	end
	if self:IsMainPlayer() then
		GlobalDispatcher:DispatchEvent(EventName.MAINROLE_RELIFE)
	end
end

--当前技能动作是否允许释放下一个技能动作
function LivingThing:CurSkillIsUseNext()
	local ani = self:GetAnimator()
	if ani and ani.curAction and ani.curAction ~= "run" and ani.curAction ~= "idle" then 
		return false
	end
	return true
end

function LivingThing:ToBack(obj, dist, time) -- 被推开 相对自己向后
end
function LivingThing:BackTo(obj, dist, time) -- 被推开 相对自己向后
end

function LivingThing:ToBati() -- 霸体(免疫)
	
end
function LivingThing:ToReady() -- 准备等待
	
end

function LivingThing:ToJump() -- 跳跃
end
function LivingThing:ToRide() -- 上坐骑	
end
function LivingThing:ToFly() -- 飞行	
end

function LivingThing:OnTriggerEnter( co, luaObj )
	if luaObj == nil then return end
		if self.isMainRole then
		self.sceneCtrl:GetScene():UpdateCameraById(co.transform.name)
		self.sceneCtrl:GetScene():JudgeGuideState(co.transform.name,true)
	end
end
function LivingThing:OnTriggerExit( co, luaObj )
	if luaObj == nil then return end
		if self.isMainRole then
		self.sceneCtrl:GetScene():JudgeGuideState(co.transform.name,false)
	end
end

-- CharacterController.Move 触发 LuaBindSceneObj.Add(gameObject, self) -- 启用与c#中的触发器处理
function LivingThing:OnControllerColliderHit( controllerColliderHit, sender )
	local target = controllerColliderHit.gameObject
	self.hitObj = target
	local luaObj = target:GetComponent("LuaBindSceneObj")
	if self:IsMonster() then
		self.isHitPlayer = true
		self:SetColliderInfo("center", Vector3.New(0, self.bodyHeight*0.5, 0))
	elseif luaObj then
	end
end


--------------------------------各种状态 start---------------------------------------------
--隐身
	--隐身
	function LivingThing:Cloaking()
		self:CloakingHandler()
		self.isCloaking= true
	end

	--解除隐身
	function LivingThing:UnCloaking()
		self:UnCloakingHandler()
		self.isCloaking= false
	end

	--是否隐身中
	function LivingThing:IsCloaking()
		return self.isCloaking
	end

--锁定
	--锁定(无法移动，无法执行其他动作，无法释放技能)
	function LivingThing:Lock()
		self:DoStand(true)
		self.isLock = true
	end

	--解锁
	function LivingThing:UnLock()
		if not self.isDizzy then
			self.isLock = false
		end
	end

	--是否锁定中
	function LivingThing:IsLock()
		return self.isLock
	end

--定身
	--定身
	function LivingThing:Frozen()
		self.isFrozen = true
	end

	--解除定身
	function LivingThing:UnFrozen()
		self.isFrozen = false
	end

	--是否定身中
	function LivingThing:IsFrozen()
		return self.isFrozen
	end

--冲撞
	--冲撞
	function LivingThing:Colliding()
		self.isColliding = true
	end

	--解除冲撞
	function LivingThing:UnColliding()
		self.isColliding = false

		if self.sceneModel:IsMainPlayer(self.guid) then
			local msg = {}
			msg.guid = self.guid
			msg.direction = self:GetEulerAngles()
			msg.position = self.transform.position
			GlobalDispatcher:DispatchEvent(EventName.ReqUpdatePosition, msg)
		end
	end

	--是否冲撞中
	function LivingThing:IsColliding()
		return self.isColliding
	end
--------------------------------各种状态 end---------------------------------------------

--各种重置
function LivingThing:Reset()
	self:UnLock()
	self:SetBattle(nil)

	self.aiSkillId = -1
	self.isAIExecuting = false

	if self:GetAnimator() then
		self:GetAnimator():Reset()
	end
end

-- attr
	function LivingThing:GetHp()
		if self.vo then
			return self.vo.hp
		end
		return 0
	end
	function LivingThing:GetMaxHp()
		if self.vo then
			return self.vo.hpMax
		end
		return 0
	end
	function LivingThing:GetMp()
		if self.vo then
			return self.vo.mp
		end
		return 0
	end
	function LivingThing:GetMaxMp()
		if self.vo then
			return self.vo.mpMax
		end
		return 0
	end
	function LivingThing:SetMoveSpeed(speed)
		
		self.moveSpeed = speed or 0
	end
	function LivingThing:GetAttackSpeed()
		if self.vo then
			return self.vo.attackSpeed
		end
		return 0
	end
	function LivingThing:GetLevel()
		if self.vo then
			return self.vo.level
		end
		return 0
	end
	function LivingThing:IsDie()
		if self.vo then
			return self.vo.die
		end
		return true
	end
	function LivingThing:IsDying()
		return self.isDying
	end

------------ add dizzy buff start ==>>
-- 是否含有眩晕buff
function LivingThing:IsDizzy()
	if self.buffManager then
		if self.buffManager:HasBuffGroup(104101) then
			return true
		end
	end
	return false
end

function LivingThing:UpdateDizzyState(data)
	local isSelf = false
	if data and data.guid and data.state and self.guid == data.guid and self.sceneModel:IsMainPlayer( data.guid ) then
		isSelf = true
	end
	if self:ShouldEnterDizzy() then
		self:EnterDizzy(isSelf)
	elseif self:ShouldQuitDizzy() then
		self:QuitDizzy(isSelf)
	end
end

function LivingThing:ShouldEnterDizzy()
	return self:IsDizzy() and (not self.isDizzy)
end

function LivingThing:ShouldQuitDizzy()
	return ( not self:IsDizzy() ) and self.isDizzy
end

function LivingThing:GetDizzyState()
	return self.isDizzy
end

function LivingThing:EnterDizzy(isSelf)
	self.isDizzy = true
	self:DoDizzyStopEvent()
	self:DoDizzy()
	self:Lock()
	if isSelf then
		GlobalDispatcher:DispatchEvent(EventName.DizzyStateChange, {isEnter = true})
	end
end

function LivingThing:QuitDizzy(isSelf)
	self.isDizzy = false
	self:UnLock()
	self:DoUnDizzy()
	if isSelf then
		GlobalDispatcher:DispatchEvent(EventName.DizzyStateChange, {isEnter = false})
	end
end

function LivingThing:DoDizzy()
	self:StopMove()
end

function LivingThing:DoUnDizzy()
	if self:IsMainPlayer() then
		local scene = self.sceneCtrl:GetScene()
		if scene then
			local player = scene:GetMainPlayer()
			if player and player.autoFight and player.autoFight:IsAutoFighting() then
				self.sceneCtrl:GetScene():StopAutoFight(false)
				player.autoFight:Start(false)
			end
		end
	end
end

-- 中眩晕时中断的一些东东
function LivingThing:DoDizzyStopEvent()
	if self:IsMainPlayer() then
		GlobalDispatcher:DispatchEvent(EventName.StopReturnMainCity)
		GlobalDispatcher:DispatchEvent(EventName.StopCollect)
	end
end

------------<< add dizzy buff end

function LivingThing:IsInWakingUpAction()
	return self:GetAnimator().curAction == "wakeup_01"
end
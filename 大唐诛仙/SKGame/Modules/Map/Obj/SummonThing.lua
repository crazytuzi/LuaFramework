--召唤物
SummonThing =BaseClass(LivingThing)

function SummonThing:__init( vo )
	if not vo or not vo.ownerGuid then return end
	self.type = PuppetVo.Type.Summon
	self:SetVo(vo)
	self.cfg = Monster.GetVO( vo.eid )
	if self.cfg then
		vo.name = self.cfg.name or ""
		self.changeBR = self.cfg.changeBR or 1
		self.bodyRadius = MapUtil.DistanceSC( self.cfg.hitBR or 100 ) * self.changeBR-- 身体实体宽度
		self.bodyHeight = MapUtil.DistanceSC( self.cfg.bodyH or 100 ) * self.changeBR -- 身体高度
		self.hitRadius = MapUtil.DistanceSC( self.cfg.hitBR or 1 ) * self.changeBR-- 身体实体宽度
		self.skillIds = self.cfg.defaultSkill1
	end
	self.dieCallback = nil

	self.maxAwayDistance = 9 --跟随距离
	self.cfg = GetCfgData("constant"):Get(32)
	if self.cfg then
		self.maxAwayDistance = self.cfg.value
	end

	self.nearDistance = 1.5 --跟随接近距离
	self.sceneCtrl = SceneController:GetInstance()
	self.scene = self.sceneCtrl:GetScene()
	self.owner = self.scene:GetPlayer(self.vo.ownerGuid) --跟随目标

	self.attackTarget = nil --攻击目标
	self.attackState = 0 --0:停止攻击 1:攻击
	self.attackInternal = 0 --攻击间隔

	self.mainPkModel = -1

	self.targetList = {}
	self.targetListTemp = {}

	self.fightDistance = 0
	self.nearMoving = false
	self.zdModel = ZDModel:GetInstance()
	self.asyncPos = Vector3.zero
	self.targetAsyncPos = Vector3.zero
	self:InitEvent()
end

-- 清理
function SummonThing:__delete()
	RenderMgr.Remove(self.removeRender)
	self:RemoveEvent()
	
	self.cfg = nil
	self.skillIds = nil
	self.dieCallback = nil
	self.owner = nil
	self.targetList = nil
	self.attackTarget = nil
	self.targetListTemp = nil
	 self.targetAsyncPos = nil
	self:StopAttack()
end

function SummonThing:GetOwnerPlayer()
	if self.is_destroy_ then return nil end
	if self.owner == nil then
		self.owner = self.scene:GetPlayer(self.vo.ownerGuid)
	end
	return self.owner
end

function SummonThing:SetDieHandler(dieCallback)
	self.dieCallback = dieCallback
end

function SummonThing:ToDie()
	LivingThing.ToDie(self)
	if self.head then
		HeadUIMgr:GetInstance():Remove(self.head)
	end
	self.head = nil
	self:StopMove()
	GlobalDispatcher:DispatchEvent(EventName.SummonThing_DEAD, {self.guid, 0, self:IsBoss()})
	RenderMgr.Delay(function ()
		if ToLuaIsNull(self.gameObject) then return end
			local function DoDead(guid)
				GlobalDispatcher:DispatchEvent(EventName.SummonThing_DEAD, {guid, 1, self:IsBoss()})
				if not ToLuaIsNull(self.gameObject) then
					self.gameObject:SetActive(false)
				end
				RenderMgr.Realse(guid)
			end
			if not ToLuaIsNull(self.gameObject) then
				self.removeRender = RenderMgr.Add(function ()
					if not ToLuaIsNull(self.transform) then
						self.transform.position = self.transform.position + Vector3.New(0, -0.02, 0)
					end
				end, nil, 2, DoDead, self.vo.guid)
			end
	end, 3)
end

function SummonThing:InitEvent()
	LivingThing.InitEvent(self)
	local onUpdateHandle = function (key, value, pre)
		if self.vo then
			if key == "moveSpeed" then
				if self.agentDriver then
					self.agentDriver:SetMoveSpeed(value)
				end
			end
			if key == "position" then
				if not ToLuaIsNull(self.transform) then
					local targetPos = value
					if self.vo.state == 3 then  --被击飞或者击退就直接设置位置
						self.transform.position = targetPos
					else
						self:MoveToPositionByAgent(targetPos)
					end
				end
			end
			if key == "direction" then
				if not ToLuaIsNull(self.transform) then
					local targetDir = value
					if self.vo.state == 3 then
						self.transform.rotation = value
					end
				end
			end
			if key == "die" then
				if value then  --如果怪物死亡,全局发布死亡通知
					self:ToDie()
				end
			end
		end
	end
	if self.vo then
		self.handler=self.vo:AddEventListener(SceneConst.OBJ_UPDATE, onUpdateHandle) -- 属性更新变化事件
	end

	if self.owner and self.owner:IsMainPlayer() then
		self.handler1 = GlobalDispatcher:AddEventListener(EventName.MAINROLE_WALKING, function () self:OnMainPlayerWalking() end)
		self.handler2 = GlobalDispatcher:AddEventListener(EventName.SummonAttack, function ( data ) self:OnSummonAttackHandler(data) end)
		self.handler3 = GlobalDispatcher:AddEventListener(EventName.MAINROLE_STOPWALK, function ( data ) 
			if not self.targetAsyncPos or self.targetAsyncPos == Vector3.zero or  self.attackTarget then
				return
			end
			self:SynPosition(self.targetAsyncPos, true)
		end)
	end
end

function SummonThing:RemoveEvent()
	if self.vo then
		self.vo:RemoveEventListener(self.handler)
	end
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
end

function SummonThing:OnSummonAttackHandler(data)
	local targets = data.targets
	for i = 1, #targets do
		table.insert(self.targetList, 1, targets[i])
	end
	self:SelectTarget()
	self:StartAttack()
end

function SummonThing:SelectTarget()
	local mainRole = self.sceneModel:GetMainPlayer()
	if mainRole and self.mainPkModel ~= mainRole.pkModel or self.targetListTemp == nil then
		self.targetListTemp = BattleManager.PkModelFilter(self.targetList)
		self.mainPkModel = mainRole.pkModel
		self.attackTarget = nil
	end
	if self.attackTarget==nil or (self.attackTarget and self.attackTarget:IsDie()) then
		self.attackTarget = nil
		if self.targetListTemp then
			for i = 1, #self.targetListTemp do
				if not self.targetListTemp[i]:IsDie() then
					self.attackTarget = self.targetListTemp[i]
					break
				end
			end
		end
	end
	if self.attackTarget then
		return true
	else
		self:StopAttack()
		return false
	end
end

function SummonThing:Approaching(async)
	if not self.owner then return end
	local tf = self.owner.transform
	if not ToLuaIsNull(tf) then 
		local direct = -tf.forward
		local targetPos = tf.position + direct*self.nearDistance
		if async then
			self:SynPosition(targetPos)
		end
	end
end

function SummonThing:IsAttacking()
	return self.attackState == 1
end

function SummonThing:StartAttack()
	local mainRole = self.sceneModel:GetMainPlayer()
	if mainRole then
		self.mainPkModel = mainRole.pkModel
	end
	self.targetListTemp = BattleManager.PkModelFilter(self.targetList)
	self.attackState = 1
end

function SummonThing:StopAttack()
	self.attackState = 0
	self.targetList = {}
	self.attackTarget = nil
	self.targetListTemp = nil
	self:Approaching(false)
end

function SummonThing:Attack()
	if not self:SelectTarget() then return end
	local skillInfo = self.skillIds[math.random(#self.skillIds)]
	local skillId = skillInfo[1]
	self.fightDistance = SkillManager.GetStaticSkillVo(skillId).fReleaseDist*0.01
	local ap = self.attackTarget.transform.position
	local p = self.transform.position
	local attackFunc = function()
		local fightRot = MapUtil.GetRotation(p, ap)
		local fightDir = fightRot and fightRot.eulerAngles.y or 0
		local msg = {}
		msg.type = 0 --施法类型
		msg.guid = self.guid--fightPlayerId 攻击者Id
		msg.fightTarget = self.attackTarget.guid --攻击目标Id
		msg.fightType = skillId --攻击类型(技能id)
		msg.fightDirection = fightDir --攻击朝向
		GlobalDispatcher:DispatchEvent(EventName.PlayerAttack, msg)
		self.attackInternal = skillInfo[2] * 0.001
	end

	local distance = Vector3.Distance(ap, p)
	if distance <= self.fightDistance then
		attackFunc()
	else
		self:MoveToTarget()
	end
end

function SummonThing:MoveToTarget()
	if not self.attackTarget then return end
	local pos = self.attackTarget.transform.position
	self.nearMoving = true
	local direct = (pos - self.transform.position):Normalize()
	local targetPos = pos + direct*(self.fightDistance*0.9)
	self:SynPosition(targetPos)
end

function SummonThing:SynPosition(pos, force)
	self.targetAsyncPos = pos
	if  Vector3.Distance(self.targetAsyncPos, self.asyncPos) > 2 or force  then
		self.asyncPos = pos
		self.sceneCtrl:C_SynPosition(self.guid, 1, pos, self:GetEulerAngles())
	end
end

function SummonThing:OnMainPlayerWalking()
	if not self.owner then return end
	local tf = self.owner.transform
	if not ToLuaIsNull(tf) and not ToLuaIsNull(self.transform) then
		local selfPos = self.transform.position
		local tfPos = tf.position
		if not self.attackTarget and Vector3.Distance(tfPos, selfPos)  < 3 then return end
		if Vector3.Distance(tfPos, selfPos) > self.maxAwayDistance   then
			self:StopAttack()
		else
			if not self:IsAttacking() then
				self:Approaching(true)
			end
		end
	end
end

function SummonThing:SetVo(vo)
	LivingThing.SetVo(self, vo)
end

function SummonThing:SetGameObject( gameObject )
	if ToLuaIsNull(gameObject) then return end
	LivingThing.SetGameObject(self, gameObject)
end

-- 
function SummonThing:Update()
	if not self:GetGameObject() then return end
	if self.isHitPlayer and not self.isWalking then
		self.isHitPlayer = nil
		self:SetColliderInfo("center", Vector3.New(0, self.bodyHeight*0.5, 0))
		self.characterController:Move(Vector3.up*0.01)
	end
	local dt = Time.deltaTime
	LivingThing.Update(self, dt)
	local target = self.attackTarget
	if self.attackState == 1 then
		if self:IsDie() then
			self:StopAttack()
			return
		end
		if target then
			local owner = target:GetOwnerPlayer()
			if (target:IsHuman() and target.vo and self.zdModel:IsTeamMate(target.vo.playerId)) or (target:IsSummonThing() 
				and owner and owner.vo and self.zdModel:IsTeamMate(owner.vo.playerId)) then
					self:StopAttack()
					return
			end
		end
		
		if self.nearMoving and target and not ToLuaIsNull(target.transform) then
			local distance = Vector3.Distance(target.transform.position, self.transform.position)
			if distance <= self.fightDistance then
				self.nearMoving = false
				self:Attack()
			else
				self:MoveToTarget()
			end
		else
			if self.attackInternal <= 0 then
				self:Attack()
			end
			self.attackInternal = self.attackInternal - dt
		end
	end
end

function SummonThing.GetVO( eid )
	local id = tonumber(eid)
	return SummonThingVo.GetCfg( id )
end
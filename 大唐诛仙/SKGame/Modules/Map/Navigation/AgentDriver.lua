-- AgentDriver
AgentDriver =BaseClass()

function AgentDriver:__init(tartget)
	self.tartget = tartget
	self.gameObject = self.tartget.gameObject
	self.transform = self.gameObject.transform
	self.isMainRole = self.tartget.isMainRole
	self.navMeshAgent = nil
	self.direction = nil
	self.moveSpeed = 7
	self.needMove = false
	self.agentMove = false
	self.targetPos = nil
	self.moveTarget = nil

	self.originalSpeed = self.moveSpeed
	self.movingCall = nil
	self.reachCompleteCall = nil
	self.nearDistance = 0
	self.nearDistanceCall = nil
	self.rotateSpeed = 12

	self.targetRot = nil

	self:AgentInit()
end
function AgentDriver:AgentInit()
	self.navMeshAgent = self.gameObject:GetComponent("NavMeshAgent")
	if ToLuaIsNull(self.navMeshAgent) then
		self.navMeshAgent = self.gameObject:AddComponent(typeof(UnityEngine.NavMeshAgent)) -- 寻路组件
	end
	self.navMeshAgent.speed = self.moveSpeed
	self.navMeshAgent.angularSpeed = 0
	self.navMeshAgent.acceleration = 100
	self.navMeshAgent.updateRotation = false
	self.navMeshAgent.radius = 0
	self.navMeshAgent.height = 0
	-- self.navMeshAgent.enabled = false
end
function AgentDriver:__delete()
	self.tartget = nil
	self.transform = nil
	self.navMeshAgent = nil
	self.direction = nil
	self.moveSpeed = nil
	self.needMove = nil
	self.agentMove = nil
	self.targetPos = nil
	self.moveTarget = nil

	self.originalSpeed = nil
	self.movingCall = nil
	self.reachCompleteCall = nil
	self.nearDistance = nil
	self.nearDistanceCall = nil
	self.rotateSpeed = nil

	self.targetRot = nil
end

function AgentDriver:SetMoveSpeed(moveSpeed)
	self.moveSpeed = moveSpeed
	self.originalSpeed = self.moveSpeed
	self.navMeshAgent.speed = self.moveSpeed
end

--移动到目标点
--@param targetPos 目标点
--@param speed 移动速度
--@param movigCall 移动过程中回调
--@param reachCompleteCall 寻路结束回调
--@param nearDistance 接近目标距离
--@param nearDistanceCall 接近目标距离回调
function AgentDriver:MoveToPos(targetPos, speed, movigCall, reachCompleteCall, nearDistance, nearDistanceCall)
	self.navMeshAgent = self.gameObject:GetComponent("NavMeshAgent")
	if ToLuaIsNull(self.navMeshAgent) then return end
	
	self:MoveClear()

	self.navMeshAgent:Resume()
	if speed and speed > 0 then
		self.navMeshAgent.speed = speed
	end
	if movigCall then
		self.movigCall = movigCall
	end
	if reachCompleteCall then
		self.reachCompleteCall = reachCompleteCall
	end
	if nearDistance and nearDistance > 0 then
		self.nearDistance = nearDistance
	end
	if nearDistanceCall then
		self.nearDistanceCall = nearDistanceCall
	end

	self.navMeshAgent.enabled = true
	self.targetPos = targetPos
	if self.tartget and self.tartget:IsMainPlayer() and targetPos == SceneModel:GetInstance().targetPos then
		if MapUtil.IsNearV3DistanceByXZ( targetPos, self.tartget:GetPosition(), 1.5) then
			self:StopMove()
			return
		end
	end

	self.navMeshAgent:SetDestination(self.targetPos)
	self.agentMove = true
	self.nextFrame = false
end

--移动到Transform目标
--@param target 目标
--@param speed 移动速度
--@param movigCall 移动过程中回调
--@param reachCompleteCall 寻路结束回调
--@param nearDistance 接近目标距离
--@param nearDistanceCall 接近目标距离回调
function AgentDriver:MoveToTarget(target, speed, movigCall, reachCompleteCall, nearDistance, nearDistanceCall)
	self.navMeshAgent = self.gameObject:GetComponent("NavMeshAgent")
	if ToLuaIsNull(self.navMeshAgent) then return end

	self:MoveClear()
	self.navMeshAgent:Resume()
	if speed and speed > 0 then
		self.navMeshAgent.speed = speed
	end
	if movigCall then
		self.movigCall = movigCall
	end
	if reachCompleteCall then
		self.reachCompleteCall = reachCompleteCall
	end
	if nearDistance and nearDistance > 0 then
		self.nearDistance = nearDistance
	end
	if nearDistanceCall then
		self.nearDistanceCall = nearDistanceCall
	end

	self.navMeshAgent.enabled = true
	self.moveTarget = target
	self.targetPos = self.moveTarget.transform.position
	self.navMeshAgent:SetDestination(self.targetPos)
	self.agentMove = true
	self.nextFrame = false
end

--按给定方向移动
function AgentDriver:MoveByDir(direction)
	self.navMeshAgent:Resume()
	self.navMeshAgent.enabled = true
	self.direction = direction
	self.needMove = true
end
	
--强制停止移动
function AgentDriver:StopMove()
	self.navMeshAgent = self.gameObject:GetComponent("NavMeshAgent")
	if ToLuaIsNull(self.navMeshAgent) then return end

	if self.isMainRole and not SceneModel:GetInstance():IsWayFinding() then
		GlobalDispatcher:DispatchEvent(EventName.Player_AutoRunEnd)
	end
	self.direction = nil
	self.needMove = false
	self.agentMove = false
	if self.navMeshAgent.hasPath then
		self.navMeshAgent:ResetPath()
	end
		self.navMeshAgent:Stop()
		if self.isMainRole then
			self.tartget:AsyncStop()
		end
	
	self:Reset()
end

function AgentDriver:StopAll()
	self.navMeshAgent = self.gameObject:GetComponent("NavMeshAgent")
	if ToLuaIsNull(self.navMeshAgent) then return end
	if self.tartget then
		self.tartget:DoStand()
	end
	if self.navMeshAgent.hasPath then
		self.navMeshAgent:ResetPath()
	end
		self.navMeshAgent:Stop()
		if self.isMainRole then
			self.tartget:AsyncStop()
		end
	self.direction = nil
	self.needMove = false
	self.agentMove = false
	self:MoveClear()
end

function AgentDriver:MoveClear()
	self.movigCall = nil
	self.reachCompleteCall = nil
	self.nearDistance = nil
	self.nearDistanceCall = nil
	self.moveTarget = nil
end

--重置
function AgentDriver:Reset()
	self.navMeshAgent.speed = self.originalSpeed
	self:MoveClear()
	self.tartget:DoStand()
	self.targetPos = nil
end

function AgentDriver:Update()
	if ToLuaIsNull(self.navMeshAgent) then return end
	if self.moveTarget and ToLuaIsNull(self.moveTarget.transform) then
		self:StopMove()
	end

	if self.tartget:IsLock()  then
		if self.agentMove then
			self:StopMove()
		end
		return		
	end
	local tf = self.transform
	if ToLuaIsNull(tf) then return end
	local dt = Time.deltaTime
	local position = tf.position
	if self.agentMove and self.tartget.vo then
		local pos = position + self.navMeshAgent.velocity*(100*dt)
		self.targetRot = MapUtil.GetRotation(position, pos)
		if self.targetRot then
			tf.rotation = Quaternion.Slerp(tf.rotation, self.targetRot, dt*self.rotateSpeed)
		end
		self.tartget:DoRun()
		if self.isMainRole then --保存角色当前位置，后端暂时没有同步
			self.tartget.vo.position = position
		end
		if self.nextFrame then
			if not self:IsMoving() then
				--到达目标点回调
				if self.reachCompleteCall then
					self.reachCompleteCall()
					self.reachCompleteCall = nil
				end
				if self.nearDistanceCall then
					self.nearDistanceCall()
					self.nearDistanceCall = nil
				end
				self:StopMove()
			else
				--移动过程中回调
				if self.movigCall then
					self.movigCall()
				end

				--接近目标点回调
				if self.nearDistanceCall and self.targetPos and self.nearDistance 
					and Vector3.Distance(position, self.targetPos) <= self.nearDistance then 
					self.nearDistanceCall()
					self.nearDistanceCall = nil
				end
			end
		end
		self.nextFrame = true
	end
	
	if self.moveTarget and self.moveTarget.transform then
		self.targetPos = self.moveTarget.transform.position
	end
	
	if self.needMove then
		if self.direction then
			local pos = position + self.direction*(dt*100)
			self.targetRot = MapUtil.GetRotation(position, pos)
			self:MoveToPos(pos)
			if GameConst.Debug and self.isMainRole then
				DebugMgr.ShowRoleXYZ( pos.x, pos.y, pos.z )
			end
		end
	end
end

function AgentDriver:IsMoving()
	self.navMeshAgent = self.gameObject:GetComponent("NavMeshAgent")
	if ToLuaIsNull(self.navMeshAgent) then return true end
	return (not ToLuaIsNull(self.navMeshAgent)) and self.navMeshAgent.enabled and (self.navMeshAgent.remainingDistance > self.navMeshAgent.stoppingDistance or self.navMeshAgent.pathPending or self.navMeshAgent.velocity ~= Vector3.zero)
end
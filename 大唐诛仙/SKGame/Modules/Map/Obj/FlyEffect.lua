FlyEffect =BaseClass()
FlyEffect.Fly_id = 10000

FlyEffect.Type = {
	No = 0,	
	Empty = 1, --1:空放
	Follow = 2, --2:最终目标
}

function FlyEffect:__init( vo )
	self.flyId = FlyEffect.Fly_id
	FlyEffect.Fly_id = FlyEffect.Fly_id + 1
	
	local go = GameObject.New("FlyEffect_"..self.flyId)
	go.layer = LayerMask.NameToLayer("FlyEffect")
	self.gameObject = go
	self.transform = go.transform

	self.canUpdate = false
	self.callBack = nil
	self.flyTransform = nil
	self.flyEnd = false

	self.type = FlyEffect.Type.No
end

function FlyEffect:SetEffect(effectName, speed, initPos, initRot, target, callBack, emptyPos)
	self.transform.localRotation = initRot
	self.transform.position = initPos

	self._speed = speed *0.01 -- 速度
	
	if emptyPos then
		self.emptyPos = emptyPos
		self.type = FlyEffect.Type.Empty
	else
		self.followTarget = target
		self.hitBone = self.followTarget:GetCenterBone()
		self.type = FlyEffect.Type.Follow
	end
	effectName = effectName or ""
	if effectName ~= "" then
		self.effectId = EffectMgr.BindTo(effectName, self.gameObject, nil, nil, nil, nil, function(eid)
			local flyEft = EffectMgr.GetEffectById(eid)
			local zidan = flyEft.transform:Find("zidan")
			if zidan then
				self.flyTransform = zidan.transform
			self.canUpdate = true
			end
		end)
	else
		self.canUpdate = true
		self.flyTransform = self.gameObject.transform
	end

	self.callBack = callBack
end

function FlyEffect:RemoveEffet()
	EffectMgr.RealseEffect(self.effectId)
	SceneController:GetInstance():GetScene():RemoveFlyEffect( self.flyId )
end

function FlyEffect:Update()
	if not self.canUpdate then return end
	
	if self.flyEnd or ToLuaIsNull(self.gameObject) or ToLuaIsNull(self.flyTransform) or 
		(self.type == FlyEffect.Type.Empty and self.emptyPos == nil) or
		(self.type == FlyEffect.Type.Follow and (self.followTarget.transform == nil or self.hitBone == nil)) then
		self:RemoveEffet()
		return
	end

	local targetPos = nil
	if self.emptyPos then
		self.flyEnd = true
		targetPos = self.emptyPos
	else
		if self.hitBone and self.hitBone.transform and self.hitBone.transform.position then
			targetPos = self.hitBone.transform.position
		elseif self.hitBone and self.hitBone.position then
			targetPos = self.hitBone.position
		else
			targetPos = self.emptyPos
		end
	end
	local p = self.flyTransform.position
	if not self.flyEnd and Vector3.Distance(targetPos, p) <= 0.5 then
		self.flyEnd = true
		if self.callBack then --到达目标回调
			self.callBack()
			self.callBack = nil
		end

	else
		local direction = (targetPos - p).normalized
		local newPos = p + direction*(Time.deltaTime*self._speed)
		local offSetDirection = (targetPos - newPos).normalized
		if direction == -offSetDirection then
			self.flyTransform.position = targetPos
		else
			self.flyTransform.position = newPos
		end
	end

end

function FlyEffect:__delete()
	if self.gameObject then	-- 清理VO的事件
		destroyImmediate(self.gameObject)
	end
	self:RemoveEffet()
	self.gameObject = nil
	self.transform = nil
	self.emptyPos = nil
	self.flyTransform = nil
end